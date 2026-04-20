/*
 * Copyright (c) Huawei Technologies Co., Ltd. 2024-2025. All rights reserved.
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

/* instrument ignore file */
import { BusinessError } from '@ohos.base';
import CommonEventManager from '@ohos.commonEventManager';
import common from '@ohos.app.ability.common';
import taskpool from '@ohos.taskpool';
import {
  CompCtrlParam,
  ComponentControl,
  SettingBaseModel,
} from '@ohos/settings.common/src/main/ets/framework/model/SettingBaseModel';
import { CommonEventHelper } from '@ohos/settings.common/src/main/ets/utils/CommonEventHelper';
import { LogUtil } from '@ohos/settings.common/src/main/ets/utils/LogUtil';
import { AbilityContextManager } from '@ohos/settings.common/src/main/ets/ability/AbilityContextManager';
import { PreferencesUtil } from '@ohos/settings.common/src/main/ets/utils/PreferencesUtil';
import { DateTimeUtil } from '@ohos/settings.common/src/main/ets/utils/DateTimeUtil';
import { BatteryManager } from '@ohos/settings.common/src/main/ets/batteryManager/BatteryManager';
import { EventBus } from '@ohos/settings.common/src/main/ets/framework/common/EventBus';
import { CommonEventConstant } from '@ohos/settings.common/src/main/ets/constant/CommonEventConstant';
import { CurrentMemScene, PerformanceReporter } from '@ohos/settings.common/src/main/ets/memery/PerformanceReporter';
import { BATTERY_STATE_CHANGE_EVENT } from '../constants/BatteryConsts';

const LAST_APP_POWER_DATA_TIME: string = 'LastAppPowerDataTime';
const DEFAULT_APP_POWER_DATA_TIME: number = 0;

@Concurrent
function getAppPowerData(startTimestamp: number, endTimestamp: number, context: common.Context): void {
  BatteryManager.getAppPowerDataFunForPhone(startTimestamp, endTimestamp, context);
}

@Concurrent
function getDeviceUsageDuration(startTimestamp: number, endTimestamp: number, context: common.Context): void {
  BatteryManager.getDeviceUsageDurationFun(startTimestamp, endTimestamp, context);
}

/**
 * 电池页面控制器类
 *
 * @since 2024-06-25
 */
export class BatteryPageController implements ComponentControl {
  public tag: string = 'BatteryPageController:';
  private subscribeInfo: CommonEventManager.CommonEventSubscribeInfo = {
    events: [
      CommonEventManager.Support.COMMON_EVENT_BATTERY_CHANGED,
      CommonEventManager.Support.COMMON_EVENT_CHARGING,
      CommonEventManager.Support.COMMON_EVENT_DISCHARGING,
    ]
  };

  private batteryStateEventHelper: CommonEventHelper = new CommonEventHelper(this.subscribeInfo, (err, data) => {
    LogUtil.info(`${this.tag} batteryStateEventHelper battery state changed`);
    EventBus.getInstance().emit(BATTERY_STATE_CHANGE_EVENT);
  });

  init(compParam: CompCtrlParam): void {
    LogUtil.info(`${this.tag} init`);
    this.batteryStateEventHelper.registerCommonEvent();
    PerformanceReporter.getInstance().reportExitMemScene(CurrentMemScene.START_BATTERY);
  }

  onPageShow(component: SettingBaseModel): void {
    LogUtil.info(`${this.tag} onPageShow`);
    this.updateChartData();
    EventBus.getInstance().emit(CommonEventConstant.EVENT_BATTERY_PAGE_SHOW);
  }

  private updateChartData() {
    let nowTime: number = new Date().getTime();
    let lastTime: number = Number(PreferencesUtil.getSync(LAST_APP_POWER_DATA_TIME, DEFAULT_APP_POWER_DATA_TIME));
    let isNeedUpdate = Math.abs(nowTime - lastTime) > (DateTimeUtil.getPerHourInMillis() / 2);
    LogUtil.info(`${this.tag} updateChartData. nowTime: ${nowTime} lastTime: ${lastTime}, isNeedUpdate: ${isNeedUpdate}`);
    if (!isNeedUpdate) {
      return;
    }
    LogUtil.info(`${this.tag} updateData. more than half hour`);
    let endTimestamp: number = DateTimeUtil.getPassTimestamp();
    let startTimestamp: number = endTimestamp - DateTimeUtil.getPerDayInMillis();
    LogUtil.info(`${this.tag} startTimestamp:${startTimestamp} endTimestamp:${endTimestamp}`);
    let taskGroup: taskpool.TaskGroup = new taskpool.TaskGroup;
    let context: Context = AbilityContextManager.getContext();
    if (taskpool.isConcurrent(getAppPowerData)) {
      taskGroup.addTask(getAppPowerData, startTimestamp, endTimestamp, context); // 更新app电池数据
    }
    if (taskpool.isConcurrent(getDeviceUsageDuration)) {
      taskGroup.addTask(getDeviceUsageDuration, startTimestamp, endTimestamp, context); // 更新设备使用数据
    }
    try {
      taskpool.execute(taskGroup, taskpool.Priority.HIGH).then(() => {
        LogUtil.info(`${this.tag} updateChart execute success`);
      }).catch((err: BusinessError) => {
        LogUtil.error(`${this.tag} updateChart execute error, code: ${err?.code}, msg: ${err?.message}`);
      });
    } catch (err) {
      LogUtil.error(`${this.tag} updateChart taskGroup error, code: ${err?.code}, msg: ${err?.message}`);
    }
  }

  onPageHide(): void {
    LogUtil.info(`${this.tag} onPageHide`);
    EventBus.getInstance().emit(CommonEventConstant.EVENT_BATTERY_PAGE_HIDE);
  }

  destroy(): void {
    LogUtil.info(`${this.tag} destroy`);
    this.batteryStateEventHelper.unRegisterCommonEvent();
    PerformanceReporter.getInstance().reportExitMemScene(CurrentMemScene.START_BATTERY);
  }
}

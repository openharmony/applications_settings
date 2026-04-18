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
import connection from '@ohos.net.connection';
import commonEventManager from '@ohos.commonEventManager';
import { CommonEventHelper } from '@ohos/settings.common/src/main/ets/utils/CommonEventHelper';
import {
  CompCtrlParam,
  ComponentControl,
  SettingBaseModel
} from '@ohos/settings.common/src/main/ets/framework/model/SettingBaseModel';
import { EventBus } from '@ohos/settings.common/src/main/ets/framework/common/EventBus';
import { HiSysEventUtil } from '@ohos/settings.common/src/main/ets/systemEvent/HiSysEventUtil';
import { HiSysNetworkGroup } from '@ohos/settings.common/src/main/ets/systemEvent/BehaviorEventConsts';
import { ItemResultType } from '@ohos/settings.common/src/main/ets/framework/model/SettingItemModel';
import { LogUtil } from '@ohos/settings.common/src/main/ets/utils/LogUtil';
import {
  notifyCompStateChange,
  SettingResultState,
  SettingStateType,
  SettingToggleState
} from '@ohos/settings.common/src/main/ets/framework/model/SettingStateModel';
import { SettingsDataUtils } from '@ohos/settings.common/src/main/ets/utils/SettingsDataUtils';

const TAG: string = 'AirPlaneModeSwitchController : ';
const AIR_PLANE_MODE: string = 'settings.telephony.airplanemode';
const AIR_PLANE_MODE_DEFAULT_VAL: string = '0';

export class AirPlaneModeSwitchController implements ComponentControl {
  private compId: string = '';
  /**
   * 当前开关状态
   */
  private isAirPlaneOn: boolean = false;
  private onToggleChange = (state: SettingToggleState) => {
    LogUtil.info(`${TAG} onToggleChange ${state.state}`);
    if (!this.handleCheckedChange(state.state)) {
      LogUtil.info(`${TAG} handleCheckedChange fail`);
      return false;
    }
    return true;
  }
  /**
   * 订阅者信息，飞行模式已更改的公共事件的动作
   */
  private subscribeInfo: commonEventManager.CommonEventSubscribeInfo = {
    events: [commonEventManager.Support.COMMON_EVENT_AIRPLANE_MODE_CHANGED]
  };
  /**
   * 订阅/取消订阅飞行模式的回调时间
   */
  private airPlaneModeCommonEvent: CommonEventHelper = new CommonEventHelper(this.subscribeInfo, async (err, data) => {
    LogUtil.info(`${TAG} airPlaneModeCommonEvent, code: ${err?.code},data: ${data?.code},
      currentStatus: ${this.isAirPlaneOn}`);
    if (!(err?.code as number) && this.isAirPlaneOn !== (data?.code ? true : false)) {
      this.updateStatus();
    }
  });

  init(param: CompCtrlParam): void {
    LogUtil.info(`${TAG} init`);
    if (!param) {
      LogUtil.error(`${TAG} init failed, param is empty.`);
      return;
    }
    this.compId = (param as CompCtrlParam).compId;
    LogUtil.info(`${TAG} init ${this.compId}`);
    EventBus.getInstance().on(`${this.compId}.toggle`, this.onToggleChange);
    this.airPlaneModeCommonEvent.registerCommonEvent();
    this.updateStatus();
  }

  destroy(): void {
    LogUtil.info(`${TAG} destroy`);
    EventBus.getInstance().detach(`${this.compId}.toggle`, this.onToggleChange);
    this.airPlaneModeCommonEvent.unRegisterCommonEvent();
  }

  onPageShow(component: SettingBaseModel): void {
    LogUtil.info(`${TAG} onPageShow`);
    this.updateCheckedState();
  }

  onPageHide(component: SettingBaseModel): void {
    LogUtil.info(`${TAG} onPageHide`);
  }

  protected updateCheckedState(): boolean {
    let value: string = SettingsDataUtils.getSettingsData(AIR_PLANE_MODE, AIR_PLANE_MODE_DEFAULT_VAL);
    this.isAirPlaneOn = value === AIR_PLANE_MODE_DEFAULT_VAL ? false : true;
    return this.isAirPlaneOn;
  }

  protected handleCheckedChange(isChecked: boolean): boolean {
    LogUtil.info(`${TAG} handleCheckedChange isChecked:${isChecked}`);
    if (isChecked && !this.isAirPlaneOn) {
      this.enableAirplaneMode();
    }
    if (!isChecked && this.isAirPlaneOn) {
      this.disableAirplaneMode();
    }
    this.isAirPlaneOn = isChecked;
    return true;
  }

  /**
   * 开启飞行模式开关
   */
  private enableAirplaneMode(): Promise<void> {
    LogUtil.info(`${TAG} enableAirplaneMode`);
    HiSysEventUtil.reportDefaultBehaviorEventByUE(HiSysNetworkGroup.PC_AIRPLANE_MODE_SWITCH, 'on');
    return connection.enableAirplaneMode().catch((error: Error) => {
      LogUtil.error(`${TAG} enableAirplaneMode, error: ${error?.message}`);
      this.updateStatus();
    });
  }

  /**
   * 关闭飞行模式开关
   */
  private disableAirplaneMode(): Promise<void> {
    LogUtil.info(`${TAG} disableAirplaneMode`);
    HiSysEventUtil.reportDefaultBehaviorEventByUE(HiSysNetworkGroup.PC_AIRPLANE_MODE_SWITCH, 'off');
    return connection.disableAirplaneMode().catch((error: Error) => {
      LogUtil.error(`${TAG} disableAirplaneMode, error: ${error?.message}`);
      this.updateStatus();
    });
  }

  private updateStatus(): void {
    LogUtil.info(`${TAG} updateStatus`);
    let isChecked = this.updateCheckedState();
    notifyCompStateChange(this.compId,
      new Map<SettingStateType, SettingResultState>([[SettingStateType.STATE_TYPE_ITEM_RESULT,
        {
          type: ItemResultType.RESULT_TYPE_TOGGLE,
          result: {
            state: isChecked,
          },
        } as SettingResultState]]));
  }
}
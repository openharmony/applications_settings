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
import { EventBus } from '@ohos/settings.common/src/main/ets/framework/common/EventBus';
import { CompCtrlParam, ComponentControl } from '@ohos/settings.common/src/main/ets/framework/model/SettingBaseModel';
import { ItemResultType } from '@ohos/settings.common/src/main/ets/framework/model/SettingItemModel';
import {
  notifyCompStateChange,
  SettingBaseState,
  SettingResultState,
  SettingStateType,
  SettingToggleState,
} from '@ohos/settings.common/src/main/ets/framework/model/SettingStateModel';
import { LogUtil } from '@ohos/settings.common/src/main/ets/utils/LogUtil';
import { DeviceUtil } from '@ohos/settings.common/src/main/ets/utils/BaseUtils';
import { SettingsDataUtils } from '@ohos/settings.common/src/main/ets/utils/SettingsDataUtils';
import { HiSysEventUtil } from '@ohos/settings.common/src/main/ets/systemEvent/HiSysEventUtil';
import { HiSysBatteryEventGroup } from '@ohos/settings.common/src/main/ets/systemEvent/BehaviorEventConsts';
import { EventResultConsts } from '@ohos/settings.common/src/main/ets/systemEvent/EventResultConsts';

const TAG: string = 'DisplayBatteryPercentageSwitchController: ';
const BATTERY_PERCENTAGE_SWITCHES_TABLE: string = 'status_bar_show_battery_soc';

export class DisplayBatteryPercentageSwitchController implements ComponentControl {
  public compId?: string;
  public isChecked: boolean = false;
  private toggleStateChangeEventCallback = (toggleState: SettingToggleState) => {
    if (!toggleState) {
      LogUtil.error(`${TAG} toggleModel is invalid`);
      return;
    }

    LogUtil.info(`${TAG} toggleStateChange: ${toggleState.state}`);
    this.handleCheckedChange(toggleState.state);
  };

  init(compParam: CompCtrlParam): void {
    if (!compParam || !compParam.compId) {
      LogUtil.error(`${TAG} init fail, compParam is invalid`);
      return;
    }
    LogUtil.info(`${TAG} init compId: ${compParam?.compId}`);
    this.compId = compParam?.compId;
    this.isChecked = this.updateCheckedState();
    // 监听界面开关状态变化
    EventBus.getInstance().on(`${this.compId}.toggle`, this.toggleStateChangeEventCallback);
    // 发消息更新开关初始状态
    this.refreshUi();
  }

  destroy(): void {
    LogUtil.info(`${TAG} destroy`);
    EventBus.getInstance().detach(`${this.compId}.toggle`, this.toggleStateChangeEventCallback);
  }

  private refreshUi(): void {
    notifyCompStateChange(`${this.compId}`, new Map<SettingStateType, SettingBaseState>(
      [[SettingStateType.STATE_TYPE_ITEM_RESULT, {
        type: ItemResultType.RESULT_TYPE_TOGGLE,
        result: { state: this.isChecked } as SettingToggleState
      } as SettingResultState]]
    ));
  }

  /*
   * 返回开关的实时状态
   */
  private updateCheckedState(): boolean {
    // 获取当前系统设置中的显示电池百分比开关的状态 默认true(该规格由状态栏领域确认)
    const value = SettingsDataUtils.getSecureValue(BATTERY_PERCENTAGE_SWITCHES_TABLE,
      DeviceUtil.is2In1DevicePcType() ? 'false' : 'true');
    LogUtil.info(`${TAG} updateCheckedState. value:${value}`);
    return value === 'true';
  }

  /*
   * 开关变化的回调
   */
  private handleCheckedChange(isChecked: boolean): void {
    LogUtil.info(`${TAG} handleCheckedChange. isChecked:${isChecked} this.isChecked:${this.isChecked}`);
    if (isChecked === this.isChecked) {
      return;
    }
    HiSysEventUtil.reportDefaultBehaviorEventByUE(HiSysBatteryEventGroup.BATTERY_PERCENTAGE_SWITCH,
      isChecked ? EventResultConsts.SWITCH_ON : EventResultConsts.SWITCH_OFF);
    this.isChecked = isChecked;
    SettingsDataUtils.setSecureValue(BATTERY_PERCENTAGE_SWITCHES_TABLE, isChecked ? 'true' : 'false');
  }
}
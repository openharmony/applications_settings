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

import netQuality from '@hms.networkboost.netquality';
import { CompCtrlParam, ComponentControl } from '@ohos/settings.common/src/main/ets/framework/model/SettingBaseModel';
import { LogUtil } from '@ohos/settings.common/src/main/ets/utils/LogUtil';
import { EventBus } from '@ohos/settings.common/src/main/ets/framework/common/EventBus';
import { HiSysEventUtil } from '@ohos/settings.common/src/main/ets/systemEvent/HiSysEventUtil';
import { HiSysSystemEventGroup } from '@ohos/settings.common/src/main/ets/systemEvent/BehaviorEventConsts';
import {
  notifyCompStateChange,
  SettingBaseState,
  SettingResultState,
  SettingStateType,
  SettingToggleState
} from '@ohos/settings.common/src/main/ets/framework/model/SettingStateModel';
import { ItemResultType } from '@ohos/settings.common/src/main/ets/framework/model/SettingItemModel';
import { SearchDataController } from '@ohos/settings.search/src/main/ets/controller/SearchController';
/* instrument ignore file */
export const NETWORK_NAVIGATOR_SWITCH: string = 'NetworkNavigatorSwitch';

const TAG: string = 'NetworkNavigatorSwitchController : ';

export class NetworkNavigatorSwitchController implements ComponentControl {
  private compId: string = '';
  private isSwitchOn: boolean = false;
  private toggleStateChangeEventCallback = (toggleState: SettingToggleState) => {
    if (!toggleState) {
      LogUtil.error(`${TAG} toggleModel is invalid`);
      return;
    }
    this.handleCheckedChange(toggleState.state);
  };

  init(compParam: CompCtrlParam): void {
    if (!compParam || !compParam.compId) {
      LogUtil.showError(TAG, `init fail, compParam is invalid`);
      return;
    }
    LogUtil.info(`${TAG} init`);
    this.compId = compParam?.compId;
    this.updateCheckedState();
    this.refreshUi();
    // 监听界面开关状态变化
    EventBus.getInstance().on(`${this.compId}.toggle`, this.toggleStateChangeEventCallback);
  }

  private handleCheckedChange(isChecked: boolean): void {
    LogUtil.info(`${TAG} handleCheckedChange, isChecked: ${isChecked}, this.getChecked(): ${this.isSwitchOn}`);
    SearchDataController.getInstance().updateChildItemSearchStatus('network_navigator_entry', isChecked);
    HiSysEventUtil.reportDefaultBehaviorEventByUE(HiSysSystemEventGroup.NETWORK_NAVIGATOR_SWITCH,
      isChecked ? 'on' : 'off');
    if (isChecked === this.isSwitchOn) {
      LogUtil.info(`${TAG} handleCheckedChange isChecked not change : ${isChecked}`);
      return;
    }
    try {
      netQuality.setNetSimulatorEnabled(isChecked);
      this.isSwitchOn = isChecked;
      this.updateCheckedState();
    } catch (err) {
      LogUtil.error(`${TAG} setNetSimulatorEnabled err:${err?.code}-${err?.message}`);
    }
  }

  private updateCheckedState(): void {
    try {
      this.isSwitchOn = netQuality.isNetSimulatorEnabled();
    } catch (err) {
      LogUtil.error(`${TAG} isNetSimulatorEnabled err:${err?.code}-${err?.message}`);
    }
    EventBus.getInstance().emit(NETWORK_NAVIGATOR_SWITCH, this.isSwitchOn);
    LogUtil.info(`${TAG} updateCheckedState : ${this.isSwitchOn}`);
  }

  private refreshUi(): void {
    notifyCompStateChange(`${this.compId}`, new Map<SettingStateType, SettingBaseState>(
      [[SettingStateType.STATE_TYPE_ITEM_RESULT, {
        type: ItemResultType.RESULT_TYPE_TOGGLE,
        result: { state: this.isSwitchOn } as SettingToggleState
      } as SettingResultState]]
    ));
  }

  destroy(): void {
    LogUtil.info(`${TAG} destroy`);
    EventBus.getInstance().detach(`${this.compId}.toggle`, this.toggleStateChangeEventCallback);
  }
}
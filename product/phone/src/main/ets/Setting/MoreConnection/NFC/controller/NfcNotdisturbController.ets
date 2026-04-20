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
import Settings from '@ohos.settings';
import { EventBus } from '@ohos/settings.common/src/main/ets/framework/common/EventBus';
import {
  CompCtrlParam,
  ComponentControl,
  SettingBaseModel
} from '@ohos/settings.common/src/main/ets/framework/model/SettingBaseModel';
import { ItemResultType } from '@ohos/settings.common/src/main/ets/framework/model/SettingItemModel';
import {
  notifyCompStateChange,
  SettingBaseState,
  SettingResultState,
  SettingStateType,
  SettingToggleState,
} from '@ohos/settings.common/src/main/ets/framework/model/SettingStateModel';
import { HiSysNfcEventGroup } from '@ohos/settings.common/src/main/ets/systemEvent/BehaviorEventConsts';
import { HiSysEventUtil } from '@ohos/settings.common/src/main/ets/systemEvent/HiSysEventUtil';
import { LogUtil } from '@ohos/settings.common/src/main/ets/utils/LogUtil';
import { SettingsDataUtils } from '@ohos/settings.common/src/main/ets/utils/SettingsDataUtils';
/* instrument ignore file */
const TAG: string = 'NfcNotDisturbController';
export const NFC_NOT_DISTURB: string = 'settings.nfc.not_disturb';
export const ON: string = '1';
export const OFF: string = '0';

export class NfcNotDisturbController implements ComponentControl {
  private compId: string = '';
  private isChecked: boolean = false;
  private toggleStateChangeCallback = (toggleState: SettingToggleState) => {
    if (!toggleState) {
      LogUtil.error(`${TAG} toggleModel is invalid`);
      return;
    }
    if (toggleState.state === this.isChecked) {
      LogUtil.warn(`${TAG} target state equal to current state`);
      return;
    }
    this.isChecked = toggleState.state;
    LogUtil.info(`${TAG} this.isChecked ${this.isChecked}`);
    this.handleCheckedChange(toggleState.state);
  };

  async init(compParam: CompCtrlParam) {
    LogUtil.info(`${TAG} init`);
    if (!compParam) {
      LogUtil.error(`${TAG} init fail, compParam is invalid`);
      return;
    }
    this.compId = compParam.compId;
    EventBus.getInstance().on(`${this.compId}.toggle`, this.toggleStateChangeCallback);
    SettingsDataUtils.getSettingsDataAsync(NFC_NOT_DISTURB, '0').then((nfcNotDisturbSwitchMode) => {
      this.isChecked = nfcNotDisturbSwitchMode === ON;
      this.refreshUi(this.compId, this.isChecked);
    });
  }

  onPageShow(component: SettingBaseModel): void {
    LogUtil.info(`${TAG} onPageShow`);
  }

  onPageHide(component: SettingBaseModel): void {
    LogUtil.info(`${TAG} onPageHide`);
  }

  destroy(): void {
    LogUtil.info(`${TAG} destroy`);
    EventBus.getInstance().detach(`${this.compId}.toggle`, this.toggleStateChangeCallback);
  }

  private handleCheckedChange(isChecked: boolean): void {
    LogUtil.info(`${TAG} handleCheckedChange isChecked ${isChecked}`);
    HiSysEventUtil.reportDefaultBehaviorEventByUE(HiSysNfcEventGroup.NFC_NOT_DISTURB, isChecked ? 'true' : 'false');
    SettingsDataUtils.setSettingsData(NFC_NOT_DISTURB, isChecked ? ON : OFF,
      Settings.domainName.DEVICE_SHARED);
  }

  private refreshUi(compId: string, isChecked: boolean): void {
    notifyCompStateChange(compId, new Map<SettingStateType, SettingBaseState>(
      [[SettingStateType.STATE_TYPE_ITEM_RESULT, {
        type: ItemResultType.RESULT_TYPE_TOGGLE,
        result: { state: isChecked } as SettingToggleState
      } as SettingResultState]]
    ));
  }
}
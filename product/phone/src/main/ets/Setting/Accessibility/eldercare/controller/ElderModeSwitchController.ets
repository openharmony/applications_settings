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
import dataShare from '@ohos.data.dataShare';
import { EventBus } from '@ohos/settings.common/src/main/ets/framework/common/EventBus';
import {
  CompCtrlParam,
  ComponentControl,
  SettingBaseModel
} from '@ohos/settings.common/src/main/ets/framework/model/SettingBaseModel';
import { ItemResultType } from '@ohos/settings.common/src/main/ets/framework/model/SettingItemModel';
import {
  notifyCompStateChange,
  SettingResultState,
  SettingStateType,
  SettingToggleState
} from '@ohos/settings.common/src/main/ets/framework/model/SettingStateModel';
import { HiSysEventUtil } from '@ohos/settings.common/src/main/ets/systemEvent/HiSysEventUtil';
import { LogUtil } from '@ohos/settings.common/src/main/ets/utils/LogUtil';
import { SettingsDataUtils } from '@ohos/settings.common/src/main/ets/utils/SettingsDataUtils';
import {
  CloseElderCare,
  ElderCareManager,
  ElderCareUtils,
  OpenElderCare
} from '@ohos/settings.accessibility/src/main/ets/ElderCareUtils';
import { HiSysElderCareEventGroup } from '@ohos/settings.common/src/main/ets/systemEvent/BehaviorEventConsts';

const TAG: string = 'ElderCareSwitchController :';
const ACCESSIBILITY_ELDER_CARE_SWITCH_ENABLED: string = 'accessibility_elder_care_switch_enabled';
const WAIT_TIME = 300;
const SWITCH_DELAY = 200;
const SWITCH_OFF: string = '0';
const SWITCH_ON: string = '1';
const ELDER_CARE_SWITCH_TOGGLE_ID = 'Setting.ElderCare.elder_care_switch_group.elder_care_switch';

/**
 * 关怀模式-Switch-controller
 *
 * @since 2024-11-02
 */
export class ElderCareSwitchController implements ComponentControl {
  protected dataHelper?: dataShare.DataShareHelper;
  private isChecked: boolean = true;
  private compId: string = '';
  private switchTimerId: number | null = null;
  private toggleStateChangeEventCallback = (toggleState: SettingToggleState) => {
    this.refreshSwitchEnabled(toggleState.state, false);
    if (!toggleState) {
      LogUtil.error(`${TAG} toggleModel is invalid`);
      return;
    }
    let isChecked: boolean = toggleState.state;
    let elderCareState: boolean = SettingsDataUtils.getSecureValue(ACCESSIBILITY_ELDER_CARE_SWITCH_ENABLED,
      SWITCH_OFF) === SWITCH_ON;
    LogUtil.info(`${TAG} toggleState: ${isChecked} eldercareswitch: ${elderCareState}`);
    if (isChecked === elderCareState) {
      this.recoveryToggleEnabledState(isChecked, false);
      return;
    }
    SettingsDataUtils.setSecureValue(ACCESSIBILITY_ELDER_CARE_SWITCH_ENABLED, isChecked ? SWITCH_ON : SWITCH_OFF);
    ElderCareUtils.updateElderCareSearchItemStatus(isChecked);
    HiSysEventUtil.reportDefaultBehaviorEventByUE(
      HiSysElderCareEventGroup.ELDER_CARE_SWITCH_CLICK, isChecked ? SWITCH_ON : SWITCH_OFF);
    this.recoveryToggleEnabledState(isChecked, true);
  };

  init(compParam: CompCtrlParam): void {
    LogUtil.info(`${TAG} `);
    this.registerDataChange()
    if (!compParam || !compParam.compId) {
      LogUtil.error(`${TAG} init fail, compParam is invalid`);
      return;
    }
    this.compId = compParam.compId;
    let isChecked: boolean = SettingsDataUtils.getSecureValue(ACCESSIBILITY_ELDER_CARE_SWITCH_ENABLED,
      SWITCH_OFF) === SWITCH_ON;
    LogUtil.info(`${TAG} init toggleState: ${isChecked}`)
    this.setChecked(isChecked);
    EventBus.getInstance().on(`${ELDER_CARE_SWITCH_TOGGLE_ID}.toggle`, this.toggleStateChangeEventCallback);
  }

  onPageShow(component: SettingBaseModel): void {
    LogUtil.info(`${TAG} onPageShow`);
  }

  onPageHide(component: SettingBaseModel): void {
    LogUtil.info(`${TAG} onPageHide`);
  }

  destroy(): void {
    LogUtil.info(`${TAG} destroy -- ${this.compId}`);
    this.unRegisterDataChange()
    EventBus.getInstance().detach(`${ELDER_CARE_SWITCH_TOGGLE_ID}.toggle`, this.toggleStateChangeEventCallback);
  }

  protected setChecked(isChecked: boolean): void {
    LogUtil.showInfo(TAG, `setChecked ${isChecked}`);
    if (this.isChecked !== isChecked) {
      this.isChecked = isChecked;
      LogUtil.showInfo(TAG, `setChecked, refresh: ${this.isChecked}`);
      this.refreshUi();
    }
  }

  protected refreshUi(): void {
    notifyCompStateChange(ELDER_CARE_SWITCH_TOGGLE_ID,
      new Map<SettingStateType, SettingResultState>([[SettingStateType.STATE_TYPE_ITEM_RESULT,
        { type: ItemResultType.RESULT_TYPE_TOGGLE, result: { state: this.isChecked } } as SettingResultState]]));
  }

  private onDataChange(): void {
    let isVisible = SettingsDataUtils.getSecureValue(ACCESSIBILITY_ELDER_CARE_SWITCH_ENABLED,
      SWITCH_OFF) === SWITCH_ON;
    notifyCompStateChange(ELDER_CARE_SWITCH_TOGGLE_ID,
      new Map<SettingStateType, SettingResultState>([[SettingStateType.STATE_TYPE_ITEM_RESULT,
        { type: ItemResultType.RESULT_TYPE_TOGGLE, result: { state: isVisible } } as SettingResultState]]));
    LogUtil.info(`onDataChange isVisible ${isVisible}`)
    if (isVisible) {
      SettingsDataUtils.setSecureValue(ElderCareUtils.ELDER_CARE_HAS_ENABLED, 'true');
    }
  }

  registerDataChange() {
    if (this.dataHelper) {
      SettingsDataUtils.registerSecurityDataChange(this.dataHelper, ACCESSIBILITY_ELDER_CARE_SWITCH_ENABLED,
        this.onDataChange)
    } else {
      (SettingsDataUtils.createSecurityDataHelper(ACCESSIBILITY_ELDER_CARE_SWITCH_ENABLED) as
      Promise<dataShare.DataShareHelper>).then((dataShareHelper?: dataShare.DataShareHelper | undefined) => {
        if (dataShareHelper) {
          this.dataHelper = dataShareHelper;
          SettingsDataUtils.registerSecurityDataChange(this.dataHelper, ACCESSIBILITY_ELDER_CARE_SWITCH_ENABLED,
            this.onDataChange);
        }
      })
    }
    LogUtil.info(`${TAG} elder care key listener registerd`);
  }

  unRegisterDataChange() {
    SettingsDataUtils.unRegisterSecurityDataChange(this.dataHelper as dataShare.DataShareHelper,
      ACCESSIBILITY_ELDER_CARE_SWITCH_ENABLED);
    LogUtil.info(`${TAG} elder care key listener unregisterd`);
  }

  private refreshSwitchEnabled(state: boolean, enabled: boolean): void {
    notifyCompStateChange(ELDER_CARE_SWITCH_TOGGLE_ID,
      new Map<SettingStateType, SettingResultState>([[SettingStateType.STATE_TYPE_ITEM_RESULT,
        { type: ItemResultType.RESULT_TYPE_TOGGLE, result: { state: state, enabled: enabled } } as
        SettingResultState]]));
  }

  private stopTask(): void {
    if (this.switchTimerId !== null) {
      LogUtil.showInfo(TAG, 'stop existing switchTimerId task');
      clearTimeout(this.switchTimerId);
      this.switchTimerId = null;
    }
  }

  private recoveryToggleEnabledState(isChecked: boolean, isNeedExecute: boolean): void {
    this.stopTask();
    this.switchTimerId = setTimeout(() => {
      if (isNeedExecute) {
        let elderCareManager: ElderCareManager = new ElderCareManager(isChecked ? new OpenElderCare() :
          new CloseElderCare());
        elderCareManager.doSetting();
      }
      setTimeout(() => {
        this.refreshSwitchEnabled(isChecked, true);
      }, SWITCH_DELAY);
    }, WAIT_TIME);
  }
}
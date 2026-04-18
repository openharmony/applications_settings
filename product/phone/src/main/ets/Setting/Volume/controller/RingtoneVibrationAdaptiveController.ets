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
import { CommonEventConstant } from '@ohos/settings.common/src/main/ets/constant/CommonEventConstant';
import { EventBus } from '@ohos/settings.common/src/main/ets/framework/common/EventBus';
import { ItemResultType } from '@ohos/settings.common/src/main/ets/framework/model/SettingItemModel';
import { HiSysVolumeEventGroup } from '@ohos/settings.common/src/main/ets/systemEvent/BehaviorEventConsts';
import { HiSysEventUtil } from '@ohos/settings.common/src/main/ets/systemEvent/HiSysEventUtil';
import { LogUtil } from '@ohos/settings.common/src/main/ets/utils/LogUtil';
import { SettingsDataUtils } from '@ohos/settings.common/src/main/ets/utils/SettingsDataUtils';
import {
  CompCtrlParam,
  ComponentControl
} from '@ohos/settings.common/src/main/ets/framework/model/SettingBaseModel';
import {
  notifyCompStateChange,
  SettingResultState,
  SettingStateType,
  SettingToggleState
} from '@ohos/settings.common/src/main/ets/framework/model/SettingStateModel';

const RINGTONE_VIBRATION_ADAPTIVE: string = 'ringtone_vibrate_adaptive_switch';
const TAG: string = 'RingtoneVibrationAdaptiveController';

/**
 * 铃声振动自适应controller
 *
 * @since 2025-07-15
 */
export class RingtoneVibrationAdaptiveController implements ComponentControl {
  private isChecked: boolean = true;
  private compId: string = '';
  private onPageShowCallback = () => this.onPageShow();
  private onPageHideCallback = () => this.onPageHide();
  private toggleStateChangeEventCallback = (toggleState: SettingToggleState) => {
    if (!toggleState || toggleState.state === this.isChecked) {
      LogUtil.error(`${TAG} toggleState is invalid or state is equal`);
      return;
    }
    let isChecked: boolean = toggleState.state;
    LogUtil.info(`${TAG} toggleStateChangeEventCallback toggleState: ${isChecked}`);
    HiSysEventUtil.reportDefaultBehaviorEventByUE(HiSysVolumeEventGroup.VOLUME_RINGTONE_VIBRATION_SWITCH,
      isChecked ? 'On' : 'off');
    SettingsDataUtils.setSettingsData(RINGTONE_VIBRATION_ADAPTIVE, isChecked ? 'true' : 'false');
    this.setChecked(isChecked);
  };

  init(compParam: CompCtrlParam): void {
    LogUtil.info(`${TAG} init`);
    this.compId = compParam?.compId;
    EventBus.getInstance().on(CommonEventConstant.EVENT_VOLUME_PAGE_SHOW, this.onPageShowCallback);
    EventBus.getInstance().on(CommonEventConstant.EVENT_VOLUME_PAGE_HIDE, this.onPageHideCallback);
    EventBus.getInstance().on(`${this.compId}.toggle`, this.toggleStateChangeEventCallback);
    this.refreshState();
  }

  onPageShow(): void {
    LogUtil.info(`${TAG} onPageShow`);
    this.refreshState();
  }

  onPageHide(): void {
    LogUtil.info(`${TAG} onPageHide`);
  }

  destroy(): void {
    LogUtil.info(`${TAG} destroy`);
    EventBus.getInstance().detach(CommonEventConstant.EVENT_VOLUME_PAGE_SHOW, this.onPageShowCallback);
    EventBus.getInstance().detach(CommonEventConstant.EVENT_VOLUME_PAGE_HIDE, this.onPageHideCallback);
    EventBus.getInstance().detach(`${this.compId}.toggle`, this.toggleStateChangeEventCallback);
  }

  private refreshState(): void {
    SettingsDataUtils.getSettingsDataAsync(RINGTONE_VIBRATION_ADAPTIVE, 'true').then((state: string) => {
      let isChecked: boolean = state === 'true';
      LogUtil.info(`${TAG} refreshState state: ${isChecked}`);
      this.setChecked(isChecked);
    });
  }

  private setChecked(isChecked: boolean): void {
    LogUtil.showInfo(TAG, `setChecked new status: ${isChecked}, old status ${this.isChecked}`);
    if (this.isChecked !== isChecked) {
      this.isChecked = isChecked;
      this.refreshUi();
    }
  }

  private refreshUi(): void {
    notifyCompStateChange(this.compId,
      new Map<SettingStateType, SettingResultState>([[SettingStateType.STATE_TYPE_ITEM_RESULT,
        { type: ItemResultType.RESULT_TYPE_TOGGLE, result: { state: this.isChecked } } as SettingResultState]]));
  }
}
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
import settings from '@ohos.settings';
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
import { HiSysVolumeGroup } from '@ohos/settings.common/src/main/ets/systemEvent/BehaviorEventConsts';
import { HiSysEventUtil } from '@ohos/settings.common/src/main/ets/systemEvent/HiSysEventUtil';
import { EventResultConsts } from '@ohos/settings.common/src/main/ets/systemEvent/EventResultConsts';
import { LogUtil } from '@ohos/settings.common/src/main/ets/utils/LogUtil';
import { SettingsDataUtils } from '@ohos/settings.common/src/main/ets/utils/SettingsDataUtils';

const HW_VIBRATE_WHEN_RINGING: string = 'hw_vibrate_when_ringing';
const TAG: string = 'VibrateWhenRingController';

export class VibrateWhenRingController implements ComponentControl {
  public isChecked: boolean = true;
  private compId: string = '';
  private toggleStateChangeEventCallback = (toggleState: SettingToggleState) => {
    let context: Context = SettingsDataUtils.getContext();
    if (!toggleState) {
      LogUtil.error(`${TAG} toggleModel is invalid`);
      return;
    }
    let isChecked: boolean = toggleState.state;
    LogUtil.info(`${TAG} toggleState: ${isChecked}`);
    HiSysEventUtil.reportDefaultBehaviorEventByUE(HiSysVolumeGroup.VIBRATE_WHEN_RING_SWITCH,
      isChecked ? EventResultConsts.SWITCH_ON : EventResultConsts.SWITCH_OFF);
    SettingsDataUtils.setSettingsDataAsyncWithContext(context, HW_VIBRATE_WHEN_RINGING,
      isChecked ? '1' : '0', settings.domainName.USER_PROPERTY);
    this.setChecked(isChecked);
  };

  init(compParam: CompCtrlParam): void {
    this.compId = compParam?.compId;
    let context: Context = SettingsDataUtils.getContext();
    LogUtil.info(`${TAG} init`);
    let isChecked: boolean = SettingsDataUtils.getSettingsDataWithContext(context, HW_VIBRATE_WHEN_RINGING, '1',
      settings.domainName.USER_PROPERTY) === '1';
    this.setChecked(isChecked);
    EventBus.getInstance()
      .on(`${this.compId}.toggle`, this.toggleStateChangeEventCallback);
    // 监听开关值的变化
    SettingsDataUtils.registerKeyObserverUser(HW_VIBRATE_WHEN_RINGING, () => {
      let isChecked: boolean = SettingsDataUtils.getSettingsDataWithContext(context, HW_VIBRATE_WHEN_RINGING, '1',
        settings.domainName.USER_PROPERTY) === '1';
      this.setChecked(isChecked);
    });
  }

  onPageShow(component: SettingBaseModel): void {
    LogUtil.info(`${TAG} onPageShow`);
    SettingsDataUtils.getSettingsDataAsync(HW_VIBRATE_WHEN_RINGING, '1',
      settings.domainName.USER_PROPERTY).then(state => {
      let isChecked: boolean = state === '1';
      LogUtil.info(`${TAG} onPageShow toggleState: ${isChecked}`);
      this.setChecked(isChecked);
    });
  }

  onPageHide(component: SettingBaseModel): void {
    LogUtil.info(`${TAG} onPageHide`);
  }

  destroy(): void {
    LogUtil.info(`${TAG} destroy`);
    EventBus.getInstance()
      .detach(`${this.compId}.toggle`, this.toggleStateChangeEventCallback);
    SettingsDataUtils.unregisterKeyObserverUser(HW_VIBRATE_WHEN_RINGING);
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
    notifyCompStateChange(this.compId,
      new Map<SettingStateType, SettingResultState>([[SettingStateType.STATE_TYPE_ITEM_RESULT,
        { type: ItemResultType.RESULT_TYPE_TOGGLE, result: { state: this.isChecked } } as SettingResultState]]));
  }
}
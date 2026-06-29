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
import emitter from '@ohos.events.emitter';
import { EventBus } from '@ohos/settings.common/src/main/ets/framework/common/EventBus';
import {
  CompCtrlParam,
  ComponentControl,
} from '@ohos/settings.common/src/main/ets/framework/model/SettingBaseModel';
import { ItemResultType } from '@ohos/settings.common/src/main/ets/framework/model/SettingItemModel';
import {
  notifyCompStateChange,
  SettingResultState,
  SettingStateType,
  SettingToggleState
} from '@ohos/settings.common/src/main/ets/framework/model/SettingStateModel';
import { HiSysEventUtil } from '@ohos/settings.common/src/main/ets/systemEvent/HiSysEventUtil';
import { HiSysVolumeGroup } from '@ohos/settings.common/src/main/ets/systemEvent/BehaviorEventConsts';
import { EventResultConsts } from '@ohos/settings.common/src/main/ets/systemEvent/EventResultConsts';
import { LogUtil } from '@ohos/settings.common/src/main/ets/utils/LogUtil';
import { SettingsDataUtils } from '@ohos/settings.common/src/main/ets/utils/SettingsDataUtils';
import { EVENT_ID_LOCK_SCREEN_TONE } from '@ohos/settings.common/src/main/ets/event/types';
import { ToggleMenuController } from './VolumeController';

const TAG: string = 'ScreenLockToggleController';
const LOCKSCREEN_SOUNDS_ENABLED: string = 'lockscreen_sounds_enabled';

export class ScreenLockToggleController extends ToggleMenuController implements ComponentControl {
  private compId: string = '';
  private toggleStateChangeEventCallback = (toggleState: SettingToggleState) => {
    if (!toggleState) {
      LogUtil.error(`${TAG} toggleModel is invalid`);
      return;
    }
    let isChecked: boolean = toggleState.state;
    LogUtil.info(`${TAG} setSettingsData lockscreen sounds enabled: ${isChecked}`);
    HiSysEventUtil.reportDefaultBehaviorEventByUE(HiSysVolumeGroup.SCREEN_LOCK_TONE_SWITCH,
      isChecked ? EventResultConsts.SWITCH_ON : EventResultConsts.SWITCH_OFF);
    SettingsDataUtils.setSettingsDataDomain(LOCKSCREEN_SOUNDS_ENABLED, isChecked ? '1' : '0',
      settings.domainName.USER_PROPERTY);
    this.setChecked(isChecked);
  };

  init(compParam: CompCtrlParam): void {
    LogUtil.showDebug(TAG, 'init');
    this.compId = compParam?.compId;
    let isChecked: boolean =
      SettingsDataUtils.getSettingsDataDomain(LOCKSCREEN_SOUNDS_ENABLED, '1', settings.domainName.USER_PROPERTY) ===
        '1';
    LogUtil.info(`${TAG} getSettingsData lockscreen sounds enabled: ${isChecked}`);
    this.setChecked(isChecked);
    emitter.on({
      eventId: EVENT_ID_LOCK_SCREEN_TONE,
    }, (eventData: emitter.EventData) => {
      let isChecked: boolean =
        SettingsDataUtils.getSettingsDataDomain(LOCKSCREEN_SOUNDS_ENABLED, '1', settings.domainName.USER_PROPERTY) ===
          '1';
      LogUtil.info(`${TAG} emitter lockscreen sounds ${isChecked}`);
      this.setChecked(isChecked);
      this.refreshUi();
    });
    EventBus.getInstance()
      .on(`${this.compId}.toggle`, this.toggleStateChangeEventCallback);
  }

  destroy(): void {
    EventBus.getInstance()
      .detach(`${this.compId}.toggle`, this.toggleStateChangeEventCallback);
    emitter.off(EVENT_ID_LOCK_SCREEN_TONE);
  }

  protected refreshUi(): void {
    notifyCompStateChange(this.compId,
      new Map<SettingStateType, SettingResultState>([[SettingStateType.STATE_TYPE_ITEM_RESULT,
        { type: ItemResultType.RESULT_TYPE_TOGGLE, result: { state: this.isChecked } } as SettingResultState]]));
  }
}
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
  ComponentControl
} from '@ohos/settings.common/src/main/ets/framework/model/SettingBaseModel';
import { ItemResultType } from '@ohos/settings.common/src/main/ets/framework/model/SettingItemModel';
import {
  notifyCompStateChange,
  SettingResultState,
  SettingStateType,
  SettingToggleState
} from '@ohos/settings.common/src/main/ets/framework/model/SettingStateModel';
import { LogUtil } from '@ohos/settings.common/src/main/ets/utils/LogUtil';
import { SettingsDataUtils } from '@ohos/settings.common/src/main/ets/utils/SettingsDataUtils';
import { SystemParamUtil } from '@ohos/settings.common/src/main/ets/utils/SystemParamUtil';
import { GAZE_OFF, GAZE_ON } from '../DisplayUtils';

const TAG: string = 'GazeScreenController';
const GAZE_SWITCH: string = 'item_wakeup_gaze_switch';
const PERSIST_SWING_SWITCH_ENABLE: string = 'persist.swing.switch_enable';

export class GazeScreenController implements ComponentControl {
  public isChecked: boolean = true;
  private toggleStateChangeEventCallback = (toggleState: SettingToggleState) => {
    if (!toggleState) {
      LogUtil.error(`${TAG} toggleModel is invalid`);
      return;
    }
    let isChecked: boolean = toggleState.state;
    LogUtil.info(`${TAG} toggleState: ${isChecked}`)
    SettingsDataUtils.setSettingsData(GAZE_SWITCH, isChecked ? GAZE_ON : GAZE_OFF, Settings.domainName.USER_SECURITY);
    // 调整系统参数
    let swingParam: string = SystemParamUtil.getParam(PERSIST_SWING_SWITCH_ENABLE, '1');
    let currentTime: number = Number.parseInt(swingParam) + (isChecked ? 1 : -1);
    LogUtil.info(`${TAG} : swingParam:${swingParam}, currentTime:${currentTime}`);
    SystemParamUtil.setParam(PERSIST_SWING_SWITCH_ENABLE, currentTime.toString());
    this.setChecked(isChecked);
  };

  init(compParam: CompCtrlParam): void {
    this.isChecked = SettingsDataUtils.getSettingsData(GAZE_SWITCH, GAZE_OFF,
      Settings.domainName.USER_SECURITY) === GAZE_ON;
    this.refreshUi();
    EventBus.getInstance().on('Setting.Display.screen_group.gaze_screen.toggle', this.toggleStateChangeEventCallback);
  }

  destroy(): void {
    EventBus.getInstance()
      .detach('Setting.Display.screen_group.gaze_screen.toggle', this.toggleStateChangeEventCallback);
  }

  private setChecked(isChecked: boolean): void {
    LogUtil.showInfo(TAG, `setChecked ${isChecked}`);
    if (this.isChecked !== isChecked) {
      this.isChecked = isChecked;
      LogUtil.showInfo(TAG, `setChecked, refresh: ${this.isChecked}`);
      this.refreshUi();
    }
  }

  private refreshUi(): void {
    notifyCompStateChange('Setting.Display.screen_group.gaze_screen',
      new Map<SettingStateType, SettingResultState>([[SettingStateType.STATE_TYPE_ITEM_RESULT,
        { type: ItemResultType.RESULT_TYPE_TOGGLE, result: { state: this.isChecked } } as SettingResultState]]));
  }
}
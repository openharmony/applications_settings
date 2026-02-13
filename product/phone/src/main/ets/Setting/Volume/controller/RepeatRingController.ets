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
  ComponentControl
} from '@ohos/settings.common/src/main/ets/framework/model/SettingBaseModel';
import {
  ItemResultType,
  SettingToggleModel
} from '@ohos/settings.common/src/main/ets/framework/model/SettingItemModel';
import {
  notifyCompStateChange,
  SettingResultState,
  SettingStateType
} from '@ohos/settings.common/src/main/ets/framework/model/SettingStateModel';
import { LogUtil } from '@ohos/settings.common/src/main/ets/utils/LogUtil';
import { SettingsDataUtils } from '@ohos/settings.common/src/main/ets/utils/SettingsDataUtils';
import {
  NOT_DISTURB_VALUE_DISABLE,
  NOT_DISTURB_VALUE_ENABLE
} from '@ohos/settings.notDisturb/src/main/ets/utils/NotDisturbUtils';
import { ToggleMenuController } from './VolumeController';

const FOCUS_MODE_REPEAT_CALLERS_ENABLE: string = 'focus_mode_repeate_callers_enable';
const TAG: string = 'RepeatRingController: ';

/**
 * 重复来电菜单控制器
 */
@Observed
export class RepeatRingController extends ToggleMenuController implements ComponentControl {
  init(compParam: CompCtrlParam): void {
    LogUtil.showDebug(TAG, 'init');
    let isChecked: boolean = SettingsDataUtils.getSettingsData(FOCUS_MODE_REPEAT_CALLERS_ENABLE,
      NOT_DISTURB_VALUE_DISABLE, settings.domainName.USER_PROPERTY) === NOT_DISTURB_VALUE_ENABLE;
    this.setChecked(isChecked);
    EventBus.getInstance().on('Setting.IncomingCall.repeat_ringing_group.repeat_ringing.toggle', (param: object) => {
      let toggleState: SettingToggleModel = param as SettingToggleModel;
      let isChecked: boolean = !!(toggleState?.state);
      SettingsDataUtils.setSettingsData(FOCUS_MODE_REPEAT_CALLERS_ENABLE,
        isChecked ? NOT_DISTURB_VALUE_ENABLE : NOT_DISTURB_VALUE_DISABLE, settings.domainName.USER_PROPERTY);
      this.setChecked(isChecked);
    });
  }

  destroy(): void {
    EventBus.getInstance().detach('Setting.IncomingCall.repeat_ringing_group.repeat_ringing.toggle', () => {});
  }

  refreshUi(): void {
    LogUtil.info(`${TAG}refreshUi`);
    notifyCompStateChange('Setting.IncomingCall.repeat_ringing_group.repeat_ringing',
      new Map<SettingStateType, SettingResultState>([[SettingStateType.STATE_TYPE_ITEM_RESULT,
        { type: ItemResultType.RESULT_TYPE_TOGGLE, result: { state: this.isChecked } } as SettingResultState]]));
  }

  public static updateCheckedState(): boolean {
    return SettingsDataUtils.getSettingsData(FOCUS_MODE_REPEAT_CALLERS_ENABLE,
      NOT_DISTURB_VALUE_ENABLE, settings.domainName.USER_PROPERTY) === NOT_DISTURB_VALUE_ENABLE;
  }
}
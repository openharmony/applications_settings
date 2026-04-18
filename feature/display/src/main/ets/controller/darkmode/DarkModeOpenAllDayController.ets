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

import config from '@ohos.accessibility.config';
import { PreferencesUtil } from '@ohos/settings.common/src/main/ets/utils/PreferencesUtil';
import { EventBus } from '@ohos/settings.common/src/main/ets/framework/common/EventBus';
import uiAppearance from '@ohos.uiAppearance';
import {
  CompCtrlParam,
} from '@ohos/settings.common/src/main/ets/framework/model/SettingBaseModel';
import { ItemResultType,
  SettingDialogModel,
  SettingItemModel
} from '@ohos/settings.common/src/main/ets/framework/model/SettingItemModel';
import {
  notifyCompStateChange,
  SettingBaseState,
  SettingResultState,
  SettingStateType,
  SettingToggleState
} from '@ohos/settings.common/src/main/ets/framework/model/SettingStateModel';
import {
  HiSysEventUtil
} from '@ohos/settings.common/src/main/ets/systemEvent/HiSysEventUtil';
import { LogUtil } from '@ohos/settings.common/src/main/ets/utils/LogUtil';
import { SettingsDataUtils } from '@ohos/settings.common/src/main/ets/utils/SettingsDataUtils';
import { BusinessError } from '@kit.BasicServicesKit';
import { DisplayUtils } from '@ohos/settings.common/src/main/ets/utils/DisplayUtils';
import Settings from '@ohos.settings';
import {
  COLOR_MODE_DARK,
  COLOR_MODE_LIGHT,
  DARK_MODE_OPEN_ALL_DAY,
  DARK_MODE_TIMED_ON,
  DEFAULT_DARK_MODE_STATE,
  SETTINGS_UI_APPEARANCE_DARK_MODE,
  SETTING_DATA_DARK_MODE,
  SETTING_DATA_LIGHT_MODE,
  SET_MODE_DELAY, SWITCH_DELAY,
  SYSTEM_COLOR_MODE,
} from '../../constant/DarkModeConstant';
import { BaseDarkModeController } from './BaseDarkModeController';
import { HiSysDisplayEventGroup } from '@ohos/settings.common/src/main/ets/systemEvent/BehaviorEventConsts';

const DEFAULT_TIMER_ID: number = -1;

export class DarkModeOpenAllDayController extends BaseDarkModeController {
  protected tag: string = 'DarkModeOpenAllDayController: ';
  private setModeTimerId: number = DEFAULT_TIMER_ID;
  private switchTimerId: number = DEFAULT_TIMER_ID;
  private isNeedDealToggleChange: boolean = true;
  private toggleStateChangeEventCallback = (toggleState: SettingToggleState) => {
    if (!toggleState) {
      LogUtil.error(`${this.tag} toggleModel is invalid`);
      return;
    }
    LogUtil.info(`${this.tag} toggleState ${toggleState.state}`);
    /* instrument ignore if*/
    if (this.isInDarkModeOnTime() && toggleState.state) {
      LogUtil.info(`${this.tag} in dark mode time, open all day type`);
      this.changeColorMode(true);
      return;
    }
    if (!this.isNeedDealToggleChange) {
      LogUtil.warn(`${this.tag} no need deal toggle change`);
      return;
    }
    this.handleCheckedChange(toggleState.state);
    if (toggleState.state) {
      this.updateDarkTimeSearchItemStatus(false);
    }
  };

  private timedOnDarkModeOpenCallback = () => {
    LogUtil.info(`${this.tag} timedOnDarkModeOpenCallback`);
    this.stopTask();
    this.isNeedDealToggleChange = false;
    this.updateEnableState(this.compId, false, false);
    this.setModeTimerId = setTimeout(() =>{
      this.setModeTimerId = DEFAULT_TIMER_ID;
      this.isNeedDealToggleChange = true;
    }, SET_MODE_DELAY);

    this.switchTimerId = setTimeout(() => {
      this.switchTimerId = DEFAULT_TIMER_ID;
      this.updateEnableState(this.compId, false, true);
      LogUtil.info(`${this.tag} set switch enabled`)
    }, SWITCH_DELAY);
  };

  protected darkModeChangeCallback = () => {
    let darkModeType: string = this.getDarkModeType();
    LogUtil.info(`${this.tag} dark mode change callback ${darkModeType}`);
    if (darkModeType === DARK_MODE_OPEN_ALL_DAY) {
      this.changeColorMode(true, false);
      return;
    }
    if (darkModeType === DARK_MODE_TIMED_ON || darkModeType === DEFAULT_DARK_MODE_STATE) {
      this.timedOnDarkModeOpenCallback();
    }
  }

  init(compParam: CompCtrlParam): void {
    if (!compParam || !compParam.compId) {
      LogUtil.error(`${this.tag} init fail, compParam is invalid`);
      return;
    }
    this.compId = compParam.compId;
    this.registerEvent();
  }

  private registerEvent(): void {
    EventBus.getInstance().on(`${this.compId}.toggle`, this.toggleStateChangeEventCallback);
    this.registerDataHelper();
  }

  private unRegisterEvent(): void {
    EventBus.getInstance().detach(`${this.compId}.toggle`, this.toggleStateChangeEventCallback);
    this.unRegisterDataHelper();
  }

  private changeColorMode(isModeDark: boolean, isNeedDealSettingData: boolean = true): void {
    HiSysEventUtil
      .reportDefaultBehaviorEventByUE(HiSysDisplayEventGroup.DARK_MODE_ALL_DAY_SWITCH, isModeDark ? 'on' : 'off');
    LogUtil.info(`${this.tag} changeColorMode ${isModeDark}, ${isNeedDealSettingData}`);
    this.updateEnableState(this.compId, isModeDark, false);
    this.stopTask();
    this.updateTimedOnItemStatus(false); // 全天开启按钮处理过程中，需将定时开启开关置为不可点击状态
    if (isNeedDealSettingData) {
      this.dealDarkModeInSettingsData(isModeDark);
    }
    this.setModeTimerId = setTimeout(() => {
      this.setModeTimerId = DEFAULT_TIMER_ID;
      let uiNightMode = isModeDark ? SETTING_DATA_DARK_MODE : SETTING_DATA_LIGHT_MODE;
      LogUtil.info(`${this.tag} updateConfiguration start`);
      PreferencesUtil.put(SYSTEM_COLOR_MODE, isModeDark ? COLOR_MODE_DARK : COLOR_MODE_LIGHT);
      SettingsDataUtils.setSecureValue('ui_night_mode', uiNightMode);
    }, SET_MODE_DELAY);

    this.switchTimerId = setTimeout(() => {
      this.switchTimerId = DEFAULT_TIMER_ID;
      this.updateEnableState(this.compId, isModeDark, true);
      this.isNeedDealToggleChange = true;
      this.updateTimedOnItemStatus(true);
      LogUtil.info(`${this.tag} change color mode end.`);
    }, SWITCH_DELAY);
  }

  private dealDarkModeInSettingsData(isOpenedAllDay: boolean): void {
    let darkModeType: string = this.getDarkModeType();
    LogUtil.info(`${this.tag} dealDarkModeInSettingsData ${isOpenedAllDay}, ${darkModeType}`);
    if (isOpenedAllDay && darkModeType !== DARK_MODE_OPEN_ALL_DAY) {
      SettingsDataUtils.setSettingsData(SETTINGS_UI_APPEARANCE_DARK_MODE, DARK_MODE_OPEN_ALL_DAY,
          Settings.domainName.USER_PROPERTY);
      return;
    }
    if (!isOpenedAllDay && darkModeType === DARK_MODE_OPEN_ALL_DAY) {
      SettingsDataUtils.setSettingsData(SETTINGS_UI_APPEARANCE_DARK_MODE, DEFAULT_DARK_MODE_STATE,
          Settings.domainName.USER_PROPERTY);
      return;
    }
  }

  private updateTimedOnItemStatus(isEnabled: boolean): void {
    notifyCompStateChange('Setting.DarkMode.timed_on.timeOn', new Map<SettingStateType, SettingBaseState>(
      [[SettingStateType.STATE_TYPE_ITEM_RESULT,
        { type: ItemResultType.RESULT_TYPE_TOGGLE,
          result: {
            state: this.getDarkModeType() === DARK_MODE_TIMED_ON,
            enabled: isEnabled
          } as SettingToggleState
        } as SettingResultState]]
    ));
  }

  private stopTask(): void {
    if (this.setModeTimerId !== DEFAULT_TIMER_ID) {
      LogUtil.info(`${this.tag} stop existing task`);
      clearTimeout(this.setModeTimerId);
      this.setModeTimerId = DEFAULT_TIMER_ID;
    }
    if (this.switchTimerId !== DEFAULT_TIMER_ID) {
      LogUtil.showInfo(this.tag, 'stop existing switchTimerId task');
      clearTimeout(this.switchTimerId);
      this.switchTimerId = DEFAULT_TIMER_ID;
    }
  }

  // 开关变化的回调
  private handleCheckedChange(isChecked: boolean): void {
    if (isChecked && DisplayUtils.isHighContrastOn()) {
      this.isNeedDealToggleChange = false;
      this.updateEnableState(this.compId, false, true);
      this.showDialog(this.compId);
      return;
    }
    this.changeColorMode(isChecked);
  }

  private showDialog(compId: string): void {
    let state = new Map<SettingStateType, SettingDialogModel>([[SettingStateType.STATE_TYPE_ITEM_DIALOG,
      {
        title: $r('app.string.dark_mode_dialog_title'),
        message: $r('app.string.confirm_close_high_contrast_content'),
        buttonVertical: true,
        onWillDismiss: () => {
          LogUtil.info(`${this.tag} onWillDismiss`);
          this.isNeedDealToggleChange = true;
        },
        buttons: [
          {
            value: $r('app.string.dialog_cancel'),
            action: () => {
              this.hideDialog(this.compId);
              this.isNeedDealToggleChange = true;
            },
            style: {
              buttonStyle: ButtonStyleMode.TEXTUAL
            }
          },
          {
            value: $r('app.string.dialog_enable'),
            action: () => {
              this.hideDialog(this.compId);
              this.closeHighContrastTextMode();
              this.changeColorMode(true);
            },
            style: {
              buttonStyle: ButtonStyleMode.TEXTUAL
            }
          }
        ]
      } as SettingDialogModel]]);
    notifyCompStateChange(compId, state);
  }

  private closeHighContrastTextMode(): void {
    config.highContrastText.set(false).then(() => {
      LogUtil.info(`${this.tag} highContrastText set success`);
    }).catch((error: BusinessError) => {
      LogUtil.error(`${this.tag} highContrastText set err: ${error?.message}`);
    });
  }

  private hideDialog(compId: string): void {
    let state = new Map<SettingStateType, SettingDialogModel>([[SettingStateType.STATE_TYPE_ITEM_DIALOG,
      {
        buttons: [
          {
            value: $r('app.string.dialog_sure'),
            action: (component: SettingItemModel) => {
            }
          }
        ]
      } as SettingDialogModel]]);
    notifyCompStateChange(compId, state);
  }

  private refreshUi(compId: string, isChecked: boolean): void {
    notifyCompStateChange(compId, new Map<SettingStateType, SettingBaseState>(
      [[SettingStateType.STATE_TYPE_ITEM_RESULT, { type: ItemResultType.RESULT_TYPE_TOGGLE,
        result: { state: isChecked } as SettingToggleState } as SettingResultState]]
    ));
  }

  private updateEnableState(compId: string, state: boolean, isItemEnable: boolean): void {
    notifyCompStateChange(compId, new Map<SettingStateType, SettingBaseState>(
      [[SettingStateType.STATE_TYPE_ITEM_RESULT, { type: ItemResultType.RESULT_TYPE_TOGGLE,
        result: { state: state, enabled: isItemEnable } as SettingToggleState } as SettingResultState]]
    ));
  }

  destroy(): void {
    LogUtil.showInfo(this.tag, 'onDestroy eventbus');
    this.unRegisterEvent();
    this.stopTask();
  }
}
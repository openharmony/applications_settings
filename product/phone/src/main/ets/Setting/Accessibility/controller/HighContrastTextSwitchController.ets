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
import config from '@ohos.accessibility.config';
import common from '@ohos.app.ability.common';
import ConfigurationConstant from '@ohos.app.ability.ConfigurationConstant';
import { BusinessError } from '@ohos.base';
import uiAppearance from '@ohos.uiAppearance';
import { DisplayUtils } from '@ohos/settings.common/src/main/ets/utils/DisplayUtils';
import { EventBus } from '@ohos/settings.common/src/main/ets/framework/common/EventBus';
import { FontScaleUtils } from '@ohos/settings.common/src/main/ets/utils/FontScaleUtils';
import {
  CompCtrlParam,
  ComponentControl,
  SettingBaseModel
} from '@ohos/settings.common/src/main/ets/framework/model/SettingBaseModel';
import {
  notifyCompStateChange,
  SettingBaseState,
  SettingDialogState,
  SettingResultState,
  SettingStateType,
  SettingToggleState
} from '@ohos/settings.common/src/main/ets/framework/model/SettingStateModel';
import { ItemResultType } from '@ohos/settings.common/src/main/ets/framework/model/SettingItemModel';
import { LogUtil } from '@ohos/settings.common/src/main/ets/utils/LogUtil';
import { HiSysEventUtil } from '@ohos/settings.common/src/main/ets/systemEvent/HiSysEventUtil';
import { AccessibilitySettingModel } from '@ohos/settings.accessibility/src/main/ets/model/AccessibilitySettingModel';
import { CheckEmptyUtils } from '@ohos/settings.common/src/main/ets/utils/CheckEmptyUtils';
import { SettingsDataUtils } from '@ohos/settings.common/src/main/ets/utils/SettingsDataUtils';
import { PADDING_0 } from '@ohos/settings.common/src/main/ets/constant/StyleConstant';
import { HiSysAccessibilityEventGroup } from '@ohos/settings.common/src/main/ets/systemEvent/BehaviorEventConsts';
import { NIGHT_MODE_STATE_OFF, NIGHT_MODE_STATE_ON } from '../constant/Constants';
import { darkModeDialogContentBuilder } from '../AccessibilityPage';
import { a11yInitData } from '../sendable/A11yInitData';

const TAG: string = 'HighContrastTextSwitchController : ';

export class HighContrastTextSwitchController implements ComponentControl {
  public highContrastTextState: boolean = false;
  private static switchState: boolean = true;
  private compId: string = '';
  private toggleStateChangeEventCallback = (toggleState: SettingToggleState) => {
    if (!toggleState) {
      LogUtil.error(`${TAG} toggleModel is invalid`);
      return;
    }
    let isChecked: boolean = toggleState.state;
    LogUtil.info(`${TAG} toggleState: ${isChecked}`);
    this.handleCheckedChange(isChecked);
  };
  private configObserver = (data: boolean): void => {
    LogUtil.info(`${TAG} highContrastText on configObserver:${data}`);
    if (HighContrastTextSwitchController.switchState === data) {
      HiSysEventUtil.reportDefaultBehaviorEventByUE(
        HiSysAccessibilityEventGroup.HIGH_CONTRAST_TEXT_SWITCH, data ? 'on' : 'off');
      HighContrastTextSwitchController.switchState = !data;
    }
    if (this.highContrastTextState !== data) {
      this.highContrastTextState = data;
      a11yInitData.highContrastTextState = data;
      LogUtil.info(`${TAG} highContrastText state change:${data}`);
      this.refreshUi();
    }
  };

  async getAccessibilityConfig(): Promise<void> {
    let result: boolean = false;
    result = DisplayUtils.isHighContrastOn();
    LogUtil.info(`${TAG} reload highContrastTextState success:${result}`);
    if (this.highContrastTextState !== result) {
      LogUtil.info(`${TAG} initializationState refresh`);
      this.highContrastTextState = result;
      a11yInitData.highContrastTextState = result;
    }
  }

  /**
   * 开关变化的回调
   */
  protected handleCheckedChange(isChecked: boolean): boolean {
    LogUtil.info(`${TAG} handleCheckedChange isChecked: ${isChecked}`);
    HighContrastTextSwitchController.switchState = isChecked;
    if (isChecked) {
      if (HighContrastTextSwitchController.isDarkModeOn()) {
        if (SettingsDataUtils.getSecureValue('ui_night_mode', NIGHT_MODE_STATE_OFF) !== NIGHT_MODE_STATE_ON) {
          SettingsDataUtils.setSecureValue('ui_night_mode', NIGHT_MODE_STATE_ON);
        }
        this.handleDarkMode();
        return false;
      }
      AccessibilitySettingModel.accessibilityConfigSetting('highContrastText', true);
    } else {
      AccessibilitySettingModel.accessibilityConfigSetting('highContrastText', false);
    }
    return true;
  }


  /**
   * 监听开关的实时状态
   */
  protected registerDataChange(): void {
    try {
      config.highContrastText.on(this.configObserver);
    } catch (err) {
      LogUtil.error(`${TAG} failed subscribe highContrastText, because ${err?.message}`);
    }
  }

  /**
   * 取消监听开关的实时状态
   */
  protected unRegisterDataChange(): void {
    LogUtil.info(`${TAG} unRegisterDataChange`);
    try {
      config.highContrastText.off(this.configObserver);
    } catch (err) {
      LogUtil.error(`${TAG} failed unsubscribe highContrastText, because ${err?.message}`);
    }
  }

  /**
   * 深色模式是否已打开
   *
   * @returns true: 已开启深色模式
   */
  static isDarkModeOn(): boolean {
    let context: common.UIAbilityContext | undefined =
      AppStorage.get<common.UIAbilityContext>('settingsAbilityContext');
    if (CheckEmptyUtils.isEmpty(context)) {
      context = AppStorage.get<Context>('pageContext') as common.UIAbilityContext;
    }
    const colorMode: ConfigurationConstant.ColorMode | undefined = context?.config?.colorMode;
    LogUtil.info(`${TAG} colorMode : ${colorMode}`);
    return colorMode === ConfigurationConstant.ColorMode.COLOR_MODE_DARK;
  }

  /**
   * 关闭深色模式
   */
  static setDarkModeOff(): void {
    uiAppearance.setDarkMode(uiAppearance.DarkMode.ALWAYS_LIGHT).then(() => {
      LogUtil.info(`${TAG} succeed to set dark mode.`);
    }).catch((err: BusinessError) => {
      LogUtil.error(`${TAG} Failed to set dark mode. Cause: ${err?.message}`);
    });
  }

  private handleDarkMode(): void {
    config.highContrastText.get().then((isHighContrastOn) => {
      LogUtil.info(`${TAG} highContrastText get status: ${isHighContrastOn}`);
      if (isHighContrastOn) {
        // 通过辅助功能快捷键开启时，不弹窗，直接关深色模式
        uiAppearance.setDarkMode(uiAppearance.DarkMode.ALWAYS_LIGHT).then(() => {
          LogUtil.error(`${TAG} succeed to set dark mode.`);
          SettingsDataUtils.setSecureValue('ui_night_mode', NIGHT_MODE_STATE_OFF);
          this.highContrastTextState = true;
          a11yInitData.highContrastTextState = true;
          this.refreshUi();
        }).catch((err: BusinessError) => {
          LogUtil.error(`${TAG} Failed to set dark mode. Cause: ${err?.message}`);
        });
      } else {
        this.alertDarkModeDialog();
      }
    })
  }

  // 深色模式下，打开高对比度文字提醒
  private alertDarkModeDialog(): void {
    notifyCompStateChange(`${this.compId}`, new Map(
      [[SettingStateType.STATE_TYPE_ITEM_DIALOG, {
        contentBuilder: wrapBuilder(darkModeDialogContentBuilder),
        style: {
          contentButtonSpace: PADDING_0,
        },
        buttons: [
          {
            value: $r('app.string.dialog_cancel'),
            style: {
              buttonStyle: ButtonStyleMode.TEXTUAL,
            },
            action: () => {
              LogUtil.info(`${TAG} highContrastTextState dialog cancel`);
              this.highContrastTextState = false;
              a11yInitData.highContrastTextState = false;
              this.refreshUi();
            }
          },
          {
            value: $r(`app.string.dialog_enable`),
            style: {
              buttonStyle: ButtonStyleMode.TEXTUAL,
            },
            action: () => {
              LogUtil.info(`${TAG} highContrastTextState dialog enable`);
              this.highContrastTextState = true;
              a11yInitData.highContrastTextState = true;
              uiAppearance.setDarkMode(uiAppearance.DarkMode.ALWAYS_LIGHT).then(() => {
                AccessibilitySettingModel.accessibilityConfigSetting('highContrastText', true);
                SettingsDataUtils.setSecureValue('ui_night_mode', NIGHT_MODE_STATE_OFF);
              }).catch((err: BusinessError) => {
                LogUtil.error(`${TAG} Failed to set dark mode. Cause: ${err?.message}`);
              });
              this.refreshUi();
            }
          },
        ],
        buttonVertical: FontScaleUtils.isExtraLargeFontMode() ? false : true,
      } as SettingDialogState]]
    ));
  }

  async init(compParam: CompCtrlParam): Promise<void> {
    LogUtil.info(`${TAG} init, state:${a11yInitData.highContrastTextState}`);
    if (!compParam.compId) {
      LogUtil.error(`${TAG} init fail, compParam is invalid`);
      return;
    }
    this.compId = compParam.compId;
    await this.getAccessibilityConfig();
    this.refreshUi();
    EventBus.getInstance().on(`${this.compId}.toggle`, this.toggleStateChangeEventCallback);
    this.registerDataChange();
  }

  destroy(): void {
    LogUtil.info(`${TAG} on destroy`);
    EventBus.getInstance().detach(`${this.compId}.toggle`, this.toggleStateChangeEventCallback);
    this.unRegisterDataChange();
  }

  onPageShow(component: SettingBaseModel): void {
    LogUtil.info(`${TAG} onPageShow`);
  }

  onPageHide(component: SettingBaseModel): void {
    LogUtil.info(`${TAG} onPageHide`);
  }

  private refreshUi(): void {
    notifyCompStateChange(this.compId,
      new Map<SettingStateType, SettingResultState>([[SettingStateType.STATE_TYPE_ITEM_RESULT,
        {
          type: ItemResultType.RESULT_TYPE_TOGGLE,
          result: { state: this.highContrastTextState }
        } as SettingResultState]]));
  }
}

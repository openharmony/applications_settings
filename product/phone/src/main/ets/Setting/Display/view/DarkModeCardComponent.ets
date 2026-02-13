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

import { display, uiAppearance } from '@kit.ArkUI';
import { BusinessError } from '@ohos.base';
import {
  PADDING_36,
  PADDING_4,
  PADDING_40,
  PADDING_7,
} from '@ohos/settings.common/src/main/ets/constant/StyleConstant';
import { AccessibilityUtils } from '@ohos/settings.common/src/main/ets/utils/AccessibilityUtils';
import { DeviceUtil } from '@ohos/settings.common/src/main/ets/utils/BaseUtils';
import { LogUtil } from '@ohos/settings.common/src/main/ets/utils/LogUtil';
import {
  COLOR_MODE_DARK,
  COLOR_MODE_LIGHT,
  SWITCH_DELAY
} from '@ohos/settings.display/src/main/ets/constant/DarkModeConstant';
import { EventBus } from '@ohos/settings.common/src/main/ets/framework/common/EventBus';
import { EVENT_ID_DARK_MODE_CACHE } from '@ohos/settings.common/src/main/ets/event/types';
import { DisplayUtils } from '../utils/DisplayUtils';
import { notifyCompStateChange,
  SettingResultState,
  SettingStateType} from '@ohos/settings.common/src/main/ets/framework/model/SettingStateModel';
import { ItemResultType } from '@ohos/settings.common/src/main/ets/framework/model/SettingItemModel';
import { SearchDataController } from '@ohos/settings.search';

/* instrument ignore file */
const TAG: string = 'DarkModeCardComponent : ';

@Component
export struct DarkModeCardComponent {
  @State private clickEnable: boolean = true;
  @State private currentMode: number = this.getDarkMode();
  @State private needShowPad: boolean = false;

  private getDarkMode(): number {
    try {
      return uiAppearance.getDarkMode();
    } catch (e) {
      LogUtil.error(`${TAG} uiAppearance.getDarkMode Error, error code = ${e?.code}, error message = ${e?.message}`);
    }
    return COLOR_MODE_DARK;
  }

  private eventDarkModeChange = (isDarkMode: boolean) => {
    this.currentMode = isDarkMode ? COLOR_MODE_DARK : COLOR_MODE_LIGHT;
  };

  private switchColorMode(isOn: boolean): void {
    try {
      let darkMode = uiAppearance.getDarkMode() === uiAppearance.DarkMode.ALWAYS_DARK;
      if (darkMode === isOn) {
        LogUtil.info(`${TAG} darkMode ${darkMode} is same as isOn ${isOn}`);
        return;
      }
      //防止卡片被连续点击，需要增加延时
      this.refreshClickEnableValue(false);
      setTimeout(() => {
        this.refreshClickEnableValue(true);
      }, SWITCH_DELAY)
      uiAppearance.setDarkMode(isOn ? uiAppearance.DarkMode.ALWAYS_DARK : uiAppearance.DarkMode.ALWAYS_LIGHT);
      if (isOn) {
        DisplayUtils.closeHighContrastTextMode();
      }
      this.currentMode = isOn ? COLOR_MODE_DARK : COLOR_MODE_LIGHT;
      LogUtil.info(`${TAG} switchColorMode ${isOn}`);
      let result = isOn ? darkMode?$r('app.string.open_all_day'):$r('app.string.eye_timed_on') : $r('app.string.open_all_day_close');
      notifyCompStateChange('Setting.Display.display_setting.dark_mode',
        new Map<SettingStateType, SettingResultState>([[SettingStateType.STATE_TYPE_ITEM_RESULT,
          { type: ItemResultType.RESULT_TYPE_TEXT, result: { content: result } } as SettingResultState]]));
    } catch (paramError) {
      let code: number = (paramError as BusinessError).code;
      let message: string = (paramError as BusinessError).message;
      LogUtil.error(`${TAG} error.code: ${code}, error.message: ${message}`);
    }
  }

  private refreshClickEnableValue(newValue: boolean): void {
    if (newValue !== this.clickEnable) {
      this.clickEnable = newValue;
    }
  }

  @Builder
  padCardComponent(): void {
    Row() {
      Column() {
        Image($r('app.media.light_mode_pad'))
          .enabled(this.clickEnable)
          .width('80%')
          .margin({
            top: PADDING_40,
          })
          .onClick(() => {
            this.switchColorMode(false)
          })
          .draggable(false)
        Text($r('app.string.light_color'))
          .fontSize($r('sys.float.Body_M'))
          .fontWeight(FontWeight.Bold)
          .margin({ top: $r('app.float.wh_value_10'), bottom: $r('app.float.wh_value_6') })
        Radio({ value: 'dark_once', group: 'DarkCardPadGroup' })
          .enabled(this.clickEnable)
          .checked(this.currentMode !== COLOR_MODE_DARK)
          .onClick(() => {
            this.switchColorMode(false)
          })
          .radioStyle({
            checkedBackgroundColor: $r('sys.color.comp_background_emphasize')
          })
          .height($r('app.float.wh_value_21'))
          .width($r('app.float.wh_value_21'))
          .margin({ bottom: $r('app.float.wh_value_10') })
      }
      .width('50%')
      .accessibilityGroup(true)
      .accessibilityText($r('app.string.light_color'))
      .accessibilitySelected(uiAppearance.getDarkMode() !== COLOR_MODE_DARK)
      .accessibilityDescription(uiAppearance.getDarkMode() !== COLOR_MODE_DARK ? ' ' : '')
      .onClick(() => {
        this.accessibilityOnClick(false);
      })

      Column() {
        Image($r('app.media.dark_mode_pad'))
          .enabled(this.clickEnable)
          .width('80%')
          .margin({
            top: PADDING_40,
          })
          .onClick(() => {
            this.switchColorMode(true)
          })
          .draggable(false)
        Text($r('app.string.dark_color'))
          .fontSize($r('sys.float.Body_M'))
          .margin({ top: $r('app.float.wh_value_10'), bottom: $r('app.float.wh_value_6') })
          .fontWeight(FontWeight.Bold)
        Radio({ value: 'dark_once', group: 'DarkCardPadGroup' })
          .enabled(this.clickEnable)
          .checked(this.currentMode === COLOR_MODE_DARK)
          .onClick(() => {
            this.switchColorMode(true)
          })
          .radioStyle({
            checkedBackgroundColor: $r('sys.color.comp_background_emphasize')
          })
          .height($r('app.float.wh_value_21'))
          .width($r('app.float.wh_value_21'))
          .margin({ bottom: $r('app.float.wh_value_10') })
      }
      .width('50%')
      .accessibilityGroup(true)
      .accessibilityText($r('app.string.dark_color'))
      .accessibilitySelected(uiAppearance.getDarkMode() === COLOR_MODE_DARK)
      .accessibilityDescription(uiAppearance.getDarkMode() === COLOR_MODE_DARK ? ' ' : '')
      .onClick(() => {
        this.accessibilityOnClick(true);
      })
    }
  }

  @Builder
  phoneCardComponent(): void {
    Row() {
      Column() {
        Image($r('app.media.light_mode'))
          .enabled(this.clickEnable)
          .width('66%')
          .margin({
            start: PADDING_4,
            top: PADDING_36,
            bottom: PADDING_7,
          })
          .onClick(() => {
            this.switchColorMode(false)
          })
          .draggable(false)
        Text($r('app.string.light_color'))
          .fontSize($r('sys.float.Body_M'))
          .fontWeight(FontWeight.Bold)
          .margin({ bottom: '6vp' })
        Radio({ value: 'tab_unlock', group: 'DarkCardGroup' })
          .enabled(this.clickEnable)
          .checked(this.currentMode !== COLOR_MODE_DARK)
          .onClick(() => {
            this.switchColorMode(false)
          })
          .radioStyle({
            checkedBackgroundColor: $r('sys.color.comp_background_emphasize')
          })
          .height($r('app.float.wh_value_21'))
          .width($r('app.float.wh_value_21'))
          .margin({ bottom: '12vp' })
      }
      .width('50%')
      .accessibilityGroup(true)
      .accessibilityText($r('app.string.light_color'))
      .accessibilitySelected(uiAppearance.getDarkMode() !== COLOR_MODE_DARK)
      .accessibilityDescription(uiAppearance.getDarkMode() !== COLOR_MODE_DARK ? ' ' : '')
      .onClick(() => {
        this.accessibilityOnClick(false);
      })

      Column() {
        Image($r('app.media.dark_mode'))
          .enabled(this.clickEnable)
          .width('66%')
          .margin({
            end: PADDING_4,
            top: PADDING_36,
            bottom: PADDING_7,
          })
          .onClick(() => {
            this.switchColorMode(true)
          })
          .draggable(false)
        Text($r('app.string.dark_color'))
          .fontSize($r('sys.float.Body_M'))
          .margin({ bottom: '6vp' })
          .fontWeight(FontWeight.Bold)
        Radio({ value: 'tab_unlock', group: 'DarkCardGroup' })
          .enabled(this.clickEnable)
          .checked(this.currentMode === COLOR_MODE_DARK)
          .onClick(() => {
            this.switchColorMode(true)
          })
          .radioStyle({
            checkedBackgroundColor: $r('sys.color.comp_background_emphasize')
          })
          .height($r('app.float.wh_value_21'))
          .width($r('app.float.wh_value_21'))
          .margin({ bottom: '12vp' })
      }
      .width('50%')
      .accessibilityGroup(true)
      .accessibilityText($r('app.string.dark_color'))
      .accessibilitySelected(uiAppearance.getDarkMode() === COLOR_MODE_DARK)
      .accessibilityDescription(uiAppearance.getDarkMode() === COLOR_MODE_DARK ? ' ' : '')
      .onClick(() => {
        this.accessibilityOnClick(true);
      })
    }
  }

  /**
   * 开启无障碍下的点击事件
   * @param checked 是否深色模式
   */
  private accessibilityOnClick(checked: boolean): void {
    if (AccessibilityUtils.isAccessibilityMode()) {
      this.switchColorMode(checked);
    }
  }

  private registerDisplayStatusChangeCallback(): void {
    if (!DeviceUtil.isThreeFoldable()) { //非XT设备不做监听
      return;
    }
    try {
      display.on('change', this.callback);
    } catch (e) {
      LogUtil.error(`${TAG} display.on foldStatusChange Error, error code = ${e?.code}, error message = ${e?.message}`);
    }
  }

  private unRegisterDisplayStatusChangeCallback(): void {
    if (!DeviceUtil.isThreeFoldable()) { //非XT设备不做监听
      return;
    }
    try {
      display.off('change', this.callback);
    } catch (e) {
      LogUtil.error(`${TAG} display.on change Error, error code = ${e?.code}, error message = ${e?.message}`);
    }
  }

  private callback: Callback<display.FoldStatus> = () => {
    this.needShowPad =
      DeviceUtil.isThreeFoldable() && DeviceUtil.isThreeFoldableGmodel();
  };

  aboutToAppear(): void {
    LogUtil.info(`${TAG} aboutToAppear`);
    EventBus.getInstance().on(EVENT_ID_DARK_MODE_CACHE, this.eventDarkModeChange);
    this.needShowPad = DeviceUtil.isDevicePad() ||
      (DeviceUtil.isThreeFoldable() && DeviceUtil.isThreeFoldableGmodel());
    this.registerDisplayStatusChangeCallback();
  }

  aboutToDisappear(): void {
    LogUtil.info(`${TAG} aboutToDisappear`);
    EventBus.getInstance().detach(EVENT_ID_DARK_MODE_CACHE, this.eventDarkModeChange);
    this.unRegisterDisplayStatusChangeCallback();
  }

  build() {
    if (this.needShowPad) {
      this.padCardComponent()
    } else {
      this.phoneCardComponent()
    }
  }
}
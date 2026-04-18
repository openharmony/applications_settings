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

import UIExtensionContentSession from '@ohos.app.ability.UIExtensionContentSession';
import settings from '@ohos.settings';
import uiAppearance from '@ohos.uiAppearance';
import { PackagesConstant } from '@ohos/settings.common/src/main/ets/constant/PackagesConstant';
import { EventBus } from '@ohos/settings.common/src/main/ets/framework/common/EventBus';
import { AbilityUtils } from '@ohos/settings.common/src/main/ets/utils/AbilityUtils';
import { AccessibilityUtils } from '@ohos/settings.common/src/main/ets/utils/AccessibilityUtils';
import { NavEntryKey } from '@ohos/settings.common/src/main/ets/utils/Consts';
import { LogUtil } from '@ohos/settings.common/src/main/ets/utils/LogUtil';
import { HiSysEventUtil } from '@ohos/settings.common/src/main/ets/systemEvent/HiSysEventUtil';
import { SettingsDataUtils } from '@ohos/settings.common/src/main/ets/utils/SettingsDataUtils';
import {
  CLICK_ENABLE_EVENT,
  DARK_MODE_OPEN_ALL_DAY,
  DARK_MODE_STATE,
  DARK_MODE_TIMED_ON,
  SETTINGS_UI_APPEARANCE_DARK_MODE,
} from '@ohos/settings.display/src/main/ets/constant/DarkModeConstant';
import { DisplayUtils } from './utils/DisplayUtils';
import { DarkModeItemComponent, DarkModeWindowTitleComponent } from './view/DarkModeWindowComponent';
import { MoreSettingButtonComponent } from './view/DarkModeWindowComponent';
/* instrument ignore file */
const TAG: string = 'DarkModeWindowPage: ';
const DARK_MODE_WINDOW_TITLE: string = 'dark_mode_window_title';
const ENTER_EXTERNAL_ENTRY: string = 'enter_dark_mode_entry';
const EVENT_ID_DARK_MODE_WINDOW: string = 'EVENT_ID_DARK_MODE_WINDOW';

let storage = LocalStorage.getShared();

interface ReceiveData {
  controlCenterColor?: number;
}

@Entry
@Component
struct DarkModeWindowSettings {
  @State controlCenterColor: ResourceColor = $r('app.color.control_center_sub_panel_color');
  @State darkMode: string = '';
  @State clickEnable: boolean = true;
  @State isDarkMode: boolean = uiAppearance.getDarkMode() === uiAppearance.DarkMode.ALWAYS_DARK;
  session: UIExtensionContentSession | undefined = storage?.get<UIExtensionContentSession>('uIExtensionSession');
  subTitle: string = '';
  private darkEnableCallback = (enable: boolean) => {
    this.clickEnable = enable;
  }

  private eventDarkModeChange = (isDarkMode: boolean) => {
    this.isDarkMode = isDarkMode;
    LogUtil.info(`${TAG} current mode ${this.isDarkMode}`);
  };

  build() {
    Column() {
      DarkModeWindowTitleComponent({
        isDarkMode: this.isDarkMode
      })
      Scroll() {
        List() {
          this.DarkSelectBuilder()
        }
      }
      .edgeEffect(EdgeEffect.Spring)
      .scrollable(ScrollDirection.Vertical)
      .scrollBar(BarState.Auto)
      .layoutWeight(1)
      .padding({
        left:  $r('app.float.wh_value_8'),
        right: $r('app.float.wh_value_8'),
      })

      MoreSettingButtonComponent({
        controlCenterColor: DisplayUtils.getColor(),
        onMoreSettingClick: () => {
          this.onMoreSettingClick();
        },
      })
    }
    .size({ width: '100%', height: '100%' })
    .borderRadius($r('app.float.wh_value_32'))
    .onAppear(() => {
      AccessibilityUtils.requestFocusAccessibilityWithBundleName(DARK_MODE_WINDOW_TITLE);
    })
  }

  @Builder
  DarkSelectBuilder() {
    List() {
      DarkModeItemComponent({
        comId: 'all_day',
        title: $r('app.string.open_all_day'),
        subTitle: $r('app.string.until_turn_off'),
        value: DARK_MODE_OPEN_ALL_DAY,
        isSelected: this.darkMode === DARK_MODE_OPEN_ALL_DAY,
        controlCenterColor: this.controlCenterColor
      })
        .enabled(this.clickEnable)
        .opacity(this.clickEnable ? 1 : 0.5)
      DarkModeItemComponent({
        comId: 'every_day',
        title: $r('app.string.not_disturb_everyday'),
        subTitle: this.subTitle,
        value: DARK_MODE_TIMED_ON,
        isSelected: this.darkMode === DARK_MODE_TIMED_ON,
        controlCenterColor: this.controlCenterColor
      })
        .enabled(this.clickEnable)
        .opacity(this.clickEnable ? 1 : 0.5)
    }
    .divider({
      strokeWidth: px2vp(1),
      color: $r('app.color.bluetooth_window_settings_divider_color'),
      startMargin: $r('app.float.wh_value_8'),
      endMargin: $r('app.float.wh_value_8'),
    })
  }

  onMoreSettingClick(): void {
    let message: string = `bundleName: ${PackagesConstant.SETTINGS_BUNDLE_NAME}, abilityName: ` +
      `${PackagesConstant.SETTINGS_MAIN_ABILITY_NAME}, navEntryKey: ${NavEntryKey.DARK_SETTINGS}`;
    LogUtil.info(`${TAG} onMoreSettingClick startAbilityForResult`);
    HiSysEventUtil.reportEntryEventByUE(ENTER_EXTERNAL_ENTRY, message);
    AbilityUtils.startAbilityForResult({
      bundleName: PackagesConstant.SETTINGS_BUNDLE_NAME,
      abilityName: PackagesConstant.SETTINGS_MAIN_ABILITY_NAME,
      uri: NavEntryKey.DARK_SETTINGS,
    }, () => {
      try {
        this.session?.sendData({ 'method': 'hideControlCenter' });
      } catch (e) {
        LogUtil.error(`${TAG} sendData err err.code ${e?.code} err.message ${e?.message}`);
      }
    });
  }

  aboutToAppear(): void {
    LogUtil.info(`${TAG} aboutToAppear`);
    this.darkMode = SettingsDataUtils.getSettingsDataDomain(SETTINGS_UI_APPEARANCE_DARK_MODE,
      DARK_MODE_STATE, settings.domainName.USER_PROPERTY);
    this.subTitle = DisplayUtils.getScheduleTimeframe();
    const controlCenterSubPanelColor = AppStorage.get<number>('control_center_sub_panel_color');
    if (typeof controlCenterSubPanelColor === 'number') {
      this.controlCenterColor = controlCenterSubPanelColor;
      LogUtil.info(`${TAG} init controlCenterColor:${this.controlCenterColor}`);
    }
    this.initSessionReceiveDataCallback();
    EventBus.getInstance().on(CLICK_ENABLE_EVENT, this.darkEnableCallback);
    EventBus.getInstance().on(EVENT_ID_DARK_MODE_WINDOW, this.eventDarkModeChange);
  }

  aboutToDisappear(): void {
    LogUtil.info(`${TAG} aboutToDisappear`);
    EventBus.getInstance().detach(CLICK_ENABLE_EVENT, this.darkEnableCallback);
    EventBus.getInstance().detach(EVENT_ID_DARK_MODE_WINDOW, this.eventDarkModeChange);
  }

  /**
   * 监听拉起方发送的数据
   */
  private initSessionReceiveDataCallback(): void {
    try {
      this.session?.setReceiveDataCallback((data: ReceiveData) => {
        const controlCenterSubPanelColor = data?.controlCenterColor;
        if (typeof controlCenterSubPanelColor === 'number') {
          LogUtil.info(`${TAG} setReceiveDataCallback new controlCenterColor:${controlCenterSubPanelColor}`);
          this.controlCenterColor = controlCenterSubPanelColor;
        }
      })
    } catch (error) {
      LogUtil.error(`${TAG} setReceiveDataCallback catch error.code:${error?.code} error.message:${error?.message}`);
    }
  }
}
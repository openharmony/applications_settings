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

import settings from '@ohos.settings';
import { AccessibilityLevelType} from '@ohos/settings.common/src/main/ets/utils/AccessibilityUtils';
import { SwitchItem } from '../model/SwitchItem';
import { AiBarSwitchManager, SWITCH_TERTIARY_FONTCOLOR, SWITCH_TITLE_FONTCOLOR } from '../viewmodel/AiBarSwitchManager';
import { LogUtil } from '@ohos/settings.common/src/main/ets/utils/LogUtil';
import { SettingsDataUtils } from '@ohos/settings.common/src/main/ets/utils/SettingsDataUtils';
import { HiSysEventUtil } from '@ohos/settings.common/src/main/ets/systemEvent/HiSysEventUtil';
import { NavSwitchType } from '../model/NavSwitchType';
import { CheckEmptyUtils } from '@ohos/settings.common/src/main/ets/utils/CheckEmptyUtils';

/* instrument ignore file */
const TAG: string = 'FloatingNavigationBallView';

/**
 * 悬浮导航开关
 */
@Component
export struct FloatingNavigationBallView {
  readonly on: string = '1';
  readonly off: string = '0';
  readonly SETINGS_DATA_KEY: string = 'floating_navigation_ball';
  readonly SCREEN_READER_ON_KEY: string = 'accessibility_screenreader_enabled';
  readonly SETINGS_DATA_DOMAIN = settings.domainName.USER_PROPERTY;
  readonly screenReaderEnabled: string = settings.domainName.DEVICE_SHARED;
  readonly FLOATING_NAVIGATION_TYPE = 1;
  @State floatingItem: SwitchItem = {
    index: -1,
    content: $r('app.string.floating_navigation_ball_name'),
    switchStatus: false,
    name: 'floatingNavigation',
    detail: '',
    switchType: this.FLOATING_NAVIGATION_TYPE,
  };
  @State isScreenReaderEnabled: boolean = false;
  private ballPageId: number = -1;

  // 悬浮导航开关值改变
  private onFloatingDataChange = () => {
    let isOn = this.isFloatingOpen();
    this.floatingItem.switchStatus = isOn;
    LogUtil.showInfo(TAG, `onFloatingDataChange ${isOn}`);
  }

  aboutToAppear(): void {
    LogUtil.showInfo(TAG, 'aboutToAppear');
    try {
      this.ballPageId = AiBarSwitchManager.getInstance().getPageId();
      let isOn = this.isFloatingOpen();
      this.floatingItem.switchStatus = isOn;
      this.unregisterKeyObserver();
      let isRegisterSuccess = SettingsDataUtils.registerKeyObserverWithDomain(this.SETINGS_DATA_KEY,
        this.SETINGS_DATA_DOMAIN, this.onFloatingDataChange);
      LogUtil.showInfo(TAG,
        `aboutToAppear isOn is: ${isOn} isRegisterSuccess:${isRegisterSuccess}}`);
    } catch (err) {
      LogUtil.showError(TAG, `err is: ${err?.code}  ${err?.message}`);
      this.floatingItem.switchStatus = false;
    }
  }

  private isFloatingOpen(): boolean {
    let isOpen = settings.getValueSync(getContext(), this.SETINGS_DATA_KEY, this.off, this.SETINGS_DATA_DOMAIN);
    return isOpen === this.on;
  }

  aboutToDisappear(): void {
    LogUtil.showInfo(TAG, `aboutToDisappear`);
    let pageId = AiBarSwitchManager.getInstance().getPageId();
    if (this.ballPageId === pageId) {
      this.unregisterKeyObserver();
    }
  }

  private unregisterKeyObserver() {
    let unRegisterSuccess = SettingsDataUtils.unregisterKeyObserverWithDomain(this.SETINGS_DATA_KEY,
      this.SETINGS_DATA_DOMAIN);
    let unAccessRegister = SettingsDataUtils.unregisterKeyObserverWithDomain(this.SCREEN_READER_ON_KEY,
      this.screenReaderEnabled);
    LogUtil.showInfo(TAG, `unRegisterSuccess is ${unRegisterSuccess} unAccessRegister is ${unAccessRegister}`);
  }

  build() {
    this.aiBarSwitchItem(this.floatingItem);
  }

  @Builder
  aiBarSwitchItem(switchItem: SwitchItem) {
    Row() {
      Column() {
        Text(switchItem.content).fontFamily('HarmonyHeiTi')
          .fontWeight(FontWeight.Medium)
          .fontSize(16)
          .fontColor(!this.isScreenReaderEnabled ? SWITCH_TITLE_FONTCOLOR : SWITCH_TERTIARY_FONTCOLOR)

        Text(switchItem.detail)
          .fontFamily('HarmonyHeiTi')
          .fontWeight(FontWeight.Regular)
          .fontSize(14)
          .margin({ top: 2 })
          .fontColor($r('sys.color.ohos_id_color_text_secondary'))
          .visibility(CheckEmptyUtils.isEmpty(switchItem.detail) ? Visibility.None : Visibility.Visible)
      }
      .alignItems(HorizontalAlign.Start)
      .layoutWeight(1)

      Toggle({
        type: ToggleType.Switch,
        isOn: this.floatingItem.switchStatus
      })
        .enabled(!this.isScreenReaderEnabled)
        .onChange(async (isOn: boolean) => {
          if (isOn) {
            LogUtil.showInfo(TAG, `toggleStatusChange index:%{public}d`, switchItem.index);
          }
          this.setValueToSettingsData(isOn);
        })
        .accessibilityLevel(AccessibilityLevelType.YES)
        .hoverEffect(HoverEffect.None)
    }
    .accessibilityGroup(true)
    .justifyContent(FlexAlign.SpaceBetween)
    .settingItemStyle();
  }

  @Styles
  settingItemStyle() {
    .padding({
      top: 14,
      bottom: 14,
      left: 12,
      right: 12
    })
    .backgroundColor($r('sys.color.ohos_id_color_card_bg'))
    .borderRadius(16)
    .width('100%')
  }

  private setValueToSettingsData(isOn: boolean): void {
    try {
      LogUtil.showInfo(TAG, `setValue is ${isOn} `);
      settings.setValue(getContext(), this.SETINGS_DATA_KEY, isOn ? this.on : this.off, this.SETINGS_DATA_DOMAIN);
      AiBarSwitchManager.getInstance().closeThreeButtonOrFloating(false, isOn);
      HiSysEventUtil.reportFloatingBallSwitchParams(NavSwitchType.FLOATING_NAV_BALL, isOn);
    } catch (e) {
      LogUtil.showError(TAG, `setValue is error ${e?.code} ${e?.message}`);
    }
  }
}
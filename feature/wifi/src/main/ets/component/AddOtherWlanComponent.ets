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
import window from '@ohos.window';
import Display from '@ohos.display';
import UIExtensionContentSession from '@ohos.app.ability.UIExtensionContentSession';
import { LogUtil } from '@ohos/settings.common/src/main/ets/utils/LogUtil';
import { EventBus } from '@ohos/settings.common/src/main/ets/framework/common/EventBus';
import { SettingToggleState } from '@ohos/settings.common/src/main/ets/framework/model/SettingStateModel';
import { DeviceUtil } from '@ohos/settings.common/src/main/ets/utils/BaseUtils';
import { DisplayUtils } from '@ohos/settings.common/src/main/ets/utils/DisplayUtils';
import { FontScaleUtils } from '@ohos/settings.common/src/main/ets/utils/FontScaleUtils';
import { WifiUtils } from '../WifiUtils';

const TAG: string = 'AddOtherWlanComponent';
const UX_DESIGN_BOTTOM_MARGIN: number = 16;
const UX_DESIGN_DEFAULT_BOTTOM_MARGIN: number = 28;
const WLAN_SWITCH_ID: string = 'OpenNetWorkSetting.NetworkSetting.WlanConfig.WlanSwitch.toggle';

@Component
export struct AddOtherWlanComponent {
  @State isHover: boolean = false;
  @State isWlanSwitchOn: boolean = false;
  @State bottomMargin: number = 0;
  private onToggleChangeCallback = (toggleState: SettingToggleState) => {
    if (!toggleState) {
      LogUtil.error(`${TAG} toggleState is invalid`);
      return;
    }
    LogUtil.info(`${TAG} receive toggle state change: ${toggleState.state}`);
    this.isWlanSwitchOn = toggleState.state;
  };

  private onFoldChangeCallBack = (status: number) => {
    this.handleFoldStateChange(status);
  };

  build() {
    Stack() {
      Row() {
        Row() {
          Text($r('app.string.wifi_add_other_wifi'))
            .fontColor($r('sys.color.font_emphasize'))
            .fontSize(16)
            .fontFamily('HarmonyHeiTi')
            .fontWeight(FontWeight.Medium)
            .maxFontScale(1.75)
        }
        .width('100%')
        .constraintSize({
          minHeight: 48,
        })
        .borderRadius($r('sys.float.corner_radius_level10'))
        .padding({
          left: $r('sys.float.padding_level4'),
          right: $r('sys.float.padding_level4'),
          top: FontScaleUtils.getCurrentPadding(),
          bottom: FontScaleUtils.getCurrentPadding(),
        })
        .stateStyles({
          normal: this.normalStyles,
          pressed: this.buttonPressedStyles,
        })
        .onHover((isHover?: boolean) => {
          this.isHover = isHover ?? false;
        })
        .alignItems(VerticalAlign.Center)
        .justifyContent(FlexAlign.Start)

      }
      .padding($r('sys.float.padding_level2'))
      .width('100%')
      .borderRadius($r('sys.float.corner_radius_level10'))
      .backgroundColor($r('sys.color.comp_background_list_card'))
      .onClick(() => {
        EventBus.getInstance().emit('NetWorkSettingsAddOtherWlan');
      })
    }
    .width('100%')
    .padding({
      left: DeviceUtil.isDevicePad() || DeviceUtil.isDevicePc() ? $r('app.float.padding_24') : $r('app.float.padding_16'),
      right: DeviceUtil.isDevicePad() || DeviceUtil.isDevicePc() ? $r('app.float.padding_24') : $r('app.float.padding_16'),
      bottom: this.bottomMargin
    })
    .visibility(this.isWlanSwitchOn ? Visibility.Visible : Visibility.None)
  }

  aboutToAppear(): void {
    LogUtil.info(`${TAG} aboutToAppear.`);
    this.isWlanSwitchOn = WifiUtils.isWifiActive();
    EventBus.getInstance().on(`${WLAN_SWITCH_ID}`, this.onToggleChangeCallback);
    if (DeviceUtil.isDevicePad() || DeviceUtil.isDevicePc() || DeviceUtil.isFoldExpand()) {
      this.bottomMargin = UX_DESIGN_BOTTOM_MARGIN;
      return;
    }
    this.bottomMargin = Math.max(UX_DESIGN_DEFAULT_BOTTOM_MARGIN, this.getNavigationIndicatorHeight());
    if (DeviceUtil.isFoldable()) {
      DisplayUtils.registerFoldStatusChange(this.onFoldChangeCallBack);
    }
  }

  aboutToDisappear(): void {
    LogUtil.info(`${TAG} aboutToDisappear.`);
    EventBus.getInstance().detach(`${WLAN_SWITCH_ID}`, this.onToggleChangeCallback);
    if (DeviceUtil.isFoldable()) {
      DisplayUtils.unRegisterFoldStatusChange(this.onFoldChangeCallBack);
    }
  }

  private getNavigationIndicatorHeight(): number {
    const session = LocalStorage.getShared()?.get<UIExtensionContentSession>('session');
    let navigationIndicatorHeight: number = 0;
    if (session) {
      let navigationIndicatorArea: window.AvoidArea =
        session.getUIExtensionWindowProxy().getWindowAvoidArea(window.AvoidAreaType.TYPE_NAVIGATION_INDICATOR);
      navigationIndicatorHeight = px2vp(navigationIndicatorArea.bottomRect.height);
      LogUtil.info(`${TAG} navigationIndicatorHeight: ${navigationIndicatorHeight}`);
    }
    return navigationIndicatorHeight;
  }

  private handleFoldStateChange(status: number): void {
    LogUtil.info(`${TAG} on fold status changed: ${status}`);
    if (status === Display.FoldStatus.FOLD_STATUS_FOLDED) {
      this.bottomMargin = this.getNavigationIndicatorHeight();
    } else {
      this.bottomMargin = UX_DESIGN_BOTTOM_MARGIN;
    }
  }

  @Styles
  normalStyles() {
    .backgroundColor(this.isHover ? $r('sys.color.interactive_click') : Color.Transparent)
  }

  @Styles
  buttonPressedStyles() {
    .backgroundColor($r('sys.color.interactive_click'))
  }
}
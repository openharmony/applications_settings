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
import { PackagesConstant } from '@ohos/settings.common/src/main/ets/constant/PackagesConstant';
import { PADDING_36, PADDING_44, PADDING_8 } from '@ohos/settings.common/src/main/ets/constant/StyleConstant';
import { HiSysAboutBluetoothEventGroup } from '@ohos/settings.common/src/main/ets/systemEvent/BehaviorEventConsts';
import { HiSysEventUtil } from '@ohos/settings.common/src/main/ets/systemEvent/HiSysEventUtil';
import { AbilityUtils } from '@ohos/settings.common/src/main/ets/utils/AbilityUtils';
import { AccessibilityUtils } from '@ohos/settings.common/src/main/ets/utils/AccessibilityUtils';
import { CommonUtils } from '@ohos/settings.common/src/main/ets/utils/CommonUtils';
import { NavEntryKey } from '@ohos/settings.common/src/main/ets/utils/Consts';
import { LogUtil } from '@ohos/settings.common/src/main/ets/utils/LogUtil';
import BlendModeUtil from '@ohos/settings.commonUikit/src/main/ets/utils/BlendModeUtil';
import { ApMenu } from '@ohos/settings.wifi/src/main/ets/model/WifiModel';
import { WifiUtils } from '@ohos/settings.wifi/src/main/ets/WifiUtils';
import WifiControlCenterPageController from './controller/WifiControlCenterPageController';
import { ControlCenterWlanDataSource } from './model/ControlCenterWlanDataSource';
import { WifiWindowItemComponent } from './view/controlCenter/WifiWindowItemComponent';
/* instrument ignore file */
const TAG: string = 'WifiWindowSettings : ';
const ENTER_EXTERNAL_ENTRY: string = 'enter_external_entry';
const WINDOW_WLAN_TITLE: string = 'wlan_window_title';
const DEFAULT_CACHE_COUNT: number = 3;
const storage: LocalStorage = LocalStorage.getShared();

interface ReceiveData {
  controlCenterColor?: number;
}

/**
 * 控制中心wlan界面入口
 *
 * @since 2024-10-18
 */
@Entry
@Component
struct WifiWindowSettings {
  private dataSource: ControlCenterWlanDataSource = new ControlCenterWlanDataSource();
  private session: UIExtensionContentSession | undefined =
    storage?.get<UIExtensionContentSession>('wifiExtensionSession');
  private wifiControlCenterPageController: WifiControlCenterPageController = new WifiControlCenterPageController();
  // 当前是否在外屏
  private isOuterScreen: boolean = CommonUtils.isOuterScreen();
  @StorageLink('WlanListLoadingVisible') loadingVisible: boolean = false;
  @State controlCenterColor: ResourceColor = $r('app.color.control_center_sub_panel_color');
  @State isHover: boolean = false;

  build() {
    Column() {
      this.wifiWindowTitleBuilder()

      this.wifiListBuilder()

      if (!this.isOuterScreen) {
        this.moreWifiSettingBuilder()
      }
    }
    .padding({
      top: $r('app.float.wh_value_16'),
      bottom: $r('app.float.wh_value_16'),
    })
    .size({ width: '100%', height: '100%' })
    .borderRadius($r('app.float.wh_value_32'))
    .onAppear(() => {
      AccessibilityUtils.requestFocusAccessibilityWithBundleName(WINDOW_WLAN_TITLE);
    })
  }

  @Builder
  wifiWindowImageBuilder() {
    Image($r('app.media.ic_wifi_signal_4'))
      .fillColor($r('app.color.window_settings_icon_primary'))
      .advancedBlendMode(BlendModeUtil.getCenterBlender())
      .draggable(false)
      .size({
        width: $r('app.float.wh_value_24'),
        height: $r('app.float.wh_value_24')
      })
      .margin({
        bottom: $r('app.float.wh_value_8'),
        end: this.isOuterScreen ? PADDING_8 : undefined,
      })
  }

  @Builder
  wifiWindowWlanTextBuilder() {
    Text($r('app.string.wifi_settings_title'))
      .fontFamily('HarmonyHeiTi')
      .fontWeight(FontWeight.Medium)
      .advancedBlendMode(BlendModeUtil.getCenterBlender())
      .fontSize($r('sys.float.ohos_id_text_size_headline8'))
      .fontColor($r('app.color.window_settings_font_primary'))
      .lineHeight($r('app.float.wh_value_26'))
      .height($r('app.float.wh_value_26'))
      .id(WINDOW_WLAN_TITLE)
  }

  @Builder
  wifiWindowTitleBuilder() {
    if (this.isOuterScreen) {
      Row() {
        this.wifiWindowImageBuilder()
        this.wifiWindowWlanTextBuilder()
        LoadingProgress()
          .width($r('app.float.width_24'))
          .height($r('app.float.height_24'))
          .margin({
            start: PADDING_44
          })
          .id('loading_progress_wifi_list_group')
          .visibility(this.loadingVisible ? Visibility.Visible : Visibility.Hidden)
          .position({
            end: PADDING_36
          })
      }
      .width('100%')
      .padding({
        bottom: $r('app.float.wh_value_24'),
      })
      .justifyContent(FlexAlign.Center)
    } else {
      Column() {
        this.wifiWindowImageBuilder()
        this.wifiWindowWlanTextBuilder()
      }
      .width('100%')
      .padding({
        bottom: $r('app.float.wh_value_24'),
      })
      .alignItems(HorizontalAlign.Center)
    }
  }

  @Builder
  moreWifiSettingBuilder() {
    Column() {
      Text($r('app.string.wifi_more_settings'))
        .fontFamily('HarmonyHeiTi')
        .fontWeight(FontWeight.Medium)
        .fontSize($r('app.float.font_16'))
        .fontColor(this.controlCenterColor)
        .lineHeight($r('app.float.font_21'))
        .width('100%')
        .textAlign(TextAlign.Center)
        .maxFontScale(2)
    }
    .onClick(() => {
      HiSysEventUtil.reportDefaultBehaviorEventByUE(HiSysAboutBluetoothEventGroup.ENTER_SETTINGS_WIFI_PAGE);
      this.onMoreSettingClick();
    })
    .alignItems(HorizontalAlign.Center)
    .margin({
      top: $r('app.float.wh_value_15'),
      left: $r('app.float.wh_value_16'),
      right: $r('app.float.wh_value_16'),
    })
    .padding({
      top: $r('app.float.wh_value_9'),
      bottom: $r('app.float.wh_value_10'),
    })
    .stateStyles({
      normal: this.normalStyles,
      pressed: this.buttonPressedStyles,
    })
    .onHover((isHover?: boolean) => {
      this.isHover = isHover ?? false;
    })
  }

  @Builder
  wifiListBuilder() {
    Column() {
      List() {
        this.wifiListContentBuilder()
      }
      .padding({
        left: $r('app.float.wh_value_8'),
        right: $r('app.float.wh_value_8'),
      })
      .width('100%')
      .height('100%')
      .cachedCount(DEFAULT_CACHE_COUNT)
      .divider({
        strokeWidth: px2vp(1),
        color: $r('app.color.wlan_window_settings_divider_color'),
        startMargin: $r('app.float.wh_value_56'),
        endMargin: $r('app.float.wh_value_20'),
      })
      .alignSelf(ItemAlign.Start)
      .clip(true)
      .edgeEffect(EdgeEffect.Spring, {alwaysEnabled: true})
    }
    .layoutWeight(1)
  }

  @Builder
  wifiListContentBuilder() {
    LazyForEach(this.dataSource, (item: ApMenu) => {
      ListItem() {
        WifiWindowItemComponent({
          menu: item,
          controlCenterColor: this.controlCenterColor,
        })
      }
    }, (item: ApMenu) => {
      let stateIconId: string = (item.stateIcon as Resource)?.id?.toString() || '';
      return `${item?.toString()}${stateIconId}${item.index}`;
    })
  }

  @Styles
  normalStyles() {
    .backgroundColor(this.isHover ? $r('sys.color.interactive_hover') : Color.Transparent)
    .borderRadius($r('app.float.wh_value_20'))
  }

  @Styles
  buttonPressedStyles() {
    .backgroundColor(this.isHover ? $r('sys.color.interactive_hover') : $r('sys.color.interactive_click'))
    .borderRadius($r('app.float.wh_value_20'))
  }

  onMoreSettingClick(): void {
    let bundleName: string = PackagesConstant.SETTINGS_BUNDLE_NAME;
    let abilityName: string = PackagesConstant.SETTINGS_MAIN_ABILITY_NAME;
    let navEntryKey: string = NavEntryKey.WIFI_ENTRY;
    let message: string = `bundleName: ${bundleName}, abilityName: ${abilityName}, navEntryKey: ${navEntryKey}`;
    HiSysEventUtil.reportEntryEvent(ENTER_EXTERNAL_ENTRY, message);
    LogUtil.info(`${TAG} onMoreSettingClick startAbilityForResult ${message}`);
    AbilityUtils.startAbilityForResult({
      bundleName: bundleName,
      abilityName: abilityName,
      uri: navEntryKey,
      parameters: {
        // 从更多设置进入wifi详情页
        fromMoreSetting: true
      }
    }, () => {
      this.session?.sendData({ 'method': 'hideControlCenter' });
    });
  }

  aboutToAppear(): void {
    LogUtil.info(`${TAG} aboutToAppear `);
    this.initSessionReceiveDataCallback();
    this.wifiControlCenterPageController.bindList(this.dataSource);
    this.wifiControlCenterPageController.aboutToAppear();
  }

  aboutToDisappear(): void {
    LogUtil.info(`${TAG} aboutToDisappear`);
    this.wifiControlCenterPageController.aboutToDisappear();
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
      LogUtil.error(`${TAG} setReceiveDataCallback catch error. code:${error?.code} message:${error?.message}`);
    }
  }

  onPageShow(): void {
    LogUtil.info(`${TAG} onPageShow`);
    this.wifiControlCenterPageController.onPageShow();
    WifiUtils.publishEnterWlanPageEvent(true);
    HiSysEventUtil.reportDefaultBehaviorEventByUE(HiSysAboutBluetoothEventGroup.CLICK_WLAN_TEXT_SHOW_DIALOG);
  }

  onPageHide(): void {
    LogUtil.info(`${TAG} onPageHide, send hideSubPage message.`);
    this.wifiControlCenterPageController.onPageHide();
    // 某些特殊场景下，关闭wifi控制中心窗口的时候无触碰事件，这会导致后续点击其他控制中心按钮无法弹窗，发hideSubPage消息可以解决
    this.session?.sendData({ 'method': 'hideSubPage' });
    WifiUtils.publishEnterWlanPageEvent(false);
  }
}

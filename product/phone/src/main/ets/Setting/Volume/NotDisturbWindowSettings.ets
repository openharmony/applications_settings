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

import { PackagesConstant } from '@ohos/settings.common/src/main/ets/constant/PackagesConstant';
import { NavEntryKey } from '@ohos/settings.common/src/main/ets/utils/Consts';
import { AbilityUtils } from '@ohos/settings.common/src/main/ets/utils/AbilityUtils';
import { LogUtil } from '@ohos/settings.common/src/main/ets/utils/LogUtil';
import { AccessibilityUtils } from '@ohos/settings.common/src/main/ets/utils/AccessibilityUtils';
import UIExtensionContentSession from '@ohos.app.ability.UIExtensionContentSession';
import { NoDisturbWindowComponent } from './components/NotDisturbWindowComponent';
import { NotDisturbMenuEntry } from './view/NotDisturbMenuEntry';
import { NotDisturbWindowViewModel } from './viewmodel/NotDisturbWindowViewModel';
import { MoreSettingButtonComponent, titleComponentBuilder } from '../ControlCenterCommon/view/WindowCommonComponent';
/* instrument ignore file */
export const NOT_DISTURB_WINDOW_PAGE_URL: string = 'Setting/Volume/NotDisturbWindowSettings';

const TAG: string = 'NotDisturbWindowSettings : ';
const WINDOW_DISTURB_TITLE: string = 'not_disturb_window_title';
const DEFAULT_CACHE_COUNT: number = 4;
let storage: LocalStorage = LocalStorage.getShared();

interface ReceiveData {
  controlCenterColor?: number;
}

/**
 * 控制中心免打扰二级面板
 */
@Entry(storage)
@Component
struct NotDisturbWindowSettings {
  @State controlCenterColor: ResourceColor = $r('app.color.control_center_sub_panel_color');
  @State notDisturbMenusArray: NotDisturbMenuEntry[] = [];
  @State notDisturbWindowViewModel: NotDisturbWindowViewModel = new NotDisturbWindowViewModel();
  private session: UIExtensionContentSession | undefined =
    storage?.get<UIExtensionContentSession>('extensionSession');

  build() {
    Column() {
      titleComponentBuilder($r('app.media.ic_public_not_disturb'), $r('app.string.not_disturb_title'),
        WINDOW_DISTURB_TITLE)

      Column() {
        this.notDisturbListBuilder();
      }
      .layoutWeight(1)

      MoreSettingButtonComponent({
        controlCenterColor: this.controlCenterColor,
        onMoreSettingClick: () => {
          this.onMoreSettingClick();
        }
      })
    }
    .size({ width: '100%', height: '100%' })
    .borderRadius($r('app.float.wh_value_32'))
  }

  @Builder
  moreSettingBuilder() {
    Column() {
      Text($r('app.string.more_settings'))
        .fontFamily('HarmonyHeiTi')
        .fontWeight(FontWeight.Medium)
        .fontSize($r('app.float.wh_value_16'))
        .fontColor(this.controlCenterColor)
        .lineHeight($r('app.float.wh_value_21'))
        .width('100%')
        .textAlign(TextAlign.Center)
        .maxFontScale(2)
    }
    .onClick(() => {
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
  }

  @Builder
  notDisturbTips(){
    Row() {
      Text($r('app.string.not_disturb_tips_settings'))
        .fontWeight(FontWeight.Medium)
        .fontSize($r('sys.float.Caption_L'))
        .fontColor($r('app.color.window_settings_font_tertiary'))
        .fontFamily('HarmonyHeiTi')
        .maxFontScale(2)
    }
    .width('100%')
    .margin({ bottom: $r('app.float.wh_value_24') })
    .justifyContent(FlexAlign.Center)
  }

  @Builder
  notDisturbListBuilder() {
    List() {
      ListItem() {
        this.notDisturbTips();
      }
      ForEach(this.notDisturbMenusArray, (menu: NotDisturbMenuEntry, index: number) => {
        ListItem() {
          Column() {
            NoDisturbWindowComponent({
              menu: menu,
              notDisturbWindowViewModel: this.notDisturbWindowViewModel,
              controlCenterColor: this.controlCenterColor,
            })
            if (index !== this.notDisturbMenusArray.length - 1) {
              Divider()
                .strokeWidth(px2vp(1))
                .color($r('app.color.wlan_window_settings_divider_color'))
            }
          }
        }
      }, (menu: NotDisturbMenuEntry) => {
        return menu.key;
      });
    }
    .padding({
      left: $r('app.float.wh_value_24'),
      right: $r('app.float.wh_value_24'),
    })
    .width('100%')
    .height('100%')
    .cachedCount(DEFAULT_CACHE_COUNT)
    .alignSelf(ItemAlign.Start)
    .clip(true)
  }

  @Styles
  normalStyles() {
    .backgroundColor(Color.Transparent)
  }

  @Styles
  buttonPressedStyles() {
    .backgroundColor($r('sys.color.interactive_click'))
    .borderRadius($r('app.float.wh_value_20'))
  }

  onMoreSettingClick(): void {
    let bundleName = PackagesConstant.SETTINGS_BUNDLE_NAME;
    let abilityName = PackagesConstant.SETTINGS_MAIN_ABILITY_NAME;
    let navEntryKey = NavEntryKey.INTELLIGENT_SCENE_SETTINGS_ENTRY;
    let message: string = `bundleName: ${bundleName}, abilityName: ${abilityName}, navEntryKey: ${navEntryKey}`;
    LogUtil.info(`${TAG} onMoreSettingClick startAbilityForResult ${message}`);
    AbilityUtils.startAbilityForResult({
      bundleName: bundleName,
      abilityName: abilityName,
      uri: navEntryKey,
    }, () => {
      this.session?.sendData({ 'method': 'hideControlCenter' });
    });
  }

  aboutToAppear(): void {
    LogUtil.info(`${TAG} aboutToAppear `);
    // 主题颜色
    const controlCenterSubPanelColor = AppStorage.get<number>('control_center_sub_panel_color');
    if (typeof controlCenterSubPanelColor === 'number') {
      this.controlCenterColor = controlCenterSubPanelColor;
      LogUtil.info(`${TAG} init controlCenterColor:${this.controlCenterColor}`);
    }
    this.initSessionReceiveDataCallback();
    // 无障碍
    AccessibilityUtils.requestFocusAccessibility(WINDOW_DISTURB_TITLE);
    this.notDisturbWindowViewModel.init(this.notDisturbMenusArray);
    this.notDisturbWindowViewModel.registerListener();
  }

  aboutToDisappear(): void {
    LogUtil.info(`${TAG} aboutToDisappear`);
    this.notDisturbWindowViewModel.unregisterListener();
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
}
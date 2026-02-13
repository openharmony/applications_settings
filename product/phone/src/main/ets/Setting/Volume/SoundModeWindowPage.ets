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
import { HiSysEventUtil } from '@ohos/settings.common/src/main/ets/systemEvent/HiSysEventUtil';
import { AbilityUtils } from '@ohos/settings.common/src/main/ets/utils/AbilityUtils';
import { AccessibilityUtils } from '@ohos/settings.common/src/main/ets/utils/AccessibilityUtils';
import { NavEntryKey } from '@ohos/settings.common/src/main/ets/utils/Consts';
import { LogUtil } from '@ohos/settings.common/src/main/ets/utils/LogUtil';
import { RINGER_MODE_NORMAL, RINGER_MODE_SILENT, RINGER_MODE_VIBRATE } from './controller/VolumeAdapter';
import { VolumeModeWindowController } from './controller/VolumeModeWindowController';
import {
  MoreSettingButtonComponent,
  SoundModeItemsComponent,
  soundModeWindowTitleBuilder
} from './view/SoundModeWindowComponent';

const SOUND_MODE_WINDOW_TITLE: string = 'sound_window_title';
const TAG = 'SoundModeWindowPage: ';
const ENTER_EXTERNAL_ENTRY: string = 'enter_sound_entry';
let storage = LocalStorage.getShared();

@Entry
@Component
struct SoundModeWindowPage {
  @State controlCenterColor: ResourceColor = $r('app.color.control_center_sub_panel_color');
  session: UIExtensionContentSession | undefined = storage?.get<UIExtensionContentSession>('uIExtensionSession');
  currentMode: string = '1';
  @State controller: VolumeModeWindowController = new VolumeModeWindowController();

  build() {
    Column() {
      soundModeWindowTitleBuilder($r('sys.symbol.bell_fill'), $r('app.string.volume_mode'), SOUND_MODE_WINDOW_TITLE)

      Scroll() {
        List() {
          this.soundSelectBuilder()
        }
        .divider({
          strokeWidth: px2vp(1),
          color: $r('app.color.bluetooth_window_settings_divider_color'),
          startMargin: $r('app.float.wh_value_56'),
          endMargin: $r('app.float.wh_value_16'),
        })
      }
      .edgeEffect(EdgeEffect.Spring)
      .scrollable(ScrollDirection.Vertical)
      .scrollBar(BarState.Auto)
      .layoutWeight(1)

      MoreSettingButtonComponent({
        controlCenterColor: this.controlCenterColor,
        onMoreSettingClick: () => {
          this.onMoreSettingClick();
        },
      })
    }
    .size({ width: '100%', height: '100%' })
    .borderRadius($r('app.float.wh_value_32'))
    .onAppear(() => {
      AccessibilityUtils.requestFocusAccessibilityWithBundleName(SOUND_MODE_WINDOW_TITLE);
    })
  }

  aboutToAppear(): void {
    this.controller.init();
  }

  aboutToDisappear(): void {
  }

  @Builder
  soundSelectBuilder() {
    SoundModeItemsComponent({
      icon: $r('sys.symbol.bell_fill'),
      title: $r('app.string.volume_mode_sound'),
      ringMode: RINGER_MODE_NORMAL,
      controller: this.controller
    })
    SoundModeItemsComponent({
      icon: $r('sys.symbol.rectangle_portrait_wave_2_fill'),
      title: $r('app.string.volume_mode_vibrate'),
      ringMode: RINGER_MODE_VIBRATE,
      controller: this.controller
    }).visibility(this.controller?.volumeModeVibrateShow ? Visibility.Visible : Visibility.None)
    SoundModeItemsComponent({
      icon: $r('sys.symbol.bell_slash_fill'),
      title: $r('app.string.volume_mode_silent'),
      ringMode: RINGER_MODE_SILENT,
      controller: this.controller
    })
  }

  onMoreSettingClick(): void {
    LogUtil.info(`${TAG} onMoreSettingClick startAbilityForResult`);
    let message: string = `bundleName: ${PackagesConstant.SETTINGS_BUNDLE_NAME}, abilityName: ` +
      `${PackagesConstant.SETTINGS_MAIN_ABILITY_NAME}, navEntryKey: ${NavEntryKey.VOLUME_ENTRY}`;
    HiSysEventUtil.reportEntryEventByUE(ENTER_EXTERNAL_ENTRY, message);
    AbilityUtils.startAbilityForResult({
      bundleName: PackagesConstant.SETTINGS_BUNDLE_NAME,
      abilityName: PackagesConstant.SETTINGS_MAIN_ABILITY_NAME,
      uri: NavEntryKey.VOLUME_ENTRY,
    }, () => {
      this.session?.sendData({ 'method': 'hideControlCenter' });
    });
  }
}
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
import promptAction from '@ohos.promptAction';
import { DeviceUtil } from '@ohos/settings.common/src/main/ets/utils/BaseUtils';
import { LogUtil } from '@ohos/settings.common/src/main/ets/utils/LogUtil';

@Component
export struct RingToneImageComponent {
  private tag: string = 'RingToneImageComponent : ';

  @Builder
  OverlayNode() {
    Column() {
      Row() {
        Text($r('app.string.ringtone_theme'))
          .fontSize($r('sys.float.Title_S'))
          .fontColor($r('sys.color.font_on_primary'))
          .fontFamily('HarmonyHeiTi')
          .textAlign(TextAlign.Start)
      }
      .margin({ bottom: $r('sys.float.padding_level1') })

      Text($r('app.string.default_ringtone'))
        .fontSize($r('sys.float.Subtitle_S'))
        .fontColor($r('sys.color.font_on_secondary'))
        .fontFamily('HarmonyHeiTi')
        .textAlign(TextAlign.Start)
    }
    .alignItems(HorizontalAlign.Start)
  }

  build() {
    Stack() {
      Image(DeviceUtil.isDevicePhone() ? $r('app.media.ic_ringtone_phone') : $r('app.media.ic_ringtone_pad'))
        .id('ring_tone_image')
        .draggable(false)
        .objectFit(ImageFit.Cover)
        .overlay(this.OverlayNode(), { align: Alignment.TopStart, offset: { x: 12, y: 12 } })
        .fillColor($r('sys.color.icon_secondary'))
        .borderRadius($r('sys.float.corner_radius_level8'))
        .onClick(() => {
          try {
            promptAction.showToast({ message: $r('app.string.ringtone_theme_prompt_text') });
          } catch (e) {
            LogUtil.error(`${this.tag} showToast args error`);
          }
        })
        .syncLoad(true)
    }
    .alignContent(Alignment.Center)
    .height('164vp')
    .clip(false)
  }

  aboutToAppear(): void {
    LogUtil.debug(`${this.tag} aboutToAppear`);
  }

  aboutToDisappear(): void {
    LogUtil.debug(`${this.tag} aboutToDisappear`);
  }
}
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
import { LogUtil } from '@ohos/settings.common/src/main/ets/utils/LogUtil';
import { DeviceUtil } from '@ohos/settings.common/src/main/ets/utils/BaseUtils';
import { ResourceUtil } from '@ohos/settings.common/src/main/ets/utils/ResourceUtil';

const SHORTCUT_TIMEOUT: number = 3;
const TAG: string = 'ShortKeyPageImageComponent';

@Component
export struct ShortKeyPageImageComponent {
  @State isConfigInit: Boolean = false;

  private getImage(): ResourceStr | PixelMap {
    if (DeviceUtil.isDevicePhone()) {
      return $r('app.media.ic_accessibility_shortkey');
    }
    if (DeviceUtil.isDevicePortrait()) {
      return $r('app.media.ic_accessibility_shortkey_pad_land');
    }
    return $r('app.media.ic_accessibility_shortkey_pad');
  }

  private getImageSize(): number {
    let length = AppStorage.get<number>('AccessibilityImageSize') as number;
    LogUtil.info(`${TAG} GetImageSize: ${length}`);
    return length;
  }

  aboutToAppear(): void {
    LogUtil.info(`${TAG} aboutToAppear`);
  }

  aboutToDisappear(): void {
    LogUtil.info(`${TAG} aboutToDisappear`);
  }

  build() {
    Column() {
      Column() {
        Stack() {
          Column() {
            Image(this.getImage())
              .visibility(Visibility.Visible)
              .interpolation(ImageInterpolation.Medium)
              .autoResize(false)
              .size({
                width: `${(this.getImageSize())}vp`,
                height: `${(this.getImageSize())}vp`,
              })
              .objectFit(ImageFit.Cover)
              .draggable(false)
          }
        }
        .size({
          width: '100%',
          height: `${(this.getImageSize())}vp`,
        })
        .clip(true)
        .margin({ bottom: $r('app.float.margin_24') })
      }

      Column() {
        Row() {
          Text($r('app.string.shortKey_prompt', ResourceUtil.getLocalNumberFormat(SHORTCUT_TIMEOUT)))
            .id(`text_title_tips`)
            .visibility(Visibility.Visible)
            .fontColor($r('sys.color.font_secondary'))
            .textOverflow({ overflow: TextOverflow.None })
            .font({
              size: $r('sys.float.ohos_id_text_size_body2'),
              weight: FontWeight.Regular,
            })
            .size({
              width: '100%',
            })
            .textAlign(TextAlign.Center)
            .wordBreak(WordBreak.HYPHENATION)
        }
        .visibility(Visibility.Visible)
        .width('100%')
        .constraintSize({
          minHeight: $r('app.float.lineHeight_19'),
        })
        .justifyContent(FlexAlign.Start)
      }
    }
    .accessibilityGroup(true)
    .width('100%')
  }
}
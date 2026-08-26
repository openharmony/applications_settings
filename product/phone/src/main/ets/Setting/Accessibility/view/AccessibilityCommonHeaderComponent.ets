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
import { EventBus } from '@ohos/settings.common/src/main/ets/framework/common/EventBus';
import { FontScaleUtils } from '@ohos/settings.common/src/main/ets/utils/FontScaleUtils';
import { LogUtil } from '@ohos/settings.common/src/main/ets/utils/LogUtil';
import { ResourceUtil } from '@ohos/settings.common/src/main/ets/utils/ResourceUtil';
import { DeviceUtil } from '@ohos/settings.common/src/main/ets/utils/BaseUtils';
import { PADDING_4, PADDING_6 } from '@ohos/settings.common/src/main/ets/constant/StyleConstant';
import { RESTORE_DEFAULT_GROUP_EVENT } from '../constant/Constants';

const RESTORE_GROUP_TYPE_LIST: ResourceStr[] =
  [$r('app.string.accessibility_visual_aids'), $r('app.string.accessibility_hearing_aids'),
    $r('app.string.accessibility_interactive_control')];

@Component
export struct AccessibilityCommonHeaderComponent {
  private tag: string = 'AccessibilityCommonHeaderComponent: ';
  name: ResourceStr = '';

  build() {
    Column() {
      if (FontScaleUtils.isExtraLargeFontMode()) {
        this.buttonHorizontalBuilder()
      } else {
        this.buttonBuilder()
      }
    }
    .focusable(false)
  }

  @Builder
  buttonHorizontalBuilder() {
    Column() {
      Row() {
        Text(this.name)
          .accessibilityDescription($r('app.string.title'))
          .fontFamily('HarmonyHeiTi')
          .fontWeight(FontWeight.Medium)
          .fontColor($r('sys.color.font_secondary'))
          .fontSize($r('sys.float.Subtitle_S'))
          .lineHeight(19)
          .wordBreak(WordBreak.HYPHENATION)
          .width('100%')
          .margin({
            top: PADDING_4,
            start: PADDING_4,
            end: PADDING_4,
            bottom: PADDING_4
          })
      }

      Row() {
        Button({ buttonStyle: ButtonStyleMode.TEXTUAL }) {
          Text($r('app.string.restore_defaults'))
            .fontFamily('HarmonyHeiTi')
            .fontWeight(FontWeight.Medium)
            .fontColor($r('sys.color.font_emphasize'))
            .fontSize($r('sys.float.Body_M'))
            .lineHeight(19)
            .textAlign(TextAlign.Start)
            .textOverflow({ overflow: TextOverflow.Ellipsis })
            .maxLines(2)
            .wordBreak(WordBreak.HYPHENATION)
        }
        .borderRadius($r('sys.float.corner_radius_level4'))
        .padding({
          top: $r('app.float.margin_4'),
          bottom: $r('app.float.margin_4'),
          left: $r('app.float.margin_2'),
          right: $r('app.float.margin_2'),
        })
        .margin({
          start: PADDING_4,
          end: PADDING_4,
        })
        .visibility(DeviceUtil.is2In1DevicePcType() ? Visibility.None : Visibility.Visible)
        .onClick(() => {
          this.handleClickEvent();
        })
      }
      .width('100%')
      .justifyContent(FlexAlign.Start)
    }
    .width('100%')
    .justifyContent(FlexAlign.SpaceBetween)
  }

  @Builder
  buttonBuilder() {
    Row() {
      Text(this.name)
        .accessibilityDescription($r('app.string.title'))
        .fontFamily('HarmonyHeiTi')
        .fontWeight(FontWeight.Medium)
        .fontColor($r('sys.color.font_secondary'))
        .fontSize($r('sys.float.Subtitle_S'))
        .lineHeight(19)
        .constraintSize({ maxWidth: '50%' })
        .wordBreak(WordBreak.HYPHENATION)
        .width('50%')
        .margin({
          top: PADDING_4,
          start: PADDING_6,
          end: PADDING_6,
          bottom: PADDING_4
        })

      Button({ buttonStyle: ButtonStyleMode.TEXTUAL }) {
        Text($r('app.string.restore_defaults'))
          .fontFamily('HarmonyHeiTi')
          .fontWeight(FontWeight.Medium)
          .fontColor($r('sys.color.font_emphasize'))
          .fontSize($r('sys.float.Body_M'))
          .lineHeight(19)
          .textAlign(TextAlign.End)
          .constraintSize({ maxWidth: '50%' })
          .textOverflow({ overflow: TextOverflow.Ellipsis })
          .maxLines(2)
          .wordBreak(WordBreak.HYPHENATION)
      }
      .borderRadius($r('sys.float.corner_radius_level4'))
      .padding({
        top: $r('app.float.margin_4'),
        bottom: $r('app.float.margin_4'),
        left: $r('app.float.margin_2'),
        right: $r('app.float.margin_2'),
      })
      .margin({
        start: PADDING_6,
        end: PADDING_6,
      })
      .visibility(DeviceUtil.is2In1DevicePcType() ? Visibility.None : Visibility.Visible)
      .onClick(() => {
        this.handleClickEvent();
      })
    }
    .width('100%')
    .justifyContent(FlexAlign.SpaceBetween)
  }

  private handleClickEvent(): void {
    let groupName: string = ResourceUtil.getStringSync(this.name);
    LogUtil.info(`${this.tag} handleClickEvent: ${groupName}`);
    if (groupName === undefined) {
      return;
    }
    const index = RESTORE_GROUP_TYPE_LIST.findIndex((key) => {
      return ResourceUtil.getStringSync(key) === groupName;
    });
    if (index !== -1) {
      EventBus.getInstance().emit(RESTORE_DEFAULT_GROUP_EVENT, index);
    }
  }

  aboutToAppear(): void {
    LogUtil.info(`${this.tag} aboutToAppear`);
  }

  aboutToDisappear(): void {
    LogUtil.info(`${this.tag} aboutToDisappear`);
  }
}
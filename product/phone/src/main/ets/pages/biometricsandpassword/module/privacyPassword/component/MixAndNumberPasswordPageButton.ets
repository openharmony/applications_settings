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

import { CommonConstants } from '../common/constants/CommonConstants';
import FontScaleUtils, { LARGE_LIMIT_HEIGHT } from '../common/utils/FontScaleUtils';
import Log from '../common/utils/Log';
import { common } from '@kit.AbilityKit';

/* instrument ignore file */
const TAG = 'MixAndNumberPasswordPageButton';

@Component
export default struct MixAndNumberPasswordPageButton {
  @Prop resourceLeft: Resource;
  @Prop resourceRight: Resource;
  @Prop buttonAreaWidth: number;
  @Prop enableClick: boolean;
  @State bottomMargin: number = 16;
  private navigationIndicatorHeight: number = 48;
  @State isHeightTooSmall: boolean = false;
  @Consume @Watch('onContainerChange') containerHeight: number;

  onContainerChange() {
    this.isHeightTooSmall = this.containerHeight < LARGE_LIMIT_HEIGHT;
  }
  cancelClicked: () => void = () => {
  };

  continueClicked: () => void = () => {
  };

  aboutToAppear(): void {
    try {
      this.bottomMargin = getContext().resourceManager.getNumber($r('sys.float.padding_level8'));
      this.bottomMargin = this.navigationIndicatorHeight + this.bottomMargin;
    } catch (err) {
      this.bottomMargin = 16;
      Log.error(TAG, `getBottomMargin error, error code: ${err?.code}, message: ${err?.message}.`);
    }
  }

  build() {
   if (FontScaleUtils.buttonColumnLayout(this.buttonAreaWidth, this.resourceLeft, this.resourceRight)) {
     if (this.isHeightTooSmall && FontScaleUtils.isExtraLargeFontMode(getContext() as common.UIAbilityContext)) {
       Column({ space: 12 }) {
         Button(this.resourceLeft)
           .fontColor($r('sys.color.font_emphasize'))
           .fontWeight(FontWeight.Medium)
           .buttonStyle(ButtonStyleMode.NORMAL)
           .type(ButtonType.Normal)
           .borderRadius($r('sys.float.corner_radius_level10'))
           .width('100%')
           .fontSize(FontScaleUtils.getRealPX(getContext(), $r('sys.float.ohos_id_text_size_button1')))
           .onClick(() => {
             this.cancelClicked();
           })
         Button(this.resourceRight)
           .fontColor($r('sys.color.font_emphasize'))
           .fontWeight(FontWeight.Medium)
           .buttonStyle(ButtonStyleMode.NORMAL)
           .type(ButtonType.Normal)
           .borderRadius($r('sys.float.corner_radius_level10'))
           .width('100%')
           .enabled(this.enableClick)
           .fontSize(FontScaleUtils.getRealPX(getContext(), $r('sys.float.ohos_id_text_size_button1')))
           .onClick(() => {
             this.continueClicked();
           })
       }
       .width(this.buttonAreaWidth)
       .margin({
         top: $r('sys.float.padding_level8'),
         bottom: $r('sys.float.padding_level8')
       })
       .flexShrink(0)
     } else {
       Column({ space: 12 }) {
         Button(this.resourceLeft)
           .buttonCommonStyle()
           .width('100%')
           .onClick(() => {
             this.cancelClicked();
           })
         Button(this.resourceRight)
           .buttonCommonStyle()
           .width('100%')
           .enabled(this.enableClick)
           .onClick(() => {
             this.continueClicked();
           })
       }
       .width(this.buttonAreaWidth)
       .margin({
         top: $r('sys.float.padding_level8'),
         bottom: $r('sys.float.padding_level8')
       })
       .flexShrink(0)
     }
    } else {
      Row({ space: 12 }) {
        Button(this.resourceLeft)
          .buttonCommonStyle()
          .layoutWeight(1)
          .onClick(() => {
            this.cancelClicked();
          })
        Button(this.resourceRight)
          .buttonCommonStyle()
          .layoutWeight(1)
          .enabled(this.enableClick)
          .onClick(() => {
            this.continueClicked();
          })
      }
      .flexShrink(0)
      .constraintSize({
        minHeight: $r('app.float.wh_40'),
        maxWidth: CommonConstants.MAX_BUTTON_WIDTH,
      })
      .justifyContent(FlexAlign.Center)
      .margin({
        top: $r('sys.float.padding_level8'),
        bottom: $r('sys.float.padding_level8')
      })
    }
  }
}

@Extend(Button)
function buttonCommonStyle() {
  .fontColor($r('sys.color.font_emphasize'))
  .fontWeight(FontWeight.Medium)
  .buttonStyle(ButtonStyleMode.NORMAL)
  .type(ButtonType.Normal)
  .borderRadius($r('sys.float.corner_radius_level10'))
  .labelStyle({
    maxLines: 1,
    minFontSize: 9,
    maxFontSize: $r('app.float.font_16')
  })
}
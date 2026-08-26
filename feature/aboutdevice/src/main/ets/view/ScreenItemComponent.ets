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
import { AbilityUtils } from '@ohos/settings.common/src/main/ets/utils/AbilityUtils';
import { SystemUpdateConstants } from '@ohos/settings.common/src/main/ets/constant/SystemUpdateConstants';
import settings from '@ohos.settings';
import { DisplayConstant } from '@ohos/settings.common/src/main/ets/constant/DisplayConstant';
import { FontScaleUtils } from '@ohos/settings.common/src/main/ets/utils/FontScaleUtils';
import { SettingsDataUtils } from '@ohos/settings.common/src/main/ets/utils/SettingsDataUtils';
import { SystemParamUtil } from '@ohos/settings.common/src/main/ets/utils/SystemParamUtil';
import { AboutDeviceUtils } from '../utils/AboutDeviceUtils';

const DEFAULT_CARD_HEIGHT = 330;
const DEFAULT_FOOTER_SPACE = 12;
const DEFAULT_FOOTER_BOTTOM_MARGIN = 24;
const LARGE_FONT_FOOTER_SPACE = 16;
const LARGE_FONT_FOOTER_BOTTOM_MARGIN = 32;
const LARGE_FONT_SCALE_STEP = 0.25;
const LARGE_FONT_CARD_HEIGHT_STEP = 16;
const DEFAULT_CHECK_UPDATE_BUTTON_HEIGHT = 36;
const DEFAULT_CHECK_UPDATE_BUTTON_MIN_WIDTH = 120;
const DEFAULT_CHECK_UPDATE_BUTTON_HORIZONTAL_PADDING = 16;
const DEFAULT_CHECK_UPDATE_BUTTON_VERTICAL_PADDING = 4;
const LARGE_FONT_BUTTON_HEIGHT_STEP = 6;
const LARGE_FONT_BUTTON_MIN_WIDTH_STEP = 10;
const LARGE_FONT_BUTTON_HORIZONTAL_PADDING_STEP = 4;
const LARGE_FONT_BUTTON_VERTICAL_PADDING_STEP = 2;
const LARGE_FONT_CARD_FOOTER_GROWTH_STEP = LARGE_FONT_BUTTON_HEIGHT_STEP +
  LARGE_FONT_BUTTON_VERTICAL_PADDING_STEP * 2;

@Component
export struct ScreenItemComponent {
  @State API: string = '';

  private getValidFontScale(fontScale: number): number {
    if (Number.isNaN(fontScale) || fontScale < FontScaleUtils.DEFAULT_FONT_SCALE) {
      return FontScaleUtils.DEFAULT_FONT_SCALE;
    }
    return fontScale;
  }

  private getCurrentFontScale(): number {
    let contextScale = this.getValidFontScale(FontScaleUtils.getCurrentScale(getContext(this)));
    let settingsScale = this.getValidFontScale(Number(SettingsDataUtils.getSettingsDataDomain(settings.display.FONT_SCALE,
      DisplayConstant.DEFAULT_FONT_SIZE_SCALE, settings.domainName.USER_PROPERTY)));
    let paramScale = this.getValidFontScale(Number(SystemParamUtil.getParam(
      DisplayConstant.PERSIST_SYS_FONT_SIZE_SCALE, DisplayConstant.DEFAULT_FONT_SIZE_SCALE)));
    return Math.max(contextScale, settingsScale, paramScale);
  }

  private getCardHeight(): number {
    return DEFAULT_CARD_HEIGHT + this.getLargeFontScaleSteps() *
      (LARGE_FONT_CARD_HEIGHT_STEP + LARGE_FONT_CARD_FOOTER_GROWTH_STEP);
  }

  private getLargeFontScaleSteps(): number {
    let fontScale = this.getCurrentFontScale();
    if (fontScale < FontScaleUtils.EXTRA_LARGE_FONT) {
      return 0;
    }
    return Math.ceil((fontScale - FontScaleUtils.EXTRA_LARGE_FONT) / LARGE_FONT_SCALE_STEP) + 1;
  }

  private getFooterSpace(): number {
    return this.getCurrentFontScale() >= FontScaleUtils.EXTRA_LARGE_FONT ? LARGE_FONT_FOOTER_SPACE :
      DEFAULT_FOOTER_SPACE;
  }

  private getFooterBottomMargin(): number {
    return this.getCurrentFontScale() >= FontScaleUtils.EXTRA_LARGE_FONT ? LARGE_FONT_FOOTER_BOTTOM_MARGIN :
      DEFAULT_FOOTER_BOTTOM_MARGIN;
  }

  private getCheckUpdateButtonHeight(): number {
    return DEFAULT_CHECK_UPDATE_BUTTON_HEIGHT + this.getLargeFontScaleSteps() * LARGE_FONT_BUTTON_HEIGHT_STEP;
  }

  private getCheckUpdateButtonMinWidth(): number {
    return DEFAULT_CHECK_UPDATE_BUTTON_MIN_WIDTH + this.getLargeFontScaleSteps() * LARGE_FONT_BUTTON_MIN_WIDTH_STEP;
  }

  private getCheckUpdateButtonHorizontalPadding(): number {
    return DEFAULT_CHECK_UPDATE_BUTTON_HORIZONTAL_PADDING +
      this.getLargeFontScaleSteps() * LARGE_FONT_BUTTON_HORIZONTAL_PADDING_STEP;
  }

  private getCheckUpdateButtonVerticalPadding(): number {
    return DEFAULT_CHECK_UPDATE_BUTTON_VERTICAL_PADDING +
      this.getLargeFontScaleSteps() * LARGE_FONT_BUTTON_VERTICAL_PADDING_STEP;
  }

  build() {
    Column() {
      Blank()
        .layoutWeight(1)

      Column({ space: this.getFooterSpace() }) {
        Text(this.API)
          .fontFamily('HarmonyHeiTi')
          .fontWeight(FontWeight.Medium)
          .fontSize($r('sys.float.Body_L'))
          .fontColor(Color.White)

        Button() {
          Text($r('app.string.btn_check_new_version'))
            .fontSize($r('sys.float.Body_M'))
            .fontColor(Color.White)
            .fontWeight(FontWeight.Medium)
        }
        .type(ButtonType.Capsule)
        .constraintSize({
          minWidth: this.getCheckUpdateButtonMinWidth(),
          minHeight: this.getCheckUpdateButtonHeight(),
        })
        .padding({
          left: this.getCheckUpdateButtonHorizontalPadding(),
          right: this.getCheckUpdateButtonHorizontalPadding(),
          top: this.getCheckUpdateButtonVerticalPadding(),
          bottom: this.getCheckUpdateButtonVerticalPadding(),
        })
        .backgroundColor($r('app.color.0A59F7'))
        .onClick(() => {
          this.onCheckUpdateClick();
        })
      }
      .alignItems(HorizontalAlign.Center)
      .margin({ bottom: this.getFooterBottomMargin() })
    }
    .width('100%')
    .borderRadius($r('sys.float.corner_radius_level8'))
    .backgroundImage($r('app.media.video_bg'))
    .backgroundImageSize(ImageSize.Cover)
    .backgroundImagePosition(Alignment.Center)
    .height(this.getCardHeight())
    .onClick(() => {
      this.onCheckUpdateClick();
    })
  }

  aboutToAppear(): void {
    this.API = AboutDeviceUtils.getApiVersion();
  }

  private onCheckUpdateClick(): void {
    AbilityUtils.startAbility({
      bundleName: SystemUpdateConstants.OUC_BUNDLE_NAME,
      abilityName: 'com.ohos.updateapp.MainAbility',
    });
  }
}

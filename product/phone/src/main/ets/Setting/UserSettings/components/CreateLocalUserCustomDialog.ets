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

export interface IConfirmCrateUserDialogStyles {
  backgroundColor?: ResourceColor,
  shadow?: ShadowOptions | ShadowStyle,
  backgroundBlurStyle?: BlurStyle,
}

const MAX_LINES_2: number = 2;
const TAG: string = 'CreateLocalUserCustomDialog: '


@CustomDialog
export struct CreateLocalUserCustomDialog {
  controller: CustomDialogController;
  confirm: () => void = () => {
  };
  styles?: IConfirmCrateUserDialogStyles;
  fontSize?: ResourceStr;
  titleFontSize?: ResourceStr;
  lineHeight?: ResourceStr;

  build() {
    Column() {
      Text($r('app.string.creating_user'))
        .id('askForCreate')
        .fontSize(this.titleFontSize)
        .popFrameTitleTextStyle();

      Text($r('app.string.no_password_created_for_user'))
        .id('createInfo')
        .fontSize(this.fontSize)
        .lineHeight(this.lineHeight)
        .popFrameTextStyle();

      Row() {
        Button({ type: ButtonType.Normal, stateEffect: true }) {
          Text($r('app.string.cancel'))
            .fontSize(this.fontSize)
            .lineHeight(this.lineHeight)
            .fontColor($r('sys.color.font_emphasize'))
            .fontWeight(FontWeight.Medium)
            .fontFamily('HarmonyHeiTi')
            .textAlign(TextAlign.Center)
        }
        .id('cancelButton')
        .popFrameButtonStyle()
        .backgroundColor($r('sys.color.ohos_id_color_button_normal'))
        .onClick(() => {
          LogUtil.info(`${TAG} the cancel create user button is clicked , will to close the customDialog`);
          this.controller.close()
        });

        Button({ type: ButtonType.Normal, stateEffect: true }) {
          Text($r('app.string.button_tittle_yes'))
            .fontSize(this.fontSize)
            .lineHeight(this.lineHeight)
            .fontColor($r('sys.color.font_on_primary'))
            .fontWeight(FontWeight.Medium)
            .fontFamily('HarmonyHeiTi')
        }
        .id('okButton')
        .popFrameButtonStyle()
        .backgroundColor($r('sys.color.ohos_id_color_emphasize'))
        .margin({ left: 16 })
        .onClick(() => {
          LogUtil.info(`${TAG} the create user button is clicked,
          confirm to create user local user without password`);
          if (this.controller) {
            this.controller.close();
          }
          this.confirm()
        });
      }
      .margin({ bottom: 16 })
    }.dialogStyle();
  }
}

/* oobe弹框标题文本样式 */
@Extend(Text)
function popFrameTitleTextStyle() {
  .fontColor($r('sys.color.ohos_id_color_text_primary'))
  .fontWeight(FontWeight.Bold)
  .textAlign(TextAlign.Center)
  .width(352)
  .maxLines(MAX_LINES_2)
  .heightAdaptivePolicy(TextHeightAdaptivePolicy.MIN_FONT_SIZE_FIRST)
  .padding({
    top: $r('app.float.margin_0'),
    bottom: $r('app.float.margin_0'),
  })
  .margin({
    left: $r('app.float.margin_24'),
    right: $r('app.float.margin_24'),
    top: $r('app.float.margin_15'),
    bottom: $r('app.float.margin_14'),
  })
}

/* oobe弹框提示文本样式 */
@Extend(Text)
function popFrameTextStyle() {
  .fontColor($r('sys.color.ohos_id_color_text_primary'))
  .fontWeight(FontWeight.Regular)
  .fontFamily('HarmonyHeiTi')
  .width(352)
  .heightAdaptivePolicy(TextHeightAdaptivePolicy.LAYOUT_CONSTRAINT_FIRST)
  .margin({
    left: 24,
    right: 24,
    top: 0,
    bottom: 16
  })
}

/* oobe弹框内btn按钮样式 */
@Extend(Button)
function popFrameButtonStyle() {
  .align(Alignment.Center)
  .alignSelf(ItemAlign.Center)
  .width(176)
  .height($r('app.float.height_40'))
  .borderRadius($r('sys.float.corner_radius_level4'))
}


/* oobe弹窗样式 */
@Extend(Column)
function dialogStyle(styles?: IConfirmCrateUserDialogStyles) {
  .borderRadius(16)
  .width(400)
  .shadow(styles?.shadow)
}

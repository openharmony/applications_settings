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

import { LogUtil } from '@ohos/settings.common/src/main/ets/utils/LogUtil';
import { SettingsBaseMenu } from '@ohos/settings.common/src/main/ets/core/model/menu/SettingsMenu';
import { UiRefresher } from '@ohos/settings.common/src/main/ets/core/controller/Controller';
import { PwdLinkHwAccountMenuController } from '@ohos/settings.common/src/main/ets/core/controller/MenuController';
import { StyleConstant } from '@ohos/settings.common/src/main/ets/constant/StyleConstant';
import { SubHeaderStyle } from '@ohos/settings.common/src/main/ets/core/model/menu/ComponetStyle';

const TAG: string = 'HwAccountInfoTextMenuComponent: ';

@Component
export struct HwAccountInfoTextMenuComponent {
  tag: string = 'TextMenuComponent : ';
  @State menu?: SettingsBaseMenu = undefined;
  @State controller?: PwdLinkHwAccountMenuController = undefined;
  @State uiRefresher: UiRefresher = new UiRefresher();

  build() {
    Column() {
      Flex({ direction: FlexDirection.Row, justifyContent: FlexAlign.SpaceBetween, alignItems: ItemAlign.Center }) {
        Image(this.menu?.icon)
          .visibility(Visibility.Visible)
          .flexShrink(0)
          .flexGrow(0)
          .width(32)
          .height(32)
          .clipShape(new Circle({
            width: 32,
            height: 32
          }))
          .align(Alignment.Start)
          .autoResize(false)
          .draggable(false)
          .interpolation(ImageInterpolation.Medium)
          .margin({ right: 8 })

        Column() {
          Column() {
            Text((this.menu?.title))
              .fontColor($r('sys.color.ohos_id_color_text_primary'))
              .fontSize(16)
              .lineHeight(19)
              .fontWeight(FontWeight.Medium)
              .margin(1)
          }

          Column() {
            Text(this.menu?.summary)
              .visibility(Visibility.Visible)
              .fontColor($r('sys.color.ohos_id_color_text_secondary'))
              .fontSize(14)
              .lineHeight(16)
              .fontWeight(FontWeight.Regular)
              .margin(1)
          }
          .margin({ top: 2 })
          .visibility(this.uiRefresher.refreshId && this.controller?.isRealNameFlagShow ? Visibility.Visible :
          Visibility.None);

        }
        .flexGrow(1)
        .alignItems(HorizontalAlign.Start)
        .accessibilityGroup(true);

        Row() {
          Column() {
            Text(this.controller?.getRealAnonymousName())
              .fontColor($r('sys.color.ohos_id_color_text_secondary'))
              .fontSize(14)
              .lineHeight(16)
              .fontFamily('HarmonyHeiTi')
              .fontWeight(FontWeight.Regular)
              .margin(1)
          }
          .margin({ right: 8 })

          Column() {
            Text($r('app.string.already_registered_with_real_name'))
              .fontSize(10)
              .lineHeight(12)
              .fontColor($r('sys.color.font_emphasize'))
              .fontFamily('HarmonyHeiTi')
              .fontWeight(FontWeight.Regular)
              .margin(1)
          }
          .padding({
            right: 4,
            left: 4
          })
          .borderColor($r('sys.color.font_emphasize'))
          .borderWidth(2)
          .borderRadius(4)
        }
        .visibility(this.uiRefresher.refreshId && this.controller?.isRealNameFlagShow ? Visibility.Visible :
        Visibility.None)
        .flexGrow(0)
        .flexShrink(0)

      }
      .padding({ left: 12, right: 12 })
      .height(56)
      .width('100%')
    }
    .padding(StyleConstant.getLocalizedPadding((this.menu?.style as SubHeaderStyle)?.rootContainer?.padding))
    .margin(StyleConstant.getLocalizedPadding((this.menu?.style as SubHeaderStyle)?.rootContainer?.margin))
  }

  aboutToAppear(): void {
    LogUtil.showDebug(this.tag, ` aboutToAppear, ${this.menu?.getLogKey()}`);
    this.controller = this.menu?.getControllerInstance(this.uiRefresher) as PwdLinkHwAccountMenuController;
  }

  aboutToDisappear(): void {
    LogUtil.showDebug(this.tag, `aboutToDisappear, ${this.menu?.getLogKey()}`);
    this.controller?.aboutToDisappear();
  }
}
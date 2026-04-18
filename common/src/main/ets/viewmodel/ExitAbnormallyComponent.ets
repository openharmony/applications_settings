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
import { DeviceUtil } from '../utils/BaseUtils';

const DIALOG_WIDTH: number = 400;

@CustomDialog
export struct ExitAbnormallyComponent {
  controller?: CustomDialogController;
  private isPad: boolean = DeviceUtil.isDevicePad();
  private isFoldExpand: boolean = DeviceUtil.isFoldExpand();
  private dialogWidth: number | string = this.isPad || this.isFoldExpand ? DIALOG_WIDTH : '100%'
  private paddingValue: ResourceStr | number = this.isPad || this.isFoldExpand ? 0 : $r('sys.float.padding_level8');


  build() {
    Column() {
      Text($r('app.string.page_load_failed_message'))
        .fontFamily('HarmonyHeiTi')
        .fontSize($r('sys.float.Body_L'))
        .fontWeight(FontWeight.Regular)
        .fontColor($r('sys.color.icon_primary'))
        .constraintSize({ minHeight: $r('app.float.wh_value_24') })
        .margin({
          top: $r('app.float.margin_24'),
          bottom: $r('app.float.margin_8'),
        })
        .fontWeight(FontWeight.Regular)
        .textAlign(TextAlign.Start)

      Button() {
        Text($r('app.string.button_title_got_it'))
          .fontColor($r('sys.color.font_emphasize'))
          .fontSize($r('sys.float.Body_L'))
          .fontFamily('HarmonyHeiTi')
          .fontWeight(FontWeight.Medium)
          .width('100%')
          .textAlign(TextAlign.Center)
          .constraintSize({ minHeight: $r('app.float.wh_value_24') })
          .margin({
            top: $r('app.float.margin_8'),
            bottom: $r('app.float.margin_8'),
          })
      }
      .backgroundColor(Color.Transparent)
      .margin({
        top: $r('app.float.margin_8'),
        bottom: $r('app.float.margin_16'),
      })
      .onClick(() => {
        this.controller?.close();
      })
    }
    .width(this.dialogWidth)
    .padding({
      left: this.paddingValue,
      right: this.paddingValue,
    })
    .borderRadius($r('sys.float.corner_radius_level8'))
  }
}
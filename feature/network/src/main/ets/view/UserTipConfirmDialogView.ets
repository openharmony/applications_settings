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
import { DeviceUtil } from '@ohos/settings.common/src/main/ets/utils/BaseUtils';
import { DialogButton } from './NetworkDialogComponent';

@CustomDialog
struct UserTipConfirmDialogView {
  @State focused: boolean = false;
  private tipMessage: Resource | null = null;
  private controller?: CustomDialogController;
  private confirm: (() => void) | null = null;
  private scroller: Scroller = new Scroller();

  build() {
    Scroll(this.scroller) {
      Column() {
        Text(this.tipMessage)
          .textAlign(TextAlign.Center)
          .fontWeight(FontWeight.Medium)
          .fontSize($r('sys.float.Body_L'))
          .fontColor($r('sys.color.font_primary'))
          .constraintSize({
            minHeight: $r('app.float.length_21'),
          })
          .margin({
            top: $r('sys.float.padding_level12'),
            bottom: DeviceUtil.isDevicePc() ? $r('sys.float.padding_level8') : $r('sys.float.padding_level12'),
            left: $r('sys.float.padding_level4'),
            right: $r('sys.float.padding_level4')
          })

        Flex({ justifyContent: FlexAlign.Center, alignItems: ItemAlign.Center }) {
          DialogButton({
            title: $r('app.string.button_title_ok'),
            buttonWidth: '100%',
            isActive: false,
            clickMethod: () => {
              if (this.controller) {
                this.controller.close();
              }
              if (this.confirm) {
                this.confirm();
              }
            }
          })
        }
      }
      .padding({
        bottom: $r('sys.float.padding_level8'),
        left: $r('sys.float.padding_level8'),
        right: $r('sys.float.padding_level8')
      })
      .onFocus(() => {
        this.focused = true;
      })
      .onBlur(() => {
        this.focused = false;
      })
    }
  }
}

export { UserTipConfirmDialogView };

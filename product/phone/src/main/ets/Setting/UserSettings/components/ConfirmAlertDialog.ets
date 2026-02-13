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
/* 创建用户报错信息弹框 */
export class ConfirmAlertDialog {
  private msg: ResourceStr;
  private buttonText: ResourceStr;
  private action?: () => void = () => {
  }

  constructor(msg: ResourceStr, buttonText?: ResourceStr, action?: () => void) {
    this.msg = msg;
    this.buttonText = buttonText ?? $r('app.string.confirm');
    if (action) {
      this.action = action;
    }
  }

  public show(): void {
    AlertDialog.show({
      message: this.msg,
      autoCancel: true,
      backgroundColor: $r('sys.color.ohos_id_color_subtab_bg'),
      backgroundBlurStyle: BlurStyle.COMPONENT_ULTRA_THICK,
      shadow: DEFAULT_DIALOG_SHADOW,
      primaryButton: {
        value: this.buttonText,
        fontColor: $r('sys.color.ohos_id_color_text_primary_activated'),
        backgroundColor: $r('sys.color.ohos_id_color_button_normal'),
        action: this.action,
      },
    })
  }
}

const DEFAULT_DIALOG_SHADOW: ShadowOptions = {
  offsetX: 0,
  offsetY: 20,
  color: $r('sys.color.ohos_id_shadow_floating_md'),
  radius: 40,
}
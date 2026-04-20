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

import { SettingsBaseMenu } from '@ohos/settings.common/src/main/ets/core/model/menu/SettingsMenu';

const OPACITY_PERCENT_FULL: number = 1;
/* instrument ignore file */
const ALPHA_DISABLED: Resource = $r('sys.float.ohos_id_alpha_disabled');

@Component
export struct TextTipsComponent {
  @State menu?: SettingsBaseMenu = undefined;

  build() {
    Text($r('app.string.block_list_tips'))
      .fontFamily('HarmonyHeiTi')
      .fontWeight(FontWeight.Regular)
      .fontSize($r('sys.float.Body_S'))
      .fontColor($r('sys.color.font_secondary'))
      .constraintSize({
        minHeight: '16vp',
      })
      .textAlign(TextAlign.Start)
      .width('100%')
      .enabled(this.menu?.enable as boolean)
      .opacity((this.menu?.enable) ? OPACITY_PERCENT_FULL : ALPHA_DISABLED)
      .padding({
        left: '12vp',
        right: '12vp',
      })
      .margin({
        top: '8vp',
      })
  }
}
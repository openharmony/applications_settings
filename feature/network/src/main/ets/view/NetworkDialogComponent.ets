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

@Component
export struct DialogTitleBar {
  @State title: Resource = $r('app.string.network_proxy_title');

  build() {
    Text(this.title)
      .fontSize($r('sys.float.Title_S'))
      .fontColor($r('sys.color.font_primary'))
      .fontWeight(FontWeight.Bold)
      .fontFamily('HarmonyHeiTi')
      .width('100%')
      .constraintSize({
        minHeight: $r('app.float.height_56')
      })
      .padding({
        top: $r('sys.float.padding_level6'),
        bottom: $r('sys.float.padding_level6')
      })
      .textAlign(TextAlign.Center)
  }
}

@Component
export struct DialogButton {
  title: Resource = $r('app.string.save');
  buttonWidth: Resource | string = $r('app.float.network_dialog_button_width');
  isActive: boolean = false;
  customKey: string = 'dialog_button';
  clickMethod: () => void = () => {
  };

  build() {
    Button(this.title, { type: ButtonType.Normal, stateEffect: true })
      .backgroundColor(this.getBackgroundColor())
      .key(this.customKey)
      .fontColor(this.isActive ? Color.White
        : $r('sys.color.font_emphasize'))
      .fontSize($r('sys.float.Body_L'))
      .width(this.buttonWidth)
      .constraintSize({
        minHeight: $r('app.float.height_40')
      })
      .borderRadius(DeviceUtil.isDevicePc() ? $r('sys.float.corner_radius_level4') :
      $r('sys.float.corner_radius_level10'))
      .onClick((): void => this.clickMethod())
  }

  private getBackgroundColor(): ResourceColor {
    let inactiveColor: ResourceColor =
      DeviceUtil.isDevicePc() ? $r('sys.color.comp_background_tertiary') : Color.Transparent;
    return this.isActive ? $r('sys.color.brand') : inactiveColor;
  }
}
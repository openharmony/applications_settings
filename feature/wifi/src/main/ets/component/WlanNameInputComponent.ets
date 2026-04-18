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
import wifiManager from '@ohos.wifiManager';
import { TextInputMenuStyle } from '@ohos/settings.common/src/main/ets/core/model/menu/BaseMenu';
import { EventBus } from '@ohos/settings.common/src/main/ets/framework/common/EventBus';
import { InputComponent } from '@ohos/settings.commonUikit/src/main/ets/component/InputComponent';
import { DeviceUtil } from '@ohos/settings.common/src/main/ets/utils/BaseUtils';
import {
  NewDefaultTextInputMenuStyle,
  NewTextInputStyle,
  TextDividerStyle,
} from '@ohos/settings.commonUikit/src/main/ets/InputStyle';
import { WLAN_CONFIG_INPUT_CHANGE_EVENT } from '../model/WifiModel';
import { AddOtherWlanConfigManager } from '../AddOtherWlanConfigManager';

let newDefaultTextInputDividerStyle: TextDividerStyle = new TextDividerStyle();

// 限制网络名称最大长度
let ssidInputMenuStyle: NewDefaultTextInputMenuStyle = new NewDefaultTextInputMenuStyle();

let newTextInputStyle: NewTextInputStyle = new NewTextInputStyle();

const ADD_WIFI_MAX_LENGTH: number = 32;

@Component
export struct WlanNameInputComponent {
  item ?: object;
  private content: ResourceStr = '';
  private wifiConfig?: wifiManager.WifiDeviceConfig;
  @State showInputComponent: boolean = true;
  @State hasReachMaxNum: boolean = false;
  @State dividerBackgroundColor: Resource = $r('sys.color.comp_background_tertiary');

  build() {
    Column() {
      InputComponent({
        hint: $r('app.string.wifi_enter_ssid_hint'),
        content: this.content,
        onChange: (input: string) => {
          if (!this.wifiConfig) {
            return;
          }
          if (input?.length >= ADD_WIFI_MAX_LENGTH) {
            this.hasReachMaxNum = true;
          } else {
            this.hasReachMaxNum = false;
          }
          this.wifiConfig.ssid = input;
          EventBus.getInstance().emit(WLAN_CONFIG_INPUT_CHANGE_EVENT);
        },
        showComponent: this.showInputComponent,
        style: this.getStyle(),
      })

      if (this.hasReachMaxNum) {
        Text($r('app.string.wifi_name_max'))
          .padding({
            left: $r('sys.float.padding_level6')
          })
          .fontSize($r('sys.float.Body_S'))
          .fontColor($r('sys.color.warning'))
          .width('100%')
          .textAlign(TextAlign.Start)
          .margin({
            top: $r('sys.float.padding_level5'),
          })
      }
    }
    .width('100%')

  }

  aboutToAppear(): void {
    this.wifiConfig = AddOtherWlanConfigManager.getInstance().wifiConfig;
    this.initStyle();
  }

  initStyle(): void {
    newTextInputStyle.maxLength = ADD_WIFI_MAX_LENGTH;
    newTextInputStyle.padding = {
      left: DeviceUtil.isDevicePc() ? $r('sys.float.padding_level5') : 12,
    }
    newTextInputStyle.margin = {
      top: $r('app.float.margin_8'),
    }
    newDefaultTextInputDividerStyle.size = {
      width: DeviceUtil.isDevicePc() ? '100%' : 'calc(100% - 24vp)',
      height: $r('app.float.length_1'),
    }
    ssidInputMenuStyle.textInputStyle = newTextInputStyle;
    ssidInputMenuStyle.dividerStyle = newDefaultTextInputDividerStyle;
  }

  aboutToDisappear(): void {
  }

  private getStyle(): TextInputMenuStyle {
    return ssidInputMenuStyle;
  }
}
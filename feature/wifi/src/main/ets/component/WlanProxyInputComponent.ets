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
import { LanguageUtils } from '@ohos/settings.common/src/main/ets/utils/LanguageUtils';
import { LogUtil } from '@ohos/settings.common/src/main/ets/utils/LogUtil';
import { SettingGroupModel } from '@ohos/settings.common/src/main/ets/framework/model/SettingGroupModel';
import { EventBus } from '@ohos/settings.common/src/main/ets/framework/common/EventBus';
import { DeviceUtil } from '@ohos/settings.common/src/main/ets/utils/BaseUtils';
import {
  NewDefaultTextInputMenuStyle,
  NewNumDefaultTextInputMenuStyle,
  NewNumTextInputStyle,
  NewTextInputStyle,
} from '@ohos/settings.commonUikit/src/main/ets/InputStyle';
import { PROXY_EXCLUSION_MAX_LENGTH } from '@ohos/settings.uikit/src/main/ets/menus/Menu';
import { InputComponent } from '@ohos/settings.commonUikit/src/main/ets/component/InputComponent';
import { WifiPasswordConfigManager } from '../WifiPasswordConfigManager';
import { AddOtherWlanConfigManager } from '../AddOtherWlanConfigManager';
import { WIFI_PROXY_HOSTNAME_LABEL, WIFI_PROXY_PORT_LABEL, WIFI_PROXY_EXCLUSIONLIST_LABEL } from '../WifiMenuManager';
import { WLAN_PROXY_INPUT_CHANGE_EVENT } from '../model/WifiModel';

let newNumDefaultTextInputMenuStyle: NewNumDefaultTextInputMenuStyle = new NewNumDefaultTextInputMenuStyle();

let newDefaultTextInputMenuStyle: NewDefaultTextInputMenuStyle = new NewDefaultTextInputMenuStyle();

let newProxyTextInputMenuStyle: NewDefaultTextInputMenuStyle = new NewDefaultTextInputMenuStyle();

let newNumTextInputStyle: NewNumTextInputStyle = new NewNumTextInputStyle();

const TAG: string = 'WlanProxyInputComponent : ';

@Component
export struct WlanProxyInputComponent {
  private item?: SettingGroupModel;
  private hint: ResourceStr = $r('app.string.wifi_password_input_hint');
  private content: ResourceStr = '';
  private proxyConfig?: wifiManager.WifiProxyConfig;
  private maxWidth?: string = '100%';

  build() {
    Column() {
      InputComponent({
        hint: this.hint,
        content: this.content,
        onChange: (input: string) => {
          this.inputChange(input);
        },
        enablePreviewText: false,
        showComponent: true,
        style: this.getStyle(),
        showDivider: false,
        tabInd: this.item?.tabIndex
      })
    }
    .constraintSize({
      maxWidth: this.maxWidth,
    })
    .width('100%')
  }

  aboutToAppear(): void {
    LogUtil.info(`${TAG} aboutToAppear.`);
    let config: wifiManager.WifiDeviceConfig | undefined = AddOtherWlanConfigManager.getInstance().wifiConfig;
    if (config) {
      this.proxyConfig = config?.proxyConfig;
    } else {
      this.proxyConfig = WifiPasswordConfigManager.getInstance().getConfig()?.proxyConfig;
    }
    if (this.item?.id === WIFI_PROXY_HOSTNAME_LABEL) {
      this.hint = $r('app.string.wifi_proxy_hostname_hint');
      this.content = this.proxyConfig?.serverHostName ?? '';
      if (!LanguageUtils.isLtrDirection()) {
        this.maxWidth = '40%';
        if (DeviceUtil.isDevicePhone() || DeviceUtil.isFoldable()) {
          this.maxWidth = '33%';
        }
      }
    } else if (this.item?.id === WIFI_PROXY_PORT_LABEL) {
      this.hint = $r('app.string.wifi_proxy_port_hint');
      let serverPort: string = '';
      if (this.proxyConfig?.serverPort === undefined) {
        serverPort = '';
      } else {
        serverPort = `${this.proxyConfig.serverPort}`;
      }
      this.content = serverPort;
      if (!LanguageUtils.isLtrDirection() && (DeviceUtil.isDevicePhone() || DeviceUtil.isFoldable())) {
        this.maxWidth = '33%';
      }
    } else {
      this.hint = $r('app.string.wifi_proxy_exclusionlist_hint');
      this.content = this.proxyConfig?.exclusionObjects ?? '';
    }
  }

  aboutToDisappear(): void {
  }

  private getStyle(): TextInputMenuStyle {
    if (this.item?.id === WIFI_PROXY_PORT_LABEL) {
      newNumTextInputStyle.textAlign = TextAlign.End;
      newNumTextInputStyle.size = {
        height: 32,
      };
      newNumTextInputStyle.padding = {
        left: $r('sys.float.padding_level0'),
        right: $r('sys.float.padding_level0'),
        bottom: $r('sys.float.padding_level0'),
        top: $r('sys.float.padding_level0'),
      }
      newNumTextInputStyle.borderRadius = $r('sys.float.corner_radius_none');
      newNumDefaultTextInputMenuStyle.textInputStyle = newNumTextInputStyle;
      return newNumDefaultTextInputMenuStyle;
    }
    let newDefaultTextInputStyle: NewTextInputStyle = new NewTextInputStyle();
    newDefaultTextInputStyle.textAlign = LanguageUtils.isLtrDirection() ? TextAlign.End : TextAlign.Start;
    newDefaultTextInputStyle.direction = Direction.Ltr;
    newDefaultTextInputStyle.size = {
      height: 32,
    };
    newDefaultTextInputStyle.padding = {
      left: $r('sys.float.padding_level0'),
      right: $r('sys.float.padding_level0'),
      bottom: $r('sys.float.padding_level0'),
      top: $r('sys.float.padding_level0'),
    }
    newDefaultTextInputStyle.borderRadius = $r('sys.float.corner_radius_none');
    if (this.item?.id === WIFI_PROXY_EXCLUSIONLIST_LABEL) {
      newDefaultTextInputStyle.maxLength = PROXY_EXCLUSION_MAX_LENGTH;
      newProxyTextInputMenuStyle.textInputStyle = newDefaultTextInputStyle;
      return newProxyTextInputMenuStyle;
    }
    newDefaultTextInputMenuStyle.textInputStyle = newDefaultTextInputStyle;
    return newDefaultTextInputMenuStyle;
  }

  private inputChange(input: string): void {
    if (this.proxyConfig === undefined) {
      LogUtil.error(`${TAG} onChange, proxyConfig is invalid`);
      return;
    }
    if (this.item?.id === WIFI_PROXY_HOSTNAME_LABEL) {
      this.proxyConfig.serverHostName = input;
    } else if (this.item?.id === WIFI_PROXY_PORT_LABEL) {
      this.proxyConfig.serverPort = Number.parseInt(input);
    } else {
      this.proxyConfig.exclusionObjects = input;
    }
    EventBus.getInstance().emit(WLAN_PROXY_INPUT_CHANGE_EVENT);
  }
}
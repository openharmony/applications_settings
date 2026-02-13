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
import { LogUtil } from '@ohos/settings.common/src/main/ets/utils/LogUtil';
import { LanguageUtils } from '@ohos/settings.common/src/main/ets/utils/LanguageUtils';
import { SettingGroupModel } from '@ohos/settings.common/src/main/ets/framework/model/SettingGroupModel';
import { EventBus } from '@ohos/settings.common/src/main/ets/framework/common/EventBus';
import { DeviceUtil } from '@ohos/settings.common/src/main/ets/utils/BaseUtils';
import { InputComponent } from '@ohos/settings.commonUikit/src/main/ets/component/InputComponent';
import {
  NewDefaultTextInputMenuStyle,
  NewNumDefaultTextInputMenuStyle,
  NewNumTextInputStyle,
  NewTextInputStyle,
  TextInputMenuStyle,
} from '@ohos/settings.commonUikit/src/main/ets/InputStyle';
import { WifiUtils, IPV6_FAMILY_FLAG } from '../WifiUtils';
import {
  WIFI_IP_ADDRESS,
  WIFI_IP_DNS_SERVERS_1,
  WIFI_IP_DNS_SERVERS_2,
  WIFI_IP_GATEWAY,
  WIFI_IP_PREFIX_LENGTH,
} from '../WifiMenuManager';
import { WLAN_IP_INPUT_CHANGE_EVENT } from '../model/WifiModel';
import { WifiPasswordConfigManager } from '../WifiPasswordConfigManager';
import { AddOtherWlanConfigManager } from '../AddOtherWlanConfigManager';
import { WifiBaseConfigManager } from '../WifiBaseConfigManager';

let newNumDefaultTextInputMenuStyle: NewNumDefaultTextInputMenuStyle = new NewNumDefaultTextInputMenuStyle();

let newDefaultTextInputMenuStyle: NewDefaultTextInputMenuStyle = new NewDefaultTextInputMenuStyle();

let newNumTextInputStyle: NewNumTextInputStyle = new NewNumTextInputStyle();

let newDefaultTextInputStyle: NewTextInputStyle = new NewTextInputStyle();

@Component
export struct StaticIpInputComponent {
  private readonly tag: string = 'StaticIpInputComponent: ';
  private item?: SettingGroupModel;
  private hint: ResourceStr = '';
  private staticIp?: wifiManager.IpConfig;
  private staticIpv6?: wifiManager.Ipv6Config;
  private family: number = 0;
  private maxWidth?: string = '56%';
  @State content: ResourceStr = '';
  @State dividerBackgroundColor: Resource = $r('sys.color.comp_background_tertiary');

  build() {
    Column() {
      InputComponent({
        hint: this.hint,
        content: this.content,
        onChange: (input: string) => {
          this.inputChange(input);
        },
        onChangeInput: (input: string): string => {
          return this.onChangeInput(input);
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
    LogUtil.info(`${this.tag} aboutToAppear.`);
    let config: wifiManager.WifiDeviceConfig | undefined = AddOtherWlanConfigManager.getInstance().wifiConfig;
    if (config) {
      this.staticIp = config.staticIp;
      this.staticIpv6 = config.staticIpv6;
      this.family = config.family ?? 0;
    } else {
      this.staticIp = WifiPasswordConfigManager.getInstance().getConfig()?.staticIp;
      this.staticIpv6 = WifiPasswordConfigManager.getInstance().getConfig()?.staticIpv6;
      this.family = WifiPasswordConfigManager.getInstance().getConfig()?.family ?? 0;
    }
    this.initContent();
  }

  aboutToDisappear(): void {
  }

  /**
   * 文字提示内容
   *
   * @param id 标题id
   * @returns 返回字符串
   */
  private getIpHintString(id: string): ResourceStr {
    switch (id) {
      case WIFI_IP_ADDRESS:
        return $r('app.string.wifi_ip_address_hint');
      case WIFI_IP_GATEWAY:
        return $r('app.string.wifi_static_ip_gateway_hint');
      case WIFI_IP_PREFIX_LENGTH:
        return $r('app.string.wifi_static_ip_network_prefix_hint');
      case WIFI_IP_DNS_SERVERS_1:
        return $r('app.string.wifi_static_ip_dns_servers_1_hint');
      case WIFI_IP_DNS_SERVERS_2:
        return $r('app.string.wifi_static_ip_dns_servers_2_hint');
      default:
        return '';
    }
  }

  /**
   * 返回ip4、ipv6字符串
   *
   * @param ipAddress ipv4
   * @param ipv6Address ipv6
   * @returns 字符串内容
   */
  private getContent(ipAddress: number | undefined, ipv6Address?: string): ResourceStr {
    if (ipv6Address !== undefined && this.family === IPV6_FAMILY_FLAG) {
      return ipv6Address;
    }
    return WifiUtils.number2IpString(ipAddress ?? 0);
  }

  initContent(): void {
    if (this.item?.id === WIFI_IP_ADDRESS) {
      this.hint = this.getIpHintString(WIFI_IP_ADDRESS);
      this.content = this.getContent(this.staticIp?.ipAddress, this.staticIpv6?.ipAddress);
    } else if (this.item?.id === WIFI_IP_GATEWAY) {
      this.hint = this.getIpHintString(WIFI_IP_GATEWAY);
      this.content = this.getContent(this.staticIp?.gateway, this.staticIpv6?.gateway);
    } else if (this.item?.id === WIFI_IP_PREFIX_LENGTH) {
      this.hint = this.getIpHintString(WIFI_IP_PREFIX_LENGTH);
      this.maxWidth = '100%';
      if (!LanguageUtils.isLtrDirection()) {
        this.maxWidth = '40%';
        if (DeviceUtil.isDevicePhone() || DeviceUtil.isFoldable()) {
          this.maxWidth = '33%';
        }
      }
      if (this.staticIp?.prefixLength === 0) {
        this.content = '';
      }
      if (this.family === IPV6_FAMILY_FLAG) {
        this.content = `${this.staticIpv6?.prefixLength}`;
      } else {
        this.content = `${this.staticIp?.prefixLength}`;
      }
    } else if (this.item?.id === WIFI_IP_DNS_SERVERS_1) {
      this.hint = this.getIpHintString(WIFI_IP_DNS_SERVERS_1);
      this.content = this.getContent(this.staticIp?.dnsServers?.[0], this.staticIpv6?.dnsServers?.[0]);
    } else if (this.item?.id === WIFI_IP_DNS_SERVERS_2) {
      this.hint = this.getIpHintString(WIFI_IP_DNS_SERVERS_2);
      this.content = this.getContent(this.staticIp?.dnsServers?.[1], this.staticIpv6?.dnsServers?.[1]);
    }
  }

  private getStyle(): TextInputMenuStyle {
    if (this.item?.id === WIFI_IP_PREFIX_LENGTH) {
      newNumTextInputStyle.textAlign = TextAlign.End;
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
    newDefaultTextInputStyle.textAlign = LanguageUtils.isLtrDirection() ? TextAlign.End : TextAlign.Start;
    newDefaultTextInputStyle.direction = Direction.Ltr;
    newDefaultTextInputStyle.borderRadius = $r('sys.float.corner_radius_none');
    newDefaultTextInputStyle.padding = {
      left: $r('sys.float.padding_level0'),
      right: $r('sys.float.padding_level0'),
      bottom: $r('sys.float.padding_level0'),
      top: $r('sys.float.padding_level0'),
    }
    newDefaultTextInputMenuStyle.textInputStyle = newDefaultTextInputStyle;
    return newDefaultTextInputMenuStyle;
  }

  private inputChange(input: string): void {
    // 获取配置对象引用，确保数据同步
    let config: wifiManager.WifiDeviceConfig | undefined = AddOtherWlanConfigManager.getInstance().wifiConfig;
    if (!config) {
      config = WifiPasswordConfigManager.getInstance().getConfig();
    }
    
    if (this.staticIp === undefined) {
      this.staticIp = {
        ipAddress: 0,
        gateway: 0,
        prefixLength: 0,
        dnsServers: [],
        domains: [],
      }
      // 将新创建的对象赋值回配置对象，确保数据同步
      if (config) {
        config.staticIp = this.staticIp;
      }
    }
    if (this.staticIpv6 === undefined) {
      this.staticIpv6 = {
        ipAddress: '',
        gateway: '',
        prefixLength: 0,
        dnsServers: [],
        domains: [],
      }
      // 将新创建的对象赋值回配置对象，确保数据同步
      if (config) {
        config.staticIpv6 = this.staticIpv6;
      }
    }
    if (this.item?.id === WIFI_IP_ADDRESS) {
      this.staticIp.ipAddress = WifiBaseConfigManager.convertIpString2Number(input);
      this.staticIpv6.ipAddress = WifiBaseConfigManager.convertIpv6String(input);
    } else if (this.item?.id === WIFI_IP_GATEWAY) {
      this.staticIp.gateway = WifiBaseConfigManager.convertIpString2Number(input);
      this.staticIpv6.gateway = WifiBaseConfigManager.convertIpv6String(input);
    } else if (this.item?.id === WIFI_IP_PREFIX_LENGTH) {
      let sub = false;
      while (input.startsWith('0')) {
        input = input.substr(1);
        sub = true;
      }
      if (sub) {
        this.content = input;
      }
      let prefixLength: number = WifiBaseConfigManager.convertString2Number(input)
      this.staticIp.prefixLength = prefixLength;
      this.staticIpv6.prefixLength = prefixLength;
    } else if (this.item?.id === WIFI_IP_DNS_SERVERS_1) {
      // 确保dnsServers数组已初始化
      if (!this.staticIp.dnsServers || this.staticIp.dnsServers.length === 0) {
        this.staticIp.dnsServers = [];
      }
      if (!this.staticIpv6.dnsServers || this.staticIpv6.dnsServers.length === 0) {
        this.staticIpv6.dnsServers = [];
      }
      this.staticIp.dnsServers[0] = WifiBaseConfigManager.convertIpString2Number(input);
      this.staticIpv6.dnsServers[0] = WifiBaseConfigManager.convertIpv6String(input);
    } else if (this.item?.id === WIFI_IP_DNS_SERVERS_2) {
      // 判断dns2的值不为空则更新
      if (input) {
        if (this.staticIpv6?.dnsServers && this.staticIpv6.dnsServers.length <= 1) {
          this.staticIpv6.dnsServers.length = 2;
          this.staticIpv6.dnsServers[1] = WifiBaseConfigManager.convertIpv6String(input);
        } else if (this.staticIpv6?.dnsServers && this.staticIpv6.dnsServers.length === 2) {
          this.staticIpv6.dnsServers[1] = WifiBaseConfigManager.convertIpv6String(input);
        } else {
          LogUtil.error(`${this.tag} onChange, staticIpv6 dnsServers is invalid`);
        }
        if (this.staticIp?.dnsServers && this.staticIp.dnsServers.length <= 1) {
          this.staticIp.dnsServers.length = 2;
          this.staticIp.dnsServers[1] = WifiBaseConfigManager.convertIpString2Number(input);
        } else if (this.staticIp?.dnsServers && this.staticIp.dnsServers.length === 2) {
          this.staticIp.dnsServers[1] = WifiBaseConfigManager.convertIpString2Number(input);
        } else {
          LogUtil.error(`${this.tag} onChange, staticIp dnsServers is invalid`);
        }
      } else {
        // 为空，则清空dns2的数据
        if (this.staticIp?.dnsServers && this.staticIp.dnsServers.length === 2) {
          this.staticIp.dnsServers.pop();
        }
        if (this.staticIpv6?.dnsServers && this.staticIpv6.dnsServers.length === 2) {
          this.staticIpv6.dnsServers.pop();
        }
      }
    }
    EventBus.getInstance().emit(WLAN_IP_INPUT_CHANGE_EVENT);
  }

  /**
   * 去除0开始的网络前缀数字
   * @param input 组件输入
   * @returns 非0开头的数字
   */
  private onChangeInput(input: string): string {
    if (this.item?.id === WIFI_IP_PREFIX_LENGTH) {
      while (input.startsWith('0')) {
        input = input.substr(1);
      }
    }
    return input;
  }
}
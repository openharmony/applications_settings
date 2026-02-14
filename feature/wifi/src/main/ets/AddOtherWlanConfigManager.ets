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

import wifiManager from '@ohos.wifiManager';
import { LogUtil } from '@ohos/settings.common/src/main/ets/utils/LogUtil';
import { WapiPskType } from './WifiMenuManager';
import { WifiUtils } from './WifiUtils';

const TAG: string = 'AddOtherWlanConfigManager: ';

/**
 * add other wlan config manager
 *
 * @since 2024-07-17
 */
export class AddOtherWlanConfigManager {
  private static instance: AddOtherWlanConfigManager;
  public wifiConfig?: wifiManager.WifiDeviceConfig;
  private isAddOtherWlanPage: boolean = false;

  public static getInstance(): AddOtherWlanConfigManager {
    if (AddOtherWlanConfigManager.instance == null) {
      AddOtherWlanConfigManager.instance = new AddOtherWlanConfigManager();
    }
    return AddOtherWlanConfigManager.instance;
  }

  /**
   * 设置添加网络页面状态标识
   *
   * @param isAddOtherWlanPage 是否在添加网络页面
   */
  public setAddOtherWlanPageFlag(isAddOtherWlanPage: boolean): void {
    this.isAddOtherWlanPage = isAddOtherWlanPage;
  }

  /**
   * 获取添加网络页面状态标识
   *
   * @returns 是否在添加网络界面
   */
  public getAddOtherWlanPageFlag(): boolean {
    return this.isAddOtherWlanPage;
  }

  public initConfig(): wifiManager.WifiDeviceConfig {
    this.wifiConfig = {
      isHiddenSsid: true,
      ssid: '',
      preSharedKey: '',
      securityType: wifiManager.WifiSecurityType.WIFI_SEC_TYPE_OPEN,
      ipType: wifiManager.IpType.DHCP,
      randomMacType: 0,
      family: 0,
      staticIp: {
        ipAddress: 0,
        gateway: 0,
        prefixLength: 0,
        dnsServers: [],
        domains: [],
      },
      staticIpv6: {
        ipAddress: '',
        gateway: '',
        prefixLength: 0,
        dnsServers: [],
        domains: [],
      },
      proxyConfig: {
        proxyMethod: wifiManager.ProxyMethod.METHOD_NONE,
      },
      wapiConfig: {
        wapiPskType: WapiPskType.WAPI_PSK_ASCII,
        wapiAsCert: '',
        wapiUserCert: '',
      },
      eapConfig: {
        eapMethod: wifiManager.EapMethod.EAP_PEAP,
        phase2Method: wifiManager.Phase2Method.PHASE2_MSCHAPV2,
        identity: '',
        anonymousIdentity: '',
        password: '',
        caCertAlias: '',
        caPath: '',
        clientCertAlias: '',
        certEntry: new Uint8Array(),
        certPassword: '',
        altSubjectMatch: '',
        domainSuffixMatch: '',
        realm: '',
        plmn: '',
        eapSubId: 0,
      }
    };
    return this.wifiConfig;
  }

  public getConfig(): wifiManager.WifiDeviceConfig | undefined {
    return this.wifiConfig;
  }

  public clearConfig(): void {
    this.wifiConfig = undefined;
  }

  /**
   * connect wifi
   *
   */
  public connectToWifiDevice(): void {
    if (!this.wifiConfig) {
      LogUtil.warn(`${TAG} connectToWifiDevice config null`);
      return;
    }
    let config: wifiManager.WifiDeviceConfig = this.wifiConfig;
    if (this.wifiConfig?.proxyConfig?.proxyMethod === wifiManager.ProxyMethod.METHOD_NONE) {
      config.proxyConfig = undefined;
    }
    if (config?.ipType === wifiManager.IpType.DHCP) {
      config.staticIp = undefined;
    }
    if (config?.securityType !== wifiManager.WifiSecurityType.WIFI_SEC_TYPE_WAPI_CERT &&
      config?.securityType !== wifiManager.WifiSecurityType.WIFI_SEC_TYPE_WAPI_PSK) {
      config.wapiConfig = undefined;
    }
    // 手动连接 把bssid清空 底层可以优选连接
    config.bssid = undefined;
  }

  public clearAndGetFormattedConfig(config: wifiManager.WifiDeviceConfig): wifiManager.WifiDeviceConfig {
    if (this.wifiConfig?.proxyConfig?.proxyMethod === wifiManager.ProxyMethod.METHOD_NONE) {
      config.proxyConfig = undefined;
    }
    if (config?.ipType === wifiManager.IpType.DHCP) {
      config.staticIp = undefined;
    }
    if (config?.securityType !== wifiManager.WifiSecurityType.WIFI_SEC_TYPE_WAPI_CERT &&
      config?.securityType !== wifiManager.WifiSecurityType.WIFI_SEC_TYPE_WAPI_PSK) {
      config.wapiConfig = undefined;
    }
    if (config?.securityType === wifiManager.WifiSecurityType.WIFI_SEC_TYPE_WAPI_CERT ||
      config?.securityType == wifiManager.WifiSecurityType.WIFI_SEC_TYPE_WAPI_PSK) {
      config.eapConfig = undefined;
    }
    config.bssid = undefined;
    WifiUtils.clearUseLessParam(config);
    return config;
  }
}
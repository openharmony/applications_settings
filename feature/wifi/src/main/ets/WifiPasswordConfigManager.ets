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
import { WlanItemModel } from './model/WlanItemModel';
import { WapiPskType } from './WifiMenuManager';
import { WifiUtils } from './WifiUtils';

const TAG: string = 'WifiPasswordConfigManager: ';

/**
 * wifi base config manager
 *
 * @since 2024-07-06
 */
export class WifiPasswordConfigManager {
  private static instance: WifiPasswordConfigManager;
  public wifiConfig?: wifiManager.WifiDeviceConfig;
  public model?: WlanItemModel;
  public hiLinkLoadingContent?: ResourceStr | undefined;

  public static getInstance(): WifiPasswordConfigManager {
    if (WifiPasswordConfigManager.instance == null) {
      WifiPasswordConfigManager.instance = new WifiPasswordConfigManager();
    }
    return WifiPasswordConfigManager.instance;
  }

  public initConfig(wifiConfig: wifiManager.WifiDeviceConfig, model?: WlanItemModel): void {
    this.wifiConfig = wifiConfig;
    if (model) {
      this.model = {
        id: model.id,
        wlanName: model.wlanName,
        securityType: model.securityType,
        isHiLinkNetwork: model.isHiLinkNetwork,
        isHiLinkProNetwork: model.isHiLinkProNetwork,
        capabilities: model.capabilities,
        type: 0,
      };
    }
  }

  public getConfig(): wifiManager.WifiDeviceConfig | undefined {
    return this.wifiConfig;
  }

  public clearConfig(): void {
    this.wifiConfig = undefined;
    this.model = undefined;
  }

  public setPreSharedKey(preSharedKey: string): void {
    if (!this.wifiConfig) {
      return;
    }
    this.wifiConfig.preSharedKey = preSharedKey;
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

  public getDefaultWifiConfig(apMenu: WlanItemModel): wifiManager.WifiDeviceConfig {
    if (WifiUtils.isNormalWlan(apMenu.securityType ?? 0)) {
      return this.createDefaultNormalConfig(apMenu);
    }
    return {
      ssid: apMenu.ssid ?? '',
      bssid: apMenu.bssid,
      bssidType: apMenu.bssidType,
      preSharedKey: '',
      securityType: apMenu.securityType ?? 0,
      isHiddenSsid: false,
      ipType: wifiManager.IpType.DHCP,
      randomMacType: 0,
      family:0,
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
  }

  private createDefaultNormalConfig(apMenu: WlanItemModel): wifiManager.WifiDeviceConfig {
    return {
      ssid: apMenu.ssid ?? '',
      bssid: apMenu.bssid,
      bssidType: apMenu.bssidType,
      preSharedKey: '',
      securityType: apMenu.securityType ?? 0,
      isHiddenSsid: false,
      ipType: wifiManager.IpType.DHCP,
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
      family:0,
      randomMacType: 0,
      proxyConfig: {
        proxyMethod: wifiManager.ProxyMethod.METHOD_NONE,
      },
    };
  }
}
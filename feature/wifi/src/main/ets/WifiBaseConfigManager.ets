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
import { MenuController } from '@ohos/settings.common/src/main/ets/core/controller/MenuController';
import {
  WIFI_EAP_ANONYMOUS,
  WIFI_EAP_IDENTITY,
  WIFI_EAP_METHOD,
  WIFI_EAP_PASSWORD,
  WIFI_EAP_SELECT_PHASE2,
  WIFI_IP_ADDRESS,
  WIFI_IP_DNS_SERVERS_1,
  WIFI_IP_DNS_SERVERS_2,
  WIFI_IP_GATEWAY,
  WIFI_IP_PREFIX_LENGTH,
  WIFI_IP_SETTINGS,
  WIFI_MANUAL_PROXY_SETTINGS,
  WIFI_PASSWORD_INPUT,
  WIFI_PRIVACY_MAC_ADDRESS_SETTINGS,
  WIFI_PROXY_EXCLUSIONLIST_LABEL,
  WIFI_PROXY_HOSTNAME_LABEL,
  WIFI_PROXY_PORT_LABEL,
  WIFI_EAP_CA_CERTIFICATE,
  WIFI_EAP_DOMAIN,
  WIFI_EAP_USER_CERTIFICATE,
  CaCertificateType,
  WapiPskType,
  WIFI_WAPI_PSK_PASSWORD_TYPE,
  WIFI_WAPI_CERT_AS_CERTIFICATE,
  WIFI_WAPI_CERT_USER_CERTIFICATE,
} from './WifiMenuManager';
import { apConnectManager, WifiConnectListener } from './WifiTracker';
import { WifiUtils } from './WifiUtils';
import { WlanDisconnectedReason } from './model/WifiModel';
import { AddOtherWlanConfigManager } from './AddOtherWlanConfigManager';
import { ResourceUtil } from '@ohos/settings.common/src/main/ets/utils/ResourceUtil';

/* instrument ignore file */
type MenuValueType = number | string | undefined;
const TAG: string = 'WifiConfigBaseController : ';


/**
 * wifi base config manager
 *
 * @since 2023-10-05
 */
export class WifiBaseConfigManager {
  public apConfig: wifiManager.WifiDeviceConfig;
  public wifiEapMenuKeyAndVal: Map<string, MenuValueType>;
  public wifiProxyMenuKeyAndVal: Map<string, MenuValueType>;
  public wifiIpMenuKeyAndVal: Map<string, MenuValueType>;
  public wifiWapiMenuKeyAndVal: Map<string, MenuValueType>;

  constructor(apConfig: wifiManager.WifiDeviceConfig) {
    this.apConfig = apConfig;
    if (!this.apConfig) {
      LogUtil.warn(`${TAG} apConfig is empty`);
      this.apConfig = WifiBaseConfigManager.initAppConfig();
    }
    this.wifiProxyMenuKeyAndVal = WifiBaseConfigManager.initWifiProxyMenuKeyAndValMap(this.apConfig?.proxyConfig);
    this.wifiEapMenuKeyAndVal = WifiBaseConfigManager.initWifiEapMenuKeyAndValMap(this.apConfig?.eapConfig);
    this.wifiWapiMenuKeyAndVal = WifiBaseConfigManager.initWifiWapiMenuKeyAndValMap(this.apConfig?.wapiConfig);
    this.wifiIpMenuKeyAndVal = WifiBaseConfigManager.initWifiIpMenuKeyAndValMap(this.apConfig?.staticIp,
      this.apConfig?.ipType);
  }

  /**
   * register other menu data change
   *
   * @param controller other menu controller
   */
  registerDataChange(controller: MenuController): void {
    LogUtil.info(`${TAG} registerDataChange`);
    controller.registerControllerDataChange(WIFI_PASSWORD_INPUT);
    controller.registerControllerDataChange(WIFI_PRIVACY_MAC_ADDRESS_SETTINGS);
    WifiBaseConfigManager.registerMenuControllerDataChange(this.wifiProxyMenuKeyAndVal.keys(), controller);
    WifiBaseConfigManager.registerMenuControllerDataChange(this.wifiEapMenuKeyAndVal.keys(), controller);
    WifiBaseConfigManager.registerMenuControllerDataChange(this.wifiWapiMenuKeyAndVal.keys(), controller);
    WifiBaseConfigManager.registerMenuControllerDataChange(this.wifiIpMenuKeyAndVal.keys(), controller);
  }

  /**
   * unregister other menu data change
   *
   * @param controller other menu controller
   */
  unRegisterDataChange(controller: MenuController): void {
    LogUtil.info(`${TAG} unRegisterDataChange`);
    controller.unRegisterControllerDataChange(WIFI_PASSWORD_INPUT);
    controller.unRegisterControllerDataChange(WIFI_PRIVACY_MAC_ADDRESS_SETTINGS);
    WifiBaseConfigManager.unRegisterMenuControllerDataChange(this.wifiProxyMenuKeyAndVal.keys(), controller);
    WifiBaseConfigManager.unRegisterMenuControllerDataChange(this.wifiEapMenuKeyAndVal.keys(), controller);
    WifiBaseConfigManager.unRegisterMenuControllerDataChange(this.wifiWapiMenuKeyAndVal.keys(), controller);
    WifiBaseConfigManager.unRegisterMenuControllerDataChange(this.wifiIpMenuKeyAndVal.keys(), controller);
  }

  /**
   * monitor menus data change callback
   *
   * @param fromKey monitor menu index
   * @param data monitor menu broadcast data
   */
  onDataChange(fromKey: string, data: number | string): void {
    LogUtil.info(`${TAG} onDataChange, fromKey: ${fromKey}`);
    // process wifi password
    if (fromKey === WIFI_PASSWORD_INPUT) {
      this.apConfig.preSharedKey = data as string;
    }

    if (fromKey === WIFI_PRIVACY_MAC_ADDRESS_SETTINGS) {
      this.apConfig.randomMacType = data as number;
    }
    // process wifi eap configs
    if (this.wifiEapMenuKeyAndVal.has(fromKey)) {
      this.wifiEapMenuKeyAndVal.set(fromKey, data);
      this.apConfig.eapConfig = WifiBaseConfigManager.getWifiEapConfigInfo(this.wifiEapMenuKeyAndVal);
    }

    // process wifi wapi configs
    if (this.wifiWapiMenuKeyAndVal.has(fromKey)) {
      this.wifiWapiMenuKeyAndVal.set(fromKey, data);
      this.apConfig.wapiConfig = WifiBaseConfigManager.getWifiWapiConfigInfo(this.wifiWapiMenuKeyAndVal);
    }

    // process wifi proxy configs
    if (this.wifiProxyMenuKeyAndVal.has(fromKey)) {
      this.wifiProxyMenuKeyAndVal.set(fromKey, data);
      this.apConfig.proxyConfig = WifiBaseConfigManager.getWifiProxyConfigInfo(this.wifiProxyMenuKeyAndVal);
    }

    // process wifi ip configs
    if (this.wifiIpMenuKeyAndVal.has(fromKey)) {
      this.wifiIpMenuKeyAndVal.set(fromKey, data);
      this.apConfig.staticIp = WifiBaseConfigManager.getWifiIpConfigInfo(this.wifiIpMenuKeyAndVal);
      this.apConfig.ipType = this.wifiIpMenuKeyAndVal.get(WIFI_IP_SETTINGS) as number;
    }
  }

  /**
   * 清空掉没必要的参数
   */
  private clearParam(config: wifiManager.WifiDeviceConfig): wifiManager.WifiDeviceConfig {
    if (config.eapConfig) {
      // 密码
      if (![
        wifiManager.EapMethod.EAP_PEAP,
        wifiManager.EapMethod.EAP_TTLS,
        wifiManager.EapMethod.EAP_PWD,
      ].includes(config.eapConfig.eapMethod)) {
        config.eapConfig.password = '';
      }
      // ca证书
      if (![
        wifiManager.EapMethod.EAP_PEAP,
        wifiManager.EapMethod.EAP_TLS,
        wifiManager.EapMethod.EAP_TTLS,
      ].includes(config.eapConfig.eapMethod)) {
        config.eapConfig.caCertAlias = '';
        config.eapConfig.caPath = '';
      }
      // 用户凭据
      if (![wifiManager.EapMethod.EAP_TLS].includes(config.eapConfig.eapMethod)) {
        config.eapConfig.clientCertAlias = '';
      }
      // 匿名身份/阶段2验证
      if (![wifiManager.EapMethod.EAP_PEAP, wifiManager.EapMethod.EAP_TTLS].includes(config.eapConfig.eapMethod)) {
        config.eapConfig.phase2Method = wifiManager.Phase2Method.PHASE2_NONE;
        config.eapConfig.anonymousIdentity = '';
      }
      // 身份
      if (![
        wifiManager.EapMethod.EAP_PEAP,
        wifiManager.EapMethod.EAP_TLS,
        wifiManager.EapMethod.EAP_TTLS,
        wifiManager.EapMethod.EAP_PWD,
      ].includes(config.eapConfig.eapMethod)) {
        config.eapConfig.identity = '';
      }
    }
    // 选我们提供的枚举的时候 把参数清空掉
    if (typeof config?.eapConfig?.caCertAlias === 'number') {
      config.eapConfig.caCertAlias = '';
    }
    if (typeof config?.eapConfig?.clientCertAlias === 'number') {
      config.eapConfig.clientCertAlias = '';
    }
    return config;
  }

  /**
   * connect wifi
   *
   * @param isReconnect  reconnect or not
   * @param listener controller for monitoring connection results
   */
  connectToWifiDevice(listener: WifiConnectListener, isReconnect: boolean = false, isRetry: boolean = false): void {
    LogUtil.info(`${TAG} connectToWifiDevice, isReconnect: ${isReconnect}`);
    if (!this.apConfig) {
      LogUtil.warn(`${TAG} connectToWifiDevice config null`);
      return;
    }
    let config: wifiManager.WifiDeviceConfig = this.apConfig;
    if (this.apConfig?.proxyConfig?.proxyMethod === wifiManager.ProxyMethod.METHOD_NONE) {
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
    LogUtil.debug(`${TAG} connectToWifiDevice startConnect start`);
    apConnectManager.startConnect(this.clearParam(config), isReconnect, listener, isRetry);
    LogUtil.debug(`${TAG} connectToWifiDevice startConnect end`);
  }

  /**
   * get wifi device config
   *
   * @returns wifi device config
   */
  getApConfig(): wifiManager.WifiDeviceConfig {
    return this.apConfig;
  }

  /**
   * init wifi eap config key and value map
   *
   * @param eapConfig eap info
   * @returns menu key and value map
   */
  static initWifiEapMenuKeyAndValMap(eapConfig?: wifiManager.WifiEapConfig): Map<string, MenuValueType> {
    LogUtil.info(`${TAG} initWifiEapMenuKeyAndValMap start`);
    let result: Map<string, MenuValueType> = new Map();
    result.set(WIFI_EAP_METHOD, eapConfig?.eapMethod ?? wifiManager.EapMethod.EAP_PEAP);
    result.set(WIFI_EAP_SELECT_PHASE2, eapConfig?.phase2Method ?? wifiManager.Phase2Method.PHASE2_MSCHAPV2);
    result.set(WIFI_EAP_CA_CERTIFICATE, eapConfig?.caCertAlias ?? '');
    result.set(WIFI_EAP_DOMAIN, eapConfig?.domainSuffixMatch ?? '');
    result.set(WIFI_EAP_USER_CERTIFICATE, eapConfig?.clientCertAlias ?? '');
    result.set(WIFI_EAP_IDENTITY, eapConfig?.identity ?? '');
    result.set(WIFI_EAP_ANONYMOUS, eapConfig?.anonymousIdentity ?? '');
    result.set(WIFI_EAP_PASSWORD, eapConfig?.password ?? '');

    LogUtil.info(`${TAG} initWifiEapMenuKeyAndValMap end`);

    return result;
  }

  /**
   * config wifi eap info
   *
   * @param wifiEapMenuKeyAndVal wifi eap method menu key and value map
   * @returns wifi eap configs
   */
  static getWifiEapConfigInfo(wifiEapMenuKeyAndVal: Map<string, MenuValueType>): wifiManager.WifiEapConfig {
    return {
      eapMethod: wifiEapMenuKeyAndVal.get(WIFI_EAP_METHOD) as number ?? wifiManager.EapMethod.EAP_PEAP,
      phase2Method: wifiEapMenuKeyAndVal.get(WIFI_EAP_METHOD) as number === wifiManager.EapMethod.EAP_PWD ?
        wifiManager.Phase2Method.PHASE2_NONE : (wifiEapMenuKeyAndVal.get(WIFI_EAP_SELECT_PHASE2) as number ??
        wifiManager.Phase2Method.PHASE2_MSCHAPV2),
      identity: wifiEapMenuKeyAndVal.get(WIFI_EAP_IDENTITY) as string,
      anonymousIdentity: wifiEapMenuKeyAndVal.get(WIFI_EAP_ANONYMOUS) as string,
      password: wifiEapMenuKeyAndVal.get(WIFI_EAP_PASSWORD) as string,
      caCertAlias: wifiEapMenuKeyAndVal.get(WIFI_EAP_CA_CERTIFICATE) as string,
      // 如果选择系统证书 这里给路径
      caPath: wifiEapMenuKeyAndVal.get(WIFI_EAP_CA_CERTIFICATE) === CaCertificateType.CA_CERTIFICATE_TYPE_SYSTEM ?
        '/system/etc/security/certificates/' : '',
      clientCertAlias: wifiEapMenuKeyAndVal.get(WIFI_EAP_USER_CERTIFICATE) as string,
      certEntry: new Uint8Array(),
      certPassword: '',
      altSubjectMatch: '',
      domainSuffixMatch: wifiEapMenuKeyAndVal.get(WIFI_EAP_DOMAIN) as string,
      realm: '',
      plmn: '',
      eapSubId: 0,
    };
  }

  /**
   * init wifi wapi config key and value map
   *
   * @param wapiConfig info
   * @returns wapi menu key and value map
   */
  private static initWifiWapiMenuKeyAndValMap(wapiConfig?: wifiManager.WifiWapiConfig): Map<string, MenuValueType> {
    let result: Map<string, MenuValueType> = new Map();
    result.set(WIFI_WAPI_PSK_PASSWORD_TYPE, wapiConfig?.wapiPskType ?? WapiPskType.WAPI_PSK_ASCII);
    result.set(WIFI_WAPI_CERT_AS_CERTIFICATE, wapiConfig?.wapiAsCert ?? '');
    result.set(WIFI_WAPI_CERT_USER_CERTIFICATE, wapiConfig?.wapiUserCert ?? '');
    return result;
  }

  /**
   * config wifi proxy info
   *
   * @param wifiProxyMenuKeyAndVal wifi proxy menus key and value map
   * @returns result
   */
  static getWifiWapiConfigInfo(wifiWapiMenuKeyAndVal: Map<string, MenuValueType>):
    wifiManager.WifiWapiConfig {
    return {
      wapiPskType: wifiWapiMenuKeyAndVal.get(WIFI_WAPI_PSK_PASSWORD_TYPE) as number ?? WapiPskType.WAPI_PSK_ASCII,
      wapiAsCert: wifiWapiMenuKeyAndVal.get(WIFI_WAPI_CERT_AS_CERTIFICATE) as string ?? '',
      wapiUserCert: wifiWapiMenuKeyAndVal.get(WIFI_WAPI_CERT_USER_CERTIFICATE) as string ?? '',
    };
  }

  /**
   * init wifi proxy config key and value map
   *
   * @param proxyConfig proxy info
   * @returns proxy menu key and value map
   */
  private static initWifiProxyMenuKeyAndValMap(proxyConfig?: wifiManager.WifiProxyConfig): Map<string, MenuValueType> {
    LogUtil.info(`${TAG} initWifiProxyMenuKeyAndValMap.`);
    let result: Map<string, MenuValueType> = new Map();
    result.set(WIFI_MANUAL_PROXY_SETTINGS, proxyConfig?.proxyMethod ?? wifiManager.ProxyMethod.METHOD_NONE);
    result.set(WIFI_PROXY_HOSTNAME_LABEL, proxyConfig?.serverHostName ?? '');
    result.set(WIFI_PROXY_PORT_LABEL, proxyConfig?.serverPort ?? undefined);
    result.set(WIFI_PROXY_EXCLUSIONLIST_LABEL, proxyConfig?.exclusionObjects ?? '');

    return result;
  }

  /**
   * config wifi proxy info
   *
   * @param wifiProxyMenuKeyAndVal wifi proxy menus key and value map
   * @returns result
   */
  static getWifiProxyConfigInfo(wifiProxyMenuKeyAndVal: Map<string, MenuValueType>):
    wifiManager.WifiProxyConfig {
    return {
      proxyMethod: Number.parseInt(wifiProxyMenuKeyAndVal.get(WIFI_MANUAL_PROXY_SETTINGS) as string),
      serverHostName: wifiProxyMenuKeyAndVal.get(WIFI_PROXY_HOSTNAME_LABEL) as string ?? undefined,
      serverPort: Number.parseInt(wifiProxyMenuKeyAndVal.get(WIFI_PROXY_PORT_LABEL) as string) ?? undefined,
      exclusionObjects: wifiProxyMenuKeyAndVal.get(WIFI_PROXY_EXCLUSIONLIST_LABEL) as string ?? undefined,
    };
  }

  /**
   * init wifi ip config key and value map
   *
   * @param ipConfig ip info
   * @param ipType ip type
   * @returns menu key and value map
   */
  private static initWifiIpMenuKeyAndValMap(ipConfig?: wifiManager.IpConfig, ipType?: wifiManager.IpType):
    Map<string, MenuValueType> {
    LogUtil.info(`${TAG} initWifiIpMenuKeyAndValMap.`);
    let result: Map<string, MenuValueType> = new Map();
    result.set(WIFI_IP_SETTINGS, ipType ?? wifiManager.IpType.DHCP);
    result.set(WIFI_IP_ADDRESS, ipConfig?.ipAddress ?? '');
    result.set(WIFI_IP_GATEWAY, ipConfig?.gateway ?? '');
    result.set(WIFI_IP_PREFIX_LENGTH, ipConfig?.prefixLength ?? '');
    result.set(WIFI_IP_DNS_SERVERS_1, ipConfig?.dnsServers[0] ?? '');
    result.set(WIFI_IP_DNS_SERVERS_2, ipConfig?.dnsServers[1] ?? '');

    return result;
  }

  /**
   * config wifi ip info
   *
   * @param wifiIpMenuKeyAndVal wifi ip menus key and value map
   * @returns result
   */
  static getWifiIpConfigInfo(wifiIpMenuKeyAndVal: Map<string, MenuValueType>): wifiManager.IpConfig {
    let array: number[] = [];
    if (wifiIpMenuKeyAndVal.get(WIFI_IP_DNS_SERVERS_1)) {
      array[0] = WifiBaseConfigManager.convertIpString2Number(wifiIpMenuKeyAndVal.get(WIFI_IP_DNS_SERVERS_1));
    }

    if (wifiIpMenuKeyAndVal.get(WIFI_IP_DNS_SERVERS_2)) {
      array[1] = WifiBaseConfigManager.convertIpString2Number(wifiIpMenuKeyAndVal.get(WIFI_IP_DNS_SERVERS_2));
    }
    return {
      ipAddress: WifiBaseConfigManager.convertIpString2Number(wifiIpMenuKeyAndVal.get(WIFI_IP_ADDRESS)),
      gateway: WifiBaseConfigManager.convertIpString2Number(wifiIpMenuKeyAndVal.get(WIFI_IP_GATEWAY)),
      prefixLength: WifiBaseConfigManager.convertString2Number(wifiIpMenuKeyAndVal.get(WIFI_IP_PREFIX_LENGTH)),
      dnsServers: array,
      domains: [],
    };
  }

  /**
   * convert wifi ip string to number
   *
   * @param value before convert
   * @returns value after convert
   */
  public static convertIpString2Number(value: MenuValueType): number {
    if (!value) {
      return Number.NaN;
    }

    let result: number | null = WifiUtils.ipString2Number(value.toString());
    return result === null ? Number.NaN : result;
  }

  /**
   * 转化ipv6地址
   *
   * @param value value before convert
   * @returns after convert
   */
  public static convertIpv6String(value: MenuValueType): string {
    if (!value) {
      return '';
    }
    return WifiUtils.validIpv6String((value.toString()));
  }

  /**
   * convert string to number
   *
   * @param value value before convert
   * @returns value after convert
   */
  public static convertString2Number(value: MenuValueType): number {
    if (!value) {
      return Number.NaN;
    }

    return Number.parseInt(value.toString());
  }

  /**
   * register related controllers data change monitoring
   *
   * @param menuKeys menu keys
   * @param controller controller for monitoring
   */
  private static registerMenuControllerDataChange(menuKeys: IterableIterator<string>, controller: MenuController):
    void {
    let menuKey: IteratorResult<string> = menuKeys.next();
    while (!menuKey.done) {
      controller.registerControllerDataChange(menuKey.value);
      menuKey = menuKeys.next();
    }
  }

  /**
   * unregister related controllers data change monitoring
   *
   * @param menuKeys  menu keys
   * @param controller unmonitored controller
   */
  private static unRegisterMenuControllerDataChange(menuKeys: IterableIterator<string>, controller: MenuController):
    void {
    let menuKey: IteratorResult<string> = menuKeys.next();
    while (!menuKey.done) {
      controller.unRegisterControllerDataChange(menuKey.value);
      menuKey = menuKeys.next();
    }
  }

  /**
   * init wifi config
   *
   * @returns wifi config
   */
  private static initAppConfig(): wifiManager.WifiDeviceConfig {
    LogUtil.info(`${TAG} initAppConfig`);
    return {
      ssid: '',
      preSharedKey: '',
      securityType: wifiManager.WifiSecurityType.WIFI_SEC_TYPE_INVALID,
    };
  }

  static getDisconnectedReasonMessage(reason: number): ResourceStr {
    switch (reason) {
      case WlanDisconnectedReason.WRONG_PWD:
        return $r('app.string.wifi_status_wrong_pwd');
      case WlanDisconnectedReason.FAILED_CONNECTION_FULL:
        return $r('app.string.wifi_status_failed_connection_full');
      case WlanDisconnectedReason.DISC_REASON_CONNECTION_REJECTED:
        return $r('app.string.wifi_status_failed_rejected');
      case WlanDisconnectedReason.DISC_REASON_DISABLED:
        return $r('app.string.wifi_status_failed_disabled');
      default:
        return $r('app.string.wifi_status_failed_default');
    }
  }

  /**
   * 连接失败信息
   *
   * @param reason 连接失败标识
   * @returns 失败信息字符串
   */
  static getDisconnectedMessage(reason: number): string {
    let wifiConfig: wifiManager.WifiDeviceConfig | undefined = AddOtherWlanConfigManager.getInstance().wifiConfig;
    const ssid: string = (wifiConfig?.ssid as string) ?? '';
    switch (reason) {
      case WlanDisconnectedReason.WRONG_PWD:
        return ResourceUtil.getStringSync($r('app.string.wifi_status_wrong_pwd'));
      case WlanDisconnectedReason.FAILED_CONNECTION_FULL:
        return ResourceUtil.getStringSync($r('app.string.wifi_status_failed_connection_full'));
      case WlanDisconnectedReason.DISC_REASON_CONNECTION_REJECTED:
        return ResourceUtil.getStringSync($r('app.string.wifi_status_failed_rejected'));
      case WlanDisconnectedReason.DISC_REASON_DISABLED:
        return ResourceUtil.getStringSync($r('app.string.wifi_status_failed_disabled'));
      default:
        return ResourceUtil.getFormatStringSync($r('app.string.wifi_ssid_error'), ssid);
    }
  }
}
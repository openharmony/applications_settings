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

import { LogUtil } from '@ohos/settings.common/src/main/ets/utils/LogUtil';
import wifiManager from '@ohos.wifiManager';
import { BaseEntryMenu, BaseEntryMenuData } from '@ohos/settings.common/src/main/ets/core/model/menu/BaseMenu';
import { WifiUtils, IPV6_FAMILY_FLAG, IPV4_FAMILY_FLAG } from '../WifiUtils';
import { WifiManager } from '../WifiManager';

/* instrument ignore file */
const UNREACHABLE_RSSI = -Number.MIN_VALUE;

const TAG: string = 'WifiSettings : ';

const WPA2_PSK: string = 'WPA2-PSK';

const firstRssiLevel2G: number = -88;
const secondRssiLevel2G: number = -82;
const thirdRssiLevel2G: number = -75;
const fourthRssiLevel2G: number = -65;
const firstRssiLevel5G: number = -85;
const secondRssiLevel5G: number = -79;
const thirdRssiLevel5G: number = -72;
const fourthRssiLevel5G: number = -65;

enum BandType {
  BAND_NONE = 0, /* unknown */
  BAND_2GHZ = 1, /* 2.4GHz */
  BAND_5GHZ = 2, /* 5GHz */
  BAND_6GHZ = 3, /* 6GHz */
  BAND_60GHZ = 4, /* 60GHz */
  BAND_ANY = 5, /* Dual-mode frequency band */
};

const AP_STATES: ResourceStr[] = [
  $r('app.string.wifi_status_scanning'),
  $r('app.string.wifi_status_connecting'),
  $r('app.string.wifi_status_authenticating'),
  $r('app.string.wifi_status_obtaining_iP'),
  $r('app.string.wifi_status_connected'),
  $r('app.string.wifi_status_disconnecting'),
  $r('app.string.wifi_status_disconnected'),
  $r('app.string.wifi_status_unsuccessful')];

export class WifiWorkerResponseData {
  public menus: ApMenu[] = [];
  public lastLinkedInfo: wifiManager.WifiLinkedInfo | undefined;
  public scanResultCache: Map<string, WifiScanResult> = new Map<string, WifiScanResult>();
  public updateApCache: Map<string, AccessPoint> = new Map<string, AccessPoint>();
}

/**
 * AP扫描结果类，后期应使用wifi的类
 *
 * @since 2022-03-21
 */
export class WifiScanResult {
  constructor(param?: wifiManager.WifiScanInfo) {
    if (!param) {
      return;
    }
    this.ssid = param.ssid as string;
    this.bssid = param.bssid as string;
    this.bssidType = param.bssidType as number;
    this.capabilities = param.capabilities as string;
    this.securityType = param.securityType as WifiSecurityType;
    this.rssi = param.rssi as number;
    this.band = param.band as number;
    this.frequency = param.frequency as number;
    this.channelWidth = param.channelWidth as number;
    this.timestamp = param.timestamp as number;
    this.supportedWifiCategory = param.supportedWifiCategory as number;
    this.isHiLinkNetwork = param.isHiLinkNetwork as boolean;
    this.isHiLinkProNetwork = param.isHiLinkProNetwork as boolean;
  }

  /** Wi-Fi SSID: the maximum length is 32 */
  public ssid: string = '';
  /** Wi-Fi bssid(MAC): the length is 6 */
  public bssid: string = '';
  /** Wi-Fi device address( mac / bssid ) type */
  public bssidType: number = 0;
  /** Hotspot capability */
  public capabilities: string = '';
  /** Security type: reference definition of WifiSecurityType */
  public securityType: WifiSecurityType = WifiSecurityType.WIFI_SEC_TYPE_INVALID;
  /** Received signal strength indicator (RSSI) */
  public rssi: number = 0;
  /** Frequency band, 1: 2.4G, 2: 5G */
  public band: number | null = null;
  /** Frequency */
  public frequency: number = 0;
  /** Channel width */
  public channelWidth: number = 0;
  /** Time stamp */
  public timestamp: number = 0;

  /**
   * Supported wifi category
   */
  public supportedWifiCategory: number = 0;

  /**
   * Whether this Wi-Fi support hilink.
   */
  public isHiLinkNetwork: boolean = false;

  /**
   * Whether this Wi-Fi support lxlink.
   */
  public isHiLinkProNetwork: boolean = false;
}

/**
 * AP的加密类型，后期应使用wifi的类
 *
 * @since 2022-03-21
 */
export enum WifiSecurityType {
  WIFI_SEC_TYPE_INVALID = 0, /* Invalid security type */
  WIFI_SEC_TYPE_OPEN = 1, /* Open */
  WIFI_SEC_TYPE_WEP = 2, /* Wired Equivalent Privacy (WEP) */
  WIFI_SEC_TYPE_PSK = 3, /* Pre-shared key (PSK) */
  WIFI_SEC_TYPE_SAE = 4, /* Simultaneous Authentication of Equals (SAE) */
  WIFI_SEC_TYPE_EAP = 5, /* Simultaneous Authentication of Equals (SAE) */
  WIFI_SEC_TYPE_EAP_SUITE_B = 6, /* Simultaneous Authentication of Equals (SAE) */
  WIFI_SEC_TYPE_OWE = 7, /* Simultaneous Authentication of Equals (SAE) */
  WIFI_SEC_TYPE_WAPI_CERT = 8, /* Simultaneous Authentication of Equals (SAE) */
  WIFI_SEC_TYPE_WAPI_PSK = 9, /* Simultaneous Authentication of Equals (SAE) */
}

/**
 * Wifi监听onWifiConnectionChange的状态
 *
 * @since 2024-04-28
 */
export enum WifiConnectionState {
  DISCONNECTED = 0,
  CONNECTED = 1,
  HILINK = 2,
}

/**
 * Wifi的状态
 *
 * @since 2022-03-21
 */
export enum WifiState {
  UNKNOWN = -1,
  INACTIVE = 0,
  ACTIVE = 1,
  ACTIVATING = 2,
  DEACTIVATING = 3,
  SEMIACTIVATING = 4,
  SEMIACTIVE = 5
}

/**
 * Wifi分类，后期应使用wifi的类
 */
export enum WifiCategory {
  WIFI_CATEGORY_DEFAULT = 1,

  WIFI_CATEGORY_WIFI6 = 2,

  WIFI_CATEGORY_WIFI6_PLUS = 3,

  WIFI_CATEGORY_WIFI7 = 4,

  WIFI_CATEGORY_WIFI7_PLUS = 5,
}

/**
 * 当前连接过程状态，后期应使用wifi的类
 *
 * @since 2022-03-21
 */
export enum SuppState {
  /** The supplicant is not associated with or is disconnected from the AP. */
  DISCONNECTED,

  /** The network interface is disabled. */
  INTERFACE_DISABLED,

  /** The supplicant is disabled. */
  INACTIVE,

  /** The supplicant is scanning for a Wi-Fi connection. */
  SCANNING,

  /** The supplicant is authenticating with a specified AP. */
  AUTHENTICATING,

  /** The supplicant is associating with a specified AP. */
  ASSOCIATING,

  /** The supplicant is associated with a specified AP. */
  ASSOCIATED,

  /** The four-way handshake is ongoing. */
  FOUR_WAY_HANDSHAKE,

  /** The group handshake is ongoing. */
  GROUP_HANDSHAKE,

  /** All authentication is completed. */
  COMPLETED,

  /** Failed to establish a connection to the supplicant. */
  UNINITIALIZED,

  /** The supplicant is in an unknown or invalid state. */
  INVALID
}

/**
 * 连接状态，后期应使用wifi的类
 *
 * @since 2022-03-21
 */
export enum ConnState {
  /** The device is searching for an available AP. */
  SCANNING,

  /** The Wi-Fi connection is being set up. */
  CONNECTING,

  /** The Wi-Fi connection is being authenticated. */
  AUTHENTICATING,

  /** The IP address of the Wi-Fi connection is being obtained. */
  OBTAINING_IPADDR,

  /** The Wi-Fi connection has been set up. */
  CONNECTED,

  /** The Wi-Fi connection is being torn down. */
  DISCONNECTING,

  /** The Wi-Fi connection has been torn down. */
  DISCONNECTED,

  /** Failed to set up the Wi-Fi connection. */
  UNKNOWN
}

/**
 * 连接详情类，后期应使用wifi的类
 *
 * @since 2022-03-21
 */
export class WifiLinkedInfo {
  /** The SSID of the Wi-Fi hotspot */
  public ssid: string = '';
  /** The BSSID of the Wi-Fi hotspot */
  public bssid: string = '';
  /** The ID(uniquely identifies) of a Wi-Fi connection. */
  public networkId: number = 0;
  /** The RSSI(dBm) of a Wi-Fi access point. */
  public rssi: number = 0;
  /** The frequency band of a Wi-Fi access point. */
  public band: number = 0;
  /** The speed of a Wi-Fi access point. */
  public linkSpeed: number = 0;
  /** The frequency of a Wi-Fi access point. */
  public frequency: number = 0;
  /** Whether the SSID of the access point (AP) of this Wi-Fi connection is hidden. */
  public isHidden: boolean = false;
  /** Whether this Wi-Fi connection restricts the data volume. */
  public isRestricted: boolean = false;
  /** The load value of this Wi-Fi connection. A greater value indicates a higher load. */
  public chload: number = 0;
  /** The signal-to-noise ratio (SNR) of this Wi-Fi connection. */
  public snr: number = 0;
  /** The Wi-Fi MAC address of a device. */
  public macAddress: string = '';
  /** The IP address of this Wi-Fi connection. */
  public ipAddress: number = 0;
  /** The state of the supplicant of this Wi-Fi connection. */
  public suppState: SuppState | null = null;
  /** The state of this Wi-Fi connection. */
  public connState: ConnState | null = null;
}

/**
 * Wifi的IP类型，后期应使用wifi的类
 *
 * @since 2022-11-17
 */
export enum IpType {
  /** Use statically configured IP settings */
  STATIC,

  /** Use dynamically configured IP settings */
  DHCP,

  /** No IP details are assigned */
  UNKNOWN,
}

export enum WlanDisconnectedReason {
  FAILED_DEFAULT = 0,
  WRONG_PWD = 1,
  FAILED_CONNECTION_FULL = 2,
  DISC_REASON_CONNECTION_REJECTED = 3,
  DISC_REASON_IGNORE = 4,
  DISC_REASON_DISABLED = 5,
}

export enum WifiWindowSettingsMode {
  DEFAULT = 0,
  SCREEN_LOCK = 1,
}

export interface ApMenuData extends BaseEntryMenuData {
  ssid: string;
  bssid: string;
  bssidType: number;
  level: number;
  securityType: number;
  config: wifiManager.WifiDeviceConfig;
  supportedWifiCategory: number;
  isHiLinkNetwork: boolean;
  isHiLinkProNetwork: boolean;
  scanResults: WifiScanResult[];
}

export interface ApMenuConfigData {
  ssid: string;
  capabilities: string;
  securityType: number;
  config: wifiManager.WifiDeviceConfig;
  connState: number | undefined;
}

/**
 * WiFi连接-设置IP中转数据
 *
 * @since 2025-04-27
 */
export class PendingIpConfig {
  public tag: string = 'PendingIpConfig : ';
  public ipType: wifiManager.IpType;
  public ipAddress: number;
  public gateway: number;
  public prefixLength: number;
  public dnsServers: number[];
  public domains: Array<string>;
  public modified: boolean = false;
  public connState: number | undefined;
  public ipv6Address: string;
  public ipv6Gateway: string;
  public ipv6PrefixLength: number;
  public ipv6DnsServers: Array<string>;
  public ipv6Domains: Array<string>;
  public family: number = 0;

  constructor(ipType: wifiManager.IpType, ipConfig: wifiManager.IpConfig, ipv6Config: wifiManager.Ipv6Config) {
    this.ipType = ipType;
    this.ipAddress = ipConfig?.ipAddress;
    this.gateway = ipConfig?.gateway;
    this.prefixLength = ipConfig?.prefixLength;
    this.dnsServers = ipConfig?.dnsServers;
    this.domains = ipConfig?.domains;
    this.prefixLength = ipConfig?.prefixLength;
    this.ipv6Address = ipv6Config?.ipAddress;
    this.ipv6Gateway = ipv6Config?.gateway;
    this.ipv6PrefixLength = ipv6Config?.prefixLength;
    this.ipv6DnsServers = ipv6Config?.dnsServers;
    this.ipv6Domains = ipv6Config?.domains
  }

  /**
   * 获取ip4信息
   *
   * @returns ipConfig
   */
  public getIpConfig(): wifiManager.IpConfig {
    let ipConfig: wifiManager.IpConfig = {
      ipAddress: this.ipAddress,
      gateway: this.gateway,
      prefixLength: this.prefixLength,
      dnsServers: this.dnsServers,
      domains: this.domains,
    }
    return ipConfig;
  }

  /**
   * 获取ipv6配置信息
   *
   * @returns ipv6Config
   */
  public getIpv6Config(): wifiManager.Ipv6Config {
    let ipv6Config: wifiManager.Ipv6Config = {
      ipAddress: this.ipv6Address,
      gateway: this.ipv6Gateway,
      prefixLength: this.ipv6PrefixLength,
      dnsServers: this.ipv6DnsServers,
      domains: this.ipv6Domains,
    }
    return ipv6Config;
  }

  copyData(wifiConfig: wifiManager.WifiDeviceConfig) {
    wifiConfig.ipType = this.ipType;
    if (wifiConfig.ipType === wifiManager.IpType.STATIC) {
      if (this.family === IPV4_FAMILY_FLAG) {
        wifiConfig.staticIp = {
          ipAddress: this.ipAddress,
          gateway: this.gateway,
          prefixLength: this.prefixLength,
          dnsServers: this.dnsServers,
          domains: this.domains,
        }
        wifiConfig.staticIpv6 = undefined;
      }
      if (this.family === IPV6_FAMILY_FLAG) {
        wifiConfig.staticIpv6 = {
          ipAddress: this.ipv6Address,
          gateway: this.ipv6Gateway,
          prefixLength: this.ipv6PrefixLength,
          dnsServers: this.ipv6DnsServers,
          domains: this.ipv6Domains,
        }
        wifiConfig.staticIp = undefined;
      }
      wifiConfig.family = this.family;
    } else {
      wifiConfig.staticIp = undefined;
      wifiConfig.staticIpv6 = undefined;
    }
  }
}

/**
 * Ap菜单数据
 *
 * @since 2022-03-21
 */
export class ApMenu extends BaseEntryMenu implements ApMenuData {
  public ssid: string;
  public bssid: string;
  public bssidType: number;
  public level: number;
  public securityType: number;
  public config: wifiManager.WifiDeviceConfig;
  public supportedWifiCategory: number;
  public isHiLinkNetwork: boolean;
  public isHiLinkProNetwork:boolean;
  public scanResults: WifiScanResult[];

  constructor(menu: Partial<ApMenuData>) {
    super(menu);
    this.ssid = menu.ssid as string;
    this.bssid = menu.bssid as string;
    this.bssidType = menu.bssidType as number;
    this.level = menu.level as number;
    this.scanResults = menu.scanResults as WifiScanResult[];
    this.config = menu.config as wifiManager.WifiDeviceConfig;
    this.securityType = menu.securityType as number;
    this.capabilities = menu.capabilities as string;
    this.supportedWifiCategory = menu.supportedWifiCategory as number;
    this.isHiLinkNetwork = menu.isHiLinkNetwork as boolean;
    this.isHiLinkProNetwork = menu.isHiLinkProNetwork as boolean;
    this.isNeedShowIcon = this.isHiLinkNetwork as boolean;
  }

  update(item: Partial<ApMenuData>): boolean {
    if (!item) {
      return false;
    }

    let isChange: boolean = false;
    this.index = item.index as number;
    this.ssid = item.ssid as string;
    this.bssid = item.bssid as string;
    this.bssidType = item.bssidType as number;
    this.securityType = item.securityType as number;
    this.capabilities = item.capabilities as string;
    this.supportedWifiCategory = item.supportedWifiCategory as number;
    this.isHiLinkNetwork = item.isHiLinkNetwork as boolean;
    this.isHiLinkProNetwork = item.isHiLinkProNetwork as boolean;
    this.isNeedShowIcon = this.isHiLinkNetwork as boolean;
    if (this.title !== item.title as ResourceStr) {
      this.title = item.title as ResourceStr;
      isChange = true;
    }
    if (this.summary !== item.summary as ResourceStr) {
      this.summary = item.summary as ResourceStr;
      isChange = true;
    }
    if (this.stateIcon !== item.stateIcon as ResourceStr) {
      this.stateIcon = item.stateIcon as ResourceStr;
      isChange = true;
    }

    if (this.level !== item.level as number) {
      this.level = item.level as number;
      isChange = true;
    }

    if (this.config !== item.config) {
      this.config = item.config as wifiManager.WifiDeviceConfig;
      isChange = true;
    }
    LogUtil.info(`${TAG} ApMenu update : ${WifiUtils.getLogSsidString(this.ssid)}, isChange : ${isChange}`);

    if (isChange) {
      this.refreshUi();
    }
    return isChange;
  }

  getLogKey(): string {
    return WifiUtils.getApLogKey(this.ssid, this.securityType);
  }
}

/**
 * 单个Ap数据类
 *
 * @since 2022-03-21
 */
export class AccessPoint {
  public apKey: string = '';
  public scanResults?: WifiScanResult[];
  public configs?: wifiManager.WifiDeviceConfig[] | null;
  public lastLinkedInfo?: wifiManager.WifiLinkedInfo | null;
  public lastMultiLinkedInfo?: Array<wifiManager.WifiLinkedInfo> | null;
  public bestRssi: number = UNREACHABLE_RSSI;
  public bestBand: number = 0;
  public ssid: string = '';
  public bestBssid: string = '';
  public bssidType: number = 0;
  public securityType: number = 0;
  public isAutoConnectAllowed: boolean = false;
  public bestLevel: number = 0;
  public lastIndex: number = 0;
  public lastTimestamp: number = 0;
  public supportedWifiCategory: number = 0;
  public isHiLinkNetwork: boolean = false;
  public isHiLinkProNetwork: boolean | undefined = false;
  public capabilities: string = '';
  private isUnsecuredWifi: boolean = false;

  constructor(newResult: WifiScanResult[] | null) {
    this.setScanResults(newResult);
    LogUtil.debug(`${TAG} new AccessPoint ${WifiUtils.getLogSsidString(this.ssid)}`);
  }

  isSameAp(ap: AccessPoint): boolean {
    if (!ap) {
      return false;
    }
    if (this.ssid !== ap.ssid) {
      return false;
    }
    if (this.securityType !== ap.securityType) {
      return false;
    }
    if (this.isAutoConnectAllowed !== ap.isAutoConnectAllowed) {
      return false;
    }
    if (this.getTitle() !== ap.getTitle()) {
      return false;
    }
    if (this.getSummary() !== ap.getSummary()) {
      return false;
    }
    if (this.getStateIcon() !== ap.getStateIcon()) {
      return false;
    }
    if (this.getFrequency() !== ap.getFrequency()) {
      return false;
    }
    if (this.getIpAddress() !== ap.getIpAddress()) {
      return false;
    }
    if (this.getSpeed() !== ap.getSpeed()) {
      return false;
    }
    return true;
  }

  setScanResults(newResult: WifiScanResult[] | null): void {
    if (!newResult || newResult.length === 0) {
      LogUtil.info(`${TAG} setScanResults newResult length: ${newResult?.length}`);
      return;
    }

    if (this.apKey) {
      for (let result of newResult) {
        if (!this.isScanResultMatches(result)) {
          LogUtil.info(`${TAG} ${WifiUtils.getLogSsidString(result?.ssid)} not match ${WifiUtils.getLogSsidString(this.ssid)}`);
          return;
        }
      }
    }

    this.scanResults = Array<WifiScanResult>().concat(newResult);

    this.updateFromNewScanResults();

    if (!this.apKey) {
      this.apKey = WifiUtils.getApKey(this.ssid, this.bestBssid, this.securityType) as string;
    }
  }

  setConfigs(newConfigs: Array<wifiManager.WifiDeviceConfig> | null): void {
    if (!newConfigs || newConfigs.length === 0) {
      this.configs = null;
      return;
    }

    if (this.apKey) {
      for (let config of Array.from(newConfigs as wifiManager.WifiDeviceConfig[])) {
        if (!this.isConfigMatches(config)) {
          LogUtil.info(`${TAG} config ${WifiUtils.getLogSsidString(config?.ssid)}
          not match ${WifiUtils.getLogSsidString(this.ssid)}`);
          return;
        }
      }
    }

    this.configs = Array<wifiManager.WifiDeviceConfig>().concat(newConfigs as Array<wifiManager.WifiDeviceConfig>);
    this.updateFromNewConfigs();
  }

  isScanResultMatches(result: WifiScanResult): boolean {
    if (!result) {
      return false;
    }

    if (this.ssid !== result.ssid || this.securityType !== result.securityType) {
      return false;
    }

    return true;
  }

  isConfigMatches(config: wifiManager.WifiDeviceConfig): boolean {
    if (!config) {
      return false;
    }

    if (!this.apKey) {
      return true;
    }

    if (this.ssid === config.ssid) {
      if (this.securityType === config.securityType) {
        return true;
      }
      if (config.securityType === WifiSecurityType.WIFI_SEC_TYPE_PSK &&
        this.securityType === WifiSecurityType.WIFI_SEC_TYPE_SAE &&
        this.capabilities.includes(WPA2_PSK)) {
        LogUtil.info(`${TAG} use bssid and securityType and capability to connect ap with config, ssid: ${WifiUtils.getLogSsidString(this.ssid)}`);
        return true;
      }
    }
    return false;
  }

  private getSignalLevel(rssi: number, band: number): number {
    let level: number = 0;
    do {
      if (band === BandType.BAND_2GHZ) {
        if (rssi < firstRssiLevel2G) {
          break;
        }
        ++level;
        if (rssi < secondRssiLevel2G) {
          break;
        }
        ++level;
        if (rssi < thirdRssiLevel2G) {
          break;
        }
        ++level;
        if (rssi < fourthRssiLevel2G) {
          break;
        }
        ++level;
      } else if (band === BandType.BAND_5GHZ) {
        if (rssi < firstRssiLevel5G) {
          break;
        }
        ++level;
        if (rssi < secondRssiLevel5G) {
          break;
        }
        ++level;
        if (rssi < thirdRssiLevel5G) {
          break;
        }
        ++level;
        if (rssi < fourthRssiLevel5G) {
          break;
        }
        ++level;
      } else {
        ++level;
      }
    } while (0);
    return level;
  }

  private updateFromNewScanResults(): void {
    let wifiCategory: number = WifiCategory.WIFI_CATEGORY_DEFAULT;
    if (!this.scanResults || this.scanResults.length === 0) {
      return;
    }

    let bestResult: WifiScanResult = this.scanResults[0];
    for (let result of this.scanResults) {
      if (result.rssi > bestResult.rssi) {
        bestResult = result;
      }
      if (result.supportedWifiCategory > wifiCategory) {
        wifiCategory = result.supportedWifiCategory;
      }
    }

    let bestRssi: number = bestResult.rssi;
    if (bestRssi !== UNREACHABLE_RSSI && this.bestRssi !== UNREACHABLE_RSSI) {
      bestRssi = Math.round((this.bestRssi + bestRssi) / 2);
    }

    this.bestRssi = bestRssi;
    this.bestBand = bestResult.band as number;
    this.ssid = bestResult.ssid;
    this.bestBssid = bestResult.bssid;
    this.bssidType = bestResult.bssidType;
    this.securityType = bestResult.securityType as WifiSecurityType;
    this.capabilities = bestResult.capabilities;
    // 5.0 落需求整改，目前本地计算wifi signal level -- 性能考量。
    let newLevel: number = this.getSignalLevel(this.bestRssi, this.bestBand);
    this.bestLevel = newLevel;
    this.supportedWifiCategory = wifiCategory;
    this.isHiLinkNetwork = bestResult.isHiLinkNetwork as boolean;
    this.isHiLinkProNetwork = bestResult.isHiLinkProNetwork as boolean;
  }

  private updateFromNewConfigs(): void {
    if (!this.configs || this.configs.length === 0 || !this.configs[0]) {
      LogUtil.error(`${TAG} updateFromNewConfigs failed.`);
      return;
    }
    if (!this.securityType) {
      this.securityType = this.configs[0].securityType;
      LogUtil.info(`${TAG} updateFromNewConfigs securityType: ${this.securityType}`);
    }
    this.isUnsecuredWifi =
      this.configs[0].isSecureWifi === false && WifiManager.getInstance().getWifiSecuritySwitchStatus();
    LogUtil.info(`${TAG} updateFromNewConfigs isSecureWifi: ${this.configs[0].isSecureWifi} isUnsecuredWifi:${this.isUnsecuredWifi}`);
    this.isAutoConnectAllowed =
      this.configs[0].isAutoConnectAllowed === undefined ? true : this.configs[0].isAutoConnectAllowed;
    LogUtil.info(`${TAG} updateFromNewConfigs isAutoConnectAllowed: ${this.configs[0].isAutoConnectAllowed}`);
    if (!this.ssid) {
      this.ssid = this.configs[0].ssid;
      LogUtil.info(`${TAG} updateFromNewConfigs ssid: ${WifiUtils.getLogSsidString(this.ssid)}`);
    }

    if (!this.bestBssid) {
      this.bestBssid = this.configs[0].bssid as string;
    }

    if (!this.bssidType) {
      this.bssidType = this.configs[0].bssidType as number;
    }

    if (!this.apKey) {
      this.apKey = WifiUtils.getApKey(this.ssid, this.bestBssid, this.securityType) as string;
    }
  }

  updateLastLinkedInfo(linkedInfo: wifiManager.WifiLinkedInfo): void {
    if (linkedInfo && this.isLinkedInfoForMe(linkedInfo)) {
      this.lastLinkedInfo = linkedInfo;
    } else {
      this.lastLinkedInfo = null;
      return;
    }
    if (this.scanResults && this.scanResults.length > 0) {
      LogUtil.info(`${TAG} updateLastLinkedInfo scanResults length: ${this.scanResults.length}`);
      return;
    }

    LogUtil.info(`${TAG} updateLastLinkedInfo, last bestRssi: ${this.bestRssi}, rssi: ${this.lastLinkedInfo.rssi}, linkSpeed: ${this.lastLinkedInfo?.linkSpeed}`);
    this.bestRssi = this.lastLinkedInfo.rssi;
    this.bestBand = this.lastLinkedInfo.band;
    this.ssid = this.lastLinkedInfo.ssid;
    this.bestBssid = this.lastLinkedInfo.bssid;
    this.isHiLinkProNetwork = this.lastLinkedInfo?.isHiLinkProNetwork;
    LogUtil.info(`${TAG} updateLastLinkedInfo, bestLevel: ${this.bestLevel} supportedWifiCategory: ${this.supportedWifiCategory},isHiLinkProNetwork:${this.lastLinkedInfo?.isHiLinkProNetwork}`);
    try {
      let newLevel: number = wifiManager.getSignalLevel(this.bestRssi, this.bestBand);
      LogUtil.info(`${TAG} updateLastLinkedInfo, getSignalLevel: ${newLevel}`);
      this.bestLevel = newLevel;

      if (!this.apKey) {
        this.apKey = WifiUtils.getApKey(this.ssid, this.bestBssid, this.securityType) as string;
      }
    } catch (error) {
      LogUtil.error(`${TAG} get signal level failed: ${error?.message}`);
    }
  }

  updateMultiLinkedInfo(multiLinkedInfo: Array<wifiManager.WifiLinkedInfo>): void {
    this.lastMultiLinkedInfo = multiLinkedInfo;
  }

  isLinkedInfoForMe(linkedInfo: wifiManager.WifiLinkedInfo): boolean {
    if (this.configs) {
      for (let config of this.configs) {
        if (config.netId === linkedInfo.networkId) {
          return true;
        }
      }
    } else {
      if ((!this.scanResults || this.scanResults.length <= 0) && !this.ssid) {
        return true;
      }
    }
    if (this.scanResults) {
      for (let scanResult of this.scanResults) {
        if (scanResult.bssid === linkedInfo.bssid && scanResult.ssid === linkedInfo.ssid) {
          LogUtil.info(`${TAG} net id invalid, bssid is ${WifiUtils.getLogMAC(linkedInfo.bssid)} and ssid is ${WifiUtils.getLogSsidString(linkedInfo.ssid)}`);
          return true;
        }
      }
    }
    return false;
  }

  isActive(): boolean {
    // 暂时规避，后期需要改为wifiManager.ConnState.DISCONNECTED
    return this.lastLinkedInfo !== null &&
      (WifiUtils.isValidNetworkId(this.lastLinkedInfo?.networkId as number) ||
        this.lastLinkedInfo?.connState !== 6);
  }

  isConnected(): boolean {
    // 暂时规避，后期需要改为wifiManager.ConnState.CONNECTED
    return this.isActive() && (this.lastLinkedInfo?.connState === 4);
  }

  isHidden(): boolean {
    if (this.lastLinkedInfo !== null && this.lastLinkedInfo) {
      return this.lastLinkedInfo.isHidden;
    }

    if (this.configs && this.configs.length > 0) {
      for (let config of this.configs) {
        if (!config.isHiddenSsid) {
          return false;
        }
      }
      return true;
    }
    return false;
  }

  isReachable(): boolean {
    return this.bestRssi !== UNREACHABLE_RSSI;
  }

  isValid(): boolean {
    return this.securityType !== WifiSecurityType.WIFI_SEC_TYPE_INVALID;
  }

  isSaved(): boolean {
    if (this.configs) {
      return this.configs && this.configs.length > 0;
    }
    return false;
  }

  getTitle(): string {
    return this.ssid ?? '';
  }

  isOpen(): boolean {
    return this.securityType === WifiSecurityType.WIFI_SEC_TYPE_OPEN;
  }

  isOpenAutoConnect(): boolean {
    LogUtil.info(`${TAG} isAutoConnectAllowed-${this.isAutoConnectAllowed}`)
    return this.isAutoConnectAllowed;
  }

  isUnsecuredWifiDetect(): boolean {
    return this.isUnsecuredWifi;
  }

  getSummary(): ResourceStr {
    if (this.isActive() && this.lastLinkedInfo && this.lastLinkedInfo.ssid) {
      if (this.lastLinkedInfo.connState >= 0 && this.lastLinkedInfo.connState < AP_STATES.length) {
        return AP_STATES[this.lastLinkedInfo.connState];
      }
    }
    if (this.isUnsecuredWifi && this.isSaved()) {
      return this.isOpenAutoConnect() ?
        (this.isOpen() ? $r('app.string.unsecure_wifi_status_saved') :
        $r('app.string.unsecure_wifi_status_saved_encrypted')) :
      $r('app.string.unsecure_is_close_auto_reconnect');
    }
    if (this.isSaved()) {
      return this.isOpenAutoConnect() ?
        (this.isOpen() ? $r('app.string.wifi_status_saved') : $r('app.string.wifi_status_saved_encrypted')) :
      $r('app.string.is_close_auto_reconnect');
    } else {
      return this.isOpen() ? $r('app.string.wifi_status_security_open') : $r('app.string.wifi_status_encrypted');
    }
  }

  getStateIcon(): ResourceStr | undefined {
    return WifiUtils.getStateIcon(this);
  }

  getBestConfig(): wifiManager.WifiDeviceConfig | undefined {
    if (!this.configs || this.configs.length === 0) {
      return undefined;
    }
    for (let config of this.configs) {
      if (this.bestBssid === config.bssid) {
        return config;
      }
    }
    return this.configs[0];
  }

  getFrequency(): number {
    return this.lastLinkedInfo?.frequency ?? 0;
  }

  getIpAddress(): number {
    return this.lastLinkedInfo?.ipAddress ?? 0;
  }

  getSpeed(): number {
    return this.lastLinkedInfo?.linkSpeed ?? 0;
  }

  getMacAddress(): string {
    return this.lastLinkedInfo?.macAddress ?? '';
  }

  toString(): string {
    return `ssid: ${WifiUtils.getLogSsidString(this.ssid)}, bestLevel: ${this.bestLevel}, bestRssi: ${this.bestRssi}, securityType: ${this.securityType}, isActive: ${this.isActive()}, isReachable: ${this.isReachable()}, isSaved: ${this.isSaved()}, supportedWifiCategory: ${this.supportedWifiCategory}, isHiLinkNetwork: ${this.isHiLinkNetwork},isHiLinkProNetwork: ${this.isHiLinkProNetwork}`;
  }

  static compare(ap1: AccessPoint, ap2: AccessPoint): number {
    if (ap1.isActive() && !ap2.isActive()) {
      return -1;
    }
    if (!ap1.isActive() && ap2.isActive()) {
      return 1;
    }

    if (ap1.isReachable() && !ap2.isReachable()) {
      return -1;
    }
    if (!ap1.isReachable() && ap2.isReachable()) {
      return 1;
    }

    if (ap1.isSaved() && !ap2.isSaved()) {
      return -1;
    }
    if (!ap1.isSaved() && ap2.isSaved()) {
      return 1;
    }

    let levelDiff: number = ap2.bestLevel - ap1.bestLevel;
    if (levelDiff !== 0) {
      return levelDiff;
    }

    let rssiDiff: number = ap2.bestRssi - ap1.bestRssi;
    if (rssiDiff !== 0) {
      return rssiDiff;
    }

    let securityTypeDiff: number = ap2.securityType - ap1.securityType;
    if (securityTypeDiff !== 0) {
      return securityTypeDiff;
    }

    return ap1.getTitle().localeCompare(ap2.getTitle());
  }
}

export const WLAN_SWITCH_ID: string = 'Setting.Wlan.WlanConfig.WlanSwitch.toggle';

export const OPEN_NET_WORK_SHEET_ID: string = 'OpenNetWorkSetting.Wlan.EditSheetConfig.EditSheet';

export const WLAN_SWITCH_GROUP_ID: string = 'Setting.Wlan.WlanConfig.WlanSwitch';

export const RANDOM_MAC_TYPE_CHANGED_EVENT: string = 'RANDOM_MAC_TYPE_CHANGED';

export const ADD_OTHER_WLAN_PASSWORD_ID: string = 'add_other_wlan_wifi_password_input';

export const SECURITY_CHANGE_EVENT: string = 'SECURITY_CHANGE';

export const WLAN_CONFIG_INPUT_CHANGE_EVENT: string = 'WLAN_CONFIG_INPUT_CHANGE';

export const WLAN_PSW_ENTER_EVENT: string = 'WLAN_PSW_ENTER_EVENT';

export const OTHER_WLAN_CONNECT_EVENT: string = 'OTHER_WLAN_CONNECT';

export const AVAILABLE_WLAN_DETAIL_CHANGE_EVENT: string = 'AVAILABLE_WLAN_DETAIL_CHANGE';

export const EAP_METHOD_CHANGED_EVENT: string = 'EAP_METHOD_CHANGED';

export const WLAN_IP_INPUT_CHANGE_EVENT: string = 'WLAN_IP_INPUT_CHANGE';

export const WLAN_PROXY_INPUT_CHANGE_EVENT: string = 'WLAN_PROXY_INPUT_CHANGE';

export const EAP_CA_CERTIFICATE_CHANGED_EVENT: string = 'EAP_CA_CERTIFICATE_CHANGED';

export const OTHER_WLAN_SHEET_SHOW_EVENT: string = 'OTHER_WLAN_SHEET_SHOW';

export const KEYBOARD_VISIBLE_EVENT:string = 'KEYBOARD_VISIBLE_EVENT';

export const CONNECT_RESULT_EVENT: string = 'CONNECT_RESULT_EVENT';

export const CONNECTED_DATA_CHANGE_EVENT: string = 'CONNECTED_DATA_CHANGE_EVENT';

export const WIFI_WINDOW_SETTINGS_MODE_KEY: string = 'wifiWindowSettingsMode';
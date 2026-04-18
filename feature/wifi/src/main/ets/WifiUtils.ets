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

import promptAction from '@ohos.promptAction';
import { commonEventManager } from '@kit.BasicServicesKit';
import wifiManager from '@ohos.wifiManager';
import certManager from '@ohos.security.certManager';
import connection from '@ohos.net.connection';
import enterpriseWifiManager from '@ohos.enterprise.wifiManager';
import systemParameterEnhance from '@ohos.systemParameterEnhance';
import { BusinessError, Callback } from '@ohos.base';
import { LogUtil } from '@ohos/settings.common/src/main/ets/utils/LogUtil';
import { CheckEmptyUtils } from '@ohos/settings.common/src/main/ets/utils/CheckEmptyUtils';
import { HiSysEventUtil } from '@ohos/settings.common/src/main/ets/systemEvent/HiSysEventUtil';
import {
  HiSysAboutBluetoothEventGroup,
  HiSysWlanEvenGroup
} from '@ohos/settings.common/src/main/ets/systemEvent/BehaviorEventConsts';
import lazy { ResourceUtil } from '@ohos/settings.common/src/main/ets/utils/ResourceUtil';
import lazy { CaCertificateType, WapiPskType, WifiMenuManager } from './WifiMenuManager';
import lazy {
  AccessPoint,
  ApMenu,
  ApMenuData,
  WifiCategory,
  WifiScanResult,
  WifiSecurityType,
  WifiState,
  WifiWindowSettingsMode,
  WIFI_WINDOW_SETTINGS_MODE_KEY,
  PendingIpConfig
} from './model/WifiModel';
import { WIFI7_EMLSR } from './WifiTracker';

/* instrument ignore file */
class FrequencyThreshold {
  public freqMin: number = 0;
  public freqMax: number = 0;
}

const TAG: string = 'WifiUtils : ';

const WIFI_SAE_MIN_PASSWORD_LEN: number = 1;
const WIFI_EAP_MIN_PASSWORD_LEN: number = 1;
const WIFI_SAE_MAX_PASSWORD_LEN: number = 64;
const WIFI_PSK_MIN_PASSWORD_LEN: number = 8;
const WIFI_HYBRID_SECURITY_MIN_PASSWORD_LEN: number = 1;
const WIFI_PSK_MAX_PASSWORD_LEN: number = 64;
const WIFI_PSK_WPA2_MAX_PASSWORD_LEN: number = 64;

const LOWER_FREQ_24GHZ: number = 2400;
const HIGHER_FREQ_24GHZ: number = 2500;
const LOWER_FREQ_5GHZ: number = 4900;
const HIGHER_FREQ_5GHZ: number = 5900;

const INVALID_NETWORK_ID: number = -1;
const WIFI_STATE_CONNECTED: number = 4;
const WIFI_STATE_DISCONNECTED: number = 6;
const MARGIN_RSSI: number = 3;
const AP_COMPARE_LOWER: number = -1;
const AP_COMPARE_HIGHER: number = 1;
const AP_COMPARE_NO_DIFF: number = 0;

const VALID_WEB_HEX_PWD_LENGTHS: number[] = [10, 26, 58];
const VALID_WEB_ASCII_PWD_LENGTHS: number[] = [5, 13];

const FULL_SIGNAL_LEVEL: number = 4;
const WIFI_SIX_FLAG_NUM: number = 6;
const WIFI_SEVEN_FLAG_NUM: number = 7;

const AP_SIGNAL_STRINGS: ResourceStr[] = [
  $r('app.string.wifi_signal_poor'),
  $r('app.string.wifi_signal_poor'),
  $r('app.string.wifi_signal_fair'),
  $r('app.string.wifi_signal_good'),
  $r('app.string.wifi_signal_excellent')];

const EAP_WAPI_ARRAY: wifiManager.WifiSecurityType[] = [
  wifiManager.WifiSecurityType.WIFI_SEC_TYPE_EAP,
  wifiManager.WifiSecurityType.WIFI_SEC_TYPE_EAP_SUITE_B,
  wifiManager.WifiSecurityType.WIFI_SEC_TYPE_WAPI_PSK,
  wifiManager.WifiSecurityType.WIFI_SEC_TYPE_WAPI_CERT];

const AP_SECURITY_STRINGS: ResourceStr[] = [
  '',
  $r('app.string.wifi_security_open'),
  $r('app.string.wifi_security_wep'),
  $r('app.string.wifi_security_psk'),
  $r('app.string.wifi_security_sae'),
  $r('app.string.wifi_security_eap'),
  $r('app.string.wifi_security_eap_suite_b'),
  $r('app.string.wifi_security_owe'),
  $r('app.string.wifi_security_wapi_cert'),
  $r('app.string.wifi_security_wapi_psk'),
];

const AP_STATES: ResourceStr[] = [
  $r('app.string.wifi_status_scanning'),
  $r('app.string.wifi_status_connecting'),
  $r('app.string.wifi_status_authenticating'),
  $r('app.string.wifi_status_obtaining_iP'),
  $r('app.string.wifi_status_connected'),
  $r('app.string.wifi_status_disconnecting'),
  $r('app.string.wifi_status_disconnected'),
  $r('app.string.wifi_status_unsuccessful')];

const AP_SIGNAL_LOCK_ICONS: ResourceStr[] = [
  $r('app.media.ic_wifi_lock_signal_0'),
  $r('app.media.ic_wifi_lock_signal_1'),
  $r('app.media.ic_wifi_lock_signal_2'),
  $r('app.media.ic_wifi_lock_signal_3'),
  $r('app.media.ic_wifi_lock_signal_4'),
];

const AP_SIGNAL_ICONS: ResourceStr[] = [
  $r('app.media.ic_wifi_signal_0'),
  $r('app.media.ic_wifi_signal_1'),
  $r('app.media.ic_wifi_signal_2'),
  $r('app.media.ic_wifi_signal_3'),
  $r('app.media.ic_wifi_signal_4'),
];


const AP_WIFI6_SIGNAL_ICONS: ResourceStr[] = [
  $r('app.media.ic_wifi6_signal_0'),
  $r('app.media.ic_wifi6_signal_1'),
  $r('app.media.ic_wifi6_signal_2'),
  $r('app.media.ic_wifi6_signal_3'),
  $r('app.media.ic_wifi6_signal_4'),
];

const AP_WIFI6_SIGNAL_LOCK_ICONS: ResourceStr[] = [
  $r('app.media.ic_wifi6_lock_signal_0'),
  $r('app.media.ic_wifi6_lock_signal_1'),
  $r('app.media.ic_wifi6_lock_signal_2'),
  $r('app.media.ic_wifi6_lock_signal_3'),
  $r('app.media.ic_wifi6_lock_signal_4'),
];

const AP_WIFI6_ERROR_SIGNAL_ICONS: ResourceStr[] = [
  $r('app.media.ic_wifi6_error_signal_0'),
  $r('app.media.ic_wifi6_error_signal_1'),
  $r('app.media.ic_wifi6_error_signal_2'),
  $r('app.media.ic_wifi6_error_signal_3'),
  $r('app.media.ic_wifi6_error_signal_4'),
];

const AP_WIFI6_PLUS_SIGNAL_ICONS: ResourceStr[] = [
  $r('app.media.ic_wifi6plus_signal_0'),
  $r('app.media.ic_wifi6plus_signal_1'),
  $r('app.media.ic_wifi6plus_signal_2'),
  $r('app.media.ic_wifi6plus_signal_3'),
  $r('app.media.ic_wifi6plus_signal_4'),
];

const AP_WIFI6_PLUS_SIGNAL_LOCK_ICONS: ResourceStr[] = [
  $r('app.media.ic_wifi6plus_lock_signal_0'),
  $r('app.media.ic_wifi6plus_lock_signal_1'),
  $r('app.media.ic_wifi6plus_lock_signal_2'),
  $r('app.media.ic_wifi6plus_lock_signal_3'),
  $r('app.media.ic_wifi6plus_lock_signal_4'),
];

const AP_WIFI6_PLUS_ERROR_SIGNAL_ICONS: ResourceStr[] = [
  $r('app.media.ic_wifi6plus_error_signal_0'),
  $r('app.media.ic_wifi6plus_error_signal_1'),
  $r('app.media.ic_wifi6plus_error_signal_2'),
  $r('app.media.ic_wifi6plus_error_signal_3'),
  $r('app.media.ic_wifi6plus_error_signal_4'),
];

const AP_WIFI7_SIGNAL_ICONS: ResourceStr[] = [
  $r('app.media.ic_wifi7_signal_0'),
  $r('app.media.ic_wifi7_signal_1'),
  $r('app.media.ic_wifi7_signal_2'),
  $r('app.media.ic_wifi7_signal_3'),
  $r('app.media.ic_wifi7_signal_4'),
];

const AP_WIFI7_SIGNAL_LOCK_ICONS: ResourceStr[] = [
  $r('app.media.ic_wifi7_lock_signal_0'),
  $r('app.media.ic_wifi7_lock_signal_1'),
  $r('app.media.ic_wifi7_lock_signal_2'),
  $r('app.media.ic_wifi7_lock_signal_3'),
  $r('app.media.ic_wifi7_lock_signal_4'),
];

const AP_WIFI7_ERROR_SIGNAL_ICONS: ResourceStr[] = [
  $r('app.media.ic_wifi7_error_signal_0'),
  $r('app.media.ic_wifi7_error_signal_1'),
  $r('app.media.ic_wifi7_error_signal_2'),
  $r('app.media.ic_wifi7_error_signal_3'),
  $r('app.media.ic_wifi7_error_signal_4'),
];

const AP_WIFI7_PLUS_SIGNAL_ICONS: ResourceStr[] = [
  $r('app.media.ic_wifi7plus_signal_0'),
  $r('app.media.ic_wifi7plus_signal_1'),
  $r('app.media.ic_wifi7plus_signal_2'),
  $r('app.media.ic_wifi7plus_signal_3'),
  $r('app.media.ic_wifi7plus_signal_4'),
];

const AP_WIFI7_PLUS_SIGNAL_LOCK_ICONS: ResourceStr[] = [
  $r('app.media.ic_wifi7plus_lock_signal_0'),
  $r('app.media.ic_wifi7plus_lock_signal_1'),
  $r('app.media.ic_wifi7plus_lock_signal_2'),
  $r('app.media.ic_wifi7plus_lock_signal_3'),
  $r('app.media.ic_wifi7plus_lock_signal_4'),
];

const AP_WIFI7_PLUS_ERROR_SIGNAL_ICONS: ResourceStr[] = [
  $r('app.media.ic_wifi7plus_error_signal_0'),
  $r('app.media.ic_wifi7plus_error_signal_1'),
  $r('app.media.ic_wifi7plus_error_signal_2'),
  $r('app.media.ic_wifi7plus_error_signal_3'),
  $r('app.media.ic_wifi7plus_error_signal_4'),
];

const AP_WIFI_ERROR_SIGNAL_ICONS: ResourceStr[] = [
  $r('app.media.ic_wlan_error_signal_0'),
  $r('app.media.ic_wlan_error_signal_1'),
  $r('app.media.ic_wlan_error_signal_2'),
  $r('app.media.ic_wlan_error_signal_3'),
  $r('app.media.ic_wlan_error_signal_4'),
];

const AP_SIGNAL_LOCK_ICONS_TEXT: ResourceStr[] = [
  $r('app.string.ic_wifi_lock_signal_0'),
  $r('app.string.ic_wifi_lock_signal_1'),
  $r('app.string.ic_wifi_lock_signal_2'),
  $r('app.string.ic_wifi_lock_signal_3'),
  $r('app.string.ic_wifi_lock_signal_4'),
];

const AP_SIGNAL_ICONS_TEXT: ResourceStr[] = [
  $r('app.string.ic_wifi_signal_0'),
  $r('app.string.ic_wifi_signal_1'),
  $r('app.string.ic_wifi_signal_2'),
  $r('app.string.ic_wifi_signal_3'),
  $r('app.string.ic_wifi_signal_4'),
];


const AP_WIFI6_SIGNAL_ICONS_TEXT: ResourceStr[] = [
  $r('app.string.ic_wifi6_signal_0'),
  $r('app.string.ic_wifi6_signal_1'),
  $r('app.string.ic_wifi6_signal_2'),
  $r('app.string.ic_wifi6_signal_3'),
  $r('app.string.ic_wifi6_signal_4'),
];

const AP_WIFI6_SIGNAL_LOCK_ICONS_TEXT: ResourceStr[] = [
  $r('app.string.ic_wifi6_lock_signal_0'),
  $r('app.string.ic_wifi6_lock_signal_1'),
  $r('app.string.ic_wifi6_lock_signal_2'),
  $r('app.string.ic_wifi6_lock_signal_3'),
  $r('app.string.ic_wifi6_lock_signal_4'),
];

const AP_WIFI6_PLUS_SIGNAL_ICONS_TEXT: ResourceStr[] = [
  $r('app.string.ic_wifi6plus_signal_0'),
  $r('app.string.ic_wifi6plus_signal_1'),
  $r('app.string.ic_wifi6plus_signal_2'),
  $r('app.string.ic_wifi6plus_signal_3'),
  $r('app.string.ic_wifi6plus_signal_4'),
];

const AP_WIFI6_PLUS_SIGNAL_LOCK_ICONS_TEXT: ResourceStr[] = [
  $r('app.string.ic_wifi6plus_lock_signal_0'),
  $r('app.string.ic_wifi6plus_lock_signal_1'),
  $r('app.string.ic_wifi6plus_lock_signal_2'),
  $r('app.string.ic_wifi6plus_lock_signal_3'),
  $r('app.string.ic_wifi6plus_lock_signal_4'),
];

const AP_WIFI7_SIGNAL_ICONS_TEXT: ResourceStr[] = [
  $r('app.string.ic_wifi7_signal_0'),
  $r('app.string.ic_wifi7_signal_1'),
  $r('app.string.ic_wifi7_signal_2'),
  $r('app.string.ic_wifi7_signal_3'),
  $r('app.string.ic_wifi7_signal_4'),
];

const AP_WIFI7_SIGNAL_LOCK_ICONS_TEXT: ResourceStr[] = [
  $r('app.string.ic_wifi7_lock_signal_0'),
  $r('app.string.ic_wifi7_lock_signal_1'),
  $r('app.string.ic_wifi7_lock_signal_2'),
  $r('app.string.ic_wifi7_lock_signal_3'),
  $r('app.string.ic_wifi7_lock_signal_4'),
];

const AP_WIFI7_PLUS_SIGNAL_ICONS_TEXT: ResourceStr[] = [
  $r('app.string.ic_wifi6plus_signal_0'),
  $r('app.string.ic_wifi6plus_signal_1'),
  $r('app.string.ic_wifi6plus_signal_2'),
  $r('app.string.ic_wifi6plus_signal_3'),
  $r('app.string.ic_wifi6plus_signal_4'),
];

const AP_WIFI7_PLUS_SIGNAL_LOCK_ICONS_TEXT: ResourceStr[] = [
  $r('app.string.ic_wifi6plus_lock_signal_0'),
  $r('app.string.ic_wifi6plus_lock_signal_1'),
  $r('app.string.ic_wifi6plus_lock_signal_2'),
  $r('app.string.ic_wifi6plus_lock_signal_3'),
  $r('app.string.ic_wifi6plus_lock_signal_4'),
];

const IP_ADDRESS: RegExp =
  new RegExp('^(([1-9]?\\d|1\\d{2}|2[0-4]\\d|25[0-5])\\.){3}([1-9]?\\d|1\\d{2}|2[0-4]\\d|25[0-5])$');

const IPV6_ADDRESS: RegExp =
  new RegExp('^(([0-9a-fA-F]{1,4}:){7}[0-9a-fA-F]{1,4}|(([0-9a-fA-F]{1,4}:){0,6}[0-9a-fA-F]{1,4})?::(([0-9a-fA-F]{1,4}:){0,6}[0-9a-fA-F]{1,4}))$');

const IPV4_TO_IPV6_ADDRESS: RegExp =
  new RegExp('^(::([fF]{4}:){1}|(0:){5})(([0-9]{1,3}\\.){3}[0-9]{1,3})$');

const SERVER_HOSTNAME_REGEXP: RegExp = new RegExp('^[a-zA-Z0-9]+(-[a-zA-Z0-9]+)*(\\.[a-zA-Z0-9]+(-[a-zA-Z0-9]+)*)*$');

const EXCLLIST_REG: string = '[a-zA-Z0-9*]+(-[a-zA-Z0-9*]+)*(\\.[a-zA-Z0-9*]+(-[a-zA-Z0-9*]+)*)*';

const EXCLLIST_REGEXP: RegExp = new RegExp('^$|^' + EXCLLIST_REG + '(,' + EXCLLIST_REG + ')*$');

const PROXY_PORT_MAX_VAL: number = Math.pow(2, 16) - 1;

const SIM_SUB_ID_NOT_SET: number = 0;

export const CONNECTED_AP_KEY: string = 'connected_ap_key';

export const WIFI_SWITCH_KEY: string = 'wifi_switch';

export const WLAN_SCAN_KEY: string = 'wlan_scan_switch';

export const WIFI_LIST_GROUP: string = 'wifi_list_group';

export const WIFI_CONNECTED_AP_GROUP: string = 'wifi_connected_ap_group';

export const WIFI_WINDOW_LIST_GROUP: string = 'wifi_window_list_group';

export const HOT_LIST_GROUP: string = 'hotspot_list_group';

export const IS_DEBUG: boolean = false;

export const WIFI_INACTIVE_HEIGHT: number = 109;

const NETWORK_CAPABILITY_LENGTH: number = 1;

// Indicates that the network is available.
const NET_CAPABILITY_VALIDATED: number = 16;

// Indicates that the network is portal.
const NET_CAPABILITY_PORTAL: number = 17;

// Indicates that the network is detection.
const NET_CAPABILITY_DETECTION: number = 31;

const FREQ_24GHZ: string = 'frequency_24GHZ';

const FREQ_5GHZ: string = 'frequency_5GHZ';

const FREQ_6GHZ: string = 'frequency_6GHZ';

const FREQ_60GHZ: string = 'frequency_60GHZ';

const MIN_FREQ_24GHZ: number = 2400;

const MAX_FREQ_24GHZ: number = 2500;

const MIN_FREQ_5GHZ: number = 4900;

const MAX_FREQ_5GHZ: number = 5900;

const MIN_FREQ_6GHZ: number = 5925;

const MAX_FREQ_6GHZ: number = 7125;

const MIN_FREQ_60GHZ: number = 58320;

const MAX_FREQ_60GHZ: number = 70200;

export const SCAN_INTERVAL: number = 10000;

export const SCAN_LOADING_INTERVAL: number = 1000;

export const SETTINGS_SWITCH_WLAN_LOGS: string = 'settings.switch_wlan_logs';

const NEWLINE_SEPARATOR: string = '\n';

export const IPV4_FAMILY_FLAG: number = 0;

export const IPV6_FAMILY_FLAG: number = 1;

export class PluginConstants {
  public static readonly DEFAULT_WIFI_NAME: string = 'WLAN';
  public static readonly WIFI_SIGNAL_NO: number = 0;
  public static readonly WIFI_SIGNAL_LOW: number = 1;
  public static readonly WIFI_SIGNAL_MID: number = 2;
  public static readonly WIFI_SIGNAL_HIGH: number = 3;
  public static readonly WIFI_SIGNAL_FULL: number = 4;

  public static readonly DATA_FLOW_TYPE_NONE: number = 0;
  public static readonly DATA_FLOW_TYPE_DOWN: number = 1;
  public static readonly DATA_FLOW_TYPE_UP: number = 2;
  public static readonly DATA_FLOW_TYPE_UP_DOWN: number = 3;

  public static readonly CATEGORY_DEFAULT = 1;
  public static readonly CATEGORY_WIFI6 = 2;
  public static readonly CATEGORY_WIFI6_PLUS = 3;
  public static readonly CATEGORY_WIFI7 = 4;
  public static readonly CATEGORY_WIFI7_PLUS = 5;
  public static readonly CATEGORY_DOUBLE = 6;
  public static readonly CATEGORY_DOUBLE_WIFI6 = 7;
  public static readonly CATEGORY_DOUBLE_WIFI6_PLUS = 8;
  public static readonly CATEGORY_DOUBLE_WIFI7 = 9;
  public static readonly CATEGORY_DOUBLE_WIFI7_PLUS = 10;
}

export class WifiData {
  public wifiName: string = PluginConstants.DEFAULT_WIFI_NAME;
  public isConnected: boolean = false;
  public isMetered: boolean = false;
  public signalLevel: number = PluginConstants.WIFI_SIGNAL_NO;
  public dataFlowType: number = PluginConstants.DATA_FLOW_TYPE_NONE;
  public isNetworkAvailable: boolean = false;
  public supportedWifiCategory: number = PluginConstants.CATEGORY_DEFAULT;
  public isScreenOff: boolean = false;
  public state: WifiState = WifiState.UNKNOWN;
}

const EVENT_ENTER_WIFI_PAGE: string = 'usual.event.wlan.ENTER_SETTINGS_WLAN_PAGE';

/**
 * Wifi工具类
 *
 * @since 2022-03-21
 */
export class WifiUtils {
  public static readonly MAC_REGEX_PATTERN: RegExp = new RegExp('([A-Fa-f0-9]{2}[-,:]){5}[A-Fa-f0-9]{2}');
  public static readonly MAC_PRINT_WITH_PRE: number = 5;
  public static readonly MAC_PRINT_WITH_SUF: number = 3;
  public static readonly ANONYMOUS_MAC: string = ':**:**:**';

  /**
   * 二维码 securityType 转换
   */
  static securityType2str(securityType: wifiManager.WifiSecurityType): string {
    switch (securityType) {
      case WifiSecurityType.WIFI_SEC_TYPE_OPEN:
        return 'nopass';
      case WifiSecurityType.WIFI_SEC_TYPE_WEP:
        return 'WEP';
      case WifiSecurityType.WIFI_SEC_TYPE_PSK:
        return 'WPA';
      case WifiSecurityType.WIFI_SEC_TYPE_SAE:
        return 'SAE';
      case WifiSecurityType.WIFI_SEC_TYPE_OWE:
        return 'OWE';
      default:
        return 'nopass';
    }
  }

  /**
   * 判断是否是支持网络共享
   */
  static isShared(): boolean {
    try {
      let state: string = systemParameterEnhance.getSync('const.booster.virtual_modem_switch', 'true');
      LogUtil.info(`${TAG} virtual modem switch state is : ${state}`);
      return state === 'true';
    } catch (error) {
      LogUtil.error(`${TAG}: Failed to get virtual modem switch. Code: ${error?.code}, message: ${error?.message}`);
      return false;
    }
  }

  /**
   * Wifi是否开启
   */
  static isWifiActive(): boolean {
    try {
      let isActive: boolean = wifiManager.isWifiActive();
      LogUtil.info(`${TAG} check wifi active status is : ${isActive}`);
      return isActive;
    } catch (error) {
      LogUtil.error(`${TAG} failed to check whether wifi is active, errCode:${(error as BusinessError).code}, message:${(error as BusinessError).message}`);
      return false;
    }
  }

  /**
   * Wifi是否可用
   *
   * @returns true 可用 false 不可用
   */
  static isWifiEnabled(): boolean {
    try {
      // 调用wifi管理模块查询wifi管控情况
      let isDisabled = enterpriseWifiManager.isWifiDisabled(null);
      LogUtil.info(`${TAG}: Succeeded in query is wifi disabled or not, result : ${isDisabled}`);
      return !isDisabled;
    } catch (err) {
      LogUtil.error(`${TAG}: Failed to get device encryption status. Code: ${err?.code}, message: ${err?.message}`);
      return true;
    }
  }

  static async wifiLinkedInfo(): Promise<string> {
    try {
      let wifiLinked: wifiManager.WifiLinkedInfo = await wifiManager.getLinkedInfo();
      return wifiLinked.ssid;
    } catch (error) {
      LogUtil.error(`${TAG} wifiLinkedInfo failed: ${error?.message}`);
    }
    return '';
  }

  static async wifiLinkedInfoDetail(): Promise<wifiManager.WifiLinkedInfo | undefined> {
    try {
      return await wifiManager.getLinkedInfo();
    } catch (error) {
      LogUtil.error(`${TAG} wifiLinkedInfoDetail failed: ${error?.message}`);
    }
    return undefined;
  }

  static async wifiIpAddress(): Promise<number> {
    try {
      let wifiLinked: wifiManager.WifiLinkedInfo = await wifiManager.getLinkedInfo();
      return wifiLinked.ipAddress;
    } catch (error) {
      LogUtil.error(`${TAG} wifiIpAddress failed: ${error?.message}`);
    }
    return 0;
  }

  // WLAN MAC 设备地址
  static getDeviceMacAddress(): Array<string> {
    let deviceMac: string[] = [];
    try {
      deviceMac = wifiManager.getDeviceMacAddress();
    } catch (err) {
      LogUtil.error(`${TAG} Failed to get DeviceMacAddress. Cause: code: ${err.code} message: ${err.message}`);
    }
    return deviceMac;
  }

  /**
   * 获取可以打印的掩码后设备ID
   *
   * @param macStr 设备ID字符串
   */
  static getLogMAC(macStr: string): string {
    if (!WifiUtils.isValidMac(macStr)) {
      return '';
    }
    let substring: string | null = null;
    substring = macStr.substring(0, WifiUtils.MAC_PRINT_WITH_PRE);
    return substring + WifiUtils.ANONYMOUS_MAC +
    macStr.substring(macStr.length - WifiUtils.MAC_PRINT_WITH_SUF, macStr.length);
  }

  static isValidMac(macStr: string): boolean {
    if (!macStr) {
      return false;
    }

    return macStr.match(WifiUtils.MAC_REGEX_PATTERN) !== null;
  }

  /**
   * 打开Wifi
   */
  static enableWifi(): boolean {
    try {
      wifiManager.enableWifi();
      HiSysEventUtil.reportSwitchEvent(HiSysAboutBluetoothEventGroup.CHANGE_WIFI_SWITCH, 'on');
      return true;
    } catch (err) {
      LogUtil.error(`${TAG} failed to enable wifi code: ${err.code} message: ${err.message}`);
      return false;
    }
  }

  /**
   * 关闭wifi
   */
  static disableWifi(): boolean {
    try {
      wifiManager.disableWifi();
      HiSysEventUtil.reportSwitchEvent(HiSysAboutBluetoothEventGroup.CHANGE_WIFI_SWITCH, 'off');
      return true;
    } catch (err) {
      LogUtil.error(`${TAG} failed to disable wifi, code: ${err.code} message: ${err.message}`);
      return false;
    }
  }

  /**
   * 半关闭wifi
   *
   * @returns 操作是否执行成功
   */
  static enableSemiWifi(): boolean {
    try {
      wifiManager.enableSemiWifi();
      HiSysEventUtil.reportSwitchEvent(HiSysAboutBluetoothEventGroup.CHANGE_WIFI_SWITCH, 'half_close');
      return true;
    } catch (error) {
      LogUtil.error(`${TAG} failed to disable wifi sta, errCode:${(error as BusinessError).code}, message:${(error as BusinessError).message}`);
      return false;
    }
  }

  /**
   * 获取当前wifi开启状态
   *
   * @returns 当前wifi开启状态
   */
  static getDetailState(): number {
    try {
      return wifiManager.getWifiDetailState();
    } catch (error) {
      LogUtil.error(`Failed to get wifi detail state, errCode:${(error as BusinessError).code},
       message:${(error as BusinessError).message}`);
      return WifiState.UNKNOWN;
    }
   }

  /**
   * 断开已连接的网络
   */
  static disconnect(): boolean {
    try {
      wifiManager.disconnect();
      return true;
    } catch (err) {
      LogUtil.error(`${TAG} failed to disconnect wifi, code: ${err.code} message: ${err.message}`);
      return false;
    }
  }

  /**
   * 移除指定的网络配置
   */
  static removeDevice(id: number): boolean {
    try {
      wifiManager.removeDevice(id);
      return true;
    } catch (err) {
      LogUtil.error(`${TAG} failed to removeDevice wifi, code: ${err.code} message: ${err.message}`);
      return false;
    }
  }

  /**
   * securityType 转换
   */
  static str2securityType(securityType: string): wifiManager.WifiSecurityType {
    switch (securityType) {
      case 'nopass':
        return WifiSecurityType.WIFI_SEC_TYPE_OPEN;
      case 'WEP':
        return WifiSecurityType.WIFI_SEC_TYPE_WEP;
      case 'WPA':
        return WifiSecurityType.WIFI_SEC_TYPE_PSK;
      case 'SAE':
        return WifiSecurityType.WIFI_SEC_TYPE_SAE;
      case 'OWE':
        return WifiSecurityType.WIFI_SEC_TYPE_OWE;
      default:
        return WifiSecurityType.WIFI_SEC_TYPE_OPEN;
    }
  }

  /**
   * 获取扫描列表
   *
   * @return 扫描列表
   */
  static getScanInfoList(): Array<wifiManager.WifiScanInfo> {
    try {
      return wifiManager.getScanInfoList();
    } catch (err) {
      LogUtil.error(`${TAG} failed to get scanInfo list, code: ${err.code} message: ${err.message}`);
      return [];
    }
  }

  /**
   * wifiStateChange 监听事件
   */
  static wifiStateChangeOn(tag: string, fn: Callback<number>): void {
    try {
      wifiManager.on('wifiStateChange', fn);
    } catch (e) {
      LogUtil.error(`${tag} wifiStateChange.on catch error code:${e?.code} message:${e?.message}`);
    }
  }

  /**
   * wifiStateChange 卸载事件
   */
  static wifiStateChangeOff(tag: string, fn: Callback<number>): void {
    try {
      wifiManager.off('wifiStateChange', fn);
    } catch (e) {
      LogUtil.error(`${tag} wifiStateChange.off catch error code:${e?.code} message:${e?.message}`);
    }
  }

  /**
   * wifiConnectionChange 监听事件
   */
  static wifiConnectionChangeOn(tag: string, fn: Callback<number>): void {
    try {
      wifiManager.on('wifiConnectionChange', fn);
    } catch (e) {
      LogUtil.error(`${tag} wifiConnectionChange.on catch error code:${e?.code} message:${e?.message}`);
    }
  }

  /**
   * wifiConnectionChange 卸载事件
   */
  static wifiConnectionChangeOff(tag: string, fn: Callback<number>): void {
    try {
      wifiManager.off('wifiConnectionChange', fn);
    } catch (e) {
      LogUtil.error(`${tag} wifiConnectionChange.off catch error code:${e?.code} message:${e?.message}`);
    }
  }

  /**
   * wifiScanStateChange 监听事件
   */
  static wifiScanStateChangeOn(tag: string, fn: Callback<number>): void {
    try {
      wifiManager.on('wifiScanStateChange', fn);
    } catch (e) {
      LogUtil.error(`${tag} wifiScanStateChange.on catch error code:${e?.code} message:${e?.message}`);
    }
  }

  /**
   * wifiScanStateChange 卸载事件
   */
  static wifiScanStateChangeOff(tag: string, fn: Callback<number>): void {
    try {
      wifiManager.off('wifiScanStateChange', fn);
    } catch (e) {
      LogUtil.error(`${tag} wifiScanStateChange.off catch error code:${e?.code} message:${e?.message}`);
    }
  }

  /**
   * wifiRssiChange 监听事件
   */
  static wifiRssiChangeOn(tag: string, fn: Callback<number>): void {
    try {
      wifiManager.on('wifiRssiChange', fn);
    } catch (e) {
      LogUtil.error(`${tag} wifiRssiChange.on catch error code:${e?.code} message:${e?.message}`);
    }
  }

  /**
   * wifiRssiChange 卸载事件
   */
  static wifiRssiChangeOff(tag: string, fn: Callback<number>): void {
    try {
      wifiManager.off('wifiRssiChange', fn);
    } catch (e) {
      LogUtil.error(`${tag} wifiRssiChange.off catch error code:${e?.code} message:${e?.message}`);
    }
  }

  /**
   * wifiStreamChange 监听事件
   */
  static wifiStreamChangeOn(tag: string, fn: Callback<number>): void {
    try {
      wifiManager.on('streamChange', fn);
    } catch (e) {
      LogUtil.error(`${tag} wifiStreamChangeOn.on error catch code:${e?.code} message:${e?.message}`);
    }
  }

  /**
   * wifiStreamChange 卸载事件
   */
  static wifiStreamChangeOff(tag: string, fn: Callback<number>): void {
    try {
      wifiManager.off('streamChange');
    } catch (e) {
      LogUtil.error(`${tag} wifiStreamChangeOff.off error catch code:${e?.code} message:${e?.message}`);
    }
  }

  /**
   * 扫描wifi
   *
   * @return 操作是否成功执行
   */
  static scanWifi(): boolean {
    try {
      wifiManager.startScan();
      return true;
    } catch (err) {
      LogUtil.error(`${TAG} failed to start scan wifi, code: ${err.code} message: ${err.message}`);
      return false;
    }
  }

  /**
   * 拉起portal网络认证页面
   *
   * @return 操作是否成功执行
   */
  static startPortalCertification(): boolean {
    try {
      wifiManager.startPortalCertification();
      return true;
    } catch (err) {
      LogUtil.error(`${TAG} failed to start portal certification, code: ${err.code} message: ${err.message}`);
      return false;
    }
  }

/**
 * 使能hilink自动连接
 *
 * @param isHiLinkEnable 是否支持hilink
 * @param bssid 网络的bssid
 * @param config 网络配置参数
 */
  static enableHiLinkHandshake(isHiLinkEnable: boolean, bssid: string, config: wifiManager.WifiDeviceConfig) {
    if (CheckEmptyUtils.checkStrIsEmpty(bssid)) {
      LogUtil.error(`${TAG} enableHiLinkHandshake invalid, bssid is null`);
      return;
    }
    try {
      LogUtil.info(`${TAG} enableHiLinkHandshake isEnable:${isHiLinkEnable} randomMacType:${config?.randomMacType}`);
      wifiManager.enableHiLinkHandshake(isHiLinkEnable, bssid, config);
    } catch (error) {
      LogUtil.error(`${TAG} enableHiLinkHandshake catch error, errCode:${error?.code}, message:${error?.message}`);
    }
  }

  /**
   * 是否是wifi网络
   *
   * @param bearerTypes 网络类型
   * @returns true, wifi网络
   */
  static isBearerWifi(bearerTypes?: Array<connection.NetBearType>): boolean {
    return bearerTypes?.length === NETWORK_CAPABILITY_LENGTH && bearerTypes[0] === connection.NetBearType.BEARER_WIFI;
  }

  /**
   * 网络是否可用
   *
   * @param caps 网络能力
   * @returns true, 网络可用
   */
  static isWifiNetworkValidated(caps?: Array<connection.NetCap>): boolean {
    // 当网络能力包含16(不包含31正在探测)的时候为可用状态
    if (WifiMenuManager.isInOObeStage()) {
      return caps?.includes(NET_CAPABILITY_VALIDATED) as boolean &&
        (!caps?.includes(NET_CAPABILITY_DETECTION) as boolean);
    } else {
      return caps?.includes(NET_CAPABILITY_VALIDATED) as boolean;
    }
  }

  /**
   * 是否是Portal网络
   *
   * @param caps 网络能力
   * @returns true, Portal网络
   */
  static isPortalWifiNetwork(caps?: Array<connection.NetCap>): boolean {
    // 当网络能力包含17的时候为Portal网络
    return caps?.includes(NET_CAPABILITY_PORTAL) as boolean;
  }

  /**
   * 注册监听网络能力变化事件
   *
   * @param netCon 网络连接句柄
   * @param callback 监听回调函数
   * @param tag 日志TAG
   */
  static registerNetCapabilitiesChange(netCon: connection.NetConnection,
    callback: Callback<connection.NetCapabilityInfo>, tag: string): void {
    if (CheckEmptyUtils.isEmpty(netCon) || CheckEmptyUtils.isEmpty(callback)) {
      LogUtil.error(`${tag} netCon or callback is invalid, register netConnection failed`);
      return;
    }
    try {
      // register network state changes
      netCon.register((error: BusinessError) => {
        if (error) {
          LogUtil.error(`${tag} register netConnection, error: ${error?.code}`);
        }
      });
      // subscribe network capability change events
      netCon.on('netCapabilitiesChange', callback);
    } catch (err) {
      LogUtil.error(`${tag} try register netConnection code: ${err.code} message: ${err.message}`);
    }
  }

  /**
   * 取消注册监听网络能力变化事件，和registerNetCapabilitiesChange配套使用
   *
   * @param netCon 网络连接句柄
   * @param tag 日志TAG
   */
  static unRegisterNetCapabilitiesChange(netCon: connection.NetConnection, tag: string): void {
    if (CheckEmptyUtils.isEmpty(netCon)) {
      LogUtil.error(`${tag} netCon is invalid, unregister netConnection failed`);
      return;
    }
    try {
      // unregister network state changes
      netCon.unregister((error: BusinessError) => {
        if (error) {
          LogUtil.error(`${tag} unregister netConnection, error: ${error?.code}`);
        }
      });
    } catch (err) {
      LogUtil.error(`${tag} try unregister netConnection code: ${err.code} message: ${err.message}`);
    }
  }

  /**
   * 获取Config配置的Ap健值
   *
   * @param config Wifi的Ap配置
   */
  static getApKeyWithConfig(config: wifiManager.WifiDeviceConfig): string | null {
    if (!config) {
      LogUtil.error(`${TAG} getApKeyWithConfig, config is null`);
      return '';
    }
    let wifiConfig = config;
    return WifiUtils.getApKey(wifiConfig.ssid as string, wifiConfig.bssid as string, wifiConfig.securityType);
  }

  /**
   * 获取扫描结果的Ap健值
   *
   * @param scanResult Wifi扫描结果
   */
  static getApKeyWithScanResult(scanResult: WifiScanResult): string | null {
    if (!scanResult) {
      LogUtil.error(`${TAG} getApKeyWithScanResult, scanResult is null`);
      return '';
    }
    return WifiUtils.getApKey(scanResult.ssid, scanResult.bssid, scanResult.securityType as number);
  }

  /**
   * 获取Ap的健值
   *
   * @param ssid Ap的ssid
   * @param bssid Ap的bssid
   * @param securityType Ap的加密类型
   */
  static getApKey(ssid: string, bssid: string, securityType: number): string | null {
    if (securityType === undefined || securityType === null) {
      LogUtil.warn(`${TAG} getApKey, securityType is null`);
      return null;
    }
    let key: string = ssid ?? bssid;
    if (!key) {
      LogUtil.error(`${TAG} getApKey, key is null`);
      return null;
    }
    return `AP:${key},${securityType}`;
  }

  /**
   * 获取可以打印的Ap健值
   *
   * @param ssid Ap的ssid
   * @param securityType Ap的加密类型
   */
  static getApLogKey(ssid: string, securityType: number): string {
    if (securityType === undefined || securityType === null) {
      LogUtil.warn(`${TAG} getApKey, securityType is null`);
      return '';
    }
    let key: string = ssid;
    if (!key) {
      LogUtil.error(`${TAG} getApLogKey, ssid is null`);
      return '';
    }
    return `AP:${WifiUtils.getLogSsidString(key)},${securityType}`;
  }

  /**
   * 获取对应网络ID的AP配置
   *
   * @param networkId 网络ID
   * @param configs AP配置集合
   */
  static getConfigForNetworkId(networkId: number, configs: Array<wifiManager.WifiDeviceConfig>):
  wifiManager.WifiDeviceConfig | null {
    if (!configs) {
      LogUtil.error(`${TAG} getConfigForNetworkId, configs is null`);
      return null;
    }

    for (let config of configs) {
      if (config && (config.netId === networkId)) {
        return config;
      }
    }

    return null;
  }

  /**
   * 获取连接网络的AP配置
   */
  static async getConnectConfig(): Promise<wifiManager.WifiDeviceConfig | null> {
    let linkedInfo: wifiManager.WifiLinkedInfo | undefined = await WifiUtils.getLinkedInfo();
    if (linkedInfo?.connState !== WIFI_STATE_CONNECTED || !WifiUtils.isValidNetworkId(linkedInfo?.networkId)) {
      LogUtil.error(`${TAG} getConnectConfig disConnect`);
      return null;
    }
    try {
      let configs: wifiManager.WifiDeviceConfig[] = wifiManager.getDeviceConfigs();
      if (!configs) {
        LogUtil.error(`${TAG} getConfigForNetworkId, configs is null`);
        return null;
      }
      return await WifiUtils.getConfigForNetworkId(linkedInfo?.networkId, configs)
    } catch (error) {
      LogUtil.error(`${TAG} get device configs error: ${error?.message}`);
    }
    return null;
  }

  /**
   * 是否开放网络
   *
   * @param securityType 加密类型
   */
  static isOpenAp(securityType: number): boolean {
    return securityType === WifiSecurityType.WIFI_SEC_TYPE_OPEN;
  }

  /**
   * 转换成对应的信号字符串
   *
   * @param signal 信号值
   */
  static getApSignalString(signal: number): ResourceStr | undefined {
    if (signal < 0 || signal >= AP_SIGNAL_STRINGS.length) {
      LogUtil.error(`${TAG} getApSignalString, signal invalid`);
      return undefined;
    }
    return AP_SIGNAL_STRINGS[signal];
  }

  /**
   * 转换成对应的加密类型字符串
   *
   * @param security 加密类型值
   */
  static getApSecurityString(security: number): ResourceStr | undefined {
    if (security < 1 || security >= AP_SECURITY_STRINGS.length) {
      LogUtil.error(`${TAG} getApSecurityString, security invalid`);
      return undefined;
    }
    if (security === wifiManager.WifiSecurityType.WIFI_SEC_TYPE_EAP_SUITE_B) {
      return ResourceUtil.getNumberFormatStringSync($r('app.string.wifi_security_eap_suite_b'), '192')
    }
    return AP_SECURITY_STRINGS[security];
  }

  /**
   * 获取对应ssid和加密类型的Ap配置
   *
   * @param ssid Ap的ssid
   * @param securityType Ap的加密类型
   */
  static getConfig(ssid: string, securityType: number): wifiManager.WifiDeviceConfig | undefined {
    try {
      let configs: wifiManager.WifiDeviceConfig[] = wifiManager.getDeviceConfigs();
      if (!configs) {
        LogUtil.error(`${TAG} getConfig, configs null`);
        return undefined;
      }
      for (let config of configs) {
        if (config?.ssid === ssid && config?.securityType === securityType) {
          return config;
        }
      }
    } catch (error) {
      LogUtil.error(`${TAG} getConfig err: ${error?.message}`);
    }
    return undefined;
  }

  static isValidNetworkId(networkId: number | null | undefined): boolean {
    return networkId !== null && networkId !== undefined && networkId !== INVALID_NETWORK_ID;
  }

  /**
   * Sae加密的密码是否合法
   *
   * @param pwdString 密码字符串
   */
  static isValidSaePassword(pwdString: string): boolean {
    if (!pwdString) {
      return false;
    }
    let pwdLength = pwdString.length;
    return pwdLength >= WIFI_SAE_MIN_PASSWORD_LEN && pwdLength <= WIFI_SAE_MAX_PASSWORD_LEN;
  }

  /**
   * EAP加密的密码是否合法
   *
   * @param pwdString 密码字符串
   */
  static isValidEapPassword(pwdString: string): boolean {
    if (!pwdString) {
      return false;
    }
    let pwdLength = pwdString.length;
    return pwdLength >= WIFI_EAP_MIN_PASSWORD_LEN && pwdLength <= WIFI_SAE_MAX_PASSWORD_LEN;
  }

  static isPwdValid(securityType: number, pwdString: string, capabilities?: string): boolean {
    if (securityType === WifiSecurityType.WIFI_SEC_TYPE_WEP) {
      return WifiUtils.isValidWepEncryptionPwd(pwdString);
    }
    if (securityType === WifiSecurityType.WIFI_SEC_TYPE_PSK) {
      return WifiUtils.isValidPskPassword(pwdString, capabilities);
    }
    if (securityType === WifiSecurityType.WIFI_SEC_TYPE_SAE) {
      return WifiUtils.isValidSaePassword(pwdString);
    }
    return true;
  }

  static isValidWepEncryptionPwd(pwdString: string): boolean {
    LogUtil.info(`${TAG} isValidWepEncryptionPwd length: ${pwdString?.length}`);
    if (!pwdString) {
      return false;
    }
    let pwdLength = pwdString.length;
    for (let validHexLength of VALID_WEB_HEX_PWD_LENGTHS) {
      if (pwdLength === validHexLength && pwdString.match('[0-9A-Fa-f]*')![0]?.length === validHexLength) {
        return true;
      }
    }

    return VALID_WEB_ASCII_PWD_LENGTHS.includes(pwdString.length);
  }

  /**
   * Psk加密的密码是否合法
   *
   * @param pwdString 密码字符串
   * @param capabilities 加密方式能力集
   * @returns 检查结果
   */
  static isValidPskPassword(pwdString: string, capabilities?: string): boolean {
    if (!pwdString) {
      return false;
    }
    let pwdLength = pwdString.length;
    if (capabilities?.includes('TKIP') || (capabilities?.includes('CCM') && !capabilities?.includes('SAE'))) {
      // WPA2及以下场景：wpa only的场景是type=PSK，且cap里面只有TKIP没有CCM; wpa+wpa2的场景type=PSK，且cap里既有TKIP又有CCM;
      return pwdLength >= WIFI_PSK_MIN_PASSWORD_LEN && pwdLength <= WIFI_PSK_WPA2_MAX_PASSWORD_LEN;
    }

    // WPA2/WPA3混合模式及WPA3场景
    return pwdLength >= WIFI_PSK_MIN_PASSWORD_LEN && pwdLength <= WIFI_PSK_MAX_PASSWORD_LEN;
  }

  /**
   * 获取最大连接速度
   *
   * @param accessPoint 连接信息
   * @returns 连接速度
   */
  static getMaxLinkSpeed(accessPoint?: AccessPoint): number {
    let linkedInfo = accessPoint?.lastLinkedInfo;
    if (!linkedInfo || !linkedInfo.wifiLinkType || linkedInfo.wifiLinkType !== WIFI7_EMLSR) {
      return accessPoint?.getSpeed() ?? 0;
    }
    let multiLinkedInfo = accessPoint?.lastMultiLinkedInfo;
    if (!multiLinkedInfo) {
      LogUtil.error(`${TAG} multiLinkedInfo error`);
      return accessPoint?.getSpeed() ?? 0;
    }
    let maxLinkSpeed: number = 0;
    for (let info of multiLinkedInfo) {
      if (info && info.linkSpeed) {
        LogUtil.info(`${TAG} linkSpeed: ${info.linkSpeed}`);
        maxLinkSpeed = Math.max(maxLinkSpeed, info.linkSpeed);
      }
    }
    return maxLinkSpeed;
  }

  /**
   * 获取频段字符串
   *
   * @param frequency 频段值
   */
  static getFrequencyString(frequency: number): ResourceStr | undefined {
    if (frequency >= LOWER_FREQ_24GHZ && frequency < HIGHER_FREQ_24GHZ) {
      return $r('app.string.wifi_wifi_frequency_2g');
    }

    if (frequency >= LOWER_FREQ_5GHZ && frequency < HIGHER_FREQ_5GHZ) {
      return $r('app.string.wifi_wifi_frequency_5g');
    }

    LogUtil.error(`${TAG} getFrequencyString, frequency invalid`);
    return undefined;
  }

  /**
   * 获取多路频段字符串
   *
   * @param accessPoint wifi信息
   * @returns 频段描述字符串
   */
  static getMultiFrequencyString(accessPoint?: AccessPoint): ResourceStr | undefined {
    if (!accessPoint) {
      LogUtil.error(`${TAG} getMultiFrequencyString, accessPoint undefined`);
      return $r('app.string.wifi_wifi_frequency_2g');
    }
    let linkedInfo = accessPoint.lastLinkedInfo;
    if (!linkedInfo || !linkedInfo.wifiLinkType || linkedInfo.wifiLinkType !== WIFI7_EMLSR) {
      return WifiUtils.getFrequencyString(accessPoint.getFrequency() ?? 0);
    }
    let multiLinkedInfo = accessPoint.lastMultiLinkedInfo;
    if (!multiLinkedInfo) {
      LogUtil.error(`${TAG} getMultiFrequencyString, multiLinkedInfo undefined`);
      return WifiUtils.getFrequencyString(accessPoint.getFrequency() ?? 0);
    }
    let has5G: boolean = false;
    let has24G: boolean = false;
    for (let i = 0; i < multiLinkedInfo.length; i++) {
      let frequency = multiLinkedInfo[i].frequency;
      if (frequency >= LOWER_FREQ_24GHZ && frequency < HIGHER_FREQ_24GHZ) {
        has24G = true;
      }
      if (frequency >= LOWER_FREQ_5GHZ && frequency < HIGHER_FREQ_5GHZ) {
        has5G = true;
      }
    }
    if (has24G && has5G) {
      return $r('app.string.wifi_wifi_frequency_2g_5g');
    }
    if (has24G) {
      return $r('app.string.wifi_wifi_frequency_2g');
    }
    if (has5G) {
      return $r('app.string.wifi_wifi_frequency_5g');
    }
    return undefined;
  }

  /**
   * 组装IP信息
   *
   * @returns IP信息
   */
  static getIpInfoByPendingConfig(pendingIpConfig: PendingIpConfig): wifiManager.IpInfo | null {
    let ip4Info: wifiManager.IpInfo = {
      ipAddress: 0,
      gateway: 0,
      netmask: 0,
      primaryDns: 0,
      secondDns: 0,
      serverIp: 0,
      leaseDuration: 0
    };
    if (pendingIpConfig) {
      ip4Info.ipAddress = pendingIpConfig?.ipAddress || 0;
      ip4Info.gateway = pendingIpConfig?.gateway || 0;
      ip4Info.netmask = pendingIpConfig?.prefixLength || 0;
      if (pendingIpConfig?.dnsServers?.length >= 1) {
        ip4Info.primaryDns = pendingIpConfig?.dnsServers[0] || 0;
        if (pendingIpConfig?.dnsServers?.length > 1) {
          ip4Info.secondDns = pendingIpConfig?.dnsServers[1] || 0;
        }
      }
    }
    return ip4Info;
  }

  /**
   * 组装IPv6信息
   *
   * @returns IPv6信息
   */
  static getIpv6InfoByPendingConfig(pendingIpConfig: PendingIpConfig): wifiManager.Ipv6Info {
    let ipv6Info: wifiManager.Ipv6Info = {
      linkIpv6Address: '',
      globalIpv6Address: '',
      randomGlobalIpv6Address: '',
      uniqueIpv6Address: '',
      gateway: '',
      netmask: '',
      primaryDNS: '',
      secondDNS: '',
    };
    if (pendingIpConfig) {
      ipv6Info.globalIpv6Address = pendingIpConfig?.ipv6Address ?? '';
      ipv6Info.gateway = pendingIpConfig?.ipv6Gateway ?? '';
      ipv6Info.netmask =
        pendingIpConfig?.ipv6PrefixLength !== undefined ? String(pendingIpConfig.ipv6PrefixLength) : '';
      if (pendingIpConfig?.ipv6DnsServers?.length >= 1) {
        ipv6Info.primaryDNS = pendingIpConfig?.ipv6DnsServers[0] ?? '';
        if (pendingIpConfig?.ipv6DnsServers?.length > 1) {
          ipv6Info.secondDNS = pendingIpConfig?.ipv6DnsServers[1] ?? '';
        }
      }
    }
    return ipv6Info;
  }

  /**
   * 获取ipv6地址
   *
   * @param ipv6String字符串
   * @returns 合法的ipv6String字符串
   */
  static validIpv6String(ipString: string): string {
    if (!ipString || typeof ipString !== 'string' ||
      !((IPV6_ADDRESS.test(ipString) || IPV4_TO_IPV6_ADDRESS.test(ipString)))) {
      LogUtil.warn(TAG + 'ipv6 string is not valid');
      return '';
    }
    return ipString;
  }

  /**
   * 获取IP地址字符串
   *
   * @param ipNumber IP地址数值
   */
  static number2IpString(ipNumber: number | undefined): ResourceStr {
    if (!ipNumber) {
      return '';
    }
    let ip: number[] = [];
    ip[0] = (ipNumber >>> 24) >>> 0;
    ip[1] = ((ipNumber << 8) >>> 24) >>> 0;
    ip[2] = (ipNumber << 16) >>> 24;
    ip[3] = (ipNumber << 24) >>> 24;
    let ipString = String(ip[0]) + '.' + String(ip[1]) + '.' + String(ip[2]) + '.' + String(ip[3]);
    return ipString;
  }

  /**
   * 根据子网掩码计算网络前缀长度
   *
   * @param ipNumber IP地址数值
   */
  static getPrefixLength(ipNumber: number): number {
    let count = 0;
    let n = ipNumber;
    while (n) {
      n = n & (n - 1);
      count += 1;
    }
    return count;
  }

  /**
   * 根据ipv6子网掩码计算网络前缀长度
   *
   * @param ipNumber IP地址数值
   */
  static ipv6PrefixToNumber(prefixStr: string): number {
    const normalizedStr = prefixStr.trim().toLowerCase();
    if (normalizedStr === "") {
      return 0;
    }
    const parts = normalizedStr.split(":");
    let zeroIndex = -1;
    for (let i = 0; i < parts.length; i++) {
      if (parts[i] === "") {
        zeroIndex = i;
        break;
      }
    }
    if (zeroIndex !== -1) {
      const before = parts.slice(0, zeroIndex);
      const after = parts.slice(zeroIndex + 1);
      const zeroCount = 8 - (before.length + after.length);
      const expanded: string[] = new Array(zeroCount).fill("0");
      parts.splice(zeroIndex, 1, ...expanded);
    }
    while (parts.length < 8) {
      parts.push("0");
    }
    let prefixBits = 0;
    for (let i = 0; i < 8; i++) {
      let part = parts[i];
      if (part === "") {
        part = "0";
      }
      const value = parseInt(part, 16) || 0;
      if (value === 0xffff) {
        prefixBits += 16;
      } else {
        let mask = 0x8000;
        let count = 0;
        for (let j = 0; j < 16; j++) {
          if ((value & mask) === mask) {
            count++;
            mask = mask >>> 1;
          } else {
            break;
          }
        }
        prefixBits += count;
        break;
      }
    }
    return prefixBits;
  }


  /**
   * 获取十进制IP地址
   *
   * @param ipString IP地址
   */
  static ipString2Number(ipString: string): number | null {
    if (!ipString || typeof ipString !== 'string' || !IP_ADDRESS.test(ipString)) {
      LogUtil.warn(TAG + 'ip string is not valid');
      return null;
    }
    let ipNumber = Number.parseInt(ipString.split('.')
      .map((ip) => Number.parseInt(ip, 10).toString(2).padStart(8, '0'))
      .join(''), 2)
    return ipNumber;
  }

  /**
   * 获取IP地址
   *
   */
  static getIPInfo(): string {
    let ipAddress = '';
    try {
      let ip4Info = wifiManager.getIpInfo();
      let ip6Info: wifiManager.Ipv6Info = wifiManager.getIpv6Info();
      LogUtil.info(`wifiManager.getIpv6Info.`)
      if (ip4Info?.ipAddress) {
        ipAddress += WifiUtils.number2IpString(ip4Info.ipAddress);
      }
      if (ip6Info?.linkIpv6Address) {
        ipAddress += NEWLINE_SEPARATOR + ip6Info.linkIpv6Address;
      }
      if (ip6Info?.globalIpv6Address) {
        ipAddress += NEWLINE_SEPARATOR + ip6Info.globalIpv6Address;
      }
      if (ip6Info?.randomGlobalIpv6Address) {
        ipAddress += NEWLINE_SEPARATOR + ip6Info.randomGlobalIpv6Address;
      }
      if (ip6Info?.uniqueIpv6Address) {
        ipAddress += NEWLINE_SEPARATOR + ip6Info.uniqueIpv6Address;
      }
      if (ip6Info?.randomUniqueIpv6Address) {
        ipAddress += NEWLINE_SEPARATOR + ip6Info.randomUniqueIpv6Address;
      }
    } catch (error) {
      LogUtil.error(`try getIPInfo error: ${error?.code}`);
    }
    return ipAddress;
  }

  /**
   * 获取wifi列表详细日志
   *
   * @param wifiInfo wifi信息
   * @param isWlanLog 是否显示
   */
  static getWifiInfoDescription(wifiInfo: Partial<ApMenuData>): string {
    let frequencyMap: Map<string, FrequencyThreshold> = new Map();
    let getWifiInfoDescription: string = '';
    frequencyMap.set(FREQ_24GHZ, { freqMin: MIN_FREQ_24GHZ, freqMax: MAX_FREQ_24GHZ });
    frequencyMap.set(FREQ_5GHZ, { freqMin: MIN_FREQ_5GHZ, freqMax: MAX_FREQ_5GHZ });
    frequencyMap.set(FREQ_6GHZ, { freqMin: MIN_FREQ_6GHZ, freqMax: MAX_FREQ_6GHZ });
    frequencyMap.set(FREQ_60GHZ, { freqMin: MIN_FREQ_60GHZ, freqMax: MAX_FREQ_60GHZ });
    if (wifiInfo && wifiInfo.scanResults && wifiInfo.scanResults.length > 0) {
      frequencyMap.forEach((value) => {
        getWifiInfoDescription += WifiUtils.getScanResultDescription(value.freqMin,
          value.freqMax, wifiInfo.scanResults?.slice(0, 3));
      });
    }
    return getWifiInfoDescription;
  }

  /**
   * 获取wifi列表详细日志
   *
   * @param minFrequency 最小频率
   * @param maxFrequency 最大频率
   * @param scanResultsList 扫描结果
   */
  static getScanResultDescription(minFrequency: number, maxFrequency: number,
                                    scanResultsList?: WifiScanResult[]): string {
    let description: string = '';
    if (scanResultsList && scanResultsList.length > 0) {
      scanResultsList.forEach(item => {
        if (item.frequency >= minFrequency && item.frequency <= maxFrequency) {
          description = description + `{${item.bssid}=${item.frequency},${item.rssi}}`;
        }
      })
    }
    return description;
  }

  /**
   * 获取已连接wifi速率显示
   *
   * @param multiInfo 双链信息
   * @param wifiLinkedInfo 连接信息
   */
  static getConnectedDescription(multiInfo: Array<wifiManager.WifiLinkedInfo> | undefined | null,
    info: wifiManager.WifiLinkedInfo | undefined | null): string {
    if (info?.wifiLinkType !== WIFI7_EMLSR || !multiInfo || multiInfo.length < 2) {
      return WifiUtils.getLinkDesc(info);
    }
    let description = '';
    for (let i = 0; i < multiInfo.length; i++) {
      let item: wifiManager.WifiLinkedInfo = multiInfo[i];
      description += `f=${item?.frequency} ${item?.bssid}\n` +
        `rssi=${item?.rssi} tx=${item?.linkSpeed} ${item?.rxLinkSpeed} rx=${item?.maxSupportedRxLinkSpeed}`;
      if (i < multiInfo.length) {
        description += `\n`;
      }
    }
    return description;
  }

  /**
   * 获取已连接单链路wifi速率显示
   *
   * @param info WiFi单链路信息
   */
  static getLinkDesc(info: wifiManager.WifiLinkedInfo | undefined | null) {
    let description = '';
    if (info) {
      description = `f=${info?.frequency} ${info?.bssid}\n` +
        `rssi=${info?.rssi} tx=${info?.linkSpeed} ${info?.rxLinkSpeed} rx=${info?.maxSupportedRxLinkSpeed}`;
    }
    return description;
  }

  /**
   * 获取当前缓存的单链路信息
   *
   * @param accessPoint AP数据信息
   */
  static getLastLinkedInfo(accessPoint?: AccessPoint): wifiManager.WifiLinkedInfo | undefined {
    if (!accessPoint) {
      return undefined;
    }
    return accessPoint.lastLinkedInfo as wifiManager.WifiLinkedInfo;
  }

  /**
   * 获取当面缓存的双链路信息
   *
   * @param accessPoint AP数据信息
   */
  static getLastMultiLinkedInfo(accessPoint?: AccessPoint): wifiManager.WifiLinkedInfo[] | undefined {
    if (!accessPoint) {
      return undefined;
    }
    return accessPoint.lastMultiLinkedInfo as wifiManager.WifiLinkedInfo[];
  }

  /**
   * 转换成可以打印的ssid掩码
   *
   * @param ssidString 待转换的ssid
   */
  static getLogSsidString(ssidString: String): string {
    if (!ssidString) {
      return '';
    }

    let maskString: string = '************************************';
    let minMaskLen: number = 3;
    let maxLen: number = 32;
    let len = ssidString.length;
    if (len <= 1 || len > maxLen) {
      return '*****';
    }

    let maskLen: number = len + minMaskLen;
    let midLen: number = 10;
    if (len <= midLen) {
      return ssidString.charAt(0) + maskString.substring(0, maskLen - 1);
    }

    return ssidString.charAt(0) + maskString.substring(0, maskLen - 1) + ssidString.charAt(len - 1);
  }

  /**
   * check wifi configs
   *
   * @param config wifi info
   * @param capabilities wifi capabilities
   * @param isHybridSecurity hybridSecurity
   * @returns check result
   */
  static validWifiConfig(config: wifiManager.WifiDeviceConfig, capabilities?: string,
    isHybridSecurity?: boolean): boolean {
    if (isHybridSecurity) {
      return WifiUtils.isValidHybridSecurityPassword(config?.preSharedKey, capabilities);
    }
    if (config?.securityType === wifiManager.WifiSecurityType.WIFI_SEC_TYPE_EAP &&
      !WifiUtils.isValidWifiEapConfig(config?.eapConfig)) {
      LogUtil.info(`${TAG} check eapConfig failed`);
      return false;
    } else if (config?.securityType === wifiManager.WifiSecurityType.WIFI_SEC_TYPE_WAPI_PSK &&
      !WifiUtils.isValidWifiWapipskConfig(config, capabilities)) {
      LogUtil.info(`${TAG} check wapiPskConfig failed`);
      return false;
    } else if (config?.securityType === wifiManager.WifiSecurityType.WIFI_SEC_TYPE_WAPI_CERT &&
      !WifiUtils.isValidWifiWapiCertConfig(config)) {
      LogUtil.info(`${TAG} check wapiCertConfig failed`);
      return false;
    } else if (!WifiUtils.isPwdValid(config?.securityType, config?.preSharedKey, capabilities)) {
      LogUtil.info(`${TAG} check password failed`);
      return false;
    }
    if (!WifiUtils.isValidWifiAdvancedConfig(config)) {
      return false;
    }
    return true;
  }


  /**
   * 添加网络混合加密是否合法
   *
   * @param config wifi配置信息
   * @returns 检查结果
   */
  static isValidHybridSecurityPassword(pwdString: string, capabilities?: string): boolean {
    if (!pwdString) {
      return false;
    }
    let pwdLength = pwdString.length;
    if (capabilities?.includes('TKIP') || (capabilities?.includes('CCM') && !capabilities?.includes('SAE'))) {
      return pwdLength >= WIFI_PSK_MIN_PASSWORD_LEN && pwdLength <= WIFI_PSK_WPA2_MAX_PASSWORD_LEN;
    }
    return pwdLength >= WIFI_HYBRID_SECURITY_MIN_PASSWORD_LEN && pwdLength <= WIFI_PSK_MAX_PASSWORD_LEN;
  }

  /**
   * 检查Wi-Fi的高级选项信息是否合法
   *
   * @param Wi-Fi的配置信息
   * @returns 检查结果
   */
  static isValidWifiAdvancedConfig(config: wifiManager.WifiDeviceConfig): boolean {
    if (config?.proxyConfig?.proxyMethod === wifiManager.ProxyMethod.METHOD_MANUAL &&
      !WifiUtils.isValidProxyConfig(config?.proxyConfig)) {
      LogUtil.info(`${TAG} check ProxyConfig failed`);
      return false;
    }
    if (!WifiUtils.isValidWifiIpsConfig(config?.ipType, config?.staticIp, config?.staticIpv6)) {
      LogUtil.info(`${TAG} check IpConfig failed`);
      return false;
    }
    return true;
  }

  /**
   * valid wifi proxy configs
   *
   * @param proxyConfig wifi proxy info
   * @returns check result
   */
  static isValidProxyConfig(proxyConfig: wifiManager.WifiProxyConfig): boolean {
    LogUtil.debug(`${TAG} is validProxyConfig`);
    if (proxyConfig.proxyMethod === wifiManager.ProxyMethod.METHOD_NONE) {
      return true;
    }
    if (proxyConfig.proxyMethod === wifiManager.ProxyMethod.METHOD_AUTO) {
      return proxyConfig.pacWebAddress !== undefined && SERVER_HOSTNAME_REGEXP.test(proxyConfig.pacWebAddress);
    }
    if (!proxyConfig.serverHostName || !SERVER_HOSTNAME_REGEXP.test(proxyConfig.serverHostName)) {
      return false;
    }

    if (!proxyConfig.serverPort || proxyConfig.serverPort <= 0 || proxyConfig.serverPort > PROXY_PORT_MAX_VAL) {
      return false;
    }

    if (!EXCLLIST_REGEXP.test(proxyConfig.exclusionObjects as string)) {
      return false;
    }

    return true;
  }

  /**
   * valid wifi eap configs
   *
   * @param eapConfig wifi eap info
   * @returns check result
   */
  static isValidWifiEapConfig(eapConfig: wifiManager.WifiEapConfig | undefined): boolean {
    if (!eapConfig) {
      return false;
    }
    if (eapConfig.eapMethod === wifiManager.EapMethod.EAP_PEAP) {
      if (!WifiUtils.isValidEapPassword(eapConfig.password)) {
        return false;
      }
    }
    if ([
      wifiManager.EapMethod.EAP_PEAP,
      wifiManager.EapMethod.EAP_TLS,
      wifiManager.EapMethod.EAP_TTLS,
    ].includes(eapConfig.eapMethod)) {
      // ca证书必选
      if (typeof eapConfig.caCertAlias === 'string' && !eapConfig.caCertAlias) {
        return false;
      }
      // ca证书 选择了系统证书 必须填写域名
      if (typeof eapConfig.caCertAlias === 'number' &&
        eapConfig.caCertAlias === CaCertificateType.CA_CERTIFICATE_TYPE_SYSTEM && !eapConfig.domainSuffixMatch) {
        return false;
      }
    }
    if (eapConfig.eapMethod === wifiManager.EapMethod.EAP_TLS) {
      // 用户凭据必选
      if (typeof eapConfig.clientCertAlias === 'string' && !eapConfig.clientCertAlias) {
        return false;
      }
    }
    if (eapConfig.eapMethod === wifiManager.EapMethod.EAP_SIM && eapConfig.eapSubId === SIM_SUB_ID_NOT_SET) {
      LogUtil.warn(`${TAG} eapConfig sub id not set`);
      return false;
    }
    return true;
  }

  /**
   * 检查WAPI-PSK配置信息
   *
   * @param WifiDeviceConfig
   * @returns 检查结果
   */
  static isValidWifiWapipskConfig(config: wifiManager.WifiDeviceConfig, capabilities?: string): boolean {
    if (!WifiUtils.isValidPskPassword(config.preSharedKey, capabilities)) {
      return false;
    }
    if (config?.wapiConfig?.wapiPskType === WapiPskType.WAPI_PSK_HEX) {
      const len = config.preSharedKey.length;
      // hex 模式下 密码长度必须是奇数
      if (len % 2 === 0) {
        return false;
      }
    }
    return true;
  }

  /**
   * 检查WAPI-Cert配置信息
   *
   * @param WifiDeviceConfig
   * @returns 检查结果
   */
  static isValidWifiWapiCertConfig(config: wifiManager.WifiDeviceConfig): boolean {
    if (!config?.wapiConfig?.wapiAsCert || !config?.wapiConfig?.wapiUserCert) {
      return false;
    }
    return true;
  }

  static compare(ap1: AccessPoint, ap2: AccessPoint): number {
    if (WifiUtils.isActive(ap1) && !WifiUtils.isActive(ap2)) {
      return AP_COMPARE_LOWER;
    }
    if (!WifiUtils.isActive(ap1) && WifiUtils.isActive(ap2)) {
      return AP_COMPARE_HIGHER;
    }
    if (WifiUtils.isReachable(ap1) && !WifiUtils.isReachable(ap2)) {
      return AP_COMPARE_LOWER;
    }
    if (!WifiUtils.isReachable(ap1) && WifiUtils.isReachable(ap2)) {
      return AP_COMPARE_HIGHER;
    }
    if (WifiUtils.isSaved(ap1) && !WifiUtils.isSaved(ap2)) {
      return AP_COMPARE_LOWER;
    }
    if (!WifiUtils.isSaved(ap1) && WifiUtils.isSaved(ap2)) {
      return AP_COMPARE_HIGHER;
    }
    let levelDiff: number = ap2.bestLevel - ap1.bestLevel;
    if (levelDiff !== AP_COMPARE_NO_DIFF) {
      return levelDiff;
    }
    let rssiDiff: number = ap2.bestRssi - ap1.bestRssi;
    if (rssiDiff !== AP_COMPARE_NO_DIFF) {
      return rssiDiff;
    }
    let securityTypeDiff: number = ap2.securityType - ap1.securityType;
    if (securityTypeDiff !== AP_COMPARE_NO_DIFF) {
      return securityTypeDiff;
    }
    return WifiUtils.getTitle(ap1).localeCompare(WifiUtils.getTitle(ap2));
  }

  static apToMenu(ap: AccessPoint): ApMenu | void {
    if (ap.bestRssi === -Number.MIN_VALUE || ap.securityType === wifiManager.WifiSecurityType.WIFI_SEC_TYPE_INVALID) {
      return;
    }
    if (WifiUtils.isConnected(ap)) {
      return;
    }
    return new ApMenu({
      key: ap.apKey,
      index: ap.lastIndex,
      title: WifiUtils.getTitle(ap),
      summary: WifiUtils.getSummary(ap),
      stateIcon: WifiUtils.getStateIcon(ap),
      timestamp: ap.lastTimestamp,
      ssid: ap.ssid,
      bssid: ap.bestBssid,
      bssidType: ap.bssidType,
      level: ap.bestLevel,
      securityType: ap.securityType,
      capabilities: ap.capabilities,
      config: WifiUtils.getBestConfig(ap) as wifiManager.WifiDeviceConfig,
      supportedWifiCategory: ap.supportedWifiCategory as number,
      isHiLinkNetwork: ap.isHiLinkNetwork as boolean,
    });
  }

  static apListToMenuList(apList: Array<AccessPoint>): Array<ApMenu> {
    LogUtil.info(`${TAG} apListToMenuList start`);
    let menus: ApMenu[] = [];
    for (let index = 0; index < apList.length; index++) {
      let ap: AccessPoint = apList[index];
      ap.lastIndex = index;
      ap.lastTimestamp = 0;
      if (ap.bestRssi === -Number.MIN_VALUE || ap.securityType === wifiManager.WifiSecurityType.WIFI_SEC_TYPE_INVALID ||
        WifiUtils.isConnected(ap)) {
        continue;
      }
      let apMenu: ApMenu = WifiUtils.apToMenu(ap) as ApMenu;
      if (apMenu) {
        menus.push(apMenu);
      }
    }
    LogUtil.info(`${TAG} apListToMenuList end`);
    return menus;
  }

  static getScanResults(scanInfos: Array<wifiManager.WifiScanInfo>): Array<WifiScanResult> {
    let wifiScanResults: WifiScanResult[] = [];
    if (!scanInfos) {
      LogUtil.error(`${TAG} invalid scan info, please check`);
      return wifiScanResults;
    }
    LogUtil.info(`${TAG} scanInfos.length: ${scanInfos.length}`);
    for (let info of scanInfos) {
      LogUtil.info(`${TAG} getScanResults ssid: ${WifiUtils.getLogSsidString(info.ssid)}, rssi: ${info.rssi}, securityType: ${info.securityType}`);
      wifiScanResults.push(new WifiScanResult(info));
    }
    return wifiScanResults;
  }

  static isSupportQrcodeShare(securityType: wifiManager.WifiSecurityType): boolean {
    LogUtil.info(`${TAG} judge isSupportQrcodeShare, current securityType is: ${securityType}`);
    return securityType !== WifiSecurityType.WIFI_SEC_TYPE_EAP && securityType !== WifiSecurityType.WIFI_SEC_TYPE_EAP_SUITE_B
      && securityType !== WifiSecurityType.WIFI_SEC_TYPE_WAPI_CERT && securityType !== WifiSecurityType.WIFI_SEC_TYPE_WAPI_PSK;
  }

  static getScanResultsMap(cache: Map<string, WifiScanResult>): Map<string, Array<WifiScanResult>> {
    LogUtil.info(`${TAG} getScanResultsMap start`);
    let scanResultsMap: Map<string, Array<WifiScanResult>> = new Map<string, Array<WifiScanResult>>();
    for (let item of Array.from(cache.values())) {
      let apKey: string = WifiUtils.getApKeyWithScanResult(item as WifiScanResult) as string;
      let results: WifiScanResult[] = scanResultsMap.get(apKey) as Array<WifiScanResult>;
      if (!results) {
        results = [];
        scanResultsMap.set(apKey, results);
      }
      results.push(item as WifiScanResult);
    }
    LogUtil.info(`${TAG} getScanResultsMap end, scanResultsMap size: ${scanResultsMap.size}`);
    return scanResultsMap;
  }

  static getConfigMap(): Map<string, Array<wifiManager.WifiDeviceConfig>> {
    LogUtil.info(`${TAG} getConfigMap start`);
    let configMap: Map<string, Array<wifiManager.WifiDeviceConfig>> =
    new Map<string, Array<wifiManager.WifiDeviceConfig>>();
    try {
      let configs: wifiManager.WifiDeviceConfig[] = wifiManager.getDeviceConfigs();
      for (let config of configs) {
        let key: string = WifiUtils.getApKeyWithConfig(config) as string;
        let configList = configMap.get(key) as Array<wifiManager.WifiDeviceConfig>;
        if (!configList) {
          configList = [];
        }
        configList.push(config);
        configMap.set(key, configList);
      }
    } catch (error) {
      LogUtil.error(`${TAG} get device configs error: ${error?.message}`);
    }
    LogUtil.info(`${TAG} getConfigMap end`);
    return configMap;
  }

  static getCachedOrCreateAp(scanResults: Array<WifiScanResult>, apCache: Map<string, AccessPoint>): AccessPoint {
    let resultApKey: string = WifiUtils.getApKeyWithScanResult(scanResults[0]) as string;
    let ap = apCache.get(resultApKey) as AccessPoint;
    if (!ap) {
      ap = new AccessPoint(scanResults);
      apCache.set(resultApKey, ap);
    } else {
      ap = WifiUtils.setScanResults(scanResults, ap);
    }
    return ap;
  }

  static setScanResults(newResult: Array<WifiScanResult>, ap: AccessPoint): AccessPoint {
    if (!newResult || newResult.length === 0) {
      return ap;
    }
    if (ap.apKey) {
      for (let result of newResult) {
        if (!WifiUtils.isScanResultMatches(result, ap)) {
          LogUtil.info(`${TAG} result ${WifiUtils.getLogSsidString(result?.ssid)}
            not match ${WifiUtils.getLogSsidString(ap.ssid)}`);
          return ap;
        }
      }
    }
    ap.scanResults = Array<WifiScanResult>().concat(newResult);
    ap = WifiUtils.updateFromNewScanResults(ap);
    if (!ap.apKey) {
      ap.apKey = WifiUtils.getApKey(ap.ssid, ap.bestBssid, ap.securityType) as string;
    }
    return ap;
  }

  static isScanResultMatches(result: WifiScanResult, ap: AccessPoint): boolean {
    if (!result) {
      return false;
    }
    return ap.ssid === result.ssid && ap.securityType === result.securityType;
  }

  static equalSignal(signalA: number, signalB: number): boolean {
    return Math.abs(signalA - signalB) < MARGIN_RSSI;
  }

  static updateFromNewScanResults(ap: AccessPoint): AccessPoint {
    if (!ap.scanResults || ap.scanResults.length === 0) {
      return ap;
    }

    let bestResult: WifiScanResult = ap.scanResults[0];
    for (let result of ap.scanResults) {
      if (result.rssi > bestResult.rssi) {
        bestResult = result;
      }
    }

    let bestRssi: number = bestResult.rssi;
    if (bestRssi !== -Number.MIN_VALUE && ap.bestRssi !== -Number.MIN_VALUE) {
      bestRssi = Math.round((ap.bestRssi + bestRssi) / 2);
    }
    //only update signal when not 'equal' with margin.
    if (!WifiUtils.equalSignal(ap.bestRssi, bestRssi)) {
      ap.bestRssi = bestRssi;
      ap.bestBand = bestResult.band as number;
      ap.ssid = bestResult.ssid;
      ap.bestBssid = bestResult.bssid;
      ap.bssidType = bestResult.bssidType as number;
      ap.securityType = bestResult.securityType as number;
      ap.capabilities = bestResult.capabilities as string;
      //using local call within thread instead of remote call.
      try {
        let newLevel: number = wifiManager.getSignalLevel(ap.bestRssi, ap.bestBand);
        ap.bestLevel = newLevel;
      } catch (error) {
        LogUtil.error(`${TAG} get signal level error: ${error?.message}`);
      }
    }
    return ap;
  }

  static isConfigMatches(config: wifiManager.WifiDeviceConfig, ap: AccessPoint): boolean {
    if (!config) {
      return false;
    }
    if (!ap.apKey) {
      return true;
    }
    if (ap.ssid !== config.ssid || ap.securityType !== config.securityType) {
      return false;
    }
    return true;
  }

  static setConfigs(newConfigs: Array<wifiManager.WifiDeviceConfig>, ap: AccessPoint): AccessPoint {
    if (!newConfigs || newConfigs.length === 0) {
      ap.configs = null;
      return ap;
    }
    if (ap.apKey) {
      for (let config of newConfigs) {
        if (!WifiUtils.isConfigMatches(config, ap)) {
          LogUtil.info(`${TAG} config ${WifiUtils.getLogSsidString(config?.ssid)} not match ${WifiUtils
            .getLogSsidString(ap.ssid)}`);
          return ap;
        }
      }
    }
    ap.configs = Array<wifiManager.WifiDeviceConfig>().concat(newConfigs);
    if (!ap.configs || ap.configs.length === 0 || !ap.configs[0]) {
      return ap;
    }

    if (!ap.securityType) {
      ap.securityType = ap.configs[0].securityType;
    }

    if (!ap.ssid) {
      ap.ssid = ap.configs[0].ssid;
    }

    if (!ap.bestBssid) {
      ap.bestBssid = ap.configs[0].bssid as string;
    }

    if (!ap.bssidType) {
      ap.bssidType = ap.configs[0].bssidType as number;
    }

    if (!ap.apKey) {
      ap.apKey = WifiUtils.getApKey(ap.ssid, ap.bestBssid, ap.securityType) as string;
    }
    return ap;
  }

  static updateLastLinkedInfo(linkedInfo: wifiManager.WifiLinkedInfo, ap: AccessPoint): AccessPoint {
    if (linkedInfo && WifiUtils.isLinkedInfoForMe(linkedInfo, ap)) {
      ap.lastLinkedInfo = linkedInfo;
    } else {
      ap.lastLinkedInfo = null;
      return ap;
    }

    if (ap.scanResults && ap.scanResults.length > 0) {
      return ap;
    }

    if (!WifiUtils.equalSignal(ap.bestRssi, ap.lastLinkedInfo.rssi)) {
      ap.bestRssi = ap.lastLinkedInfo.rssi;
      ap.bestBand = ap.lastLinkedInfo.band;
      ap.ssid = ap.lastLinkedInfo.ssid;
      ap.bestBssid = ap.lastLinkedInfo.bssid;
      try {
        let newLevel: number = wifiManager.getSignalLevel(ap.bestRssi, ap.bestBand);
        ap.bestLevel = newLevel;
      } catch (error) {
        LogUtil.error(`${TAG} get signal level error: ${error?.message}`);
      }
    }

    if (!ap.apKey) {
      ap.apKey = WifiUtils.getApKey(ap.ssid, ap.bestBssid, ap.securityType) as string;
    }
    return ap;
  }

  static isLinkedInfoForMe(linkedInfo: wifiManager.WifiLinkedInfo, ap: AccessPoint): boolean {
    if (ap.configs) {
      for (let config of Array.from(ap.configs)) {
        if (config.netId === linkedInfo.networkId) {
          return true;
        }
      }
      return false;
    } else {
      if ((!ap.scanResults || ap.scanResults.length <= 0) && !ap.ssid) {
        return true;
      }
      return ap.ssid === linkedInfo.ssid;
    }
  }

  static getTitle(ap: AccessPoint): string {
    return ap.ssid ?? '';
  }

  static isOpen(ap: AccessPoint): boolean {
    return ap.securityType === wifiManager.WifiSecurityType.WIFI_SEC_TYPE_OPEN;
  }

  static isOpenAutoConnect(ap: AccessPoint): boolean {
    if (!ap) {
      return false;
    }
    return ap.isAutoConnectAllowed;
  }

  static getSummary(ap: AccessPoint): ResourceStr {
    LogUtil.debug(`${TAG} getSummary connState: ${ap?.lastLinkedInfo?.connState}, isActive: ${WifiUtils.isActive(ap)}`);
    if (WifiUtils.isActive(ap)) {
      if (ap.lastLinkedInfo && ap.lastLinkedInfo.connState >= 0 && ap.lastLinkedInfo.connState < AP_STATES.length) {
        return AP_STATES[ap.lastLinkedInfo.connState];
      }
    }
    if (WifiUtils.isSaved(ap)) {
      return WifiUtils.isOpenAutoConnect(ap) ?
        (WifiUtils.isOpen(ap) ? $r('app.string.wifi_status_saved') : $r('app.string.wifi_status_saved_encrypted')) :
        $r('app.string.is_close_auto_reconnect');
    } else {
      return WifiUtils.isOpen(ap) ? $r('app.string.wifi_status_security_open') : $r('app.string.wifi_status_encrypted');
    }
  }

  static getConnectedSummary(isPortalUnauthenticated: boolean, isUnsecuredWifi?: boolean): ResourceStr {
    if (isUnsecuredWifi && !isPortalUnauthenticated) {
      return $r('app.string.unsecure_wifi_status_connected');
    }
    return isPortalUnauthenticated ? $r('app.string.wifi_status_connected_unauthorized') :
    $r('app.string.wifi_status_connected');
  }

  static getNetworkUnavailableStateIcon(ap: AccessPoint): ResourceStr {
    if (CheckEmptyUtils.isEmpty(ap)) {
      LogUtil.info(`${TAG} invalid ap param to get unavailable state icon.`);
      return $r('app.media.ic_wlan_error');
    }

    switch (ap.supportedWifiCategory) {
      case WifiCategory.WIFI_CATEGORY_WIFI6:
        return AP_WIFI6_ERROR_SIGNAL_ICONS[ap.bestLevel];
      case WifiCategory.WIFI_CATEGORY_WIFI6_PLUS:
        return AP_WIFI6_PLUS_ERROR_SIGNAL_ICONS[ap.bestLevel];
      case WifiCategory.WIFI_CATEGORY_WIFI7:
        return AP_WIFI7_ERROR_SIGNAL_ICONS[ap.bestLevel];
      case WifiCategory.WIFI_CATEGORY_WIFI7_PLUS:
        return AP_WIFI7_PLUS_ERROR_SIGNAL_ICONS[ap.bestLevel];
      case WifiCategory.WIFI_CATEGORY_DEFAULT:
        return AP_WIFI_ERROR_SIGNAL_ICONS[ap.bestLevel];
      default:
        return $r('app.media.ic_wlan_error');
    }
  }

  static getStateIcon(ap: AccessPoint): ResourceStr | undefined {
    if (!ap) {
      LogUtil.info(`${TAG} invalid ap param to get state icon.`);
      return undefined;
    }

    return WifiUtils.getDetailStateIcon(ap.bestLevel, WifiUtils.isOpen(ap), ap.supportedWifiCategory);
  }

  static getDetailStateIcon(bestLevel: number, isOpen: boolean, supportedWifiCategory: number):
    ResourceStr | undefined {
    if (bestLevel >= AP_SIGNAL_LOCK_ICONS.length || bestLevel < 0) {
      LogUtil.info(`${TAG} invalid level param to get state icon: ${bestLevel}`);
      return undefined;
    }
    switch (supportedWifiCategory) {
      case WifiCategory.WIFI_CATEGORY_WIFI6:
        return isOpen ? AP_WIFI6_SIGNAL_ICONS[bestLevel] : AP_WIFI6_SIGNAL_LOCK_ICONS[bestLevel];
      case WifiCategory.WIFI_CATEGORY_WIFI6_PLUS:
        return isOpen ? AP_WIFI6_PLUS_SIGNAL_ICONS[bestLevel] : AP_WIFI6_PLUS_SIGNAL_LOCK_ICONS[bestLevel];
      case WifiCategory.WIFI_CATEGORY_WIFI7:
        return isOpen ? AP_WIFI7_SIGNAL_ICONS[bestLevel] : AP_WIFI7_SIGNAL_LOCK_ICONS[bestLevel];
      case WifiCategory.WIFI_CATEGORY_WIFI7_PLUS:
        return isOpen ? AP_WIFI7_PLUS_SIGNAL_ICONS[bestLevel] : AP_WIFI7_PLUS_SIGNAL_LOCK_ICONS[bestLevel];
      default:
        return isOpen ? AP_SIGNAL_ICONS[bestLevel] : AP_SIGNAL_LOCK_ICONS[bestLevel];
    }
  }

  static getIconReadText(isNetworkUnavailable: boolean, bestLevel: number, isConnected: boolean,
    supportedWifiCategory: number, securityType: number): ResourceStr {
    if(isNetworkUnavailable) {
      return $r('app.string.ic_wlan_error');
    }
    switch (supportedWifiCategory) {
      case WifiCategory.WIFI_CATEGORY_WIFI6:
        if (bestLevel === FULL_SIGNAL_LEVEL) {
          return WifiUtils.isAvailableNetworks(isConnected, securityType) ?
            ResourceUtil.getNumberFormatStringSync(AP_WIFI6_SIGNAL_ICONS_TEXT[bestLevel] as Resource, WIFI_SIX_FLAG_NUM.toString()) :
            ResourceUtil.getNumberFormatStringSync(AP_WIFI6_SIGNAL_LOCK_ICONS_TEXT[bestLevel] as Resource, WIFI_SIX_FLAG_NUM.toString());
        } else {
          return WifiUtils.isAvailableNetworks(isConnected, securityType) ?
            ResourceUtil.getAnyNumFormatStringSync(AP_WIFI6_SIGNAL_ICONS_TEXT[bestLevel] as Resource, WIFI_SIX_FLAG_NUM, bestLevel) :
            ResourceUtil.getAnyNumFormatStringSync(AP_WIFI6_SIGNAL_LOCK_ICONS_TEXT[bestLevel] as Resource, WIFI_SIX_FLAG_NUM, bestLevel);
        }
      case WifiCategory.WIFI_CATEGORY_WIFI6_PLUS:
        if (bestLevel === FULL_SIGNAL_LEVEL) {
          return WifiUtils.isAvailableNetworks(isConnected, securityType) ?
            ResourceUtil.getNumberFormatStringSync(AP_WIFI6_PLUS_SIGNAL_ICONS_TEXT[bestLevel] as Resource, WIFI_SIX_FLAG_NUM.toString()) :
            ResourceUtil.getNumberFormatStringSync(AP_WIFI6_PLUS_SIGNAL_LOCK_ICONS_TEXT[bestLevel] as Resource, WIFI_SIX_FLAG_NUM.toString());
        } else {
          return WifiUtils.isAvailableNetworks(isConnected, securityType) ?
            ResourceUtil.getAnyNumFormatStringSync(AP_WIFI6_PLUS_SIGNAL_ICONS_TEXT[bestLevel] as Resource, WIFI_SIX_FLAG_NUM, bestLevel) :
            ResourceUtil.getAnyNumFormatStringSync(AP_WIFI6_PLUS_SIGNAL_LOCK_ICONS_TEXT[bestLevel] as Resource, WIFI_SIX_FLAG_NUM, bestLevel);
        }
      case WifiCategory.WIFI_CATEGORY_WIFI7:
        if (bestLevel === FULL_SIGNAL_LEVEL) {
          return WifiUtils.isAvailableNetworks(isConnected, securityType) ?
            ResourceUtil.getNumberFormatStringSync(AP_WIFI7_SIGNAL_ICONS_TEXT[bestLevel] as Resource, WIFI_SEVEN_FLAG_NUM.toString()) :
            ResourceUtil.getNumberFormatStringSync(AP_WIFI7_SIGNAL_LOCK_ICONS_TEXT[bestLevel] as Resource, WIFI_SEVEN_FLAG_NUM.toString());
        } else {
          return WifiUtils.isAvailableNetworks(isConnected, securityType) ?
            ResourceUtil.getAnyNumFormatStringSync(AP_WIFI7_SIGNAL_ICONS_TEXT[bestLevel] as Resource, WIFI_SEVEN_FLAG_NUM, bestLevel) :
            ResourceUtil.getAnyNumFormatStringSync(AP_WIFI7_SIGNAL_LOCK_ICONS_TEXT[bestLevel] as Resource, WIFI_SEVEN_FLAG_NUM, bestLevel);
        }
      case WifiCategory.WIFI_CATEGORY_WIFI7_PLUS:
        if (bestLevel === FULL_SIGNAL_LEVEL) {
          return WifiUtils.isAvailableNetworks(isConnected, securityType) ?
            ResourceUtil.getNumberFormatStringSync(AP_WIFI7_PLUS_SIGNAL_ICONS_TEXT[bestLevel] as Resource, WIFI_SEVEN_FLAG_NUM.toString()) :
            ResourceUtil.getNumberFormatStringSync(AP_WIFI7_PLUS_SIGNAL_LOCK_ICONS_TEXT[bestLevel] as Resource, WIFI_SEVEN_FLAG_NUM.toString());
        } else {
          return WifiUtils.isAvailableNetworks(isConnected, securityType) ?
          ResourceUtil.getAnyNumFormatStringSync(AP_WIFI7_PLUS_SIGNAL_ICONS_TEXT[bestLevel] as Resource, WIFI_SEVEN_FLAG_NUM, bestLevel) :
          ResourceUtil.getAnyNumFormatStringSync(AP_WIFI7_PLUS_SIGNAL_LOCK_ICONS_TEXT[bestLevel] as Resource, WIFI_SEVEN_FLAG_NUM, bestLevel);
        }
      default:
        if (bestLevel === FULL_SIGNAL_LEVEL) {
          return WifiUtils.isAvailableNetworks(isConnected, securityType) ?
            ResourceUtil.getAnyNumFormatStringSync(AP_SIGNAL_ICONS_TEXT[bestLevel] as Resource) :
            ResourceUtil.getAnyNumFormatStringSync(AP_SIGNAL_LOCK_ICONS_TEXT[bestLevel] as Resource);
        } else {
          return WifiUtils.isAvailableNetworks(isConnected, securityType) ?
            ResourceUtil.getNumberFormatStringSync(AP_SIGNAL_ICONS_TEXT[bestLevel] as Resource, bestLevel.toString()) :
            ResourceUtil.getNumberFormatStringSync(AP_SIGNAL_LOCK_ICONS_TEXT[bestLevel] as Resource, bestLevel.toString());
        }
    }
  }

  static isAvailableNetworks(isConnected: boolean, securityType: number): boolean {
    return securityType === wifiManager.WifiSecurityType.WIFI_SEC_TYPE_OPEN || isConnected;
  }

  static getBestConfig(ap: AccessPoint): wifiManager.WifiDeviceConfig | wifiManager.WifiDeviceConfig | null {
    if (!ap.configs || ap.configs.length === 0) {
      return null;
    }
    for (let config of Array.from(ap.configs)) {
      if (ap.bestBssid === config.bssid) {
        return config;
      }
    }
    return ap.configs[0];
  }

  static isHidden(ap: AccessPoint): boolean {
    if (ap.lastLinkedInfo !== null) {
      return ap.lastLinkedInfo?.isHidden ?? false;
    }

    if (ap.configs && ap.configs.length > 0) {
      for (let config of ap.configs) {
        if (!config.isHiddenSsid) {
          return false;
        }
      }
      return true;
    }
    return false;
  }

  static isConnected(ap: AccessPoint): boolean {
    return WifiUtils.isActive(ap) && (ap.lastLinkedInfo?.connState === WIFI_STATE_CONNECTED);
  }

  static isActive(ap: AccessPoint): boolean {
    return ap.lastLinkedInfo !== null &&
      (WifiUtils.isValidNetworkId(ap.lastLinkedInfo?.networkId as number) ||
        ap.lastLinkedInfo?.connState !== WIFI_STATE_DISCONNECTED);
  }

  static isReachable(ap: AccessPoint): boolean {
    return ap.bestRssi !== -Number.MIN_VALUE;
  }

  static isSaved(ap: AccessPoint): boolean {
    return (ap.configs && ap.configs.length > 0) ? true : false;
  }

  /**
   * is wifi connected
   *
   * @returns true if wifi is connected
   */
  public static isWifiConnected(): boolean {
    let isWifiConnected: boolean = false;
    try {
      isWifiConnected = wifiManager.isConnected();
      LogUtil.info(`${TAG} isWifiConnected : ${isWifiConnected}`);
    } catch (error) {
      LogUtil.error(`${TAG} is connected error: ${error?.message}`);
    }
    return isWifiConnected;
  }

  /**
   * valid wifi ip configs
   *
   * @param ipType ip type
   * @param ipConfig ip config info
   * @returns check result
   */
  static isValidWifiIpConfig(ipType: wifiManager.IpType | undefined, ipConfig: wifiManager.IpConfig | undefined):
    boolean {
    if (ipType !== wifiManager.IpType.STATIC) {
      return true;
    }

    if (!ipConfig) {
      return true;
    }

    if (!ipConfig.ipAddress || !ipConfig.gateway || !ipConfig.prefixLength) {
      return false;
    }
    if (ipConfig.prefixLength) {
      if (Number(ipConfig.prefixLength) < 1 || Number(ipConfig.prefixLength) > 32) {
        return false;
      }
    }
    if (!ipConfig.dnsServers || ipConfig.dnsServers.length === 0) {
      return false;
    }

    if (!ipConfig.dnsServers[0]) {
      return false;
    }

    if (ipConfig.dnsServers.length === 2 && !ipConfig.dnsServers[1]) {
      return false;
    }

    return true;
  }

  /**
   * ip有效性校验
   *
   * @param ipType
   * @param ipConfig
   * @param ipv6Config
   * @returns
   */
  static isValidWifiIpsConfig(ipType: wifiManager.IpType | undefined, ipConfig: wifiManager.IpConfig | undefined,
    ipv6Config: wifiManager.Ipv6Config | undefined):
    boolean {
    let isIpv6ConfigValid: boolean =
      WifiUtils.isValidWifiIpv6Config(ipType, ipv6Config);
    let isIpv4ConfigValid: boolean =
      WifiUtils.isValidWifiIpConfig(ipType, ipConfig);
    return isIpv6ConfigValid || isIpv4ConfigValid
  }

  /**
   * valid wifi ip configs
   *
   * @param ipType ip type
   * @param ipConfig ip config info
   * @returns check result
   */
  static isValidWifiIpv6Config(ipType: wifiManager.IpType | undefined, ipv6Config: wifiManager.Ipv6Config | undefined):
    boolean {
    if (ipType !== wifiManager.IpType.STATIC) {
      return true;
    }
    if (!ipv6Config) {
      return true;
    }
    if (!ipv6Config.ipAddress || !ipv6Config.gateway || !ipv6Config.prefixLength) {
      return false;
    }
    if (!ipv6Config.ipAddress || !ipv6Config.gateway || !ipv6Config.prefixLength) {
      return false;
    }
    if (ipv6Config.prefixLength) {
      if (Number(ipv6Config.prefixLength) < 1 || Number(ipv6Config.prefixLength) > 128) {
        return false;
      }
    }
    if (!ipv6Config.dnsServers || ipv6Config.dnsServers.length === 0) {
      return false;
    }
    if (!ipv6Config.dnsServers[0]) {
      return false;
    }
    if (ipv6Config.dnsServers.length === 2 && !ipv6Config.dnsServers[1]) {
      return false;
    }
    return true;
  }

  static getDisconnectedReason(): number {
    try {
      let disconnectedReason: number = wifiManager.getDisconnectedReason();
      LogUtil.info(`${TAG} wifiManager.getDisconnectedReason：${disconnectedReason}`);
      return disconnectedReason;
    } catch (err) {
      LogUtil.error(`failed: code: ${err.code} message: ${err.message}`);
      return 0;
    }
  }

  /**
   * 获取用户安装得CA证书
   */
  static async getAllUserTrustedCertificates(): Promise<certManager.CertAbstract[]> {
    LogUtil.info(`${TAG} certManager.getAllUserTrustedCertificates`);
    try {
      const cmResult = await certManager.getAllUserTrustedCertificates();
      return cmResult?.certList || [];
    } catch (error) {
      LogUtil.error(`${TAG} failed getAllUserTrustedCertificates code:${error?.code} message:${error?.message}`);
    }
    return []
  }

  /**
   * 获取用户安装得用户凭据
   */
  static async getAllSystemAppCertificates(): Promise<certManager.CredentialAbstract[]> {
    LogUtil.info(`${TAG} certManager.getAllSystemAppCertificates`);
    try {
      const cmResult = await certManager.getAllSystemAppCertificates();
      return cmResult?.credentialList || [];
    } catch (error) {
      LogUtil.error(`${TAG} failed getAllSystemAppCertificates code:${error?.code} message:${error?.message}`);
    }
    return []
  }

  /**
   * 更新内存中wlan开关状态
   *
   * @param state 新的wlan状态
   */
  static updateWifiStateInStorage(state: boolean): void {
    let detailState: number = WifiUtils.getDetailState();
    let currentWifiStateIsOn: boolean | undefined = AppStorage.get<boolean>('WifiStateIsOn');
    LogUtil.info(`${TAG} setWifiState wifiActive state: ${state}, detailState: ${detailState}, currentWifiStateIsOn: ${currentWifiStateIsOn}`);
    if (state && (currentWifiStateIsOn === false)) {
      // 更新状态由inactive到active时，需要判断不处于中间关闭态
      if (detailState !== WifiState.DEACTIVATING && detailState !== WifiState.SEMIACTIVATING) {
        AppStorage.setOrCreate('WifiStateIsOn', true);
      }
    } else if (!state && currentWifiStateIsOn) {
      // 更新状态由active到inactive时，需要判断不处于中间开启态
      if (detailState !== WifiState.ACTIVATING) {
        AppStorage.setOrCreate('WifiStateIsOn', false);
      }
    } else {
      AppStorage.setOrCreate('WifiStateIsOn', state);
    }
  }

  /**
   * 扫描开关开启或关闭状态
   *
   * @returns 返回WLAN扫描开关开启或关闭状态
   */
  static getScanAlwaysAllowed(): boolean {
    try {
      let state = wifiManager.getScanAlwaysAllowed();
      LogUtil.info(`${TAG} getScanAlwaysAllowed: ${state}`);
      return state;
    } catch (error) {
      LogUtil.error(`${TAG} getScanAlwaysAllowed failed, ${error?.message}`);
    }
    return false;
  }

  /**
   * 开启或关闭扫描开关闭
   *
   * @param isAllowedScan true表示开启扫描开关 false表示关闭扫描开关
   */
  static setScanAlwaysAllowed(isAllowedScan: boolean): void {
    try {
      LogUtil.info(`${TAG} setScanAlwaysAllowed: ${isAllowedScan}`);
      wifiManager.setScanAlwaysAllowed(isAllowedScan);
    } catch (error) {
      LogUtil.error(`${TAG} setScanAlwaysAllowed failed, ${error?.message}`);
    }
  }

  /**
   * 获取连接WLAN的信息
   *
   * @returns 连接WLAN的信息
   */
  static async getLinkedInfo(): Promise<wifiManager.WifiLinkedInfo | undefined> {
    try {
      let wifiLinkedInfo = await wifiManager.getLinkedInfo();
      LogUtil.info(`${TAG} wifiLinkedInfo macAddress: ${WifiUtils.getLogMAC(wifiLinkedInfo?.macAddress)}`);
      return wifiLinkedInfo;
    } catch (error) {
      LogUtil.error(`${TAG} getLinkedInfo failed, ${error?.message}`);
    }
    return undefined;
  }

  /**
   * 判断是否是普通网络
   *
   * @param securityType 安全类型
   * @returns 判断是否是普通网络
   */
  static isNormalWlan(securityType: number): boolean {
    let isNormalWlan: boolean = !EAP_WAPI_ARRAY.includes(securityType);
    LogUtil.info(`${TAG} isNormalWlan: ${isNormalWlan}`);
    return isNormalWlan;
  }

  /**
   * 连接网络前，对config进行清理，仅保留有效数据
   *
   * @param config 入参config
   * @returns 仅保留有效数据config
   */
  static clearUseLessParam(config: wifiManager.WifiDeviceConfig): wifiManager.WifiDeviceConfig {
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
   * 判断是否需要弹出连接失败弹窗
   *
   * @returns true 表示需要弹 false 表示不需要
   */
  static needShowConnectFailedDialog(connectConfig: wifiManager.WifiDeviceConfig | null): boolean {
    try {
      if (connectConfig === null) {
        LogUtil.error(`${TAG} needShowConnectFailedDialog error, connectConfig is null.`);
        return false;
      }
      let configs: wifiManager.WifiDeviceConfig[] = wifiManager.getDeviceConfigs();
      let config: wifiManager.WifiDeviceConfig | undefined = configs.find((item) =>
        item.ssid === connectConfig?.ssid && item.securityType === connectConfig?.securityType);
      LogUtil.info(`${TAG} needShowConnectFailedDialog,\
        bssid: ${WifiUtils.getLogSsidString(config?.ssid)}, configStatus: ${config?.configStatus}`);
      // 对于新网络（未保存的网络），也返回true
      if (!config) {
        return true; // 新网络连接失败时也显示错误提示
      }
      if (!config?.configStatus) {
        LogUtil.warn(`${TAG} needShowConnectFailedDialog configStatus is null`);
        return false;
      }
      return config?.configStatus !== 0;
    } catch (error) {
      LogUtil.error(`${TAG} needShowConnectFailedDialog failed, ${error?.message}`);
    }
    return false;
  }

  /**
   * wlan连接失败后，短距侧是否会继续尝试重连
   *
   * @returns true 表示会重连
   */
  static willReconnect(connectConfig: wifiManager.WifiDeviceConfig | null): boolean {
    try {
      if (!connectConfig) {
        LogUtil.error(`${TAG} willReconnect error, connectConfig is null.`);
        return false;
      }
      if (!WifiUtils.isWifiActive()) {
        return false;
      }
      let configs: wifiManager.WifiDeviceConfig[] = wifiManager.getDeviceConfigs();
      let config: wifiManager.WifiDeviceConfig | undefined = configs.find((item) =>
        item.ssid === connectConfig?.ssid && item.securityType === connectConfig?.securityType);
      LogUtil.info(`${TAG} willReconnect, bssid: ${WifiUtils.getLogSsidString(config?.ssid)}, configStatus: ${config?.configStatus}`);
      // 等于0 表示会继续重连
      return config?.configStatus === 0;
    } catch (error) {
      LogUtil.error(`${TAG} willReconnect failed, ${error?.message}`);
    }
    return false;
  }

  static reconnectWithNewConfig(tag: string, wifiConfig: wifiManager.WifiDeviceConfig): void {
    try {
      if (wifiManager.isConnected()) {
        LogUtil.info(`${tag} updateNetwork start: ${wifiConfig?.netId}`);
        WifiUtils.disconnect();
        let netId = wifiManager.updateNetwork(wifiConfig);
        wifiManager.connectToNetwork(netId);
        LogUtil.info(`${tag} updateNetwork end, netId: ${netId}`);
      }
    } catch (error) {
      LogUtil.error(`${tag} updateNetwork error, code:${error?.code}, message:${error?.message}`);
    }
  }

  static updateNetwork(wifiConfig: wifiManager.WifiDeviceConfig): number {
    LogUtil.info(`${TAG} start updateNetwork, ssid: ${WifiUtils.getLogSsidString(wifiConfig.ssid)}`);
    try {
      let netWorkId: number = wifiManager.updateNetwork(wifiConfig);
      LogUtil.info(`${TAG} updateNetwork success, netWorkId is ${netWorkId}`);
      return netWorkId;
    } catch (error) {
      LogUtil.error(`${TAG} updateNetwork failed: code is ${error?.code}, message:${error?.message}`);
    }
    return INVALID_NETWORK_ID;
  }

  /**
   * 是否存在Ethernet以太网网络
   *
   * @param bearerTypes 网络类型
   * @returns true, 当前存在以太网网络
   */
  static isBearerEthernet(bearerTypes?: Array<connection.NetBearType>): boolean {
    return (bearerTypes?.length === NETWORK_CAPABILITY_LENGTH)
      && (bearerTypes[0] === connection.NetBearType.BEARER_ETHERNET);
  }

  /**
   * 有线网络是否可用
   *
   * @param caps 网络能力
   * @returns true, 网络可用
   */
  static isEthernetNetworkValidated(caps?: Array<connection.NetCap>): boolean {
    // 首次插入网线会触发探测，"networkCap":[12,15,16,31] 16为网络可用，31为触发探测，在探测过程会同时上报16，只有当存在16没有31的场景才能保证有网
    let networkValidated: boolean =
      (caps?.includes(NET_CAPABILITY_VALIDATED) as boolean) && !(caps?.includes(NET_CAPABILITY_DETECTION) as boolean);
    return networkValidated;
  }

  /**
   * 快速返回32位数字hash算法
   *
   * @param str
   * @returns 0 or hash
   */
  public static hashCode32(str: string | undefined): number {
    let hash: number = 0;
    if (str === undefined) {
      return hash;
    }
    for (let i = 0; i < str.length; i++) {
      let chr = str.charCodeAt(i);
      hash = (hash << 5) - hash + chr;
      // Convert to 32bit integer
      hash |= 0;
    }
    return hash;
  }

  public static getWifiConfig(apMenu: ApMenu): wifiManager.WifiDeviceConfig {
    if (apMenu.config) {
      return apMenu.config as wifiManager.WifiDeviceConfig;
    }
    return {
      ssid: apMenu.ssid,
      bssid: apMenu.bssid,
      bssidType: apMenu.bssidType,
      preSharedKey: '',
      securityType: apMenu.securityType,
      randomMacType: wifiManager.DeviceAddressType.RANDOM_DEVICE_ADDRESS,
      isHiddenSsid: false,
    };
  }

  /**
   * 判断是否是不安全网络
   *
   * @param securityType 安全类型
   * @param capabilities 网络安全数组
   * @param ssid 网络名称
   * @returns true, 该网络为不安全网络
   */
  static isUnsafeNetwork(securityType: number, capabilities: string, ssid: string): boolean {
    LogUtil.info(`${TAG} isUnsafeNetwork：${WifiUtils.getApLogKey(ssid, securityType)}, capabilities: ${capabilities}`);
    if (securityType === WifiSecurityType.WIFI_SEC_TYPE_WEP) {
      LogUtil.info(`${TAG} isUnsafeNetwork,securityType is WEP.`);
      return true;
    }
    if (securityType === WifiSecurityType.WIFI_SEC_TYPE_OPEN && !capabilities.includes('[OWE-TRANS-OPEN]')) {
      LogUtil.info(`${TAG} isUnsafeNetwork,securityType is OPEN.`);
      return true;
    }
    if (securityType === WifiSecurityType.WIFI_SEC_TYPE_PSK && capabilities.includes('TKIP') &&
      !capabilities.includes('CCMP')) {
      LogUtil.info(`${TAG} isUnsafeNetwork,securityType is PSK.`);
      return true;
    }
    return false;
  }

  /**
   * 获取不安全网络类型，用于打点
   *
   * @param securityType 安全类型
   * @param capabilities 网络安全数组
   * @returns 不安全网络类型
   */
  static getUnsafeNetworkType(securityType: number, capabilities: string): string {
    if (securityType === WifiSecurityType.WIFI_SEC_TYPE_WEP) {
      return 'WEP';
    }
    if (securityType === WifiSecurityType.WIFI_SEC_TYPE_OPEN && !capabilities?.includes('[OWE-TRANS-OPEN]')) {
      return 'OPEN';
    }
    if (securityType === WifiSecurityType.WIFI_SEC_TYPE_PSK && capabilities?.includes('TKIP')) {
      return capabilities.includes('CCM') ? 'WPA+WPA2' : 'WPA';
    }
    return 'OTHERS';
  }

  /**
   * 进入wifi界面发送广播,包括设置wifi界面、控制中心wifi界面(不涉及pc)
   *
   * @param isWlanPage 是否在wifi页面
   */
  static publishEnterWlanPageEvent(isWlanPage?: boolean): void {
    LogUtil.info(`${TAG} publishEnterWlanPageEvent isWlanPage: ${isWlanPage}`);
    const options: commonEventManager.CommonEventPublishData = {
      subscriberPermissions: ['ohos.permission.SET_WIFI_CONFIG'],
      parameters: {
        'enterWlanPage': isWlanPage
      }
    };
    try {
      commonEventManager.publish(EVENT_ENTER_WIFI_PAGE, options, (error: BusinessError) => {
      });
    } catch (error) {
      LogUtil.error(`publishEnterWlanPageEvent error: ${error?.message}`);
    }
  }

  /**
   * 判断当前 WifiWindowSettingsAbility 是否由 PC 锁屏拉起
   *
   * @returns 是否由 PC 锁屏拉起
   */
  static isScreenLockMode(): boolean {
    const mode = LocalStorage.getShared().get<WifiWindowSettingsMode>(WIFI_WINDOW_SETTINGS_MODE_KEY);
    LogUtil.showInfo(TAG, `isScreenLockMode mode ${mode}`);
    return mode === WifiWindowSettingsMode.SCREEN_LOCK;
  }

  static async reportWlanConnectFailureEvent(reason: number): Promise<void> {
    LogUtil.info(`${TAG} reportWlanConnectFailureEvent reason: ${reason}`);
    if (!HiSysEventUtil.applicationVersion) {
      await HiSysEventUtil.getApplicationVersion();
    }
    let params: Record<string, Object> = {};
    params.PACKAGE_NAME = HiSysEventUtil.getPkgName();
    params.PVERSIONID = HiSysEventUtil.applicationVersion;
    params.CONNECT_FAILED_REASON = reason;

    HiSysEventUtil.reportFaultEvent(
      HiSysWlanEvenGroup.WLAN_CONNECT_FAILED,
      params,
      HiSysWlanEvenGroup.WLAN_CONNECT_FAILED);
  }

  static showToast(message: string, duration?: number): void {
    const options: promptAction.ShowToastOptions = {
      message,
      duration: duration,
      showMode: promptAction.ToastShowMode.SYSTEM_TOP_MOST
    };
    try {
      promptAction.showToast(options)
    } catch (e) {
      LogUtil.showError(TAG, `showToast error ${e?.code}`);
    }
  }

  /**
   * 检查系统是否支持快速 BSS 切换功能
   *
   * @returns {boolean} 返回 true 表示支持，false 表示不支持
   */
  public static isWifiFastBssSupported(): boolean {
    try {
      let isSupport: boolean = systemParameterEnhance.getSync('ro.config.wifi_fast_bss_enable', 'true') === 'true';
      LogUtil.info(`${TAG} isWifiFastBssSupported isSupport: ${isSupport}`);
      return isSupport;
    } catch (err) {
      LogUtil.error(`${TAG} get isWifiFastBssSupported fail, errCode: ${err?.code}, errMsg: ${err?.message}`);
      return false;
    }
  }
}
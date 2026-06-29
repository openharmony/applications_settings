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
import { BusinessError } from '@kit.BasicServicesKit';
import sim from '@ohos.telephony.sim';
import wifiManager from '@ohos.wifiManager';
import { PADDING_12, PADDING_8 } from '@ohos/settings.common/src/main/ets/constant/StyleConstant';
import { BaseTextInputMenuData } from '@ohos/settings.common/src/main/ets/core/model/menu/BaseMenu';
import { DynamicDataSource } from '@ohos/settings.common/src/main/ets/framework/model/DynamicDataSource';
import { CompCtrlParam, ComponentControl } from '@ohos/settings.common/src/main/ets/framework/model/SettingBaseModel';
import { GroupType, SettingGroupModel } from '@ohos/settings.common/src/main/ets/framework/model/SettingGroupModel';
import {
  ItemDetailType,
  ItemResultType,
  ItemType,
} from '@ohos/settings.common/src/main/ets/framework/model/SettingItemModel';
import { DeviceUtil } from '@ohos/settings.common/src/main/ets/utils/BaseUtils';
import { NavEntryKey } from '@ohos/settings.common/src/main/ets/utils/Consts';
import { LogUtil } from '@ohos/settings.common/src/main/ets/utils/LogUtil';
import { WifiUtils, IPV6_FAMILY_FLAG } from './WifiUtils';
import { PendingIpConfig } from './model/WifiModel';

/**
 * wifi password menu group
 */
export const WIFI_PASSWORD_GROUP: string = 'wifi_password_group';

/**
 * wifi password menu key
 */
export const WIFI_PASSWORD_INPUT: string = 'wifi_password_input';

/**
 * wifi hilink summary menu key
 */
export const WIFI_HILINK_SUMMARY: string = 'wifi_hilink_summary';

/**
 * wifi hilink summary menu key
 */
export const WIFI_EAP_CA_CERTIFICATE_SUMMARY: string = 'wifi_eap_ca_certificate_summary';

/**
 * menu group prefix
 */
export const MENU_GROUP_POSTFIX: string = '_group';

/**
 * menu section prefix
 */
export const MENU_SECTION_POSTFIX: string = '_section';

/**
 * wifi-proxy manual method menu key
 */
export const WIFI_MANUAL_PROXY_SETTINGS: string = 'wifi_manual_proxy_settings';

/**
 * wifi-proxy hostname menu key
 */
export const WIFI_PROXY_HOSTNAME_LABEL: string = 'wifi_proxy_hostname_label';

/**
 * wifi-proxy port menu key
 */
export const WIFI_PROXY_PORT_LABEL: string = 'wifi_proxy_port_label';

/**
 * wifi-proxy exclusion list menu key
 */
export const WIFI_PROXY_EXCLUSIONLIST_LABEL: string = 'proxy_exclusionlist_label';

/**
 * wifi-proxy summary menu key
 */
export const WIFI_PROXY_SUMMARY: string = 'manual_proxy_summary';

/**
 * wifi-proxy group key
 */
export const WIFI_PROXY_SETTINGS_GROUP: string = 'wifi_proxy_settings_group';

/**
 * eap method list
 */
export const PROXY_NAME_VALUE_MAP: Map<ResourceStr, wifiManager.ProxyMethod> = new Map([
  [$r('app.string.wifi_proxy_settings_none'), wifiManager.ProxyMethod.METHOD_NONE],
  [$r('app.string.wifi_proxy_settings_manual'), wifiManager.ProxyMethod.METHOD_MANUAL],
]);

/**
 * security method list
 */
export const SECURITY_NAME_VALUE_MAP: Map<ResourceStr, wifiManager.WifiSecurityType> = new Map([
  [$r('app.string.wifi_proxy_settings_none'), wifiManager.WifiSecurityType.WIFI_SEC_TYPE_OPEN],
  [$r('app.string.wifi_security_wpa_wpa2_wpa3_ft_psk'), wifiManager.WifiSecurityType.WIFI_SEC_TYPE_PSK],
  [$r('app.string.wifi_security_eap'), wifiManager.WifiSecurityType.WIFI_SEC_TYPE_EAP],
  [$r('app.string.wifi_wapi_psk'), wifiManager.WifiSecurityType.WIFI_SEC_TYPE_WAPI_PSK],
  [$r('app.string.wifi_wapi_cert'), wifiManager.WifiSecurityType.WIFI_SEC_TYPE_WAPI_CERT],
]);

/**
 * eap-eap method menu key
 */
export const WIFI_EAP_METHOD: string = 'wifi_eap_method';

/**
 * eap method list
 */
export const EAP_NAME_VALUE_MAP: Map<ResourceStr, wifiManager.EapMethod> = new Map([
  [$r('app.string.wifi_eap_method_peap'), wifiManager.EapMethod.EAP_PEAP],
  [$r('app.string.wifi_eap_method_tls'), wifiManager.EapMethod.EAP_TLS],
  [$r('app.string.wifi_eap_method_ttls'), wifiManager.EapMethod.EAP_TTLS],
  [$r('app.string.wifi_eap_method_pwd'), wifiManager.EapMethod.EAP_PWD],
  [$r('app.string.wifi_eap_method_sim'), wifiManager.EapMethod.EAP_SIM],
  [$r('app.string.wifi_eap_method_aka'), wifiManager.EapMethod.EAP_AKA],
  [$r('app.string.wifi_eap_method_aka_prime'), wifiManager.EapMethod.EAP_AKA_PRIME],
]);

/**
 * eap-phase-2 authentication menu key
 */
export const WIFI_EAP_SELECT_PHASE2: string = 'wifi_eap_select_phase2';

/**
 * eap-sim key
 */
export const WIFI_EAP_SIM_SELECT: string = 'wifi_eap_sim_select';

/**
 * phase-2 authentication list for EAP-PEAP
 */
export const EAP_PHASE2_NAME_VALUE_MAP: Map<ResourceStr, wifiManager.Phase2Method> = new Map([
  [$r('app.string.phase2_mschapv2'), wifiManager.Phase2Method.PHASE2_MSCHAPV2],
  [$r('app.string.phase2_gtc'), wifiManager.Phase2Method.PHASE2_GTC],
  [$r('app.string.phase2_sim'), wifiManager.Phase2Method.PHASE2_SIM],
  [$r('app.string.phase2_aka'), wifiManager.Phase2Method.PHASE2_AKA],
  [$r('app.string.phase2_aka_prime'), wifiManager.Phase2Method.PHASE2_AKA_PRIME],
]);

/**
 * phase-2 authentication list for EAP-TTLS
 */
export const EAP_TTLS_PHASE2_NAME_VALUE_MAP: Map<ResourceStr, wifiManager.Phase2Method> = new Map([
  [$r('app.string.phase2_pap'), wifiManager.Phase2Method.PHASE2_PAP],
  [$r('app.string.phase2_mschapv2'), wifiManager.Phase2Method.PHASE2_MSCHAPV2],
  [$r('app.string.phase2_mschap'), wifiManager.Phase2Method.PHASE2_MSCHAP],
  [$r('app.string.phase2_gtc'), wifiManager.Phase2Method.PHASE2_GTC],
]);

/**
 * eap ca certificate menu key
 */
export const WIFI_EAP_CA_CERTIFICATE: string = 'wifi_eap_ca_certificate';

/**
 * CA证书/用户凭据枚举 (密钥管理暂时也用这个)
 */
export enum CaCertificateType {
  /**
   * None
   */
  CA_CERTIFICATE_TYPE_NONE = 0,

  /**
   * System certs
   */
  CA_CERTIFICATE_TYPE_SYSTEM = 1
}

/**
 * EAP_CA list
 */
export const WIFI_EAP_CA_CERTIFICATE_NAME_VALUE_MAP: Map<ResourceStr, number> = new Map([
  [$r('app.string.wifi_do_not_validate_eap_server'), CaCertificateType.CA_CERTIFICATE_TYPE_NONE],
  [$r('app.string.wifi_use_system_certs'), CaCertificateType.CA_CERTIFICATE_TYPE_SYSTEM],
]);

/**
 * eap domain menu key
 */
export const WIFI_EAP_DOMAIN: string = 'wifi_eap_domain';

/**
 * eap user certificate menu key
 */
export const WIFI_EAP_USER_CERTIFICATE: string = 'wifi_eap_user_certificate';

/**
 * eap user certificate list
 */
export const WIFI_EAP_USER_CERTIFICATE_NAME_VALUE_MAP: Map<ResourceStr, number> = new Map([
  [$r('app.string.wifi_do_not_provide_eap_user_cert'), CaCertificateType.CA_CERTIFICATE_TYPE_NONE],
]);

/**
 * wifi WAPI_CERT as certificate key
 */
export const WIFI_WAPI_CERT_AS_CERTIFICATE: string = 'wifi_wapi_cert_as_certificate';

/**
 * wifi WAPI_CERT user certificate key
 */
export const WIFI_WAPI_CERT_USER_CERTIFICATE: string = 'wifi_wapi_cert_user_certificate';

/**
 * wifi WAPI_PSK password type key
 */
export const WIFI_WAPI_PSK_PASSWORD_TYPE: string = 'wifi_wapi_psk_password_type';

/**
 * 密码类型
 */
export enum WapiPskType {
  /**
   * ascll
   */
  WAPI_PSK_ASCII = 0,

  /**
   * HEX
   */
  WAPI_PSK_HEX = 1
}

/**
 * wifi WAPI_PSK password type list
 */
export const WIFI_WAPI_PSK_PASSWORD_TYPE_NAME_VALUE_MAP: Map<ResourceStr, number> = new Map([
  [$r('app.string.wifi_wapi_psk_ascii'), WapiPskType.WAPI_PSK_ASCII],
  [$r('app.string.wifi_wapi_psk_hex'), WapiPskType.WAPI_PSK_HEX],
]);

/**
 * wifi cipherKey manage menu key
 */
export const WIFI_CIPHER_KEY_MANAGE: string = 'wifi_cipher_key_manage';

/**
 * wifi cipherKey manage list
 */
export const WIFI_CIPHER_KEY_NAME_VALUE_MAP: Map<ResourceStr, number> = new Map([
  [$r('app.string.wifi_cipher_key_none'), CaCertificateType.CA_CERTIFICATE_TYPE_NONE],
  [$r('app.string.wifi_cipher_key_ft'), CaCertificateType.CA_CERTIFICATE_TYPE_SYSTEM],
]);

/**
 * eap-identity menu key
 */
export const WIFI_EAP_IDENTITY: string = 'wifi_eap_identity';

/**
 * eap-anonymous menu key
 */
export const WIFI_EAP_ANONYMOUS: string = 'wifi_eap_anonymous';

/**
 * eap-password menu key
 */
export const WIFI_EAP_PASSWORD: string = 'wifi_eap_password';

/**
 * wifi eap need input menu group
 */
export const WIFI_EAP_INPUT_MENU_GROUP: string = 'wifi_eap_input_menu_group';

/**
 * wifi-privacy settings group
 */
export const WIFI_PRIVACY_SETTINGS_GROUP: string = 'wifi_privacy_settings_group';

/**
 * wifi-privacy use device mac settings
 */
export const WIFI_PRIVACY_MAC_ADDRESS_SETTINGS: string = 'wifi_mac_address_settings';

/**
 * wifi-ipConfig ip settings
 */
export const WIFI_IP_SETTINGS: string = 'wifi_ip_settings';

/**
 * wifi-ipConfig ip address settings
 */
export const WIFI_IP_ADDRESS: string = 'static_ip_address';

/**
 * wifi-ipConfig ip gateway settings
 */
export const WIFI_IP_GATEWAY: string = 'static_ip_gateway';

/**
 * wifi-ipConfig ip prefix length settings
 */
export const WIFI_IP_PREFIX_LENGTH: string = 'static_ip_prefix_length';

/**
 * wifi-ipConfig ip dns servers 1 settings
 */
export const WIFI_IP_DNS_SERVERS_1: string = 'static_ip_dnsServers1';

/**
 * wifi-ipConfig ip dns servers 2 settings
 */
export const WIFI_IP_DNS_SERVERS_2: string = 'static_ip_dnsServers2';

/**
 * wifi ip menu group
 */
export const WIFI_IP_GROUP: string = 'wifi_ip_settings_group';

/**
 * sim card slot 0
 */
export const SIM_SLOT_0: number = 0;

/**
 * sim card slot 1
 */
export const SIM_SLOT_1: number = 1;

/**
 * sim card slot max number
 */
export const MAX_SIM_SLOT: number = 2;

/**
 * IP method list
 */
export const IP_NAME_VALUE_MAP: Map<ResourceStr, wifiManager.IpType> = new Map([
  [$r('app.string.wifi_ip_settings_dhcp'), wifiManager.IpType.DHCP],
  [$r('app.string.wifi_ip_settings_static'), wifiManager.IpType.STATIC],
]);

/**
 * WLAN MAC
 */
export const MAC_NAME_VALUE_MAP: Map<ResourceStr, wifiManager.DeviceAddressType> = new Map([
  [$r('app.string.wifi_privacy_random'), wifiManager.DeviceAddressType.RANDOM_DEVICE_ADDRESS],
  [$r('app.string.wifi_privacy_device'), wifiManager.DeviceAddressType.REAL_DEVICE_ADDRESS],
]);

const TAG: string = 'WifiMenuManager : ';

/**
 * broadcast event info
 *
 */
export class BroadcastEventInfo {
  public eventName: string = '';
  public eventValue: number = Number.NaN;

  constructor(eventName: string, eventValue: number) {
    this.eventName = eventName;
    this.eventValue = eventValue;
  }
}

/**
 * keyboard event
 *
 */
export const EVENT_NAME_KEYBOARD: string = 'keyboard';

/**
 * keyboard enter code
 */
export const ENTER_KEY_CODE: number = 13;

/**
 * wifi menu manager
 *
 * @since 2023-10-05
 */
export class WifiMenuManager {
  // 是否OObe场景
  private static isInOOBeStage: boolean = false;
  // 是否外部拉起半模态场景
  private static isNetworkStage: boolean = false;

  /**
   * wifi-proxy manual menus
   *
   * @param proxyConfig wifi proxy config info
   */
  static getWifiManualProxyMenus(proxyConfig: wifiManager.WifiProxyConfig | undefined): Array<BaseTextInputMenuData> {
    LogUtil.debug(`${TAG} getWifiManualProxyMenus start`);
    let menus: BaseTextInputMenuData[] = [
      {
        key: WIFI_PROXY_HOSTNAME_LABEL,
        index: 35, // menu priority
        summary: $r('app.string.proxy_hostname_label'),
        hint: $r('app.string.wifi_proxy_hostname_hint'),
        title: proxyConfig?.serverHostName,
      },
      {
        key: WIFI_PROXY_PORT_LABEL,
        index: 40,
        summary: $r('app.string.proxy_port_label'),
        hint: $r('app.string.wifi_proxy_port_hint'),
        title: proxyConfig?.serverPort ? proxyConfig?.serverPort.toString() : undefined,
      },
      {
        key: WIFI_PROXY_EXCLUSIONLIST_LABEL,
        index: 45,
        summary: $r('app.string.proxy_exclusionlist_label'),
        hint: $r('app.string.wifi_proxy_exclusionlist_hint'),
        title: proxyConfig?.exclusionObjects,
      },
    ];

    let isCurrentVisible: boolean = proxyConfig?.proxyMethod === wifiManager.ProxyMethod.METHOD_MANUAL;
    menus.forEach(element => {
      element.extra = {
        supportMethod: [wifiManager.ProxyMethod.METHOD_MANUAL],
        isCurrentVisible: isCurrentVisible,
        listenMenuKey: WIFI_MANUAL_PROXY_SETTINGS,
        isClearTitle: false,
      };
    });

    LogUtil.debug(`${TAG} getWifiManualProxyMenus end`);
    return menus;
  }

  /**
   * wifi-ip static menus
   *
   * @param ipType ip type
   * @returns wifi static ip menus
   */
  static getWifiStaticIpMenus(ipType: wifiManager.IpType | undefined): Array<BaseTextInputMenuData> {
    LogUtil.debug(`${TAG} getWifiStaticIpMenus start`);
    let menus: BaseTextInputMenuData[] = [
      {
        key: WIFI_IP_ADDRESS,
        index: 40, // menu priority
        summary: $r('app.string.wifi_ip_address'),
        hint: $r('app.string.wifi_ip_address_hint'),
      },
      {
        key: WIFI_IP_GATEWAY,
        index: 50,
        summary: $r('app.string.wifi_static_ip_gateway'),
        hint: $r('app.string.wifi_static_ip_gateway_hint'),
      },
      {
        key: WIFI_IP_PREFIX_LENGTH,
        index: 60,
        summary: $r('app.string.wifi_static_ip_network_prefix'),
        hint: $r('app.string.wifi_static_ip_network_prefix_hint'),
      },
      {
        key: WIFI_IP_DNS_SERVERS_1,
        index: 70,
        summary: $r('app.string.wifi_static_ip_dns1'),
        hint: $r('app.string.wifi_static_ip_dns_servers_1_hint'),
      },
      {
        key: WIFI_IP_DNS_SERVERS_2,
        index: 80,
        summary: $r('app.string.wifi_static_ip_dns2'),
        hint: $r('app.string.wifi_static_ip_dns_servers_2_hint'),
      },
    ];

    let isCurrentVisible: boolean = ipType === wifiManager.IpType.STATIC;
    menus.forEach(element => {
      element.extra = {
        supportMethod: [wifiManager.IpType.STATIC],
        isCurrentVisible: isCurrentVisible,
        listenMenuKey: WIFI_IP_SETTINGS,
        isClearTitle: false,
      };
    });

    LogUtil.debug(`${TAG} getWifiStaticIpMenus end`);
    return menus;
  }

  static getEapMenuGroup(visible: boolean, onSelected: (index: number) => void): SettingGroupModel {
    return {
      id: WIFI_EAP_METHOD + MENU_SECTION_POSTFIX,
      type: GroupType.GROUP_TYPE_DYNAMIC,
      cached: false,
      visible: visible,
      compControl: {
        init: (param: CompCtrlParam) => {
          let dataSource: DynamicDataSource = param.dataSource as DynamicDataSource;
          dataSource.pushData({
            id: WIFI_EAP_METHOD,
            type: ItemType.ITEM_TYPE_STANDARD,
            title: {
              content: $r('app.string.wifi_eap_method'),
            },
            detail: {
              type: ItemDetailType.DETAIL_TYPE_MENU,
              icon: $r('app.media.ic_arrow_pull'),
              style: {
                width: 12,
                height: 18,
                fillColor: $r('sys.color.icon_fourth'),
              },
              menu: {
                items: [
                  $r('app.string.wifi_eap_method_peap'),
                  $r('app.string.wifi_eap_method_tls'),
                  $r('app.string.wifi_eap_method_ttls'),
                  $r('app.string.wifi_eap_method_pwd'),
                  $r('app.string.wifi_eap_method_sim'),
                  $r('app.string.wifi_eap_method_aka'),
                  $r('app.string.wifi_eap_method_aka_prime'),
                ],
                selectIcon: $r('app.media.ic_selected_ok'),
                onSelected: (index) => {
                  onSelected(index);
                },
                defaultFocus: 0,
              }
            },
            result: {
              type: ItemResultType.RESULT_TYPE_TEXT,
              result: {
                content: $r('app.string.wifi_eap_method_peap'),
              }
            }
          });
        },
        destroy: () => {
        },
      },
    }
  }

  static setEapConfigForSingleSimCard(config?: wifiManager.WifiDeviceConfig): void {
    if (!config) {
      LogUtil.warn(`${TAG} setEapConfigForSingleSimCard fail: config illegal`);
      return;
    }
    for (let index: number = 0; index < MAX_SIM_SLOT; index++) {
      if (sim.hasSimCardSync(index)) {
        sim.getSimAccountInfo(index).then((accountInfo) => {
          let eapConfig: wifiManager.WifiEapConfig | undefined = config.eapConfig;
          if (!eapConfig) {
            return;
          }
          LogUtil.info(`${TAG} setEapConfigForSingleSimCard subId: ${accountInfo.simId}`);
          eapConfig.eapSubId = accountInfo.simId;
        }).catch((err: BusinessError) => {
          LogUtil.error(`${TAG} setEapConfigForSingleSimCard catch err code: ${err.code}, message: ${err.message}`);
        });
        break;
      }
    }
  }

  static getEapSimCardSlotGroup(visible: boolean, controller?: ComponentControl): SettingGroupModel {
    return {
      id: WIFI_EAP_SIM_SELECT + MENU_SECTION_POSTFIX,
      type: GroupType.GROUP_TYPE_DYNAMIC,
      compControl: controller,
      visible: visible,
    };
  }

  static getEapPhase2Group(visible: boolean, controller?: ComponentControl): SettingGroupModel {
    return {
      id: WIFI_EAP_SELECT_PHASE2 + MENU_SECTION_POSTFIX,
      type: GroupType.GROUP_TYPE_DYNAMIC,
      compControl: controller,
      visible: visible,
    };
  }

  static getCACertificateGroup(visible: boolean, controller?: ComponentControl): SettingGroupModel {
    return {
      id: WIFI_EAP_CA_CERTIFICATE + MENU_SECTION_POSTFIX,
      type: GroupType.GROUP_TYPE_DYNAMIC,
      compControl: controller,
      visible: visible,
      footer: {
        id: 'CaCertificateFooter',
        visible: false,
        content: $r('app.string.wifi_do_not_validate_eap_server_warning'),
        style: {
          padding: {
            top: PADDING_8,
            start: PADDING_12,
          },
          fontSize: $r('sys.float.Body_S'),
          fontColor: $r('sys.color.warning'),
          fontWeight: FontWeight.Regular,
        }
      },
    };
  }

  static addWapiCertUserCertificate(visible: boolean, onItemClick: () => void): SettingGroupModel {
    return {
      id: WIFI_WAPI_CERT_USER_CERTIFICATE + MENU_SECTION_POSTFIX,
      type: GroupType.GROUP_TYPE_DYNAMIC,
      visible: visible,
      compControl: {
        init: (param: CompCtrlParam) => {
          let dataSource: DynamicDataSource = param.dataSource as DynamicDataSource;
          dataSource?.pushData({
            id: WIFI_WAPI_CERT_USER_CERTIFICATE,
            type: ItemType.ITEM_TYPE_STANDARD,
            title: {
              content: $r('app.string.wifi_user_certificate'),
              style: {
                fontColor: $r('sys.color.font_primary')
              }
            },
            result: {
              type: ItemResultType.RESULT_TYPE_TEXT,
              result: {
                content: $r('app.string.unassigned'),
              }
            },
            detail: {
              type: ItemDetailType.DETAIL_TYPE_CUSTOM,
              icon: $r('sys.symbol.chevron_right'),
              isSymbolIcon: true,
              destination: NavEntryKey.STATUS_INFO_SETTING,
              onItemClick: () => {
                onItemClick();
              }
            },
          });
        },
        destroy: () => {},
      },
    };
  }

  static addFrequencyMenuGroup(visible: boolean, onSelected: (index: number) => void): SettingGroupModel {
    return {
      id: WIFI_PRIVACY_SETTINGS_GROUP,
      type: GroupType.GROUP_TYPE_DYNAMIC,
      cached: false,
      visible: visible,
      compControl: {
        init: (param: CompCtrlParam) => {
          let dataSource: DynamicDataSource = param.dataSource as DynamicDataSource;
          dataSource?.pushData({
            id: 'ap_privacy_type',
            type: ItemType.ITEM_TYPE_STANDARD,
            title: {
              content: $r('app.string.wifi_privacy_settings'),
            },
            detail: {
              type: ItemDetailType.DETAIL_TYPE_MENU,
              icon: $r('app.media.ic_arrow_pull'),
              style: {
                width: 12,
                height: 18,
                fillColor: $r('sys.color.icon_fourth'),
              },
              menu: {
                items: [$r('app.string.wifi_privacy_random'), $r('app.string.wifi_privacy_device')],
                selectIcon: $r('app.media.ic_selected_ok'),
                onSelected: (index) => {
                  onSelected(index);
                },
                defaultFocus: 0
              }
            },
            result: {
              type: ItemResultType.RESULT_TYPE_TEXT,
              result: {
                content: $r('app.string.wifi_privacy_random'),
              }
            }
          });
        },
        destroy: () => {},
      },
    };
  }

  static addWapiCertAsCertificateMenus(visible: boolean, onItemClick: () => void): SettingGroupModel {
    return {
      id: WIFI_WAPI_CERT_AS_CERTIFICATE + MENU_SECTION_POSTFIX,
      type: GroupType.GROUP_TYPE_DYNAMIC,
      visible: visible,
      compControl: {
        init: (param: CompCtrlParam) => {
          let dataSource: DynamicDataSource = param.dataSource as DynamicDataSource;
          dataSource?.pushData({
            id: WIFI_WAPI_CERT_AS_CERTIFICATE,
            type: ItemType.ITEM_TYPE_STANDARD,
            title: {
              content: $r('app.string.as_certification'),
              style: {
                fontColor: $r('sys.color.font_primary')
              }
            },
            result: {
              type: ItemResultType.RESULT_TYPE_TEXT,
              result: {
                content: $r('app.string.unassigned'),
              }
            },
            detail: {
              type: ItemDetailType.DETAIL_TYPE_CUSTOM,
              icon: $r('sys.symbol.chevron_right'),
              isSymbolIcon: true,
              destination: NavEntryKey.STATUS_INFO_SETTING,
              onItemClick: () => {
                onItemClick();
              }
            },
          });
        },
        destroy: () => {},
      },
    };
  }

  static setOObeStage(isInOOBeStage: boolean): void {
    WifiMenuManager.isInOOBeStage = isInOOBeStage;
  }

  static isInOObeStage(): boolean {
    return WifiMenuManager.isInOOBeStage;
  }

  static setExternalNetworkStage(isNetworkStage: boolean): void {
    LogUtil.info(`${TAG} setExternalNetworkStage: ${isNetworkStage}`);
    WifiMenuManager.isNetworkStage = isNetworkStage;
  }

  static isExternalNetworkStage(): boolean {
    return WifiMenuManager.isNetworkStage;
  }

  static isFixedMarginStage(): boolean {
    return DeviceUtil.isDevicePc() || WifiMenuManager.isInOObeStage();
  }

  /**
   * 配置ip列表数据
   *
   * @param item 输入框
   * @param ip4Info Ip4信息
   * @param ipv6Info Ipv6信息
   * @param pendingIpConfig ip配置信息
   */
  static setIpItemTitle(item: BaseTextInputMenuData, ip4Info: wifiManager.IpInfo | null,
    ipv6Info: wifiManager.Ipv6Info | null, pendingIpConfig: PendingIpConfig): void {
    let isIPv6: boolean = pendingIpConfig?.family === IPV6_FAMILY_FLAG;
    if (!item) {
      LogUtil.info(`${TAG} item is null`);
      return;
    }
    switch (item.key) {
      case WIFI_IP_ADDRESS:
        item.title = isIPv6 ? ipv6Info?.globalIpv6Address : WifiUtils.number2IpString(ip4Info?.ipAddress);
        break;
      case WIFI_IP_GATEWAY:
        item.title = isIPv6 ? ipv6Info?.gateway : WifiUtils.number2IpString(ip4Info?.gateway);
        break;
      case WIFI_IP_PREFIX_LENGTH:
        if (isIPv6) {
          if (pendingIpConfig.connState === wifiManager.ConnState.CONNECTED) {
            item.title = ipv6Info?.netmask ? String(WifiUtils.ipv6PrefixToNumber(ipv6Info?.netmask)) : '';
          } else {
            item.title = String(pendingIpConfig.ipv6PrefixLength);
          }
        } else {
          if (pendingIpConfig.connState === wifiManager.ConnState.CONNECTED) {
            item.title = ip4Info?.netmask ? String(WifiUtils.getPrefixLength(ip4Info?.netmask)) : '';
          } else {
            item.title = ip4Info?.netmask ? String(ip4Info?.netmask) : '';
          }
        }
        break;
      case WIFI_IP_DNS_SERVERS_1:
        item.title = isIPv6 ? ipv6Info?.primaryDNS : WifiUtils.number2IpString(ip4Info?.primaryDns);
        break;
      case WIFI_IP_DNS_SERVERS_2:
        item.title = isIPv6 ? ipv6Info?.secondDNS : WifiUtils.number2IpString(ip4Info?.secondDns);
        break;
      default:
        break;
    }
  }
}
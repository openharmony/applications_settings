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
import systemParameterEnhance from '@ohos.systemParameterEnhance';
import { PushParam } from '@ohos/settings.common/src/main/ets/core/controller/Controller';
import { MenuGroup, SettingsBaseMenu } from '@ohos/settings.common/src/main/ets/core/model/menu/SettingsMenu';
import { TabIndexConstants } from '@ohos/settings.common/src/main/ets/constant/TabIndexConstants';
import { MenuType } from '@ohos/settings.common/src/main/ets/core/model/menu/MenuType';
import { Style } from '@ohos/settings.common/src/main/ets/core/model/menu/ComponetStyle';
import { WifiHilinkController } from '@ohos/settings.wifi/src/main/ets/controller/WifiHilinkController';
import { PsdInputMenuController } from '@ohos/settings.wifi/src/main/ets/controller/WifiEntryBaseController';
import { WifiTextInputBaseController } from '@ohos/settings.wifi/src/main/ets/controller/WifiTextInputBaseController';
import { WifiVisibleController } from '@ohos/settings.wifi/src/main/ets/controller/WifiVisibleController';
import { SelectCertificateFileController } from '@ohos/settings.wifi/src/main/ets/controller/SelectCertificateFileController';
import {
  MENU_SECTION_POSTFIX,
  WIFI_HILINK_SUMMARY,
  EAP_NAME_VALUE_MAP,
  EAP_TTLS_PHASE2_NAME_VALUE_MAP,
  WIFI_EAP_CA_CERTIFICATE,
  WIFI_EAP_CA_CERTIFICATE_NAME_VALUE_MAP,
  WIFI_EAP_DOMAIN,
  WIFI_EAP_USER_CERTIFICATE,
  WIFI_EAP_USER_CERTIFICATE_NAME_VALUE_MAP,
  WIFI_CIPHER_KEY_MANAGE,
  WIFI_CIPHER_KEY_NAME_VALUE_MAP,
  WIFI_EAP_CA_CERTIFICATE_SUMMARY,
  WIFI_EAP_INPUT_MENU_GROUP,
  WIFI_WAPI_PSK_PASSWORD_TYPE,
  WIFI_WAPI_CERT_AS_CERTIFICATE,
  WIFI_WAPI_PSK_PASSWORD_TYPE_NAME_VALUE_MAP,
  WIFI_WAPI_CERT_USER_CERTIFICATE,
  WIFI_PASSWORD_INPUT,
  WIFI_EAP_METHOD,
  WIFI_EAP_PASSWORD,
  WIFI_EAP_SELECT_PHASE2,
  EAP_PHASE2_NAME_VALUE_MAP,
  WIFI_EAP_IDENTITY,
  WIFI_EAP_ANONYMOUS,
  WIFI_PRIVACY_SETTINGS_GROUP,
  WIFI_PRIVACY_MAC_ADDRESS_SETTINGS,
  MAC_NAME_VALUE_MAP,
  WIFI_PROXY_SETTINGS_GROUP,
  WIFI_MANUAL_PROXY_SETTINGS,
  PROXY_NAME_VALUE_MAP,
  WIFI_PROXY_SUMMARY,
  WifiMenuManager,
  WIFI_PROXY_PORT_LABEL,
  WIFI_IP_GROUP,
  IP_NAME_VALUE_MAP,
  WIFI_IP_PREFIX_LENGTH,
  WIFI_IP_SETTINGS,
} from '@ohos/settings.wifi/src/main/ets/WifiMenuManager';
import {
  eapPasswordTextInputStyle,
  NewDefaultSubHeaderStyle,
  newDefaultTextInputMenuStyle,
  newNumDefaultTextInputMenuStyle,
  NewSubHeaderSpaceStyle,
  SubHeaderSection,
  SwitchOutSummaryMenu,
  UnderLineEditMenu,
  RedOutSummaryStyle,
  SingleChoiceEntryMenu,
  PrivacySingleChoiceMenuStyle,
  PhoneUnderLineEditMenuStyle,
  UnderLineEditMenuData,
  ButtonMenu,
  PasswordInputMenu,
  CardMenuSection,
  TextInputMenu,
  NavigationEntry,
  ConnectButtonMenu,
} from '@ohos/settings.uikit/src/main/ets/menus/Menu';
import { PageUrl } from '../../PageUrl';
import { WifiPasswordButtonMenuController } from '../controller/WifiPasswordButtonMenuController';
import { SettingHeaderPage } from '@ohos/settings.uikit/src/main/ets/component/SettingHeaderPage';
import { WifiEntryParams } from '../controller/WifiEntryController';
/* instrument ignore file */
import { SingleSelectController } from '../controller/SingleSelectController';
import { WifiUtils } from '@ohos/settings.wifi';

/**
 * Wifi密码页数据
 *
 * @since 2022-11-11
 */
export class WifiPasswordPage extends SettingHeaderPage {
  public apConfig: wifiManager.WifiDeviceConfig;
  public pathInfos: NavPathStack;
  public isHilink: boolean;

  constructor(navParams ?: PushParam, pathInfos ?: NavPathStack) {
    super({
      pageUrl: PageUrl.WIFI_PASSWORD_PAGE_URL,
      isNavigation: !navParams ? false : true,
      showHeader: false,
    });
    this.pathInfos = pathInfos as NavPathStack;
    const config = navParams?.config as WifiEntryParams;
    this.apConfig = config?.config as wifiManager.WifiDeviceConfig;
    this.isHilink = config?.isHiLinkNetwork as boolean;
    this.capabilities = config?.capabilities as string;
    this.title = this.apConfig?.ssid;
    let baseArray: SettingsBaseMenu[] = WifiPasswordPage.getPasswordMenus();
    if (this.apConfig?.securityType === wifiManager.WifiSecurityType.WIFI_SEC_TYPE_EAP ||
      this.apConfig?.securityType === wifiManager.WifiSecurityType.WIFI_SEC_TYPE_EAP_SUITE_B) {
      baseArray = WifiPasswordPage.getEapMenus(this.apConfig);
    } else if (this.apConfig?.securityType === wifiManager.WifiSecurityType.WIFI_SEC_TYPE_WAPI_PSK) {
      baseArray.push(...WifiPasswordPage.getWapiPskPasswordMenus());
    } else if (this.apConfig?.securityType === wifiManager.WifiSecurityType.WIFI_SEC_TYPE_WAPI_CERT) {
      baseArray = [...WifiPasswordPage.getWapiCertAsCertificateMenus(),
        ...WifiPasswordPage.getWapiCertUserCertificateMenus()]
    }
    this.addMenus([
      ...WifiPasswordPage.getHiLinkMenus(this.apConfig, this.isHilink),
      ...baseArray,
      ...WifiPasswordPage.getPrivacyMenus(this.apConfig),
      ...WifiPasswordPage.getProxyMenus(this.apConfig),
      ...WifiPasswordPage.getIpMenus(this.apConfig),
    ]);
    if (WifiUtils.isWifiFastBssSupported()) {
      this.addMenus(WifiPasswordPage.getCipherKeyMenus());
    }
    this.setFooter(
      new MenuGroup({
        key: 'wifi_password_button_group',
        index: 0,
      }, [new ConnectButtonMenu({
        key: 'wifi_password_cancel_button',
        index: 90,
        buttonTittle1: $r('app.string.dialog_cancel'),
        buttonTittle2: $r('app.string.wifi_button_tittle_connect'),
        controller: {
          createControllerConstructorInter: WifiPasswordButtonMenuController.CreateWifiPasswordButtonMenuController,
        },
        capabilities: this.capabilities,
        extra: this.apConfig,
        pathInfos: this.pathInfos,
      })])
    );
  }

  /**
   * get wifi hiLink menus
   *
   * @returns wifi hiLink menus
   */
  static getHiLinkMenus(config: wifiManager.WifiDeviceConfig, isHilink: boolean): Array<SettingsBaseMenu> {
    return [
      new SettingsBaseMenu(
        {
          key: WIFI_HILINK_SUMMARY,
          index: 5,
          menuType: MenuType.WIFI_HILINK,
          isNeedShowIcon: isHilink,
          controller: {
            createControllerConstructorInter: WifiHilinkController.CreateWifiHilinkController,
          },
          extra: config,
        },
      )
    ];
  }

  /**
   * get wifi password menus
   *
   * @returns wifi password menus
   */
  static getPasswordMenus(): Array<SettingsBaseMenu> {
    return [
      new PasswordInputMenu(
        {
          key: WIFI_PASSWORD_INPUT,
          index: 10,
          hint: $r('app.string.wifi_password_input_hint'),
          controller: {
            createControllerConstructorInter: PsdInputMenuController.CreatePsdInputMenuController,
          },
          style: eapPasswordTextInputStyle as Style,
        }
      )];
  }

  /**
   * get wifi support eap menus
   *
   * @returns wifi support eap menus
   */
  static getEapMenus(config: wifiManager.WifiDeviceConfig,
    tabIndex: number = TabIndexConstants.TAB_INDEX_DEFAULT): Array<SettingsBaseMenu> {
    return [
      ...WifiPasswordPage.getEapPasswordMenus(config),
      new CardMenuSection(
        {
          key: WIFI_EAP_METHOD + MENU_SECTION_POSTFIX,
          index: 20,
          tabIndex: tabIndex,
        },
        [
          new SingleChoiceEntryMenu(
            {
              key: WIFI_EAP_METHOD,
              index: 10,
              style: new PrivacySingleChoiceMenuStyle(),
              selectIcon: $r('app.media.ic_selected'),
              stateIcon: $r('app.media.ic_arrow_down'),
              title: $r('app.string.wifi_eap_method'),
              controller: {
                createControllerConstructorInter: SingleSelectController.CreateSingleSelectController,
              },
              extra: {
                currentSelectedVal: config?.eapConfig?.eapMethod ?? wifiManager.EapMethod.EAP_PEAP,
                selectMenuNameAndValMap: EAP_NAME_VALUE_MAP,
              },
            }
          ),
        ]
      ),
      ...WifiPasswordPage.getEapPhase2Menus(config, tabIndex),
      ...WifiPasswordPage.getCACertificateMenus(tabIndex),
      ...WifiPasswordPage.getUserCertificateMenus(tabIndex),
      ...WifiPasswordPage.getAllInputMenus(config, tabIndex),
    ];
  }

  /**
   * get wifi Eap Password menus
   *
   * @returns wifi Eap Password menus
   */
  static getEapPasswordMenus(config: wifiManager.WifiDeviceConfig): Array<SettingsBaseMenu> {
    return [
      new PasswordInputMenu(
        {
          key: WIFI_EAP_PASSWORD,
          index: 10,
          hint: $r('app.string.wifi_password_input_hint'),
          controller: {
            createControllerConstructorInter: WifiTextInputBaseController.CreateWifiTextInputBaseController,
          },
          style: eapPasswordTextInputStyle as Style,
          extra: {
            supportMethod: [
              wifiManager.EapMethod.EAP_PEAP,
              wifiManager.EapMethod.EAP_PWD,
              wifiManager.EapMethod.EAP_TTLS,
            ],
            isCurrentVisible: true,
            listenMenuKey: WIFI_EAP_METHOD,
          },
        }
      ),
    ]
  }

  /**
   * get wifi Eap Phase2 menus
   *
   * @returns wifi Eap Phase2 menus
   */
  static getEapPhase2Menus(config: wifiManager.WifiDeviceConfig,
    tabIndex: number = TabIndexConstants.TAB_INDEX_DEFAULT): Array<SettingsBaseMenu> {
    return [
      new CardMenuSection(
        {
          key: WIFI_EAP_SELECT_PHASE2 + MENU_SECTION_POSTFIX,
          index: 30,
          tabIndex: tabIndex,
          controller: {
            createControllerConstructorInter: WifiVisibleController.CreateWifiVisibleController,
          },
          extra: {
            supportEapMethod: [wifiManager.EapMethod.EAP_PEAP, wifiManager.EapMethod.EAP_TTLS],
            isCurrentVisible: true,
            listenMenuKeyArray: [WIFI_EAP_METHOD],
          },
        },
        [
          new SingleChoiceEntryMenu(
            {
              key: WIFI_EAP_SELECT_PHASE2,
              index: 10,
              style: new PrivacySingleChoiceMenuStyle(),
              selectIcon: $r('app.media.ic_selected'),
              stateIcon: $r('app.media.ic_arrow_down'),
              title: $r('app.string.please_select_phase2'),
              controller: {
                createControllerConstructorInter: SingleSelectController.CreateSingleSelectController,
              },
              extra: {
                currentSelectedVal: config?.eapConfig?.phase2Method ?? wifiManager.Phase2Method.PHASE2_MSCHAPV2,
                selectMenuNameAndValMap: config?.eapConfig?.eapMethod === wifiManager.EapMethod.EAP_TTLS ?
                  EAP_TTLS_PHASE2_NAME_VALUE_MAP : EAP_PHASE2_NAME_VALUE_MAP,
                listenMenuKeyArray: [WIFI_EAP_METHOD],
              },
            }
          ),
        ]
      ),
    ]
  }

  /**
   * get wifi CA certificate menus
   *
   * @returns wifi CA certificate menus
   */
  static getCACertificateMenus(tabIndex: number = TabIndexConstants.TAB_INDEX_DEFAULT): Array<SettingsBaseMenu> {
    return [
      new CardMenuSection({
        key: WIFI_EAP_CA_CERTIFICATE + MENU_SECTION_POSTFIX,
        index: 40,
        tabIndex: tabIndex,
        controller: {
          createControllerConstructorInter: WifiVisibleController.CreateWifiVisibleController,
        },
        extra: {
          supportEapMethod: [
            wifiManager.EapMethod.EAP_PEAP,
            wifiManager.EapMethod.EAP_TLS,
            wifiManager.EapMethod.EAP_TTLS,
          ],
          isCurrentVisible: true,
          listenMenuKeyArray: [WIFI_EAP_METHOD],
        },
      }, [
        new SingleChoiceEntryMenu({
          key: WIFI_EAP_CA_CERTIFICATE,
          index: 10,
          style: new PrivacySingleChoiceMenuStyle(),
          selectIcon: $r('app.media.ic_selected'),
          stateIcon: $r('app.media.ic_arrow_down'),
          title: $r('app.string.ca_certificate'),
          controller: {
            createControllerConstructorInter: SingleSelectController.CreateSingleSelectController,
          },
          extra: {
            selectMenuNameAndValMap: WIFI_EAP_CA_CERTIFICATE_NAME_VALUE_MAP,
            isNoneSelect: true,
          },
        }),
      ]),
      new SwitchOutSummaryMenu({
        key: WIFI_EAP_CA_CERTIFICATE_SUMMARY,
        style: new RedOutSummaryStyle(),
        index: 43,
        title: $r('app.string.wifi_do_not_validate_eap_server_warning'),
        controller: {
          createControllerConstructorInter: WifiVisibleController.CreateWifiVisibleController,
        },
        extra: {
          isCurrentVisible: false,
          listenMenuKeyArray: [WIFI_EAP_CA_CERTIFICATE, WIFI_EAP_METHOD],
        },
      }),
    ];
  }

  /**
   * get wifi user certificate menus
   *
   * @returns wifi user certificate menus
   */
  static getUserCertificateMenus(tabIndex: number = TabIndexConstants.TAB_INDEX_DEFAULT): Array<SettingsBaseMenu> {
    return [
      new CardMenuSection(
        {
          key: WIFI_EAP_USER_CERTIFICATE + MENU_SECTION_POSTFIX,
          index: 50,
          tabIndex: tabIndex,
          controller: {
            createControllerConstructorInter: WifiVisibleController.CreateWifiVisibleController,
          },
          extra: {
            supportEapMethod: [wifiManager.EapMethod.EAP_TLS],
            isCurrentVisible: false,
            listenMenuKeyArray: [WIFI_EAP_METHOD],
          },
        },
        [
          new SingleChoiceEntryMenu(
            {
              key: WIFI_EAP_USER_CERTIFICATE,
              index: 10,
              style: new PrivacySingleChoiceMenuStyle(),
              selectIcon: $r('app.media.ic_selected'),
              stateIcon: $r('app.media.ic_arrow_down'),
              title: $r('app.string.wifi_user_certificate'),
              controller: {
                createControllerConstructorInter: SingleSelectController.CreateSingleSelectController,
              },
              extra: {
                selectMenuNameAndValMap: WIFI_EAP_USER_CERTIFICATE_NAME_VALUE_MAP,
                isNoneSelect: true,
              },
            }
          ),
        ]
      ),
    ];
  }

  /**
   * get wifi wapi-psk password menus
   *
   * @returns wifi wapi-psk password menus
   */
  static getWapiPskPasswordMenus(tabIndex: number = TabIndexConstants.TAB_INDEX_DEFAULT): Array<SettingsBaseMenu> {
    return [
      new CardMenuSection(
        {
          key: WIFI_WAPI_PSK_PASSWORD_TYPE + MENU_SECTION_POSTFIX,
          index: 20,
          tabIndex: tabIndex
        },
        [
          new SingleChoiceEntryMenu(
            {
              key: WIFI_WAPI_PSK_PASSWORD_TYPE,
              index: 10,
              style: new PrivacySingleChoiceMenuStyle(),
              selectIcon: $r('app.media.ic_selected'),
              stateIcon: $r('app.media.ic_arrow_down'),
              title: $r('app.string.wifi_wapi_psk_password_type'),
              controller: {
                createControllerConstructorInter: SingleSelectController.CreateSingleSelectController,
              },
              extra: {
                selectMenuNameAndValMap: WIFI_WAPI_PSK_PASSWORD_TYPE_NAME_VALUE_MAP,
              },
            }
          ),
        ]
      ),
    ];
  }

  /**
   * get wifi wapi-Cert AS certificate menus
   *
   * @returns wifi wapi-Cert AS certificate menus
   */
  static getWapiCertAsCertificateMenus(tabIndex: number = TabIndexConstants.TAB_INDEX_DEFAULT):
    Array<SettingsBaseMenu> {
    return [
      new CardMenuSection(
        {
          key: WIFI_WAPI_CERT_AS_CERTIFICATE + MENU_SECTION_POSTFIX,
          index: 20,
          tabIndex: tabIndex
        },
        [
          new NavigationEntry(
            {
              key: WIFI_WAPI_CERT_AS_CERTIFICATE,
              index: 10,
              tabIndex: tabIndex,
              title: $r('app.string.as_certification'),
              stateIcon: $r('app.media.ic_settings_arrow'),
              controller: {
                createControllerConstructorInter: SelectCertificateFileController.CreateSelectCertificateFileController,
              },
            }
          ),
        ]
      ),
    ];
  }

  /**
   * get wifi wapi-Cert user certificate menus
   *
   * @returns wifi wapi-Cert user certificate menus
   */
  static getWapiCertUserCertificateMenus(tabIndex: number = TabIndexConstants.TAB_INDEX_DEFAULT):
    Array<SettingsBaseMenu> {
    return [
      new CardMenuSection(
        {
          key: WIFI_WAPI_CERT_USER_CERTIFICATE + MENU_SECTION_POSTFIX,
          index: 30,
          tabIndex: tabIndex
        },
        [
          new NavigationEntry(
            {
              key: WIFI_WAPI_CERT_USER_CERTIFICATE,
              index: 10,
              title: $r('app.string.wifi_user_certificate'),
              stateIcon: $r('app.media.ic_settings_arrow'),
              controller: {
                createControllerConstructorInter: SelectCertificateFileController.CreateSelectCertificateFileController,
              },
            }
          ),
        ]
      ),
    ];
  }

  /**
   * get wifi all input menus
   *
   * @returns wifi all input menus
   */
  static getAllInputMenus(config: wifiManager.WifiDeviceConfig,
    tabIndex: number = TabIndexConstants.TAB_INDEX_DEFAULT): Array<SettingsBaseMenu> {
    let inputMenus: SettingsBaseMenu[] = [];
    const jsonArr: Partial<UnderLineEditMenuData>[] = [
      {
        key: WIFI_EAP_DOMAIN,
        index: 52,
        summary: $r('app.string.wifi_eap_domain'),
        title: config?.eapConfig?.domainSuffixMatch,
      },
      {
        key: WIFI_EAP_IDENTITY,
        index: 53,
        summary: $r('app.string.wifi_eap_identity'),
        title: config?.eapConfig?.identity,
      },
      {
        key: WIFI_EAP_ANONYMOUS,
        index: 54,
        summary: $r('app.string.wifi_eap_anonymous'),
        title: config?.eapConfig?.anonymousIdentity,
      },
    ];
    jsonArr.forEach(element => {
      element.hint = $r('app.string.please_enter');
      element.controller = {
        createControllerConstructorInter: WifiTextInputBaseController.CreateWifiTextInputBaseController,
      };
      element.style = new PhoneUnderLineEditMenuStyle();
      element.extra = { isCurrentVisible: true };
      inputMenus.push(new UnderLineEditMenu(element));
    });
    return [
      new CardMenuSection(
        {
          key: WIFI_EAP_INPUT_MENU_GROUP,
          index: 50,
          tabIndex: tabIndex,
          controller: {
            createControllerConstructorInter: WifiVisibleController.CreateWifiVisibleController,
          },
          extra: {
            isCurrentVisible: true,
            listenMenuKeyArray: [WIFI_EAP_METHOD, WIFI_EAP_CA_CERTIFICATE],
          },
        },
        inputMenus,
      ),
    ];
  }

  /**
   * get wifi privacy menus
   *
   * @returns wifi privacy menus
   */
  static getPrivacyMenus(config: wifiManager.WifiDeviceConfig): Array<SettingsBaseMenu> {
    return [
      new CardMenuSection(
        {
          key: WIFI_PRIVACY_SETTINGS_GROUP,
          index: 70,
        },
        [
          new SingleChoiceEntryMenu(
            {
              key: WIFI_PRIVACY_MAC_ADDRESS_SETTINGS,
              index: 10,
              style: new PrivacySingleChoiceMenuStyle(),
              selectIcon: $r('app.media.ic_selected'),
              stateIcon: $r('app.media.ic_arrow_down'),
              title: $r('app.string.wifi_privacy_settings'),
              controller: {
                createControllerConstructorInter: SingleSelectController.CreateSingleSelectController,
              },
              extra: {
                selectMenuNameAndValMap: MAC_NAME_VALUE_MAP,
                currentSelectedVal: config?.randomMacType as number ??
                wifiManager.DeviceAddressType.RANDOM_DEVICE_ADDRESS,
              },
            }
          ),
        ]
      ),
    ];
  }

  /**
   * get wifi proxy menus
   *
   * @returns wifi proxy menus
   */
  static getProxyMenus(config: wifiManager.WifiDeviceConfig): Array<SettingsBaseMenu> {
    let proxyArray: SettingsBaseMenu[] = [
      new SubHeaderSection(
        {
          key: WIFI_PROXY_SETTINGS_GROUP,
          index: 80,
          spaceStyle: new NewSubHeaderSpaceStyle(),
          subHeaderStyle: new NewDefaultSubHeaderStyle(),
          title: $r('app.string.wifi_advanced_title'),
        },
        [
          new SingleChoiceEntryMenu(
            {
              key: WIFI_MANUAL_PROXY_SETTINGS,
              index: 10,
              style: new PrivacySingleChoiceMenuStyle(),
              selectIcon: $r('app.media.ic_selected'),
              stateIcon: $r('app.media.ic_arrow_down'),
              title: $r('app.string.wifi_proxy_settings_title'),
              controller: {
                createControllerConstructorInter: SingleSelectController.CreateSingleSelectController,
              },
              extra: {
                selectMenuNameAndValMap: PROXY_NAME_VALUE_MAP,
                currentSelectedVal: config?.proxyConfig?.proxyMethod ?? wifiManager.ProxyMethod.METHOD_NONE,
              },
            }
          ),
        ]
      ),
      new SwitchOutSummaryMenu({
        key: WIFI_PROXY_SUMMARY,
        index: 82,
        title: $r('app.string.proxy_warning_limited_support'),
        controller: {
          createControllerConstructorInter: WifiVisibleController.CreateWifiVisibleController,
        },
        extra: {
          supportEapMethod: [wifiManager.ProxyMethod.METHOD_MANUAL],
          isCurrentVisible: config?.proxyConfig?.proxyMethod !== undefined,
          listenMenuKeyArray: [WIFI_MANUAL_PROXY_SETTINGS],
        },
      }),
    ];

    WifiMenuManager.getWifiManualProxyMenus(config?.proxyConfig).forEach(item => {
      item.controller = {
        createControllerConstructorInter: WifiTextInputBaseController.CreateWifiTextInputBaseController,
      };
      item.style = (item.key === WIFI_PROXY_PORT_LABEL ? newNumDefaultTextInputMenuStyle :
        newDefaultTextInputMenuStyle) as Style;
      proxyArray.push(new TextInputMenu(item));
    });

    return proxyArray;
  }

  /**
   * get wifi IP menus
   *
   * @returns wifi IP menus
   */
  static getIpMenus(config: wifiManager.WifiDeviceConfig): Array<SettingsBaseMenu> {
    let ipArray: SettingsBaseMenu[] = [
      new CardMenuSection(
        {
          key: WIFI_IP_GROUP,
          index: 90,
        },
        [
          new SingleChoiceEntryMenu(
            {
              key: WIFI_IP_SETTINGS,
              index: 10,
              style: new PrivacySingleChoiceMenuStyle(),
              selectIcon: $r('app.media.ic_selected'),
              stateIcon: $r('app.media.ic_arrow_down'),
              title: $r('app.string.wifi_ip_settings_title'),
              controller: {
                createControllerConstructorInter: SingleSelectController.CreateSingleSelectController,
              },
              extra: {
                selectMenuNameAndValMap: IP_NAME_VALUE_MAP,
                currentSelectedVal: config?.ipType ?? wifiManager.IpType.DHCP,
              },
            }
          ),
        ]
      ),
    ];

    WifiMenuManager.getWifiStaticIpMenus(config?.ipType).forEach(item => {
      item.controller = {
        createControllerConstructorInter: WifiTextInputBaseController.CreateWifiTextInputBaseController,
      };
      item.style = (item.key === WIFI_IP_PREFIX_LENGTH ? newNumDefaultTextInputMenuStyle :
        newDefaultTextInputMenuStyle) as Style;
      ipArray.push(new TextInputMenu(item));
    });

    return ipArray;
  }

  /**
   * get wifi cipherKey menus
   *
   * @returns wifi cipherKey menus
   */
  static getCipherKeyMenus(): Array<SettingsBaseMenu> {
    return [
      new CardMenuSection(
        {
          key: WIFI_CIPHER_KEY_MANAGE + MENU_SECTION_POSTFIX,
          index: 35,
        },
        [
          new SingleChoiceEntryMenu(
            {
              key: WIFI_CIPHER_KEY_MANAGE,
              index: 10,
              style: new PrivacySingleChoiceMenuStyle(),
              selectIcon: $r('app.media.ic_selected'),
              stateIcon: $r('app.media.ic_arrow_down'),
              title: $r('app.string.wifi_cipher_key_manage'),
              controller: {
                createControllerConstructorInter: SingleSelectController.CreateSingleSelectController,
              },
              extra: {
                selectMenuNameAndValMap: WIFI_CIPHER_KEY_NAME_VALUE_MAP,
              },
            }
          ),
        ]
      ),
    ];
  }
}
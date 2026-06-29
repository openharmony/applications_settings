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

import systemParameterEnhance from '@ohos.systemParameterEnhance';
import { MenuGroup, SettingsBaseMenu } from '@ohos/settings.common/src/main/ets/core/model/menu/SettingsMenu';
import { NavEntryKey } from '@ohos/settings.common/src/main/ets/utils/Consts';
import { FontScaleUtils } from '@ohos/settings.common/src/main/ets/utils/FontScaleUtils';
import { Style } from '@ohos/settings.common/src/main/ets/core/model/menu/ComponetStyle';
import { TabIndexConstants } from '@ohos/settings.common/src/main/ets/constant/TabIndexConstants';
import { ButtonMenu, TextInputMenu } from '@ohos/settings.uikit';
import {
  AddWifiButtonMenuStyle,
  CardMenuSection,
  ConnectButtonMenu,
  eapPasswordTextInputStyle,
  NavigationEntry,
  NewDefaultSubHeaderStyle,
  NewDefaultTextInputMenuStyle,
  NewSubHeaderSpaceStyle,
  NewTextInputStyle,
  PasswordInputMenu,
  PrivacySingleChoiceMenuStyle,
  SingleChoiceEntryMenu,
  SubHeaderMenu,
  SubHeaderSection,
  TextInputContainerStyle,
} from '@ohos/settings.uikit/src/main/ets/menus/Menu';
import wifiManager from '@ohos.wifiManager';
import {
  MAC_NAME_VALUE_MAP,
  MENU_GROUP_POSTFIX,
  SECURITY_NAME_VALUE_MAP,
  WIFI_CIPHER_KEY_MANAGE,
  WIFI_CIPHER_KEY_NAME_VALUE_MAP,
  WIFI_PASSWORD_INPUT,
  WIFI_PRIVACY_MAC_ADDRESS_SETTINGS,
  WIFI_PRIVACY_SETTINGS_GROUP,
  WIFI_PROXY_SETTINGS_GROUP,
  WIFI_WAPI_CERT_AS_CERTIFICATE,
  WIFI_WAPI_PSK_PASSWORD_TYPE,
} from '@ohos/settings.wifi/src/main/ets/WifiMenuManager';
import { PsdInputMenuController, WifiUtils, WifiVisibleController } from '@ohos/settings.wifi';
import { AddOtherWifiButtonController, AddOtherWifiSsidController } from '../controller/AddOtherWifiControllers';
import { WifiSetupProxyEntryController } from '../controller/WifiSetupProxyControllers';
import { WifiSetupIpEntryController } from '../controller/WifiSetupIpControllers';
import { SettingHeaderPage } from '@ohos/settings.uikit/src/main/ets/component/SettingHeaderPage';
import { SingleSelectController } from '../controller/SingleSelectController';
/* instrument ignore file */
import { WifiPasswordPage } from './WifiPasswordPage';

/**
 * 网络名称组件 key
 */
export let KEY_INPUT_WIFI_SSID: string = 'key_input_wifi_ssid';

/**
 * 安全性选择器 key
 */
export let KEY_SECURITY_SELECTOR: string = 'key_security_selector'

/**
 * 安全性卡片 key
 */
let KEY_SECURITY_GROUP: string = 'key_security_group';

/**
 * 安全性-密码框控制器 key
 */
let KEY_SECURITY_PWD_GROUP: string = 'key_security_pwd_group';

/**
 * 安全性-EAP组 key
 */
let KEY_SECURITY_EAP_GROUP: string = 'key_security_eap_group';

/**
 * 底部按钮GROUP key
 */
let KEY_ADD_OTHER_WIFI_BUTTON_GROUP: string = 'key_add_other_wifi_button_group'

/**
 * 底部按钮 key
 */
let KEY_ADD_OTHER_WIFI_BUTTON: string = 'key_add_other_wifi_button'

// 限制网络名称最大长度
let ssidInputMenuStyle = new NewDefaultTextInputMenuStyle();
let ssidInputContainerStyle = new TextInputContainerStyle();
let newTextInputStyle = new NewTextInputStyle();
newTextInputStyle.maxLength = 32;
ssidInputMenuStyle.textInputStyle = newTextInputStyle;
ssidInputContainerStyle.margin = FontScaleUtils.isExtraLargeFontMode() ? { top: '0', bottom: '0' } :
  { top: '10vp', bottom: $r('app.float.margin_4') };
ssidInputMenuStyle.rootContainer = ssidInputContainerStyle;

/**
 * 添加其他网络-界面数据模型
 *
 * @since 2023-11-08
 */
export class AddOtherWifiModel extends SettingHeaderPage {
  public apConfig: wifiManager.WifiDeviceConfig = {
    isHiddenSsid: true,
    ssid: '',
    preSharedKey: '',
    securityType: wifiManager.WifiSecurityType.WIFI_SEC_TYPE_INVALID,
    proxyConfig: {
      proxyMethod: wifiManager.ProxyMethod.METHOD_NONE,
    },
    ipType: wifiManager.IpType.DHCP,
  };

  constructor(pathInfos ?: NavPathStack) {
    super();
    this.pathInfos = pathInfos;
    this.pageUrl = 'join_other_wifi';
    this.showHeader = false;
    this.isNavigation = true;
    this.addMenus([
      ...this.buildSsidMenus(10),
      ...this.buildSecurityMenus(20),
      ...this.buildPrivacyMenus(30),
      ...this.buildProxyAndIpMenus(40),
    ]);
    this.setFooter(this.buildFooterMenu(50));
  }

  private buildSsidMenus(index: number): SettingsBaseMenu[] {
    return [new SubHeaderMenu({
      key: 'title_wifi_name',
      index: index,
      title: $r('app.string.wifi_name'),
      style: new NewDefaultSubHeaderStyle(),
    }),
      new TextInputMenu(
        {
          key: KEY_INPUT_WIFI_SSID,
          index: 10,
          tabIndex: TabIndexConstants.TAB_INDEX_LEVEL2_PAGE,
          style: ssidInputMenuStyle,
          controller: {
            createControllerConstructorInter: AddOtherWifiSsidController.Creator,
          }
        }
      )];
  }

  private buildSecurityMenus(index: number): SettingsBaseMenu[] {
    return [
      new CardMenuSection({
        key: KEY_SECURITY_GROUP,
        index: index,
        tabIndex: TabIndexConstants.TAB_INDEX_LEVEL2_PAGE,
      }, [new SingleChoiceEntryMenu(
        {
          key: KEY_SECURITY_SELECTOR,
          index: 10,
          style: new PrivacySingleChoiceMenuStyle(),
          selectIcon: $r('app.media.ic_selected'),
          stateIcon: $r('app.media.ic_arrow_down'),
          title: $r('app.string.wifi_security'),
          controller: {
            createControllerConstructorInter: SingleSelectController.CreateSingleSelectController,
          },
          extra: {
            selectMenuNameAndValMap: SECURITY_NAME_VALUE_MAP,
            currentSelectedVal: wifiManager.WifiSecurityType.WIFI_SEC_TYPE_INVALID,
          },
        })]),
      this.getWapiPSKMenuGroup(index + 4, TabIndexConstants.TAB_INDEX_LEVEL2_PAGE),
      new MenuGroup({
        key: KEY_SECURITY_PWD_GROUP,
        index: index + 1,
        tabIndex: TabIndexConstants.TAB_INDEX_LEVEL2_PAGE,
        controller: {
          createControllerConstructorInter: WifiVisibleController.CreateWifiVisibleController,
        },
        extra: {
          supportEapMethod: [
            wifiManager.WifiSecurityType.WIFI_SEC_TYPE_WEP,
            wifiManager.WifiSecurityType.WIFI_SEC_TYPE_PSK,
            wifiManager.WifiSecurityType.WIFI_SEC_TYPE_SAE,
            wifiManager.WifiSecurityType.WIFI_SEC_TYPE_WAPI_PSK,
          ],
          isCurrentVisible: false,
          listenMenuKeyArray: [KEY_SECURITY_SELECTOR],
        },
      }, [new PasswordInputMenu({
        key: WIFI_PASSWORD_INPUT,
        index: 10,
        hint: $r('app.string.wifi_password_input_hint'),
        controller: {
          createControllerConstructorInter: PsdInputMenuController.CreatePsdInputMenuController,
        },
        style: eapPasswordTextInputStyle as Style,
      })]),
      new MenuGroup({
        key: KEY_SECURITY_EAP_GROUP,
        index: index + 2,
        tabIndex: TabIndexConstants.TAB_INDEX_LEVEL2_PAGE,
        controller: {
          createControllerConstructorInter: WifiVisibleController.CreateWifiVisibleController,
        },
        extra: {
          supportEapMethod: [
            wifiManager.WifiSecurityType.WIFI_SEC_TYPE_EAP,
          ],
          isCurrentVisible: false,
          listenMenuKeyArray: [KEY_SECURITY_SELECTOR],
        },
      }, WifiPasswordPage.getEapMenus(this.apConfig, TabIndexConstants.TAB_INDEX_LEVEL2_PAGE)),
      this.getWapiCertMenuGroup(index + 6, TabIndexConstants.TAB_INDEX_LEVEL2_PAGE),
    ];
  }

  /**
   * WAPI PSK MenuGroup and menus(密码类型)
   */
  private getWapiPSKMenuGroup(index: number, tabIndex: number): MenuGroup {
    return new MenuGroup({
      key: WIFI_WAPI_PSK_PASSWORD_TYPE + MENU_GROUP_POSTFIX,
      index: index,
      tabIndex: tabIndex,
      controller: {
        createControllerConstructorInter: WifiVisibleController.CreateWifiVisibleController,
      },
      extra: {
        supportEapMethod: [
          wifiManager.WifiSecurityType.WIFI_SEC_TYPE_WAPI_PSK,
        ],
        isCurrentVisible: false,
        listenMenuKeyArray: [KEY_SECURITY_SELECTOR],
      },
    }, WifiPasswordPage.getWapiPskPasswordMenus(tabIndex));
  }

  /**
   * WAPI CERT MenuGroup and menus(AS认证 用户凭据)
   */
  private getWapiCertMenuGroup(index: number, tabIndex: number): MenuGroup {
    return new MenuGroup({
      key: WIFI_WAPI_CERT_AS_CERTIFICATE + MENU_GROUP_POSTFIX,
      index: index,
      tabIndex: tabIndex,
      controller: {
        createControllerConstructorInter: WifiVisibleController.CreateWifiVisibleController,
      },
      extra: {
        supportEapMethod: [
          wifiManager.WifiSecurityType.WIFI_SEC_TYPE_WAPI_CERT,
        ],
        isCurrentVisible: false,
        listenMenuKeyArray: [KEY_SECURITY_SELECTOR],
      },
    }, [
      ...WifiPasswordPage.getWapiCertAsCertificateMenus(tabIndex),
      ...WifiPasswordPage.getWapiCertUserCertificateMenus(tabIndex),
    ]);
  }

  private buildProxyAndIpMenus(index: number): SettingsBaseMenu[] {
    let cipherKeyMenus: SettingsBaseMenu[] = [];
    if (WifiUtils.isWifiFastBssSupported()) {
      cipherKeyMenus.push(
        new SingleChoiceEntryMenu(
          {
            key: WIFI_CIPHER_KEY_MANAGE,
            index: 10,
            tabIndex: TabIndexConstants.TAB_INDEX_LEVEL2_PAGE,
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
      )
    }
    return [
      new SubHeaderSection(
        {
          key: WIFI_PROXY_SETTINGS_GROUP,
          index: index,
          tabIndex: TabIndexConstants.TAB_INDEX_LEVEL2_PAGE,
          spaceStyle: new NewSubHeaderSpaceStyle(),
          subHeaderStyle: new NewDefaultSubHeaderStyle(),
          title: $r('app.string.wifi_advanced_title'),
        },
        [
          new NavigationEntry(
            {
              key: NavEntryKey.WIFI_SETUP_PROXY_ENTRY,
              index: 20,
              title: $r('app.string.wifi_proxy_settings_title'),
              stateIcon: $r('app.media.ic_settings_arrow'),
              targetPageUrl: 'useless',
              controller: {
                createControllerConstructorInter: WifiSetupProxyEntryController.Creator,
              },
              extra: this.apConfig,
              pathInfos: this.pathInfos,
            }
          ),
          new NavigationEntry(
            {
              key: NavEntryKey.WIFI_SETUP_IP_ENTRY,
              index: 20,
              title: $r('app.string.wifi_ip_settings_title'),
              stateIcon: $r('app.media.ic_settings_arrow'),
              targetPageUrl: 'useless',
              controller: {
                createControllerConstructorInter: WifiSetupIpEntryController.Creator,
              },
              extra: this.apConfig,
              pathInfos: this.pathInfos,
            }
          ),
          ...cipherKeyMenus,
        ]
      ),
    ];
  }

  private buildPrivacyMenus(index: number): SettingsBaseMenu[] {
    return [
      new CardMenuSection(
        {
          key: WIFI_PRIVACY_SETTINGS_GROUP,
          index: index,
          tabIndex: TabIndexConstants.TAB_INDEX_LEVEL2_PAGE
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
                currentSelectedVal: this.apConfig?.randomMacType as number ??
                wifiManager.DeviceAddressType.RANDOM_DEVICE_ADDRESS,
              },
            }
          ),
        ]
      ),
    ]
  }

  private buildFooterMenu(index: number): MenuGroup {
    return new MenuGroup(
      {
        key: KEY_ADD_OTHER_WIFI_BUTTON_GROUP,
        index: index,
      },
      [
        new ConnectButtonMenu({
          key: KEY_ADD_OTHER_WIFI_BUTTON,
          index: 10,
          tabIndex: TabIndexConstants.TAB_INDEX_LEVEL2_PAGE,
          buttonTittle1: $r('app.string.dialog_cancel'),
          buttonTittle2: $r('app.string.wifi_button_tittle_connect'),
          controller: {
            createControllerConstructorInter: AddOtherWifiButtonController.Creator,
          },
          extra: this.apConfig,
          pathInfos: this.pathInfos,
          style: new AddWifiButtonMenuStyle(),
        }),
      ]
    )
  }
}
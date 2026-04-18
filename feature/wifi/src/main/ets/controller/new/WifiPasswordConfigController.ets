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
import sim from '@ohos.telephony.sim';
import fs from '@ohos.file.fs';
import picker from '@ohos.file.picker';
import { BusinessError } from '@ohos.base';
import systemParameterEnhance from '@ohos.systemParameterEnhance';
import {
  CompCtrlParam,
  ComponentControl,
  SettingBaseModel
} from '@ohos/settings.common/src/main/ets/framework/model/SettingBaseModel';
import { SettingPageModel,
  SettingSheetPageContext } from '@ohos/settings.common/src/main/ets/framework/model/SettingPageModel';
import { GroupType, SettingGroupModel } from '@ohos/settings.common/src/main/ets/framework/model/SettingGroupModel';
import { LogUtil } from '@ohos/settings.common/src/main/ets/utils/LogUtil';
import {
  ItemDetailType,
  ItemResultType,
  ItemType,
  SettingItemModel,
} from '@ohos/settings.common/src/main/ets/framework/model/SettingItemModel';
import { NavEntryKey } from '@ohos/settings.common/src/main/ets/utils/Consts';
import { EventBus } from '@ohos/settings.common/src/main/ets/framework/common/EventBus';
import {
  notifyCompStateChange,
  SettingBaseState,
  SettingCompState,
  SettingContentState,
  SettingResultState,
  SettingStateType,
  SettingToggleState,
} from '@ohos/settings.common/src/main/ets/framework/model/SettingStateModel';
import { DynamicDataSource } from '@ohos/settings.common/src/main/ets/framework/model/DynamicDataSource';
import { PasswordUtil } from '@ohos/settings.common/src/main/ets/utils/PasswordUtil';
import { PageRouter } from '@ohos/settings.common/src/main/ets/framework/common/PageRouter';
import { EapPhase2Controller } from './EapPhase2Controller';
import { CaCertificateController } from './CaCertificateController';
import { WifiHilinkController } from './WifiHilinkController';
import { UserCertificateController } from './UserCertificateController';
import { EapInputController } from './EapInputController';
import { WlanItemModel } from '../../model/WlanItemModel';
import { WifiPasswordConfigManager } from '../../WifiPasswordConfigManager';
import {
  EAP_METHOD_CHANGED_EVENT,
  RANDOM_MAC_TYPE_CHANGED_EVENT,
  WLAN_CONFIG_INPUT_CHANGE_EVENT,
  WLAN_SWITCH_ID,
  OPEN_NET_WORK_SHEET_ID,
} from '../../model/WifiModel';
import {
  connectWlanComponentBuilder,
  footerBuilder,
  wifiHiLinkBuilder,
  wlanPasswordBuilder,
} from '../../WifiPasswordSettingsSheet';
import { HiLinkModel } from '../../model/HiLinkModel';
import { URL_SET_UP_PROXY_PAGE } from '../../WifiSetupProxySheetPage';
import { URL_SET_UP_IP_PAGE } from '../../WifiSetupIpSheetPage';
import {
  EAP_NAME_VALUE_MAP,
  MENU_SECTION_POSTFIX,
  WapiPskType,
  WIFI_CIPHER_KEY_MANAGE,
  WIFI_EAP_INPUT_MENU_GROUP,
  WIFI_EAP_PASSWORD,
  WIFI_EAP_USER_CERTIFICATE,
  WIFI_HILINK_SUMMARY,
  WIFI_PASSWORD_INPUT,
  WIFI_WAPI_PSK_PASSWORD_TYPE,
  WIFI_WAPI_PSK_PASSWORD_TYPE_NAME_VALUE_MAP,
  WifiMenuManager,
  WIFI_EAP_SIM_SELECT,
  SIM_SLOT_0,
  SIM_SLOT_1,
} from '../../WifiMenuManager';
import { WifiUtils } from '../../WifiUtils';
import { notifyNetWorkSettingsSheetHeightChange } from './NetWorkSettingsController';
import { EapSimCardSlotController } from './EapSimCardSlotController';

/* instrument ignore file */
export class WifiPasswordConfigController implements ComponentControl {
  public tag: string = 'WifiPasswordConfigController: ';
  public settingPageModel?: SettingPageModel;
  public wifiConfig?: wifiManager.WifiDeviceConfig;
  public itemModel?: WlanItemModel;
  private sheetPageCtx?: SettingSheetPageContext;
  private compId: string = '';
  // wlan开关id
  private wlanSwitchCompId: string = '';
  // 当前半模态组件id
  private editSheetCompId: string = '';
  private onToggleChangeCallback = (toggleState: SettingToggleState) => {
    if (!toggleState) {
      LogUtil.error(`${this.tag} toggleState is invalid`);
      return;
    }
    LogUtil.info(`${this.tag} receive toggle state change: ${toggleState.state}`);
    // 关闭半模态
    this.showOrHideModal(false, this.editSheetCompId);
  };

  private showOrHideModal(isShow: boolean, itemModelId: string): void {
    // 操作半模态
    notifyCompStateChange(itemModelId,
      new Map<SettingStateType, SettingBaseState>([[SettingStateType.STATE_TYPE_ITEM_SHEET,
        {
          state: isShow,
        } as SettingCompState]]
      ));
  }

  onPageShow(): void {
  }

  onPageHide(): void {
  }

  init(compParam: CompCtrlParam): void {
    LogUtil.info(`${this.tag} init`);
    if (!compParam || !compParam.param) {
      LogUtil.error(`${this.tag} init fail, compParam is invalid`);
      return;
    }
    LogUtil.info(`${this.tag} init compId: ${compParam.compId}`);
    this.initId();
    this.compId = compParam.compId;
    this.settingPageModel = compParam?.component as SettingPageModel;
    this.sheetPageCtx = compParam?.param as SettingSheetPageContext;
    // 外部拉起半模态设置密码
    if (WifiMenuManager.isExternalNetworkStage()) {
      let instance: WifiPasswordConfigManager = WifiPasswordConfigManager.getInstance();
      instance.initConfig(instance.getDefaultWifiConfig(this.sheetPageCtx?.param as WlanItemModel),
        this.sheetPageCtx?.param as WlanItemModel);
    }
    this.itemModel = WifiPasswordConfigManager.getInstance().model;
    // 初始化标题名称
    notifyCompStateChange(`${PageRouter.getRouterName()}.SheetPage.wifi_password_config`,
      new Map<SettingStateType, SettingBaseState>([[SettingStateType.STATE_TYPE_PAGE_TITLE,
        { content: this.itemModel?.wlanName } as SettingContentState]]
      ));
    this.wifiConfig = WifiPasswordConfigManager.getInstance().getConfig();
    this.initMenus();
    EventBus.getInstance().on(this.wlanSwitchCompId, this.onToggleChangeCallback);
  }

  initId(): void {
    if (WifiMenuManager.isExternalNetworkStage()) {
      this.wlanSwitchCompId = 'OpenNetWorkSetting.NetworkSetting.WlanConfig.WlanSwitch.toggle';
      this.editSheetCompId = OPEN_NET_WORK_SHEET_ID;
    } else {
      this.wlanSwitchCompId = WLAN_SWITCH_ID;
      this.editSheetCompId = 'Setting.Wlan.EditSheetConfig.EditSheet';
    }
  }

  // 确认按钮
  addConnectMenus(): void {
    const connectMenu: SettingGroupModel = {
      id: this.itemModel?.id ?? '',
      type: GroupType.GROUP_TYPE_CUSTOM,
      builder: wrapBuilder(connectWlanComponentBuilder),
    };
    this.settingPageModel?.groups?.push(connectMenu);
  }

  addGroupForeground(): void {
    if (!this.settingPageModel) {
      LogUtil.error(`${this.tag} addGroupForeground fail.`);
      return;
    }
    this.settingPageModel.groupForeground = {
      id: this.itemModel?.id ?? '',
      builder: wrapBuilder(connectWlanComponentBuilder),
    }
  }

  initMenus(): void {
    this.addHiLinkMenu();
    if (this.itemModel?.securityType === wifiManager.WifiSecurityType.WIFI_SEC_TYPE_EAP ||
      this.itemModel?.securityType === wifiManager.WifiSecurityType.WIFI_SEC_TYPE_EAP_SUITE_B) {
      // eap密码输入框
      this.addEapPasswordMenus();
      this.addEapMenuGroup();
      this.addSimSelectGroup();
      this.addEapPhase2Menus();
      this.addCACertificateMenus();
      this.addUserCertificateMenus();
      this.addAllInputMenus();
      this.addFrequencyMenuGroup();
      this.addIpMenuGroup();
    } else if (this.itemModel?.securityType === wifiManager.WifiSecurityType.WIFI_SEC_TYPE_WAPI_PSK) {
      this.addPasswordMenus();
      this.addWapiPskPasswordMenus();
      this.addFrequencyMenuGroup();
      this.addIpMenuGroup();
    } else if (this.itemModel?.securityType === wifiManager.WifiSecurityType.WIFI_SEC_TYPE_WAPI_CERT) {
      this.addWapiCertAsCertificateMenus();
      this.addWapiCertUserCertificateMenus();
      this.addFrequencyMenuGroup();
      this.addIpMenuGroup();
    } else {
      this.addPasswordMenus();
      this.addFrequencyMenuGroup();
      this.addIpMenuGroup();
    }
    this.addGroupForeground();
  }

  destroy(): void {
    LogUtil.info(`${this.tag} destroy`);
    EventBus.getInstance().detach(this.wlanSwitchCompId, this.onToggleChangeCallback);
  }

  onBackPressed(component: SettingBaseModel): boolean {
    LogUtil.info(`${this.tag} onBackPressed`);
    if (WifiMenuManager.isExternalNetworkStage()) {
      PasswordUtil.setPrivacyMode(false);
      let isWifiActive: boolean = WifiUtils.isWifiActive();
      notifyNetWorkSettingsSheetHeightChange(isWifiActive);
    }
    return false;
  }

  private addFooter(): void {
    let model: SettingGroupModel = {
      id: 'footer',
      type: GroupType.GROUP_TYPE_CUSTOM,
      builder: wrapBuilder(footerBuilder),
    };
    this.settingPageModel?.groups?.push(model);
  }

  private addHiLinkMenu(): void {
    let isHiLinkNetwork: boolean = (this.itemModel?.isHiLinkNetwork || this.itemModel?.isHiLinkProNetwork) ?? false;
    let hiLinkModel: HiLinkModel = {
      id: WIFI_HILINK_SUMMARY,
      type: GroupType.GROUP_TYPE_CUSTOM,
      compControl: new WifiHilinkController(this.wifiConfig, isHiLinkNetwork),
      builder: wrapBuilder(wifiHiLinkBuilder),
      isHiLinkNetwork: isHiLinkNetwork,
    };
    this.settingPageModel?.groups?.push(hiLinkModel);
  }

  private addPasswordMenus(): void {
    let passwordMenu: SettingGroupModel = {
      id: WIFI_PASSWORD_INPUT,
      type: GroupType.GROUP_TYPE_CUSTOM,
      builder: wrapBuilder(wlanPasswordBuilder),
    };
    this.settingPageModel?.groups?.push(passwordMenu);
  }

  // AS 认证菜单
  private addWapiCertAsCertificateMenus(): void {
    let menu: SettingGroupModel = WifiMenuManager.addWapiCertAsCertificateMenus(true, () => {
      this.clickWapiCertAsCertificate(true);
    });
    this.settingPageModel?.groups?.push(menu);
  }

  // 用户证书
  private addWapiCertUserCertificateMenus(): void {
    let menu: SettingGroupModel = WifiMenuManager.addWapiCertUserCertificate(true, () => {
      this.clickWapiCertAsCertificate(false);
    })
    this.settingPageModel?.groups?.push(menu);
  }

  private addEapPasswordMenus(): void {
    let passwordMenu: SettingGroupModel = {
      id: WIFI_EAP_PASSWORD,
      type: GroupType.GROUP_TYPE_CUSTOM,
      builder: wrapBuilder(wlanPasswordBuilder),
    };
    this.settingPageModel?.groups?.push(passwordMenu);
  }

  // 添加EAP方法
  private addEapMenuGroup(): void {
    let model: SettingGroupModel = WifiMenuManager.getEapMenuGroup(true, (index: number) => {
      this.onEapMethodChanged(index);
    });
    this.settingPageModel?.groups?.push(model);
  }

  private addSimSelectGroup(): void {
    if (!sim.hasSimCardSync(SIM_SLOT_0) || !sim.hasSimCardSync(SIM_SLOT_1)) {
      LogUtil.info(`${this.tag} no need show sim select section`);
      WifiMenuManager.setEapConfigForSingleSimCard(this.wifiConfig);
      return;
    }
    let model: SettingGroupModel =
      WifiMenuManager.getEapSimCardSlotGroup(false, new EapSimCardSlotController(this.wifiConfig?.eapConfig));
    this.settingPageModel?.groups?.push(model);
  }

  // 阶段2身份验证菜单组
  private addEapPhase2Menus(): void {
    let controller = new EapPhase2Controller();
    let model: SettingGroupModel = WifiMenuManager.getEapPhase2Group(true, controller);
    this.settingPageModel?.groups?.push(model);
  }

  // CA 证书
  private addCACertificateMenus(): void {
    let controller = new CaCertificateController();
    let model: SettingGroupModel = WifiMenuManager.getCACertificateGroup(true, controller);
    this.settingPageModel?.groups?.push(model);
  }

  // 用户证书
  private addUserCertificateMenus(): void {
    let controller = new UserCertificateController();
    let model: SettingGroupModel = {
      id: WIFI_EAP_USER_CERTIFICATE + MENU_SECTION_POSTFIX,
      type: GroupType.GROUP_TYPE_DYNAMIC,
      compControl: controller,
      visible: false,
    };
    this.settingPageModel?.groups?.push(model);
  }

  // 身份
  private addAllInputMenus(): void {
    let controller = new EapInputController();
    let model: SettingGroupModel = {
      id: WIFI_EAP_INPUT_MENU_GROUP,
      type: GroupType.GROUP_TYPE_DYNAMIC_LAZY,
      compControl: controller,
      cached: false,
      visible: true,
    };
    this.settingPageModel?.groups?.push(model);
  }

  // 密码类型
  private addWapiPskPasswordMenus(): void {
    let model: SettingGroupModel = {
      id: WIFI_WAPI_PSK_PASSWORD_TYPE + MENU_SECTION_POSTFIX,
      type: GroupType.GROUP_TYPE_DYNAMIC,
      compControl: {
        init: (param: CompCtrlParam) => {
          let dataSource: DynamicDataSource = param.dataSource as DynamicDataSource;
          dataSource?.pushData(this.createWapiPskPasswordModel());
        },
        destroy: () => {},
      },
    };
    this.settingPageModel?.groups?.push(model);
  }

  // 添加隐私菜单组
  private addFrequencyMenuGroup(): void {
    let model: SettingGroupModel = WifiMenuManager.addFrequencyMenuGroup(true, (index: number) => {
      this.onMacTypeSelectChanged(index);
    });
    this.settingPageModel?.groups?.push(model);
  }

  // 密码类型
  private createWapiPskPasswordModel(): SettingItemModel {
    return {
      id: WIFI_WAPI_PSK_PASSWORD_TYPE,
      type: ItemType.ITEM_TYPE_STANDARD,
      title: {
        content: $r('app.string.wifi_wapi_psk_password_type'),
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
          items: [$r('app.string.wifi_wapi_psk_ascii'), $r('app.string.wifi_wapi_psk_hex')],
          selectIcon: $r('app.media.ic_selected_ok'),
          onSelected: (index) => {
            if (this.wifiConfig?.wapiConfig) {
              let passwordTypes: ResourceStr [] = Array.from(WIFI_WAPI_PSK_PASSWORD_TYPE_NAME_VALUE_MAP.keys());
              this.wifiConfig.wapiConfig.wapiPskType =
                WIFI_WAPI_PSK_PASSWORD_TYPE_NAME_VALUE_MAP.get(passwordTypes[index]) ?? WapiPskType.WAPI_PSK_ASCII;
            }
          },
          defaultFocus: 0,
        }
      },
      result: {
        type: ItemResultType.RESULT_TYPE_TEXT,
        result: {
          content: $r('app.string.wifi_wapi_psk_ascii'),
        }
      }
    };
  }

  // 秘钥管理
  private createCipherKeyModel(): SettingItemModel {
    return {
      id: WIFI_CIPHER_KEY_MANAGE,
      type: ItemType.ITEM_TYPE_STANDARD,
      title: {
        content: $r('app.string.wifi_cipher_key_manage'),
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
          items: [$r('app.string.wifi_cipher_key_none'), $r('app.string.wifi_cipher_key_ft')],
          selectIcon: $r('app.media.ic_selected_ok'),
          onSelected: (index) => {
          },
          defaultFocus: 0,
        }
      },
      result: {
        type: ItemResultType.RESULT_TYPE_TEXT,
        result: {
          content: $r('app.string.wifi_cipher_key_none'),
        }
      }
    };
  }

  private addIpMenuGroup(): void {
    let items: SettingItemModel[] = [
      {
        id: NavEntryKey.WIFI_SETUP_PROXY_ENTRY,
        type: ItemType.ITEM_TYPE_STANDARD,
        title: {
          content: $r('app.string.wifi_proxy_settings_title'),
        },
        detail: {
          type: ItemDetailType.DETAIL_TYPE_MODAL,
          icon: $r('sys.symbol.chevron_right'),
          isSymbolIcon: true,
          destination: URL_SET_UP_PROXY_PAGE,
        },
        result: {
          type: ItemResultType.RESULT_TYPE_TEXT,
          result: {
            content: $r('app.string.wifi_proxy_settings_none'),
          }
        }
      },
      {
        id: NavEntryKey.WIFI_SETUP_IP_ENTRY,
        type: ItemType.ITEM_TYPE_STANDARD,
        title: {
          content: $r('app.string.wifi_ip_settings_title'),
        },
        detail: {
          type: ItemDetailType.DETAIL_TYPE_MODAL,
          destination: URL_SET_UP_IP_PAGE,
          icon: $r('sys.symbol.chevron_right'),
          isSymbolIcon: true,
          onItemClick: () => {
          }
        },
        result: {
          type: ItemResultType.RESULT_TYPE_TEXT,
          result: {
            content: $r('app.string.wifi_ip_settings_dhcp'),
          }
        }
      },
    ];
    if (systemParameterEnhance.getSync('ro.config.wifi_fast_bss_enable', 'false') === 'true') {
      items.push(this.createCipherKeyModel());
    }
    let model: SettingGroupModel = {
      id: 'wifi_config_ip_group',
      type: GroupType.GROUP_TYPE_STANDARD,
      header: {
        id: 'WifiConfigAdvancedHeader',
        content: $r('app.string.wifi_advanced_title'),
        style: {
          height: '56vp',
          fontSize: $r('sys.float.Subtitle_S'),
          fontColor: $r('sys.color.font_secondary'),
          fontWeight: FontWeight.Medium,
        }
      },
      items: [
        ...items,
      ]
    };
    this.settingPageModel?.groups?.push(model);
  }

  private onMacTypeSelectChanged(type: number): void {
    if (this.wifiConfig) {
      this.wifiConfig.randomMacType = type;
    }
    EventBus.getInstance().emit(RANDOM_MAC_TYPE_CHANGED_EVENT, type);
  }

  private onEapMethodChanged(index: number): void {
    if (this.wifiConfig?.eapConfig) {
      let eapMethods: ResourceStr [] = Array.from(EAP_NAME_VALUE_MAP.keys());
      this.wifiConfig.eapConfig.eapMethod = EAP_NAME_VALUE_MAP.get(eapMethods[index]) ?? wifiManager.EapMethod.EAP_PEAP;
      EventBus.getInstance().emit(EAP_METHOD_CHANGED_EVENT);
      EventBus.getInstance().emit(WLAN_CONFIG_INPUT_CHANGE_EVENT);
    }
  }

  private clickWapiCertAsCertificate(isAsCertificate: boolean): void {
    const documentViewPicker: picker.DocumentViewPicker = new picker.DocumentViewPicker();
    const documentSelectOptions: picker.DocumentSelectOptions = new picker.DocumentSelectOptions();
    documentSelectOptions.maxSelectNumber = 1;
    documentSelectOptions.fileSuffixFilters = ['.cer'];
    documentViewPicker.select(documentSelectOptions).then((documentSelectResult: Array<string>) => {
      const filePath: string = documentSelectResult[0] || '';
      if (!filePath) {
        LogUtil.error(`${this.tag} filePath is empty`);
        return;
      }
      LogUtil.info(`${this.tag} documentViewPicker.select filePath`);
      let file: fs.File | undefined = undefined;
      try {
        file = fs.openSync(filePath);
        const text: string = fs.readTextSync(file.path);
        this.dealCertificateResult(isAsCertificate, text, file.name);
      } catch (err) {
        LogUtil.error(`${this.tag} fs.readfile catch code:${err.code} message:${err.message}`);
      } finally {
        try {
          file && fs.closeSync(file);
        } catch (err) {
          LogUtil.error(`${this.tag} fs.closeSync catch code:${err?.code} message:${err?.message}`);
        }
      }
    }).catch((err: BusinessError) => {
      LogUtil.error(`${this.tag} documentViewPicker.select catch code:${err.code} message:${err.message}`);
    });
  }

  private dealCertificateResult(isAsCertificate: boolean, text: string, fileName: string): void {
    LogUtil.info(`${this.tag} dealCertificateResult.`);
    if (this.wifiConfig?.wapiConfig) {
      LogUtil.info(`${this.tag} dealCertificateResult, isAsCertificate : ${isAsCertificate}`);
      if (isAsCertificate) {
        this.wifiConfig.wapiConfig.wapiAsCert = text;
      } else {
        this.wifiConfig.wapiConfig.wapiUserCert = text;
      }
    }
    let id: string =
      `${PageRouter.getRouterName()}.wifi_password_config.wifi_wapi_cert_user_certificate_section.wifi_wapi_cert_user_certificate`;
    if (isAsCertificate) {
      id = `${PageRouter.getRouterName()}.wifi_password_config.wifi_wapi_cert_as_certificate_section.wifi_wapi_cert_as_certificate`;
    }
    notifyCompStateChange(id,
      new Map<SettingStateType, SettingResultState>([[SettingStateType.STATE_TYPE_ITEM_RESULT,
        {
          type: ItemResultType.RESULT_TYPE_TEXT,
          result: {
            content: fileName,
          }
        } as SettingResultState]]));
    EventBus.getInstance().emit(WLAN_CONFIG_INPUT_CHANGE_EVENT);
  }
}

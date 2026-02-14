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

import window from '@ohos.window';
import fs from '@ohos.file.fs';
import picker from '@ohos.file.picker';
import { BusinessError } from '@ohos.base';
import wifiManager from '@ohos.wifiManager';
import sim from '@ohos.telephony.sim'
import { CompCtrlParam, ComponentControl, SettingBaseModel } from '@ohos/settings.common/src/main/ets/framework/model/SettingBaseModel';
import {
  SettingPageModel,
  SettingSheetPageContext
} from '@ohos/settings.common/src/main/ets/framework/model/SettingPageModel';
import { PageRouter } from '@ohos/settings.common/src/main/ets/framework/common/PageRouter';
import { GroupType, SettingGroupModel } from '@ohos/settings.common/src/main/ets/framework/model/SettingGroupModel';
import { LogUtil } from '@ohos/settings.common/src/main/ets/utils/LogUtil';
import { EventBus } from '@ohos/settings.common/src/main/ets/framework/common/EventBus';
import {
  ItemDetailType,
  ItemResultType,
  ItemType,
  SettingItemModel,
} from '@ohos/settings.common/src/main/ets/framework/model/SettingItemModel';
import { NavEntryKey } from '@ohos/settings.common/src/main/ets/utils/Consts';
import {
  notifyCompStateChange,
  SettingBaseState,
  SettingCompState,
  SettingResultState,
  SettingStateType,
  SettingToggleState,
} from '@ohos/settings.common/src/main/ets/framework/model/SettingStateModel';
import { PasswordUtil } from '@ohos/settings.common/src/main/ets/utils/PasswordUtil';
import { DynamicDataSource } from '@ohos/settings.common/src/main/ets/framework/model/DynamicDataSource';
import { URL_SET_UP_PROXY_PAGE } from '../../WifiSetupProxySheetPage';
import { URL_SET_UP_IP_PAGE } from '../../WifiSetupIpSheetPage';
import {
  EAP_METHOD_CHANGED_EVENT,
  OPEN_NET_WORK_SHEET_ID,
  SECURITY_CHANGE_EVENT,
  WLAN_CONFIG_INPUT_CHANGE_EVENT,
  WLAN_SWITCH_ID
} from '../../model/WifiModel';
import { connectWlanComponentBuilder, footerBuilder, wlanPasswordBuilder } from '../../WifiPasswordSettingsSheet';
import { wlanNameInputBuilder } from '../../AddOtherWlanSheetPage';
import { AddOtherWlanConfigManager } from '../../AddOtherWlanConfigManager';
import {
  EAP_NAME_VALUE_MAP,
  MENU_SECTION_POSTFIX,
  SECURITY_NAME_VALUE_MAP,
  WapiPskType,
  WIFI_EAP_INPUT_MENU_GROUP,
  WIFI_WAPI_PSK_PASSWORD_TYPE,
  WIFI_WAPI_PSK_PASSWORD_TYPE_NAME_VALUE_MAP,
  WifiMenuManager,
  WIFI_EAP_SIM_SELECT,
  SIM_SLOT_0,
  SIM_SLOT_1
} from '../../WifiMenuManager';
import { WlanItemModel } from '../../model/WlanItemModel';
import { CaCertificateController } from './CaCertificateController';
import { EapInputController } from './EapInputController';
import { EapPhase2Controller } from './EapPhase2Controller';
import { WifiPasswordConfigManager } from '../../WifiPasswordConfigManager';
import { WifiUtils } from '../../WifiUtils';
import { notifyNetWorkSettingsSheetHeightChange } from './NetWorkSettingsController';
import { EapSimCardSlotController } from './EapSimCardSlotController';

/* instrument ignore file */
const TAG: string = 'AddOtherWlanController: ';

export class AddOtherWlanController implements ComponentControl {
  public tag: string = 'AddOtherWlanController: ';
  public settingPageModel?: SettingPageModel;
  public wifiConfig?: wifiManager.WifiDeviceConfig;
  public itemModel?: WlanItemModel;
  private compId?: string = '';
  // wlan开关id
  private wlanSwitchCompId: string = '';
  // 当前半模态组件id
  private editSheetCompId: string = '';
  private addOtherWlanConfigManager: AddOtherWlanConfigManager = AddOtherWlanConfigManager.getInstance();
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

  onBackPressed(component: SettingBaseModel): boolean {
    LogUtil.info(`${this.tag} onBackPressed`);
    if (WifiMenuManager.isExternalNetworkStage()) {
      PasswordUtil.setPrivacyMode(false);
      let isWifiActive: boolean = WifiUtils.isWifiActive();
      notifyNetWorkSettingsSheetHeightChange(isWifiActive);
    }
    return false;
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
    let sheetPageContext: SettingSheetPageContext = compParam.param as SettingSheetPageContext;
    if (!sheetPageContext || !sheetPageContext.itemComp) {
      LogUtil.error(`${this.tag} init fail, sheetPageContext is invalid`);
      return;
    }
    this.initId();
    this.compId = compParam.compId;
    this.settingPageModel = compParam.component as SettingPageModel;
    if (WifiPasswordConfigManager.getInstance().getConfig()) {
      WifiPasswordConfigManager.getInstance().clearConfig();
    }
    this.wifiConfig = this.addOtherWlanConfigManager.initConfig();
    this.addOtherWlanConfigManager.setAddOtherWlanPageFlag(true);
    // 初始化itemModel信息
    this.addGroupForeground();
    this.initMenus();
    EventBus.getInstance().on(this.wlanSwitchCompId, this.onToggleChangeCallback);
    this.setWindowPrivacyMode(false);
  }

  addGroupForeground(): void {
    if (!this.settingPageModel) {
      return;
    }
    this.settingPageModel.groupForeground = {
      id: this.itemModel?.id ?? '',
      builder: wrapBuilder(connectWlanComponentBuilder),
    }
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

  initMenus(): void {
    // 名称输入
    this.addNameInputGroup();
    // 安全性
    this.addSecurityMenusGroup();
    // AS认证
    this.addWapiCertAsCertificateMenus();
    // 用户证书
    this.addWapiCertUserCertificateMenus();
    // 密码类型
    this.addWapiPskPasswordMenus();
    // 密码输入
    this.addPasswordMenus();
    // EAP方法
    this.addEapPasswordMenus();
    this.addEapMenuGroup();
    this.addEapSimCardSlot();
    this.addEapPhase2Menus();
    this.addCACertificateMenus();
    this.addAllInputMenus();
    // 隐私
    this.addFrequencyMenuGroup();
    // 代理 IP
    this.addIpMenuGroup();
  }

  destroy(): void {
    LogUtil.info(`${this.tag} destroy`);
    this.addOtherWlanConfigManager.clearConfig();
    this.addOtherWlanConfigManager.setAddOtherWlanPageFlag(false);
    EventBus.getInstance().detach(this.wlanSwitchCompId, this.onToggleChangeCallback);
    this.setWindowPrivacyMode(false);
  }

  private addFooter(): void {
    let model: SettingGroupModel = {
      id: 'footer',
      type: GroupType.GROUP_TYPE_CUSTOM,
      builder: wrapBuilder(footerBuilder),
    };
    this.settingPageModel?.groups?.push(model);
  }

  // CA 证书
  private addCACertificateMenus(): void {
    let controller = new CaCertificateController();
    let model: SettingGroupModel = WifiMenuManager.getCACertificateGroup(false, controller);
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
      visible: false,
    };
    this.settingPageModel?.groups?.push(model);
  }

  // 添加隐EAP方法
  private addEapMenuGroup(): void {
    let model: SettingGroupModel = WifiMenuManager.getEapMenuGroup(false, (index: number) => {
      this.onEapMethodChanged(index);
    });
    this.settingPageModel?.groups?.push(model);
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
    let model: SettingGroupModel = {
      id: 'wifi_config_ip_group',
      type: GroupType.GROUP_TYPE_STANDARD,
      cached: false,
      visible: true,
      items: [
        ...items,
      ]
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

  // 安全性菜单组
  private addSecurityMenusGroup(): void {
    let model: SettingGroupModel = {
      id: 'key_security_group',
      type: GroupType.GROUP_TYPE_STANDARD,
      cached: false,
      visible: true,
      items: [
        this.createSecurityModel(),
      ]
    };
    this.settingPageModel?.groups?.push(model);
  }

  // 密码类型
  private addWapiPskPasswordMenus(): void {
    let model: SettingGroupModel = {
      id: WIFI_WAPI_PSK_PASSWORD_TYPE + MENU_SECTION_POSTFIX,
      type: GroupType.GROUP_TYPE_DYNAMIC,
      cached: false,
      visible: false,
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

  // 阶段2身份验证菜单组
  private addEapPhase2Menus(): void {
    let controller = new EapPhase2Controller();
    let model: SettingGroupModel = WifiMenuManager.getEapPhase2Group(false, controller);
    this.settingPageModel?.groups?.push(model);
  }

  // 安全性
  private createSecurityModel(): SettingItemModel {
    return {
      id: 'key_security_selector',
      type: ItemType.ITEM_TYPE_STANDARD,
      title: {
        content: $r('app.string.wifi_security'),
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
            $r('app.string.wifi_proxy_settings_none'),
            $r('app.string.wifi_security_wpa_wpa2_wpa3_ft_psk'),
            $r('app.string.wifi_security_eap'),
            $r('app.string.wifi_wapi_psk'),
            $r('app.string.wifi_wapi_cert')],
          selectIcon: $r('app.media.ic_selected_ok'),
          onSelected: (index) => {
            this.onSafetySelected(index);
          },
          defaultFocus: 0,
        }
      },
      result: {
        type: ItemResultType.RESULT_TYPE_TEXT,
        result: {
          content: $r('app.string.wifi_proxy_settings_none'),
        }
      }
    };
  }

  private onSafetySelected(index: number): void {
    this.setWindowPrivacyMode(index !== 0);
    let config: wifiManager.WifiDeviceConfig | undefined = this.addOtherWlanConfigManager.wifiConfig;
    if (!config) {
      LogUtil.error(`${this.tag} wifi_security options selected error.`);
      return;
    }
    let securityNames: ResourceStr[] = Array.from(SECURITY_NAME_VALUE_MAP.keys());
    config.securityType = SECURITY_NAME_VALUE_MAP.get(securityNames[index]) ?? 0;
    EventBus.getInstance().emit(SECURITY_CHANGE_EVENT);
    EventBus.getInstance().emit(WLAN_CONFIG_INPUT_CHANGE_EVENT);
    // WIFI_SEC_TYPE_WAPI_PSK 显示密码类型菜单，否则隐藏
    this.showOrHidePswTypeGroup(config.securityType === wifiManager.WifiSecurityType.WIFI_SEC_TYPE_WAPI_PSK);
    // 显示隐藏证书菜单
    this.showOrHideWapiCertMenuGroup(config.securityType ===
    wifiManager.WifiSecurityType.WIFI_SEC_TYPE_WAPI_CERT);
    // 显示隐藏EAP菜单
    this.showOrHideEapMethodGroup(config.securityType === wifiManager.WifiSecurityType.WIFI_SEC_TYPE_EAP);
    // 显示隐藏用户证书
    this.showOrHideUserCertificateGroup(config.securityType ===
    wifiManager.WifiSecurityType.WIFI_SEC_TYPE_EAP &&
      this.wifiConfig?.eapConfig?.eapMethod === wifiManager.EapMethod.EAP_TLS);
    // 加密方式为EAP且EAP方式为SIM时，显示SIM卡槽
    this.showOrHideEapSimSelectGroup(this.wifiConfig?.securityType == wifiManager.WifiSecurityType.WIFI_SEC_TYPE_EAP &&
      this.wifiConfig?.eapConfig?.eapMethod == wifiManager.EapMethod.EAP_SIM);
  }

  // AS 认证菜单
  private addWapiCertAsCertificateMenus(): void {
    let menu: SettingGroupModel = WifiMenuManager.addWapiCertAsCertificateMenus(false, () => {
      this.clickWapiCertAsCertificate(true);
    });
    this.settingPageModel?.groups?.push(menu);
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

  // 用户证书
  private addWapiCertUserCertificateMenus(): void {
    let menu: SettingGroupModel = WifiMenuManager.addWapiCertUserCertificate(false, () => {
      this.clickWapiCertAsCertificate(false);
    })
    this.settingPageModel?.groups?.push(menu);
  }

  private addPasswordMenus(): void {
    let passwordMenu: SettingGroupModel = {
      id: 'add_other_wlan_wifi_password_input',
      type: GroupType.GROUP_TYPE_CUSTOM,
      visible: false,
      builder: wrapBuilder(wlanPasswordBuilder),
    };
    this.settingPageModel?.groups?.push(passwordMenu);
  }

  private onMacTypeSelectChanged(type: number): void {
    let config: wifiManager.WifiDeviceConfig | undefined = this.addOtherWlanConfigManager.wifiConfig;
    if (config) {
      config.randomMacType = type;
    }
  }

  private addNameInputGroup(): void {
    let passwordMenu: SettingGroupModel = {
      id: 'key_input_wifi_ssid',
      type: GroupType.GROUP_TYPE_CUSTOM,
      visible: true,
      builder: wrapBuilder(wlanNameInputBuilder),
    };
    this.settingPageModel?.groups?.push(passwordMenu);
  }

  private addEapPasswordMenus(): void {
    let passwordMenu: SettingGroupModel = {
      visible: false,
      id: 'add_other_wlan_wifi_eap_password',
      type: GroupType.GROUP_TYPE_CUSTOM,
      builder: wrapBuilder(wlanPasswordBuilder),
    };
    this.settingPageModel?.groups?.push(passwordMenu);
  }

  private addEapSimCardSlot(): void {
    let config: wifiManager.WifiDeviceConfig | undefined = AddOtherWlanConfigManager.getInstance().wifiConfig;
    if (!sim.hasSimCardSync(SIM_SLOT_0) || !sim.hasSimCardSync(SIM_SLOT_1)) {
      LogUtil.info(`${TAG} no need show sim select section`);
      WifiMenuManager.setEapConfigForSingleSimCard(config);
      return;
    }
    let model: SettingGroupModel = WifiMenuManager.getEapSimCardSlotGroup(false,
      new EapSimCardSlotController(config?.eapConfig));
    this.settingPageModel?.groups?.push(model);
  }

  private showOrHidePswTypeGroup(isShow: boolean): void {
    LogUtil.info(`${TAG} showOrHidePswTypeGroup: ${isShow}`);
    notifyCompStateChange(`${PageRouter.getRouterName()}.add_other_wlan_config.wifi_wapi_psk_password_type_section`,
      new Map<SettingStateType, SettingBaseState>([[SettingStateType.STATE_TYPE_GROUP_VISIBLE, {
        state: isShow
      } as SettingCompState]]
      ));
  }

  private showOrHideUserCertificateGroup(isShow: boolean): void {
    LogUtil.info(`${TAG} showOrHideUserCertificateGroup: ${isShow}`);
      notifyCompStateChange(`${PageRouter.getRouterName()}.add_other_wlan_config.wifi_eap_user_certificate_section`,
      new Map<SettingStateType, SettingBaseState>([[SettingStateType.STATE_TYPE_GROUP_VISIBLE, {
        state: isShow
      } as SettingCompState]]
      ));
  }

  private showOrHideEapSimSelectGroup(isShow: boolean): void {
    LogUtil.info(`${TAG} showOrHideEapSimSelectGroup: ${isShow}`);
    let compId = `${this.compId}.${WIFI_EAP_SIM_SELECT + MENU_SECTION_POSTFIX}`;
    notifyCompStateChange(compId,
      new Map<SettingStateType, SettingBaseState>([[SettingStateType.STATE_TYPE_GROUP_VISIBLE, {
        state: isShow
      } as SettingCompState]]));
  }

  private showOrHideEapMethodGroup(isShow: boolean): void {
    LogUtil.info(`${TAG} showOrHideEapMethodGroup: ${isShow}`);
    notifyCompStateChange(`${PageRouter.getRouterName()}.add_other_wlan_config.wifi_eap_method_section`,
      new Map<SettingStateType, SettingBaseState>([[SettingStateType.STATE_TYPE_GROUP_VISIBLE, {
        state: isShow
      } as SettingCompState]]
      ));
    // 阶段2身份认证
    notifyCompStateChange(`${PageRouter.getRouterName()}.add_other_wlan_config.wifi_eap_select_phase2_section`,
      new Map<SettingStateType, SettingBaseState>([[SettingStateType.STATE_TYPE_GROUP_VISIBLE, {
        state: isShow
      } as SettingCompState]]
      ));
    // CA证书
    notifyCompStateChange(`${PageRouter.getRouterName()}.add_other_wlan_config.wifi_eap_ca_certificate_section`,
      new Map<SettingStateType, SettingBaseState>([[SettingStateType.STATE_TYPE_GROUP_VISIBLE, {
        state: isShow
      } as SettingCompState]]
      ));
    // 身份
    notifyCompStateChange(`${PageRouter.getRouterName()}.add_other_wlan_config.wifi_eap_input_menu_group`,
      new Map<SettingStateType, SettingBaseState>([[SettingStateType.STATE_TYPE_GROUP_VISIBLE, {
        state: isShow
      } as SettingCompState]]
      ));
  }

  private showOrHideWapiCertMenuGroup(isShow: boolean): void {
    LogUtil.info(`${TAG} showOrHideWapiCertMenuGroup: ${isShow}`);
    notifyCompStateChange(`${PageRouter.getRouterName()}.add_other_wlan_config.wifi_wapi_cert_user_certificate_section`,
      new Map<SettingStateType, SettingBaseState>([[SettingStateType.STATE_TYPE_GROUP_VISIBLE, {
        state: isShow
      } as SettingCompState]]
      ));
    notifyCompStateChange(`${PageRouter.getRouterName()}.add_other_wlan_config.wifi_wapi_cert_as_certificate_section`,
      new Map<SettingStateType, SettingBaseState>([[SettingStateType.STATE_TYPE_GROUP_VISIBLE, {
        state: isShow
      } as SettingCompState]]
      ));
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

  private onEapMethodChanged(index: number): void {
    if (this.wifiConfig?.eapConfig) {
      let eapMethods: ResourceStr [] = Array.from(EAP_NAME_VALUE_MAP.keys());
      this.wifiConfig.eapConfig.eapMethod = EAP_NAME_VALUE_MAP.get(eapMethods[index]) ?? wifiManager.EapMethod.EAP_PEAP;
      EventBus.getInstance().emit(EAP_METHOD_CHANGED_EVENT);
      EventBus.getInstance().emit(WLAN_CONFIG_INPUT_CHANGE_EVENT);
    }
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
      `${PageRouter.getRouterName()}.add_other_wlan_config.wifi_wapi_cert_user_certificate_section.wifi_wapi_cert_user_certificate`;
    if (isAsCertificate) {
      id = `${PageRouter.getRouterName()}.add_other_wlan_config.wifi_wapi_cert_as_certificate_section.wifi_wapi_cert_as_certificate`;
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

  private setWindowPrivacyMode(isPrivacyMode: boolean): void {
    PasswordUtil.setWindowPrivacyMode((AppStorage.get<window.WindowStage>('windowStage') as
      window.WindowStage), isPrivacyMode);
  }
}

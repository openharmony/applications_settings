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
import wifiManager from '@ohos.wifiManager';
import { NavEntryKey } from '@ohos/settings.common/src/main/ets/utils/Consts';
import {
  CompCtrlParam,
  ComponentControl,
  SettingBaseModel
} from '@ohos/settings.common/src/main/ets/framework/model/SettingBaseModel';
import { GroupType, SettingGroupModel } from '@ohos/settings.common/src/main/ets/framework/model/SettingGroupModel';
import {
  ItemDetailType,
  ItemResultType,
  ItemType,
  SettingItemModel
} from '@ohos/settings.common/src/main/ets/framework/model/SettingItemModel';
import { SettingPageModel } from '@ohos/settings.common/src/main/ets/framework/model/SettingPageModel';
import { PageRouter } from '@ohos/settings.common/src/main/ets/framework/common/PageRouter';
import { LogUtil } from '@ohos/settings.common/src/main/ets/utils/LogUtil';
import { LanguageUtils } from '@ohos/settings.common/src/main/ets/utils/LanguageUtils';
import {
  notifyCompStateChange,
  SettingResultState,
  SettingStateType
} from '@ohos/settings.common/src/main/ets/framework/model/SettingStateModel';
import { EventBus } from '@ohos/settings.common/src/main/ets/framework/common/EventBus';
import { StringUtil } from '@ohos/settings.common/src/main/ets/utils/StringUtil';
import { ResourceUtil } from '@ohos/settings.common/src/main/ets/utils/ResourceUtil';
import { WifiDeleteButtonController } from './WifiDeleteButtonController';
import { WifiSetupProxyController } from './WifiSetupProxyController';
import { WifiSetupIpController } from './WifiSetupIpController';
import { WlanQrCodeComponent, WLAN_OR_CODE_REFRESH } from '../../component/WlanQrCodeComponent';
import { AccessPoint, ApMenuConfigData, AVAILABLE_WLAN_DETAIL_CHANGE_EVENT } from '../../model/WifiModel';
import { WifiUtils } from '../../WifiUtils';
import { QrCodeModel } from '../../model/QrCodeModel';
import { ShareWlanController } from './ShareWlanController';
import { WifiAutoReConnectController } from './WifiAutoReConnectController';

const TAG = 'WifiConfigController: ';

@Builder
function qrCodeBuilder(param: object) {
  WlanQrCodeComponent({
    param: param,
  });
}

export class WifiConfigController implements ComponentControl {
  private accessPoint?: AccessPoint;
  private settingPageModel?: SettingPageModel;
  private wifiConfig?: wifiManager.WifiDeviceConfig;
  private shareWlanController: ShareWlanController = new ShareWlanController();
  private apMenu?: ApMenuConfigData;
  private compId: string = '';


  init(compParam: CompCtrlParam): void {
    if (compParam) {
      this.accessPoint = compParam.param as AccessPoint;
      this.compId = compParam.compId as string;
      this.apMenu = this.apToMenu(this.accessPoint) as ApMenuConfigData;
      this.settingPageModel = compParam.component as SettingPageModel;
      this.settingPageModel.title = this.accessPoint?.ssid ?? '';
      this.initWifiConfig();
    }
    // 已保存的WLAN详情
    if (!this.accessPoint?.getSpeed()) {
      this.addAutoReconnectButton();
      this.addDeleteMenu(false);
      this.addApSignalMenuGroup();
      this.addFrequencyMenuGroupSavedWlan();
      this.addIpMenuGroup();
    } else {
      // 已连接的WLAN详情
      this.updateConnectedWifiInfo();

      this.addQrCodeMenu();
      this.addAutoReconnectButton();
      this.addDeleteMenu(true);
      this.addStateMenuGroup();
      this.addFrequencyMenuGroup();
      this.addIpMenuGroup();
    }
  }

  onPageShow(component: SettingBaseModel): void {
    LogUtil.info(`${TAG} onPageShow`);
    this.shareWlanController.onPageShow();
  }

  onPageHide(component: SettingBaseModel): void {
    LogUtil.info(`${TAG} onPageHide`);
    this.shareWlanController.onPageHide();
  }

  initWifiConfig(): void {
    if (!this.accessPoint?.configs) {
      LogUtil.error(`${TAG} initWifiConfig failed.`);
      return;
    }
    this.wifiConfig = this.accessPoint.configs[0];
  }

  private apToMenu(ap: AccessPoint): ApMenuConfigData {
    let apMenuIpConfigData: ApMenuConfigData = {
      ssid: ap?.ssid,
      capabilities: ap?.capabilities,
      securityType: ap?.securityType,
      config: ap?.getBestConfig() as wifiManager.WifiDeviceConfig,
      connState: ap?.lastLinkedInfo?.connState,
    }
    return apMenuIpConfigData;
  }

  private async updateConnectedWifiInfo(): Promise<void> {
    LogUtil.info(`${TAG} start fetchNewestWifiInfo.`);
    let isLinkSpeedChange: boolean = false;
    let newestWifiLinkedInfo = await WifiUtils.getLinkedInfo();
    LogUtil.info(`${TAG} oldNetId: ${this.wifiConfig?.netId}, newNetId: ${newestWifiLinkedInfo?.networkId},
      oldSSid: ${WifiUtils.getLogSsidString(this.wifiConfig?.ssid)},
      newSsid: ${WifiUtils.getLogSsidString(newestWifiLinkedInfo?.ssid)}`);
    if (this.wifiConfig && newestWifiLinkedInfo && this.wifiConfig.netId === newestWifiLinkedInfo.networkId &&
      this.wifiConfig.ssid === newestWifiLinkedInfo.ssid) {
      isLinkSpeedChange = this.accessPoint?.lastLinkedInfo?.linkSpeed !== newestWifiLinkedInfo.linkSpeed;
      LogUtil.info(`${TAG} fetchNewestWifiInfo success isLinkSpeedChange: ${isLinkSpeedChange}`);
      this.accessPoint?.updateLastLinkedInfo(newestWifiLinkedInfo);
    }
    if (isLinkSpeedChange) {
      let linkSpeed: string = ResourceUtil.getFormatStringSync($r('app.string.wifi_link_speed'),
        LanguageUtils.getNumberFormat(WifiUtils.getMaxLinkSpeed(this.accessPoint)));
      notifyCompStateChange(`${this.compId}.wifi_config_group_one.ap_connected_speed`,
        new Map<SettingStateType, SettingResultState>([[SettingStateType.STATE_TYPE_ITEM_RESULT,
          { type: ItemResultType.RESULT_TYPE_TEXT, result: { content: linkSpeed } } as SettingResultState]]));
    }
    let newestConfig: wifiManager.WifiDeviceConfig | undefined = undefined;
    try {
      let configs: wifiManager.WifiDeviceConfig[] = wifiManager.getDeviceConfigs();
      LogUtil.info(`${TAG} wifiManager getDeviceConfigs.length: ${configs?.length}`);
      if (!configs || configs.length <= 0) {
        return;
      }
      for (let config of configs) {
        if (newestWifiLinkedInfo?.ssid === config.ssid && newestWifiLinkedInfo?.networkId === config.netId) {
          LogUtil.info(`${TAG} getDeviceConfigs success: ${WifiUtils.getLogSsidString(config.ssid)}, netId: ${config.netId}`);
          newestConfig = config;
        }
      }
    } catch (error) {
      LogUtil.error(`${TAG} wifiManager getDeviceConfigs failed: ${error?.message}`);
    }
    LogUtil.info(`${TAG} newSecurityType is: ${newestConfig?.securityType}, old is: ${this.accessPoint?.securityType}`);
    if (this.accessPoint && newestConfig && this.accessPoint.securityType !== newestConfig.securityType) {
      this.accessPoint.securityType = newestConfig?.securityType ?? 0;
      let apSecurityString: ResourceStr = WifiUtils.getApSecurityString(newestConfig?.securityType ?? 0) ??
        $r('app.string.wifi_security_open');
      notifyCompStateChange('Setting.wifi_config_menu.wifi_config_group_second.ap_security_type',
        new Map<SettingStateType, SettingResultState>([[SettingStateType.STATE_TYPE_ITEM_RESULT,
          { type: ItemResultType.RESULT_TYPE_TEXT, result: { content: apSecurityString } } as SettingResultState]]));
      if (newestConfig) {
        EventBus.getInstance().emit(WLAN_OR_CODE_REFRESH, this.getQrCodeString(newestConfig));
      }
    }
  }

  destroy(): void {
  }

  onClick(component: SettingBaseModel): void {
  }

  addQrCodeMenu(): void {
    this.shareWlanController.setAccessPoint(this.accessPoint);
    let wifiDeviceConfig = this.accessPoint?.getBestConfig() as wifiManager.WifiDeviceConfig;
    if (wifiDeviceConfig && WifiUtils.isSupportQrcodeShare(wifiDeviceConfig.securityType) &&
      !this.accessPoint?.isHidden()) {
      let qrCodeString = this.getQrCodeString(wifiDeviceConfig);
      let qrCodeModel: QrCodeModel = {
        id: 'qr_code',
        type: GroupType.GROUP_TYPE_CUSTOM,
        cached: false,
        visible: true,
        qrCodeString: qrCodeString,
        builder: wrapBuilder(qrCodeBuilder),
      };
      this.settingPageModel?.groups?.push(qrCodeModel);
    }
  }

  private getQrCodeString(wifiDeviceConfig: wifiManager.WifiDeviceConfig): string {
    let securityType: string = WifiUtils.securityType2str(wifiDeviceConfig.securityType);
    let ssid: string = wifiDeviceConfig.ssid;
    let preSharedKey: string = wifiDeviceConfig.preSharedKey;
    return `WIFI:T:${securityType};S:${StringUtil.escapeSpecialCharacters(ssid)};P:${StringUtil.escapeSpecialCharacters(preSharedKey)};;`;
  }

  addAutoReconnectButton(): void {
    LogUtil.info(`${TAG} addAutoReconnectButton`);
    let switchState: boolean = true;
    if (this.wifiConfig) {
      switchState =
        WifiUtils.getConfig(this.wifiConfig.ssid, this.wifiConfig.securityType)?.isAutoConnectAllowed ?? true;
    }
    LogUtil.info(`${TAG} addAutoReconnectButton ${switchState}`);
    let addAutoReconnectModel: SettingGroupModel = {
      id: 'wifi_auto_reconnect',
      type: GroupType.GROUP_TYPE_STANDARD,
      cached: false,
      visible: true,
      items: [
        {
          id: 'ap_auto_reconnect_type',
          type: ItemType.ITEM_TYPE_STANDARD,
          title: { content: $r('app.string.wifi_auto_reconnect_settings'), },
          result: { type: ItemResultType.RESULT_TYPE_TOGGLE, result: { state: switchState } },
          compControl: new WifiAutoReConnectController(this.accessPoint?.getBestConfig()),
        }
      ]
    };
    this.settingPageModel?.groups?.push(addAutoReconnectModel);
  }

  addDeleteMenu(isConnectedWlan: boolean): void {
    let deleteMenuModel: SettingGroupModel = {
      id: 'wifi_delete',
      type: GroupType.GROUP_TYPE_STANDARD,
      cached: false,
      visible: true,
      items: [
        {
          id: NavEntryKey.ADD_OTHER_WIFI_ENTRY,
          type: ItemType.ITEM_TYPE_STANDARD,
          compControl: new WifiDeleteButtonController(this.accessPoint?.getBestConfig(), isConnectedWlan),
          title: {
            content: $r('app.string.wifi_delete'),
            style: {
              fontColor: $r('sys.color.warning')
            }
          }
        }
      ]
    };
    this.settingPageModel?.groups?.push(deleteMenuModel);
  }

  addStateMenuGroup(): void {
    let stateModel: SettingGroupModel = {
      id: 'wifi_config_group_one',
      type: GroupType.GROUP_TYPE_STANDARD,
      cached: false,
      visible: true,
      items: [
        {
          id: 'ap_state',
          type: ItemType.ITEM_TYPE_STANDARD,
          title: {
            content: $r('app.string.wifi_connect_status_title'),
            style: {
              fontColor: $r('sys.color.font_primary')
            }
          },
          result: {
            type: ItemResultType.RESULT_TYPE_TEXT,
            result: {
              content: $r('app.string.wifi_status_connected'),
            }
          }
        },
        this.createApSignalLevelModel(),
        {
          id: 'ap_connected_speed',
          type: ItemType.ITEM_TYPE_STANDARD,
          title: {
            content: $r('app.string.wifi_connect_speed_title'),
            style: {
              fontColor: $r('sys.color.font_primary'),
            }
          },
          result: {
            type: ItemResultType.RESULT_TYPE_TEXT,
            result: {
              content: ResourceUtil.getFormatStringSync($r('app.string.wifi_link_speed'),
                LanguageUtils.getNumberFormat(WifiUtils.getMaxLinkSpeed(this.accessPoint))),
            }
          }
        }
      ]
    };
    this.settingPageModel?.groups?.push(stateModel);
  }

  private addFrequencyMenuGroupSavedWlan(): void {
    let model: SettingGroupModel = {
      id: 'wifi_config_group_second_save_wlan',
      type: GroupType.GROUP_TYPE_STANDARD,
      cached: false,
      visible: true,
      items: [
        this.createPrivacyModel()
      ]
    };
    this.settingPageModel?.groups?.push(model);
  }

  addFrequencyMenuGroup(): void {
    let model: SettingGroupModel = {
      id: 'wifi_config_group_second',
      type: GroupType.GROUP_TYPE_STANDARD,
      cached: false,
      visible: true,
      items: [
        {
          id: 'ap_connected_frequency',
          type: ItemType.ITEM_TYPE_STANDARD,
          title: {
            content: $r('app.string.wifi_frequency'),
            style: {
              fontColor: $r('sys.color.font_primary')
            }
          },
          result: {
            type: ItemResultType.RESULT_TYPE_TEXT,
            result: {
              content: WifiUtils.getMultiFrequencyString(this.accessPoint) ??
              $r('app.string.wifi_wifi_frequency_2g'),
            }
          }
        },
        this.createApSecurityTypeModel(),
        this.createApMacAddressModel(),
        this.createApIpAddressModel(),
        this.createPrivacyModel()
      ]
    };
    this.settingPageModel?.groups?.push(model);
  }

  addApSignalMenuGroup(): void {
    let model: SettingGroupModel = {
      id: 'ap_signal_security_type',
      type: GroupType.GROUP_TYPE_STANDARD,
      cached: false,
      visible: true,
      items: [
        this.createApSignalLevelModel(),
        this.createApSecurityTypeModel(),
      ]
    };
    this.settingPageModel?.groups?.push(model);
  }

  addIpMenuGroup(): void {
    let wifiSetupProxyController = new WifiSetupProxyController(this.accessPoint?.getBestConfig(), this.apMenu);
    let wifiSetupIpController = new WifiSetupIpController(this.accessPoint?.getBestConfig(), this.apMenu);
    let model: SettingGroupModel = {
      id: 'wifi_config_group_three',
      type: GroupType.GROUP_TYPE_STANDARD,
      cached: false,
      visible: true,
      items: [
        {
          id: NavEntryKey.WIFI_SETUP_PROXY_ENTRY,
          type: ItemType.ITEM_TYPE_STANDARD,
          title: {
            content: $r('app.string.wifi_proxy_settings_title'),
            style: {
              fontColor: $r('sys.color.font_primary')
            }
          },
          compControl: wifiSetupProxyController,
          detail: {
            type: ItemDetailType.DETAIL_TYPE_CUSTOM,
            destination: NavEntryKey.WIFI_SETUP_PROXY_ENTRY,
            icon: $r('sys.symbol.chevron_right'),
            isSymbolIcon: true,
            onItemClick: () => {
              wifiSetupProxyController.onClick();
            }
          },
          result: {
            type: ItemResultType.RESULT_TYPE_TEXT,
            result: {
              content: this.getProxyString(),
            }
          }
        },
        {
          id: NavEntryKey.WIFI_SETUP_IP_ENTRY,
          type: ItemType.ITEM_TYPE_STANDARD,
          title: {
            content: $r('app.string.wifi_ip_settings_title'),
            style: {
              fontColor: $r('sys.color.font_primary')
            }
          },
          compControl: wifiSetupIpController,
          detail: {
            type: ItemDetailType.DETAIL_TYPE_CUSTOM,
            destination: NavEntryKey.WIFI_SETUP_IP_ENTRY,
            icon: $r('sys.symbol.chevron_right'),
            isSymbolIcon: true,
            onItemClick: () => {
              wifiSetupIpController.onClick();
            }
          },
          result: {
            type: ItemResultType.RESULT_TYPE_TEXT,
            result: {
              content: this.getIpString(),
            }
          }
        }
      ]
    };
    this.settingPageModel?.groups?.push(model);
  }

  createApSignalLevelModel(): SettingItemModel {
    return {
      id: 'ap_signal_level',
      type: ItemType.ITEM_TYPE_STANDARD,
      title: {
        content: $r('app.string.wifi_signal_level'),
        style: {
          fontColor: $r('sys.color.font_primary')
        }
      },
      result: {
        type: ItemResultType.RESULT_TYPE_TEXT,
        result: {
          content: WifiUtils.getApSignalString(this.accessPoint?.bestLevel ?? 0) ??
          $r('app.string.wifi_signal_poor'),
        }
      }
    };
  }

  createApSecurityTypeModel(): SettingItemModel {
    return {
      id: 'ap_security_type',
      type: ItemType.ITEM_TYPE_STANDARD,
      title: {
        content: $r('app.string.wifi_security_type'),
        style: {
          fontColor: $r('sys.color.font_primary'),
        }
      },
      result: {
        type: ItemResultType.RESULT_TYPE_TEXT,
        result: {
          content: WifiUtils.getApSecurityString(this.accessPoint?.securityType ?? 0) ??
          $r('app.string.wifi_security_open'),
        }
      }
    };
  }

  createApMacAddressModel(): SettingItemModel {
    return {
      id: 'mac_address_title',
      type: ItemType.ITEM_TYPE_STANDARD,
      title: {
        content: $r('app.string.wifi_mac_address_title'),
        style: {
          fontColor: $r('sys.color.font_primary')
        }
      },
      result: {
        type: ItemResultType.RESULT_TYPE_TEXT,
        result: {
          content: this.accessPoint ? this.accessPoint.getMacAddress() : '',
          style: { copyOption: CopyOptions.LocalDevice },
        }
      }
    };
  }

  createApIpAddressModel(): SettingItemModel {
    return {
      id: 'ap_ip_address',
      type: ItemType.ITEM_TYPE_STANDARD,
      title: {
        content: $r('app.string.wifi_ip_address'),
        style: {
          fontColor: $r('sys.color.font_primary')
        }
      },
      result: {
        type: ItemResultType.RESULT_TYPE_TEXT,
        result: {
          content: WifiUtils.getIPInfo(),
          style: {
            direction: LanguageUtils.isLtrDirection() ? Direction.Ltr : Direction.Rtl
          },
        }
      }
    };
  }

  createPrivacyModel(): SettingItemModel {
    return {
      id: 'ap_privacy_type',
      type: ItemType.ITEM_TYPE_STANDARD,
      title: {
        content: $r('app.string.wifi_privacy_settings'),
        style: {
          fontColor: $r('sys.color.font_primary'),
        }
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
            this.onMacTypeSelectChanged(index);
          },
          defaultFocus: this.wifiConfig?.randomMacType ?? 0
        }
      },
      result: {
        type: ItemResultType.RESULT_TYPE_TEXT,
        result: {
          content: this.getMacType(),
        }
      }
    };
  }

  private getProxyString(): ResourceStr {
    let wifiConfig = this.accessPoint?.getBestConfig() as wifiManager.WifiDeviceConfig;
    if (wifiConfig?.proxyConfig?.proxyMethod === wifiManager.ProxyMethod.METHOD_MANUAL) {
      return $r('app.string.wifi_proxy_settings_manual');
    } else if (wifiConfig?.proxyConfig?.proxyMethod === wifiManager.ProxyMethod.METHOD_AUTO) {
      return $r('app.string.wifi_proxy_settings_auto');
    } else {
      return $r('app.string.wifi_proxy_settings_none');
    }
  }

  private getIpString(): ResourceStr {
    let wifiConfig = this.accessPoint?.getBestConfig() as wifiManager.WifiDeviceConfig;
    if (wifiConfig?.ipType === wifiManager.IpType.DHCP) {
      return $r('app.string.wifi_ip_settings_dhcp');
    } else {
      return $r('app.string.wifi_ip_settings_static');
    }
  }

  private getMacType(): ResourceStr {
    if (this.wifiConfig?.randomMacType === wifiManager.DeviceAddressType.REAL_DEVICE_ADDRESS) {
      return $r('app.string.wifi_privacy_device');
    }
    return $r('app.string.wifi_privacy_random');
  }

  private onMacTypeSelectChanged(type: number): void {
    if (!this.wifiConfig) {
      LogUtil.error(`${TAG} type change failed, as wifiConfig is undefined.`);
      return;
    }
    LogUtil.info(`${TAG} onSelectMenuChanged data = ${type} connState ${this.apMenu?.connState}`);
    this.wifiConfig.randomMacType = type;
    if (this.apMenu?.connState === wifiManager.ConnState.CONNECTED) {
      WifiUtils.reconnectWithNewConfig(TAG, this.wifiConfig);
    } else {
      EventBus.getInstance().emit(AVAILABLE_WLAN_DETAIL_CHANGE_EVENT, this.apMenu);
    }
    PageRouter.pop('Setting');
  }
}
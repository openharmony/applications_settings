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

import connection from '@ohos.net.connection';
import wifiManager from '@ohos.wifiManager';
import {
  DialogButtonMenuController,
  MenuController
} from '@ohos/settings.common/src/main/ets/core/controller/MenuController';
import { SettingsBaseMenu } from '@ohos/settings.common/src/main/ets/core/model/menu/SettingsMenu';
import { LogUtil } from '@ohos/settings.common/src/main/ets/utils/LogUtil';
import { Controller, PushParam } from '@ohos/settings.common/src/main/ets/core/controller/Controller';
import { SettingsDataUtils } from '@ohos/settings.common/src/main/ets/utils/SettingsDataUtils';
import { HiSysEventUtil } from '@ohos/settings.common/src/main/ets/systemEvent/HiSysEventUtil';
import { NavEntryKey } from '@ohos/settings.common/src/main/ets/utils/Consts';
import { ContainerStyle, ImageStyle } from '@ohos/settings.common/src/main/ets/core/model/menu/ComponetStyle';
import { CheckEmptyUtils } from '@ohos/settings.common/src/main/ets/utils/CheckEmptyUtils';
import { AccessPoint, CONNECTED_AP_KEY, ConnectedApBaseController, wifiTracker, WifiUtils } from '@ohos/settings.wifi';
import {
  ButtonMenu,
  DefaultEntryMenuStyle,
  DialogPage,
  DialogTitleMenu,
  DividerMenuGroup,
  EntryMenu,
  RootContainerStyle,
  StateIconStyle,
  StateMenu,
  TransparentButtonMenuStyle
} from '@ohos/settings.uikit';
import {
  ButtonMenuContainerStyle,
  EntryMenuData,
  NewTitleTextStyle,
  WifiDialogTitleMenuStyle
} from '@ohos/settings.uikit/src/main/ets/menus/Menu';
import settings from '@ohos.settings';
import { HiSysWlanEvenGroup } from '@ohos/settings.common/src/main/ets/systemEvent/BehaviorEventConsts';

/* instrument ignore file */
const TAG: string = 'WifiConnectedApController : ';
const SMART_HOTSPOT_KEY: string = 'smartHotSpot';
const SETTINGS_SWITCH_WLAN_LOGS: string = 'settings.switch_wlan_logs';

// represents the network connection handle.
const netCon: connection.NetConnection = connection.createNetConnection({
  netCapabilities: {
    bearerTypes: [connection.NetBearType.BEARER_WIFI]
  }
});

/**
 * 已连接Wifi段信息展示控制器
 *
 * @since 2022-03-21
 */
export default class WifiConnectedApController extends ConnectedApBaseController {
  static CreateWifiConnectedApController(menu: SettingsBaseMenu): Controller {
    return new WifiConnectedApController(menu);
  }

  protected getConnectedApMenu(): SettingsBaseMenu | null {
    if (!this.accessPoint) {
      LogUtil.info(`${TAG} accessPoint invalid`);
      return null;
    }
    let lastLinkedInfo: wifiManager.WifiLinkedInfo = this.accessPoint.lastLinkedInfo as wifiManager.WifiLinkedInfo;
    let getWifiInfoDescription: string = '';
    let isWlanLog: boolean = SettingsDataUtils.getSettingsData(SETTINGS_SWITCH_WLAN_LOGS, 'false') === 'true';
    if (lastLinkedInfo && isWlanLog) {
      getWifiInfoDescription = `f=${lastLinkedInfo?.frequency} ${lastLinkedInfo?.bssid}\n` +
        `rssi=${lastLinkedInfo?.rssi} tx=${lastLinkedInfo?.linkSpeed} ${lastLinkedInfo?.rxLinkSpeed} ` +
        `rx=${lastLinkedInfo?.maxSupportedRxLinkSpeed}`;
    }
    let menu = new ConnectApMenu({
      key: CONNECTED_AP_KEY + this.accessPoint.apKey,
      index: 0,
      timestamp: Math.random(),
      title: this.accessPoint.getTitle(),
      summary: this.accessPoint.getSummary(),
      stateIcon: this.accessPoint.getStateIcon(),
      accessPoint: this.accessPoint,
      state: getWifiInfoDescription,
      status: isWlanLog,
      controller: {
        createControllerConstructorInter: ConnectApController.CreateConnectApController,
      },
    });
    menu.pathInfos = this.menu.pathInfos;
    return menu;
  }
}

/**
 * 已连接智能热点设备信息展示控制器
 */
export class HotSpotConnectedApController {
  static getConnectedApMenu(accessPoint: AccessPoint): SettingsBaseMenu | null {
    if (!accessPoint) {
      LogUtil.info(`${TAG} accessPoint invalid`);
      return null;
    }
    let menu = new ConnectApMenu({
      key: CONNECTED_AP_KEY + accessPoint.apKey,
      index: 0,
      timestamp: Math.random(),
      title: accessPoint.getTitle(),
      summary: accessPoint.getSummary(),
      stateIcon: accessPoint.getStateIcon(),
      accessPoint: accessPoint,
      controller: {
        createControllerConstructorInter: ConnectApController.CreateConnectApController,
      },
    });
    menu.isSmartHotSpot = true;
    return menu;
  }
}

export interface ConnectApMenuData extends EntryMenuData {
  accessPoint: AccessPoint;
}

/**
 * 已连接Ap菜单数据类
 *
 * @since 2022-03-21
 */
export class ConnectApMenu extends EntryMenu implements ConnectApMenuData {
  public accessPoint: AccessPoint;
  public isSmartHotSpot: boolean;

  constructor(menu: Partial<ConnectApMenuData>) {
    super(menu);
    if (!menu.style) {
      this.style = wifiApStyle;
    }
    this.accessPoint = menu.accessPoint as AccessPoint;
    this.isNeedShowIcon = this.accessPoint?.isHiLinkNetwork as boolean;
    this.isSmartHotSpot = false;
  }

  getLogKey(): string {
    return WifiUtils.getApLogKey(this.accessPoint?.ssid, this.accessPoint?.securityType);
  }
}

class ApStateIconStyle extends StateIconStyle {
  public size: SizeOptions = {
    width: '24vp',
    height: '24vp',
  };
  public borderRadius = 0;
  public margin: Margin = {};
  public imageFit = ImageFit.Contain;
  public fillColor = $r('sys.color.ohos_id_color_secondary');
}

class ApSecondStateContainerStyle extends ContainerStyle {
  public margin: Margin = {
    left: 0,
  };
}

class ApContainerStyle extends RootContainerStyle {
  public constraintSize: ConstraintSizeOptions = {
    minHeight: '64vp',
  };
  public padding: Padding = {
    left: $r('app.float.padding_8'),
  };
}

export class ApTitleTextStyle extends NewTitleTextStyle {
  public fontColor: ResourceColor = $r('sys.color.ohos_id_color_text_hyperlink');
}

let titleTextStyle = new ApTitleTextStyle();

/**
 * 已连接Ap菜单样式
 *
 * @since 2022-03-21
 */
class WifiApStyle extends DefaultEntryMenuStyle {
  public rootContainer: ContainerStyle = new ApContainerStyle();
  public title = titleTextStyle;
  public stateIcon: ImageStyle = new ApStateIconStyle();
  public secondStateContainer = new ApSecondStateContainerStyle();
  public secondStateIcon: ImageStyle = new ApStateIconStyle();
}

class WifiButtonStyle extends ButtonMenuContainerStyle {
  public margin: Margin = { top: '8vp', bottom: '16vp' };
}

class ButtonStyle extends TransparentButtonMenuStyle {
  public rootContainer = new WifiButtonStyle();
}

let wifiApStyle = new WifiApStyle();

/**
 * 已连接Ap菜单控制器
 *
 * @since 2022-03-21
 */
class ConnectApController extends MenuController {
  public tag: string = 'ConnectApController : ';
  public onWifiRssiChange = (state: number): void => {
    if (!this.isRegister) {
      return;
    }
    if (this.isNetworkUnavailable) {
      LogUtil.info(`${this.tag} network unavailable, don't update icon by signal, return.`);
      return;
    }
    LogUtil.info(`${TAG} wifi rssi change : ${state}`);
    // 返回以dBm为单位的RSSI值
    this.updateLinkedInfo();
  };

  private isPortalUnauthenticated: boolean = false;
  private isNetworkUnavailable: boolean = false;
  private onNetCapabilitiesChange = (data: connection.NetCapabilityInfo): void => {
    let caps = data?.netCap?.networkCap;
    let bearerTypes = data?.netCap?.bearerTypes;
    LogUtil.info(`${this.tag} netCapabilitiesChange, bearerTypes: ${bearerTypes?.join(',')}, caps: ${caps?.join(',')}`);
    if (!WifiUtils.isBearerWifi(bearerTypes)) {
      LogUtil.info(`${this.tag} the network is not wifi, no need to handle.`);
      return;
    }
    if (WifiUtils.isWifiNetworkValidated(caps)) {
      this.isPortalUnauthenticated = false;
      this.isNetworkUnavailable = false;
    } else {
      this.isPortalUnauthenticated = WifiUtils.isPortalWifiNetwork(caps);
      this.isNetworkUnavailable = true;
    }
    if (!(this.menu instanceof ConnectApMenu) || this.menu.isSmartHotSpot) {
      LogUtil.info(`${this.tag} no need to update linked menu state for non-connected menu or smart hotspot.`);
      return;
    }
    this.updateMenuStateInfo();
  };

  static CreateConnectApController(menu: SettingsBaseMenu): Controller {
    return new ConnectApController(menu);
  }

  onMenuClick(): boolean {
    HiSysEventUtil.reportDefaultBehaviorEvent(HiSysWlanEvenGroup.ENTER_CONNECTED_WLAN_ENTRY);
    if (!(this.menu instanceof ConnectApMenu)) {
      LogUtil.error(`${this.tag} menu error`);
      return false;
    }
    if (this.menu.isSmartHotSpot) {
      this.showApDetailDialog();
    } else {
      if (this.isPortalUnauthenticated) {
        LogUtil.info(`${this.tag} onMenuClick: start portal certification.`)
        WifiUtils.startPortalCertification();
        return true;
      }
      this.menu.pushName(NavEntryKey.WIFI_MENU_CONFIG_ENTRY,
        new PushParam(this.menu.accessPoint));
    }
    return true;
  }

  onMenuIconClick(): boolean {
    LogUtil.info(`${this.tag} onMenuIconClick`);
    if (!(this.menu instanceof ConnectApMenu)) {
      LogUtil.error(`${this.tag} menu error`);
      return false;
    }
    if (this.menu.isSmartHotSpot) {
      this.showApDetailDialog();
    } else {
      this.menu.pushName(NavEntryKey.WIFI_MENU_CONFIG_ENTRY, new PushParam(this.menu.accessPoint));
    }
    return true;
  }

  private showApDetailDialog(): void {
    if (!(this.menu instanceof ConnectApMenu)) {
      return;
    }
    let detail = new DialogPage({
      pageUrl: 'pages/wifi/WifiSettings/wifiConnectedApDetail',
    });
    detail.addMenus(
      [
        new DialogTitleMenu(
          {
            key: 'ap_ssid_dialog_title',
            index: 10,
            title: this.menu.accessPoint?.ssid,
            style: new WifiDialogTitleMenuStyle()
          }
        ),
        new DividerMenuGroup(
          {
            key: 'ip_settings_group',
            index: 20,
          },
          [
            new StateMenu(
              {
                key: 'ap_connect_state',
                index: 10,
                title: $r('app.string.wifi_connect_status_title'),
                state: $r('app.string.wifi_status_connected'),
              }
            ),
            new StateMenu(
              {
                key: 'ap_signal_level',
                index: 20,
                title: $r('app.string.wifi_signal_level'),
                state: WifiUtils.getApSignalString(this.menu.accessPoint?.bestLevel ?? 0),
              }
            ),
            new StateMenu(
              {
                key: 'ap_connected_speed',
                index: 30,
                title: $r('app.string.wifi_connect_speed_title'),
                state: this.menu.accessPoint?.getSpeed().toString() + ' Mbps',
              }
            ),
            new StateMenu(
              {
                key: 'ap_connected_frequency',
                index: 40,
                title: $r('app.string.wifi_frequency'),
                state: WifiUtils.getFrequencyString(this.menu.accessPoint?.getFrequency()),
              }
            ),
            new StateMenu(
              {
                key: 'ap_security_type',
                index: 50,
                title: $r('app.string.wifi_security_type'),
                state: WifiUtils.getApSecurityString(this.menu.accessPoint?.securityType ?? 0),
              }
            ),
            new StateMenu(
              {
                key: 'ap_mac_address',
                index: 60,
                title: $r('app.string.wifi_mac_address_title'),
                state: this.menu.accessPoint?.getMacAddress(),
              }
            ),
            new StateMenu(
              {
                key: 'ap_ip_address',
                index: 70,
                title: $r('app.string.wifi_ip_address'),
                state: WifiUtils.number2IpString(this.menu.accessPoint?.getIpAddress()),
              }
            ),
          ]
        ),
        new ButtonMenu(
          {
            key: 'cancel_button',
            menuType: 'DivideButton',
            index: 30,
            buttonTittle1: $r('app.string.button_tittle_cancel'),
            buttonTittle2: $r('app.string.wifi_button_tittle_delete'),
            controller: {
              createControllerConstructorInter: DeleteButtonController.CreateDeleteButtonController,
            },
            style: new ButtonStyle(),
            extra: this.menu.accessPoint?.getBestConfig() as wifiManager.WifiDeviceConfig,
          }
        )
      ]
    );
    this.openDialog(detail, true);
  }

  private async updateMenuStateInfo(): Promise<void> {
    if (!(this.menu instanceof ConnectApMenu)) {
      LogUtil.error(`${this.tag} menu error, update linked menu info failed.`);
      return;
    }
    LogUtil.info(`${this.tag} update linked menu info, portal state: ${this.isPortalUnauthenticated}, network unavailable state: ${this.isNetworkUnavailable}`);
    if (this.isNetworkUnavailable) {
      this.menu.stateIcon = WifiUtils.getNetworkUnavailableStateIcon(this.menu.accessPoint);
      this.menu.summary = WifiUtils.getConnectedSummary(this.isPortalUnauthenticated);
      this.menu.refreshUi();
    } else {
      let lastLinkedInfo: wifiManager.WifiLinkedInfo = await wifiManager.getLinkedInfo();
      if (CheckEmptyUtils.isEmpty(lastLinkedInfo)) {
        LogUtil.warn(`${this.tag} empty lastLinkedInfo, update linked menu failed.`);
        return;
      }
      LogUtil.debug(`${this.tag} update linked menu icon and summary to normal state.`);
      this.menu.accessPoint?.updateLastLinkedInfo(lastLinkedInfo);
      this.menu.stateIcon = this.menu.accessPoint?.getStateIcon();
      this.menu.summary = WifiUtils.getConnectedSummary(false);
      this.menu.refreshUi();
    }
  }

  private async updateLinkedInfo(): Promise<void> {
    let lastLinkedInfo: wifiManager.WifiLinkedInfo = await wifiManager.getLinkedInfo();
    if (lastLinkedInfo && this.menu instanceof ConnectApMenu) {
      LogUtil.info(`${TAG} updateLastLinkedInfo rssi : ${lastLinkedInfo.rssi}`);
      this.menu.accessPoint?.updateLastLinkedInfo(lastLinkedInfo);
      this.menu.stateIcon = this.menu.accessPoint?.getStateIcon();
      this.menu.refreshUi();
    }
  }

  protected registerDataChange(): void {
    WifiUtils.wifiRssiChangeOn(TAG, this.onWifiRssiChange);
    WifiUtils.registerNetCapabilitiesChange(netCon, this.onNetCapabilitiesChange, this.tag);
  }

  protected unRegisterDataChange(): void {
    WifiUtils.wifiRssiChangeOff(TAG, this.onWifiRssiChange);
    WifiUtils.unRegisterNetCapabilitiesChange(netCon, this.tag);
  }
}

/**
 * 删除按钮控制器
 *
 * @since 2022-03-21
 */
export class DeleteButtonController extends DialogButtonMenuController {
  static CreateDeleteButtonController(menu: SettingsBaseMenu): Controller {
    return new DeleteButtonController(menu);
  }

  public tag: string = 'DeleteButtonController : ';
  public config?: wifiManager.WifiDeviceConfig;

  constructor(menu: SettingsBaseMenu) {
    super(menu);
    if ((menu.extra as wifiManager.WifiDeviceConfig)?.ssid) {
      this.config = menu.extra as wifiManager.WifiDeviceConfig;
    }
  }

  onButton2Click(): void {
    HiSysEventUtil.reportDefaultBehaviorEvent(HiSysWlanEvenGroup.DELETE_CONNECTED_WLAN);
    LogUtil.info(`${TAG} onButton2Click`);
    wifiTracker.removeWifiDevice(this.config as wifiManager.WifiDeviceConfig);
    AppStorage.SetOrCreate<string>(SMART_HOTSPOT_KEY, '');
    SettingsDataUtils.setSettingsData(SMART_HOTSPOT_KEY, '');
    this.closeSelf();
  }
}

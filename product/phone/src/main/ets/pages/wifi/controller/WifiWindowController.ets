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
import { CheckEmptyUtils } from '@ohos/settings.common/src/main/ets/utils/CheckEmptyUtils';
import { ContainerStyle, ImageStyle } from '@ohos/settings.common/src/main/ets/core/model/menu/ComponetStyle';
import { Controller } from '@ohos/settings.common/src/main/ets/core/controller/Controller';
import { LogUtil } from '@ohos/settings.common/src/main/ets/utils/LogUtil';
import { MenuController } from '@ohos/settings.common/src/main/ets/core/controller/MenuController';
import { SettingsBaseMenu } from '@ohos/settings.common/src/main/ets/core/model/menu/SettingsMenu';
import { SettingsDataUtils } from '@ohos/settings.common/src/main/ets/utils/SettingsDataUtils';
import { AccessPoint, ApMenu, ApMenuData } from '@ohos/settings.wifi/src/main/ets/model/WifiModel';
import { CONNECTED_AP_KEY, WifiUtils } from '@ohos/settings.wifi/src/main/ets/WifiUtils';
import { WifiWindowBaseController } from '@ohos/settings.wifi/src/main/ets/controller/WifiWindowBaseController';
import {
  DEFAULT_PADDING_START,
  DefaultEntryMenuStyle,
  EntryMenu,
  EntryMenuData,
  RootContainerStyle,
  StateIconStyle,
  TitleTextStyle
} from '@ohos/settings.uikit/src/main/ets/menus/Menu';
import { WifiWindowEntryController } from './WifiWindowEntryController';

const TAG: string = 'WifiWindowController : ';

const SCAN_INTERVAL: number = 10000;

const SCAN_LOADING_INTERVAL: number = 2000;

// represents the network connection handle.
const netCon: connection.NetConnection = connection.createNetConnection({
  netCapabilities: {
    bearerTypes: [connection.NetBearType.BEARER_WIFI]
  }
});

/**
 * 已连Wifi段信息展示控制器
 *
 * @since 2023-03-13
 */
export default class WifiWindowController extends WifiWindowBaseController {
  static CreateWifiWindowController(menu: SettingsBaseMenu): Controller {
    return new WifiWindowController(menu);
  }

  protected getConnectedApMenu(): SettingsBaseMenu | null {
    if (!this.accessPoint) {
      LogUtil.info(`${TAG} accessPoint invalid`);
      return null;
    }
    let menu = new ConnectApMenu({
      key: CONNECTED_AP_KEY + this.accessPoint.apKey,
      index: 0,
      timestamp: Math.random(),
      title: this.accessPoint.getTitle(),
      summary: this.accessPoint.getSummary(),
      stateIcon: this.accessPoint.getStateIcon(),
      accessPoint: this.accessPoint,
      isShowConnected: true,
      controller: {
        createControllerConstructorInter: ConnectApController.CreateConnectApController,
      },
    });
    let smartHotSpot = SettingsDataUtils.getSettingsData('smartHotSpot', '');
    if (this.accessPoint.ssid === smartHotSpot) {
      menu.stateIcon = $r('app.media.ic_notification_hotspot');
      menu.isSmartHotSpot = true;
    }
    return menu;
  }

  protected getScanInternal(): number {
    return SCAN_INTERVAL;
  }

  protected getScanLoadingInternal(): number {
    return SCAN_LOADING_INTERVAL;
  }

  protected createApMenu(item: Partial<ApMenuData>): ApMenu {
    let menu = new ApMenu(item);
    menu.style = wifiEnableStyle;
    menu.isShowConnected = false;
    menu.controller = {
            createControllerConstructorInter: WifiWindowEntryController.createWifiWindowEntryController,
          };
    return menu;
  }
}

export interface ConnectApMenuData extends EntryMenuData {
  accessPoint: AccessPoint;
}
/**
 * 已连接Ap菜单数据类
 *
 * @since 2023-03-13
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
    this.isShowConnected = true;
  }

  getLogKey(): string {
    return WifiUtils.getApLogKey(this.accessPoint?.ssid, this.accessPoint?.securityType);
  }
}

class ApStateIconStyle extends StateIconStyle {
  public size: SizeOptions = {
    width: '48vp',
    height: '48vp'
  };
  public padding: Padding = { left: '12vp', right: '12vp' };
  public margin: Margin = {};
  public imageFit = ImageFit.Contain;
  public fillColor = $r('sys.color.ohos_id_color_secondary');
}

class ApSecondStateContainerStyle extends ContainerStyle {
  public margin: Margin = {
    left: 0
  };
}

class ApContainerStyle extends RootContainerStyle {
  public constraintSize: ConstraintSizeOptions = {
    minHeight: '64vp'
  };
  public padding: Padding = {
    left: DEFAULT_PADDING_START
  };
}

/**
 * 可用wifi菜单样式
 *
 * @since 2023-03-13
 */
class WifiEnableStyle extends DefaultEntryMenuStyle {
  public rootContainer: ContainerStyle = new ApContainerStyle();
  public stateIcon: ImageStyle = new ApStateIconStyle();
}

let wifiEnableStyle = new WifiEnableStyle();

export class ApTitleTextStyle extends TitleTextStyle {
  public fontColor: ResourceColor = $r('sys.color.ohos_id_color_emphasize');
}

let titleTextStyle = new ApTitleTextStyle();

/**
 * 已连接Ap菜单样式
 *
 * @since 2023-03-13
 */
class WifiApStyle extends DefaultEntryMenuStyle {
  public rootContainer: ContainerStyle = new ApContainerStyle();
  public title = titleTextStyle;
  public stateIcon: ImageStyle = new ApStateIconStyle();
  public secondStateContainer = new ApSecondStateContainerStyle();
  public secondStateIcon: ImageStyle = new ApStateIconStyle();
}

let wifiApStyle = new WifiApStyle();

/**
 * 已连接Ap菜单控制器
 *
 * @since 2023-03-13
 */
export class ConnectApController extends MenuController {
  public tag: string = 'ConnectApController : ';

  static CreateConnectApController(menu: SettingsBaseMenu): Controller {
    return new ConnectApController(menu);
  }

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

  onMenuClick(): boolean {
    if (!(this.menu instanceof ConnectApMenu)) {
      return true;
    }
    if (this.isPortalUnauthenticated) {
      LogUtil.info(`${this.tag} onMenuClick: start portal certification.`)
      WifiUtils.startPortalCertification();
      return true;
    }
    return true;
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
      if (!this.menu.isSmartHotSpot) {
        this.menu.stateIcon = this.menu.accessPoint?.getStateIcon();
      }
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

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

import { MenuGroup, SettingsBaseMenu } from '@ohos/settings.common/src/main/ets/core/model/menu/SettingsMenu';
import { LogUtil } from '@ohos/settings.common/src/main/ets/utils/LogUtil';
import { SettingsDataUtils } from '@ohos/settings.common/src/main/ets/utils/SettingsDataUtils';
import { ContainerStyle, ImageStyle } from '@ohos/settings.common/src/main/ets/core/model/menu/ComponetStyle';
import {
  PageLifecycleLoadingGroupController
} from '@ohos/settings.common/src/main/ets/core/controller/LifecycleMenuController';
import { AccessPoint, hotSpotTracker, HotSpotTrackerListener, WIFI_SWITCH_KEY, WifiState } from '@ohos/settings.wifi';
import wifiManager from '@ohos.wifiManager';
import serviceBrowser from '@hms.collaboration.serviceBrowser';
import { HotSpotMenu, HotSpotMenuData } from '@ohos/settings.wifi/src/main/ets/model/HotSpotModel';
import {
  DEFAULT_PADDING_START,
  DefaultEntryMenuStyle,
  NewTitleTextStyle,
  RootContainerStyle,
  StateIconStyle,
} from '@ohos/settings.uikit';
import distributedDeviceManager from '@ohos.distributedDeviceManager';
import { HotSpotEntryController } from './HotSpotEntryController';
import { HotSpotConnectedApController } from './WifiConnectedApController';
import { WifiUtils } from '@ohos/settings.wifi/src/main/ets/WifiUtils';

const TAG: string = 'HotSpotListController';
const SMART_HOTSPOT_KEY: string = 'smartHotSpot';

export default class HotSpotListController extends PageLifecycleLoadingGroupController
implements HotSpotTrackerListener {
  public serviceBrowserInstance: serviceBrowser.ServiceBrowser | null = null;
  public hotSpotMenuList: HotSpotMenu[] = [];
  public connectedApMenu: SettingsBaseMenu | null = null;
  public connectedHotSpotMenu: HotSpotMenu | null = null;
  public deviceNames: string[] = [];
  public lastLinkedInfo: wifiManager.WifiLinkedInfo | null = null;
  public isStartScan: boolean = false;

  static CreateHotSpotListController(menu: SettingsBaseMenu) {
    return new HotSpotListController(menu);
  }

  public onWifiStateChange = (state: number): void => {
    LogUtil.info(`${TAG} wifi state change : ${state} `);
    if (state === WifiState.INACTIVE) { // 关闭
      this.setVisible(false);
    } else if (state === WifiState.ACTIVE) { // 打开
      let isOobeWifi: boolean = AppStorage.get<boolean>('OOBEWifi') ?? false;
      LogUtil.info(`${TAG} isOOBEWifi: ${isOobeWifi}`);
      if (isOobeWifi) {
        this.setVisible(false);
      } else {
        this.setVisible(true);
        this.initServiceBrowserInstance();
        this.startScanHotSpotDevice();
      }
    }
  }

  async aboutToAppear(): Promise<void> {
    LogUtil.info(`${TAG} aboutToAppear`);
    super.aboutToAppear();
    let isOobeWifi: boolean = AppStorage.get<boolean>('OOBEWifi') ?? false;
    LogUtil.info(`${TAG} isOOBEWifi: ${isOobeWifi}`);
    if (isOobeWifi) {
      return;
    }
    try {
      this.initServiceBrowserInstance();
      this.startScanHotSpotDevice();
      this.registerHotSpotDataChange();
      hotSpotTracker.onStart();
      hotSpotTracker.registerListener(this);
    } catch (error) {
      LogUtil.error(`${TAG} error: ${error?.message}`);
    }
  }

  aboutToDisappear(): void {
    super.aboutToDisappear();
    LogUtil.info(`${TAG} aboutToDisappear`);
    if (this.serviceBrowserInstance) {
      this.hotSpotMenuList = [];
      this.deviceNames = [];
      this.releaseHotSpotDataChange();
      LogUtil.info(`${TAG} release serviceBrowserInstance`);
      this.serviceBrowserInstance.release();
      hotSpotTracker.onStop();
      hotSpotTracker.unregisterListener(this);
    }
  }

  getListenerName(): string {
    return 'HotSpotListController';
  }

  /**
   * 刷新 smartHotSpotMenu 列表数据
   */
  refreshMenusList(menuList?: Array<SettingsBaseMenu>): void {
    LogUtil.info(`${TAG} start to refreshMenusList`);
    if (this.menu instanceof MenuGroup) {
      if (this.connectedApMenu) {
        let allHotSpotMenuList: SettingsBaseMenu[] = [];
        allHotSpotMenuList.push(this.connectedApMenu);
        this.hotSpotMenuList.forEach((item, index) => {
          allHotSpotMenuList.push(item);
        });
        LogUtil.info(`${TAG} start to refresh AllHotSpotMenuList length: ${allHotSpotMenuList.length}`);
        this.menu.updateMenus(allHotSpotMenuList);
      } else {
        LogUtil.info(`${TAG} start to refresh hotSpotMenuList length: ${this.hotSpotMenuList.length}`);
        this.menu.updateMenus(this.hotSpotMenuList);
      }
      this.refreshUi();
    }
  }

  /**
   * 处理 smartHotSpot 连接状态变化事件
   * @param info
   */
  onHotSpotMenuChanged(accessPoint: AccessPoint | null): void {
    let isSmartHotSpotChanged: boolean = false;
    // wifi连接场景
    if (accessPoint) {
      if (this.connectedHotSpotMenu) {
        this.hotSpotMenuList.push(this.connectedHotSpotMenu);
      }
      for (let index = 0; index < this.hotSpotMenuList.length; index++) {
        if (this.hotSpotMenuList[index].deviceName === accessPoint.ssid) {
          this.connectedHotSpotMenu = this.hotSpotMenuList[index];
          this.hotSpotMenuList.splice(index, 1);
          isSmartHotSpotChanged = true;
          break;
        }
      }
      if (accessPoint.ssid === SettingsDataUtils.getSettingsData(SMART_HOTSPOT_KEY, '')) {
        isSmartHotSpotChanged = true;
      }
      // 如果存在 smartHotSpot 状态变化
      if (isSmartHotSpotChanged) {
        if (accessPoint.lastLinkedInfo?.connState === wifiManager.ConnState.CONNECTED) {
          LogUtil.info(`${TAG} Smart HotSpot Device Connected`);
          let connectedApMenu = HotSpotConnectedApController.getConnectedApMenu(accessPoint);
          if (connectedApMenu) {
            connectedApMenu.stateIcon = $r('app.media.ic_notification_hotspot');
            this.connectedApMenu = connectedApMenu;
          }
          this.refreshMenusList();
        }
      }
    } else {
      // wifi 断开连接场景
      LogUtil.info(`${TAG} onHotSpotMenuChanged, accessPoint is null`);
      if (this.connectedApMenu) {
        LogUtil.info(`${TAG} start to reset Connected HotSpot Info`);
        if (this.connectedHotSpotMenu) {
          LogUtil.info(`${TAG} start to recover connectedHotSpotMenu`);
          this.hotSpotMenuList.push(this.connectedHotSpotMenu);
        }
        this.connectedHotSpotMenu = null;
        this.connectedApMenu = null;
      }
      this.refreshMenusList();
    }
  }


  /**
   * 初始化ServiceBrowser
   */
  initServiceBrowserInstance(): void {
    if (!this.serviceBrowserInstance) {
      LogUtil.info(`${TAG} start to initServiceBrowserInstance`);
      this.serviceBrowserInstance = serviceBrowser.createServiceBrowser({
        serviceName: 'SmartHotSpot',
      });
    } else {
      LogUtil.info(`${TAG} serviceBrowserInstance has been inited`);
    }
  }

  /**
   * 主动扫描smartHotSpot
   * @returns
   */
  async startScanHotSpotDevice(): Promise<void> {
    if (this.serviceBrowserInstance) {
      LogUtil.info(`${TAG} start to BrowseService Async`);
      LogUtil.info(`${TAG} isStartScan: ${this.isStartScan}`);
      if (!this.isStartScan) {
        this.isStartScan = true;
        let hotSpotDevices: distributedDeviceManager.DeviceBasicInfo[] =
          await this.serviceBrowserInstance.browseService();
        LogUtil.info(`${TAG} scanned HotSpot Size: ${hotSpotDevices.length}`);
        await this.dealAddHotSpotDevices(hotSpotDevices);
        hotSpotTracker.updateConnectedWifi();
        this.isStartScan = false;
      }
      LogUtil.info(`${TAG} BrowseService Async End`);
    }
  }

  /**
   *  处理smartHotSpot添加事件
   * @param hotSpotDevices 热点设备
   */
  async dealAddHotSpotDevices(hotSpotDevices: Array<distributedDeviceManager.DeviceBasicInfo>): Promise<void> {
    LogUtil.info(`${TAG} start to dealAddHotSpotDevices event`);
    for (let deviceBasicInfo of hotSpotDevices) {
      if (deviceBasicInfo.deviceType === '2IN1') {
        LogUtil.info(`${TAG} smartHotSpot device : ${deviceBasicInfo.deviceName} is 2IN1`);
        continue;
      }
      let infoNames = ['supportSmartHotSpot', 'hotspotName'];
      let serviceRequiredInfoList: serviceBrowser.ServiceRequiredInfo[] =
        await serviceBrowser.getServiceRequiredInfos(infoNames, deviceBasicInfo?.networkId);
      let supportSmartHotSpot: string = '';
      let hotspotName: string = '';
      if (serviceRequiredInfoList && serviceRequiredInfoList.length > 0) {
        for (let serviceRequiredInfo of serviceRequiredInfoList) {
          if (serviceRequiredInfo.name === 'supportSmartHotSpot') {
            supportSmartHotSpot = serviceRequiredInfo.value;
          }
          if (serviceRequiredInfo.name === 'hotspotName') {
            hotspotName = serviceRequiredInfo.value;
          }
        }
      } else {
        LogUtil.info(`${TAG} serviceRequiredInfoList is null or no value`);
      }
      LogUtil.info(`${this.tag} supportSmartHotSpot: ${supportSmartHotSpot}`);
      if (supportSmartHotSpot === 'true') {
        LogUtil.info(`${this.tag} smart hotspotName: ${hotspotName}`);
        let hotSpotMenuData: HotSpotMenuData = {
          deviceId: deviceBasicInfo.deviceId,
          networkId: deviceBasicInfo?.networkId,
          deviceName: hotspotName === '' ? deviceBasicInfo.deviceName : hotspotName,
          deviceType: deviceBasicInfo.deviceType,
          bssid: '',
        };
        if (this.deviceNames.indexOf(deviceBasicInfo.deviceName) === -1) {
          LogUtil.info(`${this.tag} find new smartHotSpot device : ${deviceBasicInfo.deviceName}`);
          this.deviceNames.push(deviceBasicInfo.deviceName);
          this.hotSpotMenuList.push(this.createHotSpotMenu(hotSpotMenuData));
        } else {
          LogUtil.info(`${this.tag} the smartHotSpot device has been found`);
        }
      }
    }
    if (hotSpotDevices.length === 0) {
      LogUtil.info(`${this.tag} hotSpotDevices no data`);
      this.deviceNames = [];
      this.connectedApMenu = null;
      this.connectedHotSpotMenu = null;
      this.hotSpotMenuList = [];
    }
    this.refreshMenusList();
  }

  /**
   * 处理smartHotSpot删除事件
   * @param delHotSpotDevices 热点设备
   */
  dealRemoveHotSpotDevices(delHotSpotDevices: distributedDeviceManager.DeviceBasicInfo): void {
    LogUtil.info(`${TAG} start to dealRemoveHotSpotDevices event`);
    if (this.deviceNames.indexOf(delHotSpotDevices.deviceName) !== -1) {
      LogUtil.info(`${TAG} start to delete old device in deviceNames`);
      this.deviceNames.splice(this.deviceNames.indexOf(delHotSpotDevices.deviceName), 1);
    }
    this.hotSpotMenuList.forEach((hotSpotMenu, index) => {
      if (hotSpotMenu.deviceId === delHotSpotDevices.deviceId) {
        LogUtil.info(`${TAG} start to delete old device in hotSpotMenuList`);
        this.hotSpotMenuList.splice(index, 1);
      }
    });
    if (this.connectedHotSpotMenu?.deviceId === delHotSpotDevices.deviceId) {
      this.connectedHotSpotMenu = null;
    }
    this.refreshMenusList();
  }

  /**
   * 注册热点设备改变事件
   */
  registerHotSpotDataChange(): void {
    if (this.serviceBrowserInstance) {
      LogUtil.info(`${TAG} serviceBrowserInstance on serviceAdded and serviceRemoved`);
      this.serviceBrowserInstance.on('serviceAdded', (deviceInfo) => {
        let addedHotSpotDevices: distributedDeviceManager.DeviceBasicInfo[] = [];
        addedHotSpotDevices.push(deviceInfo);
        this.dealAddHotSpotDevices(addedHotSpotDevices);
      })

      this.serviceBrowserInstance.on('serviceRemoved', (deviceInfo) => {
        this.dealRemoveHotSpotDevices(deviceInfo);
      })
    }
  }

  /**
   * 释放热点设备改变事件
   */
  releaseHotSpotDataChange(): void {
    if (this.serviceBrowserInstance) {
      LogUtil.info(`${TAG} serviceBrowserInstance off serviceAdded and serviceRemoved`);
      this.serviceBrowserInstance.off('serviceAdded', (deviceInfo) => {
        LogUtil.info(`${TAG} serviceBrowserInstance serviceAdded off`);
      })
      this.serviceBrowserInstance.off('serviceRemoved', (deviceInfo) => {
        LogUtil.info(`${TAG} serviceBrowserInstance serviceRemoved off`);
      })
    }
  }

  /**
   * 创建智能热点设备菜单
   * @param item
   * @returns
   */
  protected createHotSpotMenu(item: Partial<HotSpotMenuData>): HotSpotMenu {
    let menu = new HotSpotMenu(item);
    menu.title = item.deviceName;
    menu.style = wifiApStyle;
    menu.key = item.deviceId;
    menu.stateIcon = $r('app.media.ic_notification_hotspot');
    menu.controller = {
      createControllerConstructorInter: HotSpotEntryController.createHotSpotEntryController,
    };
    return menu;
  }

  onPageShow(): void {
    LogUtil.info(`${TAG} onPageShow`);
  }

  onPageHide(): void {
    LogUtil.info(`${TAG} onPageHide`);
  }

  protected registerDataChange(): void {
    LogUtil.info(`${TAG} registerDataChange`);
    this.registerControllerDataChange(WIFI_SWITCH_KEY);
    WifiUtils.wifiStateChangeOn(TAG, this.onWifiStateChange);
  }

  protected unRegisterDataChange(): void {
    LogUtil.info(`${TAG} unRegisterDataChange`);
    this.unRegisterControllerDataChange(WIFI_SWITCH_KEY);
    WifiUtils.wifiStateChangeOff(TAG, this.onWifiStateChange);
  }

  onDataChange(fromKey: string, data: Object): void {
    LogUtil.info(`${TAG} fromKey: ${fromKey}`);
    if (fromKey == WIFI_SWITCH_KEY && typeof data === 'number') {
      this.onWifiStateChange(data);
    }
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

class ApContainerStyle extends RootContainerStyle {
  public constraintSize: ConstraintSizeOptions = {
    minHeight: '48vp',
  };
  public padding: Padding = {
    left: DEFAULT_PADDING_START,
  };
}

class WifiApStyle extends DefaultEntryMenuStyle {
  public rootContainer: ContainerStyle = new ApContainerStyle();
  public stateIcon: ImageStyle = new ApStateIconStyle();
  public title: NewTitleTextStyle = new NewTitleTextStyle();
}

let wifiApStyle = new WifiApStyle();
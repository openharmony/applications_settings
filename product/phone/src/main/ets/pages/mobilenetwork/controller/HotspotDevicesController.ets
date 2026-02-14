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

import commonEventManager from '@ohos.commonEventManager';
import emitter from '@ohos.events.emitter';
import wifiManager from '@ohos.wifiManager';
import { CommonEventHelper } from '@ohos/settings.common/src/main/ets/utils/CommonEventHelper';
import { Controller } from '@ohos/settings.common/src/main/ets/core/controller/Controller';
import { HotSpotBlackListUtils } from '@ohos/settings.common/src/main/ets/utils/HotSpotBlackListUtils';
import { LogUtil } from '@ohos/settings.common/src/main/ets/utils/LogUtil';
import { MenuGroupController } from '@ohos/settings.common/src/main/ets/core/controller/MenuController';
import { ResourceUtil } from '@ohos/settings.common/src/main/ets/utils/ResourceUtil';
import { SettingsBaseMenu } from '@ohos/settings.common/src/main/ets/core/model/menu/SettingsMenu';
import { TextStyle } from '@ohos/settings.common/src/main/ets/core/model/menu/ComponetStyle';
import { SystemUserListener } from '@ohos/settings.users/src/main/ets/SystemAccountAdapter';
import { SatelliteUtils } from '@ohos/settings.common/src/main/ets/utils/BaseUtils';
import { HiSysEventUtil } from '@ohos/settings.common/src/main/ets/systemEvent/HiSysEventUtil';
import { HiSysHotspotEventGroup } from '@ohos/settings.common/src/main/ets/systemEvent/BehaviorEventConsts';
import { EVENT_ID_BLOCK_LIST_CHANGE, EVENT_ID_BLOCK_LIST_EMPTY } from '@ohos/settings.common/src/main/ets/event/types';
import { BlockListInfo } from '@ohos/settings.uikit/src/main/ets/component/wifi/ConnectedHotSportComponent';
import { DefaultEntryMenuStyle, RootContainerStyle72, SummaryTextStyle, APUserStateIconStyle }
  from '@ohos/settings.uikit/src/main/ets/menus/Menu';
import { ConnectedHotSportMenu } from '@ohos/settings.uikit/src/main/ets/menus/hotsport/ConnectedHotSportMenu';
import { TabIndexConstants } from '@ohos/settings.common/src/main/ets/constant/TabIndexConstants';

/*instrument ignore file */
class APSummaryTextStyle extends SummaryTextStyle {
  public font: Font = {
    size: $r('sys.float.ohos_id_text_size_body2'),
    weight: FontWeight.Normal,
  };
}

class AccountMenuStyle extends DefaultEntryMenuStyle {
  public rootContainer: RootContainerStyle72 = new RootContainerStyle72();
  public iconImage: APUserStateIconStyle = new APUserStateIconStyle();
  public summary: TextStyle = new APSummaryTextStyle();
  public secondSummary: TextStyle = new APSummaryTextStyle();
}

let accountMenuStyle: AccountMenuStyle = new AccountMenuStyle();

const BLOCK_LIST_KEY: string = 'ap_block_list';

export class APUserListController extends MenuGroupController implements SystemUserListener{
  static CreateAPUserListController(menu: SettingsBaseMenu): Controller {
    return new APUserListController(menu);
  }
  public static readonly USER_MENU_PREFIX: string = 'ap_user_menu_prefix';
  public tag: string = 'APUserListController : ';
  public enable: boolean = true;
  private stations: Array<wifiManager.StationInfo> = [];
  private blockListStations: Array<wifiManager.StationInfo> = [];
  private subscribeInfo: commonEventManager.CommonEventSubscribeInfo = {
    events: [
      commonEventManager.Support.COMMON_EVENT_WIFI_AP_STA_JOIN,
      commonEventManager.Support.COMMON_EVENT_WIFI_AP_STA_LEAVE,
      commonEventManager.Support.COMMON_EVENT_WIFI_POWER_STATE,
      commonEventManager.Support.COMMON_EVENT_WIFI_HOTSPOT_STATE
    ]
  };

  private blockListChangeCallBack = (event: emitter.EventData) => {
    LogUtil.info(`${this.tag} receive block list change event.`);
    this.refreshUserMenu();
  }

  aboutToAppear(): void {
    LogUtil.info(`${this.tag} aboutToAppear`);
    this.enable = !SatelliteUtils.isCommunicationOpen();
    this.refreshUserMenu();
    super.aboutToAppear();
    HiSysEventUtil.reportDefaultBehaviorEventByUE(HiSysHotspotEventGroup.CONNECT_DEVICE, `${this.stations.length}`);
    this.registerDataChange();
    this.registerBlockListEvent();
  }

  aboutToDisappear(): void {
   super.aboutToDisappear();
   this.unregisterBlockListEvent();
  }

  async refreshUserMenu(): Promise<void> {
    this.getStationsFromWifi();
    let userMenus: SettingsBaseMenu[] = [];
    if (this.menu?.key === BLOCK_LIST_KEY) {
      this.blockListStations = HotSpotBlackListUtils.getBlockList();
      if (this.blockListStations.length === 0) {
        this.setVisible(false);
        this.refreshUi();
        emitter.emit({
          eventId: EVENT_ID_BLOCK_LIST_EMPTY,
          priority: emitter.EventPriority.IMMEDIATE,
        });
        return;
      }
      this.setVisible(true);
      for (let index = 0; index < this.blockListStations.length; index++) {
        let current = this.blockListStations[index];
        userMenus.push(await this.createUserMenuByBlockList(current, index));
      }
      this.clearChildren();
      this.addChildren(userMenus);
      this.refreshUi();
      return;
    }
    if (this.stations.length === 0) {
      this.setVisible(false);
      this.refreshUi();
      return;
    }
    this.setVisible(true);
    for (let index = 0; index < this.stations.length; index++) {
      let current = this.stations[index];
      userMenus.push(await this.createUserMenu(current, index));
    }
    this.clearChildren();
    this.addChildren(userMenus);
    this.refreshUi();
  }

  onSystemUserChange() {
    LogUtil.info(`${this.tag} onSystemUserChange`);
    this.refreshUserMenu();
  }

  getListenerName(): string {
    return this.tag;
  }

  private getStationsFromWifi(): void {
    try {
      let blockListStations = HotSpotBlackListUtils.getBlockList();
      if (this.menu.key === BLOCK_LIST_KEY) {
        this.blockListStations = blockListStations;
        return;
      }
      this.stations = wifiManager.getStations();
    } catch (error) {
      LogUtil.info(`${this.tag} getStations error: ${error?.message}`);
      this.setVisible(false);
      this.refreshUi();
    }
  }

  private apConnectDevices: CommonEventHelper = new CommonEventHelper(this.subscribeInfo, (err, data) => {
    LogUtil.info(`${this.tag} APConnectDevices connected`);
    this.refreshUserMenu();
  });

  protected registerDataChange(): void {
    super.registerDataChange();
    this.apConnectDevices.registerCommonEvent();
  }

  protected unRegisterDataChange(): void {
    super.unRegisterDataChange();
    this.apConnectDevices.unRegisterCommonEvent()
  }

  private registerBlockListEvent(): void {
    emitter.on({
      eventId: EVENT_ID_BLOCK_LIST_CHANGE,
    }, this.blockListChangeCallBack);
  }

  private unregisterBlockListEvent(): void {
    emitter.off(EVENT_ID_BLOCK_LIST_CHANGE, this.blockListChangeCallBack);
  }

  private async createUserMenu(account: wifiManager.StationInfo, index: number): Promise<SettingsBaseMenu> {
    let ip = await ResourceUtil.getFormatString($r('app.string.wifi_ap_connected_user_ip'), account.ipAddress);
    let mac = await ResourceUtil.getFormatString($r('app.string.wifi_ap_connected_user_mac'), account.macAddress);
    let info: BlockListInfo = new BlockListInfo();
    info.ipInfo = ip;
    info.macInfo = mac;
    info.isRemoveBlockList = (this.menu.key === 'ap_block_list');
    return new ConnectedHotSportMenu({
      key: APUserListController.USER_MENU_PREFIX + account.name + index,
      index: index,
      tabIndex: index == 0 ? TabIndexConstants.TAB_INDEX_LEVEL2_PAGE : TabIndexConstants.TAB_INDEX_DEFAULT,
      icon: $r('sys.symbol.hotspot'),
      title: account.name.trim() === '' ? '*' : account.name,
      summary: account.ipAddress,
      style: accountMenuStyle,
      state: account.macAddress,
      extra: info,
      enable: this.enable,
    })
  }

  private async createUserMenuByBlockList(station: wifiManager.StationInfo, index: number): Promise<SettingsBaseMenu> {
    let info: BlockListInfo = new BlockListInfo();
    info.ipInfo = ResourceUtil.getFormatStringSync($r('app.string.wifi_ap_connected_user_ip'), station.ipAddress);
    info.macInfo = ResourceUtil.getFormatStringSync($r('app.string.wifi_ap_connected_user_mac'), station.macAddress);
    info.isRemoveBlockList = (this.menu.key === 'ap_block_list');
    let deviceName: string = station.name.trim() === ''? '*' : station.name;
    return new ConnectedHotSportMenu({
      key: APUserListController.USER_MENU_PREFIX + deviceName + index,
      index: index,
      tabIndex: index == 0 ? TabIndexConstants.TAB_INDEX_LEVEL2_PAGE : TabIndexConstants.TAB_INDEX_DEFAULT,
      icon: $r('sys.symbol.hotspot'),
      title: deviceName,
      summary: station.ipAddress,
      style: accountMenuStyle,
      state: station.macAddress,
      extra: info,
      enable: this.enable,
    })
  }
}
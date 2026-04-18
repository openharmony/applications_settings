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
import {
  DialogButtonMenuController,
  MenuGroupController
} from '@ohos/settings.common/src/main/ets/core/controller/MenuController';
import { MenuGroup, SettingsBaseMenu } from '@ohos/settings.common/src/main/ets/core/model/menu/SettingsMenu';
import { LogUtil } from '@ohos/settings.common/src/main/ets/utils/LogUtil';
import { ResourceUtil } from '@ohos/settings.common/src/main/ets/utils/ResourceUtil';
import { Controller, PushParam } from '@ohos/settings.common/src/main/ets/core/controller/Controller';
import { HiSysEventUtil } from '@ohos/settings.common/src/main/ets/systemEvent/HiSysEventUtil';
import { NavEntryKey } from '@ohos/settings.common/src/main/ets/utils/Consts';
import { Style } from '@ohos/settings.common/src/main/ets/core/model/menu/ComponetStyle';
import {
  apConnectManager,
  ApMenu,
  CANCEL_BUTTON,
  CONNECT_BUTTON,
  DELETE_BUTTON,
  PSD_INPUT_KEY,
  RECONNECT_BUTTON,
  SavedWifiButtonController,
  WIFI_AP_DETAIL_GROUP,
  WifiBaseConfigManager,
  WifiConnectListener,
  WifiEntryBaseController,
  wifiTracker,
  WifiUtils,
} from '@ohos/settings.wifi';
import {
  ButtonMenu,
  DialogMessageMenu,
  DialogPage,
  DialogTitleMenu,
  DividerMenuGroup,
  LoadingMenu,
  StateMenu,
} from '@ohos/settings.uikit';
import {
  AlignCenterDialogMessageStyle,
  newTransparentButtonMenuStyle,
  WifiDialogTitleMenuStyle
} from '@ohos/settings.uikit/src/main/ets/menus/Menu';
import { WlanDisconnectedReason } from '@ohos/settings.wifi/src/main/ets/model/WifiModel';

/* instrument ignore file */
const WIFI_CONNECT_BUTTON_KEY: string = 'wifi_connect_button';
const WIFI_SAVED_BUTTON_KEY: string = 'wifi_saved_button';
const WIFI_CONNECT_ERROR_BUTTON_KEY: string = 'wifi_connect_error_button';
const CLICK_WLAN_NAME: string = 'click_wlan_name';

export interface WifiEntryParams {
  config: wifiManager.WifiDeviceConfig;
  isHiLinkNetwork: boolean;
  capabilities?: string;
  needShowModal?: boolean;
  isFromMoreSetting?: boolean;
};

/**
 * Wifi Ap项控制器
 *
 * @since 2022-03-21
 */
export class WifiEntryController extends WifiEntryBaseController implements WifiConnectListener {
  public tag: string = 'WifiEntryController : ';

  constructor(menu: SettingsBaseMenu) {
    super(menu);
  }

  static createWifiEntryController(menu: SettingsBaseMenu): Controller {
    return new WifiEntryController(menu);
  }

  protected connectOpenAp(menu: ApMenu): void {
    if (!menu) {
      return;
    }
    LogUtil.error(`${this.tag} connectOpenAp : ${WifiUtils.getLogSsidString(menu.ssid)}`);
    let config = { ssid: menu.ssid, securityType: menu.securityType } as wifiManager.WifiDeviceConfig;
    if (apConnectManager.startConnect(config, false, this)) {
      this.menu.summary = $r('app.string.wifi_status_connecting');
      this.refreshUi();
    }
  }

  /**
   * 连接结果回调
   *
   * @param result 1：成功，0：失败
   */
  onConnectResult(result: number): void {
    if (!result) {
      this.menu.summary = $r('app.string.wifi_status_unsuccessful');
      this.refreshUi();
    }
  }

  /**
   * 菜单点击回调
   */
  onMenuClick(): boolean {
    if (!(this.menu instanceof ApMenu)) {
      LogUtil.error(`${this.tag} menu error`);
      return false;
    }

    LogUtil.info(`${this.tag} onMenuClick, ${WifiUtils.getApLogKey(this.menu.ssid, this.menu.securityType)}`);
    if (WifiUtils.isOpenAp(this.menu.securityType) && !this.menu.config) {
      // 未保存的开放网络直接连
      this.connectOpenAp(this.menu);
      return true;
    }
    LogUtil.info(`${this.tag} onMenuClick openDialog`);
    HiSysEventUtil.reportButtonEvent(CLICK_WLAN_NAME, '');
    this.openConnectDialog();
    return true;
  }

  protected openConnectDialog(): void {
    let detail = new DialogPage({
      pageUrl: 'pages/wifi/WifiSettings/detail',
      title: this.menu.title,
      scrollable: false
    });

    let detailApMenu: ApMenu = new ApMenu(this.menu);
    let menus: SettingsBaseMenu[] = [];
    if (detailApMenu.config) {
      // 已保存网络
      menus = WifiEntryController.getSavedApMenu(detailApMenu);
    } else {
      LogUtil.info(`${this.tag} onMenuClick unsaved`);
      const param: WifiEntryParams = {
        config: WifiEntryBaseController.getWifiConfig(detailApMenu),
        isHiLinkNetwork: detailApMenu.isHiLinkNetwork,
        isFromMoreSetting: true,
      };
      this.menu.pushName(NavEntryKey.WIFI_MENU_ENTRY, new PushParam(param));
      return;
    }

    detail.addMenu(
      new MenuGroup(
        {
          key: WIFI_AP_DETAIL_GROUP,
          index: 10,
          timestamp: Math.random(),
          controller: {
            createControllerConstructorInter: WifiDetailGroupController.CreateWifiDetailGroupController,
          },
          extra: detailApMenu,
        },
        menus,
      ));
    this.openDialog(detail, true);
  }

  /**
   * 已保存网络详情菜单内容
   *
   * @param menu 当前菜单
   */
  static getSavedApMenu(menu: ApMenu): Array<SettingsBaseMenu> {
    // index 用于菜单的下标排序
    let menus: SettingsBaseMenu[] = [
      new DialogTitleMenu(
        {
          key: 'wifi_saved_ap_detail_title',
          index: 1,
          title: menu?.title,
          style: new WifiDialogTitleMenuStyle()
        }
      ),
      new DividerMenuGroup(
        {
          key: 'system_info_group',
          index: 50,
        },
        [
          new StateMenu(
            {
              key: 'ap_signal_level',
              index: 20,
              title: $r('app.string.wifi_signal_level'),
              state: WifiUtils.getApSignalString(menu?.level ?? 0),
            }
          ),
          new StateMenu(
            {
              key: 'ap_security_type',
              index: 30,
              title: $r('app.string.wifi_security_type'),
              state: WifiUtils.getApSecurityString(menu?.securityType ?? 0),
            }
          )
        ]
      ),
      new ButtonMenu({
        key: WIFI_SAVED_BUTTON_KEY,
        timestamp: 1,
        index: 101,
        buttonTittle1: $r('app.string.button_tittle_cancel'),
        buttonTittle2: $r('app.string.wifi_button_tittle_delete'),
        buttonTittle3: $r('app.string.wifi_button_tittle_connect'),
        controller: {
          createControllerConstructorInter: SavedWifiButtonController.CreateSavedWifiButtonController,
        },
      })
    ];
    return menus;
  }
}

/**
 * 连接/已保存页组控制器，管理已保存网络和连接页面
 *
 * @since 2022-03-21
 */
@Observed
export class WifiDetailGroupController extends MenuGroupController implements WifiConnectListener {
  static CreateWifiDetailGroupController(menu: SettingsBaseMenu): Controller {
    return new WifiDetailGroupController(menu);
  }

  public tag: string = 'WifiDetailGroupController : ';
  public psdInput: string = '';
  public detailApMenu?: ApMenu;
  public isReconnect: boolean = false;

  constructor(menu: SettingsBaseMenu) {
    super(menu);
    if (this.menu?.extra instanceof ApMenu) {
      this.detailApMenu = this.menu.extra;
    }
  }

  protected registerDataChange(): void {
    this.registerControllerDataChange(PSD_INPUT_KEY);
    this.registerControllerDataChange(WIFI_CONNECT_BUTTON_KEY);
    this.registerControllerDataChange(WIFI_SAVED_BUTTON_KEY);
    this.registerControllerDataChange(WIFI_CONNECT_ERROR_BUTTON_KEY);
  }

  protected unRegisterDataChange(): void {
    this.unRegisterControllerDataChange(PSD_INPUT_KEY);
    this.unRegisterControllerDataChange(WIFI_CONNECT_BUTTON_KEY);
    this.unRegisterControllerDataChange(WIFI_SAVED_BUTTON_KEY);
    this.unRegisterControllerDataChange(WIFI_CONNECT_ERROR_BUTTON_KEY);
  }

  onDataChange(fromKey: string, data: Object): void {
    if (fromKey === PSD_INPUT_KEY && typeof data === 'string') {
      this.psdInput = data;
      LogUtil.info(`${this.tag} from psd input`);
      return;
    }
    if (fromKey === WIFI_CONNECT_BUTTON_KEY || WIFI_SAVED_BUTTON_KEY || WIFI_CONNECT_ERROR_BUTTON_KEY) {
      LogUtil.info(`${this.tag} from button : ${data}`);
      if (typeof data === 'number') {
        if (data === CANCEL_BUTTON) {
          this.closeSelf();
        } else if (data === CONNECT_BUTTON) {
          this.connectToWifiDevice();
        } else if (data === DELETE_BUTTON) {
          this.removeWifiDevice();
        } else if (data === RECONNECT_BUTTON && WifiUtils.isOpenAp(this.detailApMenu?.securityType as number)) {
          this.connectToWifiDevice();
        }
      }
    }
  }

  /**
   * 连接结果回调
   *
   * @param result 1：成功，0：失败
   */
  onConnectResult(result: number): void {
    LogUtil.info(`${this.tag} onConnectResult ${result}`);
    if (result) {
      // 连接成功
      this.closeSelf();
    } else {
      this.onConnectFailed();
    }
  }

  private connectToWifiDevice(): void {
    let config = this.detailApMenu?.config as wifiManager.WifiDeviceConfig;
    if (!config) {
      LogUtil.info(`${this.tag} connectToWifiDevice config null`);
      return;
    }
    if (!WifiUtils.isValidNetworkId(config.netId) || this.isReconnect) {
      config.preSharedKey = this.psdInput;
    }
    if (apConnectManager.startConnect(config, this.isReconnect, this)) {
      this.showLoadingMenu();
    }
  }

  private onConnectFailed(): void {
    let failReason: number = WifiUtils.getDisconnectedReason();
    if (failReason === WlanDisconnectedReason.DISC_REASON_IGNORE) {
      LogUtil.info(`${this.tag} connect failed with ignore resaon, no need to handle.`);
      this.closeSelf();
      return;
    }
    if (this.menu instanceof MenuGroup) {
      let wifiManagerMsg = WifiBaseConfigManager.getDisconnectedReasonMessage(failReason);
      // index 用于菜单的下标排序 timestamp 用于时间轴分析
      this.menu.updateMenus([
        new DialogMessageMenu(
          {
            key: 'wifi_connect_error',
            index: 10,
            title: wifiManagerMsg,
            style: new AlignCenterDialogMessageStyle(),
          }
        ),
        new ButtonMenu({
          key: WIFI_CONNECT_ERROR_BUTTON_KEY,
          timestamp: 3,
          index: 100,
          buttonTittle1: $r('app.string.button_tittle_cancel'),
          controller: {
            createControllerConstructorInter: DialogButtonMenuController.CreateDialogButtonMenuController,
          },
          style: newTransparentButtonMenuStyle as Style,
        })
      ]);
      this.refreshUi();
    }
  }

  private showLoadingMenu(): void {
    if (!this.detailApMenu || !this.detailApMenu.title || typeof this.detailApMenu.title !== 'string') {
      return;
    }
    ResourceUtil.getAnyStrFormatString($r('app.string.wifi_connecting'), this.detailApMenu.title).then((result) => {
      if (this.menu instanceof MenuGroup) {
        this.menu.updateMenus(
          [
            new LoadingMenu(
              {
                key: 'wifi_connect_loading',
                index: 10,
                title: result,
              }
            )
          ]);
        this.refreshUi();
      }
    })
  }

  private removeWifiDevice(): void {
    wifiTracker.removeWifiDevice(this.detailApMenu?.config as wifiManager.WifiDeviceConfig);
    this.closeSelf();
  }
}
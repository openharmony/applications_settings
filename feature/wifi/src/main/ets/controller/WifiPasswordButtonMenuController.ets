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
import { ButtonMenuController,
  DialogButtonMenuController } from '@ohos/settings.common/src/main/ets/core/controller/MenuController';
import { SettingsBaseMenu } from '@ohos/settings.common/src/main/ets/core/model/menu/SettingsMenu';
import { Controller } from '@ohos/settings.common/src/main/ets/core/controller/Controller';
import { HiSysEventUtil } from '@ohos/settings.common/src/main/ets/systemEvent/HiSysEventUtil';
import { LogUtil } from '@ohos/settings.common/src/main/ets/utils/LogUtil';
import { ResourceUtil } from '@ohos/settings.common/src/main/ets/utils/ResourceUtil';
import {
  ButtonMenu,
  DialogPage,
  LoadingMenu,
  newDefaultStateMenuStyle,
  newTransparentButtonMenuStyle,
  StateMenu,
} from '@ohos/settings.uikit/src/main/ets/menus/Menu';
import { CONNECT_CANCEL, WifiConnectDialogController } from './WifiConnectDialogController';
import { WlanDisconnectedReason } from '../model/WifiModel';
import { WifiBaseConfigManager } from '../WifiBaseConfigManager';
import { WifiUtils } from '../WifiUtils';
import { WIFI_PASSWORD_INPUT } from '../WifiMenuManager';
import { WifiConnectListener, wifiTracker } from '../WifiTracker';

const TAG: string = 'WifiPasswordButtonMenuController : ';
const CONFIRM_WLAN_NAME: string = 'confirm_wlan_name';

/**
 * wifi密码界面按钮控制器
 * @since 2024-04-12
 */
@Observed
export class WifiPasswordButtonMenuController extends ButtonMenuController implements WifiConnectListener {
  static CreateWifiPasswordButtonMenuController(menu: SettingsBaseMenu): Controller {
    return new WifiPasswordButtonMenuController(menu);
  }

  public isApPsdValid: boolean = false;
  public wifiBaseConfigManager: WifiBaseConfigManager;
  public isReconnect: boolean = false;

  constructor(menu: SettingsBaseMenu) {
    super(menu);
    if (!this.menu?.extra) {
      LogUtil.info(`${TAG} router params apConfig is invalid`);
    }

    this.wifiBaseConfigManager = new WifiBaseConfigManager(menu.extra as wifiManager.WifiDeviceConfig);
    this.isApPsdValid = WifiUtils.validWifiConfig(menu.extra as wifiManager.WifiDeviceConfig, menu?.capabilities);
  }

  onButton1Click(): void {
    this.menu.pathInfos?.pop();
  }

  onButton2Click(): void {
    HiSysEventUtil.reportButtonEvent(CONFIRM_WLAN_NAME, '');
    this.connectToWifiDevice();
  }

  isButton2Enabled(): boolean {
    return this.isApPsdValid;
  }

  registerDataChange(): void {
    this.wifiBaseConfigManager.registerDataChange(this);
  }

  unRegisterDataChange(): void {
    this.wifiBaseConfigManager.unRegisterDataChange(this);
  }

  onDataChange(fromKey: string, data: number | string): void {
    this.wifiBaseConfigManager.onDataChange(fromKey, data);
    if (fromKey === WIFI_PASSWORD_INPUT) {
      this.isReconnect = true;
    }
    this.refreshButton(WifiUtils.validWifiConfig(this.wifiBaseConfigManager.getApConfig(), this.menu?.capabilities));
  }

  private refreshButton(isValid: boolean): void {
    if (this.isApPsdValid === isValid) {
      return;
    }

    this.isApPsdValid = isValid;
    this.refreshUi();
  }

  private connectToWifiDevice(): void {
    this.wifiBaseConfigManager.connectToWifiDevice(this, this.isReconnect);
    this.showLoadingMenu(this.wifiBaseConfigManager.getApConfig()?.ssid);
  }

  private showLoadingMenu(ssid: string): void {
    LogUtil.info(`${TAG} showLoadingMenu`);
    let detail = new DialogPage({
      pageUrl: 'pages/wifi/WifiSettings/showLoadingMenu',
      controller: {
        createControllerConstructorInter: WifiConnectDialogController.CreateWifiConnectDialogController,
      },
      extra: this.menu?.extra,
      scrollable: false,
    });
    ResourceUtil.getAnyStrFormatString($r('app.string.wifi_connecting'), ssid).then((result) => {
      detail.addMenus(
        [
          new LoadingMenu(
            {
              key: 'wifi_connect_loading',
              index: 10,
              title: result,
            }
          ),
        ]
      );
      this.openDialog(detail, false);
    })
  }


  private showFailMessage(failResult: number): void {
    LogUtil.info(`${TAG} showFailMessage`);
    let wifiManagerMsg = WifiBaseConfigManager.getDisconnectedReasonMessage(failResult);
    let detail = new DialogPage({
      pageUrl: 'pages/wifi/WifiSettings/showFailMessage',
      scrollable: false,
    });
    detail.addMenus(
      [
        new StateMenu(
          {
            key: 'connect_fail_message',
            index: 10,
            title: wifiManagerMsg,
            style: newDefaultStateMenuStyle,
          }
        ),
        new ButtonMenu(
          {
            key: 'connect_fail_cancel',
            index: 10,
            buttonTittle1: $r('app.string.dialog_know'),
            controller: {
              createControllerConstructorInter: DialogButtonMenuController.CreateDialogButtonMenuController,
            },
            style: newTransparentButtonMenuStyle,
          }
        ),
      ]
    );
    this.openDialog(detail, false);
  }

  /**
   * 连接结果回调
   *
   * @param result 1：成功，0：失败
   */
  onConnectResult(result: number): void {
    /* instrument ignore if*/
    if (AppStorage.get<Boolean>(CONNECT_CANCEL)) {
      LogUtil.info(`${TAG} connect cancel, ignore result`);
      return;
    }
    this.closeDialog();
    if (result) {
      this.menu.pathInfos?.pop();
    } else {
      let failReason: number = WifiUtils.getDisconnectedReason();
      if (WifiUtils.needShowConnectFailedDialog(this.wifiBaseConfigManager.getApConfig())) {
        this.showFailMessage(failReason);
      }
      if (failReason === WlanDisconnectedReason.DISC_REASON_IGNORE) {
        LogUtil.info(`${TAG} connect failed with ignore resaon, no need to handle.`);
        return;
      }
      if (failReason == WlanDisconnectedReason.WRONG_PWD) {
        LogUtil.info(`${TAG} connect with wrong pwd , remove wifi device.`);
        wifiTracker.removeWifiDevice(this.wifiBaseConfigManager.getApConfig());
      }
    }
  }
}
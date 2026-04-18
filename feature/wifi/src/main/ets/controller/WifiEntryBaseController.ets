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
import common from '@ohos.app.ability.common';
import commonEventManager from '@ohos.commonEventManager';
import { AbilityContextManager } from '@ohos/settings.common/src/main/ets/ability/AbilityContextManager';
import {
  ButtonMenuController,
  MenuController,
  TextInputMenuController
} from '@ohos/settings.common/src/main/ets/core/controller/MenuController';
import { CommonEventConstant } from '@ohos/settings.common/src/main/ets/constant/CommonEventConstant';
import { CommonEventHelper } from '@ohos/settings.common/src/main/ets/utils/CommonEventHelper';
import { SettingsBaseMenu } from '@ohos/settings.common/src/main/ets/core/model/menu/SettingsMenu';
import { LogUtil } from '@ohos/settings.common/src/main/ets/utils/LogUtil';
import { Controller } from '@ohos/settings.common/src/main/ets/core/controller/Controller';
import { HiSysEventUtil } from '@ohos/settings.common/src/main/ets/systemEvent/HiSysEventUtil';
import wifiManager from '@ohos.wifiManager';
import { ApMenu } from '../model/WifiModel';
import { AdvSecurityModeManager, ConnectScene } from '../AdvSecurityModeManager';
import { WifiUtils } from '../WifiUtils';
import { BroadcastEventInfo, ENTER_KEY_CODE, EVENT_NAME_KEYBOARD } from '../WifiMenuManager';

export const PSD_INPUT_KEY: string = 'psd_input';

export const CANCEL_BUTTON: number = 1;

export const DELETE_BUTTON: number = 2;

export const CONNECT_BUTTON: number = 3;

export const RECONNECT_BUTTON: number = 4;

export const WIFI_AP_DETAIL_GROUP: string = 'wifi_ap_detail_group';

const CONFIRM_WLAN_NAME: string = 'confirm_wlan_name';

/**
 * Wifi Ap项控制器基类
 *
 * @since 2022-03-21
 */
export class WifiEntryBaseController extends MenuController {
  public tag: string = 'WifiEntryBaseController : ';

  /**
   * 从ApMenu获取AP配置
   *
   * @param apMenu
   */
  static getWifiConfig(apMenu: ApMenu): wifiManager.WifiDeviceConfig {
    if (apMenu.config) {
      return apMenu.config as wifiManager.WifiDeviceConfig;
    }
    return {
      ssid: apMenu.ssid,
      bssid: apMenu.bssid,
      bssidType: apMenu.bssidType,
      preSharedKey: '',
      securityType: apMenu.securityType,
      randomMacType: wifiManager.DeviceAddressType.RANDOM_DEVICE_ADDRESS,
      isHiddenSsid: false,
    };
  }
}

/**
 * 密码输入控制器
 *
 * @since 2022-03-21
 */
export class PsdInputMenuController extends TextInputMenuController {
  public tag: string = 'PsdInputMenuController : ';
  public isAlreadyRegister: boolean = false;
  public input: string = '';
  public securityType: number = 0;

  constructor(menu: SettingsBaseMenu) {
    super(menu);
    if (typeof menu.extra === 'number') {
      this.securityType = menu.extra;
    }
  }

  static CreatePsdInputMenuController(menu: SettingsBaseMenu): Controller {
    return new PsdInputMenuController(menu);
  }

  /**
   * 密码输入回调
   *
   * @param input 密码字符串
   */
  onTextInputChange(input: string): void {
    this.input = input;
    this.publishDataChange(input);
  }

  onRegisteredByObserver(observerKey: string): void {
    // 被注册时发送当前input
    this.publishDataChange(this.menu.title);
  }
}

/**
 * 密码输入控制器
 */
export class PsdInputMenuControllerSupportEditChange extends PsdInputMenuController {
  public tag: string = 'PsdInputMenuControllerSupportEditChange : ';

  static CreatePsdInputMenuControllerSupportEditChange(menu: SettingsBaseMenu): Controller {
    return new PsdInputMenuControllerSupportEditChange(menu);
  }

  onEditChange(isEditing: boolean): void {
    LogUtil.info(`${this.tag} onEditChange `);
    this.refreshUi();
  }

  onSubmit(enterKey: EnterKeyType): void {
    LogUtil.info(`${this.tag} onSubmit, enterKey: ${enterKey} `);
    this.publishDataChange(new BroadcastEventInfo(EVENT_NAME_KEYBOARD, ENTER_KEY_CODE));
  }
}

/**
 * 连接页按钮控制器
 *
 * @since 2022-03-21
 */
@Observed
export class WifiButtonController extends ButtonMenuController {
  static CreateWifiButtonController(menu: SettingsBaseMenu): Controller {
    return new WifiButtonController(menu);
  }

  public tag: string = 'WifiButtonController : ';
  public securityType: number;
  public isApPsdValid: boolean = false;
  private detailApMenu: ApMenu | undefined = undefined;
  private subscribeInfo: commonEventManager.CommonEventSubscribeInfo = {
    events: [CommonEventConstant.EVENT_WLAN_UN_SAVE_DIALOG],
    publisherPermission: 'ohos.permission.ACCESS_SYSTEM_SETTINGS',
  };
  private closeUnSaveDialogEvent: CommonEventHelper = new CommonEventHelper(this.subscribeInfo, async (err, data) => {
    if (err?.code) {
      LogUtil.error(`${this.tag} subscribe failed ${err?.code}`);
    } else {
      LogUtil.info(`${this.tag} receive close unSave dialog event ${data?.parameters?.continueJoin}`);
      if (AdvSecurityModeManager.getInstance().getConnectData()?.connectScene !==
      ConnectScene.CONTROL_CENTER_WLAN_LIST) {
        LogUtil.error(`${this.tag} joinUnSavaNet connectScene is wrong.`);
        return;
      }
      let apMenu: ApMenu | undefined = AdvSecurityModeManager.getInstance().getConnectData()?.apMenu;
      if (apMenu && apMenu.capabilities) {
        HiSysEventUtil.reportUnsafeWifiDialogButtonEvent(WifiUtils.getUnsafeNetworkType(apMenu.securityType,
          apMenu.capabilities), data?.parameters?.continueJoin);
      }
      if (!data?.parameters?.continueJoin) {
        return;
      }
      HiSysEventUtil.reportButtonEvent(CONFIRM_WLAN_NAME, '');
      this.publishDataChange(CONNECT_BUTTON);
    }
  });

  constructor(menu: SettingsBaseMenu) {
    super(menu);
    this.detailApMenu = new ApMenu(menu);
    this.securityType = (menu.extra as Object as wifiManager.WifiDeviceConfig).securityType;

    this.isApPsdValid = WifiUtils.validWifiConfig(menu.extra as wifiManager.WifiDeviceConfig, menu?.capabilities);
  }

  onButton1Click(): void {
    LogUtil.info(`${this.tag} onButton1Click`);
    this.publishDataChange(CANCEL_BUTTON);
  }

  onButton3Click(): void {
    LogUtil.info(`${this.tag} onButton3Click`);
    if (this.detailApMenu &&
    AdvSecurityModeManager.getInstance().isNeedShowWifiUnsafeDialog(this.detailApMenu.securityType ?? 0,
      this.detailApMenu.capabilities ?? '', this.detailApMenu.ssid ?? '')) {
      AdvSecurityModeManager.getInstance().setConnectData({
        connectScene: ConnectScene.CONTROL_CENTER_WLAN_LIST,
        ssid: this.detailApMenu?.ssid,
        securityType: this.detailApMenu?.securityType,
        config: this.detailApMenu?.config,
        capabilities: this.detailApMenu?.capabilities,
      });
      AdvSecurityModeManager.getInstance()
        .showWifiUnsafeDialog(AbilityContextManager.getContext() as common.UIAbilityContext);
      LogUtil.info(`${this.tag} onButton3Click isNeedShowWifiUnsafeDialog true, return!`);
      return;
    }
    HiSysEventUtil.reportButtonEvent(CONFIRM_WLAN_NAME, '');
    this.publishDataChange(CONNECT_BUTTON);
  }

  protected registerDataChange(): void {
    this.registerControllerDataChange(WIFI_AP_DETAIL_GROUP);
    this.closeUnSaveDialogEvent.registerCommonEvent();
  }

  protected unRegisterDataChange(): void {
    this.unRegisterControllerDataChange(WIFI_AP_DETAIL_GROUP);
    this.closeUnSaveDialogEvent.unRegisterCommonEvent();
  }

  onDataChange(fromKey: string, data: Object): void {
    if (data instanceof BroadcastEventInfo) {
      this.onKeyEvent({ type: KeyType.Down, keyCode: data.eventValue, } as KeyEvent);
      return;
    }

    interface DataI extends Object {
      result: boolean;
    }

    LogUtil.info(`${this.tag} onDataChange, fromKey: ${fromKey}, data: {data}`);
    let dataInstance = data as DataI;
    if (this.isApPsdValid !== dataInstance?.result) {
      this.isApPsdValid = dataInstance?.result;
      this.refreshUi();
    }
  }

  isButton3Enabled(): boolean {
    return this.isApPsdValid;
  }

  onKeyEvent(event: KeyEvent): void {
    LogUtil.info(`${this.tag} onKeyEvent, keyCode: ${event.keyCode}, type: ${event.type}`);
    if (event.keyCode !== ENTER_KEY_CODE || event.type !== KeyType.Down) {
      LogUtil.info(`${this.tag} onKeyEvent, not enter key`);
      return;
    }

    if (!this.isButton3Enabled()) {
      LogUtil.warn(`${this.tag} button `);
      return;
    }

    this.onButton3Click();
  }
}

/**
 * 已保存页按钮控制器
 *
 * @since 2022-03-21
 */
@Observed
export class SavedWifiButtonController extends ButtonMenuController {
  public tag: string = 'SavedWifiButtonController : ';

  constructor(menu: SettingsBaseMenu) {
    super(menu);
  }

  static CreateSavedWifiButtonController(menu: SettingsBaseMenu): Controller {
    return new SavedWifiButtonController(menu);
  }

  onButton1Click(): void {
    LogUtil.info(`${this.tag} onButton1Click`);
    this.publishDataChange(CANCEL_BUTTON);
  }

  onButton2Click(): void {
    LogUtil.info(`${this.tag} onButton2Click`);
    this.publishDataChange(DELETE_BUTTON);
  }

  onButton3Click(): void {
    LogUtil.info(`${this.tag} onButton3Click`);
    this.publishDataChange(CONNECT_BUTTON);
  }
}

/**
 * 连接失败页按钮控制器
 *
 * @since 2022-03-21
 */
@Observed
export class ConnectFailButtonController extends ButtonMenuController {
  public tag: string = 'ConnectFailButtonController : ';

  static CreateConnectFailButtonController(menu: SettingsBaseMenu): Controller {
    return new ConnectFailButtonController(menu);
  }

  onButton1Click(): void {
    LogUtil.info(`${this.tag} onButton1Click`);
    this.publishDataChange(CANCEL_BUTTON);
  }

  onButton3Click(): void {
    LogUtil.info(`${this.tag} onButton3Click`);
    this.publishDataChange(RECONNECT_BUTTON);
  }
}

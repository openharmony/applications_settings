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

import { WIFI_LIST_GROUP, WIFI_PRIVACY_MAC_ADDRESS_SETTINGS } from '@ohos/settings.wifi';
import {
  MenuController,
  TextInputMenuController
} from '@ohos/settings.common/src/main/ets/core/controller/MenuController';
import { SettingsBaseMenu } from '@ohos/settings.common/src/main/ets/core/model/menu/SettingsMenu';
import { Controller } from '@ohos/settings.common/src/main/ets/core/controller/Controller';
import {
  DATA_CHANGE_KEY_4_STATE,
  STATE_HIDE_AP_LIST,
  STATE_START_LOADING
} from '@ohos/settings.wifi/src/main/ets/controller/WifiListBaseController';
import { KEY_INPUT_WIFI_SSID, KEY_SECURITY_SELECTOR } from '../model/AddOtherWifiModel';
/* instrument ignore file */
import { WifiPasswordButtonMenuController } from './WifiPasswordButtonMenuController';

/**
 * 外部拉起时-添加其他网络-入口Controller
 *
 * @since 2023-12-05
 */
export class ExternalAddOtherWifiEntryGroupController extends MenuController {
  static Creator(menu: SettingsBaseMenu): Controller {
    return new ExternalAddOtherWifiEntryGroupController(menu);
  }

  constructor(menu: SettingsBaseMenu) {
    super(menu);
    this.setVisible(false);
  }

  registerDataChange() {
    this.registerControllerDataChange(WIFI_LIST_GROUP);
    this.menu?.getRoot()?.publishControllerDataChange(DATA_CHANGE_KEY_4_STATE, undefined);
  }

  unRegisterDataChange() {
    this.unRegisterControllerDataChange(WIFI_LIST_GROUP);
  }

  onDataChange(fromKey: string, data: string): void {
    if (fromKey === WIFI_LIST_GROUP && (typeof data) === 'string') {
      if (data === STATE_START_LOADING) {
        this.setVisible(true);
      } else if (data === STATE_HIDE_AP_LIST) {
        this.setVisible(false);
      }
    }
  }
}

/**
 * 添加其他网络-网络名称Controller
 *
 * @since 2023-11-08
 */
export class AddOtherWifiSsidController extends TextInputMenuController {
  static Creator(menu: SettingsBaseMenu): Controller {
    return new AddOtherWifiSsidController(menu);
  }

  onTextInputChange(input: string): void {
    this.publishDataChange(input);
  }
}

/**
 * 添加其他网络-底部按钮Controller
 *
 * @since 2023-11-08
 */
export class AddOtherWifiButtonController extends WifiPasswordButtonMenuController {
  static Creator(menu: SettingsBaseMenu): Controller {
    return new AddOtherWifiButtonController(menu);
  }

  constructor(menu: SettingsBaseMenu) {
    super(menu);
    this.isReconnect = true;
  }

  registerDataChange() {
    super.registerDataChange();
    this.registerControllerDataChange(KEY_INPUT_WIFI_SSID);
    this.registerControllerDataChange(KEY_SECURITY_SELECTOR);
    this.registerControllerDataChange(WIFI_PRIVACY_MAC_ADDRESS_SETTINGS);
  }

  unRegisterDataChange() {
    super.unRegisterDataChange();
    this.unRegisterControllerDataChange(KEY_INPUT_WIFI_SSID);
    this.unRegisterControllerDataChange(KEY_SECURITY_SELECTOR);
    this.unRegisterControllerDataChange(WIFI_PRIVACY_MAC_ADDRESS_SETTINGS);
  }

  onDataChange(fromKey: string, data: number | string): void {
    if (KEY_INPUT_WIFI_SSID === fromKey) {
      this.wifiBaseConfigManager.apConfig.ssid = data as string;
      this.refreshUi();
    } else if (KEY_SECURITY_SELECTOR === fromKey) {
      this.wifiBaseConfigManager.apConfig.securityType = data as number;
      super.onDataChange(fromKey, data);
    } else if (WIFI_PRIVACY_MAC_ADDRESS_SETTINGS === fromKey) {
      this.wifiBaseConfigManager.apConfig.randomMacType = data as number;
    } else {
      super.onDataChange(fromKey, data);
    }
  }

  isButton2Enabled(): boolean {
    return super.isButton2Enabled() && this.wifiBaseConfigManager.apConfig.ssid?.length > 0;
  }
}
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
import { CheckEmptyUtils } from '@ohos/settings.common/src/main/ets/utils/CheckEmptyUtils';
import { Controller } from '@ohos/settings.common/src/main/ets/core/controller/Controller';
import { LogUtil } from '@ohos/settings.common/src/main/ets/utils/LogUtil';
import { SettingsBaseMenu } from '@ohos/settings.common/src/main/ets/core/model/menu/SettingsMenu';
import { SingleChoiceListController } from '@ohos/settings.common/src/main/ets/core/controller/MenuController';
import { SingleChoiceEntryMenu, SingleSelectMenuItem } from '@ohos/settings.uikit/src/main/ets/menus/Menu';
import { WifiUtils } from '@ohos/settings.wifi/src/main/ets/WifiUtils';

/* instrument ignore file */
const TAG: string = 'privacyController : ';
const SLOT_ID_UNDEFINED: number = -1;

export default class PrivacyController extends SingleChoiceListController {
  public menuList: SingleSelectMenuItem[] = [];
  public defaultSlotId = SLOT_ID_UNDEFINED;
  public selectMenu:number = 0;
  public wifiConfig: wifiManager.WifiDeviceConfig;

  constructor(menu: SettingsBaseMenu) {
    super(menu);
    this.wifiConfig = menu.extra as wifiManager.WifiDeviceConfig;
    if ((this.menu instanceof SingleChoiceEntryMenu) && this.menu.singleChoiceData != null) {
      this.menuList = this.menu.singleChoiceData;
    }
    this.selectMenu = this.wifiConfig?.randomMacType ?
      wifiManager.DeviceAddressType.REAL_DEVICE_ADDRESS : wifiManager.DeviceAddressType.RANDOM_DEVICE_ADDRESS;
  }

  static CreatePrivacyController(menu: SettingsBaseMenu): Controller {
    return new PrivacyController(menu);
  }

  aboutToAppear(): void {
    if ((this.menu instanceof SingleChoiceEntryMenu) && this.menu.singleChoiceData != null) {
      this.menuList = this.menu.singleChoiceData;
    }

    super.aboutToAppear();
  }

  aboutToDisappear(): void {
    super.aboutToDisappear();
  }

  onSelectMenuChanged(key: number): void {
    LogUtil.info(`${TAG} onSelectMenuChanged data = ${key}`);
    this.selectMenu = key;
    this.wifiConfig.randomMacType = key;
    this.updateStatus();
    WifiUtils.reconnectWithNewConfig(TAG, this.wifiConfig);
    // 退出页面重进 用来刷新 mac 和 ip 显示
    this.menu.pathInfos?.pop();
  }

  onBindMenuAppear(): void {
    LogUtil.info(`${TAG} onBindMenuAppear`);
    this.updateStatus();
  }

  onBindMenuDisAppear(): void {
    LogUtil.info(`${TAG} onBindMenuDisAppear`);
    this.updateStatus();
  }

  updateStatus(): void {
    if (CheckEmptyUtils.isEmptyArr(this.menuList)) {
      LogUtil.error(`${TAG} menuList is null.`);
      return;
    }
    for (let item of this.menuList) {
      item.isSelect = item?.key === this.selectMenu;
    }
    this.menu.state = this.selectMenu ? $r('app.string.wifi_privacy_device') : $r('app.string.wifi_privacy_random');
    this.publishDataChange(this.menuList[this.selectMenu].title as string | number);
  }

}
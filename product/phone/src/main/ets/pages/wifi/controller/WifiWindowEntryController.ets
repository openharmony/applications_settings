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
import { PackagesConstant } from '@ohos/settings.common/src/main/ets/constant/PackagesConstant';
import { Controller } from '@ohos/settings.common/src/main/ets/core/controller/Controller';
import { SettingsBaseMenu } from '@ohos/settings.common/src/main/ets/core/model/menu/SettingsMenu';
import { AbilityUtils } from '@ohos/settings.common/src/main/ets/utils/AbilityUtils';
import { NavEntryKey } from '@ohos/settings.common/src/main/ets/utils/Consts';
import { LogUtil } from '@ohos/settings.common/src/main/ets/utils/LogUtil';
import { WindowManager } from '@ohos/settings.common/src/main/ets/window/WindowManager';
import { WifiEntryBaseController } from '@ohos/settings.wifi/src/main/ets/controller/WifiEntryBaseController';
import { ApMenu } from '@ohos/settings.wifi/src/main/ets/model/WifiModel';
import { apConnectManager } from '@ohos/settings.wifi/src/main/ets/WifiTracker';
import { WifiUtils } from '@ohos/settings.wifi/src/main/ets/WifiUtils';
import { PLUGIN_WIFI_WINDOW_URL } from '../model/WifiWindowPage';
import { WifiEntryController, WifiEntryParams } from './WifiEntryController';

/**
 * Wifi弹窗 Ap项控制器
 *
 * @since 2023-03-13
 */
export class WifiWindowEntryController extends WifiEntryController {
  public tag: string = 'WifiWindowEntryController : ';

  constructor(menu: SettingsBaseMenu) {
    super(menu);
  }

  static createWifiWindowEntryController(menu: SettingsBaseMenu): Controller {
    return new WifiWindowEntryController(menu);
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
    this.openConnectPage();
    return true;
  }

  protected openConnectPage(): void {
    let detailApMenu: ApMenu = new ApMenu(this.menu);
    if (detailApMenu.config) {
      // 已保存网络
      if (apConnectManager.startConnect(detailApMenu.config, false, this)) {
        this.menu.summary = $r('app.string.wifi_status_connecting');
        this.refreshUi();
      }
    } else {
      LogUtil.info(`${this.tag} openConnectPage`);
      let apConfig = WifiEntryBaseController.getWifiConfig(detailApMenu) as wifiManager.WifiDeviceConfig;
      let bundleName = PackagesConstant.SETTINGS_BUNDLE_NAME;
      let abilityName = PackagesConstant.SETTINGS_MAIN_ABILITY_NAME;
      let navEntryKey = NavEntryKey.WIFI_ENTRY;
      let message: string = `bundleName: ${bundleName}, abilityName: ${abilityName}, navEntryKey: ${navEntryKey}}`;
      LogUtil.info(`${this.tag} openConnectPage: ${message}`);
      const param: WifiEntryParams = {
        config: apConfig,
        isHiLinkNetwork: detailApMenu.isHiLinkNetwork,
        capabilities: detailApMenu.capabilities,
        // 进入WLAN列表界面后，展示密码输入半模态
        needShowModal: true,
        isFromMoreSetting: true,
      };
      if (bundleName && abilityName) {
        AbilityUtils.startAbilityForResult({
          bundleName: bundleName,
          abilityName: abilityName,
          uri: navEntryKey,
          parameters: {
            pushParams: param,
          },
        }, () => {
          // 关闭wifi plugin弹窗
          WindowManager.closePluginWindow(PLUGIN_WIFI_WINDOW_URL, true);
        });
      }
    }
  }
}

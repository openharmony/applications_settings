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

import dataShare from '@ohos.data.dataShare';
import { Controller } from '@ohos/settings.common/src/main/ets/core/controller/Controller';
import { DeviceNameUtil } from '@ohos/settings.common/src/main/ets/utils/DeviceNameUtils';
import { LogUtil } from '@ohos/settings.common/src/main/ets/utils/LogUtil';
import { MenuController } from '@ohos/settings.common/src/main/ets/core/controller/MenuController';
import { SettingsBaseMenu } from '@ohos/settings.common/src/main/ets/core/model/menu/SettingsMenu';
import { SettingsDataUtils } from '@ohos/settings.common/src/main/ets/utils/SettingsDataUtils';
import { HW_NEW_SYSTEM_UPDATE, SoftwareUpdateBadgeListenerManager } from '../listener/SoftwareUpdateBadgeListener';
import { SoftwareUpdateBadgeMenuStyle } from '../style/SoftwareUpdateBadgeMenuStyle';

const SETTINGS_DATA_DISPLAY_DEVICE_NAME: string = 'settings.general.display_device_name';

/**
 * 软件更新跳转控制器
 *
 * @since 2023-11-28
 */
export class SoftwareUpdateController extends MenuController {
  public tag: string = 'SoftwareUpdateController : ';
  private dataHelper: dataShare.DataShareHelper | null = null;
  private onDeviceNameDataChange = () => {
    if (this.menu.title) {
      this.menu.title = DeviceNameUtil.getDisplayDeviceName();
      this.refreshUi();
    }
  }

  /**
   * 创建软件更新控制器
   *
   * @param menu 软件更新菜单
   * @return 软件更新控制器
   */
  static CreateSoftwareUpdateController(menu: SettingsBaseMenu): Controller {
    return new SoftwareUpdateController(menu);
  }

  updateStatus(): void {
    super.updateStatus();
    this.setMenuBadgeValue('updateStatus');
  }

  private setMenuBadgeValue(source: string): void {
    let badge: string = SettingsDataUtils.getSettingsData(HW_NEW_SYSTEM_UPDATE, '0');
    LogUtil.info(`${this.tag} ${this.getLogKey()} badge from database is ${badge},
      menu badge: ${this.menu.badge}, source : ${source}`);
    if (badge !== null && badge !== undefined && !Number.isNaN(badge) && this.menu.badge !== Number(badge)) {
      this.changeBadgeAndStyle(badge);
      if (this.getLogKey() === 'about_device') {
        this.menu.state = $r('app.string.new_version_found_text');
      }
      this.refreshUi();
    }
  }

  private changeBadgeAndStyle(badge: string): void {
    this.menu.badge = Number(badge);
    (this.menu.style as SoftwareUpdateBadgeMenuStyle).changeStyle(this.menu);
  }

  protected registerDataChange(): void {
    super.registerDataChange();
    this.registerDeviceNameDataChange();
    SoftwareUpdateBadgeListenerManager.getInstance().registerSoftwareUpdateBadgeChangeListener(this);
  }

  protected unRegisterDataChange(): void {
    super.unRegisterDataChange();
    this.unRegisterDeviceNameDataChange();
    SoftwareUpdateBadgeListenerManager.getInstance().unRegisterSoftwareUpdateBadgeChangeListener(this);
  }

  private registerDeviceNameDataChange(): void {
    if (this.dataHelper) {
      SettingsDataUtils.registerSecurityDataChange(this.dataHelper, SETTINGS_DATA_DISPLAY_DEVICE_NAME,
        this.onDeviceNameDataChange);
    } else {
      (SettingsDataUtils.createDataHelper(SETTINGS_DATA_DISPLAY_DEVICE_NAME) as Promise<dataShare.DataShareHelper>)
        .then((dataShareHelper?: dataShare.DataShareHelper) => {
          if (dataShareHelper) {
            this.dataHelper = dataShareHelper;
            SettingsDataUtils.registerSecurityDataChange(this.dataHelper, SETTINGS_DATA_DISPLAY_DEVICE_NAME,
              this.onDeviceNameDataChange);
          }
        })
    }
  }

  private unRegisterDeviceNameDataChange(): void {
    SettingsDataUtils.unRegisterSecurityDataChange(this.dataHelper as dataShare.DataShareHelper,
      SETTINGS_DATA_DISPLAY_DEVICE_NAME);
  }

  /**
   * 软件更新角标变更监听器名称
   *
   * @return 监听器名称
   */
  getListenName(): string {
    return this.getKey();
  }

  /**
   * 软件更新角标变更监听器回调
   */
  onSoftwareUpdateBadgeChange(): void {
    this.setMenuBadgeValue('onMenuBadgeChange');
  }
}
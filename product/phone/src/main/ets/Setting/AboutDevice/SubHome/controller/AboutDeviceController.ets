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
import dataShare from '@ohos.data.dataShare';
import { LogMaskUtil, LogUtil } from '@ohos/settings.common/src/main/ets/utils/LogUtil';
import { SettingsDataUtils } from '@ohos/settings.common/src/main/ets/utils/SettingsDataUtils';
import { SystemUpdateConstants } from '@ohos/settings.common/src/main/ets/constant/SystemUpdateConstants';
import { homeInitData } from '@ohos/settings.common/src/main/ets/sendable/HomeInitData';
import { ItemResultType } from '@ohos/settings.common/src/main/ets/framework/model/SettingItemModel';
import lazy { DeviceNameUtil } from '@ohos/settings.common/src/main/ets/utils/DeviceNameUtils';
import { AccountUtil } from '@ohos/settings.common/src/main/ets/utils/AccountUtil';
import {
  notifyCompStateChange,
  SettingResultState,
  SettingStateType
} from '@ohos/settings.common/src/main/ets/framework/model/SettingStateModel';
import { AboutDeviceInfo } from '@ohos/settings.aboutdevice/src/main/ets/model/AboutDeviceInfo';
import { FormatUtils } from '@ohos/settings.systemUpdate/src/main/ets/utils/FormatUtils';
import { AllSceneMenuItemInfo } from '@ohos/settings.systemUpdate/src/main/ets/model/AllSceneMenuItemModel';
import {
  HW_NEW_SYSTEM_UPDATE,
  SoftwareUpdateBadgeListenerManager
} from '@ohos/settings.systemUpdate/src/main/ets/listener/SoftwareUpdateBadgeListener';
import {
  HW_NEW_SYSTEM_UPDATE_STATUS,
  SystemUpdateStatusListenerManager
} from '@ohos/settings.systemUpdate/src/main/ets/listener/SystemUpdateStatusListener';
import {
  AllSceneUpdateBadgeListenerManager
} from '@ohos/settings.systemUpdate/src/main/ets/listener/AllSceneUpdateBadgeListener';

const TAG = 'AboutDeviceController';
const SETTINGS_DATA_DISPLAY_DEVICE_NAME = 'settings.general.display_device_name';

export class AboutDeviceController {
  private deviceInfo?: AboutDeviceInfo;
  private badge: number = 0;
  private updateStatus: number = 0;
  private hasAllSceneVersion: boolean = false;
  private dataHelper: dataShare.DataShareHelper | null = null;
  private onDataChange = () => {
    const deviceName =  DeviceNameUtil.getDeviceNameAsync()
    if (this.deviceInfo) {
      this.deviceInfo.deviceName = deviceName;
      homeInitData.deviceName = deviceName;
    }
  }

  constructor(deviceInfo: AboutDeviceInfo) {
    this.deviceInfo = deviceInfo;
  }

  aboutToAppear(): void {
    LogUtil.showInfo(TAG, `deviceName is ${LogMaskUtil.getLogNickNameString(homeInitData.deviceName)}`);
    this.setMenuBadgeValue('updateStatus');
    this.setMenuSystemUpdateStatusValue('updateStatus');
    this.setAllSceneUpdateBadgeValue('aboutToAppear');
    this.getIsPrivacyUser();
    this.registerDataChange();
    if (homeInitData.deviceName && this.deviceInfo) {
      this.deviceInfo.deviceName = homeInitData.deviceName;
    } else {
      this.setDeviceName();
    }

    SoftwareUpdateBadgeListenerManager.getInstance().registerSoftwareUpdateBadgeChangeListener(this);
    SystemUpdateStatusListenerManager.getInstance().registerSystemUpdateStatusChangeListener(this);
    AllSceneUpdateBadgeListenerManager.getInstance().registerAllSceneUpdateBadgeChangeListener(this);
  }

  private getIsPrivacyUser(): void {
    AccountUtil.isCurrentPrivate().then((value) => {
      if (this.deviceInfo) {
        this.deviceInfo.isPrivacyUser = value;
      }
    }).catch(() => {
      LogUtil.error(`${TAG} get isPrivacyUser err`);
    })
  }

  private setDeviceName() {
    if (this.deviceInfo?.deviceName) {
      this.deviceInfo.deviceName = DeviceNameUtil.getDeviceNameAsync()
      notifyCompStateChange('Home.about_device_group.device_name',
        new Map<SettingStateType, SettingResultState>([[SettingStateType.STATE_TYPE_ITEM_RESULT,
          {
            type: ItemResultType.RESULT_TYPE_TEXT,
            result: { content: this.deviceInfo.deviceName }
          } as SettingResultState]]));
    }

  }

  aboutToDisappear(): void {
    this.deviceInfo = undefined;
    SoftwareUpdateBadgeListenerManager.getInstance().unRegisterSoftwareUpdateBadgeChangeListener(this);
    SystemUpdateStatusListenerManager.getInstance().unRegisterSystemUpdateStatusChangeListener(this);
    AllSceneUpdateBadgeListenerManager.getInstance().unRegisterAllSceneUpdateBadgeChangeListener(this);
    this.unRegisterDataChange();
  }

  private setMenuBadgeValue(source: string): void {
    SettingsDataUtils.getSettingsDataAsync(HW_NEW_SYSTEM_UPDATE, '0').then((badge) => {
      LogUtil.showInfo(TAG, `badge from database is ${badge}, source : ${source}`);
      if (badge !== null && badge !== undefined && !Number.isNaN(badge) && this.badge !== Number(badge)) {
        this.badge = Number(badge);
        if (this.deviceInfo) {
          this.deviceInfo.badge = this.badge;
        }
      }
    });
  }

  private setMenuSystemUpdateStatusValue(source: string): void {
    SettingsDataUtils.getSettingsDataAsync(HW_NEW_SYSTEM_UPDATE_STATUS, '0').then((updateStatus) => {
      LogUtil.showInfo(TAG, `updateStatus from database is ${updateStatus}, source : ${source}`);
      if (updateStatus !== null && updateStatus !== undefined && !Number.isNaN(updateStatus) &&
        this.updateStatus !== Number(updateStatus)) {
        this.updateStatus = Number(updateStatus);
        if (this.deviceInfo) {
          this.deviceInfo.systemUpdateStatus = this.updateStatus;
        }
      }
    });
  }

  private setAllSceneUpdateBadgeValue(source: string): void {
    LogUtil.showInfo(TAG, `setAllSceneUpdateBadgeValue, source : ${source}`);
    SettingsDataUtils.getSettingsDataAsync(SystemUpdateConstants.ALL_SCENE_MENU_ITEM_INFO, '').then((allSceneInfo) => {
      let allSceneMenuItemInfo = FormatUtils.parseJson<AllSceneMenuItemInfo>(allSceneInfo);
      LogUtil.showInfo(TAG, `hasAllSceneVersion is ${allSceneMenuItemInfo?.isShowBadge}`);
      if (allSceneMenuItemInfo !== null && allSceneMenuItemInfo !== undefined &&
        this.hasAllSceneVersion !== allSceneMenuItemInfo.isShowBadge) {
        this.hasAllSceneVersion = allSceneMenuItemInfo.isShowBadge;
        if (this.deviceInfo) {
          this.deviceInfo.hasAllSceneVersion = this.hasAllSceneVersion;
        }
      }
    });
  }

  private registerDataChange(): void {
    if (this.dataHelper) {
      SettingsDataUtils.registerSecurityDataChange(this.dataHelper, SETTINGS_DATA_DISPLAY_DEVICE_NAME,
        this.onDataChange);
    } else {
      (SettingsDataUtils.createDataHelper(SETTINGS_DATA_DISPLAY_DEVICE_NAME) as Promise<dataShare.DataShareHelper>)
        .then((dataShareHelper?: dataShare.DataShareHelper) => {
          if (dataShareHelper) {
            this.dataHelper = dataShareHelper;
            SettingsDataUtils.registerSecurityDataChange(this.dataHelper, SETTINGS_DATA_DISPLAY_DEVICE_NAME,
              this.onDataChange);
          }
        })
    }
  }

  private unRegisterDataChange(): void {
    SettingsDataUtils.unRegisterSecurityDataChange(this.dataHelper as dataShare.DataShareHelper,
      SETTINGS_DATA_DISPLAY_DEVICE_NAME);
  }

  /**
   * 软件更新角标变更监听器名称
   *
   * @return 监听器名称
   */
  getListenName(): string {
    return TAG;
  }

  /**
   * 软件更新角标变更监听器回调
   */
  onSoftwareUpdateBadgeChange(): void {
    this.setMenuBadgeValue('onMenuBadgeChange');
  }

  /**
   * 系统升级状态变更监听回调
   */
  onSystemUpdateStatusChange(): void {
    this.setMenuSystemUpdateStatusValue('onSystemUpdateStatusChange');
  }

  /**
   * 协同升级角标变更监听器回调
   */
  onAllSceneUpdateBadgeChange(): void {
    this.setAllSceneUpdateBadgeValue('onAllSceneUpdateBadgeChange');
  }
}
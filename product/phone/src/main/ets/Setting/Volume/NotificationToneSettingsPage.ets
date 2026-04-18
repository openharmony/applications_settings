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

import systemSoundManager from '@ohos.multimedia.systemSoundManager';
import { AboutDeviceUtils } from '@ohos/settings.aboutdevice/src/main/ets/utils/AboutDeviceUtils';
import { CommonEventConstant } from '@ohos/settings.common/src/main/ets/constant/CommonEventConstant';
import { EventBus } from '@ohos/settings.common/src/main/ets/framework/common/EventBus';
import { PageLoader } from '@ohos/settings.common/src/main/ets/framework/common/PageLoader';
import { PageType, SettingPageModel } from '@ohos/settings.common/src/main/ets/framework/model/SettingPageModel';
import { HiSysVolumeEventGroup } from '@ohos/settings.common/src/main/ets/systemEvent/BehaviorEventConsts';
import { HiSysEventUtil } from '@ohos/settings.common/src/main/ets/systemEvent/HiSysEventUtil';
import { NavEntryKey } from '@ohos/settings.common/src/main/ets/utils/Consts';
import { LogUtil } from '@ohos/settings.common/src/main/ets/utils/LogUtil';
import { PreferencesUtil } from '@ohos/settings.common/src/main/ets/utils/PreferencesUtil';
import { ResourceUtil } from '@ohos/settings.common/src/main/ets/utils/ResourceUtil';
import { RingtoneType } from './constant/VolumeConstant';
import { ToneAttrs } from './model/VolumeType';
import { RingtonesUtils } from './utils/RingtonesUtils';
import { SystemRingTonePage } from './view/SystemRingToneComponent';
/* instrument ignore file */
@Component
export struct NotificationToneSettings {
  private card1Type: systemSoundManager.SystemToneType =
    systemSoundManager.SystemToneType.SYSTEM_TONE_TYPE_NOTIFICATION;
  private localeChangeForNotificationTone: string = 'localeChangeForNotificationTone';
  private otaFlagForNotification = 'otaFlagForNotification';
  tag: string = 'NotificationToneSettings';
  title: string = ResourceUtil.getStringSync($r('app.string.ring_tone_settings_notification'));
  dataKey: string = 'NotificationTone';
  @State notificationList: Array<ToneAttrs> | null = null;
  @State filePath: string = '';

  build() {
    NavDestination() {
      Column() {
        if (this.notificationList !== null) {
          Blank().height($r('app.float.navigation_56'))
          SystemRingTonePage({
            ringList: this.notificationList.filter(tone => {
              return tone.customizedType === systemSoundManager.ToneCustomizedType.PRE_INSTALLED
            }),
            navKey: NavEntryKey.NOTIFICATION_TONE_ENTRY,
          }).margin({bottom: $r('app.float.navigation_56')})
        }
      }
      .expandSafeArea([SafeAreaType.SYSTEM])
      .size({ width: '100%', height: '100%' })
    }
    .hideTitleBar(false)
    .title(this.title)
    // .titleBar({content: {title: {mainTitle: this.title}}})
    .backgroundColor($r('sys.color.comp_background_gray'))
    .onShown(() => {
      this.onPageShow();
    })
    .onHidden(() => {
      this.onPageHide();
    })
  }

  private async getCardData(): Promise<void> {
    this.notificationList = PreferencesUtil.getSync(this.dataKey, []) as Array<ToneAttrs>;
    let isLocaleChange: boolean = PreferencesUtil.getSync(this.localeChangeForNotificationTone, false) as boolean;
    let curVersion: string = AboutDeviceUtils.getSoftwareVersion();
    let otaFlag: boolean = PreferencesUtil.getSync(this.otaFlagForNotification + '_version', '') as string !== curVersion;
    if (!PreferencesUtil.hasSync(this.dataKey) || isLocaleChange || this.notificationList.length === 0 || otaFlag) {
      this.notificationList = await RingtonesUtils.getRingerToneList(this.card1Type,
        RingtoneType.RINGTONE_TYPE_NOTIFICATION);
      PreferencesUtil.putSync(this.dataKey, this.notificationList);
      // ota场景刷新一次，避免出现列表不显示问题
      PreferencesUtil.putSync(this.otaFlagForNotification + '_version', curVersion);
      LogUtil.showInfo(this.tag, `getCardData notificationList: ${this.notificationList.length}, isLocalChange: ${isLocaleChange}, otaFlag: ${otaFlag}`);
      return;
    }
    LogUtil.showInfo(this.tag, `get notification list from preference : ${this.notificationList.length}, isLocalChange: ${isLocaleChange}, otaFlag: ${otaFlag}`);
  }

  aboutToAppear(): void {
    LogUtil.info(`${this.tag} aboutToAppear`);
    this.getCardData();
  }

  aboutToDisappear(): void {
    LogUtil.info(`${this.tag} aboutToDisappear`);
  }

  onPageShow(): void {
    HiSysEventUtil.reportDefaultBehaviorEventByUE(HiSysVolumeEventGroup.VOLUME_NOTIFICATION_RINGTONE);
    EventBus.getInstance().emit(CommonEventConstant.EVENT_VOLUME_RINGTONE_PAGE_STATE_CHANGE, true);
    LogUtil.info(`${this.tag} onPageShow`);
  }

  onPageHide(): void {
    EventBus.getInstance().emit(CommonEventConstant.EVENT_VOLUME_RINGTONE_PAGE_STATE_CHANGE, false);
    LogUtil.info(`${this.tag} onPageHide`);
  }
}

@Builder function notificationToneSettingsBuilder(item: object) {
  NotificationToneSettings();
}

function notificationTonePage(): SettingPageModel {
  return {
    id: 'notification_tone_settings_page',
    url: NavEntryKey.NOTIFICATION_TONE_ENTRY,
    type: PageType.PAGE_TYPE_CUSTOM,
    title: $r('app.string.ring_tone_settings_notification'),
  }
}

// 页面配置导入
PageLoader.load(NavEntryKey.NOTIFICATION_TONE_ENTRY, {
  configGenerator: notificationTonePage,
  pageBuilder: wrapBuilder(notificationToneSettingsBuilder),
});
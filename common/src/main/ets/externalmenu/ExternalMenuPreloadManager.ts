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

import type { BusinessError } from '@ohos.base';
import type Want from '@ohos.app.ability.Want';
import type { Context } from '@ohos.abilityAccessCtrl';
import { LogUtil } from '../utils/LogUtil';

const TAG = 'ExternalMenuPreloadManager : ';

export class PreloadPageInfo {
  bundleName: string;
  moduleName: string;
  abilityName: string;
  entryKey: string[];
}

/**
 * 外部菜单UIExtension预加载管理类
 *
 * @since 2024-04-26
 */
export class ExternalMenuPreloadManager {
  private preloadPages: PreloadPageInfo[] = [
    {
      'bundleName': 'com.ohos.sceneboard',
      'moduleName': 'default_notificationmanagement',
      'abilityName': 'NotificationUIExtAbility',
      'entryKey': ['systemui_notification_settings', 'aod_settings_entry', 'aod_style_entry']
    },
    {
      'bundleName': 'com.ohos.security.privacycenter',
      'moduleName': 'entry',
      'abilityName': 'MainAbility',
      'entryKey': ['privacy_settings']
    },
    {
      'bundleName': 'com.ohos.pcsettings',
      'moduleName': 'entry',
      'abilityName': 'AudioUIExtensionAbility',
      'entryKey': ['pc_audio_settings']
    },
    {
      'bundleName': 'com.ohos.security.privacycenter',
      'moduleName': 'entry',
      'abilityName': 'SettingsPermissionAbility',
      'entryKey': ['SettingsPermissionAbility']
    },
    {
      'bundleName': 'com.ohos.sceneboard',
      'moduleName': '',
      'abilityName': 'SettingThemeComponentExtAbility',
      'entryKey': ['SettingThemeComponentExtAbility']
    },
    {
      'bundleName': 'com.ohos.sceneboard',
      'moduleName': '',
      'abilityName': 'TvThemeComponentExtAbility',
      'entryKey': ['TvThemeComponentExtAbility']
    },
    {
    'bundleName': 'com.ohos.sceneboard',
    'moduleName': '',
    'abilityName': 'AodSettingsAbility',
    'entryKey': ['AodSettingsAbility']
  },
  ];

  private getPreloadPageInfo(key: string): PreloadPageInfo | undefined {
    let preloadPageInfo: PreloadPageInfo | undefined = this.preloadPages.find(item => {
      let entryKeys: string[] = item.entryKey;
      return entryKeys.find(entry => entry === key);
    });
    return preloadPageInfo;
  }

  public async preloadUIExtensionAbility(key: string, context: Context): Promise<void> {
    LogUtil.info(`${TAG} preloadUIExtensionAbility ${key}`);
    if (!context) {
      LogUtil.warn(`${TAG} preloadUIExtensionAbility failed, context is null`);
      return;
    }
    let pageInfo: PreloadPageInfo | undefined = this.getPreloadPageInfo(key);
    if (pageInfo) {
      LogUtil.info(`${TAG} preloadUIExtensionAbility ${key} start, ${pageInfo.bundleName}, ${pageInfo.abilityName} `);
      let want: Want = {
        bundleName: pageInfo.bundleName,
        abilityName: pageInfo.abilityName,
      };
      context.getApplicationContext().preloadUIExtensionAbility(want)
        .then(() => {
          LogUtil.info(`${TAG} preloadUIExtensionAbility ${key} success`);
        })
        .catch((err: BusinessError) => {
          LogUtil.info(`${TAG} preloadUIExtensionAbility ${key} fail, errCode is ${err.code}, errMsg ${err.message}`);
        });
    } else {
      LogUtil.info(`${TAG} preloadUIExtensionAbility can not find menu, uri is ${key}`);
    }
  }

  static getInstance(): ExternalMenuPreloadManager {
    if (!Boolean(AppStorage.get<ExternalMenuPreloadManager>('ExternalMenuPreloadManager') as ExternalMenuPreloadManager).valueOf()) {
      AppStorage.setOrCreate<ExternalMenuPreloadManager>('ExternalMenuPreloadManager', new ExternalMenuPreloadManager());
    }
    return AppStorage.get<ExternalMenuPreloadManager>('ExternalMenuPreloadManager') as ExternalMenuPreloadManager;
  }
}

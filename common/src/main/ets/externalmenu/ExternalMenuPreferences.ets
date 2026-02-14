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

import systemParameter from '@ohos.systemparameter';
import deviceInfo from '@ohos.deviceInfo';
import preferences from '@ohos.data.preferences';
import common from '@ohos.app.ability.common';
import { BusinessError } from '@ohos.base';
import { LogUtil } from '../utils/LogUtil';
import { ExternalMenu } from './ExternalMenuManager';
import { APP_CONFIG, PreferencesUtil } from '../utils/PreferencesUtil';
import { MemoryMgrUtils } from '../utils/MemoryMgrUtils';
import { ResourceManagerUtil } from '../utils/ResourceManagerUtil';

const TAG = 'ExternalMenuPreferences : ';
const DISPLAY_VERSION_SYS_PARAM_KEY: string = 'persist.hwpatch.display.version';

/**
 * 外部加载项工具类，用于优化页面冷启动元素加载
 *
 * @author openharmony
 * @since 2024-01-04
 */
export class ExternalMenuPreferences {
  /**
   * 系统版本号
   */
  public systemVersion: string = systemParameter.getSync(DISPLAY_VERSION_SYS_PARAM_KEY) ?? deviceInfo.displayVersion;

  private getPreferences(key: string): string[] {
    let value: string = String(PreferencesUtil.getSync(key, ''));
    let dataArray: string[] = [];
    dataArray = value.split('_');
    return dataArray;
  }

  /**
   * 获取系统版本
   */
  public getDisplayVersion(): void {
    let version: string = systemParameter.getSync(DISPLAY_VERSION_SYS_PARAM_KEY);
    if (version) {
      this.systemVersion = version;
      return;
    }
    this.systemVersion = deviceInfo.displayVersion;
  }

  /**
   * 加载标题和辅助文本资源
   *
   * @param externalMenu 当前的外部接入对象
   * @param force 是否强制加载，true为是，false为否
   * @return 标题和辅助文本资源
   */
  public getTitleAndSummaryResource(externalMenu: ExternalMenu | undefined, force: boolean): string[] {
    if (!externalMenu) {
      return ['', ''];
    }

    const titleKey: string = `Title_${externalMenu.bundleName}${externalMenu.abilityName}`;
    const summaryKey: string = `Sum_${externalMenu.bundleName}${externalMenu.abilityName}`;
    let title: string = '';
    let summary: string = '';
    try {
      let keyExist: boolean = PreferencesUtil.hasSync(titleKey);
      LogUtil.info(`${TAG} ${titleKey} keyExist: ${keyExist}, force ${force}`);
      if (!keyExist || force) {
        let resourceManager = ResourceManagerUtil.getBundleResourceManager(externalMenu.bundleName);
        title = externalMenu.loadTitleResourceNew(resourceManager);
        PreferencesUtil.put(titleKey, this.systemVersion + '_' + title);
        summary = externalMenu.loadSummaryResourceNew(resourceManager);
        PreferencesUtil.put(summaryKey, this.systemVersion + '_' + summary);
        MemoryMgrUtils.removeNapiWrap(resourceManager, false);
      } else {
        let titleArray: string[] = this.getPreferences(titleKey);
        title = titleArray.length < 2 ? '' : titleArray[1];
        let summaryArray: string[] = this.getPreferences(summaryKey);
        summary = summaryArray.length < 2 ? '' : summaryArray[1];
      }
      LogUtil.info(`${TAG} ${titleKey} title: ${title}, summary ${summary}`);
      return [title, summary];
    } catch (e) {
      LogUtil.error(`${TAG} get external menu fail, key: ${title} error: ${(e as BusinessError).message}`)
      return ['', ''];
    }
  }
}

export let externalMenuPreferences = new ExternalMenuPreferences();

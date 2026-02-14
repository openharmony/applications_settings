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

import bundle from '@ohos.bundle.bundleManager';
import { LogUtil } from '@ohos/settings.common/src/main/ets/utils/LogUtil';
import accessibility from '@ohos.accessibility';
/* instrument ignore file */
const TAG: string = 'ExtensionServiceInstallModel : ';
const ACCESSIBILITY: string = 'accessibility';

/**
 * 查询已安装扩展服务
 *
 * @since 2024-01-02
 */
export class ExtensionServiceInstallModel {
  static async getInstalledList(): Promise<bundle.ExtensionAbilityInfo[]> {
    let flags = bundle.BundleFlag.GET_BUNDLE_INFO_WITH_APPLICATION |
    bundle.BundleFlag.GET_BUNDLE_INFO_WITH_HAP_MODULE |
    bundle.BundleFlag.GET_BUNDLE_INFO_WITH_EXTENSION_ABILITY;
    let list: bundle.ExtensionAbilityInfo[] = [];
    let data: bundle.BundleInfo[] = [];
    try {
      data = await bundle.getAllBundleInfo(flags);
      LogUtil.info(`${TAG} get getInstalledList success data: ${data.length}`);
    } catch (err) {
      LogUtil.error(`${TAG} failed to get getAllBundleInfo, because ${err?.message}`);
    }
    for (let item of data) {
      if (item.hapModulesInfo[0].extensionAbilitiesInfo) {
        for (let val of item.hapModulesInfo[0].extensionAbilitiesInfo) {
          if (val.extensionAbilityTypeName === ACCESSIBILITY) {
            list.push(val);
          }
        }
      }
    }
    LogUtil.info(`${TAG} get getInstalledList success list: ${list.length}`);
    let installedServiceList: accessibility.AccessibilityAbilityInfo[] =
      await accessibility.getAccessibilityExtensionList('all', 'install');
    let resultList: bundle.ExtensionAbilityInfo[] = [];
    for (let entry of list) {
      if (!entry) {
        LogUtil.info(`${TAG} entry is null.`);
        continue;
      }
      let entryId: string = entry.bundleName.concat('/').concat(entry.name);
      if (!entry.bundleName || !entry.name) {
        LogUtil.info(`${TAG} paramter error`);
        continue;
      }

      for (let installedService of installedServiceList) {
        if (installedService.id === entryId) {
          if (installedService.needHide) {
            LogUtil.info(`${TAG} this service ${entryId} need hide`);
            continue;
          } else {
            resultList.push(entry);
          }
        }
      }
    }
    return resultList;
  }
}
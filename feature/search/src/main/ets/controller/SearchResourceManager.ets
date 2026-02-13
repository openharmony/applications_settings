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

import resmgr from '@ohos.resourceManager';
import { AbilityContextManager } from '@ohos/settings.common/src/main/ets/ability/AbilityContextManager';
import { AbilityUtils } from '@ohos/settings.common/src/main/ets/utils/AbilityUtils';
import { CheckEmptyUtils } from '@ohos/settings.common/src/main/ets/utils/CheckEmptyUtils';
import { LogUtil } from '@ohos/settings.common/src/main/ets/utils/LogUtil';
import { MemoryMgrUtils } from '@ohos/settings.common/src/main/ets/utils/MemoryMgrUtils';
import { ThreadUtils } from '@ohos/settings.common/src/main/ets/utils/ThreadUtils';

const TAG: string = 'SearchResourceManager';
const PATH_SYMBOL: string = ' > ';
const LINK_STRING_FLAG: string = '$string:';

export class SearchResourceManager {
  private resourceManager: resmgr.ResourceManager | undefined = undefined;
  private locale: string = 'en-US';
  private bundleResourceManagerMap: Map<string, resmgr.ResourceManager> = new Map();

  constructor(locale: string) {
    if (CheckEmptyUtils.checkStrIsEmpty(locale)) {
      LogUtil.showError(TAG, 'setLocale failed, locale is empty');
      return;
    }
    this.locale = locale;
    LogUtil.showInfo(TAG, `set current locale: ${locale}`);
  }

  /**
   * 移除外部包管理
   *
   * @param bundleName 包名
   */
  public removeExternalResourceManager(bundleName: string): void {
    if (this.bundleResourceManagerMap.has(bundleName)) {
      MemoryMgrUtils.removeNapiWrap(this.bundleResourceManagerMap.get(bundleName), false);
      this.bundleResourceManagerMap.delete(bundleName);
    }
  }

  public clearCache(): void {
    this.resourceManager?.release();
    for (let resourceManager of this.bundleResourceManagerMap.values()) {
      MemoryMgrUtils.removeNapiWrap(resourceManager, false);
    }
    this.bundleResourceManagerMap.clear();
    // 主动触发GC，清理包管理信息
    AbilityUtils.timeoutForceGC(1000, 'SearchDataController->initExternalSearchData');
  }

  public getStringByName(stringName: string): string {
    try {
      let resourceManager = this.getResourceManager();
      let name = stringName.replace(LINK_STRING_FLAG, '');
      return resourceManager.getStringByNameSync(name);
    } catch (error) {
      LogUtil.error(`${TAG} getStringByName failed, error code: ${error?.code}, message: ${error?.message}.`);
      return '';
    }
  }

  public getExternalStringByName(bundleName: string, stringName: string): string {
    if (CheckEmptyUtils.checkStrIsEmpty(bundleName)) {
      LogUtil.showError(TAG, 'getExternalStringByName bundleName is empty');
      return '';
    }

    try {
      /* instrument ignore if*/
      let overrideResourceManager = this.getBundleResourceManager(bundleName);
      if (!overrideResourceManager) {
        return '';
      }

      let name = stringName.replace(LINK_STRING_FLAG, '');
      return overrideResourceManager.getStringByNameSync(name);
    } catch (error) {
      LogUtil.error(`${TAG} getExternalStringByName failed, message: ${error?.message}.`);
      return '';
    }
  }

  public getPathByName(bundleName: string, nameList: string[], isExternal: boolean): string {
    if (CheckEmptyUtils.isEmptyArr(nameList)) {
      return '';
    }
    try {
      let resourceManager: resmgr.ResourceManager | undefined =
        isExternal ? this.getBundleResourceManager(bundleName) : this.getResourceManager();
      /* instrument ignore if*/
      if (!resourceManager) {
        return '';
      }

      let path: string = '';
      for (let stringName of nameList) {
        let pathName = resourceManager?.getStringByNameSync(stringName.replace(LINK_STRING_FLAG, ''));
        /* instrument ignore if*/
        if (CheckEmptyUtils.checkStrIsEmpty(pathName)) {
          return '';
        }
        path = path.concat(pathName + PATH_SYMBOL);
      }
      return path.substring(0, path.length - PATH_SYMBOL.length);
    } catch (err) {
      LogUtil.showError(TAG, `getPathByName error: ${err?.message}}`);
      return '';
    }
  }

  public getNumberFormatStringSync(resource: Resource, subStr: string): string {
    let resourceString: string = '';
    if (!resource) {
      return resourceString;
    }

    try {
      let resourceManager = this.getResourceManager();
      /* instrument ignore if*/
      if (!resourceManager) {
        return resourceString;
      }
      resourceString = resourceManager.getStringSync(resource.id);
    } catch (err) {
      LogUtil.error(`${TAG} getNumberFormatStringSync error: ${err?.message}`);
      return resourceString;
    }
    return resourceString.replace(new RegExp('%d', 'gm'), subStr);
  }

  private getResourceManager(): resmgr.ResourceManager {
    if (this.resourceManager) {
      return this.resourceManager;
    }

    let resMgr = this.getContext()?.resourceManager;
    let config: resmgr.Configuration = resMgr.getOverrideConfiguration();
    config.locale = this.locale;
    this.resourceManager = resMgr.getOverrideResourceManager(config);
    return this.resourceManager;
  }

  private getBundleResourceManager(bundleName: string): resmgr.ResourceManager | undefined {
    let defaultResourceManager: resmgr.ResourceManager | undefined;
    if (this.bundleResourceManagerMap.has(bundleName)) {
      defaultResourceManager = this.bundleResourceManagerMap.get(bundleName);
    } else {
      defaultResourceManager = this.getContext()?.createBundleContext(bundleName)?.resourceManager;
    }
    if (!defaultResourceManager) {
      return undefined;
    }
    this.bundleResourceManagerMap.set(bundleName, defaultResourceManager);
    let config: resmgr.Configuration = defaultResourceManager.getOverrideConfiguration();
    config.locale = this.locale;
    return defaultResourceManager.getOverrideResourceManager(config);
  }

  private getContext(): Context {
    if (ThreadUtils.isMainThread()) {
      return AbilityContextManager.getStageContext();
    }
    return AbilityContextManager.getSubThreadContext();
  }
}
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
import resourceManager from '@ohos.resourceManager';
import accessibility from '@ohos.accessibility';
import { LogUtil } from '@ohos/settings.common/src/main/ets/utils/LogUtil';
import { ServiceBaseEntry } from '@ohos/settings.common/src/main/ets/core/model/menu/SettingsMenu';
import { BaseEntryMenu } from '@ohos/settings.common/src/main/ets/core/model/menu/BaseMenu';
import { AbilityContextManager } from '@ohos/settings.common/src/main/ets/ability/AbilityContextManager';
import { MemoryMgrUtils } from '@ohos/settings.common/src/main/ets/utils/MemoryMgrUtils';
import { ResourceManagerUtil } from '@ohos/settings.common/src/main/ets/utils/ResourceManagerUtil';
/* instrument ignore file */
const TAG: string = 'ServiceModel: ';
const DEFAULT_ID: number = 0;

/**
 * 扩展服务数据类
 *
 * @since 2023-06-26
 */
export class ServiceEntry implements ServiceBaseEntry {
  public appInfo: bundle.ApplicationInfo;
  public name: string;
  public icon: ResourceStr;
  public locale: string = '';
  public description: string;
  public serviceName: string;
  public bundleName: string;
  public serviceState: boolean;
  public label: string;
  public iconId: number = DEFAULT_ID;
  public moduleInfo: Array<bundle.HapModuleInfo>;
  public pageContext: Context = AbilityContextManager.getContext();

  constructor(serviceInfo: bundle.ExtensionAbilityInfo | accessibility.AccessibilityAbilityInfo, state: boolean,
              bundleInfo: bundle.BundleInfo) {
    this.serviceName = serviceInfo.name;
    this.bundleName = serviceInfo.bundleName;
    this.description = '';
    this.label = '';
    this.serviceState = state;
    this.appInfo = bundleInfo.appInfo;
    this.iconId = bundleInfo.appInfo.iconId;
    this.icon = '';
    this.moduleInfo = bundleInfo.hapModulesInfo;
    this.name = serviceInfo.bundleName + '/' + serviceInfo.name;
  }

  isLocaleMatch(locale: string): boolean {
    return this.locale === locale;
  }

  private isResourceIdValid(id: number): boolean {
    return !Number.isNaN(id) && id > DEFAULT_ID;
  }

  /**
   * 异步加载图标
   * @returns icon是否重新加载
   */
  async loadIcon(): Promise<boolean> {
    if (this.icon) {
      LogUtil.info(`${TAG} loadIcon return`);
      return false;
    }
    if (!this.isResourceIdValid(this.iconId)) {
      LogUtil.warn(`${TAG} iconId invalid: ${this.iconId}`);
      this.icon = this.getDefaultIcon();
      return true;
    }
    let resourceManager = ResourceManagerUtil.getResManagerWithContext(this.bundleName, this.pageContext);
    if (!resourceManager) {
      LogUtil.warn(`${TAG} resourceManager invalid`);
      this.icon = this.getDefaultIcon();
      return true;
    }

    this.icon = await resourceManager.getMediaBase64(this.iconId);
    if (!this.icon) {
      LogUtil.warn(`${TAG} get icon invalid`);
      this.icon = this.getDefaultIcon();
    }
    MemoryMgrUtils.removeNapiWrap(resourceManager, false);
    return true;
  }

  private getDefaultIcon(): ResourceStr {
    return $r('sys.media.ohos_app_icon');
  }

  /**
   * 异步加载服务说明
   * @returns description是否重新加载
   */
  async loadDescription(): Promise<boolean> {
    if (this.description) {
      LogUtil.info(`${TAG} loadDescription return`);
      return false;
    }
    if (this.moduleInfo) {
      for (let hapInfo of this.moduleInfo) {
        for (let ability of hapInfo.extensionAbilitiesInfo) {
          if (ability.name === this.serviceName) {
            let resourceManager = ResourceManagerUtil.getResManagerWithContext(this.bundleName, this.pageContext);
            if (!resourceManager) {
              LogUtil.warn(`${TAG} resourceManager invalid`);
              return true;
            }
            if (!this.isResourceIdValid(ability.descriptionId)) {
              LogUtil.info(`${TAG} descriptionId invalid: ${ability.descriptionId}`);
              return true;
            }
            this.description = await resourceManager.getString(ability.descriptionId);
            if (!this.description) {
              LogUtil.warn(`${TAG} get description invalid`);
            }
            LogUtil.info(`${TAG} loadDescription end`);
            MemoryMgrUtils.removeNapiWrap(resourceManager, false);
            return true;
          }
        }
      }
    }
    LogUtil.info(`${TAG} loadDescription end`);
    return true;
  }

  /**
   * 异步加载服务名称，使用label作为服务名称
   * @returns label是否重新加载
   */
  async loadLabel(): Promise<boolean> {
    if (this.label) {
      LogUtil.info(`${TAG} loadLabel return`);
      return false;
    }
    this.label = await this.getLabelInfo();
    if (!this.label) {
      LogUtil.warn(`${TAG} get label invalid`);
    }
    LogUtil.info(`${TAG} loadLabel end`);
    return true;
  }

  async getLabelInfo(): Promise<string> {
    if (!this.moduleInfo) {
      LogUtil.info(`${TAG} moduleInfo invalid`);
      return '';
    }
    for (let hapInfo of this.moduleInfo) {
      for (let ability of hapInfo.extensionAbilitiesInfo) {
        if (ability.name != this.serviceName) {
          continue;
        }
        let resourceManager = ResourceManagerUtil.getResManagerWithContext(ability.bundleName, this.pageContext);
        if (!resourceManager) {
          LogUtil.info(`${TAG} resourceManager invalid`);
          return '';
        }
        if (!this.isResourceIdValid(ability.labelId)) {
          LogUtil.info(`${TAG} descriptionId invalid: ${ability.labelId}`);
          return '';
        }
        let label: string = await resourceManager.getString(ability.labelId);
        if (!label) {
          LogUtil.warn(`${TAG} get label invalid`);
          return '';
        }
        MemoryMgrUtils.removeNapiWrap(resourceManager, false);
        return label;
      }
    }
    return '';
  }
}

/**
 * 扩展服务菜单数据类
 *
 * @since 2022-05-26
 */
export class ServiceMenu extends BaseEntryMenu {
  public serviceEntry: ServiceEntry | null = null;

  constructor(serviceEntry: ServiceEntry) {
    super(serviceEntry);
    this.updateEntry(serviceEntry);
  }

  updateEntry(serviceEntry: ServiceEntry): void {
    this.serviceEntry = serviceEntry;
    this.key = serviceEntry.name;
    this.title = serviceEntry.label;
    this.icon = serviceEntry.icon;
    this.timestamp = new Date().getTime();
  }
}

export class RecentServiceMenu extends ServiceMenu {
  updateEntry(serviceEntry: ServiceEntry): void {
    this.serviceEntry = serviceEntry;
    this.title = serviceEntry.label;
    this.icon = serviceEntry.icon;
    this.timestamp = new Date().getTime();
  }
}

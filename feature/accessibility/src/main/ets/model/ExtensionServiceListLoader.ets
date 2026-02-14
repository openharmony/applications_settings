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
import accessibility from '@ohos.accessibility';
import i18n from '@ohos.i18n';
import intl from '@ohos.intl';
import { LogUtil } from '@ohos/settings.common/src/main/ets/utils/LogUtil';
import { ExtensionServiceInstallModel } from './ExtensionServiceInstallModel';
import { ServiceEntry } from './ServiceModel';
import {
  BundleStatusChangeListener,
  BundleStatusChangeManager
} from '@ohos/settings.common/src/main/ets/bundle/BundleStatusChangeManager';
/* instrument ignore file */
const TAG: string = 'ExtensionServiceListLoader: ';

/**
 * 扩展服务列表加载监听接口
 *
 * @since 2023-06-15
 */
export interface ServiceEntryChangedListener {
  /**
   * 获取 listener name
   * @returns listener name
   */
  getListenerName(): string;

  /**
   * 扩展服务列表变化回调
   */
  onServiceListChanged(serviceList: Array<ServiceEntry>): void;

  /**public
   * 扩展服务更新/数据变化回调
   */
  onServiceUpdate(serviceEntry: ServiceEntry): void;

  /**
   * 扩展服务卸载回调
   */
  onServiceRemove(bundleName: string): void;
}

/**
 * 扩展服务列表加载类
 *
 * @since 2023-06-16
 */
export class ExtensionServiceListLoader {
  public listenerKey: string = 'extension_service_list_loader';
  private static instance: ExtensionServiceListLoader;
  public isRegister: boolean = false;
  public lastSystemLocale: string = '';
  public servicesCache: Map<string, ServiceEntry> = new Map<string, ServiceEntry>();
  public serviceListeners: ServiceEntryChangedListener[] = [];

  /**
   * 注册扩展服务加载变化监听
   *
   * @param listener 监听者
   */
  public registerServiceChangedListener(listener: ServiceEntryChangedListener): void {
    if (!listener) {
      LogUtil.error(`${TAG} registerServiceChangedListener listener invalid`);
      return;
    }

    for (const serviceListener of this.serviceListeners) {
      if (serviceListener.getListenerName() === listener.getListenerName()) {
        LogUtil.info(`${TAG} registerStateChangeListener listener already register`);
        return;
      }
    }

    this.serviceListeners.push(listener);
    this.registerStatusChange();
  }

  /**
   * 取消注册扩展服务加载变化监听
   *
   * @param listener 监听者
   */
  public unRegisterServiceChangedListener(listener: ServiceEntryChangedListener): void {
    if (!listener) {
      LogUtil.error(`${TAG} unRegisterServiceChangedListener: invalid listener`);
      return;
    }
    for (let index = 0; index < this.serviceListeners.length; index++) {
      if (this.serviceListeners[index].getListenerName() === listener.getListenerName()) {
        this.serviceListeners.splice(index, 1);
        if (this.serviceListeners.length === 0) {
          this.unRegisterStatusChange();
        }
        return;
      }
    }
  }

  private readonly bundleStatusCallback: BundleStatusChangeListener = {
    getListenerName: (): string => {
      return this.listenerKey ?? ' ';
    },
    onBundleAdd: (bundleName: string, userId: number) => {
      LogUtil.info(`${TAG} bundleStatusCallback add : bundleName:${bundleName} userId:${userId}`);
      this.updateServiceEntry(bundleName);
    },
    onBundleRemove: (bundleName: string, userId: number) => {
      LogUtil.info(`${TAG} bundleStatusCallback remove : bundleName:${bundleName} userId:${userId}`);
      this.removeServiceEntry(bundleName);
    },
    onBundleUpdate: (bundleName: string, userId: number) => {
      LogUtil.info(`${TAG} bundleStatusCallback update : bundleName:${bundleName} userId:${userId}`);
      this.updateServiceEntry(bundleName);
    }
  };

  private registerStatusChange(): void {
    if (!this.isRegister) {
      BundleStatusChangeManager.getInstance().registerBundleChangedListener(this.bundleStatusCallback);
      this.isRegister = true;
    }
  }

  private unRegisterStatusChange(): void {
    if (this.isRegister) {
      BundleStatusChangeManager.getInstance().unRegisterBundleChangedListener(this.bundleStatusCallback);
      this.isRegister = false;
    }
  }

  private updateSystemLocale(): void {
    let currentSystemLocale = i18n.getSystemLocale();
    LogUtil.info(`${TAG} currentSystemLocale : ${currentSystemLocale}`);
    if (this.lastSystemLocale !== currentSystemLocale) {
      LogUtil.info(`${TAG} clear cache`);
      this.servicesCache.clear();
      this.lastSystemLocale = currentSystemLocale;
    }
  }

  /**
   * 新建并缓存应用数据
   *
   * @param bundleName 应用包名
   */
  public async createAndCache(bundleName: string): Promise<ServiceEntry | null> {
    if (!bundleName) {
      LogUtil.error(`${TAG} createAndCache serviceName invalid`);
      return null;
    }
    let entry = await this.createServiceEntryByName(bundleName);
    if (entry) {
      this.servicesCache.set(entry.name, entry);
    }
    return entry;
  }

  private removeServiceEntry(bundleName: string): void {
    if (!bundleName) {
      LogUtil.error(`${TAG} removeServiceEntry bundleName invalid`);
      return;
    }
    LogUtil.info(`${TAG} removeServiceEntry enter`);
    let keys = Array.from(this.servicesCache.keys());
    for (let key of keys) {
      let nameArray: string[] = (key as string).split('/');
      if (nameArray.length > 0 && nameArray[0] === bundleName) {
        let entry = this.servicesCache.get(key);
        if (entry) {
          this.servicesCache.delete(key);
        }
        this.dispatchServiceRemove(key);
      }
    }
  }

  /**
   * 更新应用数据
   *
   * @param bundleName 应用包名
   */
  public async updateServiceEntry(bundleName: string): Promise<void> {
    if (!bundleName) {
      LogUtil.error(`${TAG} updateServiceEntry bundleName invalid`);
      return;
    }
    LogUtil.info(`${TAG} updateServiceEntry`);
    let keys = Array.from(this.servicesCache.keys());
    for (let key of keys) {
      let nameArray: string[] = (key as string).split('/');
      if (nameArray.length > 0 && nameArray[0] === bundleName) {
        await this.refreshServiceList();
        return;
      }
    }
    LogUtil.info(`${TAG} createAndCache`);
    let entry = await this.createAndCache(bundleName);
    if (entry) {
      await this.loadIcon(entry);
      await this.loadDescription(entry);
      await this.loadLabel(entry);
    }
    await this.refreshServiceList();
  }

  /**
   * 新建应用数据
   *
   * @param bundleName 应用包名
   */
  private async createServiceEntryByName(bundleName: string): Promise<ServiceEntry | null> {
    if (!bundleName) {
      LogUtil.error(`${TAG} createServiceEntryByName serviceName invalid`);
      return null;
    }
    let serviceList: bundle.ExtensionAbilityInfo[] = await ExtensionServiceInstallModel.getInstalledList();
    let enabledServiceList: accessibility.AccessibilityAbilityInfo[] =
      await accessibility.getAccessibilityExtensionList('all', 'enable');
    for (let serviceInfo of serviceList) {
      if (!serviceInfo.bundleName && serviceInfo.bundleName === bundleName) {
        let serviceState: boolean = false;
        for (let enabledService of enabledServiceList) {
          if (enabledService.name === serviceInfo.name) {
            serviceState = true;
            return null;
          }
        }
        let flags = bundle.BundleFlag.GET_BUNDLE_INFO_WITH_APPLICATION |
        bundle.BundleFlag.GET_BUNDLE_INFO_WITH_HAP_MODULE |
        bundle.BundleFlag.GET_BUNDLE_INFO_WITH_EXTENSION_ABILITY;
        let bundleInfo: bundle.BundleInfo = await bundle.getBundleInfo(serviceInfo.bundleName, flags);
        if (!bundleInfo || !bundleInfo.appInfo) {
          LogUtil.error(`${TAG} getAndUpdateAppInfo return`);
          return null;
        }
        let entry = await this.createServiceEntry(serviceInfo, serviceState, bundleInfo);
        return entry;
      }
      return null;
    }
    return null;
  }

  private async getAndUpdateServiceEntry(serviceInfo: bundle.ExtensionAbilityInfo |
  accessibility.AccessibilityAbilityInfo, state: boolean, bundleInfo: bundle.BundleInfo):
    Promise<ServiceEntry | null> {
    let extensionServiceId: string = serviceInfo.bundleName.concat('/').concat(serviceInfo.name);
    if (!serviceInfo.bundleName || !serviceInfo.name) {
      return null;
    }
    let entry = this.servicesCache.get(extensionServiceId);
    if (entry && entry.serviceState === state) {
      return entry;
    }
    entry = await this.createServiceEntry(serviceInfo, state, bundleInfo);
    if (entry.name) {
      this.servicesCache.set(entry.name, entry);
      return entry;
    }
    return null;
  }

  private async createServiceEntry(serviceInfo: bundle.ExtensionAbilityInfo |
  accessibility.AccessibilityAbilityInfo, state: boolean, bundleInfo: bundle.BundleInfo): Promise<ServiceEntry> {
    let entry = new ServiceEntry(serviceInfo, state, bundleInfo);
    if (entry) {
      await this.loadLabel(entry);
    }
    return entry;
  }

  /**
   * 刷新应用列表数据
   */
  public async refreshServiceList(isAccessibilityNotification: boolean = false): Promise<void> {
    LogUtil.info(`${TAG} refreshServiceList start`);
    this.updateSystemLocale();
    let extensionServiceList: (bundle.ExtensionAbilityInfo | accessibility.AccessibilityAbilityInfo)[] = [];
    if (isAccessibilityNotification) {
      extensionServiceList = await accessibility.getAccessibilityExtensionList('all', 'install');
    } else {
      extensionServiceList = await ExtensionServiceInstallModel.getInstalledList();
    }
    let enabledServiceList: accessibility.AccessibilityAbilityInfo[] =
      await accessibility.getAccessibilityExtensionList('all', 'enable');
    LogUtil.info(`${TAG} refreshServiceList serviceList size : ${extensionServiceList?.length}`);
    LogUtil.info(`${TAG} refreshServiceList enabledServiceList size : ${enabledServiceList?.length}`);
    let serviceList: ServiceEntry[] = [];
    for (let extensionService of extensionServiceList) {
      let extensionServiceId: string = extensionService.bundleName.concat('/').concat(extensionService.name);
      if (!extensionService || !extensionService.bundleName || !extensionService.name) {
        continue;
      }
      if (extensionService.bundleName === 'ohos.uitest' ||
        extensionService.bundleName === 'com.ohos.screenreader') {
        LogUtil.info(`${TAG} remove uitest/screenreader success`);
        continue;
      }
      let serviceState: boolean = false;
      for (let enabledService of enabledServiceList) {
        if (enabledService.id === extensionServiceId) {
          serviceState = true;
          break;
        }
      }
      LogUtil.info(`${TAG} serviceState: ${serviceState}`);
      let flags = bundle.BundleFlag.GET_BUNDLE_INFO_WITH_APPLICATION |
      bundle.BundleFlag.GET_BUNDLE_INFO_WITH_HAP_MODULE |
      bundle.BundleFlag.GET_BUNDLE_INFO_WITH_EXTENSION_ABILITY;
      let bundleInfo: bundle.BundleInfo = await bundle.getBundleInfo(extensionService.bundleName, flags);
      if (!bundleInfo || !bundleInfo.appInfo) {
        continue;
      }
      let entry = await this.getAndUpdateServiceEntry(extensionService, serviceState, bundleInfo);
      if (entry && entry.serviceName) {
        serviceList.push(entry);
      }
    }

    // 排序
    serviceList.sort(this.compare);

    // 先加载前15个扩展服务图标和说明
    let firstLoadServiceCount = 15;
    await this.loadServicesIconAndDescription(serviceList, firstLoadServiceCount);

    // 列表展示
    await Promise.resolve(this.dispatchServiceListChanged(serviceList));
    LogUtil.info(`${TAG} refreshServiceList dispatchServiceListChanged end`);

    await Promise.resolve(this.refreshCache(serviceList));

    // 加载剩余服务图标和说明
    await this.loadServicesIconAndDescription(serviceList);
  }

  private async loadServicesIconAndDescription(serviceList: Array<ServiceEntry>, size?: number): Promise<void> {
    for (let index = 0; index < serviceList.length; index++) {
      if (size && index > size) {
        return;
      }
      let entry = serviceList[index];
      if (entry) {
        await this.loadIcon(entry);
        await this.loadDescription(entry);
      }
    }
  }

  private async loadLabel(entry: ServiceEntry): Promise<void> {
    let isLabelChanged = await entry.loadLabel();
    if (isLabelChanged) {
      this.dispatchServiceUpdate(entry);
    }
  }

  private async loadDescription(entry: ServiceEntry): Promise<void> {
    let isDescriptionChanged = await entry.loadDescription();
    if (isDescriptionChanged) {
      this.dispatchServiceUpdate(entry);
    }
  }

  private async loadIcon(entry: ServiceEntry): Promise<void> {
    let isIconChanged = await entry.loadIcon();
    if (isIconChanged) {
      this.dispatchServiceUpdate(entry);
    }
  }

  public compare = (firstEntry: ServiceEntry, secondEntry: ServiceEntry): number => {
    let collator = new intl.Collator();
    return collator.compare(firstEntry.name.toString(), secondEntry.name.toString());
  }

  private refreshCache(appList: Array<ServiceEntry>): void {
    this.servicesCache = new Map<string, ServiceEntry>();
    for (let i = 0; i < appList.length; ++i) {
      this.servicesCache.set(appList[i].name, appList[i]);
    }
  }

  private dispatchServiceListChanged(appList: Array<ServiceEntry>): void {
    for (let listener of this.serviceListeners) {
      listener?.onServiceListChanged(appList);
    }
  }

  private dispatchServiceUpdate(appEntry: ServiceEntry): void {
    for (let listener of this.serviceListeners) {
      listener?.onServiceUpdate(appEntry);
    }
  }

  private dispatchServiceRemove(bundleName: string): void {
    for (let listener of this.serviceListeners) {
      listener?.onServiceRemove(bundleName);
    }
  }

  private constructor() {
    LogUtil.info(`${TAG} constructor`);
  }

  /**
   * 获取应用列表加载类单例
   */
  public static getInstance(): ExtensionServiceListLoader {
    if (!ExtensionServiceListLoader.instance) {
      ExtensionServiceListLoader.instance = new ExtensionServiceListLoader();
    }
    return ExtensionServiceListLoader.instance;
  }
}
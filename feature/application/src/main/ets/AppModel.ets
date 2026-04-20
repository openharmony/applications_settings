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

import util from '@ohos.util';
// import hdsDrawable from '@hms.hds.hdsDrawable';
import { image } from '@kit.ImageKit';
import bundle from '@ohos.bundle.bundleManager';
import bundleResourceManager from '@ohos.bundle.bundleResourceManager';
import { DeviceUtil } from '@ohos/settings.common/src/main/ets/utils/BaseUtils';
import { LogUtil } from '@ohos/settings.common/src/main/ets/utils/LogUtil';
import { BaseEntryMenu } from '@ohos/settings.common/src/main/ets/core/model/menu/BaseMenu';
import { AppUtils } from './AppUtils';

const TAG: string = 'AppModel : ';
const UID_MARK: number = 200000;
const DEFAULT_ACTIVATED_ID: number = 100;
const ICON_DEFAULT_SIZE: number = 48;
const APP_ICON_STANDARD_WIDTH: number = vp2px(ICON_DEFAULT_SIZE);
const APP_ICON_STANDARD_HEIGHT: number = vp2px(ICON_DEFAULT_SIZE);
const DEFAULT_LENGTH: number = 64;

export const enum AppType {
  SYSTEM_APP = 'systemApp',
  UN_SYSTEM_APP = 'unSystemApp',
  SERVICE_APP = 'meetaApp',
  CONTAINER_APP = 'containerApp',
  UNKNOWN_TYPE = 'unknownApp'
}

/**
 * @name Indicates the custom metadata
 * @since 7
 * @syscap SystemCapability.BundleManager.BundleFramework
 * @permission NA
 *
 */
export interface CustomizeData {
  /**
   * @default Indicates the custom metadata name
   * @since 7
   * @syscap SystemCapability.BundleManager.BundleFramework
   */
  name: string;

  /**
   * @default Indicates the custom metadata value
   * @since 7
   * @syscap SystemCapability.BundleManager.BundleFramework
   */
  value: string;

  /**
   * @default Indicates the custom metadata resource
   * @since 8
   * @syscap SystemCapability.BundleManager.BundleFramework
   */
  extra: string;
}

/**
 * @name Indicates the Metadata
 * @since 9
 * @syscap SystemCapability.BundleManager.BundleFramework
 * @permission NA
 *
 */
export interface Metadata {
  /**
   * @default Indicates the metadata name
   * @since 9
   * @syscap SystemCapability.BundleManager.BundleFramework
   */
  name: string;

  /**
   * @default Indicates the metadata value
   * @since 9
   * @syscap SystemCapability.BundleManager.BundleFramework
   */
  value: string;

  /**
   * @default Indicates the metadata resource
   * @since 9
   * @syscap SystemCapability.BundleManager.BundleFramework
   */
  resource: string;
}

/**
 * @name Stores module information about an application.
 * @since 7
 * @syscap SystemCapability.BundleManager.BundleFramework
 * @permission NA
 *
 */
export interface ModuleInfo {
  /**
   * The module name.
   *
   * @default Indicates the name of the .hap package to which the capability belongs
   *
   * @since 7
   * @syscap SystemCapability.BundleManager.BundleFramework
   */
  readonly moduleName: string;

  /**
   * The module source path.
   *
   * @default Indicates the module source dir of this module
   *
   * @since 7
   * @syscap SystemCapability.BundleManager.BundleFramework
   */
  readonly moduleSourceDir: string;
}

// /**
//  * HDS处理的数据集合
//  *
//  * @since 2024-12-24
//  */
// export interface HdsHandleIcons {
//   /**
//    * bundle name and pixelMap array
//    *
//    * @description drawableDescriptor icon
//    */
//   pixelMapIcons: hdsDrawable.Icon[];
//
//   /**
//    * bundle name and LayeredDrawableDescriptor array
//    *
//    * @description LayeredDrawableDescriptor icon
//    */
//   layeredIcons: hdsDrawable.LayeredIcon[];
// }

export class BasicAppEntry {
  public name: string = '';
  public codePath: string = '';
  public uid: number = 0;
  public bundleType: number = 0;
  public systemApp: boolean = false;
  public enabled: boolean = true;
  public dataUnclearable: boolean = false;
  public multiAppModeMaxCount?: number;
}

/**
 * 应用数据类
 *
 * @since 2022-05-26
 */
export class AppEntry {
  public appInfo?: BasicAppEntry;
  public name: string;
  public removable: boolean = false;
  public userDataClearable: boolean = true;
  public label?: string;
  public labelId: number = 0;
  public icon?: ResourceStr | PixelMap;
  public iconId = 0;
  public appSize: string = '';
  public cacheSize: string = '';
  public dataSize: string = '';
  public totalSize: string = '';
  public versionName: string;
  public updateTime: number;
  public locale: string = '';
  public currentActivatedId: number = DEFAULT_ACTIVATED_ID;
  public moduleName?: string = '';
  public appIndex: number = 0;
  public installSource: string = '';

  constructor(bundleInfo?: bundle.BundleInfo) {
    if (bundleInfo) {
      this.name = bundleInfo.name;
      this.versionName = bundleInfo.versionName;
      this.updateTime = bundleInfo.updateTime;
      this.updateAppInfo(bundleInfo.appInfo);
    } else {
      this.name = '';
      this.versionName = '';
      this.updateTime = 0;
    }
  }

  /**
   * 深拷贝应用数据对象
   *
   * @param entry 原应用数据对象
   * @returns 返回深拷贝后的新应用数据对象
   */
  public static copy(entry: AppEntry): AppEntry {
    let result: AppEntry = new AppEntry();
    if (!entry) {
      return result;
    }
    if (entry.appInfo) {
      let appInfo: BasicAppEntry = new BasicAppEntry();
      appInfo.name = entry.appInfo.name;
      appInfo.codePath = entry.appInfo.codePath;
      appInfo.uid = entry.appInfo.uid;
      appInfo.systemApp = entry.appInfo.systemApp;
      appInfo.bundleType = entry.appInfo.bundleType;
      appInfo.multiAppModeMaxCount = entry.appInfo.multiAppModeMaxCount;
      appInfo.enabled = entry.appInfo.enabled;
      appInfo.dataUnclearable = entry.appInfo.dataUnclearable;
      result.appInfo = appInfo;
    }
    result.name = entry.name;
    result.removable = entry.removable;
    result.userDataClearable = entry.userDataClearable;
    result.label = entry.label;
    result.labelId = entry.labelId;
    result.icon = entry.icon;
    result.iconId = entry.iconId;
    result.appSize = entry.appSize;
    result.cacheSize = entry.cacheSize;
    result.dataSize = entry.dataSize;
    result.totalSize = entry.totalSize;
    result.versionName = entry.versionName;
    result.updateTime = entry.updateTime;
    result.locale = entry.locale;
    result.currentActivatedId = entry.currentActivatedId;
    result.moduleName = entry.moduleName;
    result.appIndex = entry.appIndex;
    result.installSource = entry.installSource;
    return result;
  }

  /**
   * updateAppInfo 更新应用信息数据
   *
   * @param appInfo 应用信息数据
   */
  public updateAppInfo(appInfo: bundle.ApplicationInfo): void {
    if (!appInfo) {
      LogUtil.info(`${TAG} updateAppInfo return`);
      return;
    }

    this.appInfo = new BasicAppEntry();
    this.appInfo.name = appInfo.name;
    this.appInfo.codePath = appInfo.codePath;
    this.appInfo.uid = appInfo.uid;
    this.appInfo.systemApp = appInfo.systemApp;
    this.appInfo.bundleType = appInfo.bundleType;
    this.appInfo.multiAppModeMaxCount = appInfo.multiAppMode?.maxCount;
    this.appInfo.enabled = appInfo.enabled;
    this.appInfo.dataUnclearable = appInfo.dataUnclearable;

    this.removable = appInfo.removable;
    this.labelId = appInfo.labelId;
    this.label = appInfo.label;
    this.iconId = appInfo.iconId;
    this.icon = appInfo.icon;
    this.moduleName = appInfo?.labelResource?.moduleName ?? '';
    this.appIndex = appInfo.appIndex;
    this.installSource = appInfo.installSource;
  }

  /**
   * 获取激活状态的系统帐号的ID列表
   */
  public getCurrentActivatedId(): number {
    LogUtil.info(`${TAG} currentActivatedId is ${this.currentActivatedId}`);
    return this.currentActivatedId;
  }

  /**
   * 设置激活状态的系统帐号的ID列表
   *
   * @param currentActivatedId 激活状态的系统帐号的ID列表
   */
  public setCurrentActivatedId(currentActivatedId: number): void {
    if (!currentActivatedId || this.currentActivatedId === currentActivatedId) {
      LogUtil.info(`${TAG} setCurrentActivatedId return`);
      return;
    }
    this.currentActivatedId = currentActivatedId;
  }

  public isLocaleMatch(locale: string): boolean {
    return this.locale === locale;
  }

  public isBundleMatch(bundleInfo: bundle.BundleInfo): boolean {
    if (!bundleInfo) {
      return false;
    }
    if (!this.isVersionMatch(bundleInfo.versionName)) {
      LogUtil.info(`${TAG} version change`);
      return false;
    }
    if (this.updateTime !== bundleInfo.updateTime) {
      LogUtil.info(`${TAG} updateTime change`);
      return false;
    }
    return true;
  }

  private isVersionMatch(versionName: string): boolean {
    if (!this.versionName || !versionName) {
      return false;
    }
    return this.versionName.localeCompare(versionName) === 0;
  }

  private isResourceIdValid(id: number): boolean {
    return !Number.isNaN(id) && id > 0;
  }

  public getBundleResourceInfo(bundleName: string, bundleFlags: number, appIndex: number):
    bundleResourceManager.BundleResourceInfo | undefined {
    if (bundleName.length == 0) {
      return undefined;
    }
    let bundleResourceLabelList: bundleResourceManager.BundleResourceInfo | undefined = undefined;
    try {
      bundleResourceLabelList = bundleResourceManager.getBundleResourceInfo(bundleName, bundleFlags, appIndex);
    } catch (error) {
      LogUtil.error(`${TAG} getBundleResourceInfo error, errmsg: ${error?.message}, bundleName: ${bundleName}, appIndex: ${appIndex}`);
    }
    LogUtil.info(`${TAG} getBundleResourceInfo label: ${bundleResourceLabelList?.label},bundleName: ${bundleName}, appIndex: ${appIndex}`);
    return bundleResourceLabelList;
  }

  public async base64ToPixelMap(base64Helper: util.Base64Helper,
    bundleInfo: bundleResourceManager.BundleResourceInfo | undefined): Promise<ResourceStr | PixelMap | undefined> {
    if (!bundleInfo || !bundleInfo.icon) {
      return undefined;
    }
    LogUtil.info(`${TAG} ${bundleInfo.bundleName} pixelMap create`);
    return AppEntry.createPixelMap(base64Helper, bundleInfo.icon, bundleInfo.bundleName);
  }

  public static async createPixelMap(base64Helper: util.Base64Helper,
    icon: string, bundleName: string): Promise<ResourceStr | PixelMap | undefined> {
    if (!icon) {
      return undefined;
    }
    // 解码前先去掉前缀
    const pngPrefix: string = 'data:image/png;base64,';
    const jpegPrefix: string = 'data:image/jpeg;base64,';
    let newStr: string = icon;
    if (newStr.startsWith(pngPrefix)) {
      newStr = newStr.substring(pngPrefix.length);
    } else if (newStr.startsWith(jpegPrefix)) {
      newStr = newStr.substring(jpegPrefix.length);
    }
    let length: number = (newStr.length - (newStr.length / 8) * 2) / 1024;
    LogUtil.info(`${TAG} pixelMap create ${length}`);
    let imageSource: image.ImageSource | undefined = undefined;
    try {
      const data = base64Helper.decodeSync(newStr, util.Type.BASIC);
      let sourceOptions: image.SourceOptions = {
        sourceDensity: 120,
        sourceSize: { width: APP_ICON_STANDARD_WIDTH, height: APP_ICON_STANDARD_HEIGHT }
      };
      imageSource = image.createImageSource(data.buffer, sourceOptions);
      let pixelMap: PixelMap = await imageSource.createPixelMap({
        desiredSize: { width: APP_ICON_STANDARD_WIDTH, height: APP_ICON_STANDARD_HEIGHT }
      });
      const size: Size = pixelMap.getImageInfoSync().size;
      LogUtil.info(`${TAG} pixelMap size is ${size.width} x ${size.height}, bundle is ${bundleName}`);
      return pixelMap;
    } catch (err) {
      LogUtil.error(`${TAG} decode base64 failed message is ${err?.message}`);
    } finally {
      if (imageSource) {
        imageSource.release();
      }
    }
    return icon;
  }

  /**
   * 异步加载应用名
   */
  public async loadLabel(): Promise<boolean | undefined> {
    if (this.label) {
      LogUtil.info(`${TAG} loadLabel return`);
      return;
    }

    if (!this.isResourceIdValid(this.labelId)) {
      LogUtil.info(`${TAG} labelId invalid: ${this.labelId}`);
      this.label = this.name;
      return false;
    }

    let bundleFlags = bundleResourceManager.ResourceFlag.GET_RESOURCE_INFO_WITH_LABEL;
    let bundleResourceInfo: bundleResourceManager.BundleResourceInfo | undefined =
      this.getBundleResourceInfo(this.name, bundleFlags, this.appIndex);

    this.label = bundleResourceInfo?.label;
    if (!this.label) {
      LogUtil.error(`${TAG} get label invalid`);
      this.icon = AppEntry.getDefaultIcon();
    }

    return true;
  }

  /**
   * 异步加载图标
   */
  public async loadIcon(): Promise<boolean> {
    if (this.icon) {
      LogUtil.info(`${TAG} loadIcon return`);
      return false;
    }
    if (!this.isResourceIdValid(this.iconId)) {
      LogUtil.info(`${TAG} iconId invalid: ${this.iconId}`);
      this.icon = AppEntry.getDefaultIcon();
      return true;
    }

    let bundleFlags = bundleResourceManager.ResourceFlag.GET_RESOURCE_INFO_WITH_ICON;
    let bundleResourceInfo: bundleResourceManager.BundleResourceInfo | undefined =
      this.getBundleResourceInfo(this.name, bundleFlags, this.appIndex);

    this.icon = bundleResourceInfo?.icon;
    if (!this.icon) {
      LogUtil.error(`${TAG} get icon invalid`);
      this.icon = AppEntry.getDefaultIcon();
    }

    return true;
  }

  public static getDefaultIcon(): Resource {
    return $r('sys.media.ohos_app_icon');
  }

  /**
   * 异步加载存储大小
   */
  public async loadSize(): Promise<boolean> {
    if (this.appInfo?.codePath === '2') {
      return false;
    }
    let storage = await import('@ohos.file.storageStatistics');
    let bundleStats = await (DeviceUtil.isWearable() ? storage.default.getBundleStats(this.name) :
      storage.default.getBundleStats(this.name, this.appIndex));
    if (!bundleStats) {
      LogUtil.warn(`${TAG} get bundleStats invalid`);
      return false;
    }

    let isUpdate: boolean = false;
    let appSize = AppUtils.formatSize(bundleStats.appSize);
    if (appSize !== this.appSize) {
      this.appSize = appSize;
      isUpdate = true;
    }
    let cacheSize = AppUtils.formatSize(bundleStats.cacheSize);
    if (cacheSize !== this.cacheSize) {
      this.cacheSize = cacheSize;
      isUpdate = true;
    }
    let dataSize = AppUtils.formatSize(bundleStats.dataSize);
    if (dataSize !== this.dataSize) {
      this.dataSize = dataSize;
      isUpdate = true;
    }
    let totalSize = AppUtils.formatSize(bundleStats.appSize + bundleStats.cacheSize + bundleStats.dataSize);
    if (totalSize !== this.totalSize) {
      this.totalSize = totalSize;
      isUpdate = true;
    }
    return isUpdate;
  }

  public isRemovable(): boolean {
    return this.removable !== false;
  }

  public isUserDataClearable(): boolean {
    LogUtil.info(`${TAG} ${this.name}`);
    LogUtil.info(`${TAG} isUserDataClearable uid: ${(this.appInfo as BasicAppEntry).uid}`);
    LogUtil.info(`${TAG} isUserDataClearable this.currentActivatedId: ${this.currentActivatedId}`);
    return Math.floor((this.appInfo as BasicAppEntry).uid / UID_MARK) === this.currentActivatedId &&
      this.dataSize !== '0B' && this.userDataClearable !== false;
  }

  public hasCache(): boolean {
    LogUtil.info(`${TAG} ${this.appInfo?.name}`);
    LogUtil.info(`${TAG} hasCache uid: ${this.appInfo?.uid}`);
    LogUtil.info(`${TAG} hasCache this.currentActivatedId: ${this.currentActivatedId}`);
    return Math.floor((this.appInfo as BasicAppEntry).uid / UID_MARK) === this.currentActivatedId && this.cacheSize !== '0B';
  }
}

/**
 * 应用菜单数据类
 *
 * @since 2022-05-26
 */
export class AppMenu extends BaseEntryMenu {
  public appEntry: AppEntry | undefined = undefined;

  /**
   * 应用分身索引
   */
  public appIndex: number = 0;

  constructor(appEntry: AppEntry) {
    super({
      key: appEntry.name,
    });
    this.updateEntry(appEntry);
  }

  public updateEntry(appEntry: AppEntry): void {
    this.appEntry = appEntry;
    this.appType = this.getAppType(appEntry);
    this.appIndex = appEntry.appIndex;
    this.title = appEntry.label as string;
    this.icon = appEntry.icon as ResourceStr | PixelMap;
    this.timestamp = new Date().getTime();
    this.summary = appEntry.totalSize || ' ';
  }

  public getAppType(appEntry: AppEntry): string {
    if (appEntry!.appInfo!.bundleType === 0) {
      return appEntry!.appInfo!.codePath!.includes('/') ?
        (appEntry!.appInfo!.systemApp ? 'systemApp' : 'unSystemApp') : 'containerApp';
    }
    if (appEntry!.appInfo!.bundleType === 1) {
      return 'metaApp';
    }
    return '';
  }
}

/**
 * 应用菜单数据类
 *
 * @since 2022-05-26
 */
export class InputMenu extends BaseEntryMenu {
  public appEntry: AppEntry | undefined = undefined;
  /**
   * 应用分身索引
   */
  public appIndex: number = 0;

  constructor(appEntry: AppEntry) {
    super({
      key: appEntry.name,
    });
    this.updateEntry(appEntry);
  }

  public updateEntry(appEntry: AppEntry): void {
    this.appEntry = appEntry;
    this.appIndex = appEntry.appIndex;
    this.title = appEntry.label as string;
    this.icon = appEntry.icon as ResourceStr | PixelMap;
    this.timestamp = new Date().getTime();
  }
}

export class RecentAppMenu extends AppMenu {
  public updateEntry(appEntry: AppEntry): void {
    this.appEntry = appEntry;
    this.appIndex = appEntry.appIndex;
    this.title = appEntry.label as string;
    this.icon = appEntry.icon as ResourceStr | PixelMap;
    this.timestamp = new Date().getTime();
  }
}

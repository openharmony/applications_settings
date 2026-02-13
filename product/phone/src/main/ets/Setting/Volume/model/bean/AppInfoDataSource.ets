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
import bundleResourceManager from '@ohos.bundle.bundleResourceManager';
import util from '@ohos.util';
import i18n from '@ohos.i18n';
import image from '@ohos.multimedia.image';
import { BusinessError } from '@ohos.base';
import { LogUtil } from '@ohos/settings.common/src/main/ets/utils/LogUtil';
import { ResourceManagerUtil } from '@ohos/settings.common/src/main/ets/utils/ResourceManagerUtil';
import { AppEntry } from '@ohos/settings.application/src/main/ets/AppModel';
import { BasicDataSource } from './BasicDataSource';
import { alphabets } from '../../view/NotDisturbTrustAppItemComponent';
/* instrument ignore file */
const TAG: string = 'AppInfoData : ';
const APP_ICON_STANDARD_WIDTH: number = 192;
const APP_ICON_STANDARD_HEIGHT: number = 192;
const DEFAULT_LENGTH: number = 64;

@Observed
export class AppInfoData {
  private tag: string = 'NotDisturbAppInfoData: ';
  public appName: string = '';
  public bundleName: string = '';
  public appIconBase64?: ResourceStr | PixelMap;
  public isSelected: boolean = false;
  public uid: number = 0;
  public prefix: string = '';
  public index: number = -1;
  public pinyin: string = '';
  public isLastItem: boolean = false;
  private pixelMapIcon?: PixelMap;

  constructor(bundleName: string, uid: number) {
    this.bundleName = bundleName;
    this.uid = uid;
  }

  private getDefaultIcon(): ResourceStr {
    return $r('sys.media.ohos_app_icon');
  }

  public async base64ToPixelMap(base64Helper: util.Base64Helper,
    bundleInfo: bundleResourceManager.BundleResourceInfo
      | undefined): Promise<ResourceStr | PixelMap | undefined> {
    if (!bundleInfo || !bundleInfo.icon) {
      return undefined;
    }
    LogUtil.info(`${TAG} ${bundleInfo.bundleName} pixelMap create`);
    return this.createPixelMap(base64Helper, bundleInfo.icon);
  }

  public releaseResources(): void {
    if (this.pixelMapIcon) {
      this.pixelMapIcon.release().then(() => {
        LogUtil.info(`${TAG} release success`);
      }).catch((err: BusinessError) => {
        LogUtil.error(`${TAG} faild to release pixelMap code: ${err.code} message: ${err.message}`);
      });
    }
  }

  private async createPixelMap(base64Helper: util.Base64Helper,
    icon: string): Promise<ResourceStr | PixelMap | undefined> {
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
    if (length <= DEFAULT_LENGTH) {
      return icon;
    }
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
      LogUtil.info(`${TAG} pixelMap size is ${size.width} x ${size.height}`);
      this.pixelMapIcon = pixelMap;
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

  public async init(): Promise<boolean> {
    try {
      let bundleFlags = bundleResourceManager.ResourceFlag.GET_RESOURCE_INFO_WITH_LABEL |
      bundleResourceManager.ResourceFlag.GET_RESOURCE_INFO_WITH_ICON;
      let bundleResourceInfo: bundleResourceManager.BundleResourceInfo | undefined =
        ResourceManagerUtil.getBundleResourceInfo(this.bundleName, bundleFlags);
      this.appName = bundleResourceInfo?.label as string;
      this.prefix = this.getFirstLetter(this.appName);
      const base64Helper: util.Base64Helper = new util.Base64Helper();
      this.appIconBase64 = await this.base64ToPixelMap(base64Helper, bundleResourceInfo);

      if (!this.appIconBase64) {
        LogUtil.warn(`${this.tag}  get icon invalid`);
        this.appIconBase64 = this.getDefaultIcon();
      }
      this.updateCloneAppIconAndName(); // 更新克隆app的图标和名称
      return true;
    } catch (err) {
      LogUtil.info(`${this.tag} getBundleInfo fail exception ${err.massage}}`);
      return false;
    }
  }

  private async updateCloneAppIconAndName(): Promise<void> {
    let allCloneApps = await this.getCloneAppDetail(this.bundleName);
    if (allCloneApps.length == 0) {
      return;
    }
    for (let bundleInfo of allCloneApps) {
      if (bundleInfo.appInfo.uid != this.uid) {
        continue;
      }
      let index = bundleInfo?.appIndex;
      let bundleResInfo = bundleResourceManager.getBundleResourceInfo(bundleInfo.appInfo.name,
        bundleResourceManager.ResourceFlag.GET_RESOURCE_INFO_WITH_ICON, index);
      this.appIconBase64 = bundleResInfo.icon;
      this.appName += index;
    }
  }

  private async getCloneAppDetail(bundleName: string): Promise<Array<bundle.BundleInfo>> {
    let allCloneApps: bundle.BundleInfo[] = [];
    try {
      allCloneApps = await bundle.getAllBundleInfo(bundle.BundleFlag.GET_BUNDLE_INFO_WITH_APPLICATION);
      allCloneApps = allCloneApps.filter((bundleInfo) => {
        return bundleInfo.appIndex != 0 && bundleInfo.name === bundleName;
      });
    } catch (err) {
      LogUtil.error(`${TAG} getCloneAppDetail failed code:${err?.code}, message: ${err?.message}`);
    }
    return allCloneApps;
  }

  private getFirstLetter(str: string): string {
    let prefix = '';
    this.pinyin = i18n.Transliterator.getInstance('Any-Latn; Latin-ASCII').transform(str);
    prefix = this.pinyin[0].toUpperCase();
    if (!isNaN(Number(prefix))) {
      prefix = '#';
    }
    return prefix;
  }
}

@Observed
export class AppInfoDataGroups extends BasicDataSource {
  public appInfoDataGroups: AppInfoData[] = [];
  public prefix: string = '';
  public index: number = -1;

  constructor(prefix: string) {
    super();
    this.prefix = prefix;
  }

  public setData(appInfoData: AppInfoData): void {
    this.appInfoDataGroups.push(appInfoData)
  }

  public totalCount(): number {
    return this.appInfoDataGroups.length;
  }

  public getData(index: number): AppInfoDataGroups | AppInfoData | null {
    return this.appInfoDataGroups[index];
  }

  public deleteData(index: number): void {
    this.appInfoDataGroups.splice(index, 1);
    this.notifyDataDelete(index);
  }
}

export class AppInfoDataSource extends BasicDataSource {
  public appInfoDataGroupsArr: AppInfoDataGroups[] = [];

  public sort(): void {
    this.appInfoDataGroupsArr.forEach(group => {
      group.appInfoDataGroups.sort((a, b) => a.pinyin.localeCompare(b.pinyin));
    })
    this.appInfoDataGroupsArr.sort((a, b) => a.prefix.localeCompare(b.prefix));
    let len = this.appInfoDataGroupsArr[this.appInfoDataGroupsArr.length - 1];
    let lastItem = len.appInfoDataGroups[len.appInfoDataGroups.length - 1];
    for (let i = 0; i < this.appInfoDataGroupsArr.length; i++) {
      this.appInfoDataGroupsArr[i].index = i;
      this.appInfoDataGroupsArr[i].appInfoDataGroups.forEach(item => {
        item.index = i;
        item.isLastItem = lastItem === item;
      })
    }
  }

  public releaseResource(): void {
    this.appInfoDataGroupsArr.forEach(group => {
      group.appInfoDataGroups.forEach(appData => {
        appData.releaseResources();
      });
    });
  }

  public totalCount(): number {
    return this.appInfoDataGroupsArr.length;
  }

  public setData(appInfoGroups: AppInfoDataGroups): void {
    this.appInfoDataGroupsArr.push(appInfoGroups)
  }

  public getPrefixList(index: number): string[] {
    let result: string[] = [];
    let prefixSet: Set<string> = new Set();
    for (let item of this.appInfoDataGroupsArr) {
      let str = alphabets[index];
      if (str == item.prefix) {
        item.appInfoDataGroups.forEach(element => {
          prefixSet.add(element.appName[0]);
        })
        break;
      }
    }
    result = Array.from(prefixSet);
    return result;
  }

  public getPrefixIndex(index: number): number {
    let str = this.appInfoDataGroupsArr[index].prefix;
    return alphabets.indexOf(str);
  }

  public getListScrollIndex(index: number): number {
    let str = alphabets[index];
    let i = 0;
    for (const item of this.appInfoDataGroupsArr) {
      if (str === item.prefix) {
        return i;
      }
      i++;
    }
    return -1;
  }

  public searchItemByKeyWord(word: string): AppInfoDataGroups {
    let searchAppGroup: AppInfoDataGroups = new AppInfoDataGroups('');
    this.appInfoDataGroupsArr.forEach(item => {
      item.appInfoDataGroups.forEach(element => {
        if (element.appName.includes(word)) {
          searchAppGroup.appInfoDataGroups.push(element);
        }
      })
    })
    return searchAppGroup;
  }

  public getData(index: number): AppInfoDataGroups | null {
    return this.appInfoDataGroupsArr[index];
  }

  public addData(index: number, data: AppInfoDataGroups): void {
    this.appInfoDataGroupsArr.splice(index, 0, data);
    this.notifyDataAdd(index);
  }

  public pushData(data: AppInfoDataGroups): void {
    this.appInfoDataGroupsArr.push(data);
    this.notifyDataAdd(this.appInfoDataGroupsArr.length - 1);
  }
}
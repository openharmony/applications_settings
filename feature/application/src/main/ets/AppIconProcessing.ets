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

import bundleResourceManager from '@ohos.bundle.bundleResourceManager';
import ArkTSUtils from '@arkts.utils';
// import hdsDrawable from '@hms.hds.hdsDrawable';
import image from '@ohos.multimedia.image';
import { BusinessError } from '@ohos.base';
import { LayeredDrawableDescriptor } from '@ohos.arkui.drawableDescriptor';
import { LogUtil } from '@ohos/settings.common/src/main/ets/utils/LogUtil';
import { ResourceUtil } from '@ohos/settings.common/src/main/ets/utils/ResourceUtil';
import { ThemeManager } from './util/ThemeManager';
import { AppEntry, AppType } from './AppModel';
/* instrument ignore file */
import { AppListLoader } from './AppListLoader';

'use shared'

@Sendable
export class HdsDrawableTools {
  public static readonly defaultSize: number = 48;
  // getHdsIcons,getHdsLayeredIcons最大处理数量为500个
  private static readonly HDS_MAX_PROC_COUNT: number = 500;
  private static instance: HdsDrawableTools = new HdsDrawableTools();
  private readonly TAG: string = 'HdsDrawableTools :';
  private lock_: ArkTSUtils.locks.AsyncLock = new ArkTSUtils.locks.AsyncLock();

  public static getInstance(): HdsDrawableTools {
    return HdsDrawableTools.instance;
  }

  /**
   * 获取Hds裁剪所需的蒙层
   */
  public getMask(): PixelMap {
    let settingsDrawableDescriptor: LayeredDrawableDescriptor =
      bundleResourceManager.getBundleResourceInfo('com.ohos.settings',
        bundleResourceManager.ResourceFlag.GET_RESOURCE_INFO_WITH_DRAWABLE_DESCRIPTOR)
        .drawableDescriptor as LayeredDrawableDescriptor;
    return settingsDrawableDescriptor.getMask().getPixelMap();
  }

  /**
   * 判断并释放PixelMap
   *
   * @param icon 任意icon对象
   */
  public static releaseIcon(icon: ResourceStr | PixelMap | undefined) {
    if (icon) {
      let procIcon = icon as PixelMap;
      if (procIcon.isEditable !== undefined && procIcon.release !== undefined) {
        procIcon.release();
      }
    }
  }

  /**
   * 获取hds处理的icon
   *
   * @param appEntry 应用信息实例
   * @param drawDesc 要处理的图标描述符
   * @param size 处理后图标输出大小
   * @param mask hds根据该mask进行图标裁剪
   * @param hasBorder 处理图标是否带描边
   * @return 裁剪处理后的图标
   */
  public getCustomHdsIcon(appEntry: AppEntry, drawDesc: DrawableDescriptor, size: number, mask: PixelMap,
    hasBorder: boolean): PixelMap | undefined {
    let result: PixelMap | undefined;
    let fixBundleName = appEntry.name;
    if (appEntry) {
      fixBundleName = this.getFixAppBundleName(appEntry);
    }
    if (drawDesc instanceof LayeredDrawableDescriptor) {
      try {
        // result = hdsDrawable.getHdsLayeredIcon(fixBundleName, drawDesc, size, hasBorder);
      } catch (error) {
        LogUtil.error(`${this.TAG} getHdsLayeredIcon code is ${error?.code}, message is ${error?.message}`);
      }
    } else {
      let pixelMap: PixelMap = drawDesc.getPixelMap();
      try {
        // result = hdsDrawable.getHdsIcon(fixBundleName, pixelMap, size, mask, hasBorder);
      } catch (error) {
        LogUtil.error(`${this.TAG} getHdsIcon code is ${error?.code}, message is ${error?.message}`);
      }
      pixelMap.release();
    }
    if (result) {
      try {
        let imageInfo: image.ImageInfo = result.getImageInfoSync();
        LogUtil.info(`${this.TAG} getCustomHdsIcon name: ${appEntry.name}, pixelMap size {${imageInfo.size.width}, ${imageInfo.size.height}}`);
      } catch {
        LogUtil.error(`${this.TAG} getCustomHdsIcon name: ${appEntry.name}, get imageInfo failed`);
      }
    } else {
      LogUtil.error(`${this.TAG} getCustomHdsIcon name: ${appEntry.name}, get pixelMap failed, it's empty.`);
    }
    return result;
  }

  /**
   * 获取HDS图标接口对应的修正应用包名
   *
   * @param appEntry 应用数据
   */
  public getFixAppBundleName(appEntry: AppEntry): string {
    let fixBundleName = appEntry.name;
    return fixBundleName;
  }

  /**
   * 获取hds批量处理的icons
   *
   * @param bundleName 应用包名
   * @param drawDesc 要处理的图标描述符
   * @param size 处理后图标输出大小
   * @param mask hds根据该mask进行图标裁剪
   * @param hasBorder 处理图标是否带描边
   * @return 裁剪处理后的图标
   */
  public async getCustomHdsIcons(appList: AppEntry[], handleIcons: ESObject, options: ESObject) {
    // 注意：该接口一定要加锁，同一时刻主子线程不能同时执行，否则会报1012600001
    return this.lock_.lockAsync(async () => {
      LogUtil.info(`${this.TAG} getCustomHdsIcons appList len: ${appList.length}, LayeredIcons len: ${handleIcons.layeredIcons.length}, pixelMapIcons len: ${handleIcons.pixelMapIcons.length}`);
      await this.getHdsLayeredIcons(handleIcons.layeredIcons, appList, options);
      await this.getHdsIcons(handleIcons.pixelMapIcons, appList, options);
    }, ArkTSUtils.locks.AsyncLockMode.EXCLUSIVE).catch((error: BusinessError) => {
      LogUtil.error(`${this.TAG} getHdsIcons errcode: ${error?.code}, errMes: ${error?.message}`);
    });
  }

  /**
   * 获取hds批量处理的单层图标
   *
   * @param pixelMapIcons 需要处理的单层图标
   * @param appList 需要更新的应用列表
   * @param options 输出的图标样式
   */
  private async getHdsIcons(pixelMapIcons: ESObject[], appList: AppEntry[], options: ESObject) {
    if (pixelMapIcons.length == 0 || appList.length == 0) {
      LogUtil.error(`${this.TAG} getHdsIcons failed appList: ${appList.length}, pixelMapIcons: ${pixelMapIcons.length}`);
      return;
    }
    LogUtil.info(`${this.TAG} getHdsIcons start appList: ${appList.length}, pixelMapIcons: ${pixelMapIcons.length}`);
    try {
      let remainCount: number = pixelMapIcons.length;
      let handledCount: number = 0;
      let startIndex: number = 0;
      let mask :PixelMap = this.getMask();
      let localMask :PixelMap = this.clonePixelMap(mask);
      mask.release();
      do {
        handledCount = remainCount >= HdsDrawableTools.HDS_MAX_PROC_COUNT ?
          HdsDrawableTools.HDS_MAX_PROC_COUNT : remainCount;
        let handlerIcons: ESObject[] = pixelMapIcons.slice(startIndex, startIndex + handledCount);
        let processedIcons: ESObject[] = []
          // await hdsDrawable?.getHdsIcons(handlerIcons, localMask, options);
        appList.forEach((entryObj: AppEntry) => {
          let icon: ESObject | undefined =
            processedIcons.find((element: ESObject) => {
              return entryObj.name === element.bundleName ||
                entryObj.name === element.bundleName.replace(AppType.CONTAINER_APP, '');
            })
          if (icon) {
            entryObj.icon = icon.pixelMap;
            // try {
            //   let imageInfo: image.ImageInfo = entryObj.icon?.getImageInfoSync()
            //   LogUtil.info(`${this.TAG} getHdsIcons ${entryObj.name} get icon {${imageInfo?.size?.width}, ${imageInfo?.size?.height}} success`);
            // } catch {
            //   LogUtil.error(`${this.TAG} getHdsIcons name: ${entryObj.name}, get imageInfo failed`);
            // }
          }
        })
        startIndex += handledCount;
        handlerIcons.forEach((entryObj:ESObject) => {
          entryObj.pixelMap?.release();
        })
        remainCount -= handledCount;
      } while (remainCount > 0)
      localMask.release();
    } catch (error) {
      LogUtil.error(`${this.TAG} getHdsIcons errcode: ${error?.code}, errMes: ${error?.message}`);
    }
    LogUtil.info(`${this.TAG} getHdsIcons finish appList: ${appList.length}, pixelMapIcons: ${pixelMapIcons.length}`);
  }

  /**
   * 获取hds批量处理的双层图标
   *
   * @param LayeredIcons 需要处理的双层图标
   * @param appList 需要更新的应用列表
   * @param options 输出的图标样式
   */
  private async getHdsLayeredIcons(layeredIcons: ESObject[], appList: AppEntry[],
    options: ESObject) {
    if (layeredIcons.length == 0 || appList.length == 0) {
      LogUtil.error(`${this.TAG} getHdsLayeredIcons failed appList: ${appList.length}, LayeredIcons: ${layeredIcons.length}`);
      return;
    }
    LogUtil.info(`${this.TAG} getHdsLayeredIcons start appList: ${appList.length}, LayeredIcons: ${layeredIcons.length}`);
    try {
      let remainCount: number = layeredIcons.length;
      let handledCount: number = 0;
      let startIndex: number = 0;
      do {
        handledCount = remainCount >= HdsDrawableTools.HDS_MAX_PROC_COUNT ?
        HdsDrawableTools.HDS_MAX_PROC_COUNT : remainCount;
        let handlerIcons: ESObject[] = layeredIcons.slice(startIndex, startIndex + handledCount);
        let processedIcons: ESObject[] = [];
        // let processedIcons: ESObject[] = await hdsDrawable.getHdsLayeredIcons(handlerIcons, options);
        appList.forEach((entryObj: AppEntry) => {
          let icon: ESObject | undefined =
            processedIcons.find((element: ESObject) => {
              return entryObj.name === element.bundleName ||
                entryObj.name === element.bundleName.replace(AppType.CONTAINER_APP, '');
            })
          if (icon) {
            entryObj.icon = icon.pixelMap;
            // try {
            //   let imageInfo: image.ImageInfo = entryObj.icon.getImageInfoSync();
            //   LogUtil.info(`${this.TAG} getHdsLayeredIcons ${entryObj.name} get icon {${imageInfo.size.width}, ${imageInfo.size.height}} success`);
            // } catch {
            //   LogUtil.error(`${this.TAG} getHdsLayeredIcons name: ${entryObj.name}, get imageInfo failed`);
            // }
          }
        })
        startIndex += handledCount;
        remainCount -= handledCount;
      } while (remainCount > 0)
    } catch (error) {
      LogUtil.error(`${this.TAG} getHdsLayeredIcons errcode: ${error?.code}, errMes: ${error?.message}`);
    }
    LogUtil.info(`${this.TAG} getHdsLayeredIcons finish appList: ${appList.length}, LayeredIcons: ${layeredIcons.length}`);
  }

  /**
   * 获取经过hds裁剪的本地资源
   *
   * @param resName 资源名称
   * @param bundleName 应用名称
   * @returns 返回pixelMap，获取失败则返回undefined
   */
  public getHdsIconFromResource(resName: string, bundleName: string): PixelMap | undefined {
    let pixelMap: PixelMap | undefined = ResourceUtil.getPixelMap(resName);
    if (!pixelMap) {
      return undefined;
    }
    let mask: PixelMap = this.getMask();
    let hasBorder: boolean = !ThemeManager.getInstance().checkIsOnlineIcon();
    let result: PixelMap | undefined;
    try {
      // result = hdsDrawable.getHdsIcon(bundleName, pixelMap, HdsDrawableTools.defaultSize,
      //   mask, hasBorder);
    } catch (error) {
      LogUtil.error(`${this.TAG} loadLabelAndIcon getHdsIcon err code: ${error?.code}, message ${error?.message}`);
    }
    pixelMap.release()
    mask.release();
    return result;
  }

  /**
   * 加载指定应用的图标
   *
   * @param appEntry 指定的应用信息
   * @param isHdsHandle 是否需要经过hds处理
   * @return 是否成功加载图标
   */
  public async loadLabelAndIcon(appEntry: AppEntry, isHdsHandle: boolean): Promise<boolean> {
    let defaultLabel: string = appEntry.name;
    let defaultIcon: ResourceStr | PixelMap = AppEntry.getDefaultIcon();

    let bundleFlags = bundleResourceManager.ResourceFlag.GET_RESOURCE_INFO_WITH_LABEL;
    bundleFlags = bundleFlags | (isHdsHandle ?
      bundleResourceManager.ResourceFlag.GET_RESOURCE_INFO_WITH_DRAWABLE_DESCRIPTOR :
      bundleResourceManager.ResourceFlag.GET_RESOURCE_INFO_WITH_ICON);
    let bundleResourceInfo: bundleResourceManager.BundleResourceInfo | undefined =
      appEntry.getBundleResourceInfo(appEntry.name, bundleFlags, appEntry.appIndex);
    if (!bundleResourceInfo || !appEntry.appInfo) {
      appEntry.label = defaultLabel;
      appEntry.icon = defaultIcon;
      LogUtil.error(`${this.TAG} loadLabelAndIcon fail, name: ${appEntry?.name}, appIndex: ${appEntry?.appIndex}`);
      return false;
    }
    if (!isHdsHandle) {
      appEntry.label = bundleResourceInfo.label;
      appEntry.icon = bundleResourceInfo.icon;
      return true;
    }
    if (appEntry.appInfo.bundleType === 0) {
      let hasBorder: boolean = !ThemeManager.getInstance().checkIsOnlineIcon();
      let mask = this.getMask();
      appEntry.icon = this.getCustomHdsIcon(appEntry, bundleResourceInfo.drawableDescriptor,
        HdsDrawableTools.defaultSize, mask, hasBorder) ?? defaultIcon;
      mask.release();
    } else {
      // 元服务图标不接入hds
      appEntry.icon = bundleResourceInfo.drawableDescriptor.getPixelMap();
    }
    appEntry.label = bundleResourceInfo.label;
    if (!appEntry.label) {
      LogUtil.error(`${this.TAG} get label invalid, name: ${appEntry?.name}, appIndex: ${appEntry?.appIndex}`);
      appEntry.label = defaultLabel;
    }

    return true;
  }

  /**
   * 深拷贝pixelMap
   *
   * @param pixelMap 目标pixelMap
   * @returns 拷贝后的pixelMap
   */
  public clonePixelMap(pixelMap: PixelMap): PixelMap {
    const buffer: ArrayBuffer = new ArrayBuffer(pixelMap.getPixelBytesNumber());
    pixelMap.readPixelsToBufferSync(buffer);
    let opts: image.InitializationOptions = {
      pixelFormat: image.PixelMapFormat.BGRA_8888,
      size: pixelMap.getImageInfoSync().size,
      srcPixelFormat: pixelMap.getImageInfoSync().pixelFormat
    }
    let newPixelMap: image.PixelMap = image.createPixelMapSync(buffer, opts);
    return newPixelMap;
  }
}


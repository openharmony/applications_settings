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

import { image } from '@kit.ImageKit';
import { commonEventManager } from '@kit.BasicServicesKit';
import { effectKit } from '@kit.ArkGraphics2D';
import base from '@ohos.base';
import { LogUtil } from '@ohos/settings.common/src/main/ets/utils/LogUtil';
import { DeviceUtil } from '@ohos/settings.common/src/main/ets/utils/BaseUtils';
import { EventBus } from '@ohos/settings.common/src/main/ets/framework/common/EventBus';
import { ThemeEditorUtil } from './ThemeEditorUtil';
import { ThemeConstant } from './Consts';
import { display } from '@kit.ArkUI';
/* instrument ignore file */
const TAG: string = 'WallpaperPreloader';
const ACTIVATE_THEME_FLAG: number = 1;
const RED_LEVEL: number = 0.299;
const GREEN_LEVEL: number = 0.587;
const BLUE_LEVEL: number = 0.114;
const CHECK_DARK_NUM: number = 192;
const PERMISSION_ACTIVATE_THEME: string = 'ohos.permission.ACTIVATE_THEME_PACKAGE';
const HOME_EXTRA_CROP_RATIO: number = 0.045;
const HPR_X: number = 3296;
const HPR_Y: number = 3296;
const HPR_PREVIEW_MAXSIZE: number = 1280;

/**
 * 壁纸预加载类
 *
 * @since 2025-2-13
 */
class WallpaperPreloader {
  private static instance: WallpaperPreloader | null = null;
  private homeWallPaper: image.PixelMap | null = null;
  private lockWallPaper: image.PixelMap | null = null;
  private isDarkWallpaper: boolean = true;
  private isInitialized: boolean = false;
  private subscriber?: commonEventManager.CommonEventSubscriber;
  private readonly subscribeInfo?: commonEventManager.CommonEventSubscribeInfo = {
    events: [
      'com.ohos.ActivateTheme',
      commonEventManager.Support.COMMON_EVENT_PACKAGE_REMOVED
    ],
    publisherPermission: PERMISSION_ACTIVATE_THEME
  };
  private orientationChangeCallback = () => {
    LogUtil.showInfo(TAG, 'orientationChangeCallback');
    this.loadWallpapers();
  };

  public static getInstance(): WallpaperPreloader {
    if (!WallpaperPreloader.instance) {
      WallpaperPreloader.instance = new WallpaperPreloader();
    }
    return WallpaperPreloader.instance;
  }

  public init(): void {
    LogUtil.showInfo(TAG, 'start init');
    if (this.isInitialized) {
      LogUtil.showInfo(TAG, 'isInitialized , no need init');
      return;
    }
    this.isInitialized = true;
    this.initSubscriber();
    this.loadWallpapers();
  }

  public registerOrientationListener(): void {
    if (DeviceUtil.isSuperFoldProduct()) {
      display.on('change', this.orientationChangeCallback);
    }
  }

  public unregisterOrientationListener(): void {
    if (DeviceUtil.isSuperFoldProduct()) {
      display.off('change', this.orientationChangeCallback);
    }
  }

  public getHomeWallpaper(): image.PixelMap | null {
    return this.homeWallPaper;
  }

  public getLockWallpaper(): image.PixelMap | null {
    return this.lockWallPaper;
  }

  public getIsDarkWallpaper(): boolean {
    return this.isDarkWallpaper;
  }

  private initSubscriber(): void {
    try {
      commonEventManager.createSubscriber(this.subscribeInfo,
        (err: base.BusinessError, data: commonEventManager.CommonEventSubscriber) => {
          if (err) {
            LogUtil.showError(TAG, `create subscriber failed ${err?.code} : ${err?.message}`);
            return;
          }
          this.subscriber = data;
          if (!this.subscriber) {
            LogUtil.showError(TAG, 'invalid subscriber.');
            return;
          }
          this.handleSubscribe();
        })
    } catch (e) {
      LogUtil.showError(TAG, 'initSubscriber failed.');
    }
  }

  private handleSubscribe(): void {
    try {
      commonEventManager.subscribe(this.subscriber,
        (err: base.BusinessError, eventData: commonEventManager.CommonEventData) => {
          if (err) {
            LogUtil.showError(TAG, `subscribe failed: ${eventData?.event}. Code:${err.code}, message:${err.message}`);
            return;
          }
          if (!eventData?.parameters) {
            LogUtil.showError(TAG, 'invalid parameters');
            return;
          }
          LogUtil.showInfo(TAG, `received ${eventData?.event}, ${eventData?.parameters?.home}.`);
          if (eventData?.parameters?.home === ACTIVATE_THEME_FLAG) {
            this.loadWallpapers();
          }
        });
    } catch (e) {
      LogUtil.showError(TAG, `subscribe failed: ${e?.code}, ${e?.message}`);
    }
  }

  private async loadWallpapers(): Promise<void> {
    this.getWallpaperPixelMap();
    this.getWallpaperPixelMap(true);
  }

  private async getWallpaperPixelMap(isLock: boolean = false): Promise<void> {
    LogUtil.showInfo(TAG, 'getWallpaperPixelMap');
    const targetDir: string =
      (DeviceUtil.isSuperFoldProduct() && !DeviceUtil.isDevicePortrait()) ? ThemeConstant.LAND_DIR :
      ThemeConstant.BASE_DIR;
    await ThemeEditorUtil.getCurrentHomeWallpaperPath(targetDir, isLock)
      .then(async (result: ResourceStr) => {
        let imageSource: image.ImageSource | undefined = undefined;
        try {
          imageSource = image.createImageSource(result as string);
          const imageInfo: image.ImageInfo = await imageSource.getImageInfo();
          const decodingOptions: image.DecodingOptions = this.getNormalOptions(imageInfo);
          let pixelMap: image.PixelMap = await imageSource.createPixelMap(decodingOptions);
          if (DeviceUtil.isSuperFoldProduct()) {
            pixelMap = await this.cropWallpaper(pixelMap, isLock);
          }
          if (isLock) {
            this.lockWallPaper = pixelMap;
            await this.calculateIsDarkWallpaper(this.lockWallPaper);
          } else {
            this.homeWallPaper = pixelMap;
          }
          EventBus.getInstance().emit('wallpaper_change');
        } catch (e) {
          LogUtil.showError(TAG, `getWallpaperPixelMap error ${e?.message}`);
        } finally {
          imageSource?.release();
        }
      });
  }

  private getNormalOptions(imageInfo: image.ImageInfo): image.DecodingOptions {
    let decodingOptions: image.DecodingOptions = {
      editable: true,
      desiredPixelFormat: image.PixelMapFormat.RGBA_8888,
    };
    if (!imageInfo) {
      LogUtil.showError(TAG, 'getNormalOptions fail,imageInfo is undefined');
      return decodingOptions;
    }
    const imageWidth: number = imageInfo.size.width;
    const imageHeight: number = imageInfo.size.height;
    let x: number = 0;
    let y: number = 0;
    decodingOptions = {
      editable: true,
      desiredPixelFormat: image.PixelMapFormat.RGBA_8888,
      desiredRegion: {
        size: {
          height: imageHeight, width: imageWidth
        }, x: x, y: y
      }
    };
    if (DeviceUtil.isSuperFoldProduct()) {
      decodingOptions.desiredSize = imageWidth >= imageHeight ?
        { width: HPR_PREVIEW_MAXSIZE, height: HPR_PREVIEW_MAXSIZE * imageHeight / imageWidth } :
        { width: HPR_PREVIEW_MAXSIZE * imageWidth / imageHeight, height: HPR_PREVIEW_MAXSIZE }
    }
    return decodingOptions;
  }

  // 计算壁纸是否为深色
  private async calculateIsDarkWallpaper(image: PixelMap | null): Promise<void> {
    if (!image) {
      return;
    }
    const colorPicker: effectKit.ColorPicker = await effectKit.createColorPicker(image);
    const color: effectKit.Color = colorPicker.getAverageColor();
    const grayLevel: number = color.red * RED_LEVEL + color.green * GREEN_LEVEL + color.blue * BLUE_LEVEL;
    this.isDarkWallpaper = grayLevel < CHECK_DARK_NUM;
  }

  // 壁纸预览图按照实际显示裁切
  private async cropWallpaper(pixelMap: image.PixelMap, isLock: boolean): Promise<image.PixelMap> {
    LogUtil.showInfo(TAG, `cropWallpaper isLock = ${isLock}`);
    const tempWidth: number = DeviceUtil.isDevicePortrait() ? HPR_X : HPR_Y;
    const tempHeight: number = DeviceUtil.isDevicePortrait() ? HPR_Y : HPR_X;
    const tempSize: number = HPR_Y;
    const imgInfo: image.ImageInfo = pixelMap.getImageInfoSync();
    const imgW: number = imgInfo.size.width;
    const imgH: number = imgInfo.size.height;
    let x: number = 0;
    let y: number = 0;
    let targetHeight: number = 0;
    let targetWidth: number = 0;
    if (imgH <= imgW) {
      y = imgH * (tempSize - tempHeight) / (2 * tempSize);
      x = imgH * (tempSize - tempWidth) / (2 * tempSize) + (imgW - imgH) / 2;
      targetHeight = tempHeight * imgH / tempSize;
      targetWidth = tempWidth * imgH / tempSize;
    } else {
      y = imgW * (tempSize - tempHeight) / (2 * tempSize) + (imgH - imgW) / 2;
      x = imgW * (tempSize - tempWidth) / (2 * tempSize);
      targetHeight = tempHeight * imgW / tempSize;
      targetWidth = tempWidth * imgW / tempSize;
    }
    if (!isLock) {
      y += HOME_EXTRA_CROP_RATIO * targetHeight;
      x += HOME_EXTRA_CROP_RATIO * targetWidth;
      targetHeight = (1 - 2 * HOME_EXTRA_CROP_RATIO) * targetHeight;
      targetWidth = (1 - 2 * HOME_EXTRA_CROP_RATIO) * targetWidth;
    }
    LogUtil.showInfo(TAG, `imgW ${imgW} imgH ${imgH} y ${y} x ${x} height ${targetHeight} width ${targetWidth}`);
    await pixelMap.crop({ x: x, y: y, size: { height: targetHeight, width: targetWidth, } });
    LogUtil.showInfo(TAG, 'cropWallpaper end');
    return pixelMap;
  }
}

/**
 * 全局单例
 */
export const wallpaperPreloader: WallpaperPreloader = WallpaperPreloader.getInstance();

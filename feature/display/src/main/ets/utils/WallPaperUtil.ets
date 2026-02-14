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

/* instrument ignore file */
import fs from '@ohos.file.fs';
import image from '@ohos.multimedia.image';
import fileuri from '@ohos.file.fileuri';
import commonEventManager from '@ohos.commonEventManager';
import { BusinessError } from '@ohos.base';
import { LogUtil } from '@ohos/settings.common/src/main/ets/utils/LogUtil';
import { EventBus } from '@ohos/settings.common/src/main/ets/framework/common/EventBus';
import { ThemeEditorUtil } from './ThemeEditorUtil';
import { DisplayConstants } from '../constant/DisplayConstant';

const TAG: string = 'ScreenWallpaperUtil:';
// 缩略图缓存路径
const THUMBNAIL_PATH = getContext(this) !== undefined ? getContext(this).cacheDir + '/wallpaper_thumbnail.jpg' : '';
const ACTIVATE_THEME_FLAG: number = 1;
const THUMBNAIL_CACHE_DELAY: number = 150;

type CallbackFunction = () => void;

export class ScreenWallpaperUtil {
  private static instance: ScreenWallpaperUtil;
  // 当前壁纸更换事件回调
  private currentWallpaperCb: CallbackFunction[] = [];
  private subscriber?: commonEventManager.CommonEventSubscriber;
  private readonly subscribeInfo: commonEventManager.CommonEventSubscribeInfo = {
    events: ['com.ohos.ActivateTheme']
  };

  private constructor() {
    this.initSubscriber();
  }

  public static getInstance(): ScreenWallpaperUtil {
    if (!ScreenWallpaperUtil.instance) {
      ScreenWallpaperUtil.instance = new ScreenWallpaperUtil();
    }
    return ScreenWallpaperUtil.instance;
  }

  private emit() {
    if (this.currentWallpaperCb.length === 0) {
      LogUtil.showError(TAG, `has no subscriber`);
      return;
    }
    LogUtil.showInfo(TAG, `callback emit`);
    this.currentWallpaperCb.forEach((callback) => {
      callback();
    })
  }

  /**
   * 添加监听
   * @param callback 回调
   */
  public on(callback: () => void) {
    // 无对应事件订阅，触发刷新
    if (!this.subscriber) {
      this.initSubscriber();
    }
    if (this.currentWallpaperCb.includes(callback)) {
      LogUtil.showError(TAG, `callback already exists`);
    } else {
      LogUtil.showInfo(TAG, `callback push`);
      this.currentWallpaperCb.push(callback);
    }
  }

  // 撤销特定回调监听
  public detach(callback: () => void) {
    this.currentWallpaperCb = this.currentWallpaperCb.filter((cb) => cb !== callback);
    if (this.currentWallpaperCb.length === 0) {
      this.die();
    }
  }

  // 撤销所有监听
  public off() {
    this.die();
  }

  private die() {
    try {
      this.currentWallpaperCb = [];
      commonEventManager.unsubscribe(this.subscriber);
      this.subscriber = undefined;
    } catch (e) {
      LogUtil.showError(TAG, 'commonEventManager unsubscribe failed');
    }
  }

  /**
   * 仅用于显示与亮度内壁纸刷新触发
   */
  public initSubscriber() {
    LogUtil.showInfo(TAG, `init subscriber start`);
    try {
      LogUtil.showInfo(TAG, `create subscriber start`);
      commonEventManager.createSubscriber(this.subscribeInfo,
        (err: BusinessError, data: commonEventManager.CommonEventSubscriber) => {
          if (err) {
            LogUtil.showError(TAG, `create subscriber failed ${err.code} : ${err.message}`);
            return;
          }
          this.subscriber = data;
          if (!this.subscriber) {
            LogUtil.showError(TAG, 'invalid subscriber.');
            return;
          }
          this.handleSubscribe();
          LogUtil.showInfo(TAG, `create subscriber end`);
        })
    } catch (e) {
      LogUtil.showError(TAG, 'initSubscriber failed.');
    }
  }

  private handleSubscribe(): void {
    LogUtil.showInfo(TAG, `init handle subscribe start`);
    try {
      commonEventManager.subscribe(this.subscriber,
        (err: BusinessError, eventData: commonEventManager.CommonEventData) => {
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
            this.emit();
          }
          LogUtil.showInfo(TAG, `init handle subscribe end`);
        });
    } catch (e) {
      LogUtil.showError(TAG, `subscribe failed: ${e?.code}, ${e?.message}`);
    }
  }

  /**
   * 读取低分辨率图片，转换为PixelMap格式
   *
   * @param filePath 图片应用沙箱路径
   * @returns 低分辨率PixelMap图片数据
   */
  public static readImage(filePath: string, scaleFlag: boolean = true): PixelMap | null {
    let file: fs.File | undefined = undefined;
    let imageSourceApi: image.ImageSource | undefined = undefined;
    let pixelMap: image.PixelMap | undefined = undefined;
    try {
      file = fs.openSync(filePath, fs.OpenMode.READ_ONLY);
      imageSourceApi = image.createImageSource(file.fd);
      LogUtil.info(`${TAG} ImageProperty width:${imageSourceApi.getImageInfoSync().size.width}-height:${imageSourceApi.getImageInfoSync().size.height}`);
      if (scaleFlag) {
        let decodingOptions: image.DecodingOptions = {
          desiredSize: { width: imageSourceApi.getImageInfoSync().size.width * DisplayConstants.DEFAULT_SIZE_SCALE_RATE,
            height: imageSourceApi.getImageInfoSync().size.height * DisplayConstants.DEFAULT_SIZE_SCALE_RATE}
        };
        pixelMap = imageSourceApi.createPixelMapSync(decodingOptions);
      } else {
        pixelMap = imageSourceApi.createPixelMapSync();
      }
      if (!pixelMap) {
        LogUtil.warn(`${TAG} read image is null`);
        return null;
      }
      LogUtil.info(`${TAG} pixelMap width:${pixelMap.getImageInfoSync().size.width}-height:${pixelMap.getImageInfoSync().size.width}`);
      return pixelMap;
    } catch (err) {
      LogUtil.error(`${TAG} read image error`);
    } finally {
      if (imageSourceApi) {
        imageSourceApi.release().then(() => {
          LogUtil.info(`${TAG} release imageSource success.`)
        }).catch(() => {
          LogUtil.error(`${TAG} release imageSource error`);
        })
      }
      if (file) {
        fs.closeSync(file);
      }
    }
    return null;
  }

  /**
   * 设置冷启动1s后，主动缓存缩略图
   * @returns
   */
  public static startCacheThumbnail = async () => {
    LogUtil.info(`${TAG} start CacheThumbnail`);
    this.cacheThumbnail();
    LogUtil.info(`${TAG} CacheThumbnail end`);
  }

  /**
   * 缩略图缓存开启函数
   * @returns
   */
  public static cacheThumbnail = async () => {
    LogUtil.info(`${TAG} cacheThumbnail start`);
    const timerCacheThumbnail = setTimeout(() => {
      this.cachingThumbnailFile();
      clearTimeout(timerCacheThumbnail);
    }, THUMBNAIL_CACHE_DELAY);
  }

  /**
   * 缓存缩略图
   *
   * @returns
   */
  private static async cachingThumbnailFile() {
    LogUtil.info(`${TAG} cachingThumbnailFile start`);
    let pixelMap = ScreenWallpaperUtil.readImage(await ThemeEditorUtil.readCurrentWallpaper() as string);
    if (!pixelMap) {
      LogUtil.warn(`${TAG} cachingThumbnailFile pixelMap is null`);
      return;
    }
    let packOpts: image.PackingOption = { format: 'image/jpeg', quality: 100 };
    const imagePackerApi = image.createImagePacker();
    const imgBuffer = await imagePackerApi.packing(pixelMap, packOpts);
    fs.open(THUMBNAIL_PATH, fs.OpenMode.READ_WRITE | fs.OpenMode.CREATE).then((file) => {
      try {
        fs.writeSync(file.fd, imgBuffer);
      } catch (error) {
        LogUtil.error(`${TAG} cachingThumbnailFile write code: ${error.code} - message: ${error.message}`);
      } finally {
        try {
          fs.closeSync(file.fd);
          LogUtil.info(`${TAG} cachingThumbnailFile end`);
          EventBus.getInstance().emit('ReloadCurrentWallpaper');
        } catch (err) {
          LogUtil.error(`${TAG} cachingThumbnailFile close code:${err?.code} message:${err?.message}`);
        }
      }
    }).catch((err: BusinessError) => {
      LogUtil.error(`${TAG} cachingThumbnailFile open code:${err.code} message:${err.message}`);
    });
  }

  /**
   * 获取低分辨率壁纸
   *
   * @returns 低分辨率壁纸数据信息
   */
  public static async getCurrentWallpaper(): Promise<image.PixelMap | null | string> {
    if (ThemeEditorUtil.isFileExists(THUMBNAIL_PATH)) {
      LogUtil.info(`${TAG} getCurrentWallpaper from THUMBNAIL_PATH`);
      return ScreenWallpaperUtil.readImage(THUMBNAIL_PATH, false);
    } else {
      LogUtil.info(`${TAG} getCurrentWallpaper from CurrentWallpaperPath`);
      return ScreenWallpaperUtil.readImage(await ThemeEditorUtil.readCurrentWallpaper() as string);
    }
  }
}
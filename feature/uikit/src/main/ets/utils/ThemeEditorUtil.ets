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

import { LogUtil } from '@ohos/settings.common/src/main/ets/utils/LogUtil';
import { DeviceUtil } from '@ohos/settings.common/src/main/ets/utils/BaseUtils';
import fileuri from '@ohos.file.fileuri';
import fs from '@ohos.file.fs';
import { BusinessError } from '@ohos.base';
import { ThemeConstant } from './Consts';

const TAG = 'ThemeEditorUtil';
/* instrument ignore file */
const INSUFFICIENT_STORAGE_SPACE = 110009; // 主题服务存储空间不足错误码

/**
 * 主题设置工具类
 */
export class ThemeEditorUtil {
  /**
   * 读取当前壁纸图片资源
   */
  static async readCurrentWallpaper(isLock: boolean = false): Promise<ResourceStr> {
    LogUtil.showInfo(TAG, 'readCurrentWallpaper start');
    let curEnableWallpaperImage: string = '';
    try {
      const targetDir: string =
        (DeviceUtil.isSuperFoldProduct() && !DeviceUtil.isDevicePortrait()) ? ThemeConstant.LAND_DIR :
        ThemeConstant.BASE_DIR;
      const wallpaperPath: string = await ThemeEditorUtil.getCurrentHomeWallpaperPath(targetDir, isLock);
      if (fs.accessSync(wallpaperPath)) {
        curEnableWallpaperImage = fileuri.getUriFromPath(wallpaperPath);
      } else {
        LogUtil.showWarn(TAG, 'cannot access currentWallpaper path');
      }
    } catch (error) {
      LogUtil.showError(TAG, `readCurrentWallpaper error: ${error.code}, ${error.message}.`);
    }
    LogUtil.showInfo(TAG, 'readCurrentWallpaper end');
    return curEnableWallpaperImage;
  }

  /**
   * 从A/B目录读取当前桌面壁纸路径
   *
   * @param baseDir 基础目录，base或origin
   * @returns 图片沙箱路径
   */
  static getCurrentHomeWallpaperPath(baseDir: string, isLock: boolean = false): Promise<string> {
    return new Promise(async (resolve, reject) => {
      const rootPath: string = ThemeEditorUtil.getRootPath(isLock);
      const jsonPath: string = rootPath + 'manifest.json';
      let file: fs.File | undefined = undefined;
      try {
        file = fs.openSync(jsonPath);
        const jsonContent: object | null = JSON.parse(fs.readTextSync(jsonPath));
        if (!jsonContent) {
          LogUtil.showError(TAG, 'JSON.parse manifest returns null.');
          reject();
          return;
        }
        const imageContent: object | null = JSON.parse(JSON.stringify(jsonContent['image']));
        if (!imageContent) {
          LogUtil.showError(TAG, 'JSON.parse imageContent returns null.');
          reject();
          return;
        }
        const wallpaperFileName: string = imageContent['src'];
        let resourcePath: string = rootPath + baseDir + '/resources/' + wallpaperFileName;
        if (!ThemeEditorUtil.isFileExists(resourcePath)) {
          resourcePath = rootPath + 'base/resources/' + wallpaperFileName;
        }
        resolve(resourcePath);
      } catch (error) {
        LogUtil.showError(TAG, `error in getCurrentHomeWallpaperPath: ${error?.message}`);
        reject();
      } finally {
        try {
          file && fs.closeSync(file);
        } catch (error) {
          LogUtil.showError(TAG, `error in getCurrentHomeWallpaperPath: ${error?.message}`);
        }
      }
    })
  }

  private static getRootPath(isLock: boolean = false): string {
    let rootPath: string = '';
    try {
      if (fs.accessSync(ThemeConstant.FLAG_PATH_A)) {
        rootPath = isLock ? ThemeConstant.SANDBOX_LOCK_PATH_A : ThemeConstant.SANDBOX_PATH_A;
      } else if (fs.accessSync(ThemeConstant.FLAG_PATH_B)) {
        rootPath = isLock ? ThemeConstant.SANDBOX_LOCK_PATH_B : ThemeConstant.SANDBOX_PATH_B;
      } else {
        LogUtil.showError(TAG, 'there is no FLAG in A/B path.')
      }
    } catch (error) {
      LogUtil.showError(TAG, `error in getRootPath: ${error.code}, ${error.message}`);
    }
    return rootPath;
  }

  static isFileExists(path: string): boolean {
    let exist = false;
    try {
      exist = fs.accessSync(path);
    } catch (error) {
      LogUtil.showError(TAG, `isFileExists error: ${error.code}, ${error.message}`);
    }
    return exist;
  }

  /**
   * 根据错误码弹出toast提示
   *
   * @param uiContext ui上下文
   * @param err 错误信息
   * @param toastErrMessage 弹出toast提示的文字内容
   */
  public static openToast(uiContext: UIContext, err: BusinessError<void>, toastErrMessage: Resource): void {
    const toastDuration: number = 500; // toast显示时长，单位毫秒
    try {
      if (err?.code === INSUFFICIENT_STORAGE_SPACE) {
        uiContext.getPromptAction().openToast({
          message: $r('app.string.insufficient_storage_toast'),
          duration: toastDuration,
        });
      } else {
        uiContext.getPromptAction().openToast({
          message: toastErrMessage,
          duration: toastDuration,
        });
      }
    } catch (e) {
      LogUtil.showError(TAG, `show toast error, ${e?.code} ${e?.message}`);
    }
  }
}

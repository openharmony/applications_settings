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

import image from '@ohos.multimedia.image';
import fs from '@ohos.file.fs';
import { LogUtil } from '@ohos/settings.common/src/main/ets/utils/LogUtil';

/* instrument ignore file */
const TAG = 'LoadFileUtil';

export class LoadFileUtil {
  /**
   * 从磁盘中加载一张图片到内存
   * @param path 路径
   * @param imageFormat 图片格式
   * @returns 加载成功返回pixelMap，否则返回undefined
   */
  public static async loadImageFromDisk(path: string): Promise<image.PixelMap | undefined> {
    LogUtil.info(`${TAG} loadImageFromDisk`);
    try {
      if (!path || !fs.access(path)) {
        LogUtil.error('${TAG} loadImageFromDisk path is invalid.');
        return undefined;
      }
      let fd: number = -1;
      fd = fs.openSync(path, fs.OpenMode.READ_ONLY).fd;
      let imageSource = image.createImageSource(fd);
      let fpImage: PixelMap = await imageSource.createPixelMap({});
      LogUtil.info(`${TAG} loadImageFromDisk success PixelBytes`);
      await imageSource.release();
      if (fd !== -1) {
        fs.closeSync(fd);
      }
      return fpImage;
    } catch (error) {
      LogUtil.error(`${TAG} loadImageFromDisk current Exception, code is ${error?.code}`);
    }
    return undefined;
  }
}
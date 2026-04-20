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

import { BusinessError } from '@ohos.base';
import util from '@ohos.util';
import resmgr from '@ohos.resourceManager';
import { LogUtil } from './LogUtil';

const TAG: string = 'RawFileUtil';
const UNICODE: string = 'utf-8';
const DECODER: util.TextDecoder = new util.TextDecoder('utf-8', {ignoreBOM: true});

/**
 * rawFile工具类
 */
export class RawFileUtil {
  /**
   * 获取指定JSON文件的对象
   * @param context 上下文
   */
  public static getStringByFile(resourceManager: resmgr.ResourceManager | undefined,
                                fileName: string): Promise<string> {
    return new Promise((resolve, reject) => {
      if (!resourceManager || !fileName) {
        LogUtil.error(`getFileContent failed. resourceManager or fileName is null.`);
        reject();
        return;
      }
      try {
        resourceManager.getRawFileContent(fileName).then((value) => {
          let content = util.TextDecoder.create(UNICODE).decodeWithStream(value);
          resolve(content);
        }).catch((err: BusinessError) => {
          LogUtil.error(`${TAG} getFileContent of ${fileName} failed. ${err?.code} ${err?.message}`);
          reject(err);
        });
      } catch (jsonError) {
        LogUtil.error(`${TAG} JSON parse error:${jsonError?.code} ${jsonError?.message}`);
        reject();
      }
    });
  }

  /**
   * 读取rawfile json文件
   *
   * @param fileName 文件名
   * @returns 解码后json数据
   */
  static getJsonRawFile(fileName: string): Promise<object> {
    let context: Context = AppStorage.get<Context>('pageContext') as Context;
    return new Promise((resolve, reject) => {
      context?.resourceManager.getRawFileContent(fileName).then((value: Uint8Array) => {
        try {
          if (value) {
            const rawContent: string = DECODER.decode(new Uint8Array(value.buffer));
            const data: object = JSON.parse(rawContent);
            resolve(data);
          } else {
            reject();
          }
        } catch (e) {
          reject();
        }
      });
    });
  }
}

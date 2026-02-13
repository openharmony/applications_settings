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
import { LogUtil } from '@ohos/settings.common/src/main/ets/utils/LogUtil';
import { ResourceManagerUtil } from '@ohos/settings.common/src/main/ets/utils/ResourceManagerUtil';

const TAG = 'ExternalResourceUtils'

/**
 * 外部资源工具类
 */
export class ExternalResourceUtils {
  /**
   * 根据资源名获取外部resource对象字符串
   *
   * @param bundleName 包名
   * @param stringName Resource资源名
   * @returns string 返回字符串
   */
  static getExternalStringByName(bundleName: string, stringName: string): string {
    try {
      let resourceManager = ResourceManagerUtil.getBundleResourceManager(bundleName);
      if (!resourceManager) {
        LogUtil.showError(TAG, 'getExternalStringByName failed, resourceManager not found');
        return '';
      }
      return resourceManager?.getStringByNameSync(stringName);
    } catch (error) {
      let code = (error as BusinessError).code;
      let message = (error as BusinessError).message;
      LogUtil.showError(TAG, `getExternalStringByName failed, error code: ${code}, message: ${message}.`);
      return '';
    }
  }

  /**
   * 根据资源名+指定数量获取外部resource对象表示的单复数字符串
   *
   * @param bundleName 包名
   * @param stringName Resource资源名
   * @param num 数量
   * @returns string 返回字符串
   */
  static getExternalPluralStringByName(bundleName: string, stringName: string, num: number): string {
    try {
      let resourceManager = ResourceManagerUtil.getBundleResourceManager(bundleName);
      if (!resourceManager) {
        LogUtil.showError(TAG, 'getExternalPluralStringByName failed, resourceManager not found');
        return '';
      }
      return resourceManager.getPluralStringByNameSync(stringName, num);
    } catch (err) {
      LogUtil.showError(TAG, `getExternalPluralStringByName failed, error code: ${err?.code}, message: ${err?.message}`);
      return '';
    }
  }
}
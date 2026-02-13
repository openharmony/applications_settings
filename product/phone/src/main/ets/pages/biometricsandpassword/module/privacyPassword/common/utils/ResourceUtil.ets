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
import { Context } from '@kit.AbilityKit';
import { BusinessError } from '@ohos.base';
import Log from './Log';

const TAG = 'ResourceUtil';

/**
 * 资源工具类
 */
export class ResourceUtil {
  /**
   * 以同步方式获取string资源值
   *
   * @param resource Resource资源类
   */
  static getStringSync(resource: Resource | undefined | string): string {
    let resourceString: string = '';
    if (!resource) {
      return resourceString;
    }
    if (typeof resource === 'string') {
      return resource;
    }
    let resourceManager = (AppStorage.get<Context>('pageContext') as Context)?.resourceManager;
    if (!resourceManager) {
      return resourceString;
    }
    try {
      resourceString = resourceManager.getStringSync(resource.id);
    } catch (err) {
      Log.error(TAG, `getStringSync error, BusinessError code is ${(err as BusinessError).code}`);
    }
    return resourceString;
  }

  /**
   * 以同步方式获取plural资源值
   *
   * @param resource Resource资源类
   */
  static getPluralStringSync(resource: Resource | undefined, num: number): string {
    let resourceString: string = '';
    if (!resource) {
      return resourceString;
    }
    if (typeof resource === 'string') {
      return resource;
    }
    let resourceManager = (AppStorage.get<Context>('pageContext') as Context)?.resourceManager;
    if (!resourceManager) {
      return resourceString;
    }
    try {
      resourceString = resourceManager.getPluralStringValueSync(resource.id, num);
    } catch (err) {
      Log.error(TAG, `getStringSync error, BusinessError code is ${(err as BusinessError).code}`);
    }
    return resourceString;
  }

  /**
   * 任意数量string类型替换
   *
   * @param resource Resource资源类
   * @param ...subStrs 任意数量替换子串
   */
  static getAnyStrFormatStringSync(resource: Resource, ...subStrs: Array<string>): string {
    let result = ResourceUtil.getStringSync(resource);
    if (!result) {
      return '';
    }
    for (let i = 0; i < subStrs.length; i++) {
      result = result.replace(new RegExp('%' + (i + 1) + '\\$s', 'gm'), subStrs[i]);
      result = result.replace(new RegExp('%' + (i + 1) + '\\$d', 'gm'), subStrs[i]);
    }
    return result;
  }

  /**
   * 同步方式任意数量string类型替换
   *
   * @param resource Resource资源类
   * @param ...numbers 任意数量替换数字
   */
  static getAnyNumFormatStringSync(resource: Resource, ...numbers: Array<number>): string {
    let result = ResourceUtil.getStringSync(resource);
    if (!result) {
      return '';
    }
    for (let i: number = 0; i < numbers.length; i++) {
      result = result.replace(new RegExp('%' + (i + 1) + '\\$d', 'gm'), String(numbers[i]));
    }
    return result;
  }

  /**
   * number类型替换
   *
   * @param subStr 格式替换子串(%d)
   */
  static getNumberFormatString(resource: Resource, ...numbers: Array<number>): string {
    let result = ResourceUtil.getStringSync(resource);
    if (!result) {
      return '';
    }
    for (let i: number = 0; i < numbers.length; i++) {
      result = result.replace(new RegExp('%d', 'gm'), String(numbers[i]));
    }
    return result;
  }
}
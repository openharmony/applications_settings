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

import { Context } from '@kit.AbilityKit';
import common from '@ohos.app.ability.common';
import { BusinessError } from '@ohos.base';
import preferences from '@ohos.data.preferences';
import { ContextUtils } from './baseutils/ContextUtils';
import { LogUtil } from './LogUtil';

const TAG: string = 'PreferencesUtil : ';

// UserConfigs
export const APP_CONFIG = 'APP_CONFIG';

/**
 * Preferences工具类
 *
 * @since 2023-08-10
 */
export class PreferencesUtil {
  /**
   * 获取key-value
   * @param key
   * @param defValue
   * @returns
   */
  static async get(key: string, defValue: preferences.ValueType): Promise<preferences.ValueType> {
    try {
      const context = await preferences.getPreferences(ContextUtils.getContext(), APP_CONFIG);
      return await context.get(key, defValue);
    } catch (e) {
      LogUtil.error(`${TAG} preferences get key: ${key} error: ${e?.code}`)
      return defValue;
    }
  }

  /**
   * 子线程获取key-value
   * @param key
   * @param defValue
   * @returns
   */
  static async getPreferencesData(key: string, defValue: preferences.ValueType,
                                  taskPoolContext: common.Context): Promise<preferences.ValueType> {
    try {
      const preferencesData = await preferences.getPreferences(taskPoolContext, APP_CONFIG);
      return await preferencesData.get(key, defValue);
    } catch (error) {
      LogUtil.error(`${TAG} preferences getPreferencesData key: ${key} error: ${(error as BusinessError)?.message}`)
      return defValue;
    }
  }

  /**
   * 判断是否存在
   *
   * @param key
   * @returns
   */
  static async has(key: string): Promise<boolean> {
    try {
      const context = await preferences.getPreferences(ContextUtils.getContext(), APP_CONFIG);
      return await context.has(key);
    } catch (e) {
      LogUtil.error(`${TAG} preferences has key: ${key} error: ${(e as BusinessError).message}`)
      return false;
    }
  }

  /**
   * 同步接口，获取key-value
   * @param key
   * @param defValue
   * @returns
   */
  static getSync(key: string, defValue: preferences.ValueType): preferences.ValueType {
    try {
      let options: preferences.Options = { name: APP_CONFIG };
      const context = preferences.getPreferencesSync(ContextUtils.getContext(), options);
      return context.getSync(key, defValue);
    } catch (e) {
      LogUtil.error(`${TAG} preferences get key: ${key} error: ${(e as BusinessError).message}`)
      return defValue;
    }
  }

  /**
   * 同步接口，判断是否存在
   *
   * @param key
   * @returns
   */
  static hasSync(key: string): boolean {
    try {
      let options: preferences.Options = { name: APP_CONFIG };
      const context = preferences.getPreferencesSync(ContextUtils.getContext(), options);
      return context.hasSync(key);
    } catch (e) {
      LogUtil.error(`${TAG} preferences has key: ${key} error: ${(e as BusinessError).message}`)
      return false;
    }
  }

  /**
   * 新增/更新
   *
   * @param key
   * @param value
   * @returns
   */
  static async put(key: string, value: preferences.ValueType): Promise<void> {
    PreferencesUtil.putValueWithPreferenceName(key, value, APP_CONFIG);
  }

  /**
   * 子线程新增/更新
   *
   * @param key
   * @param value
   * @returns
   */
  static async putPreferencesData(key: string, value: preferences.ValueType,
                                  taskPoolContext: common.Context): Promise<void> {
    try {
      const preferencesData = await preferences.getPreferences(taskPoolContext, APP_CONFIG);
      await preferencesData.put(key, value);
      await preferencesData.flush();
    } catch (error) {
      LogUtil.error(`${TAG} preferences putPreferencesData key: ${key} error: ${(error as BusinessError)?.message}`)
    }
  }

  static putSync(key: string, value: preferences.ValueType): void {
    try {
      const context = preferences.getPreferencesSync(ContextUtils.getContext(), { name: APP_CONFIG });
      context.putSync(key, value);
      context.flush(() => {
        LogUtil.info(`${TAG} preferences putsync key: ${key} flush`);
      });
    } catch (e) {
      LogUtil.error(`${TAG} preferences putsync key: ${key} error: ${(e as BusinessError).message}`)
    }
  }

  /**
   * 删除
   *
   * @param key
   * @returns
   */
  static async delete(key: string): Promise<void> {
    try {
      const context = await preferences.getPreferences(ContextUtils.getContext(), APP_CONFIG);
      await context.delete(key);
      await context.flush();
    } catch (e) {
      LogUtil.error(`${TAG} preferences delete key: ${key} error: ${(e as BusinessError).message}`)
    }
  }

  /**
   * 同步接口，获取key-value
   *
   * @param key key
   * @param defValue 默认值
   * @param preferenceName 修改的preference
   * @param ctx 上下文
   * @returns key对应的value值
   */
  static getSyncWithPreferenceName(key: string, defValue: preferences.ValueType,
    preferenceName: string, ctx?: Context): preferences.ValueType {
    try {
      let options: preferences.Options = { name: preferenceName };
      const context = preferences.getPreferencesSync(ctx ?? ContextUtils.getContext(), options);
      return context.getSync(key, defValue);
    } catch (e) {
      LogUtil.error(`${TAG} preferences get key: ${key} error: ${(e as BusinessError).message}`);
      return defValue;
    }
  }

  /**
   * 新增/更新key-value
   *
   * @param key key
   * @param value 值
   * @param preferenceName 修改的preference
   */
  static async putValueWithPreferenceName(key: string, value: preferences.ValueType,
    preferenceName: string): Promise<void> {
    try {
      const context = await preferences.getPreferences(ContextUtils.getContext(), preferenceName);
      await context.put(key, value);
      await context.flush();
    } catch (e) {
      LogUtil.error(`${TAG} preferences put key: ${key} error: ${(e as BusinessError).message}`);
    }
  }
}
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

import settingsNapi from 'libnative.so';
import hilog from '@ohos.hilog';

const TAG: string = 'native';

export default class NapiInstance {
  private static readonly SETTING_DOMAIN: number = 0x0500;

  /**
   * 获取内核版本信息
   *
   * @param type 内核版本信息类型
   * @returns 与type对应的内核信息
   */
  public getKernelInfo(type: number): string {
    try {
      return settingsNapi.getKernelInfo(type);
    } catch (e) {
      hilog.error(NapiInstance.SETTING_DOMAIN, TAG, `${TAG} get kernel info error.`);
      return '';
    }
  }

  public sleep(time: number): void {
    try {
      settingsNapi.sleep(time);
    } catch (e) {
      hilog.error(NapiInstance.SETTING_DOMAIN, TAG, `${TAG} sleep cache exception.`);
    }
  }
}

export let napi = new NapiInstance();
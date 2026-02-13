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

const MODULE_TAG: string = 'setting_vpn:commonUtils:';

export class CommonUtils {
  static uint8ArrayToString(fileData: Uint8Array): string {
    /* instrument ignore if*/
    if (!fileData) {
      LogUtil.error(`${MODULE_TAG} uint8ArrayToString failed, param is error`);
      return '';
    }
    let dataString = '';
    for (let i = 0; i < fileData.length; i++) {
      dataString += String.fromCharCode(fileData[i]);
    }
    return dataString;
  }

  static stringToUint8Array(str: string): Uint8Array {
    /* instrument ignore if*/
    if (!str) {
      LogUtil.error(`${MODULE_TAG} stringToUint8Array failed, param is error`);
      return new Uint8Array([]);
    }
    let arr: number[] = [];
    for (let i = 0, j = str.length; i < j; ++i) {
      arr.push(str.charCodeAt(i));
    }
    return new Uint8Array(arr);
  }
}
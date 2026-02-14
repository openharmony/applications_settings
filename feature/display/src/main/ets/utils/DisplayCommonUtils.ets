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
import measure from '@ohos.measure';
import { LogUtil } from '@ohos/settings.common/src/main/ets/utils/LogUtil';
import { RemoteDeviceInfo } from './DeviceUtil';

const TAG = `DisplayCommonUtils`;

export class DisplayCommonUtils {

  /**
   * 计算文字长度
   * @param textStr
   * @param fontSize
   * @returns
   */
  public static calculateTextWidth(textStr: string, fontSize: ResourceStr): number {
    let ret = measure.measureText({
      textContent: textStr,
      fontSize: fontSize
    })
    return px2vp(ret);
  }

  static parseString<T = RemoteDeviceInfo>(str: string): T | undefined {
    try {
      return JSON.parse(str) as T
    } catch (e) {
      LogUtil.showError(TAG, `parseString`);
    }
    return undefined;
  }
}
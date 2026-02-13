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

import deviceInfo from '@ohos.deviceInfo';

const DEVICE_TYPE_PHONE = 'phone';

export class DeviceUtils {
  private static deviceType: string = deviceInfo.deviceType;

  /**
   * 判断当前是否是手机
   *
   * @returns 如果是手机设备则返回true，否则返回false
   */
  static isPhone(): boolean {
    return DeviceUtils.deviceType === DEVICE_TYPE_PHONE;
  }
}
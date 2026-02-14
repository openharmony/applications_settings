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

/**
 * 定义包名常量类
 *
 * @since 2022-03-21
 */
export class PackagesConstant {
  public static readonly SETTINGS_EMPTY_STRING = '';
  public static readonly SETTINGS_NAVIGATION_URL = 'navigationUrl';
  public static readonly SETTINGS_BUNDLE_NAME = 'com.ohos.settings';
  public static readonly SETTINGS_MAIN_ABILITY_NAME = 'com.ohos.settings.MainAbility';
  public static readonly SETTINGS_PATH_STACK = 'pathInfoStack';
}

export class Constants {

  // 设备类型： 手机
  public static readonly DEVICE_TYPE_PHONE: string = 'phone';
  // 设备类型： 平板
  public static readonly DEVICE_TYPE_TABLET: string = 'tablet';
  // 设备类型： PC
  public static readonly DEVICE_TYPE_2IN1: string = '2in1';

  // 弱密码弹框类型
  public static readonly continueAnyWay: string = 'continueAnyWay';
  public static readonly repeatPinInput: string = 'repeatPinInput';

  // 设置搜索版本号每次+5，预留patch使用的版本号
  public static readonly ITEMINFO_TABLE_VERSION = '1.0.265';

  public static readonly PAGEINFO_TABLE_VERSION = '1.0.260';

  public static readonly INVALID_VALUE = -1;

  public static readonly WALLET_IDENTIFIER = '941095927463029632';
}

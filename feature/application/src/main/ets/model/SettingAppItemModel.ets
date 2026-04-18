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

import { image } from '@kit.ImageKit';
import {
  SettingContentModel,
  SettingGroupModel
} from '@ohos/settings.common/src/main/ets/framework/model/SettingGroupModel';
import { SettingItemModel } from '@ohos/settings.common/src/main/ets/framework/model/SettingItemModel';
import { AppEntry } from '../AppModel';

export interface SettingAppGroupModel extends SettingGroupModel, SettingContentModel {
  icon?: ResourceStr | PixelMap;
  versionName?: string;
  label?: string;
  name?: string;
  appIndex?: number;
  bundleName?: string;
  entry?: AppEntry;
}

export interface SettingAppItemModel extends SettingItemModel {
  appIndex?: number;
  bundleName?: string;
  entry?: AppEntry;
}

export interface RemoveHeaderModel extends SettingItemModel {
  pic?: ResourceStr | PixelMap;
  label?: string;
}

export interface AppDataModel {
  bundleName?: string;
  appIndex?: number;
  uid?: number;
}

export interface NotifyDataModel {
  config?: AppDataModel;
}

export interface INotificationConfig {
  /**
   * 应用特权配置格式{ 'com.xxx': '1' }，一个包名对应一个按位组合的字符串，从左往右每一个含义如下：
   * 第一位：是否隐藏实况窗开关配置
   */
  appPrivileges?: Record<string, string>;
}

export interface AppListInfo {
  label?: string;
  labelId?: number;
  icon?: image.PixelMap;
  bundleName?: string;
  name?: string;
  isSystemApp?: boolean;
  moduleName?: string;
}
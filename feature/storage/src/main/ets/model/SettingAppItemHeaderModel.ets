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

import { AppEntry } from '@ohos/settings.application/src/main/ets/AppModel';
import { SettingContentModel } from '@ohos/settings.common/src/main/ets/framework/model/SettingGroupModel';
import { SettingItemModel } from '@ohos/settings.common/src/main/ets/framework/model/SettingItemModel';

export interface SettingAppItemHeaderModel extends SettingContentModel {
  icon?: ResourceStr | PixelMap;
  versionName?: string;
  label?: string;
  name?: string;
  appIndex?: number;
  entry?: AppEntry;
}

export interface RemoveHeaderModel extends SettingItemModel {
  pic?: ResourceStr | PixelMap;
  label?: string;
  entry?: AppEntry;
}

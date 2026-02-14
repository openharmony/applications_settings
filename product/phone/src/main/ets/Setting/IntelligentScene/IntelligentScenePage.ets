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
import { PageLoader, PageParams } from '@ohos/settings.common/src/main/ets/framework/common/PageLoader'
import { PageType, SettingPageModel } from '@ohos/settings.common/src/main/ets/framework/model/SettingPageModel'
import { NavEntryKey, PushParam } from '@ohos/settings.common'
import { IntelligentSceneSettings } from './IntelligentSceneSettings'

@Builder function settingIntelligentSceneBuilder(param: object): void {
  IntelligentSceneSettings({ params: (param as PageParams)?.param as PushParam });
}

function customPage(): SettingPageModel {
  return {
    id: 'IntelligentScene',
    url: NavEntryKey.INTELLIGENT_SCENE_SETTINGS_ENTRY,
    type: PageType.PAGE_TYPE_CUSTOM,
    title: 'IntelligentScene',
  }
}

// 页面配置导入
PageLoader.load(NavEntryKey.INTELLIGENT_SCENE_SETTINGS_ENTRY, {
  configGenerator: customPage,
  pageBuilder: wrapBuilder(settingIntelligentSceneBuilder),
});
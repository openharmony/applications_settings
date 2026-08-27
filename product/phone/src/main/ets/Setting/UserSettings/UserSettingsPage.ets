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

import { NavEntryKey } from '@ohos/settings.common/src/main/ets/utils/Consts';
import { PageLoader, PageParams } from '@ohos/settings.common/src/main/ets/framework/common/PageLoader';
import { PageType, SettingPageModel } from '@ohos/settings.common/src/main/ets/framework/model/SettingPageModel';
import { PushParam } from '@ohos/settings.common/src/main/ets/core/controller/Controller';
import { ResourceUtil } from '@ohos/settings.common/src/main/ets/utils/ResourceUtil';
import { UserSettings } from './UserSettings';
import { UserSettingsPageController } from './controller/UserSettingsPageController';

@Builder
function userSettingsBuilder(param: object): void {
  UserSettings({ params: (param as PageParams)?.param as PushParam });
}

function userSettingsPage(): SettingPageModel {
  return {
    id: 'UserSettings',
    url: NavEntryKey.USER_SETTING_ENTRY,
    type: PageType.PAGE_TYPE_CUSTOM,
    title: ResourceUtil.getStringSync($r('app.string.user_settings_title')),
    compControl: new UserSettingsPageController(),
  };
}

PageLoader.load(NavEntryKey.USER_SETTING_ENTRY, {
  configGenerator: userSettingsPage,
  pageBuilder: wrapBuilder(userSettingsBuilder),
});

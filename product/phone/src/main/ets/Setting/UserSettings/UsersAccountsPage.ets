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
import { PageLoader } from '@ohos/settings.common/src/main/ets/framework/common/PageLoader';
import { PageType, SettingPageModel } from '@ohos/settings.common/src/main/ets/framework/model/SettingPageModel';
import { settingPageBuilder } from '@ohos/settings.common/src/main/ets/framework/view/SettingPage';
import { ResourceUtil } from '@ohos/settings.common/src/main/ets/utils/ResourceUtil';
import { UsersAccountsPageController } from './controller/UsersAccountsPageController';

function usersAccountsPage(): SettingPageModel {
  return {
    id: 'UsersAccounts',
    url: NavEntryKey.USERS_ACCOUNT_ENTRY,
    type: PageType.PAGE_TYPE_STANDARD,
    title: ResourceUtil.getStringSync($r('app.string.users_accounts_title')),
    compControl: new UsersAccountsPageController(),
    hdsNavDestinationUx: false,
    groups: [],
  };
}

PageLoader.load(NavEntryKey.USERS_ACCOUNT_ENTRY, {
  configGenerator: usersAccountsPage,
  pageBuilder: wrapBuilder(settingPageBuilder),
});

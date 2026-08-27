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

/* instrument ignore file */
import { NavEntryKey } from '@ohos/settings.common/src/main/ets/utils/Consts';
import { PageLoader, PageParams } from '@ohos/settings.common/src/main/ets/framework/common/PageLoader';
import { PageType, SettingPageModel } from '@ohos/settings.common/src/main/ets/framework/model/SettingPageModel';
import { PushParam } from '@ohos/settings.common/src/main/ets/core/controller/Controller';
import { MoreSuggestionPage } from '@ohos/settings.suggestion/src/main/ets/components/MoreSuggestionPage';
import { GroupType } from '@ohos/settings.common/src/main/ets/framework/model/SettingGroupModel';
import {
  HomePageSuggestionController
} from '@ohos/settings.suggestion/src/main/ets/controller/HomePageSuggestionController';

@Builder
function suggestionMorePageBuilder(param: object): void {
  MoreSuggestionPage({ params: (param as PageParams)?.param as PushParam });
}

function customPage(): SettingPageModel {
  return {
    id: 'homepage_suggestion_more_page',
    url: NavEntryKey.HOMEPAGE_SUGGESTION_MORE_PAGE,
    type: PageType.PAGE_TYPE_STANDARD,
    title: $r('app.string.homepage_suggestion_more_page'),
    compControl: new HomePageSuggestionController(),
    groups: [
      {
        id: 'suggestionMoreItemGroup',
        type: GroupType.GROUP_TYPE_CUSTOM,
        builder: wrapBuilder(suggestionMorePageBuilder),
        visible: true
      }
    ]
  }
}

// 页面配置导入
PageLoader.load(NavEntryKey.HOMEPAGE_SUGGESTION_MORE_PAGE, {
  configGenerator: customPage
});
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

import { CardMenuSection, NavigationEntry } from '@ohos/settings.uikit';
import { SettingHeaderPage } from '@ohos/settings.uikit/src/main/ets/component/SettingHeaderPage';
import { PageUrl } from '../../PageUrl';

/**
 * 系统和更新页菜单数据
 *
 * @since 2023-03-21
 */
interface ConstructorParams {
  pageUrl: string;
  title: Resource | string;
  isNavigation: boolean;
}

interface CardMenuSectionParams {
  key: string,
  index: number; // 用于排序
}

interface NavigationEntryParams {
  key: string;
  index: number;
  title: Resource | string;
  stateIcon: Resource;
  targetPageUrl: string;
}

export class LanguageSettingsHomePage extends SettingHeaderPage {
  public static constructorParamsImpl: ConstructorParams = {
    pageUrl: PageUrl.LANGUAGE_AND_SETTINGS_HOME_URL,
    title: $r('app.string.languageAndRegion'),
    isNavigation: true
  }
  public static cardMenuSectionParamsImplLangSettings: CardMenuSectionParams = {
    key: 'language_setting',
    index: 100, // 用于排序
  }
  public static navigationEntryParamsImplSetLangRegion: NavigationEntryParams = {
    key: 'set_language_region',
    index: 10,
    title: $r('app.string.languageAndRegion'),
    stateIcon: $r('app.media.ic_settings_arrow'),
    targetPageUrl: PageUrl.LANGUAGE_AND_REGION_PAGE_URL,
  }

  constructor() {
    super(LanguageSettingsHomePage.constructorParamsImpl);
    this.addMenus([
      new CardMenuSection(
        LanguageSettingsHomePage.cardMenuSectionParamsImplLangSettings,
        [new NavigationEntry(LanguageSettingsHomePage.navigationEntryParamsImplSetLangRegion)]
      )
    ]);
  }
}

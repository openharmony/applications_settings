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

import { HeaderPage, DefaultListStyle } from '@ohos/settings.uikit';
import { SettingHeaderPageStyle } from '@ohos/settings.uikit/src/main/ets/component/SettingHeaderPage';

export class HomePageListStyle extends DefaultListStyle {
  public clip = false;
  public borderRadius = $r('app.float.border_radius_0');
}

export class HomePageStyle extends SettingHeaderPageStyle {
  public listStyle = new HomePageListStyle();
}

let homePageStyle = new HomePageStyle();

/**
 * 首页菜单页数据
 *
 * @since 2023-10-13
 */
export class ExternalHomePage extends HeaderPage {
  constructor(pageUrl: string) {
    super({
      pageUrl: pageUrl,
      title: $r('app.string.settings_title'),
      isShowBack: false,
      style: homePageStyle,
    });

    this.addMenus([]);
  }
}

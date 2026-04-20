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

import { SettingsBaseMenu } from '@ohos/settings.common/src/main/ets/core/model/menu/SettingsMenu';
import { HeaderPageData,
  ProfilePageHeaderStyle,
  FontI,
  PageTitleTextStyle,
  DefaultPageHeaderStyle,
  DefaultHeaderPageStyle,
  ProfileHeaderPageStyle,
  HeaderPage,
} from '../menus/Menu';

const TITLE_MAX_LINES: number = 2;

// 适配设置标题文本样式
export class SettingPageTitleTextStyle extends PageTitleTextStyle {
  public font: FontI = {
    size: $r('app.float.font_size_20'),
    weight: FontWeight.Bold,
    minFontSize: $r('app.float.font_minFontSize_14'),
    maxFontSize: $r('app.float.font_maxFontSize_20'),
  };
  public margin: Margin = {
    top: $r('app.float.wh_value_16'),
    bottom: $r('app.float.wh_value_15'),
    right: $r('app.float.wh_value_48')
  };
  public size: SizeOptions = {
    width: 'auto',
  };
  public maxLines = TITLE_MAX_LINES;
}

let settingPageTitleTextStyle = new SettingPageTitleTextStyle();

class SettingPageHeaderStyle extends DefaultPageHeaderStyle {
  public title = settingPageTitleTextStyle;
}

class ProfileSettingPageHeaderStyle extends ProfilePageHeaderStyle {
  public title = settingPageTitleTextStyle;
}

export let settingPageHeaderStyle = new SettingPageHeaderStyle();

export let profileSettingPageHeaderStyle = new ProfileSettingPageHeaderStyle();

export class SettingHeaderPageStyle extends DefaultHeaderPageStyle {
  public pageHeaderStyle = settingPageHeaderStyle;
}

export class ProfileSettingHeaderPageStyle extends ProfileHeaderPageStyle {
  public pageHeaderStyle = profileSettingPageHeaderStyle;
}

let settingHeaderPageStyle = new SettingHeaderPageStyle();

export let profileSettingHeaderPageStyle = new ProfileSettingHeaderPageStyle();

export interface SettingHeaderPageData extends HeaderPageData {}

/**
 * Phone通用带标题页面
 *
 * @since 2022-09-06
 */
export class SettingHeaderPage extends HeaderPage {
  constructor(params?: Partial<SettingHeaderPageData>, menus?: Array<SettingsBaseMenu>) {
    super(params, menus);
    if (!(params?.style)) {
      this.style = settingHeaderPageStyle;
    }
  }
}
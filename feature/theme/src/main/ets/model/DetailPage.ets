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

import { PushParam } from '@ohos/settings.common/src/main/ets/core/controller/Controller';
import { SettingHeaderPage } from './SettingHeaderPage';

/**
 * 主题详情页数据
 */
export class DetailPage extends SettingHeaderPage {
  private static readonly DETAIL_PAGE_URL: string = 'pages/theme/ThemeDetailPage';
  constructor(_pathInfos: NavPathStack, param: PushParam) {
    super({
      pageUrl: DetailPage.DETAIL_PAGE_URL,
      isNavigation: false,
    });
    this.addMenus([]);
  }
}
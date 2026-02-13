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
import { SettingHeaderPage } from '@ohos/settings.uikit/src/main/ets/component/SettingHeaderPage';
import { PageUrl } from '../../PageUrl';

/**
 * 显示大小界面page
 *
 * @since 2023-08-21
 */
export class ScreenZoomPage extends SettingHeaderPage {
  constructor() {
    super({
      pageUrl: PageUrl.SCREEN_ZOOM_PAGE_URL,
      isNavigation: false,
    });
    this.addMenus([]);
  }
}
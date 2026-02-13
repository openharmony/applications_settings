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

import { Controller, MenuController, SettingsBaseMenu } from '@ohos/settings.common/index';

/**
 * 关于本机页面OUC卡片控制器
 *
 * @since 2024-03-29
 */
export class OucAboutDeviceController extends MenuController {
  public tag: string = 'OucAboutDeviceController : ';

  /**
   * 创建软件更新控制器
   *
   * @param menu 软件更新菜单
   * @return 软件更新控制器
   */
  static CreateController(menu: SettingsBaseMenu): Controller {
    return new OucAboutDeviceController(menu);
  }

  aboutToAppear(): void {
    super.aboutToAppear();
  }
}
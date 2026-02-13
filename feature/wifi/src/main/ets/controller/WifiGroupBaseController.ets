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

import { MenuController } from '@ohos/settings.common/src/main/ets/core/controller/MenuController';
import { extraType, SettingsBaseMenu } from '@ohos/settings.common/src/main/ets/core/model/menu/SettingsMenu';
import { LogUtil } from '@ohos/settings.common/src/main/ets/utils/LogUtil';
/* instrument ignore file */
import { Controller } from '@ohos/settings.common/src/main/ets/core/controller/Controller';

/**
 * wifi group base controller
 * @since 2023-09-25
 */
export class WifiGroupBaseController extends MenuController {
  static CreateWifiGroupBaseController(menu: SettingsBaseMenu): Controller {
    return new WifiGroupBaseController(menu);
  }

  public tag: string = 'WifiGroupBaseController : ';
  public listenMenuKey: string;

  constructor(menu: SettingsBaseMenu) {
    super(menu);
    if (!this.menu?.extra) {
      LogUtil.info(`${this.tag} router params apConfig is invalid`);
    }

    this.listenMenuKey = (this.menu.extra as extraType)?.listenMenuKey as string;
  }

  onDataChange(fromKey: string): void {
    LogUtil.info(`${this.tag} onDataChange, fromKey: ${fromKey}`);
    this.refreshUi();
  }

  protected registerDataChange(): void {
    LogUtil.info(`${this.tag} registerDataChange, listenMenuKey: ${this.listenMenuKey}`);
    this.registerControllerDataChange(this.listenMenuKey);
  }

  protected unRegisterDataChange(): void {
    LogUtil.info(`${this.tag} unRegisterDataChange, listenMenuKey: ${this.listenMenuKey}`);
    this.unRegisterControllerDataChange(this.listenMenuKey);
  }
}
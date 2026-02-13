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

import { LogUtil } from '@ohos/settings.common/src/main/ets/utils/LogUtil';
import { NavEntryKey } from '@ohos/settings.common/src/main/ets/utils/Consts';
import { ConfigurationMenuManager } from '../ConfigurationMenuManager';
import { ConfigurationBaseController } from './ConfigurationBaseController';
/* instrument ignore file */
import { NavigationEntry } from '../../menus/Menu';

/**
 * 配置文件中解析json生成界面控制器
 *
 * @since 2023-08-21
 */
export class ConfigurationEntryController extends ConfigurationBaseController {
  public tag: string = 'ConfigurationEntryController : ';

  aboutToAppear(): void {
    LogUtil.info(`${this.tag} aboutToAppear`);
    if (this.menu instanceof NavigationEntry && this.isVisibleStatus()) {
      ConfigurationMenuManager.getInstance()
        .parseJson(this.getSettingsDataByProperty(this.settingProperty as string) as string);
      ConfigurationMenuManager.getInstance().loadPageResource();
    }
    super.aboutToAppear();
  }

  aboutToDisappear() {
    LogUtil.info(`${this.tag} aboutToDisappear`);
    super.aboutToDisappear();
    ConfigurationMenuManager.getInstance().reset();
  }

  onPageDestroy(): void {
    super.onPageDestroy();
  }

  onMenuClick(): boolean {
    LogUtil.info(`${this.tag} onMenuClick`);
    this.menu.pushName(NavEntryKey.CONFIGURATION_OPTION_ENTRY, undefined);
    return true;
  }
}

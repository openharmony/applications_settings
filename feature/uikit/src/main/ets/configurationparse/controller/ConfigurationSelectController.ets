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
import { LogUtil } from '@ohos/settings.common/src/main/ets/utils/LogUtil';
import { Controller } from '@ohos/settings.common/src/main/ets/core/controller/Controller';
import { SettingsDataUtils } from '@ohos/settings.common/src/main/ets/utils/SettingsDataUtils';
import { ConfigurationBaseController } from './ConfigurationBaseController';
import { SelectEntryMenu } from '../../menus/Menu';
/* instrument ignore file */
const TAG: string = 'ConfigurationSelectController : ';

/**
 * 配置文件解析--选择菜单控制器
 *
 * @since 2023-08-21
 */
export default class ConfigurationSelectController extends ConfigurationBaseController {
  private selectValueList: Array<string> = [];

  static CreateConfigurationSelectController(menu: SettingsBaseMenu): Controller {
    return new ConfigurationSelectController(menu);
  }

  aboutToAppear() {
    if ((this.menu instanceof SelectEntryMenu) && this.menu.selectList != null) {
      for (let key of Object.keys(this.menu.selectList)) {
        this.selectValueList.push(this.menu.selectList[key].value.toString())
      }
    }
    super.aboutToAppear();
  }

  public updateStatus(): void {
    if (!this.settingProperty) {
      LogUtil.error(`${TAG} settingProperty is null.`);
      return;
    }
    if (!(this.menu instanceof SelectEntryMenu)) {
      LogUtil.error(`${TAG} menu is not select menu type.`);
      return;
    }
    let index = Number(this.getSettingsDataByProperty(this.settingProperty));
    if (index >= this.selectValueList.length) {
      LogUtil.error(`${TAG} the index ${index} is error.`);
      return;
    }
    let value: string = this.selectValueList[index];
    this.isRefreshUi(value, index);
  }

  public isRefreshUi(content: string, index: number): void {
    if (!(this.menu instanceof SelectEntryMenu)) {
      LogUtil.error(`${TAG} menu is not select menu type.`);
      return;
    }
    LogUtil.info(`${TAG} content is ${content}, the menu value is ${this.menu.value}.`);
    if (this.menu.value !== content) {
      this.menu.selected = index;
      this.menu.value = content;
      this.refreshUi();
    }
  }

  /**
   * 数据库监听回调
   */
  public onDataChange = () => {
    this.updateStatus();
  }

  /**
   * 响应选择事件
   */
  public onSelectClick(index: number) {
    if (!this.settingProperty || !this.selectValueList) {
      LogUtil.error(`${TAG} settingProperty or selectValueList is null.`);
      return false;
    }
    LogUtil.info(`${TAG} onSelectClick , the index is ${index}.`);
    SettingsDataUtils.setSettingsData(this.settingProperty, index.toString());
    if (!(this.menu instanceof SelectEntryMenu)) {
      LogUtil.error(`${TAG} menu is not select menu type.`);
      return;
    }
    this.menu.selected = index;
    this.menu.value = this.selectValueList[index];
    this.refreshUi();
    return;
  }

  public onClick(event: ClickEvent): void {
  }

  public onKeyEvent(event: KeyEvent): void {
    LogUtil.info(`${TAG} onKeyEvent.`);
  }
}


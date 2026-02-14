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

import { MenuGroup } from '../core/model/menu/SettingsMenu';
import { SystemParamUtil } from '../utils/SystemParamUtil';
import { PreferencesUtil } from '../utils/PreferencesUtil';
import { LogUtil } from '../utils/LogUtil';
import {
  notifyCompStateChange,
  SettingStateType,
  SettingCompState
} from '../framework/model/SettingStateModel';

const DISABLE_FALSE: string = 'false';
const TAG: string = 'MdmDisable';

export default class MdmDisable {
  private disable: boolean = false;
  private systemParamKey: string = '';
  private systemParamValue?: boolean;
  private items: string[] = [];
  private notifyItems?: string[];
  private timestamp: number = Date.now();

  constructor(systemParamKey: string, items: string[], notifyItems?: string[]) {
    this.systemParamKey = systemParamKey;
    this.items = items;
    this.notifyItems = notifyItems;
    this.updateDisableValue();
  }

  private updateDisableValue(): void {
    this.disable = SystemParamUtil.getParam(this.systemParamKey, DISABLE_FALSE) !== DISABLE_FALSE;
    LogUtil.info(`${TAG} ${this.systemParamKey}: ${this.disable}`);
  }

  public getDisable(): boolean {
    this.updateDisableValue();
    return this.disable;
  }

  public getTimestamp(): number {
    return this.timestamp;
  }

  public getItems(): string[] {
    return this.items;
  }

  /**
   * 刷新菜单禁用状态
   *
   * @param menuGroup 菜单组
   */
  public refreshMenuDisable(menuGroup: MenuGroup): void {
    this.items.forEach((item) => {
      const menu = menuGroup.findMenu(item);
      if (menu) {
        menu.isGrayed = this.disable;
        menu.opacity = undefined;
        menu.pressedColor = undefined;
        menu.refreshUi();
      }
    });
  }

  /**
   * 通知菜单是否禁用
   */
  public notifyMenuDisable(): void {
    if (!this.notifyItems) {
      return;
    }
    this.notifyItems.forEach((item) => {
      notifyCompStateChange(item, new Map<SettingStateType, SettingCompState>([[
        SettingStateType.STATE_TYPE_ITEM_ENABLED, { state: !this.disable } as SettingCompState
      ]]));
    });
  }

  /**
   * 禁用菜单项
   *
   * @returns 状态是否改变
   */
  public disableItems(): boolean {
    this.updateDisableValue();
    if (this.systemParamValue === undefined) {
      this.systemParamValue = PreferencesUtil.getSync(this.systemParamKey, false) as boolean;
    }
    if (this.systemParamValue === this.disable) {
      return false;
    }
    this.timestamp = Date.now();
    PreferencesUtil.putSync(this.systemParamKey, this.disable);
    this.systemParamValue = this.disable;
    LogUtil.info(`${TAG} disableItems`);
    this.items.forEach((item) => {
      PreferencesUtil.putSync(item, this.disable);
    });
    return true;
  }
}
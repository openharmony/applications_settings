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

import configPolicy from '@ohos.configPolicy';
import fs from '@ohos.file.fs';
import { CheckEmptyUtils } from '../utils/CheckEmptyUtils';
import { LogUtil } from '../utils/LogUtil';

const TAG = 'CustomMenuManager';

/**
 * 定制菜单管理类
 *
 * @since 2023-11-01
 */
export class CustomMenuManager {
  private ccmPage: string = 'etc/settings/hide_menu.json';
  private hideMenus: Set<string> = new Set();

  /**
   * 获取单例
   *
   * @returns CustomMenuController 单例对象
   */
  static getInstance(): CustomMenuManager {
    if (!Boolean(AppStorage.get<CustomMenuManager>('CustomMenuManager') as CustomMenuManager).valueOf()) {
      AppStorage.setOrCreate<CustomMenuManager>('CustomMenuManager', new CustomMenuManager());
    }
    return AppStorage.get<CustomMenuManager>('CustomMenuManager') as CustomMenuManager;
  }

  /**
   * 是否是隐藏菜单
   *
   * @returns true：是 false：不是
   */
  public isMenuHide(menuKey: string | undefined): boolean {
    if (this.isEmpty() || menuKey === undefined) {
      return false;
    }
    return this.hideMenus.has(menuKey);
  }

  /**
   * 隐藏菜单是否为空
   *
   * @returns true：是 false：不是
   */
  public isEmpty(): boolean {
    return this.hideMenus.size === 0;
  }

  /**
   * 加载配置
   *
   * @param context Context
   */
  public async loadCcmConfigs(): Promise<void> {
    LogUtil.info(`${TAG} loadCcmConfigs`);
    let configStr = await this.getConfigStr(this.ccmPage);
    if (configStr) {
      let hideMenuList: HideMenu[] = JSON.parse(configStr);
      LogUtil.debug(`${TAG} hideMenus`);
      hideMenuList.forEach(hideMenu => {
        if (CheckEmptyUtils.isEmptyArr(hideMenu.itemName)) {
          this.hideMenus.add(hideMenu.key);
        }
      });
    }
    LogUtil.info(`${TAG} loadCcmConfigs, size: ${this.hideMenus.size}`);
  }

  async getConfigStr(relativePath: string): Promise<string> {
    try {
      let filePath: string = await configPolicy.getOneCfgFile(relativePath);
      return fs.readTextSync(filePath);
    } catch (e) {
      LogUtil.error(`${TAG} loadCcmConfigs exception:${e?.code}  ${e?.message}`);
    }
    return '';
  }

  getHideMenus(): Set<string> {
    return this.hideMenus;
  }
}

/**
 * 隐藏菜单
 */
interface HideMenu {
  key: string;
  desc: string;
  itemName: string[];
}

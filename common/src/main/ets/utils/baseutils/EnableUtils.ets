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

import { MenuPage, SettingsBaseMenu } from '../../core/model/menu/SettingsMenu';
import { DeviceUtil } from '../BaseUtils';
import { PC_SETTING_HOME_MENU_KEYS, PHONE_SETTING_HOME_MENU_KEYS } from '../Consts';
import { LogUtil } from '../LogUtil';
import { PreferencesUtil } from '../PreferencesUtil';

const TAG: string = 'EnableUtils';

export class EnableUtils {
  private static disableItemSet: Set<string> = new Set();

  static disableItemName(key?: string): boolean {
    if (PreferencesUtil.hasSync(key as string)) {
      let enable: boolean = PreferencesUtil.getSync(key as string, true) as boolean;
      LogUtil.showInfo(TAG, `disableItem, key : ${key}, enable: ${enable}`);
      return enable;
    }
    return true;
  }

  static async setItemEnable(menuPage?: MenuPage): Promise<void> {
    LogUtil.info(`${TAG} setItemEnable`);
    let defaultItems: string[] = [];
    let items: string[] = PreferencesUtil.getSync('disableItems', defaultItems) as string[];
    for (let index = 0; index < items.length; index++) {
      if (menuPage) {
        let menu: SettingsBaseMenu | null = menuPage.findMenu(items[index]);
        if (menu) {
          let isGrayed: boolean = PreferencesUtil.getSync(items[index] as string, true) as boolean;
          LogUtil.showInfo(TAG, `item: ${items[index]}, isGrayed: ${isGrayed} ,menu: ${menu.key}`);
          menu.isGrayed = isGrayed;
          menu.refreshUi();
        }
      }
    }
  }

  static getHomePageDisableItems(): Set<string> {
    let homeMenuKeys = DeviceUtil.isDevicePc() ? PC_SETTING_HOME_MENU_KEYS : PHONE_SETTING_HOME_MENU_KEYS;
    if (EnableUtils.disableItemSet.size > 0) {
      LogUtil.showInfo(TAG, `num: ${EnableUtils.disableItemSet.size}`);
      return EnableUtils.disableItemSet;
    }
    let defaultItems: string[] = [];
    let items: string[] = PreferencesUtil.getSync('disableItems', defaultItems) as string[];
    for (let index = 0; index < items.length; index++) {
      if (homeMenuKeys.has(items[index])) {
        let isGrayed: boolean = PreferencesUtil.getSync(items[index] as string, true) as boolean;
        LogUtil.showInfo(TAG, `item: ${items[index]}, isGrayed: ${isGrayed}`);
        if (isGrayed) {
          LogUtil.showInfo(TAG, `disableItemSet add item: ${items[index]}`);
          EnableUtils.disableItemSet.add(items[index]);
        }
        if (EnableUtils.disableItemSet.has(items[index]) && !isGrayed) {
          LogUtil.showInfo(TAG, `disableItemSet delete item: ${items[index]}`);
          EnableUtils.disableItemSet.delete(items[index]);
        }
      }
    }
    return EnableUtils.disableItemSet;
  }
}
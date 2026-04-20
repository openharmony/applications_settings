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

import { GroupType, SettingGroupModel } from '../model/SettingGroupModel';
import {
  ItemDetailType,
  ItemResultType,
  ItemType,
  SettingIconModel,
  SettingItemDetailModel,
  SettingItemModel,
  SettingItemResultModel,
  SettingTextModel,
  SettingToggleModel,
} from '../model/SettingItemModel';
import { PageType, SettingPageModel } from '../model/SettingPageModel';
import { SettingTabsModel } from '../model/SettingTabsModel';
import { DataVerify } from './DataVerify';
import { LogHelper } from './LogHelper';

const TAG: string = 'PageConfigVerify';

export class PageConfigVerify {
  private static checkSettingTextVaild(text?: SettingTextModel): boolean {
    if (text?.textType && text.style) {
      return false;
    }
    return true;
  }

  private static checkSettingIconVaild(icon?: SettingIconModel): boolean {
    if (icon === undefined) {
      return true;
    }
    return icon.icon !== undefined;
  }

  private static checkSettingResultVaild(result: SettingItemResultModel, item: SettingItemModel): boolean {
    switch (result.type) {
      case ItemResultType.RESULT_TYPE_CUSTOM:
        return result.builder !== undefined;
      case ItemResultType.RESULT_TYPE_TEXT:
        return PageConfigVerify.checkSettingTextVaild(result.result as SettingTextModel);
      case ItemResultType.RESULT_TYPE_IMAGE:
        return PageConfigVerify.checkSettingIconVaild(result.result as SettingIconModel);
      case ItemResultType.RESULT_TYPE_TOGGLE:
        return (result.result as SettingToggleModel)?.state !== undefined;
      case ItemResultType.RESULT_TYPE_RADIO:
        return item.detail === undefined;
      case ItemResultType.RESULT_TYPE_CHECKBOX:
        return item.detail === undefined;
      default:
        return false;
    }
  }

  private static checkSettingDetailVaild(detail: SettingItemDetailModel, item: SettingItemModel): boolean {
    switch (detail.type) {
      case ItemDetailType.DETAIL_TYPE_CUSTOM:
        return detail.onItemClick !== undefined;
      case ItemDetailType.DETAIL_TYPE_NAVIGATE:
        return DataVerify.checkStr(detail.destination);
      case ItemDetailType.DETAIL_TYPE_DIALOG:
        return detail.dialog !== undefined;
      case ItemDetailType.DETAIL_TYPE_MENU:
        return detail.menu !== undefined && detail.menu.items.length > 0;
      case ItemDetailType.DETAIL_TYPE_MODAL:
        return DataVerify.checkStr(detail.destination) || detail.sheetBuilder !== undefined;
      default:
        LogHelper.error(TAG, `invaild detail type, item id: ${item.id}`);
        return false;
    }
  }

  private static checkSettingStandardItem(item: SettingItemModel): boolean {
    if (!item.title) {
      LogHelper.error(TAG, `invaild standard item config without title, item id: ${item.id}`);
      return false
    }

    if (!PageConfigVerify.checkSettingTextVaild(item.title)) {
      LogHelper.error(TAG, `no need to config title type and style at the same time, item id: ${item.id}`);
      return false;
    }

    if (!PageConfigVerify.checkSettingTextVaild(item.desc)) {
      LogHelper.error(TAG, `no need to config desp type and style at the same time, item id: ${item.id}`);
      return false;
    }

    if (!PageConfigVerify.checkSettingIconVaild(item.icon)) {
      LogHelper.error(TAG, `invaild icon config, icon undefined, item id: ${item.id}`);
      return false;
    }

    if (item.result && !PageConfigVerify.checkSettingResultVaild(item.result, item)) {
      LogHelper.error(TAG, `invaild result config, item id: ${item.id}`);
      return false;
    }

    if (item.detail && !PageConfigVerify.checkSettingDetailVaild(item.detail, item)) {
      LogHelper.error(TAG, `invaild detail config, item id: ${item.id}`);
      return false;
    }
    return true;
  }

  public static checkSettingItemVaild(item: SettingItemModel): boolean {
    if (!item || !DataVerify.checkStr(item.id)) {
      return false;
    }

    switch (item.type) {
      case ItemType.ITEM_TYPE_CUSTOM:
        if (!item.builder) {
          LogHelper.error(TAG, `invaild custom item without builder, item id: ${item.id}`);
        }
        return item.builder !== undefined;

      case ItemType.ITEM_TYPE_STANDARD:
        return PageConfigVerify.checkSettingStandardItem(item);

      case ItemType.ITEM_TYPE_INPUT:
      case ItemType.ITEM_TYPE_PROGRESS:
        LogHelper.error(TAG, `unsupport item type, coming soon, item id: ${item.id}`);
        return false

      default:
        LogHelper.error(TAG, `invaild config item type: ${item.type}, item id: ${item.id}`);
        return false;
    }
  }

  private static checkSettingItemsVaild(items?: SettingItemModel[]): boolean {
    if (!items || items.length <= 0) {
      LogHelper.error(TAG, 'invaild items config without item');
      return false;
    }

    for (let index = 0; index < items.length; index++) {
      const item = items[index];
      if (!item || !PageConfigVerify.checkSettingItemVaild(item)) {
        return false;
      }
    }
    return true;
  }

  public static checkSettingGroupVaild(group: SettingGroupModel, fixed?: boolean): boolean {
    if (!group || !DataVerify.checkStr(group.id)) {
      return false;
    }

    if (fixed && group.type !== GroupType.GROUP_TYPE_STANDARD) {
      LogHelper.error(TAG, `invaild fixed group config with group type, group id: ${group.id}`);
      return false;
    }

    if (group.layout?.margin && !group.layout?.margin?.top) {
      LogHelper.error(TAG, `invaild group margin config without top align, group id: ${group.id}`);
      return false;
    }

    switch (group.type) {
      case GroupType.GROUP_TYPE_CUSTOM:
        if (!group.builder) {
          LogHelper.error(TAG, `invaild custom group config, group id: ${group.id}`);
          return false;
        }
        break;

      case GroupType.GROUP_TYPE_STANDARD:
        if (!PageConfigVerify.checkSettingItemsVaild(group.items)) {
          return false;
        }
        break;

      case GroupType.GROUP_TYPE_DYNAMIC:
      case GroupType.GROUP_TYPE_DYNAMIC_LAZY:
      case GroupType.GROUP_TYPE_DYNAMIC_LAZY_SHRINK:
        if (group.items) {
          LogHelper.error(TAG, `invaild dynamic group config with items, group id: ${group.id}`);
          return false;
        }
        break;

      default:
        LogHelper.error(TAG, `invaild config group type: ${group.type}, group id: ${group.id}`);
        return false;
    }

    return true;
  }

  private static checkSettingGroupsVaild(groups?: SettingGroupModel[], fixed?: boolean): boolean {
    if (!groups || groups.length <= 0) {
      LogHelper.error(TAG, 'invaild page groups without group');
      return false;
    }

    for (let index = 0; index < groups.length; index++) {
      const group = groups[index];
      if (!group || !PageConfigVerify.checkSettingGroupVaild(group, fixed)) {
        LogHelper.error(TAG, `invaild page groups, group id: ${group.id}`);
        return false;
      }
    }
    return true;
  }

  private static checkSettingTabsVaild(tabs?: SettingTabsModel[]): boolean {
    if (!tabs || tabs.length === 0) {
      LogHelper.error(TAG, 'invaild page tabs without group');
      return false;
    }

    for (let index = 0; index < tabs.length; index++) {
      const tab = tabs[index];
      if (!tab || !PageConfigVerify.checkSettingGroupsVaild(tab.groups)) {
        LogHelper.error(TAG, `invaild page tabs, tab id: ${tab.id}`);
        return false;
      }
    }
    return true;
  }

  // 配置合法性校验
  public static checkSettingPageVaild(page: SettingPageModel): boolean {
    // base check
    if (!page || !DataVerify.checkStr(page.id) || !DataVerify.checkStr(page.url)) {
      LogHelper.error(TAG, `invaild page config without necessary information, page url: ${page.url}`);
      return false;
    }

    // custom check
    if (page.type === PageType.PAGE_TYPE_CUSTOM) {
      if (!page.builder) {
        LogHelper.error(TAG, `invaild custom page config without builder, page url: ${page.url}`);
        return false;
      }
      return true;
    }

    // dynamic check
    if (page.type === PageType.PAGE_TYPE_DYNAMIC) {
      return true;
    }

    // groups check
    if (!PageConfigVerify.checkSettingGroupsVaild(page.groups) &&
        !PageConfigVerify.checkSettingGroupsVaild(page.fixedGroups, true) &&
        !PageConfigVerify.checkSettingTabsVaild(page.tabs)) {
      LogHelper.error(TAG, `invaild page with invaild groups, page url: ${page.url}`);
      return false;
    }

    return true;
  }
}
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

import { Constants } from '@ohos/settings.common/src/main/ets/constant/PackagesConstant';
import { CustomMenuManager } from '@ohos/settings.common/src/main/ets/custom/CustomMenuManager';
import SettingPageDescManager from '@ohos/settings.common/src/main/ets/data/SettingPageDescManager';
import { CheckEmptyUtils } from '@ohos/settings.common/src/main/ets/utils/CheckEmptyUtils';
import { HiSysEventUtil } from '@ohos/settings.common/src/main/ets/systemEvent/HiSysEventUtil';
import { LogUtil } from '@ohos/settings.common/src/main/ets/utils/LogUtil';
import { PreferencesUtil } from '@ohos/settings.common/src/main/ets/utils/PreferencesUtil';
import { StringUtil } from '@ohos/settings.common/src/main/ets/utils/StringUtil';
import { PageInfo, PageInfoConfig } from '../model/PageInfoConfig';
import { SearchConfigFileParser } from '../util/SearchConfigFileParser';

const TAG: string = 'SettingPageDescController';
const pageInfoConfigPath: string = 'searchConfig/pageInfo.json';

export class SettingPageDescController {
  public static pageInfoCache: Map<string, PageInfo> = new Map();
  private static isDataUpdating: boolean = false;

  public static initPageInfoTable(): void {
    LogUtil.info(`${TAG} initPageInfoTable`);
    SettingPageDescManager.getRdbStore();
  }

  /**
   * 清空搜索PageInfo数据
   * @returns
   */
  static async deletePageInfoData(): Promise<void> {
    LogUtil.info(`${TAG} start delete SearchData`);
    if (await PreferencesUtil.has(`ClearPageInfoTable${Constants.PAGEINFO_TABLE_VERSION}`)) {
      LogUtil.info(`${TAG} ClearPageInfoTable has done`);
      return;
    }
    await SettingPageDescManager.clearPageInfoData();
    await PreferencesUtil.put(`ClearPageInfoTable${Constants.PAGEINFO_TABLE_VERSION}`, 'done');
  }

  /**
   * 初始化设置页描述信息到数据库
   * @returns
   */
  static async initPageInfoData(): Promise<void> {
    LogUtil.info(`${TAG} start init PageInfoData to DataBase. initPageInfoData`);
    if (await PreferencesUtil.has(`PageInfoDesc${Constants.PAGEINFO_TABLE_VERSION}`)) {
      LogUtil.info(`${TAG} PageInfoDesc${Constants.PAGEINFO_TABLE_VERSION} has done`);
      return;
    }

    if (SettingPageDescController.isDataUpdating) {
      LogUtil.info(`${TAG} PageInfoDesc is updating`);
      return;
    }

    SettingPageDescController.isDataUpdating = true;
    await SettingPageDescManager.clearPageInfoData();
    let pageInfoConfig: PageInfoConfig | undefined =
      await SearchConfigFileParser.getInstance().parserPageInfoConfig(pageInfoConfigPath);
    LogUtil.info(`${TAG}  pageInfoConfig content`);
    if (pageInfoConfig) {
      try {
        let pageInfos = pageInfoConfig.pageInfos;
        LogUtil.info(`${TAG} getPageInfo Size: ${pageInfos.length}`);
        if (pageInfos.length > 0) {
          await SettingPageDescManager.batchInsertPageInfoData(pageInfos);
        }
        HiSysEventUtil.searchReportEvent(TAG, `initPageInfoData success`);
      } catch (error) {
        LogUtil.error(`${TAG} pars error ${error}`);
        HiSysEventUtil.searchReportEvent(TAG, `pars error ${error}`);
      }
    } else {
      LogUtil.warn(`${TAG} parse ${pageInfoConfigPath} not find`);
      HiSysEventUtil.searchReportEvent(TAG, `parse ${pageInfoConfigPath} not find`);
    }
    await PreferencesUtil.put(`PageInfoDesc${Constants.PAGEINFO_TABLE_VERSION}`, 'done');
    SettingPageDescController.isDataUpdating = false;
  }

  /**
   * 配置文件是否有该页面
   *
   * @param entryKey 页面的key值
   * @returns true 存在, false不存在
   */
  public static async isPageExistInConfig(entryKey: string): Promise<boolean> {
    let pageInfo = await SettingPageDescController.getPageInfo(entryKey);
    return pageInfo !== undefined;
  }

  static async getParentPage(entryKey: string, entryKeyList: Array<string>): Promise<void> {
    let pageInfo = await SettingPageDescController.getPageInfo(entryKey);
    if (pageInfo === undefined) {
      return;
    }
    if (StringUtil.isNotEmpty(pageInfo.entryKey)) {
      if (!pageInfo.isVisible) {
        entryKeyList.splice(0, entryKeyList.length);
        return;
      }
      entryKeyList.push(pageInfo.entryKey);
    }
    if (StringUtil.isNotEmpty(pageInfo.parentKey)) {
      await SettingPageDescController.getParentPage(pageInfo.parentKey, entryKeyList);
    }
  }

  static async getTopLevelEntryKey(entryKey: string): Promise<string> {
    if (CheckEmptyUtils.checkStrIsEmpty(entryKey)) {
      return '';
    }

    let pageInfo = await SettingPageDescController.getPageInfo(entryKey);
    if (pageInfo === undefined) {
      return '';
    }

    let parentEntry = pageInfo.parentKey;
    while (!CheckEmptyUtils.checkStrIsEmpty(parentEntry)) {
      pageInfo = await SettingPageDescController.getPageInfo(parentEntry);
      if (pageInfo === undefined) {
        return parentEntry;
      }
      parentEntry = pageInfo.parentKey;
    }
    return pageInfo.entryKey;
  }

  private static async getPageInfo(entryKey: string): Promise<PageInfo | undefined> {
    if (StringUtil.isEmpty(entryKey)) {
      return undefined;
    }
    if (SettingPageDescController.pageInfoCache.size === 0) {
      await SettingPageDescController.getPageInfoFromJson();
      LogUtil.info(`${TAG} pageInfoConfig pageLength: ${SettingPageDescController.pageInfoCache.size}`);
    }
    return SettingPageDescController.pageInfoCache.get(entryKey);
  }

  private static async getPageInfoFromJson(): Promise<void> {
    let pageInfoConfig: PageInfoConfig | undefined = await SearchConfigFileParser.getInstance()
      .parserPageInfoConfig(pageInfoConfigPath);
    if (pageInfoConfig) {
      let pageInfoList = pageInfoConfig.pageInfos;
      if (pageInfoList.length > 0) {
        SettingPageDescController.changePageVisibility(pageInfoList);
        SettingPageDescController.pageInfoCache.clear();
        pageInfoList.forEach(item => SettingPageDescController.pageInfoCache.set(item.entryKey, item));
      }
    }
  }

  private static changePageVisibility(pageInfoList: Array<PageInfo>): void {
    if (pageInfoList === undefined || pageInfoList.length === 0) {
      return;
    }
    if (CustomMenuManager.getInstance().isEmpty()) {
      return;
    }
    pageInfoList.map(page => {
      if (CustomMenuManager.getInstance().isMenuHide(page.entryKey)) {
        page.isVisible = false;
      }
    })
  }
}
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

import { CheckEmptyUtils } from '@ohos/settings.common/src/main/ets/utils/CheckEmptyUtils';
import { LogUtil } from '@ohos/settings.common/src/main/ets/utils/LogUtil';
import { SearchDataController } from '@ohos/settings.search/src/main/ets/controller/SearchController';
import { RenderItemInfo, SearchHistory } from '@ohos/settings.search/src/main/ets/model/type';
import lazy { SearchHistoryController } from '@ohos/settings.search/src/main/ets/controller/SearchHistoryController';
import { queryMetaService } from '@ohos/settings.application/src/main/ets/util/AppManager';

const TAG = 'SearchSettingsController:';

/**
 * 设置搜索控制类
 */
export class SearchSettingsController {
  // 获取历史记录
  public getHistoryData(): Promise<SearchHistory[]> {
    LogUtil.info(`${TAG} getHistoryData`);
    return SearchHistoryController.getSearchData();
  }

  // 保存历史记录
  public saveHistoryData(value: string): void {
    LogUtil.info(`${TAG} saveHistoryData ${value}`);
    if (CheckEmptyUtils.checkStrIsEmpty(value)) {
      LogUtil.showWarn(TAG, 'saveHistoryData value is empty');
      return;
    }
    SearchHistoryController.addSearchData({
      query: value.trim(),
      timestamp: new Date().getTime()
    });
  }

  // 清空历史记录
  public delHistoryData(): void {
    LogUtil.info(`${TAG} delHistoryData`);
    SearchHistoryController.deleteSearchData();
  }

  // 搜索设置
  public getSettingsData(value: string): Promise<RenderItemInfo[]> {
    LogUtil.info(`${TAG} getSettingsData`);
    return SearchDataController.getInstance().getSearchResult(value, queryMetaService);
  }

  // 搜索防抖
  public async inputChangeEvent(input: string, type: string): Promise<RenderItemInfo[]> {
    if (input.trim().length === 0) {
      return [];
    }
    // onSubmit & 查询到数据，再保存到历史记录
    let resultList = await this.getSettingsData(input)
    if (resultList.length > 0 && type === 'onSubmit') {
      this.saveHistoryData(input);
    }
    return resultList;
  }
}

export interface HistoryDataDto {
  query: string,
  timestamp: number,
}
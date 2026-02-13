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

import { JSON } from '@kit.ArkTS';
import i18n from '@ohos.i18n';
import { SearchItemOperationManager, SearchItemInfoManager } from '@ohos/settings.common/src/main/ets/data';
import { CheckEmptyUtils } from '@ohos/settings.common/src/main/ets/utils/CheckEmptyUtils';
import { LogUtil } from '@ohos/settings.common/src/main/ets/utils/LogUtil';
import { Response } from '@ohos/settings.common/src/main/ets/constant/Response';
import { IExecutor } from '@ohos/settings.common/src/main/ets/stub/BaseServiceStub';
import { ItemInfo, OperationStatus, SearchItemOperation } from '@ohos/settings.common/src/main/ets/data/types';
import { UpdateSearchItemsModel } from '../model/UpdateSearchItemsModel';
import { SearchCheckUtil } from '../util/SearchCheckUtil';
/* instrument ignore file */
const TAG: string = 'UpdateSearchItems';

/**
 * 新增搜索配置项
 * 1、配置中不存在 新增历史记录表和配置表
 * 2、配置中存在 写入到历史记录表和更新配置表
 */
class SearchItemsAdd implements IExecutor {
  /**
   * 调用者的包名
   */
  private optBundleName: string;

  constructor(bundleName: string) {
    this.optBundleName = bundleName;
  }

  async execute(extra?: object): Promise<string> {
    LogUtil.showInfo(TAG, `execute: add search items: start`);
    let searchItems: UpdateSearchItemsModel = extra as UpdateSearchItemsModel;
    // 新增搜索项的记录
    for (let item of searchItems.itemList) {
      let value: SearchItemOperation = item as SearchItemOperation;
      value.content = (value.enable) == true ? '1' : '0';
      value.timestamp = Date.now();
      value.status = OperationStatus.ADD;
      value.locale = value.locale ?? i18n.System.getSystemLocale();
      value.optBundleName = this.optBundleName;
      value.businessId = searchItems.businessId;
      value.bundleName = value.bundleName ? value.bundleName : searchItems.bundleName;
      await SearchItemOperationManager.insertSearchOperationData(value);
      await SearchItemInfoManager.insertOrUpdateSearchItemData(value);
    }
    LogUtil.showInfo(TAG, `execute: add search items: end`);
    return Response.SUCCESS;
  }
}

/**
 * 修改搜索项
 */
class SearchItemsModify implements IExecutor {
  /**
   * 调用者的包名
   */
  private optBundleName: string;

  constructor(bundleName: string) {
    this.optBundleName = bundleName;
  }

  async execute(extra?: object): Promise<string> {
    let searchItems: UpdateSearchItemsModel = extra as UpdateSearchItemsModel;
    let itemNameList: string[] = searchItems.itemList.map((item) => (item as SearchItemOperation).itemName);
    let searchItemInfo: ItemInfo[] =
      await SearchItemInfoManager.querySearchItemData(itemNameList, searchItems.bundleName);
    LogUtil.showInfo(TAG, `execute: update search items: ${searchItemInfo.length}`);
    // 新增/修改搜索项，和操作历史记录
    for (let item of searchItems.itemList) {
      let value: SearchItemOperation = item as SearchItemOperation;
      LogUtil.showInfo(TAG, `execute: update search items: ${value.enable}`);
      value.optBundleName = this.optBundleName;
      value.content = (value.enable) == true ? '1' : '0';
      value.timestamp = Date.now();
      value.bundleName = searchItems.bundleName;
      value.status = OperationStatus.UPDATE;
      value.locale = value.locale ?? i18n.System.getSystemLocale();
      value.businessId = searchItems.businessId;
      await SearchItemOperationManager.insertSearchOperationData(value);
      await SearchItemInfoManager.insertOrUpdateSearchItemData(value);
    }

    return Response.SUCCESS;
  }
}

class SearchItemsDelete implements IExecutor {
  /**
   * 调用者的包名
   */
  private optBundleName: string;

  constructor(bundleName: string) {
    this.optBundleName = bundleName;
  }

  async execute(extra?: object): Promise<string> {
    let searchItems: UpdateSearchItemsModel = extra as UpdateSearchItemsModel;
    // 删除配置项, 需要插入一条操作历史记录
    let itemList: string[] = searchItems.itemList.map((item => item as string));
    let searchItemInfo: ItemInfo[] = await SearchItemInfoManager.querySearchItemData(itemList, searchItems.bundleName);
    if (searchItemInfo.length === 0) {
      LogUtil.showWarn(TAG, `operation: delete search items is empty!`);
    }
    for (let item of searchItemInfo) {
      let itemOp: SearchItemOperation = item as SearchItemOperation;
      itemOp.content = '0';
      itemOp.status = OperationStatus.DELETE;
      itemOp.timestamp = Date.now();
      itemOp.businessId = searchItems.businessId;
      itemOp.optBundleName = this.optBundleName;
      await SearchItemOperationManager.insertSearchOperationData(itemOp);
      // 使能状态关闭
      await SearchItemInfoManager.updateSearchItem(item.itemName, false);
    };
    return Response.SUCCESS;
  }
}

class SearchItemsQuery implements IExecutor {
  /**
   * 调用者的包名
   */
  private optBundleName: string | undefined;

  constructor(bundleName: string | undefined) {
    this.optBundleName = bundleName;
  }

  async execute(extra?: object): Promise<string> {
    let searchItems: UpdateSearchItemsModel = extra as UpdateSearchItemsModel;
    // 查询配置项
    let itemList: string[] = searchItems.itemList?.map(item => item as string);
    let searchItemInfo: SearchItemOperation[] =
      await SearchItemOperationManager.querySearchItemOperationData(searchItems.bundleName,
        itemList, searchItems.businessId);
    if (searchItemInfo.length === 0) {
      return Response.FAIL;
    }
    return JSON.stringify(searchItemInfo);
  }
}

export class UpdateSearchItems implements IExecutor {
  private status: OperationStatus;
  /**
   * 调用者的包名
   */
  private optBundleName: string | undefined;

  constructor(status: OperationStatus, bundleName?: string) {
    this.status = status;
    this.optBundleName = bundleName;
  }

  private static readonly executorUpdateMap: Map<OperationStatus, (bundleName: string) => IExecutor> = new Map([
    [OperationStatus.ADD, (bundleName: string): IExecutor => new SearchItemsAdd(bundleName)],
    [OperationStatus.DELETE, (bundleName: string): IExecutor => new SearchItemsDelete(bundleName)],
    [OperationStatus.UPDATE, (bundleName: string): IExecutor => new SearchItemsModify(bundleName)],
    [OperationStatus.QUERY, (bundleName: string): IExecutor => new SearchItemsQuery(bundleName)],
  ]);

  async execute(extra?: object): Promise<string> {
    LogUtil.showInfo(TAG, `operation: ${this.status} search items`);
    if (CheckEmptyUtils.isEmpty(extra)) {
      LogUtil.showError(TAG, `operation: ${this.status} search items fail, item list empty`);
      return Response.FAIL;
    }
    const executor = UpdateSearchItems.executorUpdateMap.get(this.status);
    LogUtil.showInfo(TAG, `execute: method ${this.status}`);
    if (!executor) {
      LogUtil.showError(TAG, `operation: ${this.status} executor is empty!`);
      return Response.FAIL;
    }
    if (this.optBundleName === undefined) {
      LogUtil.showError(TAG, `caller bundleName is undefined!`);
      return Response.FAIL;
    }
    let searchItems: UpdateSearchItemsModel = extra as UpdateSearchItemsModel;
    if (!searchItems) {
      return Response.FAIL;
    }
    if (!SearchCheckUtil.checkPermissions(this.optBundleName, searchItems.bundleName)) {
      LogUtil.showError(TAG,
        `caller bundleName[${this.optBundleName}] can't ${this.status} bundlename[${searchItems.bundleName}] item`);
      return Response.FAIL;
    }

    return await executor(this.optBundleName).execute(extra);
  }
}




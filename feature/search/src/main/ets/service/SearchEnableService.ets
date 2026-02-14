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

import rpc from '@ohos.rpc'
import bundleManager from '@ohos.bundle.bundleManager'
import { LogUtil } from '@ohos/settings.common/src/main/ets/utils/LogUtil';
import { Response } from '@ohos/settings.common/src/main/ets/constant/Response';
import { CallMessage, IExecutor, IService } from '@ohos/settings.common/src/main/ets/stub/BaseServiceStub';
import { OperationStatus } from '@ohos/settings.common/src/main/ets/data/types';
import { EnableSearchItems } from './EnableSearchItems';
import { EnableSearchEntry } from './EnableSearchEntry';
import { UpdateSearchItems } from './UpdateSearchItems';

const TAG: string = 'SearchEnableService';
const SETTINGS_ENABLE_SEARCH_ITEMS: string = 'enableSearchItems';
const SETTINGS_DISABLE_SEARCH_ITEMS: string = 'disableSearchItems';
const SETTINGS_ENABLE_SEARCH_ENTRY: string = 'enableSearchEntry';
const SETTINGS_DISABLE_SEARCH_ENTRY: string = 'disableSearchEntry';
const SETTINGS_ADD_SEARCH_ITEMS: string = 'addSearchItems';
const SETTINGS_DELETE_SEARCH_ITEMS: string = 'deleteSearchItems';
const SETTINGS_UPDATE_SEARCH_ITEMS: string = 'updateSearchItems';
const SETTINGS_QUERY_SEARCH_ITEMS: string = 'querySearchItems';

export class SearchEnableService implements IService {
  private static readonly executorMap: Map<string, (caller?: string) => IExecutor> = new Map([
    [SETTINGS_ENABLE_SEARCH_ITEMS, (): IExecutor => new EnableSearchItems(true)],
    [SETTINGS_DISABLE_SEARCH_ITEMS, (): IExecutor => new EnableSearchItems(false)],
    [SETTINGS_ENABLE_SEARCH_ENTRY, (): IExecutor => new EnableSearchEntry(true)],
    [SETTINGS_DISABLE_SEARCH_ENTRY, (): IExecutor => new EnableSearchEntry(false)],
    [SETTINGS_ADD_SEARCH_ITEMS,
      (caller?: string): IExecutor => new UpdateSearchItems(OperationStatus.ADD, caller)],
    [SETTINGS_DELETE_SEARCH_ITEMS,
      (caller?: string): IExecutor => new UpdateSearchItems(OperationStatus.DELETE, caller)],
    [SETTINGS_UPDATE_SEARCH_ITEMS,
      (caller?: string): IExecutor => new UpdateSearchItems(OperationStatus.UPDATE, caller)],
    [SETTINGS_QUERY_SEARCH_ITEMS,
      (caller?: string): IExecutor => new UpdateSearchItems(OperationStatus.QUERY, caller)],
  ]);

  async onCall(json: string): Promise<string> {
    let message: CallMessage;
    try {
      message = JSON.parse(json) as CallMessage;
    } catch (err) {
      LogUtil.showError(TAG, 'parse input message invalid');
      return Response.UNKNOWN_METHOD;
    }

    const method: string = message?.method;
    LogUtil.showInfo(TAG, `onCall method = ${method}`);
    const executor = SearchEnableService.executorMap.get(method);
    if (!executor) {
      LogUtil.showWarn(TAG, 'onCall invalid method');
      return Response.INVALID_METHOD;
    }
    let bundleName: string = '';
    try {
      let callerUid = rpc.IPCSkeleton.getCallingUid();
      bundleName = await bundleManager.getBundleNameByUid(callerUid);
    } catch (err) {
      LogUtil.showError(TAG, `get bundle name by uid error: ${err?.code} message: ${err?.message}`);
    }
    LogUtil.showInfo(TAG, `onCall bundleName = ${bundleName}`);
    return executor(bundleName)?.execute(message?.extra);
  }
}

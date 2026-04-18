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

import { SearchItemInfoManager } from '@ohos/settings.common/src/main/ets/data';
import { CheckEmptyUtils } from '@ohos/settings.common/src/main/ets/utils/CheckEmptyUtils';
import { LogUtil } from '@ohos/settings.common/src/main/ets/utils/LogUtil';
import { Response } from '@ohos/settings.common/src/main/ets/constant/Response';
import { IExecutor } from '@ohos/settings.common/src/main/ets/stub/BaseServiceStub';
import { SearchItems } from '../model/SearchItems';

const TAG: string = 'EnableSearchEntry';

export class EnableSearchEntry implements IExecutor {
  private isEnableSearch: boolean = true;

  constructor(isEnable: boolean) {
    this.isEnableSearch = isEnable;
  }

  async execute(extra: SearchItems): Promise<string> {
    LogUtil.showInfo(TAG, 'Enable search items');
    let searchItems = extra;
    if (CheckEmptyUtils.isEmpty(searchItems) || CheckEmptyUtils.isEmptyArr(searchItems?.itemList)) {
      LogUtil.showError(TAG, 'Enable search items fail, item list empty');
      return Response.FAIL;
    }

    for (let entryKey of searchItems.itemList) {
      await SearchItemInfoManager.updateSearchEntry(entryKey, this.isEnableSearch);
    }

    return Response.SUCCESS;
  }
}
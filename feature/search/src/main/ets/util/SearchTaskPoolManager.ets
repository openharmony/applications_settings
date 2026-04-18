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

import type common from '@ohos.app.ability.common';
import { intl } from '@kit.LocalizationKit';
import { AbilityContextManager } from '@ohos/settings.common/src/main/ets/ability/AbilityContextManager';
import { LogUtil } from '@ohos/settings.common/src/main/ets/utils/LogUtil';
import { ThreadUtils } from '@ohos/settings.common/src/main/ets/utils/ThreadUtils';
import { SearchDataController } from '../controller/SearchController';
import { SearchResourceManager } from '../controller/SearchResourceManager';
import { ExternalInfo } from '../model/ExternalInfoConfig';
import { HideSearchItemsConfig } from '../model/HideSearchItemsConfig';

@Concurrent
export async function initExternalSearchData(externalInfos: ExternalInfo[],
  curLocale: string, context: common.Context): Promise<void> {
  AbilityContextManager.setSubThreadContext(context);
  LogUtil.info(`initExternalSearchData cur pid ${ThreadUtils.processId}, tid ${ThreadUtils.threadId}`)
  let hideSearchConfig: HideSearchItemsConfig = await SearchDataController.getInstance().getHideSearchConfig();
  let searchResourceManager: SearchResourceManager = new SearchResourceManager(curLocale);
  let collator: intl.Collator = new intl.Collator();
  externalInfos.sort((infoA: ExternalInfo, infoB: ExternalInfo) => {
    return collator.compare(infoA.bundleName, infoB.bundleName);
  });
  let lastBundleName: string = '';
  for (let bundle of externalInfos) {
    LogUtil.info(`initExternalSearchData.bundleName: ${bundle.bundleName}`);
    if (bundle.bundleName !== lastBundleName) {
      searchResourceManager.removeExternalResourceManager(lastBundleName);
      lastBundleName = bundle.bundleName;
    }
    await SearchDataController.processExternalItemInfoList(bundle, curLocale, hideSearchConfig, searchResourceManager,
      context);
  }
  searchResourceManager.clearCache();
}
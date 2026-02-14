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

import resourceManager from '@ohos.resourceManager';
import { RawFileUtil } from '@ohos/settings.common/src/main/ets/utils/RawFileUtil';
import { LogUtil } from '@ohos/settings.common/src/main/ets/utils/LogUtil';
import lazy { MemoryMgrUtils } from '@ohos/settings.common/src/main/ets/utils/MemoryMgrUtils';
import { AbilityContextManager } from '@ohos/settings.common/src/main/ets/ability/AbilityContextManager';
import { ThreadUtils } from '@ohos/settings.common/src/main/ets/utils/ThreadUtils';
import { SearchPageConfig } from '../model/SearchPageConfig';
import { PageInfoConfig } from '../model/PageInfoConfig';
import { ExternalInfoConfig } from '../model/ExternalInfoConfig';
import { UpgradeConfig } from '../model/UpgradeConfig';

const TAG: string = 'SearchConfigFileParser';

export class SearchConfigFileParser {
  public static searchConfigParser: SearchConfigFileParser | undefined = undefined;

  public static getInstance(): SearchConfigFileParser {
    if (SearchConfigFileParser.searchConfigParser) {
      return SearchConfigFileParser.searchConfigParser;
    }
    SearchConfigFileParser.searchConfigParser = new SearchConfigFileParser();
    return SearchConfigFileParser.searchConfigParser;
  }

  private static getBundleResourceManager(bundleName: string): resourceManager.ResourceManager | undefined {
    let bundleContext: Context = SearchConfigFileParser.getContext()?.createBundleContext(bundleName);
    return bundleContext ? bundleContext.resourceManager : undefined;
  }

  public async parserSearchPageConfig(configFilePath: string): Promise<SearchPageConfig | undefined> {
    try {
      let rawContent: string =
        await RawFileUtil.getStringByFile(SearchConfigFileParser.getContext()?.resourceManager, configFilePath);
      let searchPageConfig: SearchPageConfig = JSON.parse(rawContent);
      return searchPageConfig;
    } catch (error) {
      LogUtil.error(`${TAG} parserSearchPageConfig error: ${error}`);
      return undefined;
    }
  }

  public async parseExternalSearchPageConfig(bundleName: string, configFilePath: string):
    Promise<SearchPageConfig | undefined> {
    try {
      const resourceManager: resourceManager.ResourceManager | undefined =
        SearchConfigFileParser.getBundleResourceManager(bundleName);
      let rawContent: string = await RawFileUtil.getStringByFile(resourceManager, configFilePath);
      let searchPageConfig: SearchPageConfig = JSON.parse(rawContent);
      MemoryMgrUtils.removeNapiWrap(resourceManager, false)
      return searchPageConfig;
    } catch (error) {
      LogUtil.error(`${TAG} parserSearchPageConfig error: ${error}`);
      return undefined;
    }
  }

  public async parserPageInfoConfig(configFilePath: string): Promise<PageInfoConfig | undefined> {
    try {
      let rawContent: string =
        await RawFileUtil.getStringByFile(SearchConfigFileParser.getContext()?.resourceManager, configFilePath);
      let pageInfoConfig: PageInfoConfig = JSON.parse(rawContent);
      return pageInfoConfig;
    } catch (error) {
      LogUtil.error(`${TAG} parsePageInfoConfig error: ${error}`);
      return undefined;
    }
  }

  public async parserExternalInfoConfig(configFilePath: string): Promise<ExternalInfoConfig | undefined> {
    try {
      let rawContent: string =
        await RawFileUtil.getStringByFile(SearchConfigFileParser.getContext()?.resourceManager, configFilePath);
      let externalInfoConfig: ExternalInfoConfig = JSON.parse(rawContent);
      return externalInfoConfig;
    } catch (error) {
      LogUtil.error(`${TAG} parsePageInfoConfig error: ${error}`);
      return undefined;
    }
  }

  public async parserUpgradeInfo(configFilePath: string): Promise<UpgradeConfig | undefined> {
    try {
      let rawContent: string =
        await RawFileUtil.getStringByFile(SearchConfigFileParser.getContext()?.resourceManager, configFilePath);
      let upgradeConfig: UpgradeConfig = JSON.parse(rawContent);
      return upgradeConfig;
    } catch (error) {
      LogUtil.showError(TAG, `parserUpgradeInfo error: ${error}`);
      return undefined;
    }
  }

  private static getContext(): Context {
    if (ThreadUtils.isMainThread()) {
      return AbilityContextManager.getStageContext();
    }
    return AbilityContextManager.getSubThreadContext();
  }
}
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

import { LogUtil } from '@ohos/settings.common/src/main/ets/utils/LogUtil';
import { RawFileUtil } from '@ohos/settings.common/src/main/ets/utils/RawFileUtil';
import { PackageFilterConfig } from '../PackageFilterConfig';

const TAG: string = 'packageFilterConfigFileParser';

export class PackageFilterConfigFileParser {
  public static packageFilterConfigParser: PackageFilterConfigFileParser | undefined = undefined;

  public static getInstance(): PackageFilterConfigFileParser {
    if (PackageFilterConfigFileParser.packageFilterConfigParser) {
      return PackageFilterConfigFileParser.packageFilterConfigParser;
    }
    PackageFilterConfigFileParser.packageFilterConfigParser = new PackageFilterConfigFileParser();
    return PackageFilterConfigFileParser.packageFilterConfigParser;
  }

  public async parserPackageFilterPageConfig(configFilePath: string): Promise<PackageFilterConfig | undefined> {
    try {
      let rawContent: string = await RawFileUtil.getStringByFile(AppStorage.get<Context>('pageContext')?.resourceManager, configFilePath);
      let searchPageConfig: PackageFilterConfig = JSON.parse(rawContent);
      return searchPageConfig;
    } catch (error) {
      LogUtil.error(`${TAG} parserSearchPageConfig error: ${error}`);
      return undefined;
    }
  }
}
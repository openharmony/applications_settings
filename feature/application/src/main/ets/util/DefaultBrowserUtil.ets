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

import defaultAppMgr from '@ohos.bundle.defaultAppManager';
import { BusinessError } from '@ohos.base';
import { LogUtil } from '@ohos/settings.common/src/main/ets/utils/LogUtil';

const TAG: string = 'DefaultBrowserUtil';

export class DefaultBrowserUtil {
  static async setDefaultBrowser(bundleName: string, abilityName: string, moduleName: string): Promise<void> {
    try {
      await defaultAppMgr.setDefaultApplication(defaultAppMgr.ApplicationType.BROWSER, {
        bundleName: bundleName,
        moduleName: moduleName ?? 'entry',
        abilityName: abilityName
      });
      LogUtil.info(`${TAG} set default browser success: ${bundleName}`);
    } catch (error) {
      LogUtil.error(`${TAG} set default browser fail, cause:  ${(error as BusinessError)?.message} `);
    }
  }
}
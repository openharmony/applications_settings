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
import { LogUtil } from '@ohos/settings.common/src/main/ets/utils/LogUtil';

const TAG: string = 'DefaultMailUtil';

export class DefaultMailUtil {
  static async setDefaultMail(bundleName: string): Promise<void> {
    try {
      await defaultAppMgr.setDefaultApplication(defaultAppMgr.ApplicationType.EMAIL, {
        bundleName: bundleName,
        moduleName: 'entry',
        abilityName: 'EntryAbility'
      });
      LogUtil.info(`${TAG} set default mail Scuess: ${bundleName}`);
    } catch (error) {
      LogUtil.error(`${TAG} setDefaultMail Cause:  ${error.message} `);
    }
  }
}
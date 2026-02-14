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

import { Context } from '@kit.AbilityKit';
import { LogUtil } from '@ohos/settings.common/src/main/ets/utils/LogUtil';
import { ResourceManagerUtil } from '@ohos/settings.common/src/main/ets/utils/ResourceManagerUtil';
import {
  PRIVACY_CENTER_BUNDLE_NAME,
  PRIVACY_STATEMENT_HYPERLINK,
  PRIVACY_STATEMENT_SHORT_NOTICE
} from './component/WlanSecurityCheckComponent';

@Concurrent
export function getSecurityStatement(context: Context): string[] {
  const resourceManager = ResourceManagerUtil.getResManagerWithContext(PRIVACY_CENTER_BUNDLE_NAME, context);
  if (!resourceManager) {
    LogUtil.warn(`WifiSecurityCheckUtils resourceManager invalid`);
    return [];
  }
  let statementShortNotice = '';
  let statementHyperlink = '';
  try {
    statementShortNotice = resourceManager.getStringByNameSync(PRIVACY_STATEMENT_SHORT_NOTICE);
    statementHyperlink = resourceManager.getStringByNameSync(PRIVACY_STATEMENT_HYPERLINK);
  } catch (err) {
    LogUtil.error(`WifiSecurityCheckUtils getStatement error, code: ${err?.code}, msg: ${err?.message}`);
    return [];
  }
  return [statementShortNotice, statementHyperlink];
}
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

import ServiceExtensionAbility from '@ohos.app.ability.ServiceExtensionAbility';
import Want from '@ohos.app.ability.Want';
import { AbilityUtils } from '@ohos/settings.common/src/main/ets/utils/AbilityUtils';
import { AbilityContextManager } from '@ohos/settings.common/src/main/ets/ability/AbilityContextManager';
import { LogUtil } from '@ohos/settings.common/src/main/ets/utils/LogUtil';
import { hmShareDataManager } from '@ohos/settings.wifi/src/main/ets/HarmonyShareDataManager';

/* instrument ignore file */
const TAG: string = 'SettingsInstantShareServiceAbility: ';

export default class SettingsInstantShareServiceAbility extends ServiceExtensionAbility {
  async onCreate(want: Want) {
    LogUtil.info(`${TAG} onCreate`);
    AbilityUtils.setCacheProcess(false, this.context);
    AbilityContextManager.setInstantShareServiceAbilityContext(this.context);
  }

  onRequest(want: Want, startId: number): void {
    LogUtil.info(`${TAG} onRequest`);
    let params = want?.parameters as Record<string, string>;
    if (params?.['ohos.aafwk.param.callerBundleName'] !== 'com.ohos.instantshare') {
      LogUtil.info(`${TAG} is not from hwShare`);
      return;
    }
    let uri = want.uri;
    if (want.parameters?.textContent) {
      uri = want.parameters?.textContent as string;
    }
    hmShareDataManager.processShareWifi(uri);
  }

  onDestroy(): void {
    LogUtil.info(`${TAG} onDestroy`);
  }
}
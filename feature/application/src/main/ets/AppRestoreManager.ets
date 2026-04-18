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

import common from '@ohos.app.ability.common';
import Want from '@ohos.app.ability.Want';
import { BusinessError } from '@ohos.base';
import { LogUtil } from '@ohos/settings.common/src/main/ets/utils/LogUtil';
import { AppRestoreServiceExtProxy } from './AppRestoreServiceExtProxy';
/* instrument ignore file */
const TAG: string = 'AppRestoreManager';

export class AppRestoreManager {
  private connectionId = -1;
  private context: common.UIAbilityContext | null = null;

  private options: common.ConnectOptions = {
    async onConnect(elementName, remote) {
      LogUtil.info(`${TAG} onConnect elementName: ${elementName}`);
      if (remote === null) {
        LogUtil.error(`${TAG} onConnect remote is null`);
        return;
      }
      this.restoreProxy = new AppRestoreServiceExtProxy(remote);
      let promise = new Promise<boolean>((resolve) => {
        this.restoreProxy.checkNewRestores((errCode: number, redPoint: Record<string, Object>) => {
          LogUtil.info(`${TAG} checkNewRestores hasRedPoint, errCode: ${errCode}`);
          AppStorage.setOrCreate('hasAppRestore', redPoint['app'] ?? false);
          AppStorage.setOrCreate('hasMetaServiceRestore', redPoint['service'] ?? false);
        });
      });
      await promise;
    },
    onDisconnect(elementName) {
      LogUtil.info(`${TAG} onDisconnect callback`);
      this.restoreProxy = null;
      this.context = null;
      this.connectionId = -1;
    },
    onFailed(code) {
      LogUtil.error(`${TAG} onFailed callback`);
      this.restoreProxy = null;
      this.context = null;
      this.connectionId = -1;
    }
  }

  getRestoreInfo(): void {
    this.context = getContext(this) as common.UIAbilityContext
    this.connectAbility(this.context);
    this.disconnectAbility(this.context);
  }

  connectAbility(context: common.UIAbilityContext | null): void {
    if (context === null) {
      return;
    }
    let want: Want = {
      deviceId: '',
      bundleName: 'com.ohos.restores',
      abilityName: 'SettingsRestoresServiceAbility',
    };

    this.connectionId = context.connectServiceExtensionAbility(want, this.options);
    LogUtil.info(`${TAG} connectAbility connectionId ${this.connectionId}`);
  }

  disconnectAbility(context: common.UIAbilityContext | null) {
    if (context === null) {
      return;
    }

    context.disconnectServiceExtensionAbility(this.connectionId).then(() => {
      LogUtil.info(`${TAG} disconnectServiceExtensionAbility success`);
    }).catch((error: BusinessError) => {
      LogUtil.info(`${TAG} disconnectServiceExtensionAbility failed, errcode: ${error.code}}`);
    })
  }
}

export let appRestoreManager = new AppRestoreManager();
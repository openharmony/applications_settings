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
import rpc from '@ohos.rpc';
import { BusinessError } from '@ohos.base';
import { LogUtil } from '@ohos/settings.common/src/main/ets/utils/LogUtil';

const TAG: string = 'DeveloperModeLock';

export default class DeveloperModeLock {

  public openDeveloperModeLockDialog() {
    this.openSystemDialog('com.ohos.settings', 'DeveloperModeSettingsAbility');
  }
  public openHsdrDialog() {
    this.openSystemDialog('com.ohos.securityguardassistant', 'DevCareDialogAbility');
  }

  // 拉起系统弹窗的通用模板
  private openSystemDialog(bundleName: string, abilityName: string) {
    let newWant: Want = {
      bundleName: 'com.ohos.sceneboard',
      abilityName: 'com.ohos.sceneboard.systemdialog'
    }
    let connectOption: common.ConnectOptions = {
      onConnect(elementName, remote) {
        let option = new rpc.MessageOption();
        let data = rpc.MessageSequence.create();
        let reply = rpc.MessageSequence.create();
        let parameter: Record<string, Object> = {
          'ability.want.params.uiExtensionType': 'sysDialog/common',
          'sysDialogZOrder': 1
        }
        LogUtil.showInfo(TAG, 'param ${JSON.stringify(parameter)}');
        data.writeInt(3);
        data.writeString('bundleName');
        data.writeString(bundleName); // 业务方的bundleName
        data.writeString('abilityName');
        data.writeString(abilityName); // 业务方的abilityName
        data.writeString('parameters');
        data.writeString(JSON.stringify(parameter));

        remote.sendMessageRequest(1, data, reply, option)
          .then(result => {
            LogUtil.showInfo(TAG, `Start System Dialog success ${result.errCode} ${result.reply.readInt()}`);
          })
          .catch((error: BusinessError) => {
            LogUtil.showError(TAG, `Start System Dialog error code:${error?.code},message:${error?.message}`)
          })
          .finally(() => {
            data.reclaim();
            reply.reclaim();
          });
      },
      onDisconnect(elementName) {
        LogUtil.showInfo(TAG, `DisConnect from System Dialog,elementName: ${elementName.bundleName}`)
      },
      onFailed(code) {
        LogUtil.showError(TAG, `Connect to System Dialog Failed,code: ${code}`)
      }
    }
    try {
      let context: common.UIAbilityContext = getContext(this) as common.UIAbilityContext;
      const connectionId = context?.connectServiceExtensionAbility(newWant, connectOption)
    } catch (e) {
      let err: BusinessError = e as BusinessError
      LogUtil.showError(TAG, `Connect to System Dialog Failed,code: ${err?.code}`)
    }
  }
}
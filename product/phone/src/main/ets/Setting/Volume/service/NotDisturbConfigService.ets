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

/* instrument ignore file */
import common from '@ohos.app.ability.common';
import settings from '@ohos.settings';
import Want from '@ohos.app.ability.Want';
import rpc from '@ohos.rpc';
import { BusinessError } from '@ohos.base';
import { CallMessage, IService } from '@ohos/settings.common/src/main/ets/stub/BaseServiceStub';
import { Response } from '@ohos/settings.common/src/main/ets/constant/Response';
import { LogUtil } from '@ohos/settings.common/src/main/ets/utils/LogUtil';
import { NotDisturbUtils } from '@ohos/settings.notDisturb/src/main/ets/utils/NotDisturbUtils';
import { SettingsDataUtils } from '@ohos/settings.common/src/main/ets/utils/SettingsDataUtils';
import { EventBus } from '@ohos/settings.common/src/main/ets/framework/common/EventBus';
import { EVENT_SET_NOT_DISTURB_TIMER_COMPLETE } from '@ohos/settings.notDisturb/src/main/ets/utils/NotDisturbUtils';
import { CapabilitySupportUtils } from '@ohos/settings.common/src/main/ets/utils/CapabilitySupportUtils';

const TAG: string = 'NotDisturbConfigService';
const SET_ZEN_MODE_OPEN: string = 'setZenModeOpen';
const SET_ZEN_MODE_OFF: string = 'setZenModeOff';
const DND_COUNT: string = 'dnd_count';
const CLOSE_NOT_DISTURB_TIMEOUT: number = 5000;
const NO_TIMER: number = -1;
const MAX_TIPS_COUNT: number = 3;
const DIALOG_ENABLE_VAL: number = 1;
const DIALOG_ENABLE_KEY: string = 'dialogEnable';

export class NotDisturbConfigService implements IService {

  private openConfirmDialog(): void {
    LogUtil.showInfo(TAG, 'startDialog');
    // 构造连接 systemDialog ability 参数
    let sysDialogWant: Want = {
      bundleName: 'com.ohos.sceneboard',
      abilityName: 'com.ohos.sceneboard.systemdialog'
    }
    let options: common.ConnectOptions = {
      onConnect(elementName, remote): void {
        LogUtil.showInfo(TAG, 'onConnect callback');
        if (remote === null) {
          LogUtil.showWarn(TAG, 'onConnect remote is null');
          return;
        }
        // 调用rpc的接口向服务端发送消息，客户端需自行对入参进行序列化，对返回值进行反序列化
        let option = new rpc.MessageOption();
        let data = new rpc.MessageSequence();
        let reply = new rpc.MessageSequence();
        data.writeInt(3);
        data.writeString('bundleName');
        data.writeString('com.ohos.settings');
        data.writeString('abilityName');
        data.writeString('NotDisturbDialogAbility');
        data.writeString('parameters');
        data.writeString(`{"ability.want.params.uiExtensionType":"sysDialog/common","sysDialogZOrder": 2 }`);

        remote.sendMessageRequest(1, data, reply, option).then((ret) => {
          let msg = reply.readInt();
          LogUtil.showInfo(TAG, `sendMessageRequest msg: ${msg}`);
        }).catch((error: BusinessError) => {
          LogUtil.showError(TAG, `sendMessageRequest failed err: ${error?.message}`);
        }).finally(() => {
          data?.reclaim();
          reply?.reclaim();
        })
      },
      onDisconnect(elementName): void {
        LogUtil.showInfo(TAG, 'onDisconnect callback');
      },
      onFailed(code): void {
        LogUtil.showInfo(TAG, `onFailed, code: ${code}`);
      }
    }

    try {
      let context = SettingsDataUtils.getContext();
      // 建立连接后返回的Id需要保存下来，在解绑服务时需要作为参数传入
      let connectionId = (context as common.UIAbilityContext |
        common.ServiceExtensionContext).connectServiceExtensionAbility(sysDialogWant, options);
      LogUtil.showInfo(TAG, `connectionId: ${connectionId}`);
    } catch (err) {
      LogUtil.showInfo(TAG, `err: ${err?.code} ${err?.message}`);
    }
  }

  async onCall(json: string): Promise<string> {
    if (CapabilitySupportUtils.isSupportIntelligentScene()) {
      LogUtil.showWarn(TAG, 'current device not support NotDisturb mode.');
      return Response.INVALID_METHOD;
    }
    let message: CallMessage;
    try {
      message = JSON.parse(json) as CallMessage;
    } catch (err) {
      LogUtil.showError(TAG, 'parse input message invalid');
      return Response.UNKNOWN_METHOD;
    }
    const method: string = message?.method;
    const dialogEnableVal: number = message?.extra?.[DIALOG_ENABLE_KEY] ?? DIALOG_ENABLE_VAL;
    const isDialogEnable: boolean = dialogEnableVal === DIALOG_ENABLE_VAL;
    LogUtil.showInfo(TAG, `onCall method = ${method}, isDialogEnable = ${isDialogEnable}`);
    if (method === SET_ZEN_MODE_OPEN) {
      let count: number = Number(SettingsDataUtils.getSettingsData(DND_COUNT, '0', settings.domainName.USER_PROPERTY));
      LogUtil.showInfo(TAG, `setZenModeOpen count = ${count}`);

      if (isDialogEnable && count < MAX_TIPS_COUNT) {
        this.openConfirmDialog();
        count++;
        SettingsDataUtils.setSettingsData(DND_COUNT, String(count), settings.domainName.USER_PROPERTY);
      } else {
        NotDisturbUtils.setModeStatus(true);
      }
    } else if (method === SET_ZEN_MODE_OFF) {
      return this.closeNotDisturb();
    } else {
      LogUtil.showWarn(TAG, 'onCall invalid method');
      return Response.INVALID_METHOD;
    }
    return Response.SUCCESS;
  }

  private async closeNotDisturb(): Promise<string> {
    return new Promise((resolve) => {
      let timerId: number = setTimeout(() => {
        LogUtil.showInfo(TAG, 'close not disturb timeout');
        timerId = NO_TIMER;
        resolve(Response.SUCCESS);
      }, CLOSE_NOT_DISTURB_TIMEOUT);

      EventBus.getInstance().once(EVENT_SET_NOT_DISTURB_TIMER_COMPLETE, (result: boolean) => {
        LogUtil.showInfo(TAG, `close not disturb timer complete, result:${result}`);
        if (timerId !== NO_TIMER) {
          clearTimeout(timerId);
          timerId = NO_TIMER;
          resolve(Response.SUCCESS);
        }
      });
      NotDisturbUtils.setModeStatus(false);
    });
  }
}

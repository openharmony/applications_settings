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
import { BusinessError } from '@kit.BasicServicesKit';
import common from '@ohos.app.ability.common';
import rpc from '@ohos.rpc';
import Settings from '@ohos.settings';
import { LogUtil } from '@ohos/settings.common/src/main/ets/utils/LogUtil';
import { SettingsDataUtils } from '@ohos/settings.common/src/main/ets/utils/SettingsDataUtils';
import { AOD_DISPLAY_TYPE, PowerSaveTaskManager, TaskKey } from '../../PowerSaveTaskManager';
import { PowerSaveSuggestionModel } from '../PowerSaveSuggestionModel';
import { REMOTE_CALL_SUCCESS, REQUEST_CODE, AOD_SERVICE_WANT } from './AodProxyParam';

const TAG: string = 'SmartAodModel';
const AOD_DISPLAY_MODE: string = 'displayMode';
const AOD_SWITCH_STATE: string = 'switch';

@Concurrent
async function setAodDisplayMode(context: Context): Promise<boolean> {
  let tag: string = 'SmartAodModel';
  let timer: Promise<boolean> = new Promise(resolve => {
    setTimeout(() => {
      LogUtil.warn(`${tag} setAodDisplayMode timer finish`);
      resolve(false);
    }, 5000)
  });
  let taskPromise: Promise<boolean> = new Promise((resolve) => {
    let uiContext: common.UIAbilityContext = context as common.UIAbilityContext;
    if (!uiContext) {
      LogUtil.warn(`${tag} setAodDisplayMode fail, uiContext is null or undefined`);
      resolve(false);
      return;
    };
    let connectid: number | undefined;
    let connectOptions: common.ConnectOptions = {
      onConnect(elementName, remote) {
        if (!remote) {
          LogUtil.warn(`${tag} remote is empty`);
          resolve(false);
          return;
        }
        LogUtil.info(`${tag} onConnect`);
        let option = new rpc.MessageOption();
        let data = new rpc.MessageSequence();
        let reply = new rpc.MessageSequence();
        data.writeString('setAodDisplayState');
        remote.sendMessageRequest(REQUEST_CODE, data, reply, option).then((ret) => {
          let msg: string = '';
          try {
            msg = reply.readString();
            LogUtil.info(`${tag}: setAodDisplayState ret:${ret} msg:${msg}`);
          } catch (error) {
            LogUtil.error(`${tag}: setAodDisplayState ipc read string fail, err code: ${error?.code}, err message: ${error?.message}`);
          }
          resolve(msg === REMOTE_CALL_SUCCESS);
        }).catch((error: BusinessError) => {
          LogUtil.error(`${tag}: setAodDisplayState failed, err code: ${error?.code}, err message: ${error?.message}`);
          resolve(false);
        }).finally(() => {
          LogUtil.info(`${tag} setAodDisplayState finish, disconnect service`);
          data.reclaim();
          reply.reclaim();
          uiContext.disconnectServiceExtensionAbility(connectid);
        })
      },
      onDisconnect(elementName) {
        LogUtil.info(`${tag} onDisconnect`);
        resolve(false);
      },
      onFailed(code) {
        LogUtil.info(`${tag} onFailed code: ${code}`);
        resolve(false);
      }
    }
    try {
      connectid = uiContext.connectServiceExtensionAbility(AOD_SERVICE_WANT, connectOptions);
    } catch (error) {
      LogUtil.error(`${tag}: setSmartAod connectServiceExtensionAbility failed, err code: ${error?.code}, err message: ${error?.message}`);
      resolve(false);
    }
  });
  return await Promise.race([taskPromise, timer]);
}

async function needShow(): Promise<boolean> {
  return new Promise(resolve => {
    let jsonString: string = SettingsDataUtils.getSecureValue(AOD_DISPLAY_TYPE, '');
    LogUtil.info(`${TAG} current aod state: ${jsonString}`);
    try {
      let recordModel: Record<string, number> = JSON.parse(jsonString) as Record<string, number>;
      if (!recordModel) {
        LogUtil.warn(`${TAG} no need show, recordModel is empty`);
        resolve(false);
        return;
      }
      let displayMode: number = recordModel[AOD_DISPLAY_MODE];
      let switchState: number = recordModel[AOD_SWITCH_STATE];
      LogUtil.info(`${TAG} displayMode: ${displayMode}, switchState: ${switchState}`);
      resolve(displayMode !== 0 && switchState === 1);
    } catch (err) {
      LogUtil.error(`${TAG} parse error code: ${err?.code} message: ${err?.message}`);
      resolve(false);
    }
  })
}

function registerStateChange(callback: Callback<boolean>): void {
  LogUtil.info(`${TAG} register aod state change, key: ${AOD_DISPLAY_TYPE}`);
  SettingsDataUtils.registerKeyObserverWithDomain(AOD_DISPLAY_TYPE, Settings.domainName.USER_SECURITY, () => {
    let jsonString: string = SettingsDataUtils.getSecureValue(AOD_DISPLAY_TYPE, '');
    LogUtil.info(`${TAG} handle aod state change`);
    try {
      let recordModel: Record<string, number> = JSON.parse(jsonString) as Record<string, number>;
      if (!recordModel) {
        return;
      }
      let displayMode: number = recordModel[AOD_DISPLAY_MODE];
      let switchState: number = recordModel[AOD_SWITCH_STATE];
      if (displayMode === undefined || switchState === undefined) {
        LogUtil.warn(`${TAG} handle aod state change fail: displayMode or switchState is empty`);
        return;
      }
      callback(displayMode !== 0 && switchState === 1);
    } catch (err) {
      LogUtil.error(`${TAG} parse error code: ${err?.code} message: ${err?.message}`);
    }
  })
}

function unregisterStateChange(callback: Callback<boolean>): void {
  LogUtil.info(`${TAG} unregister aod state change, key: ${AOD_DISPLAY_TYPE}`);
  SettingsDataUtils.unregisterKeyObserverWithDomain(AOD_DISPLAY_TYPE, Settings.domainName.USER_SECURITY);
}

async function generateModel(): Promise<PowerSaveSuggestionModel> {
  return {
    key: TaskKey.AOD_DISPLAY_TYPE,
    title: $r('app.string.set_aod_display_mode_smart'),
    subscription: $r('app.string.set_aod_display_mode_smart_sub'),
  }
}

PowerSaveTaskManager.getInstance().loadTask(TaskKey.AOD_DISPLAY_TYPE, {
  modelGenerator: generateModel,
  needShow: needShow,
  optimizationTask: setAodDisplayMode,
  registerStateChange: registerStateChange,
  unregisterStateChange: unregisterStateChange
})
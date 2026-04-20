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

import rpc from '@ohos.rpc';
import { BusinessError } from '@ohos.base';
import { LogUtil } from '@ohos/settings.common/src/main/ets/utils/LogUtil';
/* instrument ignore file */
const TAG: string = 'AppRestoreServiceExtProxy';
const COMMAND_CHECK_NEW_RESTORES: number = 1;
const REQUEST_SUCCESS: number = 0;
const CONNECT_SUCCESS: number = 1;
const CONNECT_FAIL: number = 1;
const APP_INDEX: number = 0;
const SERVICE_INDEX: number = 1;
const RESTORE_RESULT_LENGTH: number = 2;

export class AppRestoreServiceExtProxy implements AppRestoreServiceExt {
  private proxy: rpc.IRemoteObject;

  constructor(proxy: rpc.IRemoteObject) {
    this.proxy = proxy;
  }

  sendMessageRequestCallback(result: rpc.RequestResult, callback: checkNewRestoresCallback): void {
    if (result.errCode !== REQUEST_SUCCESS) {
      LogUtil.error(`${TAG} sendMessageRequest failed, errCode: ${result.errCode}}`);
      return;
    }

    let errCodeValue: number = CONNECT_FAIL;
    try {
      errCodeValue = result.reply.readInt();
    } catch (err) {
      LogUtil.error(`${TAG} get connect result error: code: ${err.code} message: ${err.message}`);
    }
    if (errCodeValue !== CONNECT_SUCCESS) {
      LogUtil.error(`${TAG} sendMessageRequest connect failed`);
      return;
    }

    let resultVar: boolean[] = [];
    try {
      resultVar = result.reply.readBooleanArray() as Array<boolean>;
    } catch (err) {
      LogUtil.error(`${TAG} get restore result error: code: ${err.code} message: ${err.message}`);
    }
    if (resultVar.length !== RESTORE_RESULT_LENGTH) {
      LogUtil.error(`${TAG} get restore result failed`);
      return;
    }
    let redPoint: Record<string, Object> = {
      'app': resultVar[APP_INDEX] ?? '',
      'service': resultVar[SERVICE_INDEX]
    };

    callback(errCodeValue, redPoint);
    LogUtil.info(`${TAG} sendMessageRequest.`);
  }

  checkNewRestores(callback: checkNewRestoresCallback): void {
    let option: rpc.MessageOption = new rpc.MessageOption();
    let dataSequence: rpc.MessageSequence = new rpc.MessageSequence();
    let replySequence: rpc.MessageSequence = new rpc.MessageSequence();
    this.proxy.sendMessageRequest(COMMAND_CHECK_NEW_RESTORES, dataSequence, replySequence, option).then((result) => {
      this.sendMessageRequestCallback(result, callback);
    }).catch((err: BusinessError) => {
      LogUtil.error(`${TAG} read reply failed: ${err.code}`);
    }).finally(()=> {
      dataSequence.reclaim();
      replySequence.reclaim();
    })
  }
}

export type checkNewRestoresCallback = (errCode: number, returnValue: Record<string, Object> | void) => void;

export default interface AppRestoreServiceExt {
  checkNewRestores(callback: checkNewRestoresCallback): void;
}
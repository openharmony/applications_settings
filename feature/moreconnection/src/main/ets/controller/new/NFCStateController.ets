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

import nfcController from '@ohos.nfc.controller';
import { LogUtil } from '@ohos/settings.common/src/main/ets/utils/LogUtil';
import { CommonUtils } from '@ohos/settings.common/src/main/ets/utils/CommonUtils';
import { NavEntryKey } from '@ohos/settings.common/src/main/ets/utils/Consts';
import { CompCtrlParam, ComponentControl } from '@ohos/settings.common/src/main/ets/framework/model/SettingBaseModel';
import {
  notifyCompStateChange,
  SettingResultState,
  SettingStateType
} from '@ohos/settings.common/src/main/ets/framework/model/SettingStateModel';
import { ItemResultType } from '@ohos/settings.common/src/main/ets/framework/model/SettingItemModel';
import { NFCUtil, NFCStateChangeListener } from '../../NFCUtil';

const TAG: string = 'NFCStateController:';

export class NFCStateController implements ComponentControl, NFCStateChangeListener {
  private compId: string = '';

  onNFCStateChange(state: nfcController.NfcState): void {
    LogUtil.info(`${TAG} listener find nfc service isChanged: ${state}`);
    // 底层会返回多个状态值，仅当开、关状态时 进行响应
    if (state === nfcController.NfcState.STATE_OFF || state === nfcController.NfcState.STATE_ON) {
      this.checkNFCState();
    }
  }

  init(compParam: CompCtrlParam): void {
    if (!compParam || !compParam.compId) {
      LogUtil.error(`${TAG} init fail, compParam is invalid`);
      return;
    }
    LogUtil.info(`${TAG} init, compId: ${compParam.compId}`);
    this.compId = compParam.compId;
    NFCUtil.getInstance().start();
    this.registerDataChange();
    this.updateStatus();
  }

  destroy(): void {
    if (!CommonUtils.isPageExist(NavEntryKey.MORE_CONNECTION_ENTRY)) {
      NFCUtil.getInstance().stop();
      this.unRegisterDataChange();
    } else {
      LogUtil.info(`${TAG} more_connection_entry is exist, do not unregister`);
    }
  }

  getListenerName(): string {
    return 'nfc_settings';
  }

  protected registerDataChange(): void {
    LogUtil.info(`${TAG} registerDataChange`);
    NFCUtil.getInstance().unRegisterStateChangeListener(this);
    NFCUtil.getInstance().registerStateChangeListener(this);
  }

  protected unRegisterDataChange(): void {
    LogUtil.info(`${TAG} unRegisterDataChange`);
    NFCUtil.getInstance().unRegisterStateChangeListener(this);
  }

  updateStatus(): void {
    this.checkNFCState();
  }

  private checkNFCState(): void {
    try {
      let state: boolean = nfcController.isNfcOpen();
      LogUtil.info(`${TAG} update nfc service state, state: ${state}`);
      this.refreshUi(state ? $r('app.string.nfc_switch_on_text') : $r('app.string.nfc_switch_off_text'));
    } catch (err) {
      LogUtil.error(`${TAG} check nfcStatus api failed`);
    }
  }

  private refreshUi(content: ResourceStr): void {
    notifyCompStateChange(this.compId,
      new Map<SettingStateType, SettingResultState>([[SettingStateType.STATE_TYPE_ITEM_RESULT,
        { type: ItemResultType.RESULT_TYPE_TEXT, result: { content: content } } as SettingResultState]]));
  }
}
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

/**
 * 位置信息回调
 */
export interface NFCStateChangeListener {
  /**
   * 获取 listener name
   * @returns listener name
   */
  getListenerName(): string;

  // 位置信息回调
  onNFCStateChange(state: nfcController.NfcState): void;
}

const TAG: string = 'NFCUtil : ';

export class NFCUtil {
  public isStart: boolean = false;
  public currentState: boolean = false;
  public stateChangeListeners: NFCStateChangeListener[] = [];

  private static instance = new NFCUtil();

  public nfcStateChange = (stateChanged: nfcController.NfcState): void => {
    LogUtil.info(`${TAG} listener find nfc service isChanged: ${stateChanged}`);

    this.currentState = nfcController.isNfcOpen();
    LogUtil.info(`${TAG} onNFCStateChange state : ${this.currentState}`);

    this.dispatchNFCStateChange(stateChanged);
  };

  private dispatchNFCStateChange(stateChanged: nfcController.NfcState): void {
    for (let listener of this.stateChangeListeners) {
      listener?.onNFCStateChange(stateChanged);
    }
  }

  start(): void {
    if (!this.isStart) {
      this.isStart = true;
      this.currentState = nfcController.isNfcOpen();
      LogUtil.info(`${TAG} start, update NFC service state, state: ${this.currentState}`);

      nfcController.on('nfcStateChange', this.nfcStateChange);
    }
  }

  stop(): void {
    if (this.isStart) {
      LogUtil.info(`${TAG} stop`);
      nfcController.off('nfcStateChange', this.nfcStateChange);
      this.isStart = false;

      // 释放资源
      this.stateChangeListeners = [];
    }
  }

  registerStateChangeListener(listener: NFCStateChangeListener): void {
    if (!listener) {
      LogUtil.error(`${TAG} registerStateChangeListener invalid`);
      return;
    }

    for (const stateChangeListener of this.stateChangeListeners) {
      if (stateChangeListener.getListenerName() === listener.getListenerName()) {
        LogUtil.info(`${TAG} registerStateChangeListener listener already register`);
        return;
      }
    }

    this.stateChangeListeners.push(listener);
    LogUtil.info(`${TAG} push ${listener.getListenerName()} size: ${this.stateChangeListeners.length}`);
  }

  unRegisterStateChangeListener(listener: NFCStateChangeListener): void {
    if (!listener) {
      LogUtil.error(`${TAG} unRegisterStateChangeListener invalid`);
      return;
    }
    for (let index = 0; index < this.stateChangeListeners.length; index++) {
      if (this.stateChangeListeners[index].getListenerName() === listener.getListenerName()) {
        this.stateChangeListeners.splice(index, 1);
        return;
      }
    }
  }

  /**
   * 获取位置管理类单例
   */
  static getInstance(): NFCUtil {
    return NFCUtil.instance;
  }
}
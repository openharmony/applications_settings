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
import { LogUtil } from '@ohos/settings.common/src/main/ets/utils/LogUtil';
/* instrument ignore file */
import { AccountServiceInterface, interfaceToken, AccountServiceEvent, DataStatus } from './i_idl_meetime_service';

/**
 * TAG
 */
const TAG: string = 'AccountManagerServiceProxy';

/**
 * 畅连账号服务接口proxy。
 *
 * @since 2025-03-17
 * @since 12
 */
export class AccountManagerServiceProxy implements AccountServiceInterface {
  /**
   * 畅连账号服务proxy代理对象。
   */
  private proxy: rpc.IRemoteObject | null = null;

  constructor(proxy: rpc.IRemoteObject) {
    this.proxy = proxy;
  }

  /**
   * 获取畅连长连接状态，超时时间为5S.
   *
   * @return {boolean} 长连接状态
   * @since 2024-11-19
   * @since 12
   */
  async getLoginStatus(): Promise<boolean> {
    if (this.proxy == null) {
      return false;
    }
    let option = new rpc.MessageOption();
    let data = rpc.MessageSequence.create();
    // 安全校验，防止存在中继攻击绕过权限校验的风险
    data.writeInterfaceToken(interfaceToken);
    let reply = rpc.MessageSequence.create();
    LogUtil.showInfo(TAG, 'start to get login status.');
    let result = await this.sendMessageRequestByBoolean(AccountServiceEvent.getLoginStatus,
      data, reply, option) as boolean;
    return result;
  }

  /**
   * 请求长连接建立。当发现长连接状态断连时，可向服务请求长连接建链。
   *
   * @return {boolean} 长连接状态
   * @since 2024-11-19
   * @since 12
   */
  async requestToLogin(timeout?: number): Promise<DataStatus | number> {
    if (this.proxy == null) {
      return -1;
    }
    let option = new rpc.MessageOption();
    let data = rpc.MessageSequence.create();
    // 安全校验，防止存在中继攻击绕过权限校验的风险
    data.writeInterfaceToken(interfaceToken);
    let reply = rpc.MessageSequence.create();
    LogUtil.showInfo(TAG, 'start to request login.');
    let result = await this.sendMessageRequestByBoolean(AccountServiceEvent.requestToLogin,
      data, reply, option, timeout) as (DataStatus | number);
    return result;
  }

  /**
   * push 场景请求建立长连接。
   *
   * @return {boolean} 长连接状态
   * @since 2024-11-19
   * @since 12
   */
  async pushToLogin(invokeType: number, timeout?: number): Promise<DataStatus | number> {
    if (this.proxy == null) {
      return -1;
    }
    let option = new rpc.MessageOption();
    let data = rpc.MessageSequence.create();
    // 安全校验，防止存在中继攻击绕过权限校验的风险
    data.writeInterfaceToken(interfaceToken);
    data.writeInt(invokeType);
    let reply = rpc.MessageSequence.create();
    LogUtil.showInfo(TAG, 'start to push login.');
    let result = await this.sendMessageRequestByBoolean(AccountServiceEvent.pushToLogin,
      data, reply, option, timeout) as (DataStatus | number);
    return result;
  }

  /**
   * 当某些场景必须要强制建立长连接时，可向服务请求长连接建链。
   *
   * @return {boolean} 长连接状态
   * @since 2024-11-19
   * @since 12
   */
  async forceToLogin(timeout?: number): Promise<DataStatus | number> {
    if (this.proxy == null) {
      return -1;
    }
    let option = new rpc.MessageOption();
    let data = rpc.MessageSequence.create();
    // 安全校验，防止存在中继攻击绕过权限校验的风险
    data.writeInterfaceToken(interfaceToken);
    let reply = rpc.MessageSequence.create();
    LogUtil.showInfo(TAG, 'start to request force login.');
    let result = await this.sendMessageRequestByBoolean(AccountServiceEvent.forceToLogin,
      data, reply, option, timeout) as (DataStatus | number);
    return result;
  }

  /**
   * 进行云端logout动作
   *
   * @since 2025-03-11
   * @since 12
   */
  async logout(): Promise<void> {
    if (this.proxy == null) {
      return;
    }
    let option = new rpc.MessageOption();
    let data = rpc.MessageSequence.create();
    // 安全校验，防止存在中继攻击绕过权限校验的风险
    data.writeInterfaceToken(interfaceToken);
    let reply = rpc.MessageSequence.create();
    LogUtil.showInfo(TAG, 'start to request logout.');
    await this.sendMessageRequestByBoolean(AccountServiceEvent.logout,
      data, reply, option) as (DataStatus | number);
    return;
  }

  /**
   * IPC 通信底层封装方法。
   *
   * @return {boolean} 长连接状态
   * @since 2024-11-19
   * @since 12
   */
  private async sendMessageRequestByBoolean(code: number, data: rpc.MessageSequence, reply: rpc.MessageSequence,
    options: rpc.MessageOption, timeout: number = 5000): Promise<boolean | DataStatus | number> {
    let result: boolean | DataStatus | number = -1;
    try {
      let ipcPromise = this.proxy?.sendMessageRequest(code, data, reply, options);
      let sleepPromise = sleep(timeout) as rpc.RequestResult;
      let requestResult = await Promise.race([ipcPromise, sleepPromise]);
      clearTimeout(timerId);
      if (requestResult) {
        result = this.parseResultFromReply(code, requestResult);
      } else {
        LogUtil.showError(TAG, 'sendMessageRequest timeout');
      }
    } catch (e) {
      LogUtil.showError(TAG, 'sendMessageRequest failed message:' + e?.message + ', e code:' + e?.code);
    } finally {
      data.reclaim();
      reply.reclaim();
    }
    return result;
  }

  /**
   * rpc解封工具方法。
   *
   * @param {number} code - 长连接请求类型
   * @param {rpc.RequestResult} requestResult - rpc结果
   * @since 2024-11-19
   * @since 12
   */
  private parseResultFromReply(code: number, requestResult: rpc.RequestResult): boolean | DataStatus | number {
    if (requestResult.errCode !== 0) {
      LogUtil.showError(TAG, `sendMessageRequest errCode ${requestResult.errCode}`);
    }
    let result: boolean | DataStatus | number = -1;
    if (code === AccountServiceEvent.getLoginStatus) {
      result = requestResult.reply?.readBoolean();
    } else {
      let tmp = requestResult.reply?.readString();
      if (tmp) {
        result = JSON.parse(tmp) as DataStatus | number;
      }
    }
    return result;
  }
}

/**
 * 延时方法
 *
 * @param ms 延时事件
 * @returns 执行结果返回
 */
let timerId: number;
const sleep: Function = (ms: number): Promise<void> => {
  return new Promise(resolve => {
    timerId = setTimeout(resolve, ms);
  });
};
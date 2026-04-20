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
export const interfaceToken: string = 'idl.IMeetimeService';

/**
 * 畅连账号服务能力接口集合。
 *
 * @since 2025-03-17
 * @since 12
 */
export interface AccountServiceInterface {
  /**
   * 获取畅连长连接状态。
   *
   * @return {boolean} 长连接状态
   * @since 2024-11-19
   * @since 12
   */
  getLoginStatus(): Promise<boolean>;

  /**
   * 请求长连接建立。当发现长连接状态断连时，可向服务请求长连接建链。
   *
   * @return {DataStatus} 长连接状态
   * @since 2024-11-19
   * @since 12
   */
  requestToLogin(): Promise<DataStatus | number>;

  /**
   * push 场景请求建立长连接。
   *
   * @param {number} invokeType - 唤醒场景标识，根据不同的唤醒场景，登陆时还需要做一定的适配
   * @return {DataStatus} 长连接状态
   * @since 2024-11-19
   * @since 12
   */
  pushToLogin(invokeType: number): Promise<DataStatus | number>;

  /**
   * 强制登陆 场景请求建立长连接。
   * 1、业务首次开启场景，需要强制登陆；
   * 2、某些长连接状态不同步情况下，需要调用此接口来校正；
   *
   * @return {DataStatus} 长连接状态
   * @since 2024-11-19
   * @since 12
   */
  forceToLogin(): Promise<DataStatus | number>;

  /**
   * 进行云端logout动作
   * 1、调用会和畅连云交互退登畅连云端登录状态
   *
   * @return {boolean} logout结果
   * @since 2025-03-11
   * @since 12
   */
  logout(): Promise<void>;
}

/**
 * 畅连公共服务事件code标识，用于IPC通信，不对外开放。
 *
 * @since 2024-11-19
 */
export enum AccountServiceEvent {
  /**
   * 获取长连接状态事件
   *
   * @since 2024-11-19
   * @argument
   */
  'getLoginStatus' = 0,

  /**
   * 请求长连接建立
   *
   * @since 2024-11-19
   * @argument
   */
  'requestToLogin' = 1,

  /**
   * push场景请求长连接建立
   *
   * @since 2024-11-19
   * @argument
   */
  'pushToLogin' = 2,

  /**
   * 强制更新长连接状态
   *
   * @since 2024-11-19
   * @argument
   */
  'forceToLogin' = 3,

  /**
   * 进行云端logout动作
   *
   * @since 2025-03-11
   * @argument
   */
  'logout' = 4
}

/**
 * ca as上报的登陆信息结构体
 *
 * @since 2024-12-9
 */
export interface DataStatus {
  /**
   * 长链接状态码
   */
  status: number;
  /**
   * 错误码
   */
  errCode: number;
  /**
   * 响应码
   */
  rspCode: number;
  /**
   * 失败原因
   */
  errReason?: number;
}

export default AccountServiceInterface;
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
import { CheckEmptyUtils } from '../utils/CheckEmptyUtils';
import { LogUtil } from '../utils/LogUtil';
/* instrument ignore file */
const TAG = 'BaseServiceStub';

/**
 * 服务接口定义
 *
 * @since 2024-02-05
 */
export interface IService {
  /**
   * 服务接口
   *
   * @param json 客户端请求消息json
   * @returns 服务端返回消息json
   */
  onCall(json: string): Promise<string>;
}

export interface IExecutor {
  /**
   * 根据数据执行返回结果
   *
   * @param extra 数据
   * @returns 服务端消息json
   */
  execute(extra?: object): Promise<string>;
}

export interface CallMessage {
  /**
   * 方法名
   */
  method: string;

  /**
   * 附加参数
   */
  extra?: object;
}

/**
 * 跨进程服务RPC通信抽象
 *
 * @since 2024-02-05
 */
export abstract class BaseServiceStub extends rpc.RemoteObject {
  private readonly serviceMap: Map<number, () => IService>;

  constructor(des: string) {
    super(des);
    this.serviceMap = this.initServiceMap();
  }

  async onRemoteMessageRequest(
    code: number,
    data: rpc.MessageSequence,
    reply: rpc.MessageSequence,
    options: rpc.MessageOption
  ): Promise<boolean> {
    const service = this.serviceMap.get(code);

    if (!service) {
      LogUtil.showWarn(TAG, `onRemoteMessageRequest invalid request code = ${code}`);
      return false;
    }

    if (CheckEmptyUtils.isEmpty(data)) {
      LogUtil.showError(TAG, 'onRemoteMessageRequest param error');
      return false;
    }

    let hasPermission = await this.checkPermissions(rpc.IPCSkeleton.getCallingUid(), rpc.IPCSkeleton.getCallingTokenId());
    if (!hasPermission) {
      LogUtil.showError(TAG, 'onRemoteMessageRequest caller got no permission');
      return false;
    }

    let msgJson: string;
    try {
      msgJson = data.readString();
    } catch (err) {
      LogUtil.showError(TAG, `read message failed: ${err?.message}`);
      return false;
    }

    LogUtil.showDebug(TAG, `onRemoteMessageRequest msg = ${msgJson}`);
    return service()?.onCall(msgJson).then(result => {
      LogUtil.showDebug(TAG, `onRemoteMessageRequest ret = ${result}`);
      reply.writeString( result ?? '');
      return true;
    }).catch((err: Error) => {
      LogUtil.showError(TAG, `onRemoteMessageRequest occurs err name = ${err.name}, msg = ${err.message}`);
      return false;
    });
  }

  /**
   * 服务标记
   *
   * @returns 服务标记
   */
  protected abstract getServiceTag(): string;

  /**
   * 初始化请求码映射服务接口
   */
  protected abstract initServiceMap(): Map<number, () => IService>;

  /**
   * 校验调用方权限
   *
   * @param callerUid 调用者id
   * @param callerTokenId 调用者tokenId
   * @returns true: 权限校验成功
   */
  protected abstract checkPermissions(callerUid: number, callerTokenId: number): Promise<boolean>;
}
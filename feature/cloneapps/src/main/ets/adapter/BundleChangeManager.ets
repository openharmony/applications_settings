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

import commonEventManager from '@ohos.commonEventManager';
import Base from '@ohos.base';
import { LogUtil } from '@ohos/settings.common/src/main/ets/utils/LogUtil';

const TAG = 'BundleChangeListener : ';

export const PACKAGE_ADDED: string = 'usual.event.PACKAGE_ADDED';
export const PACKAGE_REMOVED: string = 'usual.event.PACKAGE_REMOVED';
export const PACKAGE_CHANGED: string = 'usual.event.PACKAGE_CHANGED';

/**
 * 应用状态事件回调接口
 *
 * @since 2024-05-09
 */
export interface BundleChangeListener {
  /**
   * 获取 listener name
   * @returns listener name
   */
  getListenerName(): string;

  /**
   * 应用安装回调
   */
  onBundleAdd(bundleName: string, userId: number, index: number): void;

  /**
   * 应用更新回调
   */
  onBundleUpdate(bundleName: string, userId: number): void;

  /**
   * 应用卸载回调
   */
  onBundleRemove(bundleName: string, userId: number, index: number): void;
}

/**
 * 应用变更监听管理类
 *
 * @since 2024-05-09
 */
export class BundleChangeManager {
  public isRegister: boolean = false;
  public listeners: BundleChangeListener[] = [];

  public subscriber: commonEventManager.CommonEventSubscriber | null = null;
  public subscribeInfo: commonEventManager.CommonEventSubscribeInfo = {
    events: [PACKAGE_ADDED, PACKAGE_REMOVED, PACKAGE_CHANGED],
  }

  private dispatchBundleAdd(bundleName: string, userId: number, index: number): void {
    for (let listener of this.listeners) {
      listener?.onBundleAdd(bundleName, userId, index);
    }
  }

  private dispatchBundleUpdate(bundleName: string, userId: number): void {
    for (let listener of this.listeners) {
      listener?.onBundleUpdate(bundleName, userId);
    }
  }

  private dispatchBundleRemove(bundleName: string, userId: number, index: number): void {
    for (let listener of this.listeners) {
      listener?.onBundleRemove(bundleName, userId, index);
    }
  }

  private registerStatusChange(): void {
    if (this.isRegister) {
      return;
    }
    try {
      commonEventManager.createSubscriber(this.subscribeInfo, (err: Base.BusinessError,
        data: commonEventManager.CommonEventSubscriber) => {
        if (err) {
          LogUtil.error(`${TAG} Failed to create subscriber. Code is ${err.code}, message is ${err.message}`);
          return;
        }
        this.subscriber = data;
        this.dispatchEventMsg();
      })
    } catch (err) {
      LogUtil.error(`${TAG} register status failed`);
    }
    this.isRegister = true;
  }

  private dispatchEventMsg() {
    if (this.subscriber !== null) {
      commonEventManager.subscribe(this.subscriber, (err: Base.BusinessError,
        data: commonEventManager.CommonEventData) => {
        if (err) {
          LogUtil.error(`${TAG} Failed to subscribe common event. Code is ${err.code} message is ${err.message}`);
          return;
        }
        this.dispatchMsg(data);
      })
    } else {
      LogUtil.info(`${TAG} need create subscriber`);
    }
  }

  private dispatchMsg(data: commonEventManager.CommonEventData) {
    let bundleName = data?.bundleName as string;
    let userId = data?.parameters?.userId as number;
    let appIndex = data?.parameters?.appIndex as number;
    if (data.event === PACKAGE_ADDED) {
      this.dispatchBundleAdd(bundleName, userId, appIndex);
    } else if (data.event === PACKAGE_REMOVED) {
      this.dispatchBundleRemove(bundleName, userId, appIndex);
    } else if (data.event === PACKAGE_CHANGED) {
      this.dispatchBundleUpdate(bundleName, userId);
    }
  }

  private unRegisterStatusChange(): void {
    if (!this.isRegister) {
      return;
    }
    if (this.subscriber !== null) {
      commonEventManager.unsubscribe(this.subscriber, (err: Base.BusinessError) => {
        if (err) {
          LogUtil.error(`${TAG} UnsubscribeCallBack err= ${err.code}`);
        }
        this.subscriber = null;
      })
    }
    this.isRegister = false;
  }

  /**
   * 注册应用变更监听
   *
   * @param listener 监听者
   */
  registerBundleChangedListener(listener: BundleChangeListener): void {
    if (!listener) {
      LogUtil.error(`${TAG} registerBundleChangedListener listener invalid`);
      return;
    }
    for (let index = 0; index < this.listeners.length; index++) {
      if (this.listeners[index].getListenerName() === listener.getListenerName()) {
        LogUtil.info(`${TAG} registerBundleChangedListener ${listener.getListenerName()} listener already register`);
        return;
      }
    }
    LogUtil.info(`${TAG} registerBundleChangedListener ${listener.getListenerName()} listener register success`);
    this.listeners.push(listener);
    this.registerStatusChange();
  }

  /**
   * 取消注册应用变更监听
   *
   * @param listener 监听者
   */
  unRegisterBundleChangedListener(listener: BundleChangeListener): void {
    if (!listener) {
      LogUtil.error(`${TAG} unRegisterBundleChangedListener listener invalid`);
      return;
    }
    for (let index = 0; index < this.listeners.length; index++) {
      if (this.listeners[index].getListenerName() === listener.getListenerName()) {
        LogUtil.info(`${TAG} unregisterBundleChangedListener ${listener.getListenerName()}`);
        this.listeners.splice(index, 1);
        if (this.listeners.length === 0) {
          this.unRegisterStatusChange();
        }
        return;
      }
    }
  }

  static getInstance(): BundleChangeManager {
    if (!Boolean(AppStorage.get<BundleChangeManager>('bundleChangeManager')).valueOf()) {
      AppStorage.setOrCreate<BundleChangeManager>('bundleChangeManager', new BundleChangeManager());
    }
    return AppStorage.get<BundleChangeManager>('bundleChangeManager') as BundleChangeManager;
  }
}
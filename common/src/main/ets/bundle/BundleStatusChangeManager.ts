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
import bundleMonitor from '@ohos.bundle.bundleMonitor';
import { LogUtil } from '../utils/LogUtil';

const TAG = 'BundleStatusChangeManager : ';

/**
 * 应用变更监听回调接口
 *
 * @since 2022-06-25
 */
export interface BundleStatusChangeListener {
  /**
   * 获取 listener name
   * @returns listener name
   */
  getListenerName(): string;

  /**
   * 应用安装回调
   */
  onBundleAdd(bundleName: string, userId: number, appIndex: number): void;

  /**
   * 应用更新回调
   */
  onBundleUpdate(bundleName: string, userId: number, appIndex: number): void;

  /**
   * 应用卸载回调
   */
  onBundleRemove(bundleName: string, userId: number, appIndex: number): void;
}

/**
 * 应用变更监听管理类
 *
 * @since 2022-06-25
 */
export class BundleStatusChangeManager {
  public isRegister: boolean = false;
  public listeners: BundleStatusChangeListener[] = [];
  private dispatchBundleAdd(bundleName: string, userId: number, appIndex?: number): void {
    for (let listener of this.listeners) {
      listener?.onBundleAdd(bundleName, userId, appIndex);
    }
  }

  private dispatchBundleUpdate(bundleName: string, userId: number, appIndex?: number): void {
    for (let listener of this.listeners) {
      listener?.onBundleUpdate(bundleName, userId, appIndex);
    }
  }

  private dispatchBundleRemove(bundleName: string, userId: number, appIndex?: number): void {
    for (let listener of this.listeners) {
      listener?.onBundleRemove(bundleName, userId, appIndex);
    }
  }

  private async registerStatusChange(): Promise<void> {
    if (!this.isRegister) {
      try {
        bundleMonitor.on('add', (bundleChangeInfo) => {
          LogUtil.info(`${TAG} bundleStatusCallback add : ${bundleChangeInfo?.bundleName}`);
          this.dispatchBundleAdd(bundleChangeInfo?.bundleName, bundleChangeInfo?.userId, bundleChangeInfo?.appIndex,);
        });
        bundleMonitor.on('update', (bundleChangeInfo) => {
          LogUtil.info(`${TAG} bundleStatusCallback update : ${bundleChangeInfo?.bundleName}`);
          this.dispatchBundleUpdate(bundleChangeInfo?.bundleName, bundleChangeInfo?.userId, bundleChangeInfo?.appIndex);
        });
        bundleMonitor.on('remove', (bundleChangeInfo) => {
          LogUtil.info(`${TAG} bundleStatusCallback remove : ${bundleChangeInfo?.bundleName}`);
          this.dispatchBundleRemove(bundleChangeInfo?.bundleName, bundleChangeInfo?.userId, bundleChangeInfo?.appIndex);
        });
      } catch (err) {
        LogUtil.error(`${TAG} register status failed: ${err?.message}`);
      }
      this.isRegister = true;
    }
  }

  private unRegisterStatusChange(): void {
    if (this.isRegister) {
      try {
        bundleMonitor.off('add');
        bundleMonitor.off('update');
        bundleMonitor.off('remove');
      } catch (err) {
        LogUtil.error(`${TAG} unregister status failed ${err?.message}`);
      }
      this.isRegister = false;
    }
  }

  /**
   * 注册应用变更监听
   *
   * @param listener 监听者
   */
  async registerBundleChangedListener(listener: BundleStatusChangeListener): Promise<void> {
    if (!listener) {
      LogUtil.error(`${TAG} registerBundleChangedListener listener invalid`);
      return;
    }
    for (let index = 0; index < this.listeners.length; index++) {
      if (this.listeners[index].getListenerName() === listener.getListenerName()) {
        LogUtil.info(`${TAG} registerBundleChangedListener listener already register`);
        return;
      }
    }
    this.listeners.push(listener);
    await this.registerStatusChange();
  }

  /**
   * 取消注册应用变更监听
   *
   * @param listener 监听者
   */
  unRegisterBundleChangedListener(listener: BundleStatusChangeListener): void {
    if (!listener) {
      LogUtil.error(TAG + 'unRegisterBundleChangedListener listener invalid');
      return;
    }
    for (let index = 0; index < this.listeners.length; index++) {
      if (this.listeners[index].getListenerName() === listener.getListenerName()) {
        this.listeners.splice(index, 1);
        if (this.listeners.length === 0) {
          this.unRegisterStatusChange();
        }
        return;
      }
    }
  }

  static getInstance(): BundleStatusChangeManager {
    if (!Boolean(AppStorage.get<BundleStatusChangeManager>('bundleStatusChangeManager')).valueOf()) {
      AppStorage.setOrCreate<BundleStatusChangeManager>('bundleStatusChangeManager', new BundleStatusChangeManager());
    }
    return AppStorage.get<BundleStatusChangeManager>('bundleStatusChangeManager') as BundleStatusChangeManager;
  }
}
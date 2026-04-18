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

import { SystemUpdateConstants } from '@ohos/settings.common/src/main/ets/constant/SystemUpdateConstants';
import { LogUtil } from '@ohos/settings.common/src/main/ets/utils/LogUtil';
import { SettingsDataUtils } from '@ohos/settings.common/src/main/ets/utils/SettingsDataUtils';

/**
 * 协同升级角标变更监听器
 *
 * @since 2024-10-12
 */
export interface AllSceneUpdateBadgeChangeListener {
  /**
   * 协同升级角标变更监听器名称
   *
   * @return 监听器名称
   */
  getListenName(): string;

  /**
   * 协同升级角标变更监听器回调
   */
  onAllSceneUpdateBadgeChange(): void;
}

const TAG = 'AllSceneUpdateBadgeListener';

/**
 * 协同升级角标变更监听管理器
 *
 * @since 2024-10-12
 */
export class AllSceneUpdateBadgeListenerManager {
  private static instance: AllSceneUpdateBadgeListenerManager;
  private allSceneUpdateBadgeChangeListeners: AllSceneUpdateBadgeChangeListener[] = [];
  private isRegisterAllSceneUpdateDataChange: boolean = false;

  private onMenuBadgeChange = () => {
    for (let listener of this.allSceneUpdateBadgeChangeListeners) {
      LogUtil.info(`${TAG} onMenuBadgeChange, name: ${listener.getListenName()}`);
      listener.onAllSceneUpdateBadgeChange();
    }
  }

  /**
   * 获取实例
   *
   * @return 协同升级角标变更监听管理器
   */
  static getInstance(): AllSceneUpdateBadgeListenerManager {
    if (AllSceneUpdateBadgeListenerManager.instance) {
      return AllSceneUpdateBadgeListenerManager.instance;
    }
    AllSceneUpdateBadgeListenerManager.instance = new AllSceneUpdateBadgeListenerManager();
    return AllSceneUpdateBadgeListenerManager.instance;
  }

  private constructor() {
  }

  private registerAllSceneUpdateBadgeChange(): void {
    SettingsDataUtils.registerKeyObserver(SystemUpdateConstants.ALL_SCENE_MENU_ITEM_INFO, () => {
      this.onMenuBadgeChange();
    });
    this.isRegisterAllSceneUpdateDataChange = true;
    LogUtil.info(`${TAG} register success..`);
  }

  private unRegisterAllSceneUpdateBadgeChange(): void {
    SettingsDataUtils.unregisterKeyObserver(SystemUpdateConstants.ALL_SCENE_MENU_ITEM_INFO);
    this.isRegisterAllSceneUpdateDataChange = false;
    LogUtil.info(`${TAG} unRegister success.`)
  }

  /**
   * 注册协同升级角标变更监听管理器
   *
   * @param listener 协同升级角标变更监听管理器
   */
  registerAllSceneUpdateBadgeChangeListener(listener: AllSceneUpdateBadgeChangeListener): void {
    if (listener === null || listener === undefined) {
      return;
    }
    for (const allSceneUpdateBadgeChangeListener of this.allSceneUpdateBadgeChangeListeners) {
      if (allSceneUpdateBadgeChangeListener.getListenName() === listener.getListenName()) {
        return;
      }
    }
    this.allSceneUpdateBadgeChangeListeners.push(listener);
    if (this.allSceneUpdateBadgeChangeListeners.length > 0 && !this.isRegisterAllSceneUpdateDataChange) {
      Promise.resolve(this.registerAllSceneUpdateBadgeChange());
    }
  }

  /**
   * 取消协同升级角标变更监听管理器
   *
   * @param listener 协同升级角标变更监听管理器
   */
  unRegisterAllSceneUpdateBadgeChangeListener(listener: AllSceneUpdateBadgeChangeListener): void {
    if (listener === null || listener === undefined) {
      return;
    }
    for (let index = 0; index < this.allSceneUpdateBadgeChangeListeners.length; index++) {
      if (this.allSceneUpdateBadgeChangeListeners[index].getListenName() === listener.getListenName()) {
        this.allSceneUpdateBadgeChangeListeners.splice(index, 1);
        break;
      }
    }
    if (this.allSceneUpdateBadgeChangeListeners.length === 0 && this.isRegisterAllSceneUpdateDataChange) {
      this.unRegisterAllSceneUpdateBadgeChange();
    }
  }
}
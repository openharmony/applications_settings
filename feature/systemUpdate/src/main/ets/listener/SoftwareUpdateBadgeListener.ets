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

import { BusinessError } from '@ohos.base';
import dataShare from '@ohos.data.dataShare';
import { LogUtil } from '@ohos/settings.common/src/main/ets/utils/LogUtil';
import { SettingsDataUtils } from '@ohos/settings.common/src/main/ets/utils/SettingsDataUtils';

/**
 * 软件更新角标变更监听器
 *
 * @since 2023-12-08
 */
export interface SoftwareUpdateBadgeChangeListener {
  /**
   * 软件更新角标变更监听器名称
   *
   * @return 监听器名称
   */
  getListenName(): string;

  /**
   * 软件更新角标变更监听器回调
   */
  onSoftwareUpdateBadgeChange(): void;
}

/**
 * 软件更新角标数据库标志位
 */
export const HW_NEW_SYSTEM_UPDATE = 'hw_new_system_update';

const TAG = 'SoftwareUpdateBadgeListenerManager';

/**
 * 软件更新角标变更监听管理器
 *
 * @since 2023-12-08
 */
export class SoftwareUpdateBadgeListenerManager {
  private static instance: SoftwareUpdateBadgeListenerManager;
  private softwareUpdateBadgeChangeListeners: SoftwareUpdateBadgeChangeListener[] = [];
  private dataHelper?: dataShare.DataShareHelper;
  private isRegisterHwNewSystemUpdateDataChange: boolean = false;

  private onMenuBadgeChange = () => {
    for (let listener of this.softwareUpdateBadgeChangeListeners) {
      listener.onSoftwareUpdateBadgeChange();
    }
  }

  /**
   * 获取实例
   *
   * @return 软件更新角标变更监听管理器
   */
  static getInstance(): SoftwareUpdateBadgeListenerManager {
    if (SoftwareUpdateBadgeListenerManager.instance) {
      return SoftwareUpdateBadgeListenerManager.instance;
    }
    SoftwareUpdateBadgeListenerManager.instance = new SoftwareUpdateBadgeListenerManager();
    return SoftwareUpdateBadgeListenerManager.instance;
  }

  private constructor() {
  }


  private registerHwNewSystemUpdateDataChange(): void {
    if (this.dataHelper) {
      this.doRegisterDataChange();
    } else {
      (SettingsDataUtils.createDataHelper(HW_NEW_SYSTEM_UPDATE) as Promise<dataShare.DataShareHelper>)
        .then((dataShareHelper?:dataShare.DataShareHelper | undefined) => {
          if (dataShareHelper) {
            this.dataHelper = dataShareHelper;
            this.doRegisterDataChange();
          }
        })
        .catch((err: BusinessError) => {
          LogUtil.error(`${TAG} createDataHelper err: ${err?.message}`);
        })
    }
  }

  private doRegisterDataChange(): void {
    SettingsDataUtils.registerDataChange(this.dataHelper,
      HW_NEW_SYSTEM_UPDATE,
      this.onMenuBadgeChange);
    this.isRegisterHwNewSystemUpdateDataChange = true;
    LogUtil.info(`${TAG} register success..`)
  }

  private unRegisterHwNewSystemUpdateDataChange(): void {
    if (!this.dataHelper) {
      return;
    }
    SettingsDataUtils.unRegisterDataChange(this.dataHelper, HW_NEW_SYSTEM_UPDATE);
    this.isRegisterHwNewSystemUpdateDataChange = false;
    LogUtil.info(`${TAG} unRegister success.`)
  }

  /**
   * 注册软件更新角标变更监听器
   *
   * @param listener 软件更新角标变更监听器
   */
  registerSoftwareUpdateBadgeChangeListener(listener: SoftwareUpdateBadgeChangeListener): void {
    if (listener === null || listener === undefined) {
      return;
    }
    for (const softwareUpdateBadgeChangeListener of this.softwareUpdateBadgeChangeListeners) {
      if (softwareUpdateBadgeChangeListener.getListenName() === listener.getListenName()) {
        return;
      }
    }
    this.softwareUpdateBadgeChangeListeners.push(listener);
    if (this.softwareUpdateBadgeChangeListeners.length > 0 && !this.isRegisterHwNewSystemUpdateDataChange) {
      Promise.resolve(this.registerHwNewSystemUpdateDataChange());
    }
  }

  /**
   * 取消软件更新角标变更监听器
   *
   * @param listener 软件更新角标变更监听器
   */
  unRegisterSoftwareUpdateBadgeChangeListener(listener: SoftwareUpdateBadgeChangeListener): void {
    if (listener === null || listener === undefined) {
      return;
    }
    for (let index = 0; index < this.softwareUpdateBadgeChangeListeners.length; index++) {
      if (this.softwareUpdateBadgeChangeListeners[index].getListenName() === listener.getListenName()) {
        this.softwareUpdateBadgeChangeListeners.splice(index, 1);
        break;
      }
    }
    if (this.softwareUpdateBadgeChangeListeners.length === 0 && this.isRegisterHwNewSystemUpdateDataChange) {
      this.unRegisterHwNewSystemUpdateDataChange();
    }
  }
}
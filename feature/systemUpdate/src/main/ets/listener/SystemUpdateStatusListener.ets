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
 * 系统升级状态变更监听器
 *
 * @since 2024-08-22
 */
export interface SystemUpdateStatusListener {
  /**
   * 系统升级状态变更监听器名称
   *
   * @return 监听器名称
   */
  getListenName(): string;

  /**
   * 系统升级状态变更监听回调
   */
  onSystemUpdateStatusChange(): void;
}

/**
 * 系统升级状态数据库标志位
 */
export const HW_NEW_SYSTEM_UPDATE_STATUS = 'hw_new_system_update_status';

const TAG = 'SystemUpdateStatusListenerManager';

/**
 * 系统升级状态变更监听管理器
 *
 * @since 2024-08-22
 */
export class SystemUpdateStatusListenerManager {
  private static instance: SystemUpdateStatusListenerManager;
  private systemUpdateStatusChangeListeners: SystemUpdateStatusListener[] = [];
  private dataHelper?: dataShare.DataShareHelper;
  private isRegisterHwNewSystemUpdateStatusDataChange: boolean = false;

  private onSystemUpdateStatusChange = () => {
    for (let listener of this.systemUpdateStatusChangeListeners) {
      listener.onSystemUpdateStatusChange();
    }
  }

  /**
   * 获取实例
   *
   * @return 系统升级状态变更监听管理器
   */
  static getInstance(): SystemUpdateStatusListenerManager {
    if (SystemUpdateStatusListenerManager.instance) {
      return SystemUpdateStatusListenerManager.instance;
    }
    SystemUpdateStatusListenerManager.instance = new SystemUpdateStatusListenerManager();
    return SystemUpdateStatusListenerManager.instance;
  }

  private constructor() {
  }


  private registerHwNewSystemUpdateStatusDataChange(): void {
    if (this.dataHelper) {
      this.doRegisterDataChange();
    } else {
      (SettingsDataUtils.createDataHelper(HW_NEW_SYSTEM_UPDATE_STATUS) as Promise<dataShare.DataShareHelper>)
        .then((dataShareHelper?:dataShare.DataShareHelper | undefined) => {
          if (dataShareHelper) {
            this.dataHelper = dataShareHelper;
            this.doRegisterDataChange();
          }
        })
        .catch((err: BusinessError) => {
          LogUtil.error(`${TAG} createDataHelper err: ${JSON.stringify(err)}`);
        })
    }
  }

  private doRegisterDataChange(): void {
    SettingsDataUtils.registerDataChange(this.dataHelper,
      HW_NEW_SYSTEM_UPDATE_STATUS,
      this.onSystemUpdateStatusChange);
    this.isRegisterHwNewSystemUpdateStatusDataChange = true;
    LogUtil.info(`${TAG} register success..`)
  }

  private unRegisterHwNewSystemUpdateStatusDataChange(): void {
    if (!this.dataHelper) {
      return;
    }
    SettingsDataUtils.unRegisterDataChange(this.dataHelper, HW_NEW_SYSTEM_UPDATE_STATUS);
    this.isRegisterHwNewSystemUpdateStatusDataChange = false;
    LogUtil.info(`${TAG} unRegister success.`)
  }

  /**
   * 注册系统升级状态变更监听器
   *
   * @param listener 系统升级状态变更监听器
   */
  registerSystemUpdateStatusChangeListener(listener: SystemUpdateStatusListener): void {
    if (listener === null || listener === undefined) {
      return;
    }
    for (const systemUpdateStatusChangeListener of this.systemUpdateStatusChangeListeners) {
      if (systemUpdateStatusChangeListener.getListenName() === listener.getListenName()) {
        return;
      }
    }
    this.systemUpdateStatusChangeListeners.push(listener);
    if (this.systemUpdateStatusChangeListeners.length > 0 && !this.isRegisterHwNewSystemUpdateStatusDataChange) {
      Promise.resolve(this.registerHwNewSystemUpdateStatusDataChange());
    }
  }

  /**
   * 取消注册系统升级状态变更监听器
   *
   * @param listener 系统升级状态变更监听器
   */
  unRegisterSystemUpdateStatusChangeListener(listener: SystemUpdateStatusListener): void {
    if (listener === null || listener === undefined) {
      return;
    }
    for (let index = 0; index < this.systemUpdateStatusChangeListeners.length; index++) {
      if (this.systemUpdateStatusChangeListeners[index].getListenName() === listener.getListenName()) {
        this.systemUpdateStatusChangeListeners.splice(index, 1);
        break;
      }
    }
    if (this.systemUpdateStatusChangeListeners.length === 0 && this.isRegisterHwNewSystemUpdateStatusDataChange) {
      this.unRegisterHwNewSystemUpdateStatusDataChange();
    }
  }
}
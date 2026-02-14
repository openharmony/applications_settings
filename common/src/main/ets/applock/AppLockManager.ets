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

// import appLock from '@hms.security.appLock';
import { AccountUtil } from '../utils/AccountUtil';
import { LogUtil } from '../utils/LogUtil';

/* instrument ignore file */
const TAG: string = 'AppLockManager';

/**
 * The app lock manager.
 *
 * @since 2024-11-20
 */
export class AppLockManager {
  /**
   * To set app lock status.
   *
   * @param enabled True is enable.
   * @returns
   */
  public static async setEnabled(enabled: boolean): Promise<void> {
    LogUtil.info(`${TAG} start setEnabled.${enabled}`);
    try {
      const userId: number = await AccountUtil.getCurrentUserId();
      // const isAuthTypeAllowed: boolean = await AppLockManager.isAuthTypeAllowed(appLock.AuthType.PIN, userId);
      const isAuthTypeAllowed: boolean = await AppLockManager.isAuthTypeAllowed(userId);
      if (!isAuthTypeAllowed) {
        return;
      }
      // await appLock.setEnabled(false, userId);
      LogUtil.info(`${TAG} setEnabled.${userId} success.`);
    } catch (err) {
      LogUtil.error(`${TAG} setEnabled error.${err?.code}-${err?.message}`);
    }
  }

  /**
   * To get auth type.
   *
   * @param authType The auth type.
   * @param userId The user id.
   * @returns True is allowed.
   */
  public static async isAuthTypeAllowed(userId: number): Promise<boolean> {
  // public static async isAuthTypeAllowed(authType: appLock.AuthType, userId: number): Promise<boolean> {
  //   LogUtil.info(`${TAG} isAuthTypeAllowed type ${authType} user id ${userId}`);
    try {
      // const isAuthTypeAllowed: boolean = await appLock.isAuthTypeAllowed(appLock.AuthType.PIN, userId);
      // LogUtil.info(`${TAG} isAuthTypeAllowed result.${isAuthTypeAllowed}`);
      // return isAuthTypeAllowed;
    } catch (err) {
      LogUtil.error(`${TAG} isAuthTypeAllowed error.${err?.code}-${err?.message}`);
    }
    return false;
  }

  /**
   * 判断应用锁是否开启
   *
   * @returns 应用锁功能是否开启
   */
  public static async isAppLockEnabled(): Promise<boolean> {
    try {
      // return await appLock.isEnabled();
    } catch (error) {
      LogUtil.error(`${TAG} try to check appLock whether enabled failed. ${error?.code} ${error?.message}`);
    }
    return false;
  }
}
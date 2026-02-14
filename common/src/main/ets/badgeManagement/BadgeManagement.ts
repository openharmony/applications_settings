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

import type Base from '@ohos.base';
import { LogUtil } from '../utils/LogUtil';

const TAG: string = 'BadgeManagement';

export class BadgeManagement {
  public static requestEnableNotification(): void {
    import('@ohos.notificationManager').then(notificationManager => {
      notificationManager.default.requestEnableNotification().then(() => {
        LogUtil.info(`${TAG} requestEnableNotification success`);
      }).catch((err: Base.BusinessError) => {
        LogUtil.error(`${TAG} requestEnableNotification failed, code is ${err.code}, message is ${err.message}`);
      });
    });
  }

  /**
   * 设置应用角标
   *
   * @param badgeNumber 角标数字
   * @returns 设置角标结果
   */
  public static async setBadgeNumber(badgeNumber: number): Promise<boolean> {
    try {
      let notificationManager = await import('@ohos.notificationManager');
      await notificationManager.default.setBadgeNumber(badgeNumber);
      return true;
    } catch (err) {
      LogUtil.error(`${TAG} setBadgeNumber failed, code is ${err?.code}, message is ${err?.message}`);
      return false;
    }
  }
}
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

import { AccountUtil, LogUtil } from '@ohos/settings.common';
import { HiSysEventUtil } from '@ohos/settings.common/src/main/ets/systemEvent/HiSysEventUtil';
import { HiSysAccessibilityStaticEventGroup } from '@ohos/settings.common/src/main/ets/systemEvent/StaticEventConsts';
import osAccount from '@ohos.account.osAccount';

/* instrument ignore file */
export default class IamHiSysPinEventUtils {

  static async reportPasswordTypeStatus(): Promise<void> {
    LogUtil.info(`reportPasswordTypeStatus start`)
    const userIds = await AccountUtil.getAllSpaceUserIds();
    if (userIds.length === 0) {
      LogUtil.error(`reportPasswordTypeStatus fail`);
      return;
    }
    const userIdentityManager = new osAccount.UserIdentityManager();
    for (let userId of userIds) {
      let getAuthInfoOptions: osAccount.GetAuthInfoOptions = {
        authType: osAccount.AuthType.PIN,
        accountId: userId,
      };
      let enrolledCredInfo : osAccount.EnrolledCredInfo[] = [];
      try {
        enrolledCredInfo = await userIdentityManager.getAuthInfo(getAuthInfoOptions);
      } catch (e) {
        LogUtil.error(`getAuthInfo fail`);
        return;
      }
      if (enrolledCredInfo.length != 1) {
        LogUtil.error(`reportPasswordTypeStatus get length fail`);
        continue;
      }
      const params: Record<string, string | number | boolean> =
        await IamHiSysPinEventUtils.getCustomizedParamStatus(userId, enrolledCredInfo[0].authSubType.toString());
      HiSysEventUtil.reportStatisticEventByUE(HiSysAccessibilityStaticEventGroup.PASSWORD_TYPE_STATUS,
        params);
    }
    LogUtil.info(`reportPasswordTypeStatus success`);
  }

  private static async getCustomizedParamStatus(userId : number, authSubType : string) {
    if (!HiSysEventUtil.applicationVersion) {
      HiSysEventUtil.getApplicationVersion();
    }
    const customizedParams: Record<string, string | number | boolean> = {
      'PNAMEID': HiSysEventUtil.getPkgName(),
      'PVERSIONID': HiSysEventUtil.applicationVersion,
      'USER_ID': userId,
      'AUTH_SUB_TYPE' : Number(authSubType)
    };
    return customizedParams;
  }
}
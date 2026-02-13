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

import abilityDelegatorRegistry from '@ohos.app.ability.abilityDelegatorRegistry';
import { beforeAll, it, describe, afterAll } from '@ohos/hypium';
import { DeviceUtil, LogUtil } from '@ohos/settings.common';
import { Constant } from '../constant/Constant';
import { Driver, ON } from '@ohos.UiTest';
import { COMMON_DELAY } from '../types';
import osAccount from '@ohos.account.osAccount';

const DELEGATOR: abilityDelegatorRegistry.AbilityDelegator = abilityDelegatorRegistry.getAbilityDelegator();
const TAG: string = 'UserPageTest';
const INVALID_INDEX: number = -1;

export default function userPageTest() {
  describe('userPageTest', (): void => {
    beforeAll(async () => {
      try {
        await DELEGATOR.startAbility({
          'bundleName': Constant.SETTINGS_BUNDLE_NAME,
          'abilityName': Constant.SETTINGS_MAIN_ABILITY_NAME,
          'uri': 'current_user'
        }).then(() => {
          LogUtil.info(`${TAG} start user accounts page succcess`);
        })
      } catch (err) {
        LogUtil.error(`${TAG} start user accounts page failed`);
      }
    })

    afterAll(async () => {
      // 定义Driver类
      let dr = Driver.create();
      await dr.delayMs(COMMON_DELAY);
      await dr.pressHome();
      await dr.delayMs(COMMON_DELAY);
    });

    /**
     * @tc.number:userPageTest_001
     * @tc.name: 用户列表界面验证
     * @tc.type: 0 || TestType.FUNCTION || Level.LEVEL0
     * @tc.desc: 1、存在Guest用户，不展示添加访客菜单；2、不存在Guest用户，ADMIN用户展示添加访客菜单
     */
    it('userPageTest_001', 0, async () => {
      try {
        let accountMgr = osAccount.getAccountManager();
        let currentOsAccount = await accountMgr.getCurrentOsAccount();
        let isConstraintCreateAccount = await accountMgr.checkOsAccountConstraintEnabled(currentOsAccount.localId, 'constraint.os.account.create');
        LogUtil.info(`${TAG} currentOsAccount:${currentOsAccount.localId}(${currentOsAccount.type}), isConstraintCreateAccount:${isConstraintCreateAccount}`);
        // 当前多用户创建功能仅手机可用
        if (!DeviceUtil.isDevicePhone() || !DeviceUtil.isDevicePad() || isConstraintCreateAccount) {
          LogUtil.info(`${TAG} multi-user is not supported`);
          return;
        }
        let dr = Driver.create();
        await dr.delayMs(COMMON_DELAY);
        let accountList: Array<osAccount.OsAccountInfo> = await accountMgr.queryAllCreatedOsAccounts();
        let guestAccountIndex = accountList.findIndex((accountInfo: osAccount.OsAccountInfo) => accountInfo?.type === osAccount.OsAccountType.GUEST);
        LogUtil.info(`${TAG} accountList.length:${accountList.length}, guestAccountIndex:${guestAccountIndex}`);
        if (guestAccountIndex !== INVALID_INDEX) {
          // 存在访客账户，用户列表中展示访客账户
          await dr.assertComponentExist(ON.text(Constant.GUEST_USER));
          return;
        }
        if (currentOsAccount.type === osAccount.OsAccountType.ADMIN) {
          // 不存在访客账户，展示添加访客菜单
          await dr.assertComponentExist(ON.text(Constant.ADD_GUEST));
        }
      } catch (err) {
        LogUtil.error(`${TAG} test guest user error`);
      }
    })
  })
}

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

import { abilityDelegatorRegistry } from '@kit.TestKit';
import { describe, it, beforeAll, afterAll, expect } from '@ohos/hypium';
import { Driver, ON } from '@ohos.UiTest';
import { LogUtil } from '@ohos/settings.common/src/main/ets/utils/LogUtil';
import { NewVersionViewStatus } from '@ohos/settings.systemUpdate/src/main/ets/model/NewVersionViewStatusModel';
import { SettingsDataUtils } from '@ohos/settings.common/src/main/ets/utils/SettingsDataUtils';
import { COMMON_DELAY, WAIT_DELAY } from '../types';

const TAG: string = 'AllSceneBadgeTest';
const DELEGATOR: abilityDelegatorRegistry.AbilityDelegator = abilityDelegatorRegistry.getAbilityDelegator();
const HW_NEW_SYSTEM_UPDATE_STATUS = 'hw_new_system_update_status';
const HW_NEW_SYSTEM_UPDATE = 'hw_new_system_update';
const ALL_SCENE_MENU_ITEM_INFO = 'all_scene_settings_menu_item_info';

export default function allSceneBadgeTest() {
  describe('allSceneBadgeTest', () => {
    // 定义Driver类
    let dr: Driver | null = null;
    beforeAll(async () => {
      // 跳转至关于本机页面
      try {
        await DELEGATOR.startAbility({
          'bundleName': 'com.ohos.settings',
          'abilityName': 'com.ohos.settings.MainAbility',
        }).then(() => {
          LogUtil.info(`${TAG} com.ohos.settings.MainAbility start success`);
        });
      } catch (exception) {
        LogUtil.info(`Failed to startAbility. code: ${exception?.code}, message: ${exception?.message}`);
      };
    });

    afterAll(async () => {
      // 定义Driver类
      dr = Driver.create();
      await dr.delayMs(COMMON_DELAY);
      // 点击返回按钮到设置页面
      let settingsBackIcon = await dr.waitForComponent(ON.type('BackButton'), WAIT_DELAY);
      await settingsBackIcon.click();
      await dr.delayMs(COMMON_DELAY);
      await dr.pressHome();
      await dr.delayMs(COMMON_DELAY);
    });

    /*
    * @tc.number:allSceneBadgeTest_001
    * @tc.name: 无协同版本
    * @tc.type: 0 || TestType.FUNCTION  || Level.LEVEL0
    * @tc.desc: 无角标
    */
    it('allSceneBadgeTest_001', 0, allSceneBadgeTest_001);

    /*
    * @tc.number:allSceneBadgeTest_002
    * @tc.name: 有协同版本
    * @tc.type: 0 || TestType.FUNCTION  || Level.LEVEL0
    * @tc.desc: 设备名称右边显示升级状态
    */
    it('allSceneBadgeTest_002', 0, allSceneBadgeTest_002);
  });
}

async function allSceneBadgeTest_001() {
  LogUtil.info(`${TAG} allSceneBadgeTest_001 start`);
  try {
    SettingsDataUtils.setSettingsData(HW_NEW_SYSTEM_UPDATE, '0');
    SettingsDataUtils.setSettingsData(ALL_SCENE_MENU_ITEM_INFO, '');
    // 定义Driver类
    let dr = Driver.create();
    await dr.delayMs(COMMON_DELAY);
    let badgeText1 = await dr.waitForComponent(ON.id('AboutDeviceItemView_badge_text1'), WAIT_DELAY);
    let badgeText2 = await dr.waitForComponent(ON.id('AboutDeviceItemView_badge_text2'), WAIT_DELAY);
    expect(badgeText1).assertNull();
    expect(badgeText2).assertNull();
  } catch {
    LogUtil.error(`${TAG} allSceneBadgeTest_001 execute exception failed!`);
  }
}

async function allSceneBadgeTest_002() {
  LogUtil.info(`${TAG} allSceneBadgeTest_002 start`);
  try {
    // 定义Driver类
    let dr = Driver.create();
    await dr.delayMs(COMMON_DELAY);

    SettingsDataUtils.setSettingsData(HW_NEW_SYSTEM_UPDATE, '0');
    SettingsDataUtils.setSettingsData(ALL_SCENE_MENU_ITEM_INFO, '{"isShowMenuItem":true,"isShowBadge":true}');
    let badgeText1 = await dr.waitForComponent(ON.id('AboutDeviceItemView_badge_text1'), WAIT_DELAY);
    let badgeText2 = await dr.waitForComponent(ON.id('AboutDeviceItemView_badge_text2'), WAIT_DELAY);
    expect(badgeText1).assertNull();
    expect(badgeText2).assertNull();

    await dr.delayMs(COMMON_DELAY);
    SettingsDataUtils.setSettingsData(HW_NEW_SYSTEM_UPDATE, '1');
    SettingsDataUtils.setSettingsData(HW_NEW_SYSTEM_UPDATE_STATUS, NewVersionViewStatus.VIEW_DOWNLOADING.toString());
    SettingsDataUtils.setSettingsData(ALL_SCENE_MENU_ITEM_INFO, '{"isShowMenuItem":true,"isShowBadge":true}');
    badgeText2 = await dr.waitForComponent(ON.id('AboutDeviceItemView_badge_text2'), WAIT_DELAY);
    expect(await badgeText2?.getText?.() === '新版本下载中').assertInstanceOf('Boolean');
  } catch {
    LogUtil.error(`${TAG} allSceneBadgeTest_002 execute exception failed!`);
  }
}
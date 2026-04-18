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

import { describe, it, beforeAll, afterAll, expect } from '@ohos/hypium';
import { Driver, ON } from '@ohos.UiTest';
import abilityDelegatorRegistry from '@ohos.app.ability.abilityDelegatorRegistry';
import { LogUtil, NavEntryKey, SettingsDataUtils } from '@ohos/settings.common';
import { COMMON_DELAY, WAIT_DELAY } from '../../types';

const DELEGATOR: abilityDelegatorRegistry.AbilityDelegator = abilityDelegatorRegistry.getAbilityDelegator();
const TAG: string = 'AllSceneMenuItemTest';
const ALL_SCENE_MENU_ITEM_INFO = 'all_scene_settings_menu_item_info';

export default function allSceneMenuItemTest() {
  describe('allSceneMenuItemTest', () => {
    // 定义Driver类
    let dr: Driver | null = null;
    beforeAll(async () => {
      // 跳转到关于本机界面
      await startAboutDevicePage();
    });

    afterAll(async () => {
      // 定义Driver类
      dr = Driver.create();
      await dr.delayMs(COMMON_DELAY);
      // 点击返回按钮到设置页面
      let settingsBackIcon = await dr.waitForComponent(ON.type('BackButtonImage'), WAIT_DELAY);
      await settingsBackIcon.click();
      await dr.delayMs(COMMON_DELAY);
      await dr.pressHome();
      await dr.delayMs(COMMON_DELAY);
    });

    /*
    * @tc.number:allSceneMenuItemTest_001
    * @tc.name: 协同更新菜单验证
    * @tc.type: 0 || TestType.FUNCTION  || Level.LEVEL0
    * @tc.desc: 显示协同更新菜单项
    */
    it('allSceneMenuItemTest_001', 0, allSceneMenuItemTest_001);

    /*
    * @tc.number:allSceneMenuItemTest_002
    * @tc.name: 协同更新菜单验证
    * @tc.type: 0 || TestType.FUNCTION  || Level.LEVEL0
    * @tc.desc: 不显示协同更新菜单项
    */
    it('allSceneMenuItemTest_002', 0, allSceneMenuItemTest_002);
  });
}

async function startAboutDevicePage() {
  try {
    await DELEGATOR.startAbility({
      'bundleName': 'com.ohos.settings',
      'abilityName': 'com.ohos.settings.MainAbility',
      'uri': NavEntryKey.ABOUT_DEVICE_ENTRY,
    }).then(() => {
      LogUtil.info(`${TAG} com.ohos.settings.MainAbility start success`);
    });
  } catch (exception) {
    LogUtil.info(`${TAG} Failed to startAbility. Code: ${exception?.code}, message: ${exception?.message}`);
  }
}

async function allSceneMenuItemTest_001() {
  LogUtil.info(`${TAG} allSceneMenuItemTest_001 start`);
  try {
    SettingsDataUtils.setSettingsData(ALL_SCENE_MENU_ITEM_INFO,
      '{"isShowMenuItem":true,"menuItemTitle":"其他设备发现新版本","menuItemContent":"我的耳机","deviceCount":1}');
    // 定义Driver类
    let dr = Driver.create();
    await dr.delayMs(COMMON_DELAY);
    let title = await dr.waitForComponent(ON.id('AllSceneMenuItemView_title'), WAIT_DELAY);
    let content = await dr.waitForComponent(ON.id('AllSceneMenuItemView_content'), WAIT_DELAY);
    expect(await title.getText() === '其他设备发现新版本').assertTrue();
    expect(await content.getText() === '我的耳机').assertTrue();
  } catch {
    LogUtil.error(`${TAG} allSceneMenuItemTest_001 execute exception failed!`);
  }
}

async function allSceneMenuItemTest_002() {
  LogUtil.info(`${TAG} allSceneMenuItemTest_002 start`);
  try {
    SettingsDataUtils.setSettingsData(ALL_SCENE_MENU_ITEM_INFO,
      '{"isShowMenuItem":false,"menuItemTitle":"其他设备发现新版本","menuItemContent":"我的耳机","deviceCount":1}');
    // 定义Driver类
    let dr = Driver.create();
    await dr.delayMs(COMMON_DELAY);
    let title = await dr.waitForComponent(ON.id('AllSceneMenuItemView_title'), WAIT_DELAY);
    let content = await dr.waitForComponent(ON.id('AllSceneMenuItemView_content'), WAIT_DELAY);
    expect(await title.getText() === '其他设备发现新版本').assertFalse();
    expect(await content.getText() === '我的耳机').assertFalse();
  } catch {
    LogUtil.error(`${TAG} allSceneMenuItemTest_002 execute exception failed!`);
  }
}

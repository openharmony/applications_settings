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

import { describe, it, beforeAll, afterAll } from '@ohos/hypium';
import { Driver, ON } from '@ohos.UiTest';
import abilityDelegatorRegistry from '@ohos.app.ability.abilityDelegatorRegistry';
import { LogUtil, NavEntryKey } from '@ohos/settings.common';
import { COMMON_DELAY, WAIT_DELAY } from '../types';
import { Constant } from '../constant/Constant';

const DELEGATOR: abilityDelegatorRegistry.AbilityDelegator = abilityDelegatorRegistry.getAbilityDelegator();

export default function OucAboutDeviceCardTest() {
  describe('OucAboutDeviceCardTest', () => {
    // 定义Driver类
    let dr: Driver | null = null;
    beforeAll(async () => {
    });

    afterAll(async () => {
      // 定义Driver类
      dr = await Driver.create();
      await dr.delayMs(COMMON_DELAY);
      // 点击返回按钮到设置页面
      let settingsBackIcon = await dr.waitForComponent(ON.type('BackButton'), WAIT_DELAY);
      await settingsBackIcon.click();
      await dr.delayMs(COMMON_DELAY);
      await dr.pressHome();
      await dr.delayMs(COMMON_DELAY);
    });

    /*
    * @tc.number:OucAboutDeviceCardTest_001
    * @tc.name: 正常点击进入软件更新，返回关于手机
    * @tc.type: 0 || TestType.FUNCTION  || Level.LEVEL0
    * @tc.desc: 成功进入软件更新页面
    */
    it('OucAboutDeviceCardTest_001', 0, OucAboutDeviceCardTest_001);
    
    /*
    * @tc.number:OucAboutDeviceCardTest_002
    * @tc.name: 软件更新通知跳转验证，第一次走aboutToAppear，第二次走UIExtensionProxy.send
    * @tc.type: 0 || TestType.FUNCTION  || Level.LEVEL0
    * @tc.desc: 成功进入软件更新页面
    */
    it('OucAboutDeviceCardTest_002', 0, OucAboutDeviceCardTest_002);

    /*
    * @tc.number:OucAboutDeviceCardTest_003
    * @tc.name: 设置搜索以及返回手势
    * @tc.type: 0 || TestType.FUNCTION  || Level.LEVEL0
    * @tc.desc: 成功进入软件更新页面
    */
    it('OucAboutDeviceCardTest_003', 0, OucAboutDeviceCardTest_003);
  });
}

async function OucAboutDeviceCardTest_001() {
  LogUtil.info(`${Constant.TAG} OucAboutDeviceCardTest_001 start`);
  try {
    // 定义Driver类
    let dr: Driver = await Driver.create()
    await dr.delayMs(COMMON_DELAY);
    await DELEGATOR.startAbility({
      'bundleName': 'com.ohos.settings',
      'abilityName': 'com.ohos.settings.MainAbility',
      'uri': NavEntryKey.ABOUT_DEVICE_ENTRY,
    }).then(() => {
      LogUtil.info(`${Constant.TAG} com.ohos.settings.MainAbility start success`);
    });
    await dr.delayMs(COMMON_DELAY);
    // 在控件上滑动查找目标控件
    const START_X: number = 200;
    const START_Y: number = 397;
    const END_X: number = 260;
    const END_Y: number = 1900;
    const SPEED: number = 3000;
    // 在控件上滑动查找目标控件
    await dr.swipe(START_X, START_Y, END_X, END_Y, SPEED);
    // 校验状态信息存在
    await dr.assertComponentExist(ON.id('com.ohos.settings.about.ouc'));
    let oucTab = await dr.waitForComponent(ON.id('com.ohos.settings.about.ouc'), WAIT_DELAY);
    await oucTab.click();
    LogUtil.info(`${Constant.TAG} oucTab click`);
    await dr.delayMs(COMMON_DELAY);
    await dr.pressBack();
    await dr.delayMs(COMMON_DELAY);
    await oucTab.click();
    await dr.delayMs(COMMON_DELAY);
    await dr.pressBack();
    await dr.delayMs(COMMON_DELAY);
    await dr.pressBack();
  } catch {
    LogUtil.error(`${Constant.TAG} OucAboutDeviceCardTest_001 execute exception failed!`);
  }
}

async function OucAboutDeviceCardTest_002() {
  LogUtil.info(`${Constant.TAG} OucAboutDeviceCardTest_002 start`);
  try {
    // 定义Driver类
    let dr: Driver = await Driver.create()
    await dr.delayMs(COMMON_DELAY);
    await DELEGATOR.startAbility({
      'bundleName': 'com.ohos.settings',
      'abilityName': 'com.ohos.settings.MainAbility',
      'uri': NavEntryKey.OUC_SOFTWARE_UPDATE_SETTINGS,
      parameters: {
        'subUri': 'com_hmos_ouc_software_update_settings',
      },
    }).then(() => {
      LogUtil.info(`${Constant.TAG} com.ohos.settings.MainAbility start success`);
    });
    await dr.delayMs(COMMON_DELAY);
    await DELEGATOR.startAbility({
      'bundleName': 'com.ohos.settings',
      'abilityName': 'com.ohos.settings.MainAbility',
      'uri': NavEntryKey.OUC_SOFTWARE_UPDATE_SETTINGS,
      parameters: {
        'subUri': 'com_hmos_ouc_config_settings',
      },
    }).then(() => {
      LogUtil.info(`${Constant.TAG} com.ohos.settings.MainAbility start success`);
    });
    await dr.delayMs(COMMON_DELAY);
    await dr.assertComponentExist(ON.text(Constant.SOFTWARE_UPDATE_NIGHT_UPGRADE));
    await dr.pressBack();
    await dr.delayMs(COMMON_DELAY);
    await dr.pressBack();
    await dr.delayMs(COMMON_DELAY);
    await dr.pressBack();
  } catch {
    LogUtil.error(`${Constant.TAG} OucAboutDeviceCardTest_002 execute exception failed!`);
  }
}

async function OucAboutDeviceCardTest_003() {
  LogUtil.info(`${Constant.TAG} OucAboutDeviceCardTest_003 start`);
  try {
    // 定义Driver类
    let dr: Driver = await Driver.create()
    await dr.delayMs(COMMON_DELAY);
    await DELEGATOR.startAbility({
      'bundleName': 'com.ohos.settings',
      'abilityName': 'com.ohos.settings.MainAbility',
    }).then(() => {
      LogUtil.info(`${Constant.TAG} com.ohos.settings.MainAbility start success`);
    });
    await dr.delayMs(COMMON_DELAY);

    // 定义Driver的类;
    dr = await Driver.create();
    await dr.delayMs(COMMON_DELAY);

    // 点击'设置搜索'菜单
    let searchSettingsTab = await dr.findComponent(ON.id('homPageSearchInput'));
    await searchSettingsTab.click();
    await dr.delayMs(COMMON_DELAY);
    LogUtil.info(`${Constant.TAG} searchSettingsTab clicked`);

    // 搜索框中输入内容
    let searchTab = await dr.waitForComponent(ON.id('searchComponent'), WAIT_DELAY);
    await searchTab.inputText('软件更新');

    // 点击第一个搜索结果;
    let firstSearchTab = await dr.waitForComponent(ON.type('ListItem').isAfter(ON.id('searchComponent')),WAIT_DELAY);
    await firstSearchTab.click();
    LogUtil.info(`${Constant.TAG} firstSearchTab clicked`);
    await dr.delayMs(WAIT_DELAY);

    // 返回手势 到输入框
    await dr.pressBack();
    await dr.delayMs(COMMON_DELAY);
    // 返回手势 关闭键盘
    await dr.pressBack();
    await dr.delayMs(COMMON_DELAY);
    // 返回手势 到设置主界面
    await dr.pressBack();
    await dr.delayMs(COMMON_DELAY);
  } catch {
    LogUtil.error(`${Constant.TAG} OucAboutDeviceCardTest_003 execute exception failed!`);
  }
}
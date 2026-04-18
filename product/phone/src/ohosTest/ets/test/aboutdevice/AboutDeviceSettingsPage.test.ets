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
import { LogUtil } from '@ohos/settings.common/src/main/ets/utils/LogUtil';
import { NavEntryKey } from '@ohos/settings.common/src/main/ets/utils/Consts';
import { BusinessError } from '@ohos.base';
import { COMMON_DELAY, WAIT_DELAY } from '../types';
import { Constant } from '../constant/Constant';
import { AccountUtil } from '@ohos/settings.common/src/main/ets/utils/AccountUtil';
import { AccountConstants } from '@ohos/settings.common/src/main/ets/constant/AccountConstants';

const DELEGATOR: abilityDelegatorRegistry.AbilityDelegator = abilityDelegatorRegistry.getAbilityDelegator();
const TAG: string = 'Settingstest';

export default function aboutDeviceSettingsPageTest() {
  describe('aboutDeviceSettingsPageTest', () => {
    beforeAll(beforeAllTest);

    afterAll(afterAllTest);

    /*
    * @tc.number:AboutDeviceSettingsPageTest_001
    * @tc.name: 关于本机入口测试
    * @tc.type: 0 || TestType.FUNCTION  || Level.LEVEL0
    * @tc.desc: 进入关于本机页面正常，点击左上角可返回至设置页面
    */
    // it('aboutDevicePageTest', 0, aboutDevicePageTest);

    /**
     * @tc.number:AboutDeviceSettingsPageTest_002
     * @tc.name: 测试点击法律信息
     * @tc.type: 0 || TestType.FUNCTION  || Level.LEVEL0
     * @tc.desc: 进入法律信息界面，确保界面显示正常
     */
    // it('legalInformationTest', 0, legalInformationTest);

    /**
     * @tc.number:basicServicesTest
     * @tc.name: 测试点击基础服务声明
     * @tc.type: 0 || TestType.FUNCTION  || Level.LEVEL0
     * @tc.desc: 进入基础服务声明页面正常
     */
    // it('basicServicesTest', 0, basicServicesTest);

    /**
     * @tc.number:AboutDeviceSettingsPageTest_004
     * @tc.name: 测试点击参数版本
     * @tc.type: 0 || TestType.FUNCTION  || Level.LEVEL0
     * @tc.desc: 进入参数版本页面正常
     */
    // it('versionPageTest', 0, versionPageTest);

    /**
     * @tc.number:AboutDeviceSettingsPageTest_005
     * @tc.name: 测试点击应用开源声明
     * @tc.type: 0 || TestType.FUNCTION  || Level.LEVEL0
     * @tc.desc: 进入应用开源声明界面，确保界面显示正常
     */
    // it('openSourceTest', 0, openSourceTest);

    /**
     * @tc.number:permissionAgreementTest
     * @tc.name: 测试点击最终用户软件许可协议
     * @tc.type: 0 || TestType.FUNCTION  || Level.LEVEL0
     * @tc.desc: 进入最终用户软件许可协议界面，确保界面显示正常
     */
    // it('permissionAgreementTest', 0, permissionAgreementTest);

    /**
     * @tc.number:permissionAgreementTest
     * @tc.name: 测试点击状态信息
     * @tc.type: 0 || TestType.FUNCTION  || Level.LEVEL0
     * @tc.desc: 进入最终用户软件许可协议界面，确保界面显示正常
     */
    // it('statusInformationTest', 0, statusInformationTest);

    /**
     * @tc.number:DisplayVersionTest
     * @tc.name: 测试隐私用户信息
     * @tc.type: 0 || TestType.FUNCTION  || Level.LEVEL0
     * @tc.desc: 确保隐私用户接口返回正常
     */
    it('DisplayVersionTest', 0, displayVersionTest);
  })
}

async function beforeAllTest() {
  // 跳转至关于本机页面
  try {
    await DELEGATOR.startAbility({
      'bundleName': 'com.ohos.settings',
      'abilityName': 'com.ohos.settings.MainAbility',
      'uri': NavEntryKey.ABOUT_DEVICE_ENTRY,
    }).then(() => {
      LogUtil.info(`${TAG} com.ohos.settings.MainAbility start success`);
    });
  }
  catch (exception) {
    LogUtil.info(`Failed to startAbility. Code: ${(exception as BusinessError).code}, message: ${(exception as BusinessError).message}`);
  };
}

async function afterAllTest() {
  // 定义Driver类
  let dr = await Driver.create();
  await dr.delayMs(COMMON_DELAY);
  // 点击返回按钮到设置页面
  let settingsBackIcon = await dr.waitForComponent(ON.type('BackButton'), WAIT_DELAY);
  await settingsBackIcon.click();
  await dr.delayMs(COMMON_DELAY);
  await dr.pressHome();
  await dr.delayMs(COMMON_DELAY);
}

/*async function aboutDevicePageTest() {
  LogUtil.info(`${TAG} aboutDeviceSettingsPageTest start`);
  // 定义Driver类
  let dr = await Driver.create();
  await dr.delayMs(COMMON_DELAY);
  // 校验关于本机页面存在以下入口
  // 在控件上滑动查找目标控件
  const START_X: number = 260;
  const START_Y: number = 1900;
  const END_X: number = 200;
  const END_Y: number = 397;
  const SPEED: number = 3000;
  await dr.swipe(START_X, START_Y, END_X, END_Y, SPEED);
  await dr.swipe(START_X, START_Y, END_X, END_Y, SPEED); // 滑动两次，避免无法滑动到底部
  await dr.assertComponentExist(ON.text(Constant.PARAMETER_VERSION_TITLE));
  await dr.assertComponentExist(ON.text(Constant.LEGAL_INFORMATION));
  LogUtil.info(`${TAG} aboutDeviceSettingsPageTest end`);
}*/

async function legalInformationTest() {
  LogUtil.info(`${TAG} LEGAL_INFORMATIONTest start`);
  // 定义Driver类
  let dr = await Driver.create();
  await dr.delayMs(COMMON_DELAY);
  // 在控件上滑动查找目标控件
  const START_X: number = 260;
  const START_Y: number = 1900;
  const END_X: number = 200;
  const END_Y: number = 397;
  const SPEED: number = 3000;
  await dr.swipe(START_X, START_Y, END_X, END_Y, SPEED);
  await dr.swipe(START_X, START_Y, END_X, END_Y, SPEED); // 滑动两次，避免无法滑动到底部
  // 点击返回按钮到上一级页面
  let aboutDeviceBackIcon = await dr.waitForComponent(ON.type('BackButton'), WAIT_DELAY);
  await aboutDeviceBackIcon.click();
  LogUtil.info(`${TAG} AboutDeviceSettingsPageTest_002 end`);
}

async function basicServicesTest() {
  LogUtil.info(`${TAG} basicServicesTest start`);
  // 定义Driver类
  let dr = await Driver.create();
  await dr.delayMs(COMMON_DELAY);
  // 点击返回按钮到关于本机页面
  backIcon = await dr.waitForComponent(ON.type('BackButton'), WAIT_DELAY);
  await backIcon.click();
  await dr.delayMs(COMMON_DELAY);
  await dr.assertComponentExist(ON.text(Constant.ABOUT_DEVICE));
  LogUtil.info(`${TAG} basicServicesTest end`);
}

async function versionPageTest() {
  LogUtil.info(`${TAG} versionPageTest start`);
  // 定义Driver类
  let dr = await Driver.create();
  await dr.delayMs(COMMON_DELAY);
  // 在控件上滑动查找目标控件
  const START_X: number = 260;
  const START_Y: number = 1900;
  const END_X: number = 200;
  const END_Y: number = 397;
  const SPEED: number = 3000;
  // 在控件上滑动查找目标控件
  await dr.swipe(START_X, START_Y, END_X, END_Y, SPEED);
  let systemParamTab = await dr.waitForComponent(ON.text('参数版本'), WAIT_DELAY);
  await systemParamTab.click();
  LogUtil.info(`${TAG} systemParamTab clicked`);
  await dr.delayMs(COMMON_DELAY);
  let aboutDeviceBackIcon = await dr.waitForComponent(ON.type('BackButton'), WAIT_DELAY);
  await aboutDeviceBackIcon.click();
  LogUtil.info(`${TAG} versionPageTest end`);
}

async function openSourceTest() {
  LogUtil.info(`${TAG} openSourceTest start`);
  // 定义Driver类
  let dr = await Driver.create();
  await dr.delayMs(COMMON_DELAY);
  await dr.assertComponentExist(ON.text(Constant.CALCULATORS));
  await dr.assertComponentExist(ON.text(Constant.GALLERY));
  // 点击返回按钮到上一级页面
  let aboutDeviceBackIcon = await dr.waitForComponent(ON.type('BackButton'), WAIT_DELAY);
  await aboutDeviceBackIcon.click();
  await dr.delayMs(COMMON_DELAY);
  aboutDeviceBackIcon = await dr.waitForComponent(ON.type('BackButton'), WAIT_DELAY);
  await aboutDeviceBackIcon.click();
  LogUtil.info(`${TAG} openSourceTest end`);
}

async function permissionAgreementTest() {
  LogUtil.info(`${TAG} permissionAgreementTest start`);
  // 定义Driver类
  let dr = await Driver.create();
  await dr.delayMs(COMMON_DELAY);
  // 点击返回按钮到上一级页面
  let aboutDeviceBackIcon = await dr.waitForComponent(ON.type('BackButton'), WAIT_DELAY);
  await aboutDeviceBackIcon.click();
  await dr.delayMs(COMMON_DELAY);
  aboutDeviceBackIcon = await dr.waitForComponent(ON.type('BackButton'), WAIT_DELAY);
  await aboutDeviceBackIcon.click();
  LogUtil.info(`${TAG} permissionAgreementTest end`);
}

async function statusInformationTest() {
  LogUtil.info(`${TAG} statusInformationTest start`);
  // 定义Driver类
  let dr = await Driver.create();
  await dr.delayMs(COMMON_DELAY);
  // 校验状态信息存在
  await dr.assertComponentExist(ON.text(Constant.STATUS_INFORMATION));
  let statusInfoTab = await dr.waitForComponent(ON.text(Constant.STATUS_INFORMATION),WAIT_DELAY);
  await statusInfoTab.click();
  await dr.delayMs(COMMON_DELAY);
  // 校验网络
  await dr.assertComponentExist(ON.text(Constant.NETWORK_INFORMATION));
  await dr.assertComponentExist(ON.text(Constant.BLUETOOH_ADRESS));
  await dr.assertComponentExist(ON.text(Constant.BATTERY_LEVEL));
  // 点击返回按钮到上一级页面
  let aboutDeviceBackIcon = await dr.waitForComponent(ON.type('BackButton'), WAIT_DELAY);
  await aboutDeviceBackIcon.click();
  await dr.delayMs(COMMON_DELAY);
  aboutDeviceBackIcon = await dr.waitForComponent(ON.type('BackButton'), WAIT_DELAY);
  await aboutDeviceBackIcon.click();
  LogUtil.info(`${TAG} statusInformationTest end`);
}

async function displayVersionTest() {
  LogUtil.info(`${TAG} displayVersionTest start`);
  // 定义Driver类
  let dr = await Driver.create();
  await dr.delayMs(COMMON_DELAY);
  let userId = await AccountUtil.getPrivateSpaceUserId();
  expect(userId >= AccountConstants.INVALID_PRIVATE_SPACE_USER_ID).assertTrue();
}
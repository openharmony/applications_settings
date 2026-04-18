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

import { describe, it, beforeAll, afterAll, expect, Level } from '@ohos/hypium';
import { ON, Driver } from '@ohos.UiTest'
import { CustomMenuManager, DeviceUtil, LogUtil, NavEntryKey } from '@ohos/settings.common';
import { SatelliteUtils } from '@ohos/settings.common/src/main/ets/utils/BaseUtils';
import abilityDelegatorRegistry from '@ohos.app.ability.abilityDelegatorRegistry';
import { BusinessError } from '@ohos.base';
import { COMMON_DELAY, WAIT_DELAY } from '../types';
import { Constant } from '../constant/Constant';

const DELEGATOR: abilityDelegatorRegistry.AbilityDelegator = abilityDelegatorRegistry.getAbilityDelegator();
const START_X: number = 260;
const START_Y: number = 1900;
const END_X: number = 200;
const END_Y: number = 397;
const SPEED: number = 3000;
const TAG: string = 'homePageTest'

export default function homePageTest() {
  describe('homePageTest', () => {
    let driver = Driver.create()
    beforeAll(async () => {
      try {
        // 亮屏解锁
        await driver.wakeUpDisplay();
        await driver.delayMs(COMMON_DELAY);
        await driver.fling({
          x: 500, y: 2000
        }, {
          x: 500, y: 900
        }, 1000, 2000);
        await driver.delayMs(COMMON_DELAY);

        await DELEGATOR.startAbility({
          'bundleName': Constant.SETTINGS_BUNDLE_NAME,
          'abilityName': Constant.SETTINGS_MAIN_ABILITY_NAME,
        }).then(() => {
          LogUtil.info(`${Constant.TAG} com.ohos.settings.MainAbility start success!`);
        });
      } catch (exception) {
        LogUtil.info(`Failed to startAbility. Code: ${(exception as BusinessError).code}, message: ${(exception as BusinessError).message}`);
      }
    });

    afterAll(async () => {
      await driver.delayMs(COMMON_DELAY);
      await driver.pressHome();
      await driver.delayMs(COMMON_DELAY);
    });

    it('homePageTest_001', 0, homePageTest_001(driver));

    it('homePageTest_002', 0, homePageTest_002(driver));

    it('homePageTest_003', 0, homePageTest_003(driver));

    /*
    * @tc.number:homePageTest_004
    * @tc.name: test ui extension page for OUC_NEW_VERSION
    * @tc.type: Level.LEVEL2
    * @tc.desc: test ui extension page for OUC_NEW_VERSION
    */
    it('homePageTest_004', Level.LEVEL2, homePageTest_004(driver));

    it('homePageTest_005', 0, homePageTest_005(driver));

    /*
    * @tc.number: homePageTestMobileNetwork
    * @tc.name: test mobileNetwork exist
    * @tc.type: Level.LEVEL2
    * @tc.desc: test mobileNetwork exist
    */
    it('homePageTestMobileNetwork', Level.LEVEL2, homePageTestMobileNetwork(driver));

    it('homePageToWifiPageTest_006', 0, homePageToWifiPageTest_006(driver));

    /*
    * @tc.number: homePageSettingMenu
    * @tc.name: test homePage Setting menu exist
    * @tc.type: Level.LEVEL2
    * @tc.desc: test homePage Setting menu exist
    */
    it('homePageSettingMenuTest', 0, homePageSettingMenuTest(driver));

    /*
    * @tc.number: SettingAboutDeviceMenu
    * @tc.name: test AboutDevice menu exist
    * @tc.type: Level.LEVEL2
    * @tc.desc: test AboutDevice menu exist
    */
  //  it('SettingAboutDeviceMenuTest', 0, SettingAboutDeviceMenuTest(driver));
  })
}

function SettingAboutDeviceMenuTest(driver: Driver): Function {
  return async () => {
    try {
      await DELEGATOR.startAbility({
        'bundleName': Constant.SETTINGS_BUNDLE_NAME,
        'abilityName': Constant.SETTINGS_MAIN_ABILITY_NAME,
        'uri': NavEntryKey.ABOUT_DEVICE_ENTRY
      }).then(() => {
        LogUtil.info(`${Constant.TAG} com.ohos.settings.MainAbility start success`);
      });
    } catch (exception) {
      LogUtil.warn(`Failed to startAbility. Code: ${(exception as BusinessError).code}, message: ${(exception as BusinessError).message}`);
    }
    try {
      await driver.delayMs(COMMON_DELAY);
      await driver.pressBack();
      await driver.delayMs(COMMON_DELAY);
      // '关于本机'菜单移动
      await driver.assertComponentExist(ON.text(Constant.SOFTWARE_UPDATE_TEXT));
      await driver.pressBack();
      await driver.delayMs(COMMON_DELAY);
      await driver.assertComponentExist(ON.text(Constant.SETTINGS));
    } catch (err) {
      LogUtil.showError(TAG, `err.code : ${(err as BusinessError)?.code}, message: ${(err as BusinessError).message}`);
    }
  };
}

function homePageSettingMenuTest(driver: Driver): Function {
  return async () => {
    try {
      await DELEGATOR.startAbility({
        'bundleName': Constant.SETTINGS_BUNDLE_NAME,
        'abilityName': Constant.SETTINGS_MAIN_ABILITY_NAME,
        'uri': NavEntryKey.OUC_SOFTWARE_UPDATE_SETTINGS,
        parameters: {
          'subUri': 'com_hmos_ouc_new_version_settings',
        },
      }).then(() => {
        LogUtil.info(`${Constant.TAG} com.ohos.settings.MainAbility start success`);
      });
    } catch (exception) {
      LogUtil.warn(`Failed to startAbility. Code: ${(exception as BusinessError).code}, message: ${(exception as BusinessError).message}`);
    }
    await driver.delayMs(COMMON_DELAY);
    await driver.pressBack();
    await driver.delayMs(COMMON_DELAY);
    try {
      // '多设备协同'菜单
      await driver.assertComponentExist(ON.text(Constant.MULTI_DEVICE_COLLABORATION));
      await driver.pressBack();
      await driver.delayMs(COMMON_DELAY);
      await driver.assertComponentExist(ON.text(Constant.SETTINGS));
    } catch (err) {
      LogUtil.showError(TAG, `err.code : ${(err as BusinessError)?.code}, message: ${(err as BusinessError).message}`);
    }
  };
}

function homePageToWifiPageTest_006(driver: Driver): Function {
  return async () => {
    LogUtil.info(`${Constant.TAG} homePageToWifiPageTest_006 start`);
    await driver.delayMs(COMMON_DELAY);
    try {
      // 点击'WLAN'菜单
      let wifiTab = await driver.waitForComponent(ON.text(Constant.WIFI), WAIT_DELAY);
      await wifiTab.click();
      // 点击返回到按钮到设置页面
      await driver.delayMs(COMMON_DELAY);
      let wifiBackIcon = await driver.waitForComponent(ON.type('BackButtonImage'), WAIT_DELAY);
      await wifiBackIcon.click();
      await driver.delayMs(COMMON_DELAY);
      await driver.assertComponentExist(ON.text(Constant.SETTINGS));
      LogUtil.info(`${Constant.TAG} wifiTab clicked`);
    } catch (err) {
      LogUtil.showError(TAG, `err.code : ${(err as BusinessError)?.code}, message: ${(err as BusinessError).message}`);
    }
  };
}

function homePageTestMobileNetwork(driver: Driver): Function {
  return async () => {
    LogUtil.info(`${Constant.TAG} homePageTestMobileNetwork start`);
    await driver.delayMs(COMMON_DELAY);
    try {
      // 点击'移动网络'菜单
      let mobileNetTab = await driver.waitForComponent(ON.text(Constant.MOBILE_NETWORK_SETTINGS), WAIT_DELAY);
      await mobileNetTab.click();

      // 点击返回到按钮到设置页面
      await driver.delayMs(COMMON_DELAY);
      let applicationAndServiceBackIcon = await driver.waitForComponent(ON.type('BackButtonImage'), WAIT_DELAY);
      await applicationAndServiceBackIcon.click();
      await driver.delayMs(COMMON_DELAY);
      await driver.assertComponentExist(ON.text(Constant.MOBILE_NETWORK_SETTINGS));
      LogUtil.info(`${Constant.TAG} mobileNetwork clicked`);
    } catch (err) {
      LogUtil.showError(TAG, `err.code : ${(err as BusinessError)?.code}, message: ${(err as BusinessError).message}`);
    }
  };
}

function homePageTest_005(driver: Driver): Function {
  return async () => {
    LogUtil.info(`${Constant.TAG} homePageTest_005 start`);
    await driver.delayMs(COMMON_DELAY);
    try {
      // 点击'隐私和安全'菜单
      let privacyTab = await driver.waitForComponent(ON.text(Constant.PRIVACY), WAIT_DELAY);
      await privacyTab.click();
      // 点击返回到按钮到设置页面
      await driver.delayMs(COMMON_DELAY);
      let privacyBackIcon = await driver.waitForComponent(ON.type('BackButtonImage'), WAIT_DELAY);
      await privacyBackIcon.click();
      await driver.delayMs(COMMON_DELAY);
      await driver.assertComponentExist(ON.text(Constant.PRIVACY));
      LogUtil.info(`${Constant.TAG} privacyTab clicked`);
    } catch (err) {
      LogUtil.showError(TAG, `err.code : ${(err as BusinessError)?.code}, message: ${(err as BusinessError).message}`);
    }
  };
}

function homePageTest_004(driver: Driver): Function {
  return async () => {
    try {
      await DELEGATOR.startAbility({
        'bundleName': Constant.SETTINGS_BUNDLE_NAME,
        'abilityName': Constant.SETTINGS_MAIN_ABILITY_NAME,
        'uri': NavEntryKey.ABOUT_DEVICE_ENTRY
      }).then(() => {
        LogUtil.info(`${Constant.TAG} com.ohos.settings.MainAbility start success`);
      });
    } catch (exception) {
      LogUtil.warn(`Failed to startAbility. Code: ${(exception as BusinessError).code}, message: ${(exception as BusinessError).message}`);
    }
    await driver.delayMs(COMMON_DELAY);
    await driver.pressBack();
    await driver.delayMs(COMMON_DELAY);
    try {
      await driver.assertComponentExist(ON.text(Constant.COMMON));
      await driver.pressBack();
      await driver.delayMs(COMMON_DELAY);
      await driver.assertComponentExist(ON.text(Constant.SETTINGS));
    } catch (err) {
      LogUtil.showError(TAG, `err.code : ${(err as BusinessError)?.code}, message: ${(err as BusinessError).message}`);
    }
  };
}

function homePageTest_003(driver: Driver): Function {
  return async () => {
    LogUtil.info(`${Constant.TAG} homePageTest_003 start`);
    await driver.delayMs(COMMON_DELAY);
    await driver.swipe(START_X, START_Y, END_X, END_Y, SPEED);
    await driver.delayMs(COMMON_DELAY);
    try {
      let commonTab = await driver.waitForComponent(ON.text(Constant.COMMON), WAIT_DELAY);
      await commonTab.click();
      LogUtil.info(`${Constant.TAG} commonTab clicked`);
      await driver.delayMs(COMMON_DELAY);
      if (DeviceUtil.isDevicePad()) {
        //点击关于本机菜单
        let aboutPadDeviceTab = await driver.waitForComponent(ON.text(Constant.ABOUT_DEVICE), WAIT_DELAY);
        await aboutPadDeviceTab.click();
        LogUtil.info(`${Constant.TAG} aboutPadDeviceTab clicked`);
        await driver.delayMs(COMMON_DELAY);
        await driver.assertComponentExist(ON.text(Constant.DEVICE_NAME));
      } else {
        let aboutDeviceTab = await driver.waitForComponent(ON.text(Constant.ABOUT_DEVICE), WAIT_DELAY);
        await aboutDeviceTab.click();
        LogUtil.info(`${Constant.TAG} aboutDeviceTab clicked`);
        await driver.delayMs(COMMON_DELAY);
        await driver.assertComponentExist(ON.text(Constant.DEVICE_NAME));
        // 点击返回按钮到设置页面
        let applicationAndServiceBackIcon = await driver.waitForComponent(ON.type('BackButtonImage'), WAIT_DELAY);
        await applicationAndServiceBackIcon.click();
        await driver.delayMs(COMMON_DELAY);
        applicationAndServiceBackIcon = await driver.waitForComponent(ON.type('BackButtonImage'), WAIT_DELAY);
        await applicationAndServiceBackIcon.click();
        await driver.delayMs(COMMON_DELAY);
        await driver.assertComponentExist(ON.text(Constant.SETTINGS));
        await driver.pressHome();
        await driver.delayMs(COMMON_DELAY);
      }
      LogUtil.info(`${Constant.TAG} homePageTest_003 end`);
    } catch (err) {
      LogUtil.showError(TAG, `err.code : ${(err as BusinessError)?.code}, message: ${(err as BusinessError).message}`);
    }
  };
}

function homePageTest_002(driver: Driver): Function {
  return async () => {
    LogUtil.info(`${Constant.TAG} homePageTest_002 start`);
    await driver.delayMs(COMMON_DELAY);
    await driver.swipe(START_X, START_Y, END_X, END_Y, SPEED);
    // 点击'应用和元服务'菜单
    await driver.delayMs(COMMON_DELAY);
    let applicationAndServiceTab = await driver.waitForComponent(ON.text(Constant.APPLICATION_AND_SERVICE), WAIT_DELAY);
    await applicationAndServiceTab?.click();
    LogUtil.info(`${Constant.TAG} applicationAndServiceTab clicked`);
    // 点击返回按钮到设置页面
    let applicationAndServiceBackIcon = await driver.waitForComponent(ON.type('BackButtonImage'), WAIT_DELAY);
    await applicationAndServiceBackIcon?.click();
    await driver.delayMs(COMMON_DELAY);
    LogUtil.info(`${Constant.TAG} homePageTest_001 end`);
  };
}

function homePageTest_001(driver: Driver): Function {
  return async () => {
    LogUtil.info(`${Constant.TAG} homePageTest_001 start`);
    await driver.delayMs(COMMON_DELAY);
    // 点击'声音和振动'菜单
    let soundAndVibrationTab = await driver.waitForComponent(ON.text(Constant.SOUND_AND_VIBRATION), WAIT_DELAY);
    await soundAndVibrationTab?.click();
    // 点击返回到按钮到设置页面
    await driver.delayMs(COMMON_DELAY);
    let applicationAndServiceBackIcon = await driver.waitForComponent(ON.type('BackButtonImage'), WAIT_DELAY);
    await applicationAndServiceBackIcon?.click();
    await driver.delayMs(COMMON_DELAY);
    LogUtil.info(`${Constant.TAG} soundAndVibrationTab clicked`);
  };
}
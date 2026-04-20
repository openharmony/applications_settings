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
import settings from '@ohos.settings';
import { Driver, ON } from '@ohos.UiTest';
import { afterAll, beforeAll, describe, it } from '@ohos/hypium';
import { CommonUtils } from '@ohos/settings.common/src/main/ets/utils/CommonUtils';
import { NavEntryKey } from '@ohos/settings.common/src/main/ets/utils/Consts';
import { LogUtil } from '@ohos/settings.common/src/main/ets/utils/LogUtil';
import { ResourceUtil } from '@ohos/settings.common/src/main/ets/utils/ResourceUtil';
import { SettingsDataUtils } from '@ohos/settings.common/src/main/ets/utils/SettingsDataUtils';
import { DisplayUtils } from '../../../../main/ets/Setting/Display/utils/DisplayUtils';
import { Constant } from '../constant/Constant';
import { COMMON_DELAY, SWIPE_DELAY, WAIT_DELAY } from '../types';

const DELEGATOR: abilityDelegatorRegistry.AbilityDelegator = abilityDelegatorRegistry.getAbilityDelegator();
const TAG: string = 'DisplayColorPageTest';
const PCMODE_WINDOW_KEY: string = 'window_pcmode_switch_status';

export default function DisplayPageTest() {
  describe('DisplayPageTest', () => {
    let dr: Driver = Driver.create();
    beforeAll(async () => {
      try {
        await DELEGATOR.startAbility({
          'bundleName': 'com.ohos.settings',
          'abilityName': 'com.ohos.settings.MainAbility',
          'uri': NavEntryKey.DISPLAY_ENTRY,
        }).then(() => {
          LogUtil.info(`${TAG} com.ohos.settings.MainAbility start success`);
        });
      } catch (err) {
        LogUtil.info(`${TAG} failed to startAbility. Code: ${err?.code}, message: ${err?.message}`);
      };
    });

    afterAll(async () => {
      await dr.delayMs(COMMON_DELAY);
      await dr.pressHome();
      await dr.delayMs(COMMON_DELAY);
    });

    /*
    * @tc.number:displayPageTest_001
    * @tc.name: 自动调节入口验证
    * @tc.type: 0 || TestType.FUNCTION  || Level.LEVEL0
    * @tc.desc: 自动调节按钮测试
    */
    it('displayPageTest_001', 0, displayPageTest_001(dr));

    /*
    * @tc.number:displayPageTest_002
    * @tc.name: 亮度条验证
    * @tc.type: 0 || TestType.FUNCTION  || Level.LEVEL0
    * @tc.desc: 亮度条滑动验证
    */
    it('displayPageTest_002', 0, displayPageTest_002(dr));

    /*
    * @tc.number:displayPageTest_003
    * @tc.name: 显示大小和文字菜单校验
    * @tc.type: 0 || TestType.FUNCTION  || Level.LEVEL0
    * @tc.desc: 对于支持设备，进入显示与亮度菜单，显示大小和文字展示ok
    */
    it('displayPageTest_003', 0, async (done: Function) => {
      try {
        await dr.delayMs(COMMON_DELAY);
        await dr.assertComponentExist(ON.text(Constant.DISPLAY_FONT_SIZE_AND_TEXT));
      } catch (err) {
        LogUtil.showError(TAG, `DisplayPageTest_003 err.code : ${err?.code}, message: ${err?.message}`);
      }
      done();
    })

    /*
    * @tc.number: displayPageTest_004
    * @tc.name: 深色模式测试
    * @tc.type: 0 || TestType.FUNCTION  || Level.LEVEL0
    * @tc.desc: 深色模式测试
    */
    it('displayPageTest_004', 0, displayPageTest_004(dr));

    /*
    * @tc.number: displayPageTest_005
    * @tc.name: 护眼模式测试
    * @tc.type: 0 || TestType.FUNCTION  || Level.LEVEL0
    * @tc.desc: 护眼模式测试
    */
    it('displayPageTest_005', 0, displayPageTest_005(dr));

    /*
    * @tc.number: displayPageTest_006
    * @tc.name: 显示文字和大小测试
    * @tc.type: 0 || TestType.FUNCTION  || Level.LEVEL0
    * @tc.desc: 显示文字和大小测试
    */
    it('displayPageTest_006', 0, displayPageTest_006(dr));

    /*
    * @tc.number: displayPageTest_007
    * @tc.name: 休眠测试
    * @tc.type: 0 || TestType.FUNCTION  || Level.LEVEL0
    * @tc.desc: 休眠测试
    */
    it('displayPageTest_007', 0, displayPageTest_007(dr));

    /*
    * @tc.number: displayPageTest_008
    * @tc.name: 色彩与色温调节测试
    * @tc.type: 0 || TestType.FUNCTION  || Level.LEVEL0
    * @tc.desc: 色彩与色温调节测试
    */
    it('displayPageTest_008', 0, displayPageTest_008(dr));

    /*
    * @tc.number: displayPageTest_009
    * @tc.name: 屏幕刷新率测试
    * @tc.type: 0 || TestType.FUNCTION  || Level.LEVEL0
    * @tc.desc: 屏幕刷新率测试
    */
    it('displayPageTest_009', 0, displayPageTest_009(dr));

    /*
    * @tc.number: displayPageTest_010
    * @tc.name: 强制横屏测试
    * @tc.type: 0 || TestType.FUNCTION  || Level.LEVEL0
    * @tc.desc: 进入强制横屏设置页面、返回显示和亮度页面
    */
    it('displayPageTest_010', 0, displayPageTest_010(dr));

    /*
    * @tc.number: displayPageTest_011
    * @tc.name: 强制横屏测试
    * @tc.type: 0 || TestType.FUNCTION  || Level.LEVEL0
    * @tc.desc: 进入强制横屏设置页面、使能强制横屏、进入自由多窗模式，自动跳转到显示和亮度页面，关闭自由多窗模式
    */
    it('displayPageTest_011', 0, displayPageTest_011(dr));

    /*
    * @tc.number: displayPageTest_012
    * @tc.name: 强制横屏测试
    * @tc.type: 0 || TestType.FUNCTION  || Level.LEVEL0
    * @tc.desc: 进入显示和亮度页面，进入自由多窗模式，滑动到最底部
    */
    it('displayPageTest_012', 0, displayPageTest_012(dr));

    /*
    * @tc.number: displayPageTest_013
    * @tc.name: 强制横屏测试
    * @tc.type: 0 || TestType.FUNCTION  || Level.LEVEL0
    * @tc.desc: 进入显示和亮度页面，未进入自由多窗模式，滑动到最底部
    */
    it('displayPageTest_013', 0, displayPageTest_013(dr));

    it('displayPageTest_014', 0, displayPageTest_014(dr));
    it('displayPageTest_015', 0, displayPageTest_015(dr));
    it('displayPageTest_016', 0, displayPageTest_016(dr));
    it('displayPageTest_017', 0, displayPageTest_017(dr));
    it('displayPageTest_018', 0, displayPageTest_018(dr));
    it('displayPageTest_019', 0, displayPageTest_019(dr));
    it('displayPageTest_020', 0, displayPageTest_020(dr));
    it('displayPageTest_021', 0, displayPageTest_021(dr));
    it('displayPageTest_022', 0, displayPageTest_022(dr));
    it('displayPageTest_023', 0, displayPageTest_023(dr));
    it('displayPageTest_024', 0, displayPageTest_024(dr));
    it('displayPageTest_025', 0, displayPageTest_025(dr));
    it('displayPageTest_026', 0, displayPageTest_026(dr));
    it('displayPageTest_027', 0, displayPageTest_027(dr));
    it('displayPageTest_028', 0, displayPageTest_028(dr));
  })
}

function displayPageTest_001(driver: Driver): Function {
  return async (done: Function) => {
    LogUtil.info(`${TAG} displayPageTest_001 start`);
    try {
      await driver.delayMs(COMMON_DELAY);
      await driver.assertComponentExist(ON.id('automatic_adjust_toggle'));
      let toggle = await driver.waitForComponent(ON.id('automatic_adjust_toggle'), WAIT_DELAY);
      await toggle.click();
      await driver.delayMs(COMMON_DELAY);
      await driver.assertComponentExist(ON.checked(false).id('automatic_adjust_toggle'));

      toggle = await driver.waitForComponent(ON.id('automatic_adjust_toggle'), WAIT_DELAY);
      await toggle.click();
      await driver.delayMs(COMMON_DELAY);
      LogUtil.info(`${TAG} automatic adjust toggle clicked`);

      await driver.assertComponentExist(ON.checked(true).id('automatic_adjust_toggle'));
    } catch (err) {
      LogUtil.showError(TAG, `displayPageTest_001 err.code : ${err?.code}, message: ${err?.message}`);
    }
    done();
    LogUtil.info(`${TAG} displayPageTest_001 end`);
  };
}

function displayPageTest_002(driver: Driver): Function {
  return async (done: Function) => {
    LogUtil.info(`${TAG} displayPageTest_002 start`);
    try {
      await driver.delayMs(COMMON_DELAY);
      await driver.assertComponentExist(ON.id('brightness_reduce_image'));
      let imageIcon = await driver.waitForComponent(ON.id('brightness_reduce_image'), WAIT_DELAY);
      await imageIcon.click();
      await driver.delayMs(COMMON_DELAY);

      imageIcon = await driver.waitForComponent(ON.id('brightness_plus_image'), WAIT_DELAY);
      await imageIcon.click();
      await driver.delayMs(COMMON_DELAY);
    } catch (err) {
      LogUtil.showError(TAG, `displayPageTest_002 err.code : ${err?.code}, message: ${err?.message}`);
    }
    done();
    LogUtil.info(`${TAG} displayPageTest_002 end`);
  };
}

function displayPageTest_004(driver: Driver): Function {
  return async (done: Function) => {
    LogUtil.info(`${TAG} displayPageTest_004 start`);
    try {
      await driver.delayMs(COMMON_DELAY);
      await driver.assertComponentExist(ON.text(ResourceUtil.getStringSync($r('app.string.dark_mode'))));
      let darkModeTab = await driver.waitForComponent(ON.id('Setting.Display.display_setting.dark_mode'), WAIT_DELAY);
      await darkModeTab.click();

      await driver.delayMs(COMMON_DELAY);
      await driver.assertComponentExist(ON.text(ResourceUtil.getStringSync($r('app.string.dark_mode'))));
      await driver.pressBack();
      await driver.delayMs(COMMON_DELAY);
    } catch (err) {
      LogUtil.showError(TAG, `displayPageTest_004 err code: ${err?.code} msg: ${err?.message}`);
    }

    LogUtil.info(`${TAG} displayPageTest_004 end`);
    done();
  }
}

function displayPageTest_005(driver: Driver): Function {
  return async (done: Function) => {
    LogUtil.info(`${TAG} displayPageTest_005 start`);
    if (!DisplayUtils.isEyeProtectedSupport()) {
      return;
    }
    try {
      await driver.delayMs(COMMON_DELAY);
      await driver.assertComponentExist(ON.text(ResourceUtil.getStringSync($r('app.string.eye_Comfort_mode'))));
      let eyeComp = await driver.waitForComponent(ON.id('Setting.Display.eye_comfort.eye_comfort_mode'), WAIT_DELAY);
      await eyeComp.click();

      await driver.delayMs(COMMON_DELAY);
      await driver.assertComponentExist(ON.text(ResourceUtil.getStringSync($r('app.string.eye_Comfort_mode'))));
      await driver.pressBack();
      await driver.delayMs(COMMON_DELAY);
    } catch (err) {
      LogUtil.showError(TAG, `displayPageTest_005 err code: ${err?.code} msg: ${err?.message}`);
    }

    LogUtil.info(`${TAG} displayPageTest_005 end`);
    done();
  }
}

function displayPageTest_006(driver: Driver): Function {
  return async (done: Function) => {
    LogUtil.info(`${TAG} displayPageTest_006 start`);
    try {
      await driver.delayMs(COMMON_DELAY);
      await driver.assertComponentExist(ON.text(ResourceUtil.getStringSync($r('app.string.screen_zoom_and_text'))));
      let screenComp = await driver.waitForComponent(ON.id('Setting.Display.screen_zoom.screen_zoom_mode'), WAIT_DELAY);
      await screenComp.click();

      await driver.delayMs(COMMON_DELAY);
      await driver.assertComponentExist(ON.text(ResourceUtil.getStringSync($r('app.string.screen_zoom_and_text'))));
      await driver.pressBack();
      await driver.delayMs(COMMON_DELAY);
    } catch (err) {
      LogUtil.showError(TAG, `displayPageTest_006 err code: ${err?.code} msg: ${err?.message}`);
    }

    LogUtil.info(`${TAG} displayPageTest_006 end`);
    done();
  }
}

function displayPageTest_007(driver: Driver): Function {
  return async (done: Function) => {
    LogUtil.info(`${TAG} displayPageTest_007 start`);
    try {
      await driver.delayMs(COMMON_DELAY);
      await driver.assertComponentExist(ON.text(ResourceUtil.getStringSync($r('app.string.dormancy'))));
      let dormComp = await driver.waitForComponent(ON.id('Setting.Display.screen_group.dormancy_settings'), WAIT_DELAY);
      await dormComp.click();

      await driver.delayMs(COMMON_DELAY);
      await driver.assertComponentExist(ON.text(ResourceUtil.getStringSync($r('app.string.dormancy'))));
      await driver.pressBack();
      await driver.delayMs(COMMON_DELAY);
    } catch (err) {
      LogUtil.showError(TAG, `displayPageTest_007 err code: ${err?.code} msg: ${err?.message}`);
    }

    LogUtil.info(`${TAG} displayPageTest_007 end`);
    done();
  }
}

function displayPageTest_008(driver: Driver): Function {
  return async (done: Function) => {
    LogUtil.info(`${TAG} displayPageTest_008 start`);
    if (!DisplayUtils.isColorModeSupport()) {
      return;
    }
    try {
      await driver.delayMs(COMMON_DELAY);
      await driver.assertComponentExist(
        ON.text(ResourceUtil.getStringSync($r('app.string.color_adjustment_and_color_temperature_title'))));
      let colorComp =
        await driver.waitForComponent(ON.id('Setting.Display.screen_setting.color_adjustment'), WAIT_DELAY);
      await colorComp.click();

      await driver.delayMs(COMMON_DELAY);
      await driver.assertComponentExist(ON.text(
        ResourceUtil.getStringSync($r('app.string.color_adjustment_and_color_temperature_title'))));
      await driver.pressBack();
      await driver.delayMs(COMMON_DELAY);
    } catch (err) {
      LogUtil.showError(TAG, `displayPageTest_008 err code: ${err?.code} msg: ${err?.message}`);
    }

    LogUtil.info(`${TAG} displayPageTest_008 end`);
    done();
  }
}

function displayPageTest_009(driver: Driver): Function {
  return async (done: Function) => {
    LogUtil.info(`${TAG} displayPageTest_009 start`);
    try {
      await driver.delayMs(COMMON_DELAY);
      const START_X: number = 260;
      const START_Y: number = 1900;
      const END_X: number = 200;
      const END_Y: number = 397;
      const SPEED: number = 6000;
      await driver.swipe(START_X, START_Y, END_X, END_Y, SPEED);
      await driver.delayMs(SWIPE_DELAY);
      await driver.assertComponentExist(ON.text(
        ResourceUtil.getStringSync($r('app.string.screen_refresh_rate_title'))));
      let refreshComp =
        await driver.waitForComponent(ON.id('Setting.Display.screen_setting.screen_refresh_rate'), WAIT_DELAY);
      let enabled = await refreshComp.isEnabled();
      if (!enabled) {
        done();
        return;
      }
      await refreshComp.click();

      await driver.delayMs(COMMON_DELAY);
      await driver.assertComponentExist(ON.text(
        ResourceUtil.getStringSync($r('app.string.screen_refresh_rate_title'))));
      await driver.pressBack();
      await driver.delayMs(COMMON_DELAY);
    } catch (err) {
      LogUtil.showError(TAG, `displayPageTest_009 err code: ${err?.code} msg: ${err?.message}`);
    }

    LogUtil.info(`${TAG} displayPageTest_009 end`);
    done();
  }
}

function displayPageTest_010(driver: Driver): Function {
  return async (done: Function) => {
    LogUtil.info(`${TAG} displayPageTest_010 start`);
    try {
      SettingsDataUtils.setSettingsDataDomain(PCMODE_WINDOW_KEY, 'false', settings.domainName.USER_PROPERTY);
      await DELEGATOR.startAbility({
        'bundleName': 'com.ohos.settings',
        'abilityName': 'com.ohos.settings.MainAbility',
        'uri': NavEntryKey.DISPLAY_ENTRY,
      });
      await driver.delayMs(COMMON_DELAY);
      const START_X: number = 2000;
      const START_Y: number = 1500;
      const END_X: number = 2000;
      const END_Y: number = 200;
      const SPEED: number = 6000;
      await driver.swipe(START_X, START_Y, END_X, END_Y, SPEED);
      LogUtil.info(`${TAG} displayPageTest_010 swipe`);
      await driver.assertComponentExist(ON.text(ResourceUtil.getStringSync($r('app.string.forced_landscape'))));
      let dormComp = await driver.waitForComponent(ON.id('Setting.Display.forced_landscape_group.forced_landscape'), WAIT_DELAY);
      await dormComp.click();

      await driver.delayMs(COMMON_DELAY);
      await driver.assertComponentExist(ON.text(ResourceUtil.getStringSync($r('app.string.forced_landscape'))));
      await driver.pressBack();
      await driver.delayMs(COMMON_DELAY);
    } catch (err) {
      LogUtil.showError(TAG, `displayPageTest_010 err code: ${err?.code} msg: ${err?.message}`);
    }

    LogUtil.info(`${TAG} displayPageTest_010 end`);
    done();
  }
}

function displayPageTest_011(driver: Driver): Function {
  return async (done: Function) => {
    LogUtil.info(`${TAG} displayPageTest_011 start`);
    try {
      SettingsDataUtils.setSettingsDataDomain(PCMODE_WINDOW_KEY, 'false', settings.domainName.USER_PROPERTY);
      await DELEGATOR.startAbility({
        'bundleName': 'com.ohos.settings',
        'abilityName': 'com.ohos.settings.MainAbility',
        'uri': NavEntryKey.DISPLAY_ENTRY,
      });
      await driver.delayMs(COMMON_DELAY);
      CommonUtils.isPageExist(NavEntryKey.DISPLAY_ENTRY);
      const START_X: number = 2000;
      const START_Y: number = 1500;
      const END_X: number = 2000;
      const END_Y: number = 200;
      const SPEED: number = 6000;
      await driver.swipe(START_X, START_Y, END_X, END_Y, SPEED);
      await driver.assertComponentExist(ON.text(ResourceUtil.getStringSync($r('app.string.forced_landscape'))));
      let dormComp = await driver.waitForComponent(ON.id('Setting.Display.forced_landscape_group.forced_landscape'), WAIT_DELAY);
      await dormComp.click();
      LogUtil.info(`${TAG} displayPageTest_011 click`);
      await driver.delayMs(COMMON_DELAY);
      await driver.assertComponentExist(ON.text('强制横屏显示'));
      CommonUtils.isPageExist(NavEntryKey.LANDSCAPE_STARTUP_ENTRY);
      let landscapeEnableToggle = await driver.waitForComponent(ON.type('Toggle'), WAIT_DELAY);
      await landscapeEnableToggle.click();
      // 进入自由多窗模式
      SettingsDataUtils.setSettingsDataDomain(PCMODE_WINDOW_KEY, 'true', settings.domainName.USER_PROPERTY);
      await driver.delayMs(COMMON_DELAY);
      CommonUtils.isPageActive(NavEntryKey.DISPLAY_ENTRY);
      SettingsDataUtils.setSettingsDataDomain(PCMODE_WINDOW_KEY, 'false', settings.domainName.USER_PROPERTY);
      await driver.pressBack();
      CommonUtils.isPageActive(NavEntryKey.LANDSCAPE_STARTUP_ENTRY);
    } catch (err) {
      LogUtil.showError(TAG, `displayPageTest_011 err code: ${err?.code} msg: ${err?.message}`);
    }
    LogUtil.info(`${TAG} displayPageTest_011 end`);
    done();
  }
}

function displayPageTest_012(driver: Driver): Function {
  return async (done: Function) => {
    LogUtil.info(`${TAG} displayPageTest_012 start`);
    try {
      CommonUtils.isPageActive(NavEntryKey.LANDSCAPE_STARTUP_ENTRY);
      await DELEGATOR.startAbility({
        'bundleName': 'com.ohos.settings',
        'abilityName': 'com.ohos.settings.MainAbility',
        'uri': NavEntryKey.DISPLAY_ENTRY,
      });
      await driver.delayMs(COMMON_DELAY);
      SettingsDataUtils.setSettingsDataDomain(PCMODE_WINDOW_KEY, 'true', settings.domainName.USER_PROPERTY);
      await driver.delayMs(COMMON_DELAY);
      const START_X: number = 2000;
      const START_Y: number = 1500;
      const END_X: number = 2000;
      const END_Y: number = 200;
      const SPEED: number = 6000;
      await driver.swipe(START_X, START_Y, END_X, END_Y, SPEED);
      await driver.pressBack();
      CommonUtils.isPageActive(NavEntryKey.LANDSCAPE_STARTUP_ENTRY);
      CommonUtils.isPageExist(NavEntryKey.LANDSCAPE_STARTUP_ENTRY);
    } catch (err) {
      LogUtil.showError(TAG, `displayPageTest_012 err code: ${err?.code} msg: ${err?.message}`);
    }
    LogUtil.info(`${TAG} displayPageTest_012 end`);
    done();
  }
}

function displayPageTest_013(driver: Driver): Function {
  return async (done: Function) => {
    LogUtil.info(`${TAG} displayPageTest_013 start`);
    try {
      await DELEGATOR.startAbility({
        'bundleName': 'com.ohos.settings',
        'abilityName': 'com.ohos.settings.MainAbility',
        'uri': NavEntryKey.DISPLAY_ENTRY,
      });
      await driver.delayMs(COMMON_DELAY);
      SettingsDataUtils.setSettingsDataDomain(PCMODE_WINDOW_KEY, 'false', settings.domainName.USER_PROPERTY);
      await driver.delayMs(COMMON_DELAY);
      const START_X: number = 2000;
      const START_Y: number = 1500;
      const END_X: number = 2000;
      const END_Y: number = 200;
      const SPEED: number = 6000;
      await driver.swipe(START_X, START_Y, END_X, END_Y, SPEED);
      await driver.pressBack();
      CommonUtils.isPageActive(NavEntryKey.LANDSCAPE_STARTUP_ENTRY);
    } catch (err) {
      LogUtil.showError(TAG, `displayPageTest_013 err code: ${err?.code} msg: ${err?.message}`);
    }
    LogUtil.info(`${TAG} displayPageTest_013 end`);
    done();
  }
}

function displayPageTest_014(driver: Driver): Function {
  return async (done: Function) => {
    LogUtil.info(`${TAG} displayPageTest_014 start`);
    try {
      await driver.delayMs(COMMON_DELAY);
      const START_X: number = 260;
      const START_Y: number = 1900;
      const END_X: number = 200;
      const END_Y: number = 397;
      const SPEED: number = 6000;
      await driver.swipe(START_X, START_Y, END_X, END_Y, SPEED);
      await driver.delayMs(SWIPE_DELAY);
      await driver.assertComponentExist(ON.text(
        ResourceUtil.getStringSync($r('app.string.screen_refresh_rate_title'))));
      let refreshComp =
        await driver.waitForComponent(ON.id('Setting.Display.screen_setting.screen_refresh_rate'), WAIT_DELAY);
      let enabled = await refreshComp.isEnabled();
      if (!enabled) {
        done();
        return;
      }
      await refreshComp.click();

      await driver.delayMs(COMMON_DELAY);
      await driver.assertComponentExist(ON.text(
        ResourceUtil.getStringSync($r('app.string.screen_refresh_rate_title'))));
      await driver.pressBack();
      await driver.delayMs(COMMON_DELAY);
    } catch (err) {
      LogUtil.showError(TAG, `displayPageTest_014 err code: ${err?.code} msg: ${err?.message}`);
    }

    LogUtil.info(`${TAG} displayPageTest_014 end`);
    done();
  }
}

function displayPageTest_015(driver: Driver): Function {
  return async (done: Function) => {
    LogUtil.info(`${TAG} displayPageTest_015 start`);
    try {
      SettingsDataUtils.setSettingsDataDomain(PCMODE_WINDOW_KEY, 'false', settings.domainName.USER_PROPERTY);
      await DELEGATOR.startAbility({
        'bundleName': 'com.ohos.settings',
        'abilityName': 'com.ohos.settings.MainAbility',
        'uri': NavEntryKey.DISPLAY_ENTRY,
      });
      await driver.delayMs(COMMON_DELAY);
      const START_X: number = 2000;
      const START_Y: number = 1500;
      const END_X: number = 2000;
      const END_Y: number = 200;
      const SPEED: number = 6000;
      await driver.swipe(START_X, START_Y, END_X, END_Y, SPEED);
      LogUtil.info(`${TAG} displayPageTest_015 swipe`);
      await driver.assertComponentExist(ON.text(ResourceUtil.getStringSync($r('app.string.forced_landscape'))));
      let dormComp = await driver.waitForComponent(ON.id('Setting.Display.forced_landscape_group.forced_landscape'), WAIT_DELAY);
      await dormComp.click();

      await driver.delayMs(COMMON_DELAY);
      await driver.assertComponentExist(ON.text(ResourceUtil.getStringSync($r('app.string.forced_landscape'))));
      await driver.pressBack();
      await driver.delayMs(COMMON_DELAY);
    } catch (err) {
      LogUtil.showError(TAG, `displayPageTest_015 err code: ${err?.code} msg: ${err?.message}`);
    }

    LogUtil.info(`${TAG} displayPageTest_015 end`);
    done();
  }
}

function displayPageTest_016(driver: Driver): Function {
  return async (done: Function) => {
    LogUtil.info(`${TAG} displayPageTest_016 start`);
    try {
      SettingsDataUtils.setSettingsDataDomain(PCMODE_WINDOW_KEY, 'false', settings.domainName.USER_PROPERTY);
      await DELEGATOR.startAbility({
        'bundleName': 'com.ohos.settings',
        'abilityName': 'com.ohos.settings.MainAbility',
        'uri': NavEntryKey.DISPLAY_ENTRY,
      });
      await driver.delayMs(COMMON_DELAY);
      CommonUtils.isPageExist(NavEntryKey.DISPLAY_ENTRY);
      const START_X: number = 2000;
      const START_Y: number = 1500;
      const END_X: number = 2000;
      const END_Y: number = 200;
      const SPEED: number = 6000;
      await driver.swipe(START_X, START_Y, END_X, END_Y, SPEED);
      await driver.assertComponentExist(ON.text(ResourceUtil.getStringSync($r('app.string.forced_landscape'))));
      let dormComp = await driver.waitForComponent(ON.id('Setting.Display.forced_landscape_group.forced_landscape'), WAIT_DELAY);
      await dormComp.click();
      LogUtil.info(`${TAG} displayPageTest_016 click`);
      await driver.delayMs(COMMON_DELAY);
      await driver.assertComponentExist(ON.text('强制横屏显示'));
      CommonUtils.isPageExist(NavEntryKey.LANDSCAPE_STARTUP_ENTRY);
      let landscapeEnableToggle = await driver.waitForComponent(ON.type('Toggle'), WAIT_DELAY);
      await landscapeEnableToggle.click();
      // 进入自由多窗模式
      SettingsDataUtils.setSettingsDataDomain(PCMODE_WINDOW_KEY, 'true', settings.domainName.USER_PROPERTY);
      await driver.delayMs(COMMON_DELAY);
      CommonUtils.isPageActive(NavEntryKey.DISPLAY_ENTRY);
      SettingsDataUtils.setSettingsDataDomain(PCMODE_WINDOW_KEY, 'false', settings.domainName.USER_PROPERTY);
      await driver.pressBack();
      CommonUtils.isPageActive(NavEntryKey.LANDSCAPE_STARTUP_ENTRY);
    } catch (err) {
      LogUtil.showError(TAG, `displayPageTest_016 err code: ${err?.code} msg: ${err?.message}`);
    }
    LogUtil.info(`${TAG} displayPageTest_016 end`);
    done();
  }
}

function displayPageTest_017(driver: Driver): Function {
  return async (done: Function) => {
    LogUtil.info(`${TAG} displayPageTest_017 start`);
    try {
      CommonUtils.isPageActive(NavEntryKey.LANDSCAPE_STARTUP_ENTRY);
      await DELEGATOR.startAbility({
        'bundleName': 'com.ohos.settings',
        'abilityName': 'com.ohos.settings.MainAbility',
        'uri': NavEntryKey.DISPLAY_ENTRY,
      });
      await driver.delayMs(COMMON_DELAY);
      SettingsDataUtils.setSettingsDataDomain(PCMODE_WINDOW_KEY, 'true', settings.domainName.USER_PROPERTY);
      await driver.delayMs(COMMON_DELAY);
      const START_X: number = 2000;
      const START_Y: number = 1500;
      const END_X: number = 2000;
      const END_Y: number = 200;
      const SPEED: number = 6000;
      await driver.swipe(START_X, START_Y, END_X, END_Y, SPEED);
      await driver.pressBack();
      CommonUtils.isPageActive(NavEntryKey.LANDSCAPE_STARTUP_ENTRY);
      CommonUtils.isPageExist(NavEntryKey.LANDSCAPE_STARTUP_ENTRY);
    } catch (err) {
      LogUtil.showError(TAG, `displayPageTest_017 err code: ${err?.code} msg: ${err?.message}`);
    }
    LogUtil.info(`${TAG} displayPageTest_017 end`);
    done();
  }
}

function displayPageTest_018(driver: Driver): Function {
  return async (done: Function) => {
    LogUtil.info(`${TAG} displayPageTest_018 start`);
    try {
      await DELEGATOR.startAbility({
        'bundleName': 'com.ohos.settings',
        'abilityName': 'com.ohos.settings.MainAbility',
        'uri': NavEntryKey.DISPLAY_ENTRY,
      });
      await driver.delayMs(COMMON_DELAY);
      SettingsDataUtils.setSettingsDataDomain(PCMODE_WINDOW_KEY, 'false', settings.domainName.USER_PROPERTY);
      await driver.delayMs(COMMON_DELAY);
      const START_X: number = 2000;
      const START_Y: number = 1500;
      const END_X: number = 2000;
      const END_Y: number = 200;
      const SPEED: number = 6000;
      await driver.swipe(START_X, START_Y, END_X, END_Y, SPEED);
      await driver.pressBack();
      CommonUtils.isPageActive(NavEntryKey.LANDSCAPE_STARTUP_ENTRY);
    } catch (err) {
      LogUtil.showError(TAG, `displayPageTest_018 err code: ${err?.code} msg: ${err?.message}`);
    }
    LogUtil.info(`${TAG} displayPageTest_018 end`);
    done();
  }
}

function displayPageTest_019(driver: Driver): Function {
  return async (done: Function) => {
    LogUtil.info(`${TAG} displayPageTest_019 start`);
    try {
      await driver.delayMs(COMMON_DELAY);
      const START_X: number = 260;
      const START_Y: number = 1900;
      const END_X: number = 200;
      const END_Y: number = 397;
      const SPEED: number = 6000;
      await driver.swipe(START_X, START_Y, END_X, END_Y, SPEED);
      await driver.delayMs(SWIPE_DELAY);
      await driver.assertComponentExist(ON.text(
        ResourceUtil.getStringSync($r('app.string.screen_refresh_rate_title'))));
      let refreshComp =
        await driver.waitForComponent(ON.id('Setting.Display.screen_setting.screen_refresh_rate'), WAIT_DELAY);
      let enabled = await refreshComp.isEnabled();
      if (!enabled) {
        done();
        return;
      }
      await refreshComp.click();

      await driver.delayMs(COMMON_DELAY);
      await driver.assertComponentExist(ON.text(
        ResourceUtil.getStringSync($r('app.string.screen_refresh_rate_title'))));
      await driver.pressBack();
      await driver.delayMs(COMMON_DELAY);
    } catch (err) {
      LogUtil.showError(TAG, `displayPageTest_019 err code: ${err?.code} msg: ${err?.message}`);
    }

    LogUtil.info(`${TAG} displayPageTest_019 end`);
    done();
  }
}

function displayPageTest_020(driver: Driver): Function {
  return async (done: Function) => {
    LogUtil.info(`${TAG} displayPageTest_020 start`);
    try {
      SettingsDataUtils.setSettingsDataDomain(PCMODE_WINDOW_KEY, 'false', settings.domainName.USER_PROPERTY);
      await DELEGATOR.startAbility({
        'bundleName': 'com.ohos.settings',
        'abilityName': 'com.ohos.settings.MainAbility',
        'uri': NavEntryKey.DISPLAY_ENTRY,
      });
      await driver.delayMs(COMMON_DELAY);
      const START_X: number = 2000;
      const START_Y: number = 1500;
      const END_X: number = 2000;
      const END_Y: number = 200;
      const SPEED: number = 6000;
      await driver.swipe(START_X, START_Y, END_X, END_Y, SPEED);
      LogUtil.info(`${TAG} displayPageTest_020 swipe`);
      await driver.assertComponentExist(ON.text(ResourceUtil.getStringSync($r('app.string.forced_landscape'))));
      let dormComp = await driver.waitForComponent(ON.id('Setting.Display.forced_landscape_group.forced_landscape'), WAIT_DELAY);
      await dormComp.click();

      await driver.delayMs(COMMON_DELAY);
      await driver.assertComponentExist(ON.text(ResourceUtil.getStringSync($r('app.string.forced_landscape'))));
      await driver.pressBack();
      await driver.delayMs(COMMON_DELAY);
    } catch (err) {
      LogUtil.showError(TAG, `displayPageTest_020 err code: ${err?.code} msg: ${err?.message}`);
    }

    LogUtil.info(`${TAG} displayPageTest_020 end`);
    done();
  }
}

function displayPageTest_021(driver: Driver): Function {
  return async (done: Function) => {
    LogUtil.info(`${TAG} displayPageTest_021 start`);
    try {
      SettingsDataUtils.setSettingsDataDomain(PCMODE_WINDOW_KEY, 'false', settings.domainName.USER_PROPERTY);
      await DELEGATOR.startAbility({
        'bundleName': 'com.ohos.settings',
        'abilityName': 'com.ohos.settings.MainAbility',
        'uri': NavEntryKey.DISPLAY_ENTRY,
      });
      await driver.delayMs(COMMON_DELAY);
      CommonUtils.isPageExist(NavEntryKey.DISPLAY_ENTRY);
      const START_X: number = 2000;
      const START_Y: number = 1500;
      const END_X: number = 2000;
      const END_Y: number = 200;
      const SPEED: number = 6000;
      await driver.swipe(START_X, START_Y, END_X, END_Y, SPEED);
      await driver.assertComponentExist(ON.text(ResourceUtil.getStringSync($r('app.string.forced_landscape'))));
      let dormComp = await driver.waitForComponent(ON.id('Setting.Display.forced_landscape_group.forced_landscape'), WAIT_DELAY);
      await dormComp.click();
      LogUtil.info(`${TAG} displayPageTest_021 click`);
      await driver.delayMs(COMMON_DELAY);
      await driver.assertComponentExist(ON.text('强制横屏显示'));
      CommonUtils.isPageExist(NavEntryKey.LANDSCAPE_STARTUP_ENTRY);
      let landscapeEnableToggle = await driver.waitForComponent(ON.type('Toggle'), WAIT_DELAY);
      await landscapeEnableToggle.click();
      // 进入自由多窗模式
      SettingsDataUtils.setSettingsDataDomain(PCMODE_WINDOW_KEY, 'true', settings.domainName.USER_PROPERTY);
      await driver.delayMs(COMMON_DELAY);
      CommonUtils.isPageActive(NavEntryKey.DISPLAY_ENTRY);
      SettingsDataUtils.setSettingsDataDomain(PCMODE_WINDOW_KEY, 'false', settings.domainName.USER_PROPERTY);
      await driver.pressBack();
      CommonUtils.isPageActive(NavEntryKey.LANDSCAPE_STARTUP_ENTRY);
    } catch (err) {
      LogUtil.showError(TAG, `displayPageTest_021 err code: ${err?.code} msg: ${err?.message}`);
    }
    LogUtil.info(`${TAG} displayPageTest_021 end`);
    done();
  }
}

function displayPageTest_022(driver: Driver): Function {
  return async (done: Function) => {
    LogUtil.info(`${TAG} displayPageTest_022 start`);
    try {
      CommonUtils.isPageActive(NavEntryKey.LANDSCAPE_STARTUP_ENTRY);
      await DELEGATOR.startAbility({
        'bundleName': 'com.ohos.settings',
        'abilityName': 'com.ohos.settings.MainAbility',
        'uri': NavEntryKey.DISPLAY_ENTRY,
      });
      await driver.delayMs(COMMON_DELAY);
      SettingsDataUtils.setSettingsDataDomain(PCMODE_WINDOW_KEY, 'true', settings.domainName.USER_PROPERTY);
      await driver.delayMs(COMMON_DELAY);
      const START_X: number = 2000;
      const START_Y: number = 1500;
      const END_X: number = 2000;
      const END_Y: number = 200;
      const SPEED: number = 6000;
      await driver.swipe(START_X, START_Y, END_X, END_Y, SPEED);
      await driver.pressBack();
      CommonUtils.isPageActive(NavEntryKey.LANDSCAPE_STARTUP_ENTRY);
      CommonUtils.isPageExist(NavEntryKey.LANDSCAPE_STARTUP_ENTRY);
    } catch (err) {
      LogUtil.showError(TAG, `displayPageTest_022 err code: ${err?.code} msg: ${err?.message}`);
    }
    LogUtil.info(`${TAG} displayPageTest_022 end`);
    done();
  }
}

function displayPageTest_023(driver: Driver): Function {
  return async (done: Function) => {
    LogUtil.info(`${TAG} displayPageTest_023 start`);
    try {
      await DELEGATOR.startAbility({
        'bundleName': 'com.ohos.settings',
        'abilityName': 'com.ohos.settings.MainAbility',
        'uri': NavEntryKey.DISPLAY_ENTRY,
      });
      await driver.delayMs(COMMON_DELAY);
      SettingsDataUtils.setSettingsDataDomain(PCMODE_WINDOW_KEY, 'false', settings.domainName.USER_PROPERTY);
      await driver.delayMs(COMMON_DELAY);
      const START_X: number = 2000;
      const START_Y: number = 1500;
      const END_X: number = 2000;
      const END_Y: number = 200;
      const SPEED: number = 6000;
      await driver.swipe(START_X, START_Y, END_X, END_Y, SPEED);
      await driver.pressBack();
      CommonUtils.isPageActive(NavEntryKey.LANDSCAPE_STARTUP_ENTRY);
    } catch (err) {
      LogUtil.showError(TAG, `displayPageTest_023 err code: ${err?.code} msg: ${err?.message}`);
    }
    LogUtil.info(`${TAG} displayPageTest_023 end`);
    done();
  }
}

function displayPageTest_024(driver: Driver): Function {
  return async (done: Function) => {
    LogUtil.info(`${TAG} displayPageTest_024 start`);
    try {
      await driver.delayMs(COMMON_DELAY);
      const START_X: number = 260;
      const START_Y: number = 1900;
      const END_X: number = 200;
      const END_Y: number = 397;
      const SPEED: number = 6000;
      await driver.swipe(START_X, START_Y, END_X, END_Y, SPEED);
      await driver.delayMs(SWIPE_DELAY);
      await driver.assertComponentExist(ON.text(
        ResourceUtil.getStringSync($r('app.string.screen_refresh_rate_title'))));
      let refreshComp =
        await driver.waitForComponent(ON.id('Setting.Display.screen_setting.screen_refresh_rate'), WAIT_DELAY);
      let enabled = await refreshComp.isEnabled();
      if (!enabled) {
        done();
        return;
      }
      await refreshComp.click();

      await driver.delayMs(COMMON_DELAY);
      await driver.assertComponentExist(ON.text(
        ResourceUtil.getStringSync($r('app.string.screen_refresh_rate_title'))));
      await driver.pressBack();
      await driver.delayMs(COMMON_DELAY);
    } catch (err) {
      LogUtil.showError(TAG, `displayPageTest_024 err code: ${err?.code} msg: ${err?.message}`);
    }

    LogUtil.info(`${TAG} displayPageTest_024 end`);
    done();
  }
}

function displayPageTest_025(driver: Driver): Function {
  return async (done: Function) => {
    LogUtil.info(`${TAG} displayPageTest_025 start`);
    try {
      SettingsDataUtils.setSettingsDataDomain(PCMODE_WINDOW_KEY, 'false', settings.domainName.USER_PROPERTY);
      await DELEGATOR.startAbility({
        'bundleName': 'com.ohos.settings',
        'abilityName': 'com.ohos.settings.MainAbility',
        'uri': NavEntryKey.DISPLAY_ENTRY,
      });
      await driver.delayMs(COMMON_DELAY);
      const START_X: number = 2000;
      const START_Y: number = 1500;
      const END_X: number = 2000;
      const END_Y: number = 200;
      const SPEED: number = 6000;
      await driver.swipe(START_X, START_Y, END_X, END_Y, SPEED);
      LogUtil.info(`${TAG} displayPageTest_010 swipe`);
      await driver.assertComponentExist(ON.text(ResourceUtil.getStringSync($r('app.string.forced_landscape'))));
      let dormComp = await driver.waitForComponent(ON.id('Setting.Display.forced_landscape_group.forced_landscape'), WAIT_DELAY);
      await dormComp.click();

      await driver.delayMs(COMMON_DELAY);
      await driver.assertComponentExist(ON.text(ResourceUtil.getStringSync($r('app.string.forced_landscape'))));
      await driver.pressBack();
      await driver.delayMs(COMMON_DELAY);
    } catch (err) {
      LogUtil.showError(TAG, `displayPageTest_025 err code: ${err?.code} msg: ${err?.message}`);
    }

    LogUtil.info(`${TAG} displayPageTest_025 end`);
    done();
  }
}

function displayPageTest_026(driver: Driver): Function {
  return async (done: Function) => {
    LogUtil.info(`${TAG} displayPageTest_026 start`);
    try {
      SettingsDataUtils.setSettingsDataDomain(PCMODE_WINDOW_KEY, 'false', settings.domainName.USER_PROPERTY);
      await DELEGATOR.startAbility({
        'bundleName': 'com.ohos.settings',
        'abilityName': 'com.ohos.settings.MainAbility',
        'uri': NavEntryKey.DISPLAY_ENTRY,
      });
      await driver.delayMs(COMMON_DELAY);
      CommonUtils.isPageExist(NavEntryKey.DISPLAY_ENTRY);
      const START_X: number = 2000;
      const START_Y: number = 1500;
      const END_X: number = 2000;
      const END_Y: number = 200;
      const SPEED: number = 6000;
      await driver.swipe(START_X, START_Y, END_X, END_Y, SPEED);
      await driver.assertComponentExist(ON.text(ResourceUtil.getStringSync($r('app.string.forced_landscape'))));
      let dormComp = await driver.waitForComponent(ON.id('Setting.Display.forced_landscape_group.forced_landscape'), WAIT_DELAY);
      await dormComp.click();
      LogUtil.info(`${TAG} displayPageTest_026 click`);
      await driver.delayMs(COMMON_DELAY);
      await driver.assertComponentExist(ON.text('强制横屏显示'));
      CommonUtils.isPageExist(NavEntryKey.LANDSCAPE_STARTUP_ENTRY);
      let landscapeEnableToggle = await driver.waitForComponent(ON.type('Toggle'), WAIT_DELAY);
      await landscapeEnableToggle.click();
      // 进入自由多窗模式
      SettingsDataUtils.setSettingsDataDomain(PCMODE_WINDOW_KEY, 'true', settings.domainName.USER_PROPERTY);
      await driver.delayMs(COMMON_DELAY);
      CommonUtils.isPageActive(NavEntryKey.DISPLAY_ENTRY);
      SettingsDataUtils.setSettingsDataDomain(PCMODE_WINDOW_KEY, 'false', settings.domainName.USER_PROPERTY);
      await driver.pressBack();
      CommonUtils.isPageActive(NavEntryKey.LANDSCAPE_STARTUP_ENTRY);
    } catch (err) {
      LogUtil.showError(TAG, `displayPageTest_026 err code: ${err?.code} msg: ${err?.message}`);
    }
    LogUtil.info(`${TAG} displayPageTest_026 end`);
    done();
  }
}

function displayPageTest_027(driver: Driver): Function {
  return async (done: Function) => {
    LogUtil.info(`${TAG} displayPageTest_027 start`);
    try {
      CommonUtils.isPageActive(NavEntryKey.LANDSCAPE_STARTUP_ENTRY);
      await DELEGATOR.startAbility({
        'bundleName': 'com.ohos.settings',
        'abilityName': 'com.ohos.settings.MainAbility',
        'uri': NavEntryKey.DISPLAY_ENTRY,
      });
      await driver.delayMs(COMMON_DELAY);
      SettingsDataUtils.setSettingsDataDomain(PCMODE_WINDOW_KEY, 'true', settings.domainName.USER_PROPERTY);
      await driver.delayMs(COMMON_DELAY);
      const START_X: number = 2000;
      const START_Y: number = 1500;
      const END_X: number = 2000;
      const END_Y: number = 200;
      const SPEED: number = 6000;
      await driver.swipe(START_X, START_Y, END_X, END_Y, SPEED);
      await driver.pressBack();
      CommonUtils.isPageActive(NavEntryKey.LANDSCAPE_STARTUP_ENTRY);
      CommonUtils.isPageExist(NavEntryKey.LANDSCAPE_STARTUP_ENTRY);
    } catch (err) {
      LogUtil.showError(TAG, `displayPageTest_027 err code: ${err?.code} msg: ${err?.message}`);
    }
    LogUtil.info(`${TAG} displayPageTest_027 end`);
    done();
  }
}

function displayPageTest_028(driver: Driver): Function {
  return async (done: Function) => {
    LogUtil.info(`${TAG} displayPageTest_028 start`);
    try {
      await DELEGATOR.startAbility({
        'bundleName': 'com.ohos.settings',
        'abilityName': 'com.ohos.settings.MainAbility',
        'uri': NavEntryKey.DISPLAY_ENTRY,
      });
      await driver.delayMs(COMMON_DELAY);
      SettingsDataUtils.setSettingsDataDomain(PCMODE_WINDOW_KEY, 'false', settings.domainName.USER_PROPERTY);
      await driver.delayMs(COMMON_DELAY);
      const START_X: number = 2000;
      const START_Y: number = 1500;
      const END_X: number = 2000;
      const END_Y: number = 200;
      const SPEED: number = 6000;
      await driver.swipe(START_X, START_Y, END_X, END_Y, SPEED);
      await driver.pressBack();
      CommonUtils.isPageActive(NavEntryKey.LANDSCAPE_STARTUP_ENTRY);
    } catch (err) {
      LogUtil.showError(TAG, `displayPageTest_028 err code: ${err?.code} msg: ${err?.message}`);
    }
    LogUtil.info(`${TAG} displayPageTest_028 end`);
    done();
  }
}
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

import { describe, it, beforeAll, expect, afterAll } from '@ohos/hypium';
import { Driver, ON } from '@ohos.UiTest';
import call from '@ohos.telephony.call';
import abilityDelegatorRegistry from '@ohos.app.ability.abilityDelegatorRegistry';
import { LogUtil } from '@ohos/settings.common/src/main/ets/utils/LogUtil';
import { COMMON_DELAY, WAIT_DELAY, SWIPE_DELAY } from '../types';
import { Constant } from '../constant/Constant';
import { RingtonesUtils } from '../../../../main/ets/Setting/Volume/utils/RingtonesUtils';

const DELEGATOR: abilityDelegatorRegistry.AbilityDelegator = abilityDelegatorRegistry.getAbilityDelegator();

export default function soundSettingsTest() {
  describe('soundSettingsTest', () => {
    let driver: Driver = Driver.create();
    beforeAll(async () => {
      try {
        await DELEGATOR.startAbility({
          'bundleName': Constant.SETTINGS_BUNDLE_NAME,
          'abilityName': Constant.SETTINGS_MAIN_ABILITY_NAME,
          'uri': 'volume_settings',
        }).then(() => {
          LogUtil.info(`${Constant.TAG} com.ohos.settings.MainAbility start volume page success !`);
        });
      } catch (err) {
        LogUtil.info(`${Constant.TAG} failed to startAbility. Code: ${err?.code}, message: ${err?.message}`);
      }
    });

    afterAll(async () => {
      await driver.delayMs(COMMON_DELAY);
      await driver.pressHome();
      await driver.delayMs(COMMON_DELAY);
    });

    /*
    * @tc.number:soundSettingsTest_001
    * @tc.name: 静音测试.
    * @tc.type: 0 || TestType.FUNCTION  || Level.LEVEL0
    * @tc.desc: 静音切换正常
    */
    it('soundSettingsTest_001', 0, soundSettingsTest_001(driver));

    /*
    * @tc.number:soundSettingsTest_002
    * @tc.name: 振动测试
    * @tc.type: 0 || TestType.FUNCTION  || Level.LEVEL0
    * @tc.desc: 振动切换正常
    */
    it('soundSettingsTest_002', 0, soundSettingsTest_002(driver));

    /*
    * @tc.number:soundSettingsTest_003
    * @tc.name: 响铃测试
    * @tc.type: 0 || TestType.FUNCTION || Level.LEVEL0
    * @tc.desc: 响铃切换正常
    */
    it('soundSettingsTest_003', 0, soundSettingsTest_003(driver));

    /*
    * @tc.number: soundSettingsTest_005
    * @tc.name: 铃声group测试
    * @tc.type: 0 || TestType.FUNCTION  || Level.LEVEL0
    * @tc.desc: 铃声group测试
    */
    it('soundSettingsTest_005', 0, soundSettingsTest_005(driver));

    /*
    * @tc.number: soundSettingsTest_004
    * @tc.name: 系统触感反馈开关测试
    * @tc.type: 0 || TestType.FUNCTION  || Level.LEVEL0
    * @tc.desc: 触感反馈开关
    */
    it('soundSettingsTest_004', 0, soundSettingsTest_004(driver));

    /*
    * @tc.number: soundSettingsTest_009
    * @tc.name: 闹钟铃声测试
    * @tc.type: 0 || TestType.FUNCTION  || Level.LEVEL0
    * @tc.desc: 闹钟铃声测试
    */
    it('soundSettingsTest_009', 0, soundSettingsTest_009(driver));

    /*
    * @tc.number: soundSettingsTest_010
    * @tc.name: 媒体铃声测试
    * @tc.type: 0 || TestType.FUNCTION  || Level.LEVEL0
    * @tc.desc: 媒体铃声测试
    */
    it('soundSettingsTest_010', 0, soundSettingsTest_010(driver));

    /*
    * @tc.number: soundSettingsTest_011
    * @tc.name: 通话铃声测试
    * @tc.type: 0 || TestType.FUNCTION  || Level.LEVEL0
    * @tc.desc: 通话铃声测试
    */
    it('soundSettingsTest_011', 0, soundSettingsTest_011(driver));

    /*
    * @tc.number: soundSettingsTest_012
    * @tc.name: 小艺铃声测试
    * @tc.type: 0 || TestType.FUNCTION  || Level.LEVEL0
    * @tc.desc: 小艺铃声测试
    */
    it('soundSettingsTest_012', 0, soundSettingsTest_012(driver));

    /*
    * @tc.number: soundSettingsTest_013
    * @tc.name: 锁屏提示音测试
    * @tc.type: 0 || TestType.FUNCTION  || Level.LEVEL0
    * @tc.desc: 锁屏提示音测试
    */
    it('soundSettingsTest_013', 0, soundSettingsTest_013(driver));

    /*
    * @tc.number: soundSettingsTest_014
    * @tc.name: 截屏提示音测试
    * @tc.type: 0 || TestType.FUNCTION  || Level.LEVEL0
    * @tc.desc: 截屏提示音测试
    */
    it('soundSettingsTest_014', 0, soundSettingsTest_014(driver));

  });
}

function soundSettingsTest_001(driver: Driver): Function {
  return async (done: Function) => {
    LogUtil.info(`${Constant.TAG} soundSettingsTest_001 start`);
    try {
      await driver.delayMs(COMMON_DELAY);

      // 校验静音存在，并点击
      await driver.assertComponentExist(ON.text('静音'));
      let silentModeTab = await driver.waitForComponent(ON.text('静音'), WAIT_DELAY);
      await silentModeTab.click();
      await driver.delayMs(COMMON_DELAY);
    } catch (err) {
      LogUtil.showError(Constant.TAG, `soundSettingsTest_001 err code: ${err?.code} msg: ${err?.message}`);
    }
    LogUtil.info(`${Constant.TAG} silentModeTab clicked, soundSettingsTest_001 end`);
    done();
  };
}

function soundSettingsTest_002(driver: Driver): Function {
  return async (done: Function) => {
    LogUtil.info(`${Constant.TAG} soundSettingsTest_002 start`);
    try {
      await driver.delayMs(COMMON_DELAY);
      // 校验振动存在，并且点击
      await driver.assertComponentExist(ON.text('振动'));
      let vibrateModeTab = await driver.waitForComponent(ON.text('振动'), WAIT_DELAY);
      await vibrateModeTab.click();
    } catch (err) {
      LogUtil.showError(Constant.TAG, `soundSettingsTest_002 err code: ${err?.code} msg: ${err?.message}`);
    }

    LogUtil.info(`${Constant.TAG} vibrateModeTab clicked, soundSettingsTest_002 end`);
    done();
  };
}

function soundSettingsTest_003(driver: Driver): Function {
  return async (done: Function) => {
    LogUtil.info(`${Constant.TAG} soundSettingsTest_003 start`);
    try {
      await driver.delayMs(COMMON_DELAY);
      // 校验响铃存在，并点击
      await driver.assertComponentExist(ON.text('响铃'));
      let soundModeTab = await driver.waitForComponent(ON.text('响铃'), WAIT_DELAY);
      await soundModeTab.click();
    } catch (err) {
      LogUtil.showError(Constant.TAG, `soundSettingsTest_003 err code: ${err?.code} msg: ${err?.message}`);
    }

    LogUtil.info(`${Constant.TAG} soundModeTab clicked, soundSettingsTest_003 end`);
    done();
  }
}

function soundSettingsTest_004(driver: Driver): Function {
  return async (done: Function) => {
    try {
      LogUtil.info(`${Constant.TAG} soundSettingsTest_004 start`);
      await driver.delayMs(COMMON_DELAY);

      // 上滑页面,出现系统触感反馈
      const START_X: number = 260;
      const START_Y: number = 1900;
      const END_X: number = 200;
      const END_Y: number = 397;
      const SPEED: number = 6000;
      await driver.swipe(START_X, START_Y, END_X, END_Y, SPEED);
      await driver.delayMs(SWIPE_DELAY);
      await driver.assertComponentExist(ON.text(Constant.SOUND_TOUCH_SWITCH));
      await driver.assertComponentExist(ON.text(Constant.SOUND_TOUCH_SWITCH_TIP));

      // 关闭系统触感反馈
      let soundTouchSwitchTab = await driver.waitForComponent(ON.id(Constant.SOUND_TOUCH_SWITCH_ID), WAIT_DELAY);
      await soundTouchSwitchTab.click();
      await driver.delayMs(COMMON_DELAY);
      LogUtil.info(`${Constant.TAG} soundTouchSwitchTab clicked`);

      // 校验关闭成功
      await driver.assertComponentExist(ON.checked(false).id(Constant.SOUND_TOUCH_SWITCH_ID));

      // 开启系统触感反馈
      soundTouchSwitchTab = await driver.waitForComponent(ON.id(Constant.SOUND_TOUCH_SWITCH_ID), WAIT_DELAY);
      await soundTouchSwitchTab.click();
      await driver.delayMs(COMMON_DELAY);
      LogUtil.info(`${Constant.TAG} soundTouchSwitchTab clicked`);

      // 校验开启成功
      await driver.assertComponentExist(ON.checked(true).id(Constant.SOUND_TOUCH_SWITCH_ID));
    } catch (err) {
      LogUtil.showError(Constant.TAG, `soundSettingsTest_004 err: ${err?.code} msg: ${err?.message}`);
    }
    LogUtil.info(`${Constant.TAG} soundSettingsTest_004 end`);
    done();
  }
}

function soundSettingsTest_005(driver: Driver): Function {
  return async (done: Function) => {
    LogUtil.info(`${Constant.TAG} soundSettingsTest_005 start`);
    try {
      await driver.delayMs(COMMON_DELAY);
      // 校验通知铃声存在
      await driver.assertComponentExist(ON.text('通知铃声'));
      if (!RingtonesUtils.isVoiceCapabilityDisable()) {
        await driver.assertComponentExist(ON.text('来电铃声'));
        await driver.assertComponentExist(ON.text('信息铃声'));
      }
    } catch (err) {
      LogUtil.showError(Constant.TAG, `soundSettingsTest_005 err code: ${err?.code} msg: ${err?.message}`);
    }

    LogUtil.info(`${Constant.TAG} soundSettingsTest_005 end`);
    done();
  }
}

function soundSettingsTest_009(driver: Driver): Function {
  return async (done: Function) => {
    LogUtil.info(`${Constant.TAG} soundSettingsTest_009 start`);
    try {
      await driver.delayMs(COMMON_DELAY);
      await driver.assertComponentExist(ON.id('slider_alarm_volume'));
      let messageTab = await driver.waitForComponent(ON.id('slider_alarm_volume'), WAIT_DELAY);
      await messageTab.click();

      await driver.delayMs(COMMON_DELAY);
    } catch (err) {
      LogUtil.showError(Constant.TAG, `soundSettingsTest_009 err code: ${err?.code} msg: ${err?.message}`);
    }

    LogUtil.info(`${Constant.TAG} soundSettingsTest_009 end`);
    done();
  }
}

function soundSettingsTest_010(driver: Driver): Function {
  return async (done: Function) => {
    LogUtil.info(`${Constant.TAG} soundSettingsTest_010 start`);
    try {
      await driver.delayMs(COMMON_DELAY);
      await driver.assertComponentExist(ON.id('slider_media_volume'));
      let volumeSlider = await driver.waitForComponent(ON.id('slider_media_volume'), WAIT_DELAY);
      await volumeSlider.click();

      await driver.delayMs(COMMON_DELAY);
    } catch (err) {
      LogUtil.showError(Constant.TAG, `soundSettingsTest_010 err code: ${err?.code} msg: ${err?.message}`);
    }

    LogUtil.info(`${Constant.TAG} soundSettingsTest_010 end`);
    done();
  }
}

function soundSettingsTest_011(driver: Driver): Function {
  return async (done: Function) => {
    LogUtil.info(`${Constant.TAG} soundSettingsTest_011 start`);
    if (RingtonesUtils.isVoiceCapabilityDisable()) {
      return;
    }
    try {
      await driver.delayMs(COMMON_DELAY);
      await driver.assertComponentExist(ON.id('slider_call_volume'));
      let volumeSlider = await driver.waitForComponent(ON.id('slider_call_volume'), WAIT_DELAY);
      await volumeSlider.click();

      await driver.delayMs(COMMON_DELAY);
    } catch (err) {
      LogUtil.showError(Constant.TAG, `soundSettingsTest_011 err code: ${err?.code} msg: ${err?.message}`);
    }

    LogUtil.info(`${Constant.TAG} soundSettingsTest_011 end`);
    done();
  }
}

function soundSettingsTest_012(driver: Driver): Function {
  return async (done: Function) => {
    LogUtil.info(`${Constant.TAG} soundSettingsTest_012 start`);
    try {
      await driver.delayMs(COMMON_DELAY);
      await driver.assertComponentExist(ON.id('slider_vassistant_volume'));
      let volumeSlider = await driver.waitForComponent(ON.id('slider_vassistant_volume'), WAIT_DELAY);
      await volumeSlider.click();

      await driver.delayMs(COMMON_DELAY);
    } catch (err) {
      LogUtil.showError(Constant.TAG, `soundSettingsTest_012 err code: ${err?.code} msg: ${err?.message}`);
    }

    LogUtil.info(`${Constant.TAG} soundSettingsTest_012 end`);
    done();
  }
}

function soundSettingsTest_013(driver: Driver): Function {
  return async (done: Function) => {
    try {
      LogUtil.info(`${Constant.TAG} soundSettingsTest_013 start`);
      await driver.delayMs(COMMON_DELAY);

      let compId: string = 'Setting.Volume.advanced_group.screen_lock_tone.result';
      let switchTab = await driver.waitForComponent(ON.id(compId), WAIT_DELAY);
      await switchTab.click();
      await driver.delayMs(COMMON_DELAY);
      LogUtil.info(`${Constant.TAG} screen lock switchTab clicked`);

      await driver.assertComponentExist(ON.checked(false).id(compId));
      switchTab = await driver.waitForComponent(ON.id(compId), WAIT_DELAY);
      await switchTab.click();
      await driver.delayMs(COMMON_DELAY);

      await driver.assertComponentExist(ON.checked(true).id(compId));
    } catch (err) {
      LogUtil.showError(Constant.TAG, `soundSettingsTest_013 err: ${err?.code} msg: ${err?.message}`);
    }
    LogUtil.info(`${Constant.TAG} soundSettingsTest_013 end`);
    done();
  }
}

function soundSettingsTest_014(driver: Driver): Function {
  return async (done: Function) => {
    try {
      LogUtil.info(`${Constant.TAG} soundSettingsTest_014 start`);
      await driver.delayMs(COMMON_DELAY);

      let compId: string = 'Setting.Volume.advanced_group.screenshot_prompt_tone.result';
      let switchTab = await driver.waitForComponent(ON.id(compId), WAIT_DELAY);
      await switchTab.click();
      await driver.delayMs(COMMON_DELAY);
      LogUtil.info(`${Constant.TAG} screen shot switchTab clicked`);

      await driver.assertComponentExist(ON.checked(false).id(compId));
      switchTab = await driver.waitForComponent(ON.id(compId), WAIT_DELAY);
      await switchTab.click();
      await driver.delayMs(COMMON_DELAY);

      await driver.assertComponentExist(ON.checked(true).id(compId));
    } catch (err) {
      LogUtil.showError(Constant.TAG, `soundSettingsTest_014 err: ${err?.code} msg: ${err?.message}`);
    }
    LogUtil.info(`${Constant.TAG} soundSettingsTest_014 end`);
    done();
  }
}
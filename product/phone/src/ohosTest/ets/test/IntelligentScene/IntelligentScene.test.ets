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

import { Driver, ON } from '@ohos.UiTest';
import abilityDelegatorRegistry from '@ohos.app.ability.abilityDelegatorRegistry';
import { AbilityContextManager } from '@ohos/settings.common/src/main/ets/ability/AbilityContextManager';
import { afterAll, ArgumentMatchers, beforeAll, describe, expect, it, MockKit, when } from '@ohos/hypium';
import { NavEntryKey } from '@ohos/settings.common/src/main/ets/utils/Consts';
import { LogUtil } from '@ohos/settings.common/src/main/ets/utils/LogUtil';
import { DisplayConstant } from '@ohos/settings.common/src/main/ets/constant/DisplayConstant';
import { ContextUtils } from '@ohos/settings.common/src/main/ets/utils/baseutils/ContextUtils';
import { FontScaleUtils } from '@ohos/settings.common/src/main/ets/utils/FontScaleUtils';
import { LanguageUtils } from '@ohos/settings.common/src/main/ets/utils/LanguageUtils';
import { COMMON_DELAY } from '../types';
import {
  IntelligentSceneFontScaleUtil
} from '../../../../main/ets/Setting/IntelligentScene/utils/IntelligentSceneFontScaleUtil';
import { Constant } from '../constant/Constant';

const TAG: string = 'IntelligentScenePageTest';
const DELEGATOR: abilityDelegatorRegistry.AbilityDelegator = abilityDelegatorRegistry.getAbilityDelegator();

export default function IntelligentScenePageTest() {
  describe('IntelligentScenePageTest', () => {
    let dr: Driver = Driver.create();
    beforeAll(async () => {
      try {
        await DELEGATOR.startAbility({
          'bundleName': 'com.ohos.settings',
          'abilityName': 'com.ohos.settings.MainAbility',
          'uri': NavEntryKey.INTELLIGENT_SCENE_SETTINGS_ENTRY,
        }).then(() => {
          LogUtil.info(`${TAG} com.ohos.settings.MainAbility start success`);
        });
      } catch (err) {
        LogUtil.info(`${TAG} failed to startAbility. Code: ${err?.code}, message: ${err?.message}`);
      }
    });

    afterAll(async () => {
      await dr.delayMs(COMMON_DELAY);
      await dr.pressHome();
      await dr.delayMs(COMMON_DELAY);
    });

    it('intelligentSceneFontScaleUtilTest_contextEmptyTest', 0, intelligentSceneFontScaleUtilTest_contextEmptyTest(dr));
    it('intelligentSceneFontScaleUtilTest_stateTest', 0, intelligentSceneFontScaleUtilTest_stateTest(dr));
    it('intelligentSceneFontScaleUtilTest_toolBarTest', 0, intelligentSceneFontScaleUtilTest_toolBarTest(dr));
    it('intelligentSceneMainPageTest', 0, intelligentSceneMainPageTest(dr));
  })
}

function intelligentSceneMainPageTest(driver: Driver): Function {
  return async (done: Function) => {
    LogUtil.info(`${TAG} intelligentSceneMainPageTest start`);
    await driver.delayMs(COMMON_DELAY);
    try {
      const START_X: number = 260;
      const START_Y: number = 1900;
      const END_X: number = 200;
      const END_Y: number = 397;
      const SPEED: number = 6000;
      await driver.swipe(START_X, START_Y, END_X, END_Y, SPEED);
      await driver.delayMs(COMMON_DELAY);
      let appAndMetaServiceItem = await driver.waitForComponent(ON.text('应用'), COMMON_DELAY);
      await appAndMetaServiceItem.click();
      await driver.delayMs(COMMON_DELAY);
      let metaServiceTab = await driver.findComponent(ON.text('元服务'));
      await metaServiceTab.click();
      await driver.delayMs(COMMON_DELAY);

      let appTab = await driver.findComponent(ON.text('应用'));
      await appTab.click();
      await driver.delayMs(COMMON_DELAY);

    } catch (err) {
      LogUtil.showError(TAG, `intelligentSceneMainPageTest err.code : ${err?.code}, message: ${err?.message}`);
    }
    done();
    LogUtil.info(`${TAG} intelligentSceneMainPageTest end`);
  };
}

function intelligentSceneFontScaleUtilTest_contextEmptyTest(driver: Driver): Function {
  return async (done: Function) => {
    LogUtil.info(`${Constant.TAG} intelligentSceneFontScaleUtilTest_contextEmptyTest start`);
    let context = ContextUtils.getContext();
    let isHUGE4Mode: boolean = IntelligentSceneFontScaleUtil.isHUGE4Mode(context);
    if (!context) {
      expect(isHUGE4Mode).assertFalse();
    }
    done();
    LogUtil.info(`${Constant.TAG} intelligentSceneFontScaleUtilTest_contextEmptyTest end`);
  };
}

function intelligentSceneFontScaleUtilTest_stateTest(driver: Driver): Function {
  return async (done: Function) => {
    let scale: number = FontScaleUtils.getCurrentScale(AbilityContextManager.getContext());
    let isHUGE4Mode: boolean = IntelligentSceneFontScaleUtil.isHUGE4Mode(AbilityContextManager.getContext());
    LogUtil.info(`${Constant.TAG} intelligentSceneFontScaleUtilTest_stateTest start`);
    if (scale >= DisplayConstant.TEXT_FONT_SIZE_HUGE4) {
      expect(isHUGE4Mode).assertTrue();
    } else {
      expect(isHUGE4Mode).assertFalse();
    }
    done();
    LogUtil.info(`${Constant.TAG} intelligentSceneFontScaleUtilTest_stateTest end`);
  };
}

  function intelligentSceneFontScaleUtilTest_toolBarTest(driver: Driver): Function {
    return async (done: Function) => {
      LogUtil.info(`${Constant.TAG} intelligentSceneFontScaleUtilTest_toolBarTest start`);
      let mocker: MockKit = new MockKit();
      const BO_LANGUAGE_ID: string = 'bo';
      const CHINA_LANGUAGE_ID: string = 'ch';
      let getLanguage: Function = mocker.mockFunc(LanguageUtils, LanguageUtils.getLanguage);
      when(getLanguage)(ArgumentMatchers.any).afterReturn(BO_LANGUAGE_ID);

      let getCurrentScale: Function = mocker.mockFunc(FontScaleUtils, FontScaleUtils.getCurrentScale);
      when(getCurrentScale)(ArgumentMatchers.any).afterReturn(FontScaleUtils.EXTRA_LARGE_FONT_3);

      const result1 = IntelligentSceneFontScaleUtil.getToolbarMaxFontSize(AbilityContextManager.getContext(), 100);
      expect(result1).assertEqual(DisplayConstant.TEXT_FONT_SIZE_LARGE);

      when(getLanguage)(ArgumentMatchers.any).afterReturn(CHINA_LANGUAGE_ID);
      const result2 = IntelligentSceneFontScaleUtil.getToolbarMaxFontSize(AbilityContextManager.getContext(), 100);
      expect(result2).assertEqual(FontScaleUtils.EXTRA_LARGE_FONT_1);

      mocker.ignoreMock(LanguageUtils, getLanguage);
      mocker.ignoreMock(FontScaleUtils, getCurrentScale);

      done();
      LogUtil.info(`${Constant.TAG} intelligentSceneFontScaleUtilTest_toolBarTest end`);
    };
}


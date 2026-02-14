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

import { describe, it, expect, TestType } from '@ohos/hypium';
import { LogUtil } from '@ohos/settings.common/src/main/ets/utils/LogUtil';
import { SettingsBaseMenu } from '@ohos/settings.common/src/main/ets/core/model/menu/SettingsMenu';
import {
  MenuController,
  CanvasMenuController,
  SwitchMenuController,
  SliderMenuController,
  PasswordCircleController,
  ButtonMenuController,
} from '@ohos/settings.common/src/main/ets/core/controller/MenuController';

const MENU_KEY: string = 'test_menu';
const SLIDER_MAX_100: number = 100;
const SLIDER_VALUE_0: number = 0;
const SLIDER_VALUE_5: number = 5;
const SLIDER_MODE_1: number = 1;
const SLIDER_STEP_1: number = 1;
const TAG: string = 'CommonMenuControllerTest';

export default function commonMenuControllerTest() {
  describe('CommonMenuControllerTest', () => {
    it('CommonMenuControllerTest_001', TestType.FUNCTION, async () => {
      LogUtil.info(`${TAG} CommonMenuControllerTest_001 start`);
      new SettingsBaseMenu({
        key: MENU_KEY,
      });
      let menu: SettingsBaseMenu = new SettingsBaseMenu;
      let createMenuController = MenuController.CreateMenuController(menu);
      expect(createMenuController !== null).assertTrue();
      LogUtil.info(`${TAG} CommonMenuControllerTest_001 end`);
    });

    it('CommonMenuControllerTest_002', TestType.FUNCTION, async () => {
      LogUtil.info(`${TAG} CommonMenuControllerTest_002 start`);
      new SettingsBaseMenu({
        key: MENU_KEY,
      });
      let menu: SettingsBaseMenu = new SettingsBaseMenu;
      let menuController = new MenuController(menu);
      let createMenuController = MenuController.CreateMenuController(menu);
      expect(createMenuController !== null).assertTrue();
      let getKey = menuController.getKey();
      expect(getKey !== null).assertTrue();
      LogUtil.info(`${TAG} CommonMenuControllerTest_002 end`);
    });

    it('CommonMenuControllerTest_003', TestType.FUNCTION, async () => {
      LogUtil.info(`${TAG} CommonMenuControllerTest_003 start`);
      new SettingsBaseMenu({
        key: MENU_KEY,
      });
      let menu: SettingsBaseMenu = new SettingsBaseMenu;
      let canvasMenuController = new CanvasMenuController(menu);
      let createCanvasMenuController = CanvasMenuController.CreateCanvasMenuController(menu);
      expect(createCanvasMenuController !== null).assertTrue();
      let getCanvasRenderingContext = canvasMenuController.getCanvasRenderingContext();
      expect(getCanvasRenderingContext !== null).assertTrue();
      let onCanvasReady = await canvasMenuController.onCanvasReady();
      expect(onCanvasReady !== null).assertTrue();
      let onCanvasDisappear = canvasMenuController.onCanvasDisappear();
      expect(onCanvasDisappear !== null).assertTrue();
      LogUtil.info(`${TAG} CommonMenuControllerTest_003 end`);
    });

    it('CommonMenuControllerTest_004', TestType.FUNCTION, async () => {
      LogUtil.info(`${TAG} CommonMenuControllerTest_004 start`);
      new SettingsBaseMenu({
        key: MENU_KEY,
      });
      let menu: SettingsBaseMenu = new SettingsBaseMenu;
      let switchMenuController = new SwitchMenuController(menu);
      let updateStatus = switchMenuController.updateStatus();
      expect(updateStatus !== null).assertTrue();
      LogUtil.info(`${TAG} CommonMenuControllerTest_004 end`);
    });

    it('CommonMenuControllerTest_005', TestType.FUNCTION, async () => {
      LogUtil.info(`${TAG} CommonMenuControllerTest_005 start`);
      new SettingsBaseMenu({
        key: MENU_KEY,
      });
      let menu: SettingsBaseMenu = new SettingsBaseMenu;
      let switchMenuController = new SwitchMenuController(menu);
      let result = await switchMenuController.onToggleChange(true);
      expect(result).assertTrue();
      LogUtil.info(`${TAG} CommonMenuControllerTest_005 end`);
    });

    it('CommonMenuControllerTest_006', TestType.FUNCTION, async () => {
      LogUtil.info(`${TAG} CommonMenuControllerTest_005 start`);
      new SettingsBaseMenu({
        key: MENU_KEY,
      });
      let menu: SettingsBaseMenu = new SettingsBaseMenu;
      let switchMenuController = new SwitchMenuController(menu);
      let getChecked = switchMenuController.getChecked();
      expect(getChecked !== null).assertTrue();
      LogUtil.info(`${TAG} CommonMenuControllerTest_006 end`);
    });

    it('CommonMenuControllerTest_007', TestType.FUNCTION, async () => {
      LogUtil.info(`${TAG} CommonMenuControllerTest_007 start`);
      new SettingsBaseMenu({
        key: MENU_KEY,
      });
      let menu: SettingsBaseMenu = new SettingsBaseMenu;
      let sliderMenuController = new SliderMenuController(menu);
      let sliderMin = sliderMenuController.getSliderMin();
      expect(sliderMin).assertEqual(SLIDER_VALUE_0);
      LogUtil.info(`${TAG} CommonMenuControllerTest_007 end`);
    });

    it('CommonMenuControllerTest_008', TestType.FUNCTION, async () => {
      LogUtil.info(`${TAG} CommonMenuControllerTest_008 start`);
      new SettingsBaseMenu({
        key: MENU_KEY,
      });
      let menu: SettingsBaseMenu = new SettingsBaseMenu;
      let sliderMenuController = new SliderMenuController(menu);
      let sliderMax = sliderMenuController.getSliderMax();
      expect(sliderMax).assertEqual(SLIDER_MAX_100);
      LogUtil.info(`${TAG} CommonMenuControllerTest_008 end`);
    });

    it('CommonMenuControllerTest_009', TestType.FUNCTION, async () => {
      LogUtil.info(`${TAG} CommonMenuControllerTest_009 start`);
      new SettingsBaseMenu({
        key: MENU_KEY,
      });
      let menu: SettingsBaseMenu = new SettingsBaseMenu;
      let sliderMenuController = new SliderMenuController(menu);
      let sliderStep = sliderMenuController.getSliderStep();
      expect(sliderStep).assertEqual(SLIDER_STEP_1);
      LogUtil.info(`${TAG} CommonMenuControllerTest_009 end`);
    });

    it('CommonMenuControllerTest_010', TestType.FUNCTION, async () => {
      LogUtil.info(`${TAG} CommonMenuControllerTest_010 start`);
      new SettingsBaseMenu({
        key: MENU_KEY,
      });
      let menu: SettingsBaseMenu = new SettingsBaseMenu;
      let sliderMenuController = new SliderMenuController(menu);
      let sliderValue = sliderMenuController.onSliderChange(SLIDER_VALUE_5, SLIDER_MODE_1);
      expect(sliderValue).assertTrue();
      LogUtil.info(`${TAG} CommonMenuControllerTest_010 end`);
    });

    it('CommonMenuControllerTestTest_011', TestType.FUNCTION, async () => {
      LogUtil.info(`${TAG} CommonMenuControllerTestTest_011 start`);
      new SettingsBaseMenu({
        key: MENU_KEY,
      });
      let menu: SettingsBaseMenu = new SettingsBaseMenu;
      let passwordCircleController = new PasswordCircleController(menu);
      let getTextInputKey = passwordCircleController.getTextInputKey();
      expect(getTextInputKey === '').assertTrue();
      LogUtil.info(`${TAG} CommonMenuControllerTestTest_011 end`);
    });

    it('CommonMenuControllerTestTest_012', TestType.FUNCTION, async () => {
      LogUtil.info(`${TAG} CommonMenuControllerTestTest_012 start`);
      new SettingsBaseMenu({
        key: MENU_KEY,
      });
      let menu: SettingsBaseMenu = new SettingsBaseMenu;
      let passwordCircleController = new PasswordCircleController(menu);
      let getPasswordCircle: Array<string> = passwordCircleController.getPasswordCircle();
      expect(getPasswordCircle.length === 0).assertTrue();
      LogUtil.info(`${TAG} CommonMenuControllerTestTest_012 end`);
    });

    it('CommonMenuControllerTestTest_013', TestType.FUNCTION, async () => {
      LogUtil.info(`${TAG} CommonMenuControllerTestTest_013 start`);
      new SettingsBaseMenu({
        key: MENU_KEY,
      });
      let menu: SettingsBaseMenu = new SettingsBaseMenu;
      let passwordCircleController = new PasswordCircleController(menu);
      let getPassword: string = passwordCircleController.getPassword();
      expect(getPassword === '').assertTrue();
      LogUtil.info(`${TAG} CommonMenuControllerTestTest_013 end`);
    });

    it('CommonMenuControllerTestTest_014', TestType.FUNCTION, async () => {
      LogUtil.info(`${TAG} CommonMenuControllerTestTest_014 start`);
      new SettingsBaseMenu({
        key: MENU_KEY,
      });
      let menu: SettingsBaseMenu = new SettingsBaseMenu;
      let buttonMenuController = new ButtonMenuController(menu);
      let isButton1Enabled = buttonMenuController.isButton1Enabled();
      expect(isButton1Enabled).assertTrue();
      LogUtil.info(`${TAG} CommonMenuControllerTestTest_014 end`);
    });

    it('CommonMenuControllerTestTest_015', TestType.FUNCTION, async () => {
      LogUtil.info(`${TAG} CommonMenuControllerTestTest_015 start`);
      new SettingsBaseMenu({
        key: MENU_KEY,
      });
      let menu: SettingsBaseMenu = new SettingsBaseMenu;
      let buttonMenuController = new ButtonMenuController(menu);
      let isButton2Enabled = buttonMenuController.isButton2Enabled();
      expect(isButton2Enabled).assertTrue();
      LogUtil.info(`${TAG} CommonMenuControllerTestTest_015 end`);
    });

    it('CommonMenuControllerTestTest_016', TestType.FUNCTION, async () => {
      LogUtil.info(`${TAG} CommonMenuControllerTestTest_016 start`);
      new SettingsBaseMenu({
        key: MENU_KEY,
      });
      let menu: SettingsBaseMenu = new SettingsBaseMenu;
      let buttonMenuController = new ButtonMenuController(menu);
      let isButton3Enabled = buttonMenuController.isButton3Enabled();
      expect(isButton3Enabled).assertTrue();
      LogUtil.info(`${TAG} CommonMenuControllerTestTest_016 end`);
    });
  });
}
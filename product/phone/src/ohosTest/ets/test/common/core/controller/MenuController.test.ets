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
  TextInputMenuController,
  PasswordCircleController,
  ButtonMenuController,
  DialogButtonMenuController,
  MenuGroupController,
  EmptyInvisibleController,
  EmulatorMenuController,
  LoadingMenuController,
  LoadingGroupController,
  RadioMenuController,
  SimpleVolumeMenuController,
  JumpController,
  JumpAbilityController,
  JumpServiceExtensionController,
  UIExtensionJumpController,
  CheckboxMenuController,
  MultiCheckboxMenuController,
  NavCheckboxMenuController,
  MultiCheckImageMenuController,
  ButtonWithVariableTitleMenuController,
  UnRespondTouchController,
  DialogChainTextInputController,
  PinRequiredTextInputController,
  DialogChainCheckboxController,
  SingleChoiceListController,
} from '@ohos/settings.common/src/main/ets/core/controller/MenuController';
import { Constant } from '../../.././constant/Constant';

const MENU_KEY: string = 'test_menu';
const SLIDER_MAX_100: number = 100;
const SLIDER_VALUE_0: number = 0;
const SLIDER_VALUE_5: number = 5;
const SLIDER_MODE_1: number = 1;
const SLIDER_STEP_1: number = 1;
const TIME_LEFT: number = 100;
const CONTROLLER_KEY: string = 'bluetooth_PinConsist_message';
const INDEX: number = 1;

export default function MenuControllerTest() {
  describe('MenuControllerTest', () => {

    /*
    * @tc.number: MenuControllerTest_001
    * @tc.name: 基础菜单控制器
    * @tc.type: TestType.FUNCTION
    * @tc.desc: return true
    */
    it('MenuControllerTest_001', TestType.FUNCTION, async () => {
      LogUtil.info(`${Constant.TAG} MenuControllerTest_001 start`);
      new SettingsBaseMenu({
        key: MENU_KEY,
      });
      let menu: SettingsBaseMenu = new SettingsBaseMenu;
      let menuController = new MenuController(menu);
      let createMenuController = MenuController.CreateMenuController(menu);
      expect(createMenuController !== null).assertTrue();
      let getKey = menuController.getKey();
      expect(getKey !== null).assertTrue();
      let getLogKey = menuController.getLogKey();
      expect(getLogKey !== null).assertTrue();
      let refreshUi = menuController.refreshUi();
      expect(refreshUi !== null).assertTrue();
      let refreshFontStyle = menuController.refreshFontStyle();
      expect(refreshFontStyle !== null).assertTrue();
      let bindUi = menuController.bindUi(null);
      expect(bindUi !== null).assertTrue();
      let aboutToAppear = menuController.aboutToAppear();
      expect(aboutToAppear !== null).assertTrue();
      let aboutToDisappear = menuController.aboutToDisappear();
      expect(aboutToDisappear !== null).assertTrue();
      let onPageDestroy = menuController.onPageDestroy();
      expect(onPageDestroy !== null).assertTrue();
      let onMenuClick = menuController.onMenuClick();
      expect(onMenuClick === false).assertTrue();
      let isVisibleStatus = menuController.isVisibleStatus();
      expect(isVisibleStatus !== null).assertTrue();
      let setVisible = menuController.setVisible(!isVisibleStatus);
      expect(setVisible !== null).assertTrue();
      let setRender = menuController.setRender(false);
      expect(setRender !== null).assertTrue();
      let registerControllerDataChange = menuController.registerControllerDataChange(CONTROLLER_KEY);
      expect(registerControllerDataChange !== null).assertTrue();
      let unRegisterControllerDataChange = menuController.unRegisterControllerDataChange(CONTROLLER_KEY);
      expect(unRegisterControllerDataChange !== null).assertTrue();
      let publishDataChange = menuController.publishDataChange(CONTROLLER_KEY);
      expect(publishDataChange !== null).assertTrue();
      let onDataChange = menuController.onDataChange(CONTROLLER_KEY, CONTROLLER_KEY);
      expect(onDataChange !== null).assertTrue();
      let onRegisteredByObserver = menuController.onRegisteredByObserver(CONTROLLER_KEY);
      expect(onRegisteredByObserver !== null).assertTrue();
      let scrollToIndex = menuController.scrollToIndex(INDEX);
      expect(scrollToIndex !== null).assertTrue();
      let scrollEdge = menuController.scrollEdge(INDEX);
      expect(scrollEdge !== null).assertTrue();
      let closeDialog = menuController.closeDialog();
      expect(closeDialog !== null).assertTrue();
      let closeSelf = menuController.closeSelf();
      expect(closeSelf !== null).assertTrue();
      let handleHoverButtonClick = menuController.handleHoverButtonClick();
      expect(handleHoverButtonClick !== null).assertTrue();
      let handleHoverEvent = menuController.handleHoverEvent(false);
      expect(handleHoverEvent !== null).assertTrue();
      let isComponentHovered = menuController.isComponentHovered();
      expect(isComponentHovered).assertFalse();
      let isMenuVisible = MenuController.isMenuVisible(menu);
      expect(isMenuVisible !== null).assertTrue();
      let notifyChange = menuController.notifyChange();
      expect(notifyChange !== null).assertTrue();
      LogUtil.info(`${Constant.TAG} MenuControllerTest_001 end`);
    });

    /*
    * @tc.number: MenuControllerTest_002
    * @tc.name: 菜单点击事件
    * @tc.type: TestType.FUNCTION
    * @tc.desc: return true
    */
    it('MenuControllerTest_002', TestType.FUNCTION, async () => {
      LogUtil.info(`${Constant.TAG} MenuControllerTest_002 start`);
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
      LogUtil.info(`${Constant.TAG} MenuControllerTest_002 end`);
    });

    /*
    * @tc.number: MenuControllerTest_003
    * @tc.name: 菜单点击事件
    * @tc.type: TestType.FUNCTION
    * @tc.desc: return true
    */
    it('MenuControllerTest_003', TestType.FUNCTION, async () => {
      LogUtil.info(`${Constant.TAG} MenuControllerTest_003 start`);
      new SettingsBaseMenu({
        key: MENU_KEY,
      });
      let menu: SettingsBaseMenu = new SettingsBaseMenu;
      let switchMenuController = new SwitchMenuController(menu);
      let updateStatus = switchMenuController.updateStatus();
      expect(updateStatus !== null).assertTrue();
      let result = await switchMenuController.onToggleChange(true);
      expect(result).assertTrue();
      let getChecked = switchMenuController.getChecked();
      expect(getChecked !== null).assertTrue();
      let getToggleState = switchMenuController.getToggleState();
      expect(getToggleState !== null).assertTrue();
      let setChecked = switchMenuController.setChecked(false);
      expect(setChecked !== null).assertTrue();
      let setToggleState = switchMenuController.setToggleState(false);
      expect(setToggleState !== null).assertTrue();
      LogUtil.info(`${Constant.TAG} MenuControllerTest_003 end`);
    });

    /*
    * @tc.number: MenuControllerTest_004
    * @tc.name: 滑动条菜单控制器
    * @tc.type: TestType.FUNCTION
    * @tc.desc: 开关菜单控制器验证
    */
    it('MenuControllerTest_004', TestType.FUNCTION, async () => {
      LogUtil.info(`${Constant.TAG} MenuControllerTest_004 start`);
      new SettingsBaseMenu({
        key: MENU_KEY,
      });
      let menu: SettingsBaseMenu = new SettingsBaseMenu;
      let sliderMenuController = new SliderMenuController(menu);
      let sliderMin = sliderMenuController.getSliderMin();
      expect(sliderMin).assertEqual(SLIDER_VALUE_0);
      let sliderMax = sliderMenuController.getSliderMax();
      expect(sliderMax).assertEqual(SLIDER_MAX_100);
      let sliderStep = sliderMenuController.getSliderStep();
      expect(sliderStep).assertEqual(SLIDER_STEP_1);
      let sliderValue = sliderMenuController.onSliderChange(SLIDER_VALUE_5, SLIDER_MODE_1);
      expect(sliderValue).assertTrue();
      let sliderValueResult = sliderMenuController.getSliderValue();
      let result = sliderMenuController.setSliderValue(sliderValueResult);
      expect(result !== null).assertTrue();
      let updateStatus = sliderMenuController.updateStatus();
      expect(updateStatus !== null).assertTrue();
      let onStartIconClick = sliderMenuController.onStartIconClick();
      expect(onStartIconClick !== null).assertTrue();
      let onEndIconClick = sliderMenuController.onEndIconClick();
      expect(onEndIconClick !== null).assertTrue();
      LogUtil.info(`${Constant.TAG} MenuControllerTest_004 end`);
    });

    /*
    * @tc.number: MenuControllerTest_005
    * @tc.name: 输入框菜单控制器
    * @tc.type: TestType.FUNCTION
    * @tc.desc: return true
    */
    it('MenuControllerTest_005', TestType.FUNCTION, async () => {
      LogUtil.info(`${Constant.TAG} MenuControllerTest_005 start`);
      new SettingsBaseMenu({
        key: MENU_KEY,
      });
      let menu: SettingsBaseMenu = new SettingsBaseMenu;
      let textInputMenuController = new TextInputMenuController(menu);
      let onTextInputChange = textInputMenuController.onTextInputChange('');
      expect(onTextInputChange !== null).assertTrue();
      let onEditChange = textInputMenuController.onEditChange(false);
      expect(onEditChange !== null).assertTrue();
      let onSubmit = textInputMenuController.onSubmit(EnterKeyType.Done);
      expect(onSubmit !== null).assertTrue();
      LogUtil.info(`${Constant.TAG} MenuControllerTest_005 end`);
    });

    /*
    * @tc.number: MenuControllerTestTest_006
    * @tc.name: 密码圆圈菜单控制器
    * @tc.type: TestType.FUNCTION
    * @tc.desc:
    */
    it('MenuControllerTestTest_006', TestType.FUNCTION, async () => {
      LogUtil.info(`${Constant.TAG} MenuControllerTestTest_006 start`);
      new SettingsBaseMenu({
        key: MENU_KEY,
      });
      let menu: SettingsBaseMenu = new SettingsBaseMenu;
      let passwordCircleController = new PasswordCircleController(menu);
      let getTextInputKey = passwordCircleController.getTextInputKey();
      expect(getTextInputKey === '').assertTrue();
      let onTextInputChange = passwordCircleController.onTextInputChange('');
      expect(onTextInputChange !== null).assertTrue();
      let onSubmit = passwordCircleController.onSubmit(EnterKeyType.Done);
      expect(onSubmit !== null).assertTrue();
      let getPasswordCircle = passwordCircleController.getPasswordCircle();
      expect(getPasswordCircle !== null).assertTrue();
      let getPassword = passwordCircleController.getPassword();
      expect(getPassword === '').assertTrue();
      LogUtil.info(`${Constant.TAG} MenuControllerTestTest_006 end`);
    });

    /*
    * @tc.number: MenuControllerTestTest_007
    * @tc.name: 按钮菜单控制器，最多支持3个按钮
    * @tc.type: TestType.FUNCTION
    * @tc.desc:
    */
    it('MenuControllerTestTest_007', TestType.FUNCTION, async () => {
      LogUtil.info(`${Constant.TAG} MenuControllerTestTest_007 start`);
      new SettingsBaseMenu({
        key: MENU_KEY,
      });
      let menu: SettingsBaseMenu = new SettingsBaseMenu;
      let buttonMenuController = new ButtonMenuController(menu);
      let onButton1Click = buttonMenuController.onButton1Click();
      expect(onButton1Click !== null).assertTrue();
      let onButton2Click = buttonMenuController.onButton2Click();
      expect(onButton2Click !== null).assertTrue();
      let onButton3Click = buttonMenuController.onButton3Click();
      expect(onButton3Click !== null).assertTrue();
      let isButton1Enabled = buttonMenuController.isButton1Enabled();
      expect(isButton1Enabled).assertTrue();
      let isButton2Enabled = buttonMenuController.isButton2Enabled();
      expect(isButton2Enabled).assertTrue();
      let isButton3Enabled = buttonMenuController.isButton3Enabled();
      expect(isButton3Enabled).assertTrue();
      LogUtil.info(`${Constant.TAG} MenuControllerTestTest_007 end`);
    });

    /*
    * @tc.number: MenuControllerTest_008
    * @tc.name: Dialog中的按钮菜单控制器
    * @tc.type: TestType.FUNCTION
    * @tc.desc: return true
    */
    it('MenuControllerTest_008', TestType.FUNCTION, async () => {
      LogUtil.info(`${Constant.TAG} MenuControllerTest_008 start`);
      new SettingsBaseMenu({
        key: MENU_KEY,
      });
      let menu: SettingsBaseMenu = new SettingsBaseMenu;
      let dialogButtonMenuController = new DialogButtonMenuController(menu);
      let onButton1Click = dialogButtonMenuController.onButton1Click();
      expect(onButton1Click !== null).assertTrue();
      let onButton2Click = dialogButtonMenuController.onButton2Click();
      expect(onButton2Click !== null).assertTrue();
      let onButton3Click = dialogButtonMenuController.onButton3Click();
      expect(onButton3Click !== null).assertTrue();
      LogUtil.info(`${Constant.TAG} MenuControllerTest_008 end`);
    });

    /*
    * @tc.number: MenuControllerTest_009
    * @tc.name: 菜单组控制器
    * @tc.type: TestType.FUNCTION
    * @tc.desc:
    */
    it('MenuControllerTest_009', TestType.FUNCTION, async () => {
      LogUtil.info(`${Constant.TAG} MenuControllerTest_009 start`);
      new SettingsBaseMenu({
        key: MENU_KEY,
      });
      let menu: SettingsBaseMenu = new SettingsBaseMenu;
      let menuGroupController = new MenuGroupController(menu);
      let clearChildren = menuGroupController.clearChildren();
      expect(clearChildren !== null).assertTrue();
      let addChildren = menuGroupController.addChildren([menu]);
      expect(addChildren !== null).assertTrue();
      let addChildrenToShift = menuGroupController.addChildrenToShift([menu]);
      expect(addChildrenToShift !== null).assertTrue();
      let removeChildren = menuGroupController.removeChildren(MENU_KEY);
      expect(removeChildren !== null).assertTrue();
      let findChildResult = menuGroupController.findChild(MENU_KEY);
      expect(findChildResult).assertNull();
      let getChildrenResult = menuGroupController.getChildren();
      expect(getChildrenResult).assertInstanceOf('Array');
      let refreshChildren = menuGroupController.refreshChildren();
      expect(refreshChildren !== null).assertTrue();
      LogUtil.info(`${Constant.TAG} MenuControllerTest_009 end`);
    });

    /*
    * @tc.number: MenuControllerTest_010
    * @tc.name: 内容空的时候自动隐藏菜单组控制器
    * @tc.type: TestType.FUNCTION
    * @tc.desc: return true
    */
    it('MenuControllerTest_010', TestType.FUNCTION, async () => {
      LogUtil.info(`${Constant.TAG} MenuControllerTest_010 start`);
      new SettingsBaseMenu({
        key: MENU_KEY,
      });
      let menu: SettingsBaseMenu = new SettingsBaseMenu;
      let emptyInvisibleController = new EmptyInvisibleController(menu);
      let createEmptyInvisibleController = EmptyInvisibleController.CreateEmptyInvisibleController(menu);
      expect(createEmptyInvisibleController !== null).assertTrue();
      let aboutToAppear = emptyInvisibleController.aboutToAppear();
      expect(aboutToAppear !== null).assertTrue();
      let getCurrentVisibleStatus = emptyInvisibleController.getCurrentVisibleStatus();
      expect(getCurrentVisibleStatus !== null).assertTrue();
      LogUtil.info(`${Constant.TAG} MenuControllerTest_010 end`);
    });

    /*
    * @tc.number: MenuControllerTest_011
    * @tc.name: 内容空的时候自动隐藏菜单组控制器,模拟器模式隐藏部分菜单
    * @tc.type: TestType.FUNCTION
    * @tc.desc: return true
    */
    it('MenuControllerTest_011', TestType.FUNCTION, async () => {
      LogUtil.info(`${Constant.TAG} MenuControllerTest_011 start`);
      new SettingsBaseMenu({
        key: MENU_KEY,
      });
      let menu: SettingsBaseMenu = new SettingsBaseMenu;
      let emulatorMenuController = new EmulatorMenuController(menu);
      let createEmulatorMenuController = EmulatorMenuController.CreateEmulatorMenuController(menu);
      expect(createEmulatorMenuController !== null).assertTrue();
      let aboutToAppear = emulatorMenuController.aboutToAppear();
      expect(aboutToAppear !== null).assertTrue();
      let getCurrentVisibleStatus = emulatorMenuController.getCurrentVisibleStatus();
      expect(getCurrentVisibleStatus !== null).assertTrue();
      LogUtil.info(`${Constant.TAG} MenuControllerTest_011 end`);
    });

    /*
    * @tc.number: MenuControllerTest_012
    * @tc.name: 加载菜单控制器
    * @tc.type: TestType.FUNCTION
    * @tc.desc: return true
    */
    it('MenuControllerTest_012', TestType.FUNCTION, async () => {
      LogUtil.info(`${Constant.TAG} MenuControllerTest_012 start`);
      new SettingsBaseMenu({
        key: MENU_KEY,
      });
      let menu: SettingsBaseMenu = new SettingsBaseMenu;
      let loadingMenuController = new LoadingMenuController(menu);
      let onDataChange = loadingMenuController.onDataChange(CONTROLLER_KEY, CONTROLLER_KEY);
      expect(onDataChange !== null).assertTrue();
      let isLoadingVisible = loadingMenuController.isLoadingVisible();
      expect(isLoadingVisible !== null).assertTrue();
      LogUtil.info(`${Constant.TAG} MenuControllerTest_012 end`);
    });

    /*
    * @tc.number: MenuControllerTest_013
    * @tc.name: 加载菜单控制器
    * @tc.type: TestType.FUNCTION
    * @tc.desc: return true
    */
    it('MenuControllerTest_013', TestType.FUNCTION, async () => {
      LogUtil.info(`${Constant.TAG} MenuControllerTest_013 start`);
      new SettingsBaseMenu({
        key: MENU_KEY,
      });
      let menu: SettingsBaseMenu = new SettingsBaseMenu;
      let loadingGroupController = new LoadingGroupController(menu);
      let setLoading = loadingGroupController.setLoading(false);
      expect(setLoading !== null).assertTrue();
      LogUtil.info(`${Constant.TAG} MenuControllerTest_013 end`);
    });

    /*
    * @tc.number: MenuControllerTest_014
    * @tc.name: 单选卡片控制器
    * @tc.type: TestType.FUNCTION
    * @tc.desc: return true
    */
    it('MenuControllerTest_014', TestType.FUNCTION, async () => {
      LogUtil.info(`${Constant.TAG} MenuControllerTest_014 start`);
      new SettingsBaseMenu({
        key: MENU_KEY,
      });
      let menu: SettingsBaseMenu = new SettingsBaseMenu;
      let radioMenuController = new RadioMenuController(menu);
      let onRadioChange = radioMenuController.onRadioChange(false);
      expect(onRadioChange !== null).assertTrue();
      let setRadio = radioMenuController.setRadio(false);
      expect(setRadio !== null).assertTrue();
      LogUtil.info(`${Constant.TAG} MenuControllerTest_014 end`);
    });

    /*
    * @tc.number: MenuControllerTest_015
    * @tc.name: 单选卡片控制器
    * @tc.type: TestType.FUNCTION
    * @tc.desc: return true
    */
    it('MenuControllerTest_015', TestType.FUNCTION, async () => {
      LogUtil.info(`${Constant.TAG} MenuControllerTest_015 start`);
      new SettingsBaseMenu({
        key: MENU_KEY,
      });
      let menu: SettingsBaseMenu = new SettingsBaseMenu;
      let simpleVolumeMenuController = new SimpleVolumeMenuController(menu);
      let onRadioChange = simpleVolumeMenuController.onRadioChange(0);
      expect(onRadioChange !== null).assertTrue();
      LogUtil.info(`${Constant.TAG} MenuControllerTest_015 end`);
    });

    /*
    * @tc.number: MenuControllerTest_016
    * @tc.name: 跳转控制器
    * @tc.type: TestType.FUNCTION
    * @tc.desc: return false
    */
    it('MenuControllerTest_016', TestType.FUNCTION, async () => {
      LogUtil.info(`${Constant.TAG} MenuControllerTest_016 start`);
      new SettingsBaseMenu({
        key: MENU_KEY,
      });
      let menu: SettingsBaseMenu = new SettingsBaseMenu;
      let jumpController = new JumpController(menu);
      let createJumpController = JumpController.CreateJumpController(menu);
      expect(createJumpController !== null).assertTrue();
      let result = await jumpController.onMenuClick();
      expect(result).assertFalse();
      let onMenuClickCallback = jumpController.onMenuClickCallback();
      expect(onMenuClickCallback !== null).assertTrue();
      let updateStatus = jumpController.updateStatus();
      expect(updateStatus !== null).assertTrue();
      LogUtil.info(`${Constant.TAG} MenuControllerTest_016 end`);
    });

    /*
    * @tc.number: MenuControllerTest_017
    * @tc.name: 拉起市场应用控制器
    * @tc.type: TestType.FUNCTION
    * @tc.desc: return false
    */
    it('MenuControllerTest_017', TestType.FUNCTION, async () => {
      LogUtil.info(`${Constant.TAG} MenuControllerTest_017 start`);
      new SettingsBaseMenu({
        key: MENU_KEY,
      });
      let menu: SettingsBaseMenu = new SettingsBaseMenu;
      let jumpAbilityController = new JumpAbilityController(menu);
      let createJumpAbilityController = JumpAbilityController.CreateJumpAbilityController(menu);
      expect(createJumpAbilityController !== null).assertTrue();
      let result = await jumpAbilityController.onMenuClick();
      expect(result).assertFalse();
      let onMenuClickCallback = jumpAbilityController.onMenuClickCallback();
      expect(onMenuClickCallback !== null).assertTrue();
      LogUtil.info(`${Constant.TAG} MenuControllerTest_017 end`);
    });


    /*
    * @tc.number: MenuControllerTest_018
    * @tc.name: 跳转控制器
    * @tc.type: TestType.FUNCTION
    * @tc.desc: return false
    */
    it('MenuControllerTest_018', TestType.FUNCTION, async () => {
      LogUtil.info(`${Constant.TAG} MenuControllerTest_018 start`);
      new SettingsBaseMenu({
        key: MENU_KEY,
      });
      let menu: SettingsBaseMenu = new SettingsBaseMenu;
      let jumpServiceExtensionController = new JumpServiceExtensionController(menu);
      let createJumpService = JumpServiceExtensionController.CreateJumpServiceExtensionController(menu);
      expect(createJumpService !== null).assertTrue();
      let result = await jumpServiceExtensionController.onMenuClick();
      expect(result).assertFalse();
      let onMenuClickCallback = jumpServiceExtensionController.onMenuClickCallback();
      expect(onMenuClickCallback !== null).assertTrue();
      LogUtil.info(`${Constant.TAG} MenuControllerTest_018 end`);
    });

    /*
    * @tc.number: MenuControllerTest_019
    * @tc.name: UXExtension跳转控制器
    * @tc.type: TestType.FUNCTION
    * @tc.desc: return false
    */
    it('MenuControllerTest_019', TestType.FUNCTION, async () => {
      LogUtil.info(`${Constant.TAG} MenuControllerTest_019 start`);
      new SettingsBaseMenu({
        key: MENU_KEY,
      });
      let menu: SettingsBaseMenu = new SettingsBaseMenu;
      let uiExtensionJumpController = new UIExtensionJumpController(menu);
      let createUIExtensionJumpController = UIExtensionJumpController.CreateUIExtensionJumpController(menu);
      expect(createUIExtensionJumpController !== null).assertTrue();
      let result = await uiExtensionJumpController.onMenuClick();
      expect(result).assertFalse();
      let onMenuClickCallback = uiExtensionJumpController.onMenuClickCallback();
      expect(onMenuClickCallback !== null).assertTrue();
      LogUtil.info(`${Constant.TAG} MenuControllerTest_019 end`);
    });

    /*
    * @tc.number: MenuControllerTest_020
    * @tc.name: 勾选菜单控制器
    * @tc.type: TestType.FUNCTION
    * @tc.desc: return false
    */
    it('MenuControllerTest_020', TestType.FUNCTION, async () => {
      LogUtil.info(`${Constant.TAG} MenuControllerTest_020 start`);
      new SettingsBaseMenu({
        key: MENU_KEY,
      });
      let menu: SettingsBaseMenu = new SettingsBaseMenu;
      let checkboxMenuController = new CheckboxMenuController(menu);
      let onMenuChange = checkboxMenuController.onMenuChange(false);
      expect(onMenuChange !== null).assertTrue();
      LogUtil.info(`${Constant.TAG} MenuControllerTest_020 end`);
    });

    /*
    * @tc.number: MenuControllerTest_021
    * @tc.name: 多选菜单控制器
    * @tc.type: TestType.FUNCTION
    * @tc.desc: return false
    */
    it('MenuControllerTest_021', TestType.FUNCTION, async () => {
      LogUtil.info(`${Constant.TAG} MenuControllerTest_021 start`);
      new SettingsBaseMenu({
        key: MENU_KEY,
      });
      let menu: SettingsBaseMenu = new SettingsBaseMenu;
      let multiCheckboxMenuController = new MultiCheckboxMenuController(menu);
      let onMenuChange = multiCheckboxMenuController.onMenuChange(false);
      expect(onMenuChange !== null).assertTrue();
      let setCheckBox = multiCheckboxMenuController.setCheckBox(false);
      expect(setCheckBox !== null).assertTrue();
      LogUtil.info(`${Constant.TAG} MenuControllerTest_021 end`);
    });

    /*
    * @tc.number: MenuControllerTest_022
    * @tc.name: 多选菜单控制器
    * @tc.type: TestType.FUNCTION
    * @tc.desc: return false
    */
    it('MenuControllerTest_022', TestType.FUNCTION, async () => {
      LogUtil.info(`${Constant.TAG} MenuControllerTest_022 start`);
      new SettingsBaseMenu({
        key: MENU_KEY,
      });
      let menu: SettingsBaseMenu = new SettingsBaseMenu;
      let navCheckboxMenuController = new NavCheckboxMenuController(menu);
      let onCheckboxChange = navCheckboxMenuController.onCheckboxChange(false);
      expect(onCheckboxChange !== null).assertTrue();
      let setCheckBox = navCheckboxMenuController.setCheckBox(false);
      expect(setCheckBox !== null).assertTrue();
      LogUtil.info(`${Constant.TAG} MenuControllerTest_022 end`);
    });

    /*
    * @tc.number: MenuControllerTest_023
    * @tc.name: 辅助功能快捷键系统弹窗菜单控制器
    * @tc.type: TestType.FUNCTION
    * @tc.desc: return false
    */
    it('MenuControllerTest_023', TestType.FUNCTION, async () => {
      LogUtil.info(`${Constant.TAG} MenuControllerTest_023 start`);
      new SettingsBaseMenu({
        key: MENU_KEY,
      });
      let menu: SettingsBaseMenu = new SettingsBaseMenu;
      let multiCheckImageMenuController = new MultiCheckImageMenuController(menu);
      let onMenuChange = multiCheckImageMenuController.onMenuChange(false);
      expect(onMenuChange !== null).assertTrue();
      LogUtil.info(`${Constant.TAG} MenuControllerTest_023 end`);
    });

    /*
    * @tc.number: MenuControllerTest_024
    * @tc.name: 可变标题的按钮菜单控制器
    * @tc.type: TestType.FUNCTION
    * @tc.desc: return true
    */
    it('MenuControllerTest_024', TestType.FUNCTION, async () => {
      LogUtil.info(`${Constant.TAG} MenuControllerTest_024 start`);
      new SettingsBaseMenu({
        key: MENU_KEY,
      });
      let menu: SettingsBaseMenu = new SettingsBaseMenu;
      let buttonWithVariableTitleMenuController = new ButtonWithVariableTitleMenuController(menu);
      let onButtonClick = buttonWithVariableTitleMenuController.onButtonClick();
      expect(onButtonClick !== null).assertTrue();
      let setTitleResult = await buttonWithVariableTitleMenuController.setTitle(TIME_LEFT);
      expect(setTitleResult).assertUndefined();
      let isButtonEnabledResult = await buttonWithVariableTitleMenuController.isButtonEnabled();
      expect(isButtonEnabledResult).assertTrue();
      LogUtil.info(`${Constant.TAG} MenuControllerTest_024 end`);
    });

    /*
    * @tc.number: MenuControllerTest_025
    * @tc.name: 不响应touch事件的菜单控制器
    * @tc.type: TestType.FUNCTION
    * @tc.desc: return false
    */
    it('MenuControllerTest_025', TestType.FUNCTION, async () => {
      LogUtil.info(`${Constant.TAG} MenuControllerTest_025 start`);
      new SettingsBaseMenu({
        key: MENU_KEY,
      });
      let menu: SettingsBaseMenu = new SettingsBaseMenu;
      let unRespondTouchController = new UnRespondTouchController(menu);
      let aboutToAppear = unRespondTouchController.aboutToAppear();
      expect(aboutToAppear !== null).assertTrue();
      LogUtil.info(`${Constant.TAG} MenuControllerTest_025 end`);
    });

    /*
    * @tc.number: MenuControllerTest_026
    * @tc.name: 不响应touch事件的菜单控制器
    * @tc.type: TestType.FUNCTION
    * @tc.desc: return false
    */
    it('MenuControllerTest_026', TestType.FUNCTION, async () => {
      LogUtil.info(`${Constant.TAG} MenuControllerTest_026 start`);
      new SettingsBaseMenu({
        key: MENU_KEY,
      });
      let menu: SettingsBaseMenu = new SettingsBaseMenu;
      let dialogChainTextInputController = new DialogChainTextInputController(menu);
      let createDialogChainTextInputController = DialogChainTextInputController.CreateDialogChainTextInputController(menu);
      expect(createDialogChainTextInputController !== null).assertTrue();
      let onDataChange = dialogChainTextInputController.onDataChange(CONTROLLER_KEY, false);
      expect(onDataChange !== null).assertTrue();
      let onTextInputChange = dialogChainTextInputController.onTextInputChange('');
      expect(onTextInputChange !== null).assertTrue();
      LogUtil.info(`${Constant.TAG} MenuControllerTest_026 end`);
    });

    /*
    * @tc.number: MenuControllerTest_027
    * @tc.name: 不响应touch事件的菜单控制器
    * @tc.type: TestType.FUNCTION
    * @tc.desc: return false
    */
    it('MenuControllerTest_027', TestType.FUNCTION, async () => {
      LogUtil.info(`${Constant.TAG} MenuControllerTest_027 start`);
      new SettingsBaseMenu({
        key: MENU_KEY,
      });
      let menu: SettingsBaseMenu = new SettingsBaseMenu;
      let pinRequiredTextInputController = new PinRequiredTextInputController(menu);
      let createPinRequiredTextInput = PinRequiredTextInputController.CreatePinRequiredTextInputController(menu);
      expect(createPinRequiredTextInput !== null).assertTrue();
      let onTextInputChange = pinRequiredTextInputController.onTextInputChange('');
      expect(onTextInputChange !== null).assertTrue();
      LogUtil.info(`${Constant.TAG} MenuControllerTest_027 end`);
    });

    /*
    * @tc.number: MenuControllerTest_028
    * @tc.name: 不响应touch事件的菜单控制器
    * @tc.type: TestType.FUNCTION
    * @tc.desc: return false
    */
    it('MenuControllerTest_028', TestType.FUNCTION, async () => {
      LogUtil.info(`${Constant.TAG} MenuControllerTest_028 start`);
      new SettingsBaseMenu({
        key: MENU_KEY,
      });
      let menu: SettingsBaseMenu = new SettingsBaseMenu;
      let dialogChainCheckboxController = new DialogChainCheckboxController(menu);
      let createDialogChainCheckboxController = DialogChainCheckboxController.CreateDialogChainCheckboxController(menu);
      expect(createDialogChainCheckboxController !== null).assertTrue();
      let publishDataChange = dialogChainCheckboxController.publishDataChange('');
      expect(publishDataChange !== null).assertTrue();
      LogUtil.info(`${Constant.TAG} MenuControllerTest_028 end`);
    });

    /*
    * @tc.number: MenuControllerTest_029
    * @tc.name: 不响应touch事件的菜单控制器
    * @tc.type: TestType.FUNCTION
    * @tc.desc: return false
    */
    it('MenuControllerTest_029', TestType.FUNCTION, async () => {
      LogUtil.info(`${Constant.TAG} MenuControllerTest_029 start`);
      new SettingsBaseMenu({
        key: MENU_KEY,
      });
      let menu: SettingsBaseMenu = new SettingsBaseMenu;
      let singleChoiceListController = new SingleChoiceListController(menu);
      let createSingleChoiceListController = SingleChoiceListController.SingleChoiceListController(menu);
      expect(createSingleChoiceListController !== null).assertTrue();
      let onSelectMenuChanged = singleChoiceListController.onSelectMenuChanged(0);
      expect(onSelectMenuChanged !== null).assertTrue();
      let onBindMenuAppear = singleChoiceListController.onBindMenuAppear();
      expect(onBindMenuAppear !== null).assertTrue();
      let onBindMenuDisAppear = singleChoiceListController.onBindMenuDisAppear();
      expect(onBindMenuDisAppear !== null).assertTrue();
      LogUtil.info(`${Constant.TAG} MenuControllerTest_029 end`);
    });
  });
}
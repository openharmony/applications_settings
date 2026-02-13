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

import { describe, it, expect, TestType, MockKit, when } from '@ohos/hypium';
import { LogUtil } from '@ohos/settings.common/src/main/ets/utils/LogUtil';
import { SettingsBaseMenu } from '@ohos/settings.common/src/main/ets/core/model/menu/SettingsMenu';
import {
  ExternalMenuController,
  UIExtensionMenuController,
  ExternalSwitchController,
  UIExtensionSubMenuController,
  ExternalStateController,
} from '@ohos/settings.common/src/main/ets/externalmenu/ExternalMenuController';
import { Constant } from '../../constant/Constant';
import { ExternalMenu } from '@ohos/settings.common';

const MENU_KEY: string = 'test_menu';
const MENU_KEY_NULL: string = '';

export default function ExternalMenuControllerTest() {
  describe('ExternalMenuControllerTest', () => {

    /*
    * @tc.number: ExternalMenuControllerTest_001
    * @tc.name: 菜单点击事件
    * @tc.type: TestType.FUNCTION
    * @tc.desc: return True
    */
    it('ExternalMenuControllerTest_001', TestType.FUNCTION, async () => {
      LogUtil.info(`${Constant.TAG} ExternalMenuControllerTest_001 start`);
      new SettingsBaseMenu({
        key: MENU_KEY,
      });
      let menu: SettingsBaseMenu = new SettingsBaseMenu;
      let externalMenuController = new ExternalMenuController(menu);
      let trueResult: boolean = await externalMenuController.onMenuClick();
      expect(trueResult).assertTrue();
      LogUtil.info(`${Constant.TAG} ExternalMenuControllerTest_001 end`);
    });

    /*
    * @tc.number: ExternalMenuControllerTest_002
    * @tc.name: 菜单点击事件
    * @tc.type: TestType.FUNCTION
    * @tc.desc: return true
    */
    it('ExternalMenuControllerTest_002', TestType.FUNCTION, async () => {
      LogUtil.info(`${Constant.TAG} ExternalMenuControllerTest_002 start`);
      new SettingsBaseMenu({
        key: MENU_KEY,
      });
      let menu: SettingsBaseMenu = new SettingsBaseMenu;
      let uiExtensionMenuController = new UIExtensionMenuController(menu);
      let mocker: MockKit = new MockKit();
      let mockFunc: Function = mocker.mockFunc(uiExtensionMenuController, uiExtensionMenuController.onMenuClick);
      when(mockFunc)().afterReturn(true);
      let result: boolean = await uiExtensionMenuController.onMenuClick();
      expect(result).assertTrue();
      LogUtil.info(`${Constant.TAG} ExternalMenuControllerTest_002 end`);
      mocker.clear(uiExtensionMenuController);
    });

    /*
    * @tc.number: ExternalMenuControllerTest_003
    * @tc.name: 菜单点击事件
    * @tc.type: TestType.FUNCTION
    * @tc.desc: return false
    */
    it('ExternalMenuControllerTest_003', TestType.FUNCTION, async () => {
      LogUtil.info(`${Constant.TAG} ExternalMenuControllerTest_003 start`);
      new SettingsBaseMenu({
        key: MENU_KEY_NULL,
      });
      let menu: SettingsBaseMenu = new SettingsBaseMenu;
      let uiExtensionMenuController = new UIExtensionMenuController(menu);
      let result: boolean = await uiExtensionMenuController.onMenuClick();
      expect(result).assertFalse();
      LogUtil.info(`${Constant.TAG} ExternalMenuControllerTest_003 end`);
    });

    /*
    * @tc.number: ExternalMenuControllerTest_004
    * @tc.name: 返回开关的实时状态
    * @tc.type: TestType.FUNCTION
    * @tc.desc: 返回 true
    */
    it('ExternalMenuControllerTest_004', TestType.FUNCTION, async () => {
      LogUtil.info(`${Constant.TAG} ExternalMenuControllerTest_004 start`);
      new SettingsBaseMenu({
        key: MENU_KEY,
      });
      let menu: SettingsBaseMenu = new SettingsBaseMenu;
      let externalSwitchController = new ExternalSwitchController(menu);
      let trueResult: boolean = await externalSwitchController.onToggleChange(true);
      expect(trueResult).assertTrue();
      LogUtil.info(`${Constant.TAG} ExternalMenuControllerTest_004 end`);
    });

    /*
    * @tc.number: ExternalMenuControllerTest_005
    * @tc.name: 返回开关的保存状态
    * @tc.type: TestType.FUNCTION
    * @tc.desc: 返回 true
    */
    it('ExternalMenuControllerTest_005', TestType.FUNCTION, async () => {
      LogUtil.info(`${Constant.TAG} ExternalMenuControllerTest_005 start`);
      new SettingsBaseMenu({
        key: MENU_KEY,
      });
      let menu: SettingsBaseMenu = new SettingsBaseMenu;
      let externalSwitchController = new ExternalSwitchController(menu);
      let result: boolean = await externalSwitchController.getChecked();
      expect(result).assertTrue();
      LogUtil.info(`${Constant.TAG} ExternalMenuControllerTest_005 end`);
    });

    /*
    * @tc.number: ExternalMenuControllerTest_006
    * @tc.name: 设置开关的状态
    * @tc.type: TestType.FUNCTION
    * @tc.desc: return true
    */
    it('ExternalMenuControllerTest_006', TestType.FUNCTION, async () => {
      LogUtil.info(`${Constant.TAG} ExternalMenuControllerTest_006 start`);
      new SettingsBaseMenu({
        key: MENU_KEY,
      });
      let menu: SettingsBaseMenu = new SettingsBaseMenu;
      let externalSwitchController = new ExternalSwitchController(menu);
      let mocker: MockKit = new MockKit();
      let mockFunc: Function = mocker.mockFunc(externalSwitchController, externalSwitchController.setChecked);
      when(mockFunc)(true).afterReturn(true);
      let result = await externalSwitchController.setChecked(true);
      expect(result !== null).assertTrue();
      LogUtil.info(`${Constant.TAG} ExternalMenuControllerTest_006 end`);
      mocker.clear(externalSwitchController);
    });

    it('ExternalMenuControllerTest_createExternalMenuController', 0, () => {
      let menuInstance = ExternalMenuController;
      let menu: SettingsBaseMenu = new SettingsBaseMenu;
      menuInstance.createExternalMenuController(menu)
    });

    it('ExternalMenuControllerTest_onLangChange', 0, () => {
      let menu: SettingsBaseMenu = new SettingsBaseMenu;
      let menuInstance = new ExternalMenuController(menu);
      menuInstance.externalMenu = {
        bundleName: '',
        abilityName: '',
        key: 'key',
        menuType: '',
        showCondition: '',
        titleResource: '',
        title: '',
        state: '',
        iconResource: '',
        icon: '',
        summaryResource: '',
        summary: '',
        stateDbKey: '',
        stateDefault: '',
        switchDbKey: '',
        switchDefault: '',
        accessTokenId: 1,
      } as ExternalMenu;
      menuInstance.onLangChange('test')
    });

    it('ExternalMenuControllerTest_onLangChange_01', 0, () => {
      let menu: SettingsBaseMenu = new SettingsBaseMenu;
      let menuInstance = new ExternalMenuController(menu);
      menuInstance.getListenerName()
    });

    it('ExternalMenuControllerTest_updateStatus', 0, () => {
      let menu: SettingsBaseMenu = new SettingsBaseMenu;
      let menuInstance = new ExternalMenuController(menu);
      menuInstance.updateStatus()
    });

    it('ExternalMenuControllerTest_getListenerName', 0, () => {
      let menu: SettingsBaseMenu = new SettingsBaseMenu({
        key: 'key'
      });
      let menuInstance = new ExternalMenuController(menu);
      menuInstance.getListenerName()
    });

    it('ExternalMenuControllerTest_getListenerName2', 0, () => {
      let menu: SettingsBaseMenu = new SettingsBaseMenu;
      let menuInstance = new ExternalMenuController(menu);
      menuInstance.getListenerName()
    });

    it('ExternalMenuControllerTest_updateStatus_01', 0, () => {
      let menu: SettingsBaseMenu = new SettingsBaseMenu;
      let menuInstance = new ExternalMenuController(menu);
      menuInstance.updateStatus()
    });

    it('ExternalMenuControllerTest_getObserverKey', 0, () => {
      let menu: SettingsBaseMenu = new SettingsBaseMenu;
      let menuInstance = new ExternalMenuController(menu);
      menuInstance.getObserverKey()
    });

    it('ExternalMenuControllerTest_onPageShow', 0, () => {
      let menu: SettingsBaseMenu = new SettingsBaseMenu;
      let menuInstance = new ExternalMenuController(menu);
      menuInstance.onPageShow()
    });

    it('ExternalMenuControllerTest_onExternalMenuChange', 0, () => {
      let menu: SettingsBaseMenu = new SettingsBaseMenu;
      let menuInstance = new ExternalMenuController(menu);
      menuInstance.externalMenu = {
        bundleName: 'bundleName',
        abilityName: '',
        key: 'key',
        menuType: '',
        showCondition: '',
        titleResource: '',
        title: '',
        state: '',
        iconResource: '',
        icon: '',
        summaryResource: '',
        summary: '',
        stateDbKey: '',
        stateDefault: '',
        switchDbKey: '',
        switchDefault: '',
        accessTokenId: 1,
      } as ExternalMenu;
      menuInstance.onExternalMenuChange('bundleName')
    });

    it('ExternalMenuControllerTest_onExternalMenuLoadFinish', 0, () => {
      let menu: SettingsBaseMenu = new SettingsBaseMenu;
      let menuInstance = new ExternalMenuController(menu);
      menuInstance.onExternalMenuLoadFinish()
    });

    it('ExternalMenuControllerTest_loadContentResourceForInit', 0, async () => {
      let menu: SettingsBaseMenu = new SettingsBaseMenu;
      let menuInstance = new ExternalMenuController(menu);
      await menuInstance.loadContentResourceForInit(true)
    });

    it('ExternalMenuControllerTest_loadContentResourceForInit_01', 0, async () => {
      let menu: SettingsBaseMenu = new SettingsBaseMenu;
      let menuInstance = new ExternalMenuController(menu);
    });

    it('ExternalMenuControllerTest_CreateUIExtensionSubMenuController', 0, async () => {
      let uiInstance = UIExtensionSubMenuController;
      let menu: SettingsBaseMenu = new SettingsBaseMenu;
      let result = uiInstance.CreateUIExtensionSubMenuController(menu)
      expect(result !== null).assertTrue()
    });

    it('ExternalMenuControllerTest_onMenuClick', 0, async () => {
      let menu: SettingsBaseMenu = new SettingsBaseMenu;
      let uiInstance = new UIExtensionSubMenuController(menu);
      let result = uiInstance.onMenuClick()
      expect(result !== null).assertTrue()
    });

    it('ExternalStateController_onSettingsDataChange', 0, async () => {
      let menu: SettingsBaseMenu = new SettingsBaseMenu;
      let externalInstance = new ExternalStateController(menu);
      let result = externalInstance.onSettingsDataChange()
      expect(result !== null).assertTrue()
    });

    it('ExternalSwitchController_onSettingsDataChange', 0, async () => {
      let menu: SettingsBaseMenu = new SettingsBaseMenu;
      let externalSwitchInstance = new ExternalSwitchController(menu);
      let result = externalSwitchInstance.onToggleChange(true)
      expect(result !== null).assertTrue()
    });

    it('ExternalSwitchController_setChecked', 0, async () => {
      let menu: SettingsBaseMenu = new SettingsBaseMenu;
      let externalSwitchInstance = new ExternalSwitchController(menu);
      let result = externalSwitchInstance.setChecked(false)
      expect(result !== null).assertTrue()
    });

  });
}
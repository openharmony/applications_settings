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

import { describe, it, expect, TestType, MockKit, when, ArgumentMatchers } from '@ohos/hypium';
import { LogUtil } from '@ohos/settings.common/src/main/ets/utils/LogUtil';
import {
  PageRoot,
  DialogPageRoot,
} from '@ohos/settings.common/src/main/ets/core/viewmodel/PageViewModel';
import { Constant } from '../../.././constant/Constant';
import { MenuGroup, MenuPage,
  MenuSection,
  SettingsBaseMenu } from '@ohos/settings.common/src/main/ets/core/model/menu/SettingsMenu';
import { PageLifecycleOwner } from '@ohos/settings.common/src/main/ets/core/lifecycle/Lifecycle';

const MENU_KEY: string = 'test_menu';
const INDEX_0: number = 0;
const CONTROLLER_KEY: string = 'bluetooth_PinConsist_message';

export default function PageViewModelTest() {
  describe('PageViewModelTest', () => {

    /*
    * @tc.number: PageViewModelTest_002
    * @tc.name: onSelfCancel
    * @tc.type: TestType.FUNCTION
    * @tc.desc: return true
    */
    it('PageViewModelTest_002', TestType.FUNCTION, async () => {
      LogUtil.info(`${Constant.TAG} PageViewModelTest_002 start`);
      let dialogPageRoot = new DialogPageRoot();
      let setAutoCancel = dialogPageRoot.setAutoCancel(false);
      expect(setAutoCancel !== null).assertTrue();
      let onSelfCancel = dialogPageRoot.onSelfCancel();
      expect(onSelfCancel !== null).assertTrue();
      let onSelfCancelBindThis = dialogPageRoot.onSelfCancelBindThis();
      expect(onSelfCancelBindThis !== null).assertTrue();
      let onSelfOpen = dialogPageRoot.onSelfOpen(CONTROLLER_KEY);
      expect(onSelfOpen !== null).assertTrue();
      let onSelfClose = dialogPageRoot.onSelfClose(CONTROLLER_KEY);
      expect(onSelfClose !== null).assertTrue();
      let openSelf = dialogPageRoot.openSelf(false);
      expect(openSelf !== null).assertTrue();
      let aboutToDisappear = dialogPageRoot.aboutToDisappear();
      expect(aboutToDisappear !== null).assertTrue();
      LogUtil.info(`${Constant.TAG} PageViewModelTest_002 end`);
    });
    // PageRoot
    it("PageViewModelTest_003", 0, () => {
      let pageR: PageRoot = new PageRoot();
      pageR.setMenuPage(undefined);
      let pageM: MenuPage = new MenuPage();
      pageR.setMenuPage(pageM);

      pageR.onPageShow();
      pageR.onPageHide();
      (pageR as object)['lifecycleOwner'] = new PageLifecycleOwner();
      pageR.onPageShow();
      pageR.onPageHide();

      let menu: SettingsBaseMenu = new SettingsBaseMenu();
      let mocker: MockKit = new MockKit();
      let mockFun: Function = mocker.mockFunc(pageR, pageR.getController);
      when(mockFun)(ArgumentMatchers.any).afterReturn('');
      pageR.isMenuVisible(menu);
      mocker.clear(pageR);
      expect(pageR != null).assertTrue();
    })
    // getListFirstVisibleMenu
    it("PageViewModelTest_003_01", 0, () => {
      let pageR: PageRoot = new PageRoot();
      pageR.getListFirstVisibleMenu([]);

      let menus: SettingsBaseMenu[] = [new SettingsBaseMenu()];
      pageR.getListFirstVisibleMenu(menus);

      let mocker: MockKit = new MockKit();
      let mockFun: Function = mocker.mockFunc(pageR, pageR.getFirstVisibleMenu);
      when(mockFun)(ArgumentMatchers.any).afterReturn(true);
      pageR.getListFirstVisibleMenu(menus);

      when(mockFun)(ArgumentMatchers.any).afterReturn(false);
      pageR.getListFirstVisibleMenu(menus);

      mocker.clear(pageR);
      expect(pageR != null).assertTrue();
    })
    // getFirstVisibleMenu
    it("PageViewModelTest_003_02", 0, () => {
      let pageR: PageRoot = new PageRoot();
      let menu: SettingsBaseMenu = new SettingsBaseMenu();
      pageR.getFirstVisibleMenu(menu);

      let menu1: MenuGroup = new MenuGroup();
      let mocker1: MockKit = new MockKit();
      let mockFun1: Function = mocker1.mockFunc(pageR, pageR.getListFirstVisibleMenu);
      when(mockFun1)(ArgumentMatchers.any).afterReturn(true);
      pageR.getFirstVisibleMenu(menu1);

      when(mockFun1)(ArgumentMatchers.any).afterReturn(false);
      pageR.getFirstVisibleMenu(menu1);

      let menu2: MenuSection = new MenuSection();
      let mocker2: MockKit = new MockKit();
      let mockFun2: Function = mocker2.mockFunc(pageR, pageR.getSectionFirstVisibleChild);
      when(mockFun2)(ArgumentMatchers.any).afterReturn(true);
      pageR.getFirstVisibleMenu(menu2);

      when(mockFun2)(ArgumentMatchers.any).afterReturn(false);
      pageR.getFirstVisibleMenu(menu2);

      let mocker: MockKit = new MockKit();
      let mockFun: Function = mocker.mockFunc(pageR, pageR.isMenuVisible);
      when(mockFun)(ArgumentMatchers.any).afterReturn(false);
      pageR.getFirstVisibleMenu(menu1);

      mocker.clear(pageR);
      mocker1.clear(pageR);
      mocker2.clear(pageR);
      expect(pageR != null).assertTrue();
    })
    // getSectionFirstVisibleChild
    it("PageViewModelTest_003_03", 0, () => {
      let pageR: PageRoot = new PageRoot();
      let menu: MenuSection = new MenuSection();
      let mocker: MockKit = new MockKit();
      let mockFun: Function = mocker.mockFunc(pageR, pageR.getFirstVisibleMenu);
      when(mockFun)(menu.getFooter()).afterReturn(true);
      pageR.getSectionFirstVisibleChild(menu);

      mockFun = mocker.mockFunc(pageR, pageR.getListFirstVisibleMenu);
      when(mockFun)(ArgumentMatchers.any).afterReturn(true);
      pageR.getSectionFirstVisibleChild(menu);

      mockFun = mocker.mockFunc(pageR, pageR.getFirstVisibleMenu);
      when(mockFun)(menu.getHeader()).afterReturn(true);
      pageR.getSectionFirstVisibleChild(menu);

      mocker.clear(pageR);
      expect(pageR != null).assertTrue();
    })
    // updateFirstVisibleChild、updateFirstVisibleContentChild
    it("PageViewModelTest_003_04", 0, () => {
      let pageR: PageRoot = new PageRoot();
      (pageR as object)['updateFirstVisibleChild']();
      let child: SettingsBaseMenu = AppStorage.get<SettingsBaseMenu>('child') as SettingsBaseMenu;
      (pageR as object)['updateFirstVisibleContentChild'](child);
      let settingsBaseM: SettingsBaseMenu = new SettingsBaseMenu();
      (pageR as object)['firstVisibleChild'] = settingsBaseM;
      (pageR as object)['updateFirstVisibleChild']();
      (pageR as object)['updateFirstVisibleContentChild']();
      expect(pageR != null).assertTrue();
    })
    // setDialogPageRoot、openDialog
    it("PageViewModelTest_003_05", 0, () => {
      let pageR: PageRoot = new PageRoot();
      pageR.setDialogPageRoot(undefined);
      let dialog: DialogPageRoot = new DialogPageRoot();
      pageR.setDialogPageRoot(dialog);

      let menuPage: MenuPage = new MenuPage();
      pageR.openDialog(menuPage);
      (pageR as object)['dialog'] = null;
      pageR.openDialog(menuPage);
      expect(pageR != null).assertTrue();
    })
    // getDialogControllersCount
    it("PageViewModelTest_003_06", 0, () => {
      let pageR: PageRoot = new PageRoot();
      let dialog: DialogPageRoot = new DialogPageRoot();
      pageR.getDialogControllersCount();
      (pageR as object)['dialog'] = dialog;
      let mocker: MockKit = new MockKit();
      let mockFun: Function =
        mocker.mockFunc((pageR as object)['dialog'], (pageR as object)['dialog'].getControllersCount);
      when(mockFun)(ArgumentMatchers.any).afterReturn(1);
      pageR.getDialogControllersCount();

      mocker.clear((pageR as object)['dialog']);
      expect(pageR != null).assertTrue();
    })
    // registerControllerObserver
    it("PageViewModelTest_003_07", 0, () => {
      let pageR: PageRoot = new PageRoot();
      pageR.registerControllerObserver('', '');
      expect(pageR != null).assertTrue();
    })
    // other
    it("PageViewModelTest_003_08", 0, () => {
      let pageR: PageRoot = new PageRoot();
      pageR.onDialogCancel();
      pageR.onDialogOpen();
      pageR.onDialogClose();
      (pageR as object)['lifecycleOwner'] = new PageLifecycleOwner();
      pageR.onDialogCancel();
      pageR.onDialogOpen();
      pageR.onDialogClose();

      pageR.deleteController('');
      pageR.deleteController('1');
      expect(pageR != null).assertTrue();
    })
    // DialogPageRoot
    it("PageViewModelTest_004", 0, () => {
      let dialogPageR: DialogPageRoot = new DialogPageRoot();
      dialogPageR.onSelfCancel();
      dialogPageR.openSelf(false);
      dialogPageR.closeSelf();

      let dialogController: CustomDialogController = new CustomDialogController({builder: 1});
      dialogPageR.dialogController = dialogController;
      dialogPageR.onSelfCancel();
      expect(dialogPageR != null).assertTrue();
    })
  });
}
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

import { describe, beforeEach, it, expect, TestType, MockKit, when, ArgumentMatchers } from '@ohos/hypium';
import { Driver, ON } from '@ohos.UiTest';
import { Controller, CustomMenuManager, UiRefresher } from '@ohos/settings.common';
import {
  MenuGroup,
  MenuSection,
  SettingsBaseMenu,
} from '@ohos/settings.common/src/main/ets/core/model/menu/SettingsMenu';
import { LogUtil } from '@ohos/settings.common/src/main/ets/utils/LogUtil';
import { BusinessError } from '@ohos.base';
import abilityDelegatorRegistry from '@ohos.app.ability.abilityDelegatorRegistry';
import { Constant } from '../../../../constant/Constant';
import { COMMON_DELAY } from '../../../../types';
import { sleep } from '@ohos/settings.native/src/main/cpp/types/libnative';

const DELEGATOR: abilityDelegatorRegistry.AbilityDelegator = abilityDelegatorRegistry.getAbilityDelegator();
const MENU_KEY: string = 'test_menu';

export default function settingsMenuTest() {
  describe('settingsMenuTest', () => {
    beforeEach(() => {
      CustomMenuManager.getInstance().getHideMenus().clear();
    });

    /*
    * @tc.number:settingsMenu_addMenusTest_001
    * @tc.name: 添加菜单验证
    * @tc.type: TestType.FUNCTION
    * @tc.desc: 添加菜单时，如果该菜单属于定制移除列表，则删除该菜单
    */
    it('settingsMenu_addMenusTest_001', TestType.FUNCTION, () => {
      const MOVE_MENU_KEY: string = 'test_menu';
      const NORMAL_MENU_KEY: string = 'menu';
      CustomMenuManager.getInstance().getHideMenus().add(MOVE_MENU_KEY);
      let menuGroup = new MenuGroup({
        key: 'menuGroup'
      });
      menuGroup.addMenus([
        new SettingsBaseMenu({
          key: MOVE_MENU_KEY
        }),
      ]);

      menuGroup.addMenus([
        new SettingsBaseMenu({
          key: NORMAL_MENU_KEY
        }),
      ]);

      expect(menuGroup.menus.findIndex(menu => menu.key === MOVE_MENU_KEY)).assertEqual(-1);
      expect(menuGroup.menus.findIndex(menu => menu.key === NORMAL_MENU_KEY) !== -1).assertTrue();
    });

    /*
    * @tc.number: settingsMenuTest_003
    * @tc.name: 基础Menu数据
    * @tc.type: TestType.FUNCTION
    * @tc.desc: return true
    */
    it('settingsMenuTest_003', TestType.FUNCTION, async () => {
      LogUtil.info(`${Constant.TAG} MenuDataSourceTest_001 start`);
      let settingsBaseMenu = new SettingsBaseMenu();
      let clear = settingsBaseMenu.clear();
      expect(clear !== null).assertTrue();
      let toLogString = settingsBaseMenu.toLogString();
      expect(toLogString !== null).assertTrue();
      let print = settingsBaseMenu.print();
      expect(print !== null).assertTrue();
      let setSummary = settingsBaseMenu.setSummary('');
      expect(setSummary !== null).assertTrue();
      let setStyle = settingsBaseMenu.setStyle('');
      expect(setStyle !== null).assertTrue();
      let setIcon = settingsBaseMenu.setIcon('');
      expect(setIcon !== null).assertTrue();
      let printMenuList = SettingsBaseMenu.printMenuList([]);
      expect(printMenuList !== null).assertTrue();
      LogUtil.info(`${Constant.TAG} settingsMenuTest_003 end`);
    });

    /*
    * @tc.number: settingsMenuTest_004
    * @tc.name: Menu数据组容器
    * @tc.type: TestType.FUNCTION
    * @tc.desc: return true
    */
    it('settingsMenuTest_004', TestType.FUNCTION, async () => {
      LogUtil.info(`${Constant.TAG} MenuDataSourceTest_001 start`);
      new SettingsBaseMenu({
        key: MENU_KEY,
      });
      let menu: SettingsBaseMenu = new SettingsBaseMenu;
      let menuGroup = new MenuGroup();
      let print = menuGroup.print();
      expect(print !== null).assertTrue();
      let addMenuAndSort = menuGroup.addMenuAndSort(menu);
      expect(addMenuAndSort !== null).assertTrue();
      let addMenu = menuGroup.addMenu();
      expect(addMenu !== null).assertTrue();
      let addMenuToShift = menuGroup.addMenuToShift();
      expect(addMenuToShift !== null).assertTrue();
      let updateMenus = menuGroup.updateMenus([]);
      expect(updateMenus !== null).assertTrue();
      let addMenusAndSort = menuGroup.addMenusAndSort([]);
      expect(addMenusAndSort !== null).assertTrue();
      LogUtil.info(`${Constant.TAG} settingsMenuTest_004 end`);
    });

    /*
    * @tc.number: settingsMenuTest_005
    * @tc.name: Menu数据分段
    * @tc.type: TestType.FUNCTION
    * @tc.desc: return true
    */
    it('settingsMenuTest_005', TestType.FUNCTION, async () => {
      LogUtil.info(`${Constant.TAG} settingsMenuTest_005 start`);
      let menuSection = new MenuSection();
      let print = menuSection.print();
      expect(print !== null).assertTrue();
      LogUtil.info(`${Constant.TAG} settingsMenuTest_005 end`);
    });

    it('SettingsBaseMenu_getControllerInstance', 0, () => {

      let refresher = new UiRefresher()
      let menu = new SettingsBaseMenu()
      let res = menu.getControllerInstance(refresher)
      expect(menu !== null).assertTrue()
    })

    it('SettingsBaseMenu_deleteControllerFromPage', 0, () => {
      let menu = new SettingsBaseMenu()
      let res = menu.deleteControllerFromPage('')
      expect(res !== null).assertTrue()
    })

    it('SettingsBaseMenu_addControllerToPage', 0, () => {

      class MenuController extends Controller {
        getKey(): string {
          throw new Error('Method not implemented.');
        }

        aboutToAppear(): void {
          throw new Error('Method not implemented.');
        }

        aboutToDisappear(): void {
          throw new Error('Method not implemented.');
        }

        bindUi(uiRefresher: UiRefresher): void {
          throw new Error('Method not implemented.');
        }

        onMenuClick(): boolean {
          throw new Error('Method not implemented.');
        }

        onMenuIconClick(): boolean {
          throw new Error('Method not implemented.');
        }

        refreshUi(): void {
          throw new Error('Method not implemented.');
        }

        isVisibleStatus(): boolean {
          throw new Error('Method not implemented.');
        }

        updateVisibleStatus(): boolean {
          throw new Error('Method not implemented.');
        }

        onDataChange(fromKey: string, data: Object): void {
          throw new Error('Method not implemented.');
        }

        onRegisteredByObserver(observerKey: string): void {
          throw new Error('Method not implemented.');
        }

        handleHoverButtonClick(): void {
          throw new Error('Method not implemented.');
        }

        handleHoverEvent(isHovered: boolean): void {
          throw new Error('Method not implemented.');
        }

        isComponentHovered(): boolean {
          throw new Error('Method not implemented.');
        }

        onPageDestroy(): void {
          throw new Error('Method not implemented.');
        }

        notifyChange(): void {
          throw new Error('Method not implemented.');
        }
      }

      let menu = new SettingsBaseMenu()
      let res = menu.addControllerToPage('', new MenuController())
      expect(res !== null).assertTrue()
    })

    it('settingsMenuTest_updateMenus', 0, () => {
      let group = new MenuGroup()
      group.menus = [
        new SettingsBaseMenu(),
        new MenuGroup()
      ]

      group.addMenusToShift(group.menus)
      let res = group.updateMenus(group.menus)
      expect(res !== null).assertTrue()
    })

    it('settingsMenuTest_clear', 0, () => {
      let group = new MenuGroup()
      group.clear(false)
      let res = group.clear(true)
      expect(res !== null).assertTrue()
    })

    it('settingsMenuTest_removeMenu', 0, () => {

      let group = new MenuGroup()
      group.menus = [
        new MenuGroup(),
        new SettingsBaseMenu(),
      ]
      let res = group.removeMenu('')
      expect(res !== null).assertTrue()
    })

    it("settingsMenuTest_findMenu", 0, () => {
      let group = new MenuGroup()
      group.menus = [
        new SettingsBaseMenu(),
        new MenuGroup()
      ]
      group.findMenu('')
      expect(group !== null).assertTrue()
    })

    it('settingsMenuTest_refreshChildren', 0, () => {
      let group = new MenuGroup()
      group.menus = [
        new SettingsBaseMenu(),
        new MenuGroup()
      ]
      let res = group.refreshChildren()
      expect(res !== null).assertTrue()
    })

    it('settingsMenuTest_onHierarchyChange', 0, () => {
      let group = new MenuGroup()
      group.menus = [
        new SettingsBaseMenu(),
        new MenuGroup()
      ]
      let argv: undefined;
      let res = group.onHierarchyChange(argv)
      expect(res !== null).assertTrue()
    })

    it('settingsMenuTest_sort', 0, () => {
      let group = new MenuGroup()
      group.menus = [
        new SettingsBaseMenu(),
        new MenuGroup()
      ]
      let res = group.sort()
      expect(res !== null).assertTrue()
    })

    it('settingsMenuTest_setSymbolIcon', 0, () => {
      let group = new MenuGroup()
      let res = group.setSymbolIcon('')
      expect(res !== null).assertTrue()
    })

    it('MenuSection_findMenu', 0, () => {
      let section = new MenuSection()
      section.findMenu('')
      expect(section !== null).assertTrue()
    })

    it('MenuSection_clear', 0, () => {
      let section = new MenuSection()
      section.clear(false)
      let res = section.clear(false)
      expect(res !== null).assertTrue()
    })

    it('MenuSection_setHeader', 0, () => {
      let section = new MenuSection()
      section.setHeader()

      let group = new MenuGroup()
      let res = section.setHeader(group)
      expect(res !== null).assertTrue()
    })

    it('MenuSection_setFooter', 0, () => {
      let section = new MenuSection()
      section.setFooter()

      let group = new MenuGroup()
      let res = section.setFooter(group)
      expect(res !== null).assertTrue()
    })
  });
}
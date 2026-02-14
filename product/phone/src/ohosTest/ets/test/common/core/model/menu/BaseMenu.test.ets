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
import { describe, beforeAll, beforeEach, afterEach, afterAll, it, expect } from '@ohos/hypium'
import { SettingsBaseMenuData } from '@ohos/settings.common'
import {
  BaseBrowserRadioMenu,
  BaseButtonMenu,
  BaseButtonWithVariableTitleMenu,
  BaseCanvasMenu,
  BaseCardRadioMenu,
  BaseCardSection,
  BaseCheckboxMenu,
  BaseCheckboxOptionMenu,
  BaseDialogPage,
  BaseEmailRadioMenu,
  BaseEntryMenu,
  BaseHeaderPage,
  BaseIconRadioMenu,
  BaseImageMenu,
  BaseLoadingMenu,
  BaseLoadingSubHeaderSection,
  BaseNavigationEntryMenu,
  BaseNavigatorEntryMenu,
  BaseNavigatorEntryMenuData,
  BaseRadioMenu,
  BaseRingtoneImage,
  BaseSecondMenu,
  BaseSelectEntryMenu,
  BaseSliderMenu,
  BaseSliderMenuData,
  BaseStateMenu,
  BaseStateMenuData,
  BaseSubHeaderMenu,
  BaseSubHeaderSection,
  BaseSwitchMenu, BaseSwitchMenuData,
  BaseTextInputMenu,
  PasswordCircleBaseMenu,
  SwiperMenu,
  ThemeEditorMenu,
  UnderLineTextInputBaseMenu,
  WallpaperPreviewMenu,
  WindowBaseButtonMenu} from '@ohos/settings.common/src/main/ets/core/model/menu/BaseMenu'

export default function BaseMenuTest() {
  describe('BaseMenuTest', () => {
    // Defines a test suite. Two parameters are supported: test suite name and test suite function.
    beforeAll(() => {
      // Presets an action, which is performed only once before all test cases of the test suite start.
      // This API supports only one parameter: preset action function.
    })
    beforeEach(() => {
      // Presets an action, which is performed before each unit test case starts.
      // The number of execution times is the same as the number of test cases defined by **it**.
      // This API supports only one parameter: preset action function.
    })
    afterEach(() => {
      // Presets a clear action, which is performed after each unit test case ends.
      // The number of execution times is the same as the number of test cases defined by **it**.
      // This API supports only one parameter: clear action function.
    })
    afterAll(() => {
      // Presets a clear action, which is performed after all test cases of the test suite end.
      // This API supports only one parameter: clear action function.
    })
    it('assertEqual', 0, () => {
      // Defines a test case. This API supports three parameters: test case name, filter parameter, and test case function.
      let a = 'test'
      // Defines a variety of assertion methods, which are used to declare expected boolean conditions.
      expect(a).assertEqual('test')
    })

    it('BaseMenuTest_constructor', 0, () => {

      new BaseSwitchMenu()
      let data: BaseSwitchMenuData = {}
      let menu: Partial<BaseSwitchMenuData> = data

      menu.menuType = ''
      new BaseEntryMenu(menu)
      let res = new BaseSwitchMenu(menu)
      expect(res !== null).assertTrue()
    })

    it('BaseMenuTest_BaseNavigatorEntryMenuData', 0, () => {
      let data1: BaseNavigatorEntryMenuData = {}
      let menu1: Partial<BaseNavigatorEntryMenuData> = data1
      new BaseNavigatorEntryMenu(menu1)
      expect(menu1 !== null).assertTrue()
    })

    it('BaseMenuTest_BaseNavigationEntryMenuData', 0, () => {
      let data: BaseNavigatorEntryMenuData = {}
      let menu: Partial<BaseNavigationEntryMenu> = data
      new BaseNavigationEntryMenu(menu)
      expect(menu !== null).assertTrue()
    })

    it('BaseMenuTest_BaseStateMenu', 0, () => {
      let data: SettingsBaseMenuData = {}
      let menu: Partial<BaseStateMenuData> = data
      new BaseStateMenu(menu)
      expect(menu !== null).assertTrue()
    })

    it('BaseMenuTest_BaseSecondMenu', 0, () => {
      let data: BaseStateMenuData = {}
      let menu: Partial<BaseStateMenuData> = data
      new BaseSecondMenu(menu)
      expect(menu !== null).assertTrue()
    })

    it('BaseMenuTest_BaseSliderMenu', 0, () => {
      let data: BaseSliderMenuData = {}
      let menu: Partial<BaseSliderMenuData> = data
      new BaseSliderMenu(menu)
      expect(menu !== null).assertTrue()
    })

    it('BaseMenuTest_SwiperMenu', 0, () => {
      let data: SettingsBaseMenuData = {}
      let menu: Partial<SettingsBaseMenuData> = data
      new SwiperMenu(menu)
      expect(menu !== null).assertTrue()
    })

    it('BaseMenuTest_WallpaperPreviewMenu', 0, () => {
      let data: SettingsBaseMenuData = {}
      let menu: Partial<SettingsBaseMenuData> = data
      menu.menuType = ''
      new WallpaperPreviewMenu(menu)
      expect(menu !== null).assertTrue()
    })

    it('BaseMenuTest_ThemeEditorMenu', 0, () => {
      let data: SettingsBaseMenuData = {}
      let menu: Partial<SettingsBaseMenuData> = data
      menu.menuType = ''
      new ThemeEditorMenu(menu)
      expect(menu !== null).assertTrue()
    })

    it('BaseMenuTest_BaseImageMenu', 0, () => {
      let data: SettingsBaseMenuData = {}
      let menu: Partial<SettingsBaseMenuData> = data
      menu.menuType = ''
      new BaseImageMenu(menu)
      expect(menu !== null).assertTrue()
    })

    it('BaseMenuTest_BaseRingtoneImage', 0, () => {
      let data: SettingsBaseMenuData = {}
      let menu: Partial<SettingsBaseMenuData> = data
      menu.menuType = ''
      new BaseRingtoneImage(menu)
      expect(menu !== null).assertTrue()
    })

    it('BaseMenuTest_BaseCanvasMenu', 0, () => {
      let data: SettingsBaseMenuData = {}
      let menu: Partial<SettingsBaseMenuData> = data
      menu.menuType = ''
      new BaseCanvasMenu(menu)
      expect(menu !== null).assertTrue()
    })

    it('BaseMenuTest_BaseButtonMenu', 0, () => {
      let data: SettingsBaseMenuData = {}
      let menu: Partial<SettingsBaseMenuData> = data
      menu.menuType = ''
      new BaseButtonMenu(menu)
      expect(menu !== null).assertTrue()
    })

    it('BaseMenuTest_WindowBaseButtonMenu', 0, () => {
      let data: SettingsBaseMenuData = {}
      let menu: Partial<SettingsBaseMenuData> = data
      menu.menuType = ''
      new WindowBaseButtonMenu(menu)
      expect(menu !== null).assertTrue()
    })

    it('BaseMenuTest_BaseTextInputMenu', 0, () => {
      let data: SettingsBaseMenuData = {}
      let menu: Partial<SettingsBaseMenuData> = data
      menu.menuType = ''
      new BaseTextInputMenu(menu)
      expect(menu !== null).assertTrue()
    })

    it('BaseMenuTest_BaseSubHeaderMenu', 0, () => {
      let data: SettingsBaseMenuData = {}
      let menu: Partial<SettingsBaseMenuData> = data
      menu.menuType = ''
      new BaseSubHeaderMenu(menu)
      expect(menu !== null).assertTrue()
    })

    it('BaseMenuTest_BaseLoadingMenu', 0, () => {
      let data: SettingsBaseMenuData = {}
      let menu: Partial<SettingsBaseMenuData> = data
      menu.menuType = ''
      new BaseLoadingMenu(menu)
      expect(menu !== null).assertTrue()
    })

    it('BaseMenuTest_BaseCardSection', 0, () => {
      let data: SettingsBaseMenuData = {}
      let menu: Partial<SettingsBaseMenuData> = data
      menu.menuType = ''
      new BaseCardSection(menu)
      expect(menu !== null).assertTrue()
    })

    it('BaseMenuTest_BaseSubHeaderSection', 0, () => {
      let data: SettingsBaseMenuData = {}
      let menu: Partial<SettingsBaseMenuData> = data
      menu.menuType = ''
      new BaseSubHeaderSection(menu)
      expect(menu !== null).assertTrue()
    })

    it('BaseMenuTest_BaseLoadingSubHeaderSection', 0, () => {
      let data: SettingsBaseMenuData = {}
      let menu: Partial<SettingsBaseMenuData> = data
      menu.menuType = ''
      new BaseLoadingSubHeaderSection(menu)
      expect(menu !== null).assertTrue()
    })

    it('BaseMenuTest_BaseHeaderPage', 0, () => {
      let data: SettingsBaseMenuData = {}
      let menu: Partial<SettingsBaseMenuData> = data
      menu.menuType = ''
      new BaseHeaderPage(menu)
      expect(menu !== null).assertTrue()
    })

    it('BaseMenuTest_BaseDialogPage', 0, () => {
      let data: SettingsBaseMenuData = {}
      let menu: Partial<SettingsBaseMenuData> = data
      menu.menuType = ''
      new BaseDialogPage(menu)
      expect(menu !== null).assertTrue()
    })

    it('BaseMenuTest_BaseRadioMenu', 0, () => {
      let data: SettingsBaseMenuData = {}
      let menu: Partial<SettingsBaseMenuData> = data
      menu.menuType = ''
      new BaseRadioMenu(menu)
      expect(menu !== null).assertTrue()
    })

    it('BaseMenuTest_BaseCardRadioMenu', 0, () => {
      let data: SettingsBaseMenuData = {}
      let menu: Partial<SettingsBaseMenuData> = data
      menu.menuType = ''
      new BaseCardRadioMenu(menu)
      expect(menu !== null).assertTrue()
    })

    it('BaseMenuTest_BaseEmailRadioMenu', 0, () => {
      let data: SettingsBaseMenuData = {}
      let menu: Partial<SettingsBaseMenuData> = data
      menu.menuType = ''
      new BaseEmailRadioMenu(menu)
      expect(menu !== null).assertTrue()
    })

    it('BaseMenuTest_BaseIconRadioMenu', 0, () => {
      let data: SettingsBaseMenuData = {}
      let menu: Partial<SettingsBaseMenuData> = data
      menu.menuType = ''
      new BaseIconRadioMenu(menu)
      expect(menu !== null).assertTrue()
    })

    it('BaseMenuTest_BaseBrowserRadioMenu', 0, () => {
      let data: SettingsBaseMenuData = {}
      let menu: Partial<SettingsBaseMenuData> = data
      menu.menuType = ''
      new BaseBrowserRadioMenu(menu)
      expect(menu !== null).assertTrue()
    })

    it('BaseMenuTest_PasswordCircleBaseMenu', 0, () => {
      let data: SettingsBaseMenuData = {}
      let menu: Partial<SettingsBaseMenuData> = data
      menu.menuType = ''
      new PasswordCircleBaseMenu(menu)
      expect(menu !== null).assertTrue()
    })

    it('BaseMenuTest_UnderLineTextInputBaseMenu', 0, () => {
      let data: SettingsBaseMenuData = {}
      let menu: Partial<SettingsBaseMenuData> = data
      menu.menuType = ''
      new UnderLineTextInputBaseMenu(menu)
      expect(menu !== null).assertTrue()
    })

    it('BaseMenuTest_UnderLineTextInputBaseMenu_001', 0, () => {
      let data: SettingsBaseMenuData = {}
      let menu: Partial<SettingsBaseMenuData> = data
      menu.menuType = ''
      new UnderLineTextInputBaseMenu(menu)
      expect(menu !== null).assertTrue()
    })

    it('BaseMenuTest_BaseSelectEntryMenu', 0, () => {
      let data: SettingsBaseMenuData = {}
      let menu: Partial<SettingsBaseMenuData> = data
      menu.menuType = ''
      new BaseSelectEntryMenu(menu)
      expect(menu !== null).assertTrue()
    })

    it('BaseMenuTest_BaseCheckboxMenu', 0, () => {
      let data: SettingsBaseMenuData = {}
      let menu: Partial<SettingsBaseMenuData> = data
      menu.menuType = ''
      new BaseCheckboxMenu(menu)
      expect(menu !== null).assertTrue()
    })

    it('BaseMenuTest_BaseCheckboxOptionMenu', 0, () => {
      let data: SettingsBaseMenuData = {}
      let menu: Partial<SettingsBaseMenuData> = data
      menu.menuType = ''
      new BaseCheckboxOptionMenu(menu)
      expect(menu !== null).assertTrue()
    })

    it('BaseMenuTest_BaseButtonWithVariableTitleMenu', 0, () => {
      let data: SettingsBaseMenuData = {}
      let menu: Partial<SettingsBaseMenuData> = data
      menu.menuType = ''
      new BaseButtonWithVariableTitleMenu(menu)
      expect(menu !== null).assertTrue()
    })
  })
}
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
import { describe, beforeAll, beforeEach, afterEach, afterAll, it, expect, MockKit, when,
  ArgumentMatchers } from '@ohos/hypium'
import { DeviceUtil, EnableUtils, MenuPage, PreferencesUtil, SettingsBaseMenu } from '@ohos/settings.common'

export default function EnableUtilsTest() {
  describe('EnableUtilsTest', () => {
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
    it('test_disableItemName', 0, () => {
      expect(EnableUtils.disableItemName()).assertTrue()
      let mocker: MockKit = new MockKit()
      let hasSyncFunc: Function = mocker.mockFunc(PreferencesUtil, PreferencesUtil.hasSync)
      let getSyncFunc: Function = mocker.mockFunc(PreferencesUtil, PreferencesUtil.getSync)
      when(hasSyncFunc)(ArgumentMatchers.any).afterReturn(false)
      expect(EnableUtils.disableItemName('abc')).assertTrue()
      when(hasSyncFunc)(ArgumentMatchers.any).afterReturn(true)
      when(getSyncFunc)(ArgumentMatchers.any).afterReturn(false)
      expect(EnableUtils.disableItemName('abc')).assertFalse()
      when(getSyncFunc)(ArgumentMatchers.any).afterReturn(true)
      expect(EnableUtils.disableItemName('abc')).assertTrue()
      mocker.clear(PreferencesUtil)
    })
    it('test_setItemEnable', 0, async (done : Function) => {
      let res = true
      try {
        await EnableUtils.setItemEnable()
        let mocker: MockKit = new MockKit()
        let getSyncFunc: Function = mocker.mockFunc(PreferencesUtil, PreferencesUtil.getSync)
        when(getSyncFunc)(ArgumentMatchers.any).afterReturn(['a','b','c'])
        await EnableUtils.setItemEnable()
        let menuPage = new MenuPage()
        let findMenuFunc = mocker.mockFunc(menuPage, menuPage.findMenu)
        when(findMenuFunc)(ArgumentMatchers.any).afterReturn(null)
        await EnableUtils.setItemEnable(menuPage)
        let baseMenu = new SettingsBaseMenu()
        when(findMenuFunc)(ArgumentMatchers.any).afterReturn(baseMenu)
        await EnableUtils.setItemEnable(menuPage)
        mocker.clear(PreferencesUtil)
        mocker.clear(menuPage)
      } catch(e) {
        res = false
      } finally {
        expect(res).assertTrue()
        done()
      }
    })
    it('test_getHomePageDisableItems', 0, () => {
      let mocker: MockKit = new MockKit()
      let isDevicePcFunc: Function = mocker.mockFunc(DeviceUtil, DeviceUtil.isDevicePc)
      when(isDevicePcFunc)(ArgumentMatchers.any).afterReturn(true)
      let getSyncFunc: Function = mocker.mockFunc(PreferencesUtil, PreferencesUtil.getSync)
      when(getSyncFunc)(ArgumentMatchers.any).afterReturn(new Set([]))
      expect(EnableUtils.getHomePageDisableItems().size).assertInstanceOf('Number');
      when(getSyncFunc)(ArgumentMatchers.any).afterReturn(['a', 'b'])
      expect(EnableUtils.getHomePageDisableItems().size).assertInstanceOf('Number');
      when(getSyncFunc)(ArgumentMatchers.any).afterReturn(['more_connections_settings', 'theme_settings'])
      expect(EnableUtils.getHomePageDisableItems().size).assertInstanceOf('Number');
      when(isDevicePcFunc)(ArgumentMatchers.any).afterReturn(false)
      when(getSyncFunc)(ArgumentMatchers.any).afterReturn(['bluetooth_entry', 'mobile_network_entry'])
      expect(EnableUtils.getHomePageDisableItems().size).assertInstanceOf('Number');
      mocker.clear(DeviceUtil)
      mocker.clear(PreferencesUtil)
    })
  })
}
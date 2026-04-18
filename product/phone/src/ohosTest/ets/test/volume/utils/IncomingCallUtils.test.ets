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
import {
  describe,
  beforeAll,
  beforeEach,
  afterEach,
  afterAll,
  it,
  expect,
  MockKit,
  when,
  ArgumentMatchers
} from '@ohos/hypium'
import { GlobalContext } from '@ohos/settings.common/src/main/ets/utils/GlobalContext'
import { ContactPolicy } from '../../../../../main/ets/Setting/Volume/model/IncomingCallParam'
import { IncomingCallUtils } from '../../../../../main/ets/Setting/Volume/utils/IncomingCallUtils'

export default function IncomingCallUtilsTest() {
  describe('IncomingCallUtilsTest', () => {
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

    it('IncomingCallUtilsTest_getInstance', 0, () => {
      let mocker = new MockKit();
      let func: Function =
        mocker.mockFunc(IncomingCallUtils.getInstance(), IncomingCallUtils.getInstance().findAllSelectContacts)
        when(func)(ArgumentMatchers.any).afterReturn

      let res = IncomingCallUtils.getInstance()
      expect(res !== null).assertTrue()
      mocker.clear(IncomingCallUtils.getInstance())
    })

    it('IncomingCallUtilsTest_getSelectContactList', 0, async () => {

      let mocker = new MockKit()
      let func1: Function =
        mocker.mockFunc(IncomingCallUtils.getInstance(), IncomingCallUtils.getInstance().getSelectContactList)
      when(func1)(ArgumentMatchers.any)
      expect(func1() !== null).assertTrue()
      mocker.clear(IncomingCallUtils.getInstance())
    })

    it('IncomingCallUtilsTest_findAllSelectContacts', 0, () => {

      let mocker = new MockKit()
      let func1: Function =
        mocker.mockFunc(IncomingCallUtils.getInstance(), IncomingCallUtils.getInstance().findAllSelectContacts)
      when(func1)(ArgumentMatchers.any)
      expect(func1() !== null).assertTrue()
      mocker.clear(IncomingCallUtils.getInstance())
    })

    it('IncomingCallUtilsTest_setMenuTitle', 0, () => {

      IncomingCallUtils.getInstance().setMenuTitle(ContactPolicy.ALLOW_EVERYONE)
      IncomingCallUtils.getInstance().setMenuTitle(ContactPolicy.ALLOW_EXISTING_CONTACTS)
      IncomingCallUtils.getInstance().setMenuTitle(ContactPolicy.ALLOW_FAVORITE_CONTACTS)
      IncomingCallUtils.getInstance().setMenuTitle(ContactPolicy.ALLOW_SPECIFIED_CONTACTS)
      let res = IncomingCallUtils.getInstance().setMenuTitle(ContactPolicy.FORBID_EVERYONE)
      expect(res !== null).assertTrue()
    })

    it('IncomingCallUtilsTest_isSupportAiVoice', 0, () => {
      let res = IncomingCallUtils.isSupportAiVoice();
      expect(res !== null).assertTrue()
    })

    it('IncomingCallUtilsTest_isSupportStereoEnhancement', 0, () => {
      let res = IncomingCallUtils.isSupportStereoEnhancement();
      expect(res !== null).assertTrue()
    })

    it('IncomingCallUtilsTest_isShowRepeatCall', 0, () => {
      let res = IncomingCallUtils.getInstance().isShowRepeatCall();
      expect(res !== null).assertTrue()
    })
  })
}
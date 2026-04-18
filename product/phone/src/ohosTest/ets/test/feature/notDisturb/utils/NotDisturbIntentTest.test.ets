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

import { ArgumentMatchers, describe, expect, it, MockKit, when } from '@ohos/hypium';
import { SettingsDataUtils } from '@ohos/settings.common';
import { NotDisturbIntent } from '@ohos/settings.notDisturb/src/main/ets/utils/NotDisturbIntent';

export default function NotDisturbIntentTest() {
  describe('NotDisturbIntentTest', () => {

    it('test_getDisturb', 0, (): void => {
      let mocker: MockKit = new MockKit();
      let mockfunc: Function = mocker.mockFunc(SettingsDataUtils, SettingsDataUtils.getSettingsData);
      when(mockfunc)(ArgumentMatchers.any).afterReturn('1');
      let resA = NotDisturbIntent.getDisturb();
      expect(typeof resA === 'string').assertTrue();
      when(mockfunc)(ArgumentMatchers.any).afterReturn('2');
      let resB = NotDisturbIntent.getDisturb();
      expect(typeof resB === 'string').assertTrue();
      when(mockfunc)(ArgumentMatchers.any).afterReturn('3');
      let resC = NotDisturbIntent.getDisturb();
      expect(typeof resC === 'string').assertTrue();
      when(mockfunc)(ArgumentMatchers.any).afterReturn('4');
      let resD = NotDisturbIntent.getDisturb();
      expect(typeof resD === 'string').assertTrue();
      when(mockfunc)(ArgumentMatchers.any).afterReturn('5');
      let resE = NotDisturbIntent.getDisturb();
      expect(typeof resE === 'string').assertTrue();
      when(mockfunc)(ArgumentMatchers.any).afterReturn('6');
      let resF = NotDisturbIntent.getDisturb();
      expect(typeof resF === 'string').assertTrue();
      mocker.clear(SettingsDataUtils);
    })

    it('test_setDisturb', 0, (): void => {
      let resA = NotDisturbIntent.setDisturb('forbid_everyone');
      expect(resA === null).assertFalse();
      let resB = NotDisturbIntent.setDisturb('allow_everyone');
      expect(resB === null).assertFalse();
      let resC = NotDisturbIntent.setDisturb('allow_only_existing_contacts');
      expect(resC === null).assertFalse();
      let resD = NotDisturbIntent.setDisturb('allow_only_favorite_contacts');
      expect(resD === null).assertFalse();
      let resE = NotDisturbIntent.setDisturb('allow_only_specified_contacts');
      expect(resE === null).assertFalse();
      let resF = NotDisturbIntent.setDisturb('a');
      expect(resF === null).assertFalse();
    })

    it('test_getDisturbTitle', 0, (): void => {
      let mocker: MockKit = new MockKit();
      let mockfunc: Function = mocker.mockFunc(SettingsDataUtils, SettingsDataUtils.getSettingsData);
      when(mockfunc)(ArgumentMatchers.any).afterReturn('2');
      let resA = NotDisturbIntent.getDisturbTitle();
      expect(typeof resA === 'string').assertTrue();
      when(mockfunc)(ArgumentMatchers.any).afterReturn('3');
      let resB = NotDisturbIntent.getDisturbTitle();
      expect(typeof resB === 'string').assertTrue();
      when(mockfunc)(ArgumentMatchers.any).afterReturn('4');
      let resC = NotDisturbIntent.getDisturbTitle();
      expect(typeof resC === 'string').assertTrue();
      when(mockfunc)(ArgumentMatchers.any).afterReturn('5');
      let resD = NotDisturbIntent.getDisturbTitle();
      expect(typeof resD === 'string').assertTrue();
      when(mockfunc)(ArgumentMatchers.any).afterReturn('6');
      let resE = NotDisturbIntent.getDisturbTitle();
      expect(typeof resE === 'string').assertTrue();
      mocker.clear(SettingsDataUtils);
    })

  })
}
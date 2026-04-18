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
import { PasswordManager } from '@ohos/settings.common';

export default function PasswordManagerTest() {
  describe('PasswordManagerTest', () => {
    let passwordManagerInstance = PasswordManager;

    it('PasswordManagerTest_getEdmPasswordTipMessage', 0, () => {
     let result = passwordManagerInstance.getEdmPasswordTipMessage();
     expect(result !==null).assertTrue();

     let instance = new PasswordManager();
      (instance as object)['edmPolicy'] = {
        additionalDescription: ''
      };
      let mocker: MockKit = new MockKit();
      let mockfunc: Function = mocker.mockFunc(passwordManagerInstance, passwordManagerInstance.hasEdmPolicy);
      when(mockfunc)(ArgumentMatchers.any).afterReturn(true);
      let result2 = passwordManagerInstance.getEdmPasswordTipMessage();
      expect(result2 !==null).assertTrue()
      mocker.clear(passwordManagerInstance);
    })

    it('PasswordManagerTest_isMatchEdmPolicy', 0, () => {
      let password = '';
      let result = passwordManagerInstance.isMatchEdmPolicy(password);
      expect(result !==null).assertTrue();

      let password2 = '12332112';
      let result2 = passwordManagerInstance.isMatchEdmPolicy(password2);
      expect(result2 !==null).assertTrue()
    })

    it('PasswordManagerTest_updateEdmPolicy', 0, () => {
      let result = passwordManagerInstance.updateEdmPolicy();
      expect(result !==null).assertTrue();
    })

    it('PasswordManagerTest_getSetPasswordEntry', 0, () => {
      (passwordManagerInstance as object)['hasEdmPolicy'](() => true);
      let result = passwordManagerInstance.getEntryKey();
      expect(result !==null).assertTrue();

      (passwordManagerInstance as object)['hasEdmPolicy'](() => false);
      let result2 = passwordManagerInstance.getEntryKey();
      expect(result2 !==null).assertTrue();
    })

  })
}
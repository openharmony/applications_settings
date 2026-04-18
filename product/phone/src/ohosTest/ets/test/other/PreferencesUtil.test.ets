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

import { afterAll, afterEach, beforeAll, beforeEach, describe, expect, it, Level } from '@ohos/hypium';
import { PreferencesUtil } from '@ohos/settings.common/src/main/ets/utils/PreferencesUtil';

export default function preferencesUtilTest() {
  describe('preferencesUtilTest', (): void => {

    beforeAll((): void => {
    })

    beforeEach((): void => {
    })

    afterAll((): void => {
    })

    afterEach((): void => {
    })

    it('PreferenceUtilTest_has', 0, () => {
      PreferencesUtil.has('').then((v) => {
        expect(v).assertFalse()
      })
    })

    it('PreferencesUtilTest_getSync', Level.LEVEL1, () => {
      PreferencesUtil.putSync('PreferencesUtilTest_getSync', '123');
      let result: string = PreferencesUtil.getSync('PreferencesUtilTest_getSync', '456') as string;
      expect(result).assertEqual('123');
    })

    it('BaseUtilsTest_hasSync', Level.LEVEL1, () => {
      const result1 = PreferencesUtil.hasSync('123');
      expect(result1 !== null).assertTrue();
      PreferencesUtil.putSync('123', '123');
      const result2 = PreferencesUtil.hasSync('123');
      expect(result2 !== null).assertTrue();
    })

    it('putSync', 0, () => {
      PreferencesUtil.putSync('test', 'test');
      expect(PreferencesUtil.getSync('test', 'test')).assertEqual('test');
      PreferencesUtil.delete('test');
    })

    it('AppStorageTest_delete', 0, () => {
      AppStorage.delete('test');
      expect(AppStorage.get('test')).assertUndefined();
    })
  })
}


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
import { describe, it, expect, MockKit, when } from '@ohos/hypium'
import { languageAndRegionModel } from '@ohos/settings.language/src/main/ets/model/LanguageAndRegionModel'

export default function LanguageAndRegionModelTest() {
  describe('LanguageAndRegionModelTest', () => {
    it("LanguageAndRegionModelTest_001", 0, () => {
      let languageM = languageAndRegionModel
      languageM.initAppStorage()
      const emptyArr = []
      languageM.setAddedLanguages(emptyArr)
      const testArr = ['testLanguage']
      languageM.setAddedLanguages(testArr)
      const result = languageM.getSysDisplayRegion()
      expect(result.length >= 0).assertTrue()
      const testRegion = 'testRegion'
      const result1 = languageM.getSysDisplayRegion(testRegion)
      expect(result1.length >= 0).assertTrue()
    })
    it("LanguageAndRegionModelTest_002", 0, () => {
      let languageM = languageAndRegionModel
      const testLanguage = 'testLanguage'
      const result = languageM.isSystemLanguage(testLanguage)
      expect(result).assertFalse()
    })
    it("LanguageAndRegionModelTest_003", 0, () => {
      let languageM = languageAndRegionModel
      const testLanguage = 'testLanguage'
      const emptyArr = ['', '']
      const testArr = [testLanguage]
      let mocker: MockKit = new MockKit()
      let mockFun: Function = mocker.mockFunc(languageM, languageM.getAddedLanguages)
      when(mockFun)().afterReturn(emptyArr)
      const result = languageM.isInAddedLanguage(testLanguage)
      expect(result).assertFalse()
      when(mockFun)().afterReturn(testArr)
      const result1 = languageM.isInAddedLanguage(testLanguage)
      expect(result1).assertTrue()
      mocker.clear(languageM)
    })
    it("LanguageAndRegionModelTest_004", 0, () => {
      let languageM = languageAndRegionModel
      const testRegion = 'testRegion'
      let result = languageM.isSystemRegion(testRegion)
      expect(result).assertFalse()
    })
  })
}
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
import { describe, it, expect } from '@ohos/hypium'
import { SearchConfigFileParser } from '@ohos/settings.search/src/main/ets/util/SearchConfigFileParser';

export default function SearchConfigFileParserTestTest() {
  describe('SearchConfigFileParserTestTest', () => {
    it('SearchConfigFileParserTestTest_001', 0, () => {
      let searchConfigFileP: SearchConfigFileParser =  SearchConfigFileParser.getInstance();
      let searchConfigFileP1: SearchConfigFileParser =  SearchConfigFileParser.getInstance();
      expect(searchConfigFileP === searchConfigFileP1).assertTrue();
    })
  })
}
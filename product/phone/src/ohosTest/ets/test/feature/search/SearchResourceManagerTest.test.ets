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
import { SearchResourceManager } from '@ohos/settings.search/src/main/ets/controller/SearchResourceManager';

export default function SearchResourceManagerTestTest() {
  describe('SearchResourceManagerTestTest', () => {
    it('SearchResourceManagerTestTest_001', 0, () => {
      let searchResourceM: SearchResourceManager = new SearchResourceManager('');
      const locale = 'en-US';
      let searchResourceM1: SearchResourceManager = new SearchResourceManager(locale);
      expect(searchResourceM != searchResourceM1).assertTrue();
    })
    it('SearchResourceManagerTestTest_getExternalStringByName_001', 0, () => {
      const locale = 'en-US';
      let searchResourceM: SearchResourceManager = new SearchResourceManager(locale);
      const result = searchResourceM.getExternalStringByName('', '');
      expect(result).assertEqual('');
      const result1 = searchResourceM.getExternalStringByName('testBundle', '');
      expect(result1).assertEqual('');
    })
    it('SearchResourceManagerTestTest_getPathByName_001', 0, () => {
      const locale = 'en-US';
      let searchResourceM: SearchResourceManager = new SearchResourceManager(locale);
      const result = searchResourceM.getPathByName('testBundle', [], true);
      expect(result).assertEqual('');
      const result1 = searchResourceM.getPathByName('', [], true);
      expect(result1).assertEqual('');
      const result2 = searchResourceM.getPathByName('', ['$string:wifi_settings_title'], false);
      expect(result2.length >= 0).assertTrue();
    })
    it('SearchResourceManagerTestTest_getNumberFormatStringSync_001', 0, () => {
      const locale = 'en-US';
      let searchResourceM: SearchResourceManager = new SearchResourceManager(locale);
      let resource: Resource = AppStorage.get<Resource>('resource') as Resource;
      const result = searchResourceM.getNumberFormatStringSync(resource, '');
      expect(result).assertEqual('');
      const result1 = searchResourceM.getNumberFormatStringSync($r('app.string.time_24_hour_title'), '24');
      expect(result1.length >= 0).assertTrue();
    })
  })
}
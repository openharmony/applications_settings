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
  afterAll,
  beforeAll,
  describe,
  expect,
  it
} from '@ohos/hypium';
import i18n from '@ohos.i18n';
import { CheckEmptyUtils } from '@ohos/settings.common/src/main/ets/utils/CheckEmptyUtils';
import { TestUtil } from '../TestUtil';
import { SearchResourceManager } from '../../../../main/ets/controller/SearchResourceManager';

const TAG: string = 'SearchResourceManager: ';

export default function SearchResourceManagerTest() {
  describe('SearchResourceManager', () => {
    beforeAll(async () => {
      TestUtil.startSettingsAbility(TAG);
    });

    afterAll(async () => {
      TestUtil.clearSettings();
    });

    /*
    * @tc.number: getSearchResource
    * @tc.name: 查询搜索项资源.
    * @tc.type: 0 || TestType.FUNCTION  || Level.LEVEL0
    * @tc.desc: 搜索资源获取，依赖搜索语言.
    */
    it('getSearchResource', 0, async () => {
      let resourceManager: SearchResourceManager = new SearchResourceManager(i18n.System.getSystemLocale());
      let result = resourceManager.getStringByName('wifi_settings_title');
      expect(CheckEmptyUtils.checkStrIsEmpty(result)).assertFalse();

      result = resourceManager.getNumberFormatStringSync($r('app.string.time_24_hour_title'), '24');
      expect(CheckEmptyUtils.checkStrIsEmpty(result)).assertFalse();

      result = resourceManager.getPathByName('', [], false);
      expect(CheckEmptyUtils.checkStrIsEmpty(result)).assertTrue();

      result = resourceManager.getPathByName('', ['$string:wifi_settings_title'], false);
      expect(CheckEmptyUtils.checkStrIsEmpty(result)).assertFalse();

      result = resourceManager.getExternalStringByName('', '');
      expect(CheckEmptyUtils.checkStrIsEmpty(result)).assertTrue();
    })
  })
}
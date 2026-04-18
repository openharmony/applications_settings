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
import { SearchItem } from '../../../../main/ets/model/SearchPageConfig';
import { CheckItemUtil } from '../../../../main/ets/util/CheckItemUtil';
import { TestUtil } from '../TestUtil';

const TAG: string = 'CheckItemUtilTest: ';

export default function CheckItemUtilTest() {
  describe('CheckItemUtilTest', () => {
    beforeAll(async () => {
      TestUtil.startSettingsAbility(TAG);
    });

    afterAll(async () => {
      TestUtil.clearSettings();
    });

    /*
    * @tc.number: checkItemUtil
    * @tc.name: 检查搜索项是否支持.
    * @tc.type: 0 || TestType.FUNCTION  || Level.LEVEL0
    * @tc.desc: 检查搜索项是否支持.
    */
    it('checkItemUtil', 0, async () => {
      let searchItem: SearchItem = new SearchItem();
      searchItem.enable = 'true';
      expect(await CheckItemUtil.checkItemEnable(searchItem)).assertTrue();
    })
  })
}
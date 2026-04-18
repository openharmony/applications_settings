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
import { SearchConfigFileParser } from '../../../../main/ets/util/SearchConfigFileParser';
import { TestUtil } from '../TestUtil';

const TAG: string = 'SearchConfigFileParserTest: ';

export default function SearchConfigFileParserTest() {
  describe('SearchConfigFileParserTest', () => {
    beforeAll(async () => {
      TestUtil.startSettingsAbility(TAG);
    });

    afterAll(async () => {
      TestUtil.clearSettings();
    });

    /*
    * @tc.number: parserSearchPageConfig
    * @tc.name: 解析搜索页面配置文件.
    * @tc.type: 0 || TestType.FUNCTION  || Level.LEVEL0
    * @tc.desc: 解析搜索页面配置文件.
    */
    it('parserSearchPageConfig', 0, async () => {
      let pageConfig = await SearchConfigFileParser.getInstance().parserSearchPageConfig('');
      expect(pageConfig === undefined).assertTrue();
    })

    /*
    * @tc.number: parserPageInfoConfig
    * @tc.name: 解析搜索页面关系配置文件.
    * @tc.type: 0 || TestType.FUNCTION  || Level.LEVEL0
    * @tc.desc: 解析搜索页面关系配置文件.
    */
    it('parserPageInfoConfig', 0, async () => {
      let pageConfig = await SearchConfigFileParser.getInstance().parserPageInfoConfig('');
      expect(pageConfig === undefined).assertTrue();
      pageConfig = await SearchConfigFileParser.getInstance().parserPageInfoConfig('searchConfig/pageInfo.json');
      expect(pageConfig !== undefined).assertTrue();
    })

    /*
    * @tc.number: parserExternalInfoConfig
    * @tc.name: 解析外部接入应用配置文件.
    * @tc.type: 0 || TestType.FUNCTION  || Level.LEVEL0
    * @tc.desc: 解析外部接入应用配置文件.
    */
    it('parserExternalInfoConfig', 0, async () => {
      let pageConfig = await SearchConfigFileParser.getInstance().parserExternalInfoConfig('');
      expect(pageConfig === undefined).assertTrue();
      pageConfig = await SearchConfigFileParser.getInstance().parserExternalInfoConfig('searchConfig/externalInfo.json');
      expect(pageConfig !== undefined).assertTrue();
    })

    /*
    * @tc.number: parseExternalSearchPageConfig
    * @tc.name: 解析外部接入设置搜索配置文件.
    * @tc.type: 0 || TestType.FUNCTION  || Level.LEVEL0
    * @tc.desc: 解析外部接入设置搜索配置文件.
    */
    it('parseExternalSearchPageConfig', 0, async () => {
      let pageConfig = await SearchConfigFileParser.getInstance().parseExternalSearchPageConfig('', '');
      expect(pageConfig === undefined).assertTrue();
      pageConfig = await SearchConfigFileParser.getInstance().parseExternalSearchPageConfig('com.ohos.sceneboard', '');
      expect(pageConfig === undefined).assertTrue();
      pageConfig = await SearchConfigFileParser.getInstance().parseExternalSearchPageConfig('com.ohos.sceneboard',
        'searchConfig/searchPage.json');
      expect(pageConfig !== undefined).assertTrue();
    })
  })
}
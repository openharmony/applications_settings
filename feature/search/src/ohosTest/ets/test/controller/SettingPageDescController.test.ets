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
import { Constants } from '@ohos/settings.common/src/main/ets/constant/PackagesConstant';
import { PreferencesUtil } from '@ohos/settings.common/src/main/ets/utils/PreferencesUtil';
import { SettingPageDescController } from '../../../../../Index';
import { TestUtil } from '../TestUtil';

const TAG: string = 'SettingPageDescControllerTest: ';

export default function SettingPageDescControllerTest() {
  describe('SettingPageDescControllerTest', () => {
    beforeAll(async () => {
      TestUtil.startSettingsAbility(TAG);
    });

    afterAll(async () => {
      TestUtil.clearSettings();
    });

    /*
    * @tc.number: initPageData
    * @tc.name: 初始化搜索页面关系记录数据到数据库.
    * @tc.type: 0 || TestType.FUNCTION  || Level.LEVEL0
    * @tc.desc: 初始化搜索页面关系记录数据到数据库.
    */
    it('initPageData', 0, async () => {
      SettingPageDescController.initPageInfoTable();
      await PreferencesUtil.delete(`PageInfoDesc${Constants.PAGEINFO_TABLE_VERSION}`);
      await SettingPageDescController.initPageInfoData();
      expect(PreferencesUtil.hasSync(`PageInfoDesc${Constants.ITEMINFO_TABLE_VERSION}`)).assertTrue();
      await PreferencesUtil.delete(`PageInfoDesc${Constants.PAGEINFO_TABLE_VERSION}`);

      await PreferencesUtil.delete(`ClearPageInfoTable${Constants.PAGEINFO_TABLE_VERSION}`);
      await SettingPageDescController.deletePageInfoData();
      expect(PreferencesUtil.hasSync(`ClearPageInfoTable${Constants.ITEMINFO_TABLE_VERSION}`)).assertTrue();
      await SettingPageDescController.deletePageInfoData();
    })

    /*
    * @tc.number: isPageExistInConfig
    * @tc.name: 检查页面是否存在.
    * @tc.type: 0 || TestType.FUNCTION  || Level.LEVEL0
    * @tc.desc: 检查页面是否存在.
    */
    it('isPageExistInConfig', 0, async () => {
      let isPageExist = await SettingPageDescController.isPageExistInConfig('');
      expect(isPageExist).assertFalse();
      isPageExist = await SettingPageDescController.isPageExistInConfig('wifi_entry');
      expect(isPageExist).assertTrue();
    })

    /*
    * @tc.number: getParentPage
    * @tc.name: 根据entryKey获取父页面.
    * @tc.type: 0 || TestType.FUNCTION  || Level.LEVEL0
    * @tc.desc: 根据entryKey获取父页面.
    */
    it('getParentPage', 0, async () => {
      let entryKeyList: string[] = [];
      await SettingPageDescController.getParentPage('', entryKeyList);
      expect(entryKeyList.length).assertEqual(0);
      await SettingPageDescController.getParentPage('wifi_entry', entryKeyList);
      expect(entryKeyList.length).assertEqual(1);
      entryKeyList.pop();
      await SettingPageDescController.getParentPage('add_other_wifi_entry', entryKeyList);
      expect(entryKeyList.length).assertEqual(2);
    })
  })
}
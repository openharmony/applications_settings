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

import { LogUtil, PreferencesUtil } from '@ohos/settings.common';
import { SearchDataController, SettingPageDescController, SearchHistoryController } from '@ohos/settings.search';
import { afterAll, beforeAll, describe, it, MockKit, when } from '@ohos/hypium';
import i18n from '@ohos.i18n';
import { Driver } from '@ohos.UiTest';
import { BusinessError } from '@ohos.base';
import abilityDelegatorRegistry from '@ohos.app.ability.abilityDelegatorRegistry';
import { Constant } from '../constant/Constant';
import { COMMON_DELAY } from '../types';

const TAG: string = 'SearchDataTest: ';
const DELEGATOR: abilityDelegatorRegistry.AbilityDelegator = abilityDelegatorRegistry.getAbilityDelegator();

export default function searchSettingsDataTest() {
  describe('searchSettingsDataTest', () => {
    let dr: Driver | null = null;
    beforeAll(async () => {
      try {
        await DELEGATOR.startAbility({
          'bundleName': Constant.SETTINGS_BUNDLE_NAME,
          'abilityName': Constant.SETTINGS_MAIN_ABILITY_NAME,
        }).then(() => {
          LogUtil.info(`${Constant.TAG} com.ohos.settings.MainAbility start success!`);
        });
      } catch (exception) {
        LogUtil.info(`Failed to startAbility. Code: ${(exception as BusinessError).code}, message: ${(exception as BusinessError).message}`);
      }
    });

    afterAll(async () => {
      dr = await Driver.create();
      await dr.delayMs(COMMON_DELAY);
      await dr.pressHome();
      await dr.delayMs(COMMON_DELAY);
    });
    /*
    * @tc.number:searchSettingsDataTest_001
    * @tc.name: 初始化搜索数据到数据库.
    * @tc.type: 0 || TestType.FUNCTION  || Level.LEVEL0
    * @tc.desc: 初始化搜索数据到数据库.
    */
    it('searchSettingsDataTest_001', 0, async () => {
      PreferencesUtil.delete(`ItemInfo${i18n.System.getSystemLocale()}`);
      SearchDataController.initSearchData();
    })

    /*
    * @tc.number:searchSettingsDataTest_002
    * @tc.name: 初始化设置页描述信息到数据库.
    * @tc.type: 0 || TestType.FUNCTION || Level.LEVEL0
    * @tc.desc: 初始化设置页描述信息到数据库.
    */
    it('searchSettingsDataTest_002', 0, async () => {
      LogUtil.info(`${TAG} start to searchSettingsDataTest_002`);
      PreferencesUtil.delete('PageInfoDesc');
      SettingPageDescController.initPageInfoData();
    })

    /*
    * @tc.number:searchSettingsDataTest_003
    * @tc.name: 初始化设置历史搜索信息到数据库.
    * @tc.type: 0 || TestType.FUNCTION  || Level.LEVEL0
    * @tc.desc: 初始化设置历史搜索信息到数据库
    */
    it('searchSettingsDataTest_003', 0, async () => {
      LogUtil.info(`${TAG} start to searchSettingsDataTest_003`);
      SearchHistoryController.initSearchData();
    })
    /*
    * @tc.number:searchSettingsDataTest_004
    * @tc.name: 添加历史搜索记录到数据库
    * @tc.type: 0 || TestType.FUNCTION || Level.LEVEL0
    * @tc.desc: 添加历史搜索记录到数据库
    */
    it('searchSettingsDataTest_004', 0, async () => {
      LogUtil.info(`${TAG} start to searchSettingsDataTest_004`);
      SearchHistoryController.addSearchData({
        query: 'Test',
        timestamp: new Date().getTime()
      });
    })
    /*
     * @tc.number:searchSettingsDataTest_005
     * @tc.name: 查询历史搜索记录
     * @tc.type: 0 || TestType.FUNCTION || Level.LEVEL0
     * @tc.desc: 查询历史的搜索记录
     * */
    it('searchSettingsDataTest_005', 0, async () => {
      LogUtil.info(`${TAG} start to searchSettingsDataTest_005`);
      SearchHistoryController.getSearchData();
    })
    /*
     * @tc.number:searchSettingsDataTest_006
     * @tc.name: 清空历史记录
     * @tc.type: 0 || TestType.FUNCTION || Level.LEVEL0
     * @tc.desc: 清空历史搜索记录
     * */
    it('searchSettingsDataTest_006', 0, async () => {
      LogUtil.info(`${TAG} start to searchSettingsDataTest_006`);
      SearchHistoryController.deleteSearchData();
    })

    /*
     * @tc.number:searchSettingsDataTest_007
     * @tc.name: 初始化搜索数据到数据库
     * @tc.type: 0 || TestType.FUNCTION  || Level.LEVEL0
     * @tc.desc: 初始化搜索数据到数据库 非第一次进入设置
     */
    it('searchSettingsDataTest_007', 0, async () => {
      LogUtil.info(`${TAG} start to searchSettingsDataTest_007`);
      // 1.创建一个mock能力的对象MockKit
      let mocker: MockKit = new MockKit();
      let mockfunc: Function = mocker.mockFunc(new PreferencesUtil(), PreferencesUtil.has);
      when(mockfunc)(`ItemInfo${i18n.System.getSystemLocale()}`).afterReturn(false);
      SearchDataController.initSearchData();
    })

    /*
     * @tc.number:searchSettingsDataTest_008
     * @tc.name: 初始化设置页描述信息到数据库
     * @tc.type: 0 || TestType.FUNCTION || Level.LEVEL0
     * @tc.desc: 初始化设置页描述信息到数据库 非第一次进入设置
     */
    it('searchSettingsDataTest_008', 0, async () => {
      LogUtil.info(`${TAG} start to searchSettingsDataTest_008`);
      // 1.创建一个mock能力的对象MockKit
      let mocker: MockKit = new MockKit();
      let mockfunc: Function = mocker.mockFunc(new PreferencesUtil(), PreferencesUtil.has);
      when(mockfunc)('PageInfoDesc').afterReturn(false);
      SettingPageDescController.deletePageInfoData();
      SettingPageDescController.initPageInfoData();
      LogUtil.info(`${TAG} searchSettingsDataTest_008 end`);
    })
  })
}
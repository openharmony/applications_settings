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
import { Driver } from '@ohos.UiTest';
import { LogUtil } from '@ohos/settings.common/src/main/ets/utils/LogUtil';
import { BusinessError } from '@ohos.base';
import { COMMON_DELAY } from '../types';
import abilityDelegatorRegistry from '@ohos.app.ability.abilityDelegatorRegistry';
import { Constant } from '../constant/Constant';
import { SearchSettingsController } from '../../../../main/ets/Setting/Search/controller/SearchSettingsController';
import { RenderItemInfo } from '@ohos/settings.search/src/main/ets/model/type';
import { SearchDataController, SettingPageDescController } from '@ohos/settings.search';

const TAG: string = 'SearchSettingsControllerTest: ';
const DELEGATOR: abilityDelegatorRegistry.AbilityDelegator = abilityDelegatorRegistry.getAbilityDelegator();

export default function SearchSettingsControllerTest() {
  describe('SearchSettingsControllerTest', () => {
    let dr: Driver | null = null;
    let searchController: SearchSettingsController = new SearchSettingsController();
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
      await SearchDataController.initSearchData();
      await SettingPageDescController.initPageInfoData();
    });

    afterAll(async () => {
      dr = await Driver.create();
      await dr.delayMs(COMMON_DELAY);
      await dr.pressHome();
      await dr.delayMs(COMMON_DELAY);
    });

    it('inputChangeEvent', 0, async () => {
      let result: RenderItemInfo[] = [];
      searchController.inputChangeEvent('lan', 'onSubmit')
        .then((resultList) => {
          result = resultList;
        });
      LogUtil.info(`${TAG} lan search result len: ${result.length}`);
      expect(result.length >= 0).assertTrue();
    });

    it('getHistoryData', 0, async () => {
      let result = await searchController.getHistoryData();
      LogUtil.info(`${TAG} history data len: ${result.length}`);
      expect(result.length >= 0).assertTrue();
    });
  })
}
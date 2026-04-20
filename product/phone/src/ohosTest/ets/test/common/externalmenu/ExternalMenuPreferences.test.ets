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
import { describe, beforeAll, beforeEach, afterEach, afterAll, it, expect, MockKit,
  ArgumentMatchers,
  when} from '@ohos/hypium'
import { ExternalMenu, PreferencesUtil } from '@ohos/settings.common';
import { ExternalMenuPreferences } from '@ohos/settings.common/src/main/ets/externalmenu/ExternalMenuPreferences'
import { systemParameter } from '@kit.BasicServicesKit';

export default function ExternalMenuPreferencesTest() {
  describe('ExternalMenuPreferencesTest', () => {
   let externalMenuInstance = new ExternalMenuPreferences();
    it('ExternalMenuPreferencesTest_getDisplayVersion', 0, () => {
     let result = externalMenuInstance.getDisplayVersion();
      expect(result !== null).assertTrue();
    })

    it('ExternalMenuPreferencesTest_getDisplayVersion_01', 0, () => {
      try {
        let menu: ExternalMenu = {
          bundleName: '',
          abilityName: '',
          key: '',
          menuType: '',
          showCondition: '',
          titleResource: '',
          title: '',
          state: '',
          iconResource: '',
          icon: '',
          summaryResource: '',
          summary: '',
          stateDbKey: '',
          stateDefault: '',
          switchDbKey: '',
          switchDefault: '',
          accessTokenId: 1,
        } as ExternalMenu;
        let result = externalMenuInstance.getTitleAndSummaryResource(menu, true);
        expect(result !== null).assertTrue();

        let mocker: MockKit = new MockKit();

        let mockfunc: Function = mocker.mockFunc(PreferencesUtil, PreferencesUtil.hasSync);
        when(mockfunc)(ArgumentMatchers.any).afterReturn(true);
        let result2 = externalMenuInstance.getTitleAndSummaryResource(menu, true);
        expect(result2 !== null).assertTrue();

        let mockfunc2: Function = mocker.mockFunc(PreferencesUtil, PreferencesUtil.hasSync);
        when(mockfunc2)(ArgumentMatchers.any).afterReturn(true);
        let result3 = externalMenuInstance.getTitleAndSummaryResource(menu, false);
        expect(result3 !== null).assertTrue();
        mocker.clear(PreferencesUtil);
      } catch (e) {
      }

      let  menu2: undefined = undefined;
      let result2 = externalMenuInstance.getTitleAndSummaryResource(menu2, true);
      expect(result2 !== null).assertTrue();
    })

  })
}
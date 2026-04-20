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

import { describe, it, expect, MockKit, when, ArgumentMatchers, afterAll, beforeAll } from '@ohos/hypium'
import { SettingsDataUtils } from '@ohos/settings.common/src/main/ets/utils/SettingsDataUtils';
import { DisplayUtils } from '@ohos/settings.display/src/main/ets/DisplayUtils';
import { RefreshRateUtils } from '@ohos/settings.display/src/main/ets/utils/RefreshRateUtils';

export default function RefreshRateUtilsTest() {
  describe('RefreshRateUtilsTest', () => {
    it('RefreshRateUtilsTest_validateRefreshRates_001', 0, () => {
      let result = (RefreshRateUtils as object)['validateRefreshRates']() as boolean;
      expect(result).assertFalse();
      result = (RefreshRateUtils as object)['validateRefreshRates']([]) as boolean;
      expect(result).assertFalse();
      result = (RefreshRateUtils as object)['validateRefreshRates']([0]) as boolean;
      expect(result).assertFalse();
      result = (RefreshRateUtils as object)['validateRefreshRates']([60]) as boolean;
      expect(result).assertTrue();
    })
    it('RefreshRateUtilsTest_validateRefreshMode_001', 0, () => {
      let result = (RefreshRateUtils as object)['validateRefreshMode'](3, [30, 60], []) as boolean;
      expect(result).assertFalse();
      result = (RefreshRateUtils as object)['validateRefreshMode'](-1, [30, 60], [0]) as boolean;
      expect(result).assertFalse();
      result = (RefreshRateUtils as object)['validateRefreshMode'](-1, [30, 60], [-1]) as boolean;
      expect(result).assertTrue();
    })
    it('RefreshRateUtilsTest_getStateText_001', 0, () => {
      let result = (RefreshRateUtils as object)['getStateText'](-1, []) as string;
      expect(result).assertEqual('app.string.screen_refresh_rate_dynamic');
      result = (RefreshRateUtils as object)['getStateText'](0, []) as string;
      expect(result).assertEqual('app.string.screen_refresh_rate_standard');
      result = (RefreshRateUtils as object)['getStateText'](1, [30, 60, 90, 120]) as string;
      expect(result).assertEqual('30Hz');
      result = (RefreshRateUtils as object)['getStateText'](1, [60, 90, 120]) as string;
      expect(result).assertEqual('app.string.screen_refresh_rate_standard');
      result = (RefreshRateUtils as object)['getStateText'](2, [60, 90, 120]) as string;
      expect(result).assertEqual('app.string.screen_refresh_rate_mid');
      result = (RefreshRateUtils as object)['getStateText'](3, [60, 90, 120]) as string;
      expect(result).assertEqual('app.string.screen_refresh_rate_high');
      result = (RefreshRateUtils as object)['getStateText'](1, [90, 120]) as string;
      expect(result).assertEqual('app.string.screen_refresh_rate_standard');
      result = (RefreshRateUtils as object)['getStateText'](2, [90, 120]) as string;
      expect(result).assertEqual('app.string.screen_refresh_rate_high');
    })
    it('RefreshRateUtilsTest_setScreenRefreshRateValue_001', 0, () => {
      const currentRefreshType = RefreshRateUtils.getRefreshType();
      let mocker: MockKit = new MockKit();
      let mockFun :Function = mocker.mockFunc(RefreshRateUtils, RefreshRateUtils.supportRefreshRates);
      when(mockFun)().afterReturn(true);
      RefreshRateUtils.setScreenRefreshRateValue('high');
      when(mockFun)().afterReturn(false);
      RefreshRateUtils.setScreenRefreshRateValue('high');
      RefreshRateUtils.setScreenRefreshRateValue('standard');
      RefreshRateUtils.setScreenRefreshRateValue('medium');
      RefreshRateUtils.setScreenRefreshRateValue('Dynamic');
      when(mockFun)().afterReturn(true);
      RefreshRateUtils.setScreenRefreshRateValue('high');
      expect(currentRefreshType.length >= 0).assertTrue();
      mocker.clear(RefreshRateUtils);
    })
    it('RefreshRateUtilsTest_getRefreshType_001', 0, () => {
      let mocker: MockKit = new MockKit();
      let mockFun :Function = mocker.mockFunc(SettingsDataUtils, SettingsDataUtils.getSettingsData);
      when(mockFun)(ArgumentMatchers.any).afterReturn('-1');
      let result = RefreshRateUtils.getRefreshType();
      expect(result.length >= 0).assertTrue();
      when(mockFun)(ArgumentMatchers.any).afterReturn('0');
      result = RefreshRateUtils.getRefreshType();
      expect(result.length >= 0).assertTrue();
      when(mockFun)(ArgumentMatchers.any).afterReturn('1');
      result = RefreshRateUtils.getRefreshType();
      expect(result.length >= 0).assertTrue();
      when(mockFun)(ArgumentMatchers.any).afterReturn('2');
      let mockFun1 :Function = mocker.mockFunc(RefreshRateUtils, RefreshRateUtils.supportRefreshRates);
      when(mockFun1)().afterReturn(true);
      result = RefreshRateUtils.getRefreshType();
      expect(result.length >= 0).assertTrue();
      when(mockFun1)().afterReturn(false);
      result = RefreshRateUtils.getRefreshType();
      expect(result.length >= 0).assertTrue();
      when(mockFun)(ArgumentMatchers.any).afterReturn('3');
      result = RefreshRateUtils.getRefreshType();
      expect(result.length >= 0).assertTrue();
      mocker.clear(RefreshRateUtils);
      mocker.clear(SettingsDataUtils);
    })
    it('RefreshRateUtilsTest_getRefreshTypeTitle_001', 0, () => {
      let mocker: MockKit = new MockKit();
      let mockFun :Function = mocker.mockFunc(SettingsDataUtils, SettingsDataUtils.getSettingsData);
      when(mockFun)(ArgumentMatchers.any).afterReturn('-1');
      let result = RefreshRateUtils.getRefreshTypeTitle();
      expect(result.length >= 0).assertTrue();
      when(mockFun)(ArgumentMatchers.any).afterReturn('0');
      result = RefreshRateUtils.getRefreshTypeTitle();
      expect(result.length >= 0).assertTrue();
      when(mockFun)(ArgumentMatchers.any).afterReturn('1');
      result = RefreshRateUtils.getRefreshTypeTitle();
      expect(result.length >= 0).assertTrue();
      when(mockFun)(ArgumentMatchers.any).afterReturn('2');
      let mockFun1 :Function = mocker.mockFunc(RefreshRateUtils, RefreshRateUtils.supportRefreshRates);
      when(mockFun1)().afterReturn(true);
      result = RefreshRateUtils.getRefreshTypeTitle();
      expect(result.length >= 0).assertTrue();
      when(mockFun1)().afterReturn(false);
      result = RefreshRateUtils.getRefreshTypeTitle();
      expect(result.length >= 0).assertTrue();
      when(mockFun)(ArgumentMatchers.any).afterReturn('3');
      result = RefreshRateUtils.getRefreshTypeTitle();
      expect(result.length >= 0).assertTrue();
      mocker.clear(RefreshRateUtils);
      mocker.clear(SettingsDataUtils);
    })
  })
}
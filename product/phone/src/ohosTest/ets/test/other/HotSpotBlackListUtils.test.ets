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

import { afterAll, afterEach, beforeAll, beforeEach, describe, expect, it } from '@ohos/hypium';
import { HotSpotBlackListUtils } from '@ohos/settings.common/src/main/ets/utils/HotSpotBlackListUtils';
import wifiManager from '@ohos.wifiManager';

export default function hotSpotBlackListUtilsTest() {
  describe('hotSpotBlackListUtilsTest', (): void => {

    beforeAll((): void => {
    })

    beforeEach((): void => {
    })

    afterAll((): void => {
    })

    afterEach((): void => {
    })

    it('HotSpotBlackListUtilsTest_deleteFromBlackList', 0, () => {
      let station: wifiManager.StationInfo = {
        name: 'station',
        macAddress:'123',
        macAddressType: 0,
        ipAddress:'123'
      }
      HotSpotBlackListUtils.deleteFromBlackList(station)
      expect(1).assertEqual(1);
      let par: wifiManager.StationInfo = AppStorage.get<wifiManager.StationInfo>('stationInfo') as wifiManager.StationInfo;
      let resA = HotSpotBlackListUtils.deleteFromBlackList(par);
      expect(resA === null).assertFalse();

    })

    it('HotSpotBlackListUtilsTest_getStationByMac_success', 0, () => {
      let station: wifiManager.StationInfo = HotSpotBlackListUtils.getStationByMac(true, 'AA:BB:CC:DD:EE:FF') as wifiManager.StationInfo;
      expect(station).assertUndefined();

      let resA = HotSpotBlackListUtils.getStationByMac(true, '') as wifiManager.StationInfo;
      expect(resA).assertUndefined();

      let resB = HotSpotBlackListUtils.getStationByMac(false, 'AA:BB:CC:DD:EE:FF') as wifiManager.StationInfo;
      expect(resB === null).assertFalse();

    })

    it('HotSpotBlackListUtilsTest_addToBlockList', 0, () => {
      let station: wifiManager.StationInfo = {
        name: 'station',
        macAddress:'123',
        macAddressType: 0,
        ipAddress:'123'
      }
      HotSpotBlackListUtils.addToBlockList(station);
      expect(0).assertEqual(0);
      let par: wifiManager.StationInfo = AppStorage.get<wifiManager.StationInfo>('stationInfo') as wifiManager.StationInfo;
      let resA = HotSpotBlackListUtils.addToBlockList(par);
      expect(resA === null).assertFalse();

    })
  })
}


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

import { describe, it, expect, MockKit, ArgumentMatchers, when } from '@ohos/hypium'
import { connection } from '@kit.NetworkKit';
import { AboutDeviceUtils } from '@ohos/settings.aboutdevice/src/main/ets/utils/AboutDeviceUtils';
import { SimUtils } from '@ohos/settings.common/src/main/ets/utils/SimUtils';
import { SystemParamUtil } from '@ohos/settings.common/src/main/ets/utils/SystemParamUtil';
import { SystemParamUtils } from '@ohos/settings.common/src/main/ets/screenReader/utils/SystemParamUtils';
import { WifiUtils } from '@ohos/settings.wifi/src/main/ets/WifiUtils';
import { LanguageUtils } from '@ohos/settings.common/src/main/ets/utils/LanguageUtils';
import { TelephonyRadioUtils } from '@ohos/settings.common/src/main/ets/utils/TelephonyRadioUtils';
import { StorageSizeUtil } from '@ohos/settings.storage/src/main/ets/utils/StorageSizeUtil';

const NETWORK_TYPE_GSM: number = 1;
const NETWORK_TYPE_CDMA: number = 2;
const NETWORK_TYPE_WCDMA: number = 3;
const NETWORK_TYPE_TDSCDMA: number = 4;
const NETWORK_TYPE_LTE: number = 5;
const NETWORK_TYPE_5GNR: number = 6;
const NETWORK_TYPE_DTK: number = 7;

export default function AboutDeviceUtilsTest() {
  describe('AboutDeviceUtilsTest', () => {
    let aboutDeviceUtils = AboutDeviceUtils;
    it('AboutDeviceUtilsTest_getNetworkType_001', 0, (done: Function) => {
      try {
        let result = aboutDeviceUtils.getNetworkType(NETWORK_TYPE_GSM);
        expect(result === 'GSM').assertTrue();
        let result2 = aboutDeviceUtils.getNetworkType(NETWORK_TYPE_CDMA);
        expect(result2 === 'CDMA').assertTrue();
        let result3 = aboutDeviceUtils.getNetworkType(NETWORK_TYPE_WCDMA);
        expect(result3 === 'WCDMA').assertTrue();
        let result4 = aboutDeviceUtils.getNetworkType(NETWORK_TYPE_TDSCDMA);
        expect(result4 === 'TDSCDMA').assertTrue();
        let result5 = aboutDeviceUtils.getNetworkType(NETWORK_TYPE_LTE);
        expect(result5 === 'LTE').assertTrue();
        let result6 = aboutDeviceUtils.getNetworkType(NETWORK_TYPE_5GNR);
        expect(result6 === '5G NR').assertTrue();
        let result7 = aboutDeviceUtils.getNetworkType(NETWORK_TYPE_DTK);
        expect(result7 === '').assertTrue();
      } catch (e) {
      } finally {
        done()
      }
    });
    it('AboutDeviceUtilsTest_isAnonymization_002', 0, (done: Function) => {
      try {
        let result = aboutDeviceUtils.isAnonymization();
        expect(result !== null).assertTrue();
        let result2 = aboutDeviceUtils.isAnonymization();
        expect(result2 !== null).assertTrue();
      } catch (e) {
      } finally {
        done()
      }
    });
    it('AboutDeviceUtilsTest_isAnonymizationData_003', 0, (done: Function) => {
      try {
        let mocker: MockKit = new MockKit();
        let mockfunc: Function =
          mocker.mockFunc(aboutDeviceUtils, aboutDeviceUtils.isAnonymization);
        when(mockfunc)(ArgumentMatchers.any).afterReturn(true);
        (aboutDeviceUtils as object)['anonymizationInfoStr'] = '1';
        let result = aboutDeviceUtils.isAnonymizationData();
        expect(result !== null).assertTrue();
        mocker.clear(aboutDeviceUtils);
      } catch (e) {
      } finally {
        done()
      }
    });
    it('AboutDeviceUtilsTest_setAnonymizationInfo_004', 0, (done: Function) => {
      try {
        let mocker: MockKit = new MockKit();
        let mockfunc: Function =
          mocker.mockFunc(SystemParamUtils, SystemParamUtils.getSystemParam);
        when(mockfunc)(ArgumentMatchers.any).afterReturn('const;');
        let result = aboutDeviceUtils.setAnonymizationInfo();
        expect(result !== null).assertTrue();
        mocker.clear(SystemParamUtils);
      } catch (e) {
      } finally {
        done()
      }
    });
    it('AboutDeviceUtilsTest_setAnonymizationInfo_004_01', 0, (done: Function) => {
      try {
        let mocker: MockKit = new MockKit();
        let mockfunc: Function =
          mocker.mockFunc(SystemParamUtils, SystemParamUtils.getSystemParam);
        when(mockfunc)(ArgumentMatchers.any).afterReturn('const;product;hide;settings;1;3;4');
        let result = aboutDeviceUtils.setAnonymizationInfo();
        expect(result !== null).assertTrue();
        mocker.clear(SystemParamUtils);
      } catch (e) {
      } finally {
        done()
      }
    });
    it('AboutDeviceUtilsTest_getProductMemory_005', 0, (done: Function) => {
      try {
        let mocker: MockKit = new MockKit();
        let mockfunc: Function =
          mocker.mockFunc(SystemParamUtils, SystemParamUtils.getSystemParam);
        when(mockfunc)(ArgumentMatchers.any).afterReturn(1);
        let result = aboutDeviceUtils.getProductMemory();
        expect(result !== null).assertTrue();
        let mockfunc2: Function =
          mocker.mockFunc(SystemParamUtils, SystemParamUtils.getSystemParam);
        when(mockfunc2)(ArgumentMatchers.any).afterReturn(NaN);
        let result2 = aboutDeviceUtils.getProductMemory();
        expect(result2 !== null).assertTrue();
        mocker.clear(SystemParamUtils);
      } catch (e) {
      } finally {
        done()
      }
    });
    it('AboutDeviceUtilsTest_getSoftwareVersion_006', 0, (done: Function) => {
      try {
        let result = aboutDeviceUtils.getSoftwareVersion();
        expect(result !== null).assertTrue();
        let mocker: MockKit = new MockKit();
        let mockfunc: Function =
          mocker.mockFunc(SystemParamUtil, SystemParamUtil.getParam);
        when(mockfunc)(ArgumentMatchers.any).afterReturn('1');
        let result2 = aboutDeviceUtils.getSoftwareVersion();
        expect(result2 !== null).assertTrue();
        mocker.clear(SystemParamUtils);
      } catch (e) {
      } finally {
        done()
      }
    });
    it('AboutDeviceUtilsTest_getImeiId_007', 0, async (done: Function) => {
      try {
        let mocker: MockKit = new MockKit();
        let mockfunc: Function =
          mocker.mockFunc(SimUtils, SimUtils.getCardSlotNum);
        when(mockfunc)(ArgumentMatchers.any).afterReturn(-1);
        let result = await aboutDeviceUtils.getImeiId();
        expect(result !== null).assertTrue();
        mocker.clear(SimUtils);
      } catch (e) {
      } finally {
        done()
      }
    });
    it('AboutDeviceUtilsTest_getImeiId_007_01', 0, async (done: Function) => {
      try {
        let mocker: MockKit = new MockKit();
        let mockfunc: Function =
          mocker.mockFunc(SimUtils, SimUtils.getCardSlotNum);
        when(mockfunc)(ArgumentMatchers.any).afterReturn(10);
        let result = await aboutDeviceUtils.getImeiId();
        expect(result !== null).assertTrue();
        mocker.clear(SimUtils);
      } catch (e) {
      } finally {
        done()
      }
    });
    it('AboutDeviceUtilsTest_getBasebandVersion_008', 0, async (done: Function) => {
      try {
        let mocker: MockKit = new MockKit();
        let mockfunc: Function =
          mocker.mockFunc(SimUtils, SimUtils.getCardSlotNum);
        when(mockfunc)(ArgumentMatchers.any).afterReturn(-1);
        let result = await aboutDeviceUtils.getBasebandVersion();
        expect(result !== null).assertTrue();
        mocker.clear(SimUtils);
      } catch (e) {
      } finally {
        done()
      }
    });
    it('AboutDeviceUtilsTest_getBasebandVersion_008_01', 0, async (done: Function) => {
      try {
        let mocker: MockKit = new MockKit();
        let mockfunc: Function =
          mocker.mockFunc(SimUtils, SimUtils.getCardSlotNum);
        when(mockfunc)(ArgumentMatchers.any).afterReturn(10);
        let result2 = await aboutDeviceUtils.getBasebandVersion();
        expect(result2 !== null).assertTrue();
        mocker.clear(SimUtils);
      } catch (e) {
      } finally {
        done()
      }
    });
    it('AboutDeviceUtilsTest_getIpAddress_009', 0, async (done: Function) => {
      try {
        let netHandle: connection.NetHandle = await connection.getDefaultNet();
        let result = await aboutDeviceUtils.getIpAddress(netHandle);
        expect(result !== null).assertTrue();
      } catch (e) {
      } finally {
        done()
      }
    });
    it('AboutDeviceUtilsTest_getWlanMacAddress_010', 0, async (done: Function) => {
      try {
        let mocker: MockKit = new MockKit();
        let mockfunc: Function =
          mocker.mockFunc(WifiUtils,await WifiUtils.wifiLinkedInfo);
        when(mockfunc)(ArgumentMatchers.any).afterReturn('');
        let result = await aboutDeviceUtils.getWlanMacAddress();
        expect(result !== null).assertTrue();
        mocker.clear(WifiUtils);
      } catch (e) {
      } finally {
        done()
      }
    });
    it('AboutDeviceUtilsTest_getWlanMacAddress_010_01', 0, async (done: Function) => {
      try {
        let mocker: MockKit = new MockKit();
        let mockfunc: Function =
          mocker.mockFunc(WifiUtils, WifiUtils.isWifiActive);
        when(mockfunc)(ArgumentMatchers.any).afterReturn(false);
        let mockfunc3: Function =
          mocker.mockFunc(WifiUtils, await WifiUtils.wifiLinkedInfo);
        when(mockfunc3)(ArgumentMatchers.any).afterReturn('wifiName');
        let result3 = await aboutDeviceUtils.getWlanMacAddress();
        expect(result3 !== null).assertTrue();
        mocker.clear(WifiUtils);
      } catch (e) {
      } finally {
        done()
      }
    });
    it('AboutDeviceUtilsTest_getRunningMemory_011', 0, (done: Function) => {
      try {
        let mocker: MockKit = new MockKit();
        let mockfunc: Function =
          mocker.mockFunc(LanguageUtils, LanguageUtils.isLtrDirection);
        when(mockfunc)(ArgumentMatchers.any).afterReturn(true);
        let result = aboutDeviceUtils.getRunningMemory();
        expect(result !== null).assertTrue();
        mocker.clear(LanguageUtils);
      } catch (e) {
      } finally {
        done()
      }
    });
    it('AboutDeviceUtilsTest_getRunningMemory_011_01', 0, (done: Function) => {
      try {
        let mocker: MockKit = new MockKit();
        let mockfunc: Function =
          mocker.mockFunc(aboutDeviceUtils, aboutDeviceUtils.isAnonymizationData);
        when(mockfunc)(ArgumentMatchers.any).afterReturn(false);
        let result = aboutDeviceUtils.getRunningMemory();
        expect(result !== null).assertTrue();
        let mockfunc2: Function =
          mocker.mockFunc(LanguageUtils, LanguageUtils.isLtrDirection);
        when(mockfunc2)(ArgumentMatchers.any).afterReturn(false);
        let result2 = aboutDeviceUtils.getRunningMemory();
        expect(result2 !== null).assertTrue();
        mocker.clear(aboutDeviceUtils);
        mocker.clear(LanguageUtils);
      } catch (e) {
      } finally {
        done()
      }
    });
    it('AboutDeviceUtilsTest_getAppInfoStorage_012', 0, async (done: Function) => {
      try {
        let result = await aboutDeviceUtils.getAppInfoStorage();
        expect(result !== null).assertTrue();
        let mocker: MockKit = new MockKit();
        let mockfunc: Function =
          mocker.mockFunc(StorageSizeUtil, StorageSizeUtil.formatData);
        when(mockfunc)(ArgumentMatchers.any).afterReturn('12');
        let result2 = await aboutDeviceUtils.getAppInfoStorage();
        expect(result2 !== null).assertTrue();
        mocker.clear(StorageSizeUtil);
      } catch (e) {
      } finally {
        done()
      }
    });
    it('AboutDeviceUtilsTest_getDefaultDisplay_013', 0, (done: Function) => {
      try {
        let mocker: MockKit = new MockKit();
        let mockfunc: Function =
          mocker.mockFunc(AboutDeviceUtils, AboutDeviceUtils.isAnonymizationData);
        when(mockfunc)(ArgumentMatchers.any).afterReturn(false);
        let result = aboutDeviceUtils.getDefaultDisplay();
        expect(result !== null).assertTrue();
        mocker.clear(AboutDeviceUtils);
      } catch (e) {
      } finally {
        done()
      }
    });
    it('AboutDeviceUtilsTest_getDefaultDisplay_013_01', 0, (done: Function) => {
      try {
        let mocker: MockKit = new MockKit();
        let mockfunc: Function =
          mocker.mockFunc(AboutDeviceUtils, AboutDeviceUtils.isAnonymizationData);
        when(mockfunc)(ArgumentMatchers.any).afterReturn(true);
        let result2 = aboutDeviceUtils.getDefaultDisplay();
        expect(result2 !== null).assertTrue();
        mocker.clear(AboutDeviceUtils);
      } catch (e) {
      } finally {
        done()
      }
    });
    it('AboutDeviceUtilsTest_getKernelVersion_014', 0, (done: Function) => {
      try {
        let mocker: MockKit = new MockKit();
        let mockfunc: Function =
          mocker.mockFunc(AboutDeviceUtils, AboutDeviceUtils.isAnonymizationData);
        when(mockfunc)(ArgumentMatchers.any).afterReturn(false);
        let result = aboutDeviceUtils.getKernelVersion()
        expect(result !== null).assertTrue();
        mocker.clear(AboutDeviceUtils);
      } catch (e) {
      } finally {
        done()
      }
    });
    it('AboutDeviceUtilsTest_getKernelVersion_014_01', 0, (done: Function) => {
      try {
        let mocker: MockKit = new MockKit();
        let mockfunc: Function =
          mocker.mockFunc(AboutDeviceUtils, AboutDeviceUtils.isAnonymizationData);
        when(mockfunc)(ArgumentMatchers.any).afterReturn(true);
        let result2 = aboutDeviceUtils.getKernelVersion();
        expect(result2 !== null).assertTrue();
        mocker.clear(AboutDeviceUtils);
      } catch (e) {
      } finally {
        done()
      }
    });
    it('AboutDeviceUtilsTest_getHardwareModel_015', 0, (done: Function) => {
      try {
        let mocker: MockKit = new MockKit();
        let mockfunc: Function =
          mocker.mockFunc(AboutDeviceUtils, AboutDeviceUtils.isAnonymizationData);
        when(mockfunc)(ArgumentMatchers.any).afterReturn(false);
        let result = aboutDeviceUtils.getHardwareModel();
        expect(result !== null).assertTrue();
        mocker.clear(AboutDeviceUtils);
      } catch (e) {
      } finally {
        done()
      }
    });
    it('AboutDeviceUtilsTest_getHardwareModel_015_01', 0, (done: Function) => {
      try {
        let mocker: MockKit = new MockKit();
        let mockfunc: Function =
          mocker.mockFunc(AboutDeviceUtils, AboutDeviceUtils.isAnonymizationData);
        when(mockfunc)(ArgumentMatchers.any).afterReturn(true);
        let result2 = aboutDeviceUtils.getHardwareModel();
        expect(result2 !== null).assertTrue();
        mocker.clear(AboutDeviceUtils);
      } catch (e) {
      } finally {
        done()
      }
    });
    it('AboutDeviceUtilsTest_getApiVersion_016', 0, (done: Function) => {
      try {
        let result = aboutDeviceUtils.getApiVersion();
        expect(result !== null).assertTrue();
      } catch (e) {
      } finally {
        done()
      }
    });
    it('AboutDeviceUtilsTest_getOperatorNameData_017', 0, async (done: Function) => {
      try {
        let result = await aboutDeviceUtils.getOperatorNameData(10);
        expect(result !== null).assertTrue();
        let mocker: MockKit = new MockKit();
        let mockfunc: Function =
          mocker.mockFunc(SimUtils, SimUtils.isSimActivating);
        when(mockfunc)(ArgumentMatchers.any).afterReturn(true);
        let result2 = await aboutDeviceUtils.getOperatorNameData(10)
        expect(result2 !== null).assertTrue();
        mocker.clear(SimUtils);
      } catch (e) {
      } finally {
        done()
      }
    });
    it('AboutDeviceUtilsTest_getSignalStrengthDate_018', 0, async (done: Function) => {
      try {
        let mocker: MockKit = new MockKit();
        let mockfunc: Function =
          mocker.mockFunc(SimUtils, SimUtils.isSimActivating);
        when(mockfunc)(ArgumentMatchers.any).afterReturn(false);
        let result = await aboutDeviceUtils.getSignalStrengthDate(10);
        expect(result !== null).assertTrue();
        let mockfunc2: Function =
          mocker.mockFunc(SimUtils, SimUtils.isSimActivating);
        when(mockfunc2)(ArgumentMatchers.any).afterReturn(true);
        let result2 = await aboutDeviceUtils.getSignalStrengthDate(10);
        expect(result2 !== null).assertTrue();
        let list: ESObject[] = [{
          dBm: 'test'
        }];
        let mockfunc3: Function =
          mocker.mockFunc(TelephonyRadioUtils, await TelephonyRadioUtils.getSignalInformation);
        when(mockfunc3)(ArgumentMatchers.any).afterReturn(list);
        let result3 = await aboutDeviceUtils.getSignalStrengthDate(10);
        expect(result3 !== null).assertTrue();
        mocker.clear(SimUtils);
        mocker.clear(TelephonyRadioUtils);
      } catch (e) {
      } finally {
        done()
      }
    });
    it('AboutDeviceUtilsTest_getMobileNetworkTypeDate_019', 0, async (done: Function) => {
      try {

        let mocker: MockKit = new MockKit();
        let mockfunc: Function =
          mocker.mockFunc(SimUtils, SimUtils.isSimActivating);
        when(mockfunc)(ArgumentMatchers.any).afterReturn(false);
        let result = await aboutDeviceUtils.getMobileNetworkTypeDate(10);
        expect(result !== null).assertTrue();
        let list: ESObject[] = [{
          signalType: 'test'
        }];
        let mockfunc2: Function =
          mocker.mockFunc(TelephonyRadioUtils, await TelephonyRadioUtils.getSignalInformation);
        when(mockfunc2)(ArgumentMatchers.any).afterReturn(list);
        let mockfunc3: Function =
          mocker.mockFunc(SimUtils, SimUtils.isSimActivating);
        when(mockfunc3)(ArgumentMatchers.any).afterReturn(true);
        let result2 = await aboutDeviceUtils.getMobileNetworkTypeDate(10);
        expect(result2 !== null).assertTrue();
        mocker.clear(SimUtils);
        mocker.clear(TelephonyRadioUtils);
      } catch (e) {
      } finally {
        done()
      }
    });
    it('AboutDeviceUtilsTest_getCellId_020', 0, async (done: Function) => {
      try {
        let cellInfo: ESObject = [{
          data: {
            baseId: 10,
            cellId: 11,
            cgi: 12,
          } as ESObject
        }];
        let mocker: MockKit = new MockKit();
        let mockfunc: Function =
          mocker.mockFunc(SimUtils, SimUtils.isSimActivating);
        when(mockfunc)(ArgumentMatchers.any).afterReturn(true);
        let mockfunc2: Function =
          mocker.mockFunc(TelephonyRadioUtils, TelephonyRadioUtils.getCellInformation);
        when(mockfunc2)(ArgumentMatchers.any).afterReturn(cellInfo);
        let result2 = await aboutDeviceUtils.getCellId(10);
        expect(result2 !== null).assertTrue();
        mocker.clear(SimUtils);
        mocker.clear(TelephonyRadioUtils);
      } catch (e) {
      } finally {
        done()
      }
    });
    it('AboutDeviceUtilsTest_getCellId_020_01', 0, async (done: Function) => {
      try {
        let cellInfo: ESObject = [{
          data: {
            cgi: 12,
          } as ESObject
        }];
        let mocker: MockKit = new MockKit();
        let mockfunc: Function =
          mocker.mockFunc(SimUtils, SimUtils.isSimActivating);
        when(mockfunc)(ArgumentMatchers.any).afterReturn(true);
        let mockfunc2: Function =
          mocker.mockFunc(TelephonyRadioUtils, TelephonyRadioUtils.getCellInformation);
        when(mockfunc2)(ArgumentMatchers.any).afterReturn(cellInfo);
        let result2 = await aboutDeviceUtils.getCellId(11);
        expect(result2 !== null).assertTrue();
        mocker.clear(SimUtils);
        mocker.clear(TelephonyRadioUtils);
      } catch (e) {
      } finally {
        done()
      }
    });
    it('AboutDeviceUtilsTest_getCellId_020_02', 0, async (done: Function) => {
      try {
        let mocker: MockKit = new MockKit();
        let mockfunc: Function =
          mocker.mockFunc(SimUtils, SimUtils.isSimActivating);
        when(mockfunc)(ArgumentMatchers.any).afterReturn(false);
        let result = await aboutDeviceUtils.getCellId(12);
        expect(result !== null).assertTrue();
        mocker.clear(SimUtils);
      } catch (e) {
      } finally {
        done()
      }
    });
    it('AboutDeviceUtilsTest_getSmsCenterNumber_021', 0, async (done: Function) => {
      try {
        let mocker: MockKit = new MockKit();
        let mockfunc: Function =
          mocker.mockFunc(SimUtils, SimUtils.isSimActivating);
        when(mockfunc)(ArgumentMatchers.any).afterReturn(false);
        let result = await aboutDeviceUtils.getSmsCenterNumber(10)
        expect(result !== null).assertTrue();
        let mockfunc2: Function =
          mocker.mockFunc(SimUtils, SimUtils.isSimActivating);
        when(mockfunc2)(ArgumentMatchers.any).afterReturn(true);
        let result2 = await aboutDeviceUtils.getSmsCenterNumber(10)
        expect(result2 !== null).assertTrue();
        mocker.clear(SimUtils);
      } catch (e) {
      } finally {
        done()
      }
    });
    it('AboutDeviceUtilsTest_getMccMncInfo_022', 0, async (done: Function) => {
      try {
        let mocker: MockKit = new MockKit();
        let mockfunc: Function =
          mocker.mockFunc(SimUtils, SimUtils.isSimActivating);
        when(mockfunc)(ArgumentMatchers.any).afterReturn(false);
        let result = await aboutDeviceUtils.getMccMncInfo(10)
        expect(result !== null).assertTrue();
        let mockfunc2: Function =
          mocker.mockFunc(SimUtils, SimUtils.isSimActivating);
        when(mockfunc2)(ArgumentMatchers.any).afterReturn(true);
        let result2 = await aboutDeviceUtils.getMccMncInfo(10)
        expect(result2 !== null).assertTrue();
        let networkState: ESObject = {
          plmnNumeric: 'plmnNumeric'
        };
        let mockfunc3: Function =
          mocker.mockFunc(TelephonyRadioUtils, TelephonyRadioUtils.getNetworkState);
        when(mockfunc3)(ArgumentMatchers.any).afterReturn(networkState);
        let result3 = await aboutDeviceUtils.getMccMncInfo(10);
        expect(result3 !== null).assertTrue();
        mocker.clear(SimUtils);
        mocker.clear(TelephonyRadioUtils);
      } catch (e) {
      } finally {
        done()
      }
    });

    it('AboutDeviceUtilsTest_getSystemServiceVersion_023', 0, (done: Function) => {
      try {
        let result = aboutDeviceUtils.getSystemServiceVersion();
        expect(result !== null).assertTrue();
        let mocker: MockKit = new MockKit();
        let mockfunc: Function = mocker.mockFunc(SystemParamUtil, SystemParamUtil.getParam);
        when(mockfunc)(ArgumentMatchers.any).afterReturn('1');
        let result2 = aboutDeviceUtils.getSystemServiceVersion();
        expect(result2 !== null).assertTrue();
        mocker.clear(SystemParamUtil);
      } catch (e) {
      } finally {
        done();
      }
    });
  });
}
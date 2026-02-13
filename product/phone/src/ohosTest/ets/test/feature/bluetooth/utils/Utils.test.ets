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

import { describe, expect, it } from '@ohos/hypium';
import { AccessAuthorization, ShareType } from '@ohos/settings.bluetooth/src/main/ets/constants/BluetoothConstants';
import { Utils } from '@ohos/settings.bluetooth/src/main/ets/utils/Utils';
import map from '@ohos.bluetooth.map';

export default function UtilsTest() {
  describe('UtilsTest', (): void => {
    let utils = Utils;
    it('UtilsTest_001', 0, (done: Function) => {
      try {
        let result = utils.setPhoneBookAccessAuthorization(null, '', AccessAuthorization.UNKNOWN);
        expect(result !== null).assertTrue();
      } catch (e) {
      } finally {
        done()
      }
    });
    it('UtilsTest_002', 0, (done: Function) => {
      try {
        let result = utils.setShareType(null, '', ShareType.SHARE_NAME_AND_PHONE_NUMBER);
        expect(result !== null).assertTrue();
      } catch (e) {
      } finally {
        done()
      }
    });
    it('UtilsTest_003', 0, (done: Function) => {
      try {
        let params: map.MapMseProfile = {} as map.MapMseProfile;
        let result = utils.setMessageAccessAuthorization(params, '', AccessAuthorization.UNKNOWN);
        expect(result !== null).assertTrue();
      } catch (e) {
      } finally {
        done()
      }
    });
    it('UtilsTest_004', 0, async (done: Function) => {
      try {
        let result = await utils.getRemoteDeviceType('')
        expect(result !== null).assertTrue();
        let result2 = await utils.getRemoteDeviceType('deviceId');
        expect(result2 !== null).assertTrue();
      } catch (e) {
      } finally {
        done()
      }
    });
    it('UtilsTest_005', 0, (done: Function) => {
      try {
        let result = utils.getPhoneBookAccessAuthorization('');
        expect(result !== null).assertTrue();
        let result2 = utils.getPhoneBookAccessAuthorization('deviceId');
        expect(result2 !== null).assertTrue();
      } catch (e) {
      } finally {
        done()
      }
    });
    it('UtilsTest_006', 0, (done: Function) => {
      try {
        let result = utils.getShareType('');
        expect(result !== null).assertTrue();
        let result2 = utils.getShareType('deviceId');
        expect(result2 !== null).assertTrue();
      } catch (e) {
      } finally {
        done()
      }
    });
    it('UtilsTest_007', 0, (done: Function) => {
      try {
        let result = utils.getShareTypeResourceStr(ShareType.SHARE_NAME_AND_PHONE_NUMBER);
        expect(result !== null).assertTrue();
        let result2 = utils.getShareTypeResourceStr(ShareType.SHARE_ALL);
        expect(result2 !== null).assertTrue();
        let result3 = utils.getShareTypeResourceStr(ShareType.SHARE_NOTHING);
        expect(result3 !== null).assertTrue();
        let result4 = utils.getShareTypeResourceStr(3);
        expect(result4 !== null).assertTrue();
      } catch (e) {
      } finally {
        done()
      }
    });
    it('UtilsTest_008', 0, async (done: Function) => {
      try {
        let result = await utils.getPairState('')
        expect(result !== null).assertTrue();
        let result2 = await utils.getPairState('deviceId');
        expect(result2 !== null).assertTrue();
      } catch (e) {
      } finally {
        done()
      }
    });

  })
}


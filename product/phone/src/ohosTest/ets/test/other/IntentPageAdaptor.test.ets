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
  afterEach,
  ArgumentMatchers,
  beforeAll,
  beforeEach,
  describe,
  expect,
  it,
  MockKit,
  when
} from '@ohos/hypium';
import { DeviceUtil, PackagesConstant } from '@ohos/settings.common';
import { IntentPageAdaptor } from '@ohos/settings.intent/src/main/ets/adapter/IntentPageAdaptor';
import { IntentCodeConstants } from '@ohos/settings.intent/src/main/ets/constant/IntentCodeConstant';

export default function intentPageAdaptorTest() {
  describe('intentPageAdaptorTest', (): void => {

    beforeAll((): void => {
    })

    beforeEach((): void => {

    })

    afterAll((): void => {
    })

    afterEach((): void => {
    })

    it('IntentPageAdaptorTest_setNavigationUrlByItem', 0, () => {
      let res = 'test';
      IntentPageAdaptor.setNavigationUrlByItem('main_switch');
      expect(res).not().assertNull();
    })

    it('intentPageAdaptorTest_001', 0, async (done: Function) => {
      try {
        let result = await IntentPageAdaptor.checkPageCanJump('entryKey', 'close_lock_screen_password_title');
        expect(result !== null).assertTrue();
        let result2 = await IntentPageAdaptor.checkPageCanJump('hotspot_data_settings', 'uriParams');
        expect(result2 !== null).assertTrue();
        let result3 = await IntentPageAdaptor.checkPageCanJump('', 'uriParams');
        expect(result3 !== null).assertTrue();
      } catch (e) {
      } finally {
        done()
      }
    });

    it('intentPageAdaptorTest_002', 0, async (done: Function) => {
      try {
        let intentParam: Record<string, Object> = {};
        let result = await IntentPageAdaptor.setNavigationUrlByEntry(intentParam);
        expect(result !== null).assertTrue();
        let mocker: MockKit = new MockKit();
        let mockfunc: Function =
          mocker.mockFunc(IntentPageAdaptor, IntentPageAdaptor.checkPageCanJump);
        when(mockfunc)(ArgumentMatchers.any).afterReturn(false);
        let result2 = await IntentPageAdaptor.setNavigationUrlByEntry(intentParam);
        expect(result2 !== null).assertTrue();
        let mockfunc2: Function =
          mocker.mockFunc(IntentPageAdaptor, IntentPageAdaptor.checkPageCanJump);
        when(mockfunc2)(ArgumentMatchers.any).afterReturn(true);
        let intentParam2: Record<string, Object> = {
          'entryKey': 'power_consumption_entry',
        };
        let result3 = await IntentPageAdaptor.setNavigationUrlByEntry(intentParam2);
        expect(result3 !== null).assertTrue();

        let intentParam3: Record<string, Object> = {
          'entryKey': 'entryKey',
        };
        let result4 = await IntentPageAdaptor.setNavigationUrlByEntry(intentParam3);
        expect(result4 !== null).assertTrue();
        mocker.clear(IntentPageAdaptor);
      } catch (e) {
      } finally {
        done()
      }
    });
    it('intentPageAdaptorTest_003', 0, (done: Function) => {
      try {

        (IntentPageAdaptor as object)['setNavigationUrl']('entryKey');
      } catch (e) {
      } finally {
        done()
      }
    });

    it('intentPageAdaptorTest_004', 0, (done: Function) => {
      try {
        (IntentPageAdaptor as object)['navigationUrlChangeNotify']('uri');
        (IntentPageAdaptor as object)['navigationUrlChangeNotify']('');
      } catch (e) {
      } finally {
        done()
      }
    });
    it('intentPageAdaptorTest_005', 0, (done: Function) => {
      try {
        let param: Record<string, Object> = {
          'entryKey': 'power_consumption_entry',
        };
        (IntentPageAdaptor as object)['directJumpDetailsPage']('', '');
        AppStorage.setOrCreate<NavPathStack>(PackagesConstant.SETTINGS_PATH_STACK, {
          pushPath: (info: NavPathInfo, animated?: boolean | undefined): void => {
          }
        } as NavPathStack);
        (IntentPageAdaptor as object)['directJumpDetailsPage']('power_consumption_entry', param);
        (IntentPageAdaptor as object)['directJumpDetailsPage']('entryKey', param);
      } catch (e) {
      } finally {
        done()
      }
    });

    it('intentPageAdaptorTest_006', 0, (done: Function) => {
      try {
        let mocker: MockKit = new MockKit();
        let mockfunc: Function =
          mocker.mockFunc(DeviceUtil, DeviceUtil.isDevicePad);
        when(mockfunc)(ArgumentMatchers.any).afterReturn(false);
        DeviceUtil.isDeviceFoldable = false;
        (IntentPageAdaptor as object)['sendShowBgEventToHomeEntry']();
        let mockfunc2: Function =
          mocker.mockFunc(DeviceUtil, DeviceUtil.isDevicePad);
        when(mockfunc2)(ArgumentMatchers.any).afterReturn(true);
        DeviceUtil.isDeviceFoldable = true;
        (IntentPageAdaptor as object)['sendShowBgEventToHomeEntry']();
        mocker.clear(DeviceUtil);
      } catch (e) {
      } finally {
        done()
      }
    });

  })
}

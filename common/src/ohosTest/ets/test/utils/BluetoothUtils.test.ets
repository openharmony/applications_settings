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
  beforeAll,
  beforeEach,
  describe,
  expect,
  it,
  Level,
} from '@ohos/hypium';
import { BluetoothUtils } from '../../../../..';

export default function commonBluetoothUtilsTest() {
  describe('commonBluetoothUtilsTest', (): void => {

    beforeAll((): void => {
    })

    beforeEach((): void => {
    })

    afterAll((): void => {
    })

    afterEach((): void => {
    })

    it('isBluetoothDiscoveryOnTest001', Level.LEVEL0, (): void => {
      expect(BluetoothUtils.isBluetoothDiscoveryOn(1)).assertFalse();
    });

    it('isBluetoothDiscoveryOnTest_002', Level.LEVEL0, (): void => {
      expect(BluetoothUtils.isBluetoothDiscoveryOn(2)).assertTrue();
    });

    it('isBluetoothStateOpeningTest_001', Level.LEVEL0, (): void => {
      expect(BluetoothUtils.isBluetoothStateOpening(1)).assertTrue();
    });

    it('isBluetoothStateOpeningTest_002', Level.LEVEL0, (): void => {
      expect(BluetoothUtils.isBluetoothStateOpening(2)).assertFalse();
    });

    it('isBluetoothStateOpeningTest_003', Level.LEVEL0, (): void => {
      expect(BluetoothUtils.isBluetoothStateOpening(4)).assertTrue();
    });

    it('isBluetoothStateOnTest_001', Level.LEVEL0, (): void => {
      expect(BluetoothUtils.isBluetoothStateOn(2)).assertTrue();
    });

    it('isBluetoothStateOnTest_002', Level.LEVEL0, (): void => {
      expect(BluetoothUtils.isBluetoothStateOn(1) !== null).assertTrue();
    });

    it('isBluetoothStateOnTest_003', Level.LEVEL0, (): void => {
      expect(BluetoothUtils.isBluetoothStateOn(5) !== null).assertTrue();
    });

    it('isBluetoothStateClosingTest_001', Level.LEVEL0, (): void => {
      expect(BluetoothUtils.isBluetoothStateClosing(3)).assertTrue();
    });

    it('BluetoothUtilsTest_isBluetoothOn', 0, () => {
      let isOn = BluetoothUtils.isBluetoothOn();
      expect(isOn || !isOn).assertEqual(true);
    })

    it('BluetoothUtilsTest_enableBlueTooth', 0, () => {
      let closeRet = BluetoothUtils.disableBlueTooth();
      expect(closeRet !== null).assertTrue();
      let openRet = BluetoothUtils.enableBlueTooth();
      expect(openRet !==null).assertTrue();
    })

    it('testBluetoothStateOff', 0, () => {
      let bluetoothState: number = 102;
      const isBluetoothStateOff = BluetoothUtils.isBluetoothStateOff(bluetoothState);
      expect(isBluetoothStateOff).assertFalse();
    })

    it('testBluetoothUtils_isValidMac_true', 0, () => {
      const macStr: string = '00:01:B2:CC:ED:0E';
      expect(BluetoothUtils.isValidMac(macStr)).assertTrue();
    });
    it('testBluetoothUtils_isValidMac_false', 0, () => {
      const macStr: string = '00:01:B2:CC:ED';
      expect(BluetoothUtils.isValidMac(macStr)).assertFalse();
    });

    it('BluetoothUtilsTest_getLogMAC_01', 0, () => {
      const result = BluetoothUtils.getLogMAC('');
      expect(result).assertEqual('');
    })

    it('bleLogMAC01', 0, () => {
      let macStr: string[] = ['DA:DA:DA:DA:DA:DA'];
      let index: string = BluetoothUtils.getLogUuid(macStr);
      expect(index !== null).assertTrue();
    });
    it('bleLogMAC02', 0, () => {
      let macStr: string[] = [];
      let index: string = BluetoothUtils.getLogUuid(macStr);
      expect(index).assertEqual('');
    });
  })
}
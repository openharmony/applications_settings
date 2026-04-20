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
import { describe, it, expect } from '@ohos/hypium'
import { PairDialogController } from '../../../../main/ets/Setting/Bluetooth/dialog/controller/PairDialogController';

export default function PairDialogControllerTest() {
  describe('PairDialogControllerTest', () => {
    it("PairDialogControllerTest_001", 0, () => {
      let pdcCon: PairDialogController = new PairDialogController(2);
      expect(pdcCon !== null).assertTrue();
      let deviceId: string = 'XX:XX:XX:XX:XX:XX';
      pdcCon.init(deviceId);
      expect(pdcCon.deviceName !== null).assertTrue();
      pdcCon = new PairDialogController(5);
      expect(pdcCon !== null).assertTrue();
      pdcCon.init(deviceId);
      expect(pdcCon.deviceName !== null).assertTrue();

      for (let i = 0; i < 8; i++) {
        let pdcC: PairDialogController = new PairDialogController(i);
        pdcC.onPairClick(deviceId, true);
        pdcC.onPairClick(deviceId, false);
        pdcC.onCancelClick(deviceId);
        expect(pdcC !== null).assertTrue();
      }
    })
  })
}
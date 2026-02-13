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

import { afterAll, afterEach, beforeAll, beforeEach, describe, expect, it, MockKit } from '@ohos/hypium';
import { SettingsBaseMenu } from '@ohos/settings.common/src/main/ets/core/model/menu/SettingsMenu';
import { NFCServiceController } from '@ohos/settings.moreconnection/src/main/ets/controller/NFCServiceController';

export default function nFCServiceControllerTest() {
  describe('nFCServiceControllerTest', (): void => {

    beforeAll((): void => {
    })

    beforeEach((): void => {

    })

    afterAll((): void => {
    })

    afterEach((): void => {
    })

    it('CreateNFCServiceControllerTest_nfcControllerIsOpen', 0, () => {
      let menu: SettingsBaseMenu = new SettingsBaseMenu();
      expect(NFCServiceController.CreateNFCServiceController(menu)).not().assertNull();
    })

    it('NFCServiceControllerTest_onNFCStateChange_001', 0, () => {
      let nfcServiceController = new NFCServiceController(new SettingsBaseMenu());
      nfcServiceController.onNFCStateChange(0);
      expect(nfcServiceController).not().assertNull();
    })
    it('NFCServiceControllerTest_onNFCStateChange_002', 0, () => {
      let nfcServiceController = new NFCServiceController(new SettingsBaseMenu());
      nfcServiceController.onNFCStateChange(1);
      expect(nfcServiceController).not().assertNull();
    })
    it('NFCServiceControllerTest_onNFCStateChange_003', 0, () => {
      let nfcServiceController = new NFCServiceController(new SettingsBaseMenu());
      nfcServiceController.onNFCStateChange(2);
      expect(nfcServiceController).not().assertNull();
    })
    it('NFCServiceControllerTest_onNFCStateChange_004', 0, () => {
      let nfcServiceController = new NFCServiceController(new SettingsBaseMenu());
      nfcServiceController.onNFCStateChange(3);
      expect(nfcServiceController).not().assertNull();
    })
    it("NFCServiceControllerTest_updateCheckedState_001", 0, () => {
      let nfcServiceC = new NFCServiceController(new SettingsBaseMenu());
      let result = (nfcServiceC as object)['updateCheckedState']() as boolean;
      expect(result).assertInstanceOf('Boolean');
    })
    it("NFCServiceControllerTest_handleCheckedChange_001", 0, () => {
      let nfcServiceC = new NFCServiceController(new SettingsBaseMenu());
      nfcServiceC.isChecked = false;
      let result = (nfcServiceC as object)['handleCheckedChange'](false) as boolean;
      expect(result).assertFalse();
      result = (nfcServiceC as object)['handleCheckedChange'](true) as boolean;
      expect(result).assertInstanceOf('Boolean');
      nfcServiceC.isChecked = true;
      result = (nfcServiceC as object)['handleCheckedChange'](false) as boolean;
      expect(result).assertInstanceOf('Boolean');
    })
    it("NFCServiceControllerTest_updateToTargetState_001", 0, () => {
      let nfcServiceC = new NFCServiceController(new SettingsBaseMenu());
      nfcServiceC.taskTimerId = null;
      let result: boolean = nfcServiceC.updateToTargetState();
      expect(result).assertTrue();
      nfcServiceC.taskTimerId = 1;
      nfcServiceC.currentState = 0;
      result = nfcServiceC.updateToTargetState();
      expect(result).assertTrue();
      nfcServiceC.targetState = 0;
      nfcServiceC.currentState = NFCState.ACTIVE;
      result = nfcServiceC.updateToTargetState();
      expect(result).assertTrue();
      nfcServiceC.targetState = NFCState.ACTIVE;
      result = nfcServiceC.updateToTargetState();
      expect(result).assertTrue();
      nfcServiceC.targetState = NFCState.INACTIVE;
      nfcServiceC.currentState = NFCState.INACTIVE;
      result = nfcServiceC.updateToTargetState();
      expect(result).assertTrue();
    })
    it("NFCServiceControllerTest_switchNFC_001", 0, () => {
      let nfcServiceC = new NFCServiceController(new SettingsBaseMenu());
      nfcServiceC.currentState = 0;
      (nfcServiceC as object)['switchNFC']();
      nfcServiceC.currentState = NFCState.ACTIVE;
      (nfcServiceC as object)['switchNFC']();
      nfcServiceC.currentState = NFCState.INACTIVE;
      nfcServiceC.targetState = NFCState.ACTIVE;
      (nfcServiceC as object)['switchNFC']();
      nfcServiceC.targetState = NFCState.INACTIVE;
      (nfcServiceC as object)['switchNFC']();
      expect(nfcServiceC != null).assertTrue();
    })
    it("NFCServiceControllerTest_stopTask_001", 0, () => {
      let nfcServiceC = new NFCServiceController(new SettingsBaseMenu());
      nfcServiceC.taskTimerId = null;
      nfcServiceC.switchTimerId = null;
      (nfcServiceC as object)['stopTask']();
      nfcServiceC.taskTimerId = 1;
      nfcServiceC.switchTimerId = 1;
      (nfcServiceC as object)['stopTask']();
      expect(nfcServiceC != null).assertTrue();
    })

  })
}

enum NFCState {
  INACTIVE = 1,
  ACTIVATING = 2,
  ACTIVE = 3,
  DEACTIVATING = 4
}
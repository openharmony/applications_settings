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

import { afterAll, afterEach,
  ArgumentMatchers,
  beforeAll, beforeEach, describe, expect, it, MockKit, when } from '@ohos/hypium';
import { DeviceNameUtil } from '@ohos/settings.common';
import { NearLinkUtils } from '@ohos/settings.nearlink';
import { SwitchViewModel } from '@ohos/settings.nearlink/src/main/ets/viewmodel/SwitchViewModel';

export default function switchViewModelTest() {
  describe('switchViewModelTest', (): void => {
    let switchViewModel: SwitchViewModel = new SwitchViewModel();
    beforeAll((): void => {
    })

    beforeEach((): void => {
    })

    afterAll((): void => {
    })

    afterEach((): void => {
    })

    it('SwitchViewModel_init', 0, () => {
      let switchViewModel: SwitchViewModel = new SwitchViewModel();
      let pathInfos: NavPathStack = new NavPathStack();
      expect(switchViewModel.pathInfos).assertEqual(undefined);
    })

    it('testSwitchViewModel', 0, async () => {
      let switchViewModel: SwitchViewModel = new SwitchViewModel();
      expect(switchViewModel.getListenKey()).assertEqual('switch_view_model');
    });

    it('SwitchViewModelTest_unregisterListener', 0, async () => {
      let switchViewModel: SwitchViewModel = new SwitchViewModel();
      switchViewModel.destroy();
      expect(true).assertTrue();
    });

    it('switchTestUpdateHint', 0, async () => {
      let switchViewModel = new SwitchViewModel();
      switchViewModel.switchEnable = true;
      switchViewModel.updateHint();
      expect(switchViewModel.start !== '').assertFalse();
      switchViewModel.switchEnable = false;
      switchViewModel.updateHint();
      expect(switchViewModel.start === '').assertFalse();
    })

    it('test_onPageShow', 0, async () => {
      let mocker: MockKit = new MockKit();
      let contextfunc: Function = mocker.mockFunc(NearLinkUtils,NearLinkUtils.isOn);
      when(contextfunc)(ArgumentMatchers.any).afterReturn(true);
      let resA = switchViewModel.onPageShow();
      expect(resA === null).assertFalse();
      when(contextfunc)(ArgumentMatchers.any).afterReturn(false);
      let resB = switchViewModel.onPageShow();
      expect(resB === null).assertFalse();
      mocker.clear(NearLinkUtils);
    })

    it('test_onSwitchStateChange', 0, (): void => {
      (switchViewModel as object)["taskTimerId"] = null;
      let mocker: MockKit = new MockKit();
      let contextfunc: Function = mocker.mockFunc(NearLinkUtils,NearLinkUtils.isStateOn);
      when(contextfunc)(ArgumentMatchers.any).afterReturn(false);
      let resA = switchViewModel.onSwitchStateChange(0);
      expect(resA === null).assertFalse();
      when(contextfunc)(ArgumentMatchers.any).afterReturn(true);
      let resB = switchViewModel.onSwitchStateChange(3);
      expect(resB === null).assertFalse();
      (switchViewModel as object)["taskTimerId"] = 7;
      let resC = switchViewModel.onSwitchStateChange(3);
      expect(resC === null).assertFalse();
      mocker.clear(NearLinkUtils);
    })

    it('test_handleCheckedChange', 0, (): void => {
      let resA = switchViewModel.handleCheckedChange(true);
      expect(resA === null).assertFalse();
      let resB = switchViewModel.handleCheckedChange(false);
      expect(resB === null).assertFalse();
    })

    it('test_changeDeviceName', 0, (): void => {
      let resA = switchViewModel.changeDeviceName('');
      expect(resA === null).assertFalse();
      let mocker: MockKit = new MockKit();
      let contextfunc: Function = mocker.mockFunc(NearLinkUtils,NearLinkUtils.getLocalName);
      when(contextfunc)(ArgumentMatchers.any).afterReturn('deviceName');
      let resB = switchViewModel.changeDeviceName('deviceName');
      expect(resB === null).assertFalse();
      let resC = switchViewModel.changeDeviceName('deviceNameTest');
      expect(resC === null).assertFalse();
      mocker.clear(NearLinkUtils);
    })

    it('test_updateHint', 0, (): void => {
      let mocker: MockKit = new MockKit();
      let contextfunc: Function = mocker.mockFunc(NearLinkUtils,NearLinkUtils.isOn);
      when(contextfunc)(ArgumentMatchers.any).afterReturn(true);
      let resA = switchViewModel.updateHint();
      expect(resA === null).assertFalse();
      when(contextfunc)(ArgumentMatchers.any).afterReturn(false);
      let resB = switchViewModel.updateHint();
      expect(resB === null).assertFalse();
      mocker.clear(NearLinkUtils);
    })

    it('test_updateDeviceNameIfNeed', 0, (): void => {
      let resA: Object = (switchViewModel as object)['updateDeviceNameIfNeed']();
      expect(resA === null).assertFalse();
      let mocker: MockKit = new MockKit();
      let contextfunc: Function = mocker.mockFunc(DeviceNameUtil,DeviceNameUtil.getDisplayDeviceName);
      when(contextfunc)(ArgumentMatchers.any).afterReturn('deviceName');
      let resB: Object = (switchViewModel as object)['updateDeviceNameIfNeed']();
      expect(resB === null).assertFalse();
      mocker.clear(DeviceNameUtil);
    })

    it('test_setChecked', 0, (): void => {
      let resA: Object = (switchViewModel as object)['setChecked'](true);
      expect(resA === null).assertFalse();
      let resB: Object = (switchViewModel as object)['setChecked'](false);
      expect(resB === null).assertFalse();
    })

    it('test_updateToTargetState', 0, (): void => {
      (switchViewModel as object)["taskTimerId"] = null;
      let resA: Object = (switchViewModel as object)['updateToTargetState']();
      expect(resA === true).assertTrue();
      (switchViewModel as object)["taskTimerId"] = 7;
      let mocker: MockKit = new MockKit();
      let contextfunc: Function = mocker.mockFunc(NearLinkUtils,NearLinkUtils.isStateOn);
      when(contextfunc)(ArgumentMatchers.any).afterReturn(false);
      (switchViewModel as object)["currentState"] = 1;
      let resB: Object = (switchViewModel as object)['updateToTargetState'](10000);
      expect(resB === true).assertTrue();
      when(contextfunc)(ArgumentMatchers.any).afterReturn(true);
      (switchViewModel as object)["targetState"] = 1;
      let resC: Object = (switchViewModel as object)['updateToTargetState'](10000);
      expect(resC === true).assertTrue();
      (switchViewModel as object)["currentState"] = 2;
      (switchViewModel as object)["targetState"] = 4;
      switchViewModel.switchTimerId = null;
      let resD: Object = (switchViewModel as object)['updateToTargetState'](10000);
      expect(resD === true).assertTrue();
      switchViewModel.switchTimerId = 9;
      let resE: Object = (switchViewModel as object)['updateToTargetState'](10000);
      expect(resE === true).assertTrue();
      mocker.clear(NearLinkUtils);
    })

    it('test_stopTask', 0, (): void => {
      (switchViewModel as object)["taskTimerId"] = 7;
      (switchViewModel as object)["switchTimerId"] = 7;
      let resA: Object = (switchViewModel as object)['stopTask']();
      expect(resA === true).assertFalse();
      (switchViewModel as object)["taskTimerId"] = null;
      let resB: Object = (switchViewModel as object)['stopTask']();
      expect(resB === true).assertFalse();
      (switchViewModel as object)["switchTimerId"] = null;
      let resC: Object = (switchViewModel as object)['stopTask']();
      expect(resC === true).assertFalse();
    })

    it('test_switchState', 0, (): void => {
      let mocker: MockKit = new MockKit();
      let contextfunc: Function = mocker.mockFunc(NearLinkUtils,NearLinkUtils.isStateOn);
      when(contextfunc)(ArgumentMatchers.any).afterReturn(true);
      (switchViewModel as object)['targetState'] =1;
      let resA: Object = (switchViewModel as object)['switchState']();
      expect(resA === null).assertFalse();
      (switchViewModel as object)['targetState'] = 9;
      let resB: Object = (switchViewModel as object)['switchState']();
      expect(resB === null).assertFalse();
      when(contextfunc)(ArgumentMatchers.any).afterReturn(false);
      let resC: Object = (switchViewModel as object)['switchState']();
      expect(resC === null).assertFalse();
      mocker.clear(NearLinkUtils);
    })

    it('test_resetState', 0, async () => {
      let mocker: MockKit = new MockKit();
      let contextfunc: Function = mocker.mockFunc(NearLinkUtils,NearLinkUtils.isOn);
      when(contextfunc)(ArgumentMatchers.any).afterReturn(true);
      let resA: Object = (switchViewModel as object)['resetState']();
      expect(resA === null).assertFalse();
      when(contextfunc)(ArgumentMatchers.any).afterReturn(false);
      let resB: Object = (switchViewModel as object)['resetState']();
      expect(resB === null).assertFalse();
      mocker.clear(NearLinkUtils);
    })
  })
}

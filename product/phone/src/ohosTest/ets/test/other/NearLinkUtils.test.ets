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

import { ArgumentMatchers, describe, expect, it, MockKit, when } from '@ohos/hypium';
import { NearLinkUtils } from '@ohos/settings.nearlink';

export default function nearLinkUtilsTest() {
  describe('nearLinkUtilsTest', (): void => {

    it('test_isValidMac', 0, (): void => {
      let resA = NearLinkUtils.isValidMac('');
      expect(resA === false).assertTrue();
      let resB = NearLinkUtils.isValidMac('test');
      expect(resB === false).assertTrue();
    })

    it('test_getLogMAC', 0, (): void => {
      let resA = NearLinkUtils.getLogMAC('');
      expect(resA === '').assertTrue();
      let resB = NearLinkUtils.getLogMAC('AB:AB:AB:AB:AB:37:37');
      expect(typeof resB === 'string').assertTrue();
    })

    it('test_getDeviceIcon', 0, (): void => {
      let resA = NearLinkUtils.getDeviceIcon(1);
      expect(resA === null).assertFalse();
      let resB = NearLinkUtils.getDeviceIcon(2);
      expect(resB === null).assertFalse();
      let resC = NearLinkUtils.getDeviceIcon(3);
      expect(resC === null).assertFalse();
      let resD = NearLinkUtils.getDeviceIcon(7);
      expect(resD === null).assertFalse();
    })

    it('test_getConnectionState', 0, (): void => {
      let resA = NearLinkUtils.getConnectionState('');
      expect(resA === null).assertFalse();
      let resB = NearLinkUtils.getConnectionState('123456789');
      expect(resB === null).assertFalse();
    })

    it('test_getLocalAddress', 0, (): void => {
      let mocker: MockKit = new MockKit();
      let contextfunc: Function = mocker.mockFunc(NearLinkUtils,NearLinkUtils.isOn);
      when(contextfunc)(ArgumentMatchers.any).afterReturn(true);
      let resA = NearLinkUtils.getLocalAddress();
      expect(resA === null).assertFalse();
      when(contextfunc)(ArgumentMatchers.any).afterReturn(false);
      let resB = NearLinkUtils.getLocalAddress();
      expect(resB === null).assertFalse();
      mocker.clear(NearLinkUtils);
    })

    it('test_getDeviceName', 0, (): void => {
      let mocker: MockKit = new MockKit();
      let contextfunc: Function = mocker.mockFunc(NearLinkUtils,NearLinkUtils.isOn);
      when(contextfunc)(ArgumentMatchers.any).afterReturn(true);
      let resA = NearLinkUtils.getDeviceName();
      expect(resA === null).assertFalse();
      when(contextfunc)(ArgumentMatchers.any).afterReturn(false);
      let resB = NearLinkUtils.getDeviceName();
      expect(resB === null).assertFalse();
      mocker.clear(NearLinkUtils);
    })
  })
}


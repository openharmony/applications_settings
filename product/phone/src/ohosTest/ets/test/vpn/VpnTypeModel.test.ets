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
  beforeAll, beforeEach, describe, expect, it, MockKit, when } from '@ohos/hypium'
import { SystemParamUtils } from '@ohos/settings.common'
import { VpnTypeModel } from '@ohos/settings.vpn/src/main/ets/model/VpnTypeModel'

export default function VpnTypeModelTest() {
  describe('VpnTypeModelTest', () => {
    // Defines a test suite. Two parameters are supported: test suite name and test suite function.
    beforeAll(() => {
      // Presets an action, which is performed only once before all test cases of the test suite start.
      // This API supports only one parameter: preset action function.
    })
    beforeEach(() => {
      // Presets an action, which is performed before each unit test case starts.
      // The number of execution times is the same as the number of test cases defined by **it**.
      // This API supports only one parameter: preset action function.
    })
    afterEach(() => {
      // Presets a clear action, which is performed after each unit test case ends.
      // The number of execution times is the same as the number of test cases defined by **it**.
      // This API supports only one parameter: clear action function.
    })
    afterAll(() => {

    })
    it('test_vpnType', 0, () => {
      let mocker: MockKit = new MockKit();
      let mockFunc: Function = mocker.mockFunc(SystemParamUtils, SystemParamUtils.getSystemParam)
      let types = [VpnTypeModel.TYPE_IKEV2_IPSEC_MSCHAPv2,
        VpnTypeModel.TYPE_IKEV2_IPSEC_PSK,
        VpnTypeModel.TYPE_IKEV2_IPSEC_RSA,
        VpnTypeModel.TYPE_L2TP_IPSEC_PSK,
        VpnTypeModel.TYPE_L2TP_IPSEC_RSA,
        VpnTypeModel.TYPE_IPSEC_XAUTH_PSK,
        VpnTypeModel.TYPE_IPSEC_XAUTH_RSA,
        VpnTypeModel.TYPE_IPSEC_HYBRID_RSA,
        VpnTypeModel.TYPE_OPENVPN,
        -1
      ]
      when(mockFunc)(ArgumentMatchers.any).afterReturn(types.join(','))
      let typeModel1 = VpnTypeModel.getInstance()
      let typeModel2 = VpnTypeModel.getInstance()
      expect(typeModel1 === typeModel2).assertTrue()
      typeModel2.getSupportVpnTypeStrs()
      typeModel2.getVpnTypeStr(-1)
      typeModel2.getSupportVpnTypes()
      expect(typeModel2.isSupportVpn()).assertTrue()
      mocker.clear(SystemParamUtils);
    })
    it('test_vpnType1', 0, () => {
      let mocker: MockKit = new MockKit();
      let mockFunc: Function = mocker.mockFunc(SystemParamUtils, SystemParamUtils.getSystemParam)
      when(mockFunc)(ArgumentMatchers.any).afterReturn('')
      let instance = new VpnTypeModel()
      expect(instance.isSupportVpn()).assertFalse()
      mocker.clear(SystemParamUtils);
    })
    it('test_vpnType2', 0, () => {
      let mocker: MockKit = new MockKit();
      let mockFunc: Function = mocker.mockFunc(SystemParamUtils, SystemParamUtils.getSystemParam)
      when(mockFunc)(ArgumentMatchers.any).afterThrow('error')
      let instance = new VpnTypeModel()
      expect(instance.isSupportVpn()).assertFalse()
      mocker.clear(SystemParamUtils);
    })
  })
}
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
import { afterAll, afterEach, beforeAll, beforeEach, describe, expect, it } from '@ohos/hypium'
import VpnConfig from '@ohos/settings.vpn/src/main/ets/model/VpnConfig'
import { VpnConnectModel } from '@ohos/settings.vpn/src/main/ets/model/VpnConnectModel'
import common from '@ohos.app.ability.common'
import VpnConstant from '@ohos/settings.vpn/src/main/ets/model/VpnConstant'

export default function VpnConnectModelTest() {
  describe('VpnConnectModelTest', () => {
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
      // Presets a clear action, which is performed after all test cases of the test suite end.
      // This API supports only one parameter: clear action function.
    })
    it('test_vpnConnect', 0, async (done : Function) => {
      let connect1 = VpnConnectModel.getInstance()
      let connect2 = VpnConnectModel.getInstance()
      expect(connect1 === connect2).assertTrue()
      let res = true
      try {
        let context: common.UIAbilityContext | undefined = undefined
        connect2.init(context)
        context = AppStorage.get<Context>('pageContext') as common.UIAbilityContext
        connect2.init(context)
        let config: VpnConfig | undefined = undefined
        connect2.setReplaceConnectVpn(config)
        connect2.onConnectStateChange(true)
        connect2.onConnectStateChange(false)
        await connect2.setUp(config)
        config = new VpnConfig()
        connect2.setReplaceConnectVpn(config)
        await connect2.setUp(config)
        connect2.onConnectStateChange(false)
        let vpnID =  'ssVpn1'
        config.vpnId = vpnID
        await connect2.setUp(config)
        connect2.onConnectStateChange(false)
        connect2.setConnectState(VpnConstant.VPN_STATE_CONNECTING, vpnID)
        connect2.onConnectStateChange(false)
        connect2.setConnectState(VpnConstant.VPN_STATE_DISCONNECTING, vpnID)
        connect2.onConnectStateChange(false)
        {
          let isConnecting = connect2.isConnecting('')
          expect(isConnecting).assertFalse()
          isConnecting = connect2.isConnecting(vpnID)
          expect(isConnecting).assertFalse()
          connect2.setConnectState(VpnConstant.VPN_STATE_CONNECTING, vpnID)
          isConnecting = connect2.isConnecting(vpnID)
          expect(isConnecting).assertTrue()
        }
        {
          let isConnectedOrConnecting = connect2.isConnectedOrConnecting('')
          expect(isConnectedOrConnecting).assertFalse()
          connect2.setConnectState(VpnConstant.VPN_STATE_DISCONNECTING, vpnID)
          isConnectedOrConnecting = connect2.isConnecting(vpnID)
          expect(isConnectedOrConnecting).assertFalse()
          connect2.setConnectState(VpnConstant.VPN_STATE_CONNECTING, vpnID)
          isConnectedOrConnecting = connect2.isConnecting(vpnID)
          expect(isConnectedOrConnecting).assertTrue()
          connect2.setConnectState(VpnConstant.VPN_STATE_CONNECTED, vpnID)
          isConnectedOrConnecting = connect2.isConnecting(vpnID)
          expect(isConnectedOrConnecting).assertFalse()
        }

      } catch (e) {
        res = false
      } finally {
        expect(res).assertTrue()
        done()
      }
    })
  })
}
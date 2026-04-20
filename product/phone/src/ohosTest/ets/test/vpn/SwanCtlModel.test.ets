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
import { SwanCtlModel } from '@ohos/settings.vpn/src/main/ets/model/SwanCtlModel'
import common from '@ohos.app.ability.common'
import { IpsecVpnConfig } from '@ohos/settings.vpn/src/main/ets/model/VpnConfig'
import { VpnTypeModel } from '@ohos/settings.vpn/src/main/ets/model/VpnTypeModel'

export default function SwanCtlModelTest() {
  describe('SwanCtlModelTest', () => {
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
    it('test_SwanCtlModel', 0, () => {
      let model1 = SwanCtlModel.getInstance()
      let model2 = SwanCtlModel.getInstance()
      expect(model1 == model2).assertTrue()
      let res = true
      try {
        let context: common.UIAbilityContext | undefined = undefined
        model2.init(context)
        context = AppStorage.get<Context>('pageContext') as common.UIAbilityContext
        model2.init(context)
        let config : IpsecVpnConfig | undefined = undefined
        model2.buildConfig(config)
        config = new IpsecVpnConfig()
        model2.buildConfig(config)
        config.vpnType = VpnTypeModel.TYPE_L2TP_IPSEC_PSK
        model2.buildConfig(config)
        config.vpnType = VpnTypeModel.TYPE_L2TP_IPSEC_RSA
        model2.buildConfig(config)
      } catch (e) {
        res = false
      } finally {
        expect(res).assertTrue()
      }
    })
  })
}
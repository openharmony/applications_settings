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
import { describe, beforeAll, beforeEach, afterEach, afterAll, it, expect } from '@ohos/hypium'
import { WlanItemModel } from '@ohos/settings.wifi/src/main/ets/model/WlanItemModel'
import { WifiPasswordConfigManager } from '@ohos/settings.wifi/src/main/ets/WifiPasswordConfigManager'
import { wifiManager } from '@kit.MDMKit'

export default function WifiPasswordConfigManagerTest() {
  describe('WifiPasswordConfigManagerTest', () => {
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
    it('test_WifiPasswordConfigManager', 0, () => {
      let manager1 = WifiPasswordConfigManager.getInstance()
      let manager2 = WifiPasswordConfigManager.getInstance()
      expect(manager1 === manager2).assertTrue()
      manager2.setPreSharedKey('shareKey')
      manager2.connectToWifiDevice()
      {
        let wlanItem: WlanItemModel = {
          id: '',
          wlanName: '',
          isHiLinkNetwork: false,
          capabilities: '',
          type: 0,
        }
        let config = manager2.getDefaultWifiConfig(wlanItem)
        config.ipType = wifiManager.IpType.STATIC
        manager2.initConfig(config,wlanItem)
        manager2.connectToWifiDevice()
        manager2.clearAndGetFormattedConfig(config)
        expect(config.bssid).assertUndefined()
      }
      {
        let wlanItem: WlanItemModel = {
          id: '',
          wlanName: '',
          securityType: wifiManager.WifiSecurityType.WIFI_SEC_TYPE_WEP,
          isHiLinkNetwork: false,
          capabilities: '',
          type: 0,
        }
        manager2.initConfig(manager2.getDefaultWifiConfig(wlanItem))
        manager2.connectToWifiDevice()
        manager2.initConfig(manager2.getDefaultWifiConfig(wlanItem))
        if (manager2.getConfig()) {
          manager2.clearAndGetFormattedConfig(manager2.getConfig()!)
        }
      }
      {
        let wlanItem: WlanItemModel = {
          id: '',
          wlanName: '',
          securityType: wifiManager.WifiSecurityType.WIFI_SEC_TYPE_WAPI_PSK,
          isHiLinkNetwork: false,
          capabilities: '',
          type: 0,
        }
        let config = manager2.getDefaultWifiConfig(wlanItem)
        manager2.initConfig(config,wlanItem)
        manager2.setPreSharedKey('shareKey')
        manager2.connectToWifiDevice()
        manager2.initConfig(config)
        manager2.clearAndGetFormattedConfig(config)
        expect(config.bssid).assertUndefined()
      }
      manager2.clearConfig()
    })
  })
}
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
import VpnConfig, { IpsecVpnConfig, OpenVpnConfig } from '@ohos/settings.vpn/src/main/ets/model/VpnConfig'
import { VpnCertItem, VpnConfigModel } from '@ohos/settings.vpn/src/main/ets/model/VpnConfigModel'
import VpnConstant from '@ohos/settings.vpn/src/main/ets/model/VpnConstant'
import { VpnTypeModel } from '@ohos/settings.vpn/src/main/ets/model/VpnTypeModel'

export default function VpnConfigModelTest() {
  describe('VpnConfigModelTest', () => {
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
    it('test_UpdateVpnList', 0, () => {
      let configModel = VpnConfigModel.getInstance()
      configModel.setNeedUpdateVpnList(true)
      expect(configModel.isUpdateVpnList()).assertTrue()
      configModel.setNeedUpdateVpnList(false)
      expect(configModel.isUpdateVpnList()).assertFalse()
    })
    it('test_address', 0, () => {
      let configModel1 = VpnConfigModel.getInstance()
      let configModel2 = VpnConfigModel.getInstance()
      expect(configModel1 == configModel2).assertTrue()
      let vpnAddress = 'https://12.25.285.255.feiaf'
      let config1: VpnConfig | undefined = undefined
      let config2 = new VpnConfig()
      let config3 = new VpnConfig()
      configModel2.setAddress(config1,vpnAddress)
      configModel2.setAddress(config2,vpnAddress)
      configModel2.showToast('')
      configModel2.showToast(vpnAddress)
      expect(configModel2.getAddress(config1)).assertUndefined()
      expect(configModel2.getAddress(config2)).assertEqual(vpnAddress)
      expect(configModel2.getAddress(config3)).assertUndefined()
    })
    it('test_inflateConfigFromFileData', 0, () => {
      let res = true
      try {
        let configModel = VpnConfigModel.getInstance()
        let config: OpenVpnConfig | undefined = undefined
        let data: string[] | undefined = undefined
        configModel.inflateConfigFromFileData(config,data)
        config = new OpenVpnConfig()
        configModel.inflateConfigFromFileData(config,data)
        data = ['path', 'content']
        configModel.inflateConfigFromFileData(config,data)
        data = ['path', 'content\nproto tcp']
        configModel.inflateConfigFromFileData(config,data)
        data = ['path', 'content\nproto udp']
        configModel.inflateConfigFromFileData(config,data)
        data = ['path', 'content\nremote 192.168.1.1 8080']
        configModel.inflateConfigFromFileData(config,data)
        data = ['path', 'content\n<ca>ca_cert_content</ca>']
        configModel.inflateConfigFromFileData(config,data)
        data = ['path', 'content\n<cert>user_cert_content</cert>']
        configModel.inflateConfigFromFileData(config,data)
        data = ['path', 'content\n<key>private_key_content</key>']
        configModel.inflateConfigFromFileData(config,data)
      } catch (e) {
        res = false
      } finally {
        expect(res).assertTrue()
      }
    })
    it('test_inflateConfigFromContent', 0, () => {
      let res = true
      try {
        let configModel = VpnConfigModel.getInstance()
        let config: OpenVpnConfig | undefined = undefined
        let data: string[] | undefined = undefined
        configModel.inflateConfigFromContent(config,'')
        config = new OpenVpnConfig()
        configModel.inflateConfigFromContent(config,'')
        configModel.inflateConfigFromContent(config, '<auth-user-pass>\nuser123\npass456\n</auth-user-pass>')
        configModel.inflateConfigFromContent(config, 'http-proxy proxy.example.com 8080')
        let text = "<http-proxy-user-pass>\n" +
          "User: user1\n" +
          "name: name1\n" +
          "Password: p@ssw0rd\n" +
          "Proxy: proxy.example.com\n" +
          "</http-proxy-user-pass>";
        configModel.inflateConfigFromContent(config, text)
      } catch (e) {
        res = false
      } finally {
        expect(res).assertTrue()
      }
    })
    it('test_prepareAddSysVpnConfig', 0, () => {
      let res = true
      try {
        let configModel = VpnConfigModel.getInstance()
        let config: VpnConfig | undefined = undefined
        configModel.prepareAddSysVpnConfig(config)
        config = new OpenVpnConfig()
        config.vpnType = VpnTypeModel.TYPE_OPENVPN
        configModel.prepareAddSysVpnConfig(config)
        config = new IpsecVpnConfig()
        config.vpnType = VpnTypeModel.TYPE_IKEV2_IPSEC_PSK
        configModel.prepareAddSysVpnConfig(config)
        let ipsecConfig: VpnConfig | undefined = undefined
        configModel.prepareIpsecConfig(ipsecConfig)
      } catch (e) {
        res = false
      } finally {
        expect(res).assertTrue()
      }
    })
    it('test_prepareOvpnConfig', 0, () => {
      let res = true
      try {
        let configModel = VpnConfigModel.getInstance()
        let config: OpenVpnConfig | undefined = undefined
        configModel.prepareOvpnConfig(config)
        config = new OpenVpnConfig()
        configModel.prepareOvpnConfig(config)
        config.ovpnConfigContent = 'client\nrelease tun'
        configModel.prepareOvpnConfig(config)
        config.ovpnConfig = 'ovpnConfig'
        configModel.prepareOvpnConfig(config)
        config.ovpnProtocol = 0
        config.ovpnProtocolFileRaw = 'proto udp'
        configModel.prepareOvpnConfig(config)
        config.ovpnProtocol = 1
        configModel.prepareOvpnConfig(config)
        let vpnAddress = 'https://12.25.285.255.feiaf'
        configModel.setAddress(config,vpnAddress)
        configModel.prepareOvpnConfig(config)
        config.ovpnPort = '8080'
        let addressPortReplace: string = `remote ${vpnAddress} ${config.ovpnPort}`
        configModel.prepareOvpnConfig(config)
        config.ovpnAddressPortFileRaw = addressPortReplace
        configModel.prepareOvpnConfig(config)
      } catch (e) {
        res = false
      } finally {
        expect(res).assertTrue()
      }
    })
    it('test_getCAList', 0, async (done : Function) => {
      let configModel = VpnConfigModel.getInstance()
      let items = await configModel.getCAList()
      expect(items.length == 0).assertTrue()
      done()
    })
    it('test_getSystemAppCertList', 0, async (done : Function) => {
      let configModel = VpnConfigModel.getInstance()
      let items = await configModel.getSystemAppCertList()
      expect(items.length == 0).assertTrue()
      done()
    })
  })
}
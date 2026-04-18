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
  describe,
  it,
  expect,
  TestType,
  MockKit } from '@ohos/hypium';
import ethernet from '@ohos.net.ethernet';
import { EthernetUtil } from '@ohos/settings.network/src/main/ets/util/EthernetUtil';
import {
  IEthernetInterfaceInfo
} from '@ohos/settings.network/src/main/ets/model/IEthernetInterfaceInfo';
import { LogUtil } from '@ohos/settings.common/src/main/ets/utils/LogUtil';

let failIfcName: string = 'eth1';
let ifcInfo: IEthernetInterfaceInfo = {
  mode: 0,
  ipAddr: "127.0.0.1",
  route: "",
  netMask: "",
  gateway: "",
  dnsServers: "",
  dns0: "",
  dns1: "",
  domain: "",
  errorInputKeys: []
};

export default function EthernetUtilTest() {

  describe('EthernetUtilTest', () => {
    /**
     * @tc.number: EthernetUtilTest_000
     * @tc.name: isVarStringType
     * @tc.type: TestType.FUNCTION
     * @tc.desc: 检查string变量是否合法
     */
    it('EthernetUtilTest_000', TestType.FUNCTION, () => {
      let a = 'test';
      expect(EthernetUtil.isVarStringType(a)).assertTrue();
      LogUtil.info('Print Test');
    });

    /**
     * @tc.number: EthernetUtilTest_001
     * @tc.name: isVarStringType
     * @tc.type: TestType.FUNCTION
     * @tc.desc: 检查string变量是否合法
     */
    it('EthernetUtilTest_001', TestType.FUNCTION, () => {
      let b = '';
      expect(EthernetUtil.isVarStringType(b)).assertFalse();
      LogUtil.info('Wrong data');
    });

    /**
     * @tc.number: EthernetUtilTest_002
     * @tc.name: updateEthernetIfcConfig
     * @tc.type: TestType.FUNCTION
     * @tc.desc: 更新以太网接口配置
     */
    it('EthernetUtilTest_002', TestType.FUNCTION, () => {
      let mocker: MockKit = new MockKit();
      mocker.mockFunc(EthernetUtil, EthernetUtil.updateEthernetIfcConfig);
      // 修改以太网接口配置
      EthernetUtil.updateEthernetIfcConfig(failIfcName, ifcInfo, (): void => {
        // 检查方法是否调用过
        LogUtil.info('Success data');
        mocker.verify('updateEthernetIfcConfig', [failIfcName, ifcInfo]).atLeast(1);
      });
    });

    /**
     * @tc.number: EthernetUtilTest_003
     * @tc.name: updateEthernetIfcConfig
     * @tc.type: TestType.FUNCTION
     * @tc.desc: 更新以太网接口配置
     */
    it('EthernetUtilTest_003', TestType.FUNCTION, () => {
      let mocker: MockKit = new MockKit();
      mocker.mockFunc(EthernetUtil, EthernetUtil.updateEthernetIfcConfig);
      EthernetUtil.updateEthernetIfcConfig(failIfcName, null, (): void => {}, (): void => {
        // 检查方法是否调用过
        LogUtil.info('Wrong data');
        mocker.verify('updateEthernetIfcConfig', [failIfcName, null]).atLeast(1);
      });
    })

    /**
     * @tc.number: EthernetUtilTest_004
     * @tc.name: getEthernetInterfaceConfig
     * @tc.type: TestType.FUNCTION
     * @tc.desc: 获取以太网接口配置
     */
    it('EthernetUtilTest_004', TestType.FUNCTION, () => {
      // 获取以太网接口配置
      EthernetUtil.getEthernetInterfaceConfig(failIfcName, (data: ethernet.InterfaceConfiguration) => {
        LogUtil.info(`getEthernetInterfaceConfig failIfcName: ${failIfcName}, data: ${data}`);
        expect(data !== undefined).assertTrue();
      });
    })

    /**
     * @tc.number: EthernetUtilTest_005
     * @tc.name: getEthernetInterfaceConfig
     * @tc.type: TestType.FUNCTION
     * @tc.desc: 获取以太网接口配置
     */
    it('EthernetUtilTest_005', TestType.FUNCTION, () => {
      // 获取以太网接口配置
      EthernetUtil.getEthernetInterfaceConfig('', (data: ethernet.InterfaceConfiguration) => {
        LogUtil.info(`getEthernetInterfaceConfig, data: ${data}`);
        expect(data === undefined).assertTrue();
      });
    })

    /**
     * @tc.number: EthernetUtilTest_006
     * @tc.name: updateActiveIface
     * @tc.type: TestType.FUNCTION
     * @tc.desc: 更新网口数据
     */
    it('EthernetUtilTest_006', TestType.FUNCTION, () => {
      EthernetUtil.updateActiveIface();
      expect(AppStorage.get('iFaceData') === undefined).assertTrue();
    })

    /**
     * @tc.number: EthernetUtilTest_007
     * @tc.name: registerInterfaceStateListener
     * @tc.type: TestType.FUNCTION
     * @tc.desc: 注册网口监听
     */
    it('EthernetUtilTest_007', TestType.FUNCTION, () => {
      EthernetUtil.registerInterfaceStateListener();
      expect(AppStorage.get('iFaceData') !== null).assertTrue();
    })

    /**
     * @tc.number: EthernetUtilTest_008
     * @tc.name: isEthernetNetworkValidated
     * @tc.type: TestType.FUNCTION
     * @tc.desc: 有线网络是否可用
     */
    it('EthernetUtilTest_008', TestType.FUNCTION, () => {
      let isValidated: boolean = EthernetUtil.isEthernetNetworkValidated();
      expect(isValidated !== true).assertTrue();
    })

    /**
     * @tc.number: EthernetUtilTest_009
     * @tc.name: isEthernetDetailViewShow
     * @tc.type: TestType.FUNCTION
     * @tc.desc: 判断以太网详细面板是否显示
     */
    it('EthernetUtilTest_009', TestType.FUNCTION, () => {
      let isShow: boolean = EthernetUtil.isEthernetDetailViewShow();
      expect(isShow === false).assertTrue();
    })

    /**
     * @tc.number: EthernetUtilTest_010
     * @tc.name: isEthernetAdvancedSettingsEnable
     * @tc.type: TestType.FUNCTION
     * @tc.desc: 判断高级设置是否禁用
     */
    it('EthernetUtilTest_010', TestType.FUNCTION, () => {
      let isShow: boolean = EthernetUtil.isEthernetAdvancedSettingsEnable();
      expect(isShow).assertInstanceOf('Boolean');
    })

    /**
     * @tc.number: EthernetUtilTest_011
     * @tc.name: useNewNetworkPage
     * @tc.type: TestType.FUNCTION
     * @tc.desc: 判断是否使用新网络页面
     */
    it('EthernetUtilTest_011', TestType.FUNCTION, () => {
      let result: boolean = EthernetUtil.useNewNetworkPage();
      expect(result).assertInstanceOf('Boolean');
    })
  })
}
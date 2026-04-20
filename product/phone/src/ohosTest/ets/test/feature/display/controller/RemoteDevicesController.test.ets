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
 
import { describe, it, expect, MockKit, when, ArgumentMatchers } from '@ohos/hypium'
import {
  RemoteDevicesController,
  RemoteDeviceStub
} from '@ohos/settings.display/src/main/ets/controller/RemoteDevicesController'
import rpc from '@ohos.rpc'
import { RemoteDeviceInfo } from '@ohos/settings.display/src/main/ets/utils/DeviceUtil'
import { DisplayCommonUtils } from '@ohos/settings.display/src/main/ets/utils/DisplayCommonUtils'
import DeviceInfo, {
  DeviceDisplayType,
  DevicesController
} from '@ohos/settings.display/src/main/ets/controller/DevicesController'
import screen from '@ohos.screen'

export default function RemoteDevicesControllerTest() {
  describe('RemoteDevicesControllerTest', () => {
    it('RemoteDevicesControllerTest_RemoteDeviceStub_001', 0, async (done: Function) => {
      let remoteDeviceS: RemoteDeviceStub = new RemoteDeviceStub('RemoteDeviceService')
      let data: rpc.MessageSequence = rpc.MessageSequence.create()
      let options: rpc.MessageOption = new rpc.MessageOption()
      let result = await remoteDeviceS.onRemoteMessageRequest(0, data, data, options)
      expect(result).assertEqual(false)
      done()
    })
    it('RemoteDevicesControllerTest_getRemoteDeviceByDeviceId_001', 0, () => {
      let remoteDevicesC: RemoteDevicesController = RemoteDevicesController.getInstance()
      remoteDevicesC.getRemoteDeviceByDeviceId('testId')
      let result = remoteDevicesC.getRemoteDeviceByDeviceId(0)
      expect(result).assertEqual(undefined)
    })
    it('RemoteDevicesControllerTest_saveDevicePosition_001', 0, () => {
      let remoteDevicesC: RemoteDevicesController = RemoteDevicesController.getInstance()
      let deviceOrderA: Array<string | number> = []
      remoteDevicesC.saveDevicePosition(deviceOrderA)
      let mocker: MockKit = new MockKit()
      let devicesC: DevicesController = DevicesController.getInstance()
      let devicesCMockFun: Function = mocker.mockFunc(devicesC, devicesC.getOtherDeviceCount)
      when(devicesCMockFun)().afterReturn(0)
      remoteDevicesC.saveDevicePosition(deviceOrderA)
      let remoteDevice: RemoteDeviceInfo = new RemoteDeviceInfo('testDeviceName', 'testDeviceId', 'testNetworkId', 0)
      remoteDevicesC.refreshRemoteDevices('')
      let mockFun: Function = mocker.mockFunc(DisplayCommonUtils, DisplayCommonUtils.parseString)
      when(mockFun)(ArgumentMatchers.any).afterReturn([remoteDevice])
      remoteDevicesC.refreshRemoteDevices('')
      when(devicesCMockFun)().afterReturn(1)
      deviceOrderA = ['testDeviceId']
      remoteDevicesC.saveDevicePosition(deviceOrderA)
      remoteDevice.isLocalDevice = true
      when(mockFun)(ArgumentMatchers.any).afterReturn([remoteDevice])
      remoteDevicesC.refreshRemoteDevices('')
      when(devicesCMockFun)().afterReturn(1)
      remoteDevicesC.saveDevicePosition(deviceOrderA)
      expect(remoteDevicesC != null).assertTrue()
      mocker.clear(DisplayCommonUtils)
      mocker.clear(devicesC)
    })
    it("RemoteDevicesControllerTest_startKeyMoueService_001", 0, () => {
      let remoteDevicesC: RemoteDevicesController = RemoteDevicesController.getInstance()
      remoteDevicesC.startKeyMoueService()
      expect(remoteDevicesC != null).assertTrue()
    })
    it("RemoteDevicesControllerTest_stopKeyMouseService_001", 0, () => {
      let remoteDevicesC: RemoteDevicesController = RemoteDevicesController.getInstance();
      remoteDevicesC.stopKeyMouseService();
      (remoteDevicesC as object)['connectionId'] = 0;
      expect(remoteDevicesC != null).assertTrue();
    })
    it("RemoteDevicesControllerTest_disconnectCurrentDevice_001", 0, () => {
      let remoteDevicesC: RemoteDevicesController = RemoteDevicesController.getInstance()
      let remoteDevice: RemoteDeviceInfo = new RemoteDeviceInfo('testDeviceName', 'testDeviceId', 'testNetworkId', 0)
      let devicesC: DevicesController = DevicesController.getInstance()
      let deviceInfo: DeviceInfo = new DeviceInfo('testKey', 'testName', DeviceDisplayType.EXTENDED, 0, 0)
      let mocker: MockKit = new MockKit()
      let mockFun: Function = mocker.mockFunc(devicesC, devicesC.getCurrentDevice)
      when(mockFun)().afterReturn(deviceInfo)
      let mockFun1: Function = mocker.mockFunc(DisplayCommonUtils, DisplayCommonUtils.parseString)
      when(mockFun1)(ArgumentMatchers.any).afterReturn([remoteDevice])
      remoteDevicesC.refreshRemoteDevices('')
      remoteDevicesC.disconnectCurrentDevice()
      deviceInfo.deviceType = DeviceDisplayType.OTHERS
      when(mockFun)().afterReturn(deviceInfo)
      remoteDevicesC.disconnectCurrentDevice()
      deviceInfo.key = 'testDeviceId'
      when(mockFun)().afterReturn(deviceInfo)
      remoteDevicesC.disconnectCurrentDevice()
      expect(remoteDevicesC != null).assertTrue()
      mocker.clear(devicesC)
      mocker.clear(DisplayCommonUtils)
    })
    it("RemoteDevicesControllerTest_sendMessage_001", 0, () => {
      let remoteDevicesC: RemoteDevicesController = RemoteDevicesController.getInstance()
      remoteDevicesC.updateDeviceAddState('testNetworkId', () => {
      })
      remoteDevicesC.sendRefreshDevicePosition([])
      remoteDevicesC.setScreenSourceMode(screen.MultiScreenMode.SCREEN_MIRROR)
      expect(remoteDevicesC != null).assertTrue()
    })
  })
}
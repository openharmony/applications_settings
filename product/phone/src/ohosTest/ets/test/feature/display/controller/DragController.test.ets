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

import { describe, it, expect, MockKit, when } from '@ohos/hypium'
import {
  DevicesController,
  DeviceDisplayType,
  DeviceInfo,
  DeviceUserType
} from '@ohos/settings.display/src/main/ets/controller/DevicesController'
import { DragController, Point } from '@ohos/settings.display/src/main/ets/controller/DragController'

export default function DragControllerTest() {
  describe('DragControllerTest', () => {
    it('DragControllerTest_initPositions_001', 0, () => {
      let dragC: DragController = new DragController();
      dragC.initPositions();
      expect(dragC != null).assertTrue();
    })
    it('DragControllerTest_autoAlign_001', 0, () => {
      let dragC: DragController = new DragController();
      let oneDevice: DeviceInfo = new DeviceInfo('testKey', 'testName', DeviceDisplayType.BUILTIN, 0, 0);
      let point: Point = new Point(0, 0, 0, 0, oneDevice);
      (dragC as object)['positions'] = [point];
      dragC.autoAlign();
      oneDevice.deviceType = DeviceDisplayType.OTHERS;
      (dragC as object)['positions'] = [point];
      dragC.autoAlign();
      expect(dragC != null).assertTrue();
    })
    it('DragControllerTest_isCrossing_001', 0, () => {
      let dragC: DragController = new DragController();
      let oneDevice: DeviceInfo = new DeviceInfo('testKey', 'testName', DeviceDisplayType.BUILTIN, 0, 0);
      let point1: Point = new Point(0, 0, 10, 10, oneDevice);
      let point2: Point = new Point(0, 0, 20, 20, oneDevice);
      let point3: Point = new Point(11, 11, 20, 20, oneDevice);
      let pointU: Point = AppStorage.get<Point>('point') as Point;
      let result = dragC.isCrossing(point1, pointU);
      expect(result).assertFalse();
      result = dragC.isCrossing(point1, point2);
      expect(result).assertTrue();
      result = dragC.isCrossing(point1, point3);
      expect(result).assertFalse();
    })
    it('DragControllerTest_getLinePoint_001', 0, () => {
      let dragC: DragController = new DragController();
      let othersDevice: DeviceInfo = new DeviceInfo('testKey', 'testName', DeviceDisplayType.OTHERS, 0, 0);
      let oneDevice: DeviceInfo = new DeviceInfo('testKey', 'testName', DeviceDisplayType.BUILTIN, 0, 0);
      let point1: Point = new Point(0, 0, 10, 10, oneDevice);
      let point2: Point = new Point(10, 0, 20, 20, othersDevice);
      let point3: Point = new Point(0, 10, 20, 20, oneDevice);
      let point4: Point = new Point(11, 11, 20, 20, oneDevice);
      dragC.getLinePoint();
      (dragC as object)['positions'] = [point1, point2];
      dragC.getLinePoint();
      point2.deviceInfo = oneDevice;
      (dragC as object)['positions'] = [point1, point2];
      dragC.getLinePoint();
      (dragC as object)['positions'] = [point2, point1];
      dragC.getLinePoint();
      (dragC as object)['positions'] = [point1, point3];
      dragC.getLinePoint();
      (dragC as object)['positions'] = [point3, point1];
      dragC.getLinePoint();
      (dragC as object)['positions'] = [point1, point4];
      dragC.getLinePoint();
      expect(dragC != null).assertTrue();
    })
    it('DragControllerTest_snapping_001', 0, () => {
      let dragC: DragController = new DragController();
      let oneDevice: DeviceInfo = new DeviceInfo('testKey', 'testName', DeviceDisplayType.BUILTIN, 0, 0);
      let point1: Point = new Point(0, 0, 10, 10, oneDevice);
      let point12: Point = new Point(0, 21, 10, 10, oneDevice);
      let point122: Point = new Point(0, 25, 10, 10, oneDevice);
      let point2: Point = new Point(10, 0, 20, 20, oneDevice);
      let point3: Point = new Point(0, 10, 20, 20, oneDevice);
      let point13: Point = new Point(21, 0, 10, 10, oneDevice);
      let point133: Point = new Point(25, 0, 10, 10, oneDevice);
      let point4: Point = new Point(11, 11, 20, 20, oneDevice);
      (dragC as object)['positions'] = [point1];
      dragC.snapping(1);
      (dragC as object)['positions'] = [point1];
      dragC.snapping(0);
      (dragC as object)['positions'] = [point1, point4];
      dragC.snapping(0);

      (dragC as object)['positions'] = [point1, point2];
      dragC.snapping(0);
      (dragC as object)['positions'] = [point12, point2];
      dragC.snapping(0);
      (dragC as object)['positions'] = [point122, point2];
      dragC.snapping(0);
      (dragC as object)['positions'] = [point2, point12];
      dragC.snapping(0);
      (dragC as object)['positions'] = [point2, point122];
      dragC.snapping(0);

      (dragC as object)['positions'] = [point1, point3];
      dragC.snapping(0);
      (dragC as object)['positions'] = [point13, point3];
      dragC.snapping(0);
      (dragC as object)['positions'] = [point133, point3];
      dragC.snapping(0);
      (dragC as object)['positions'] = [point3, point13];
      dragC.snapping(0);
      (dragC as object)['positions'] = [point3, point133];
      dragC.snapping(0);
      expect(dragC != null).assertTrue();
    })
    it("DragControllerTest_snappingOthers_001", 0, () => {
      let dragC: DragController = new DragController();
      let oneDevice1: DeviceInfo = new DeviceInfo('testKey1', 'testName1', DeviceDisplayType.BUILTIN, 0, 0);
      let oneDevice2: DeviceInfo = new DeviceInfo('testKey2', 'testName2', DeviceDisplayType.EXTENDED, 0, 0);
      let oneDevice3: DeviceInfo = new DeviceInfo('testKey3', 'testName3', DeviceDisplayType.EXTENDED, 0, 0);
      let point1: Point = new Point(0, 0, 10, 10, oneDevice1);
      let point2: Point = new Point(10, 0, 20, 20, oneDevice2);
      let point3: Point = new Point(10, 0, 20, 20, oneDevice3);
      (dragC as object)['positions'] = [point1, point2, point3];
      dragC.setDeviceLocationOrder(['testKey1', 'testKey2', 'testKey3']);
      dragC.sortDeviceOrder();
      dragC.snappingOthers();
      oneDevice2.deviceType = DeviceDisplayType.OTHERS;
      point2.deviceInfo = oneDevice2;
      oneDevice3.deviceType = DeviceDisplayType.OTHERS;
      point3.deviceInfo = oneDevice3;
      (dragC as object)['positions'] = [point1, point2, point3];
      dragC.setDeviceLocationOrder(['testKey1', 'testKey2', 'testKey3']);
      dragC.sortDeviceOrder();
      dragC.snappingOthers();
      expect(dragC != null).assertTrue();
    })
    it("DragControllerTest_crossingOthersHandle_001", 0, () => {
      let dragC: DragController = new DragController();
      let oneDevice1: DeviceInfo = new DeviceInfo('testKey1', 'testName1', DeviceDisplayType.BUILTIN, 0, 0);
      let oneDevice2: DeviceInfo = new DeviceInfo('testKey2', 'testName2', DeviceDisplayType.OTHERS, 0, 0);
      let oneDevice3: DeviceInfo = new DeviceInfo('testKey3', 'testName3', DeviceDisplayType.OTHERS, 0, 0);
      let point1: Point = new Point(0, 0, 10, 10, oneDevice1);
      let point2: Point = new Point(10, 0, 20, 20, oneDevice2);
      let point3: Point = new Point(30, 0, 20, 20, oneDevice3);
      let pointU: Point = AppStorage.get<Point>('point') as Point;
      (dragC as object)['positions'] = [point1, point2, point3];
      dragC.setDeviceLocationOrder(['testKey1', 'testKey2', 'testKey3']);
      dragC.sortDeviceOrder();
      dragC.crossingOthersHandle(pointU);
      dragC.crossingOthersHandle(point1);
      dragC.crossingOthersHandle(point3);
      dragC.crossingOthersHandle(point2);
      expect(dragC != null).assertTrue();
    })
    it("DragControllerTest_dropping_001", 0, () => {
      let dragC: DragController = new DragController();
      let oneDevice1: DeviceInfo = new DeviceInfo('testKey1', 'testName1', DeviceDisplayType.BUILTIN, 0, 0);
      let oneDevice2: DeviceInfo = new DeviceInfo('testKey2', 'testName2', DeviceDisplayType.OTHERS, 0, 0);
      let oneDevice3: DeviceInfo = new DeviceInfo('testKey3', 'testName3', DeviceDisplayType.OTHERS, 0, 0);
      let point1: Point = new Point(0, 0, 10, 10, oneDevice1);
      let point2: Point = new Point(10, 0, 20, 20, oneDevice2);
      let point3: Point = new Point(30, 0, 20, 20, oneDevice3);
      let pointU: Point = AppStorage.get<Point>('point') as Point;
      (dragC as object)['positions'] = [point1, point2, point3];
      dragC.setDeviceLocationOrder(['testKey1', 'testKey2', 'testKey3']);
      dragC.sortDeviceOrder();
      dragC.dropping(pointU, 0, 0, 0);
      dragC.dropping(point1, 10, 10, 0);
      dragC.dropping(point2, 10, 10, 1);
      expect(dragC != null).assertTrue();
    })
    it("DragControllerTest_sortDevice_001", 0, () => {
      let dragC: DragController = new DragController();
      let oneDevice1: DeviceInfo = new DeviceInfo('0', 'testName1', DeviceDisplayType.BUILTIN, 0, 0);
      let oneDevice2: DeviceInfo = new DeviceInfo('testKey2', 'testName2', DeviceDisplayType.OTHERS, 0, 0);
      let point1: Point = new Point(0, 0, 10, 10, oneDevice1);
      let point2: Point = new Point(10, 0, 20, 20, oneDevice2);
      (dragC as object)['positions'] = [point1, point2];
      dragC.setDeviceLocationOrder(['0', '11', 'testKey2']);
      dragC.sortDeviceOrder();
      expect(dragC != null).assertTrue();
    })
    it("DragControllerTest_snapCrossing_001", 0, () => {
      let dragC: DragController = new DragController();
      let oneDevice1: DeviceInfo = new DeviceInfo('testKey1', 'testName1', DeviceDisplayType.BUILTIN, 0, 0);
      let oneDevice2: DeviceInfo = new DeviceInfo('testKey2', 'testName2', DeviceDisplayType.OTHERS, 0, 0);
      let oneDevice3: DeviceInfo = new DeviceInfo('testKey3', 'testName3', DeviceDisplayType.OTHERS, 0, 0);
      let point1: Point = new Point(0, 0, 10, 10, oneDevice1);
      let point11: Point = new Point(0, 0, 5, 5, oneDevice1);
      let point12: Point = new Point(20, 0, 10, 10, oneDevice1);
      let point13: Point = new Point(19, 15, 10, 10, oneDevice1);
      let point14: Point = new Point(1, -5, 10, 10, oneDevice1);
      let point15: Point = new Point(10, 0, 10, 10, oneDevice1);
      let point16: Point = new Point(10, 10, 10, 10, oneDevice1);
      let point111: Point = new Point(6, 1, 5, 5, oneDevice1);
      let point112: Point = new Point(16, 1, 5, 5, oneDevice1);
      let point113: Point = new Point(6, 11, 5, 5, oneDevice1);
      let point114: Point = new Point(16, 11, 5, 5, oneDevice1);
      let point2: Point = new Point(5, 0, 20, 20, oneDevice2);
      let pointU: Point = AppStorage.get<Point>('point') as Point;

      let result = dragC.snapCrossing(point11, point2);
      expect(result).assertEqual(point11);
      dragC.snapCrossing(point12, point2);
      dragC.snapCrossing(point1, point2);
      dragC.snapCrossing(point13, point2);
      dragC.snapCrossing(point14, point2);

      dragC.snapCrossing(point15, point2);
      dragC.snapCrossing(point16, point2);

      dragC.snapCrossing(point111, point2);
      dragC.snapCrossing(point112, point2);
      dragC.snapCrossing(point113, point2);
      dragC.snapCrossing(point114, point2);
      result = dragC.snapCrossing(pointU, pointU);
      expect(result.x).assertEqual(0);
      expect(dragC != null).assertTrue();
    })
    it("DragControllerTest_afterDrag_001", 0, () => {
      let dragC: DragController = new DragController();
      let oneDevice1: DeviceInfo = new DeviceInfo('testKey1', 'testName1', DeviceDisplayType.BUILTIN, 0, 0);
      let oneDevice2: DeviceInfo = new DeviceInfo('testKey2', 'testName2', DeviceDisplayType.OTHERS, 0, 0);
      let oneDevice3: DeviceInfo = new DeviceInfo('testKey3', 'testName3', DeviceDisplayType.OTHERS, 0, 0);
      let point1: Point = new Point(0, 0, 10, 10, oneDevice1);
      let point2: Point = new Point(5, 0, 20, 20, oneDevice2);
      let point3: Point = new Point(20, 0, 20, 20, oneDevice3);
      (dragC as object)['positions'] = [point1, point2, point3];
      (dragC as object)['positionsDataList'] = ['testKey1 testName1', 'testKey2 testName2', 'testKey3 testName3'];
      dragC.afterDrag(3);
      dragC.afterDrag(0);
      dragC.afterDrag(2);
      expect(dragC != null).assertTrue();
    })
    it("DragControllerTest_setRemoteDevicePosition_001", 0, () => {
      let dragC: DragController = new DragController();
      let oneDevice1: DeviceInfo = new DeviceInfo('testKey1', 'testName1', DeviceDisplayType.BUILTIN, 0, 0);
      let point1: Point = new Point(0, 0, 10, 10, oneDevice1);
      let point2: Point = new Point(5, 0, 20, 20, null);
      (dragC as object)['positions'] = [point1, point2];
      dragC.setRemoteDevicePosition();
      expect(dragC != null).assertTrue();
    })
    it("DragControllerTest_multiPositionsRefresh_001", 0, async (done: Function) => {
      let dragC: DragController = new DragController();
      let oneDevice1: DeviceInfo = new DeviceInfo('1', 'testName1', DeviceDisplayType.BUILTIN, 0, 0);
      let oneDevice2: DeviceInfo = new DeviceInfo('2', 'testName2', DeviceDisplayType.OTHERS, 0, 0);
      let point1: Point = new Point(0, 0, 10, 10, oneDevice1);
      let point2: Point = new Point(5, 0, 20, 20, oneDevice2);
      (dragC as object)['positions'] = [point1];
      await dragC.multiPositionsRefresh();

      let mocker: MockKit = new MockKit();
      let devicesC: DevicesController = DevicesController.getInstance();
      let mockFun: Function = mocker.mockFunc(devicesC, devicesC.getLocalDeviceCount)
      when(mockFun)().afterReturn(2);
      (dragC as object)['positions'] = [point1, point2];
      let mockFun1: Function = mocker.mockFunc(devicesC, devicesC.getDevices);
      let devices: DeviceInfo[] = [oneDevice1, oneDevice2];
      when(mockFun1)().afterReturn(devices);
      await dragC.multiPositionsRefresh();

      oneDevice2.key = '1';
      devices = [oneDevice1, oneDevice2];
      when(mockFun1)().afterReturn(devices);
      await dragC.multiPositionsRefresh();
      expect(dragC != null).assertTrue();
      mocker.clear(devicesC);
      done();
    })
  })
}
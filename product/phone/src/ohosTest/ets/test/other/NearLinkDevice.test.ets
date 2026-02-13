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

import { describe, expect, it } from '@ohos/hypium';
import { NearLinkDevice } from '@ohos/settings.nearlink/src/main/ets/model/NearLinkDevice';



export default function nearLinkDeviceTest() {
  let nearLinkDevice = new NearLinkDevice('deviceId', 'deviceName', 0, new ArrayBuffer(46), true);

  describe('nearLinkDeviceTest', (): void => {

    it('test_first', 0, (): void => {
      let resA = new NearLinkDevice('');
      expect(resA === null).assertFalse();
      let resB = new NearLinkDevice('deviceId', 'deviceName', 0, new ArrayBuffer(46), true);
      expect(resB === null).assertFalse();
      let resC = new NearLinkDevice('deviceId');
      expect(resC === null).assertFalse();
    })

    it('test_updateDevice', 0, (): void => {
      let resA = nearLinkDevice.updateDevice('', 0);
      expect(resA === null).assertFalse();
      let resB = nearLinkDevice.updateDevice('test', 1);
      expect(resB === null).assertFalse();
    })

    it('test_onConnectStateChange', 0, (): void => {
      let resA = nearLinkDevice.updateDeviceType('');
      expect(resA === null).assertFalse();
      let resB = nearLinkDevice.updateDeviceType('deviceId');
      expect(resB === null).assertFalse();
    })
  })
}

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

import { afterAll, afterEach, beforeAll, beforeEach, describe, expect, it, MockKit,Level } from '@ohos/hypium';
import { NearLinkConnectManager } from '@ohos/settings.nearlink/src/main/ets/manager/NearLinkConnectManager';
import manager from '@hms.nearlink.manager';

export default function nearLinkConnectManagerTest() {
  let nearLinkAdapter: NearLinkConnectManager = new NearLinkConnectManager();

  describe('nearLinkConnectManagerTest', (): void => {

    beforeAll((): void => {
    })

    beforeEach((): void => {
    })

    afterAll((): void => {
    })

    afterEach((): void => {
    })

    it('StartConnectFail', Level.LEVEL1, () => {
      let nearLinkConnectManager = new NearLinkConnectManager();
      let deviceId: string = '';
      nearLinkConnectManager.startConnect(deviceId);
      expect(nearLinkConnectManager.timerId).assertEqual(null);
    })

    it('NearLinkConnectManagerTest_disconnect', 0, () => {
      let nearLinkConnectManager = new NearLinkConnectManager();
      let deviceId: string = '123456';
      nearLinkConnectManager.disconnect(deviceId);
      expect(deviceId).not().assertNull();
    })

    it('finishConnect', Level.LEVEL1, () => {
      let nearLinkConnectManager = new NearLinkConnectManager();
      let deviceId = '123456';
      nearLinkConnectManager.finishConnect();
      expect(null).assertEqual(nearLinkConnectManager.timerId);
      nearLinkConnectManager.startConnect(deviceId);
      nearLinkConnectManager.finishConnect();
      expect(null).assertEqual(nearLinkConnectManager.timerId);
    })

    it('test_onConnectStateChange', 0, (): void => {
      let stateParam: manager.ConnectionStateParam =
        AppStorage.get<manager.ConnectionStateParam>('null') as manager.ConnectionStateParam;
      let resA = nearLinkAdapter.onConnectStateChange(stateParam);
      expect(resA === null).assertFalse();
    })
  })
}


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
  afterAll,
  beforeAll,
  describe,
  expect,
  it,
  TestType,
} from '@ohos/hypium';
import { ConnectedMouseModel, MouseManager } from '@ohos/settings.mouse/src/main/ets/model/ConnectedMouseModel';
import { LogUtil } from '@ohos/settings.common/src/main/ets/utils/LogUtil';

const TAG = 'GattClientManagerTest';

export default function ConnectedMouseModelTest() {
  describe('ConnectedMouseModelTest', () => {
    beforeAll(() => {
      LogUtil.showInfo(TAG, 'beforeAll');
    });

    afterAll(() => {
      LogUtil.showInfo(TAG, 'afterAll');
    });

    it('ConnectedMouseModelTest_001', TestType.FUNCTION, () => {
      LogUtil.showInfo(TAG, 'ConnectedMouseModelTest_001 it begin');
      const mouseModel = new ConnectedMouseModel('deviceId');
      mouseModel.setBatterySoc(1);
      MouseManager.getInstance().updateMouse('itemId', mouseModel);
      MouseManager.getInstance().removeMouse('itemId');
      MouseManager.getInstance().updateMouseSoc('itemId', mouseModel);
      MouseManager.getInstance().getMice();
      MouseManager.getInstance().clearMice();
      MouseManager.getInstance().notifyUI();
      expect().assertUndefined();
    });
  });
}

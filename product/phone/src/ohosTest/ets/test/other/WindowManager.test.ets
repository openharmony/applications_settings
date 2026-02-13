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

import { afterAll, afterEach, beforeAll, beforeEach, describe, expect, it, Level } from '@ohos/hypium';
import { WindowManager } from '@ohos/settings.common/src/main/ets/window/WindowManager';

export default function windowManagerTest() {
  describe('windowManagerTest', (): void => {

    beforeAll((): void => {
    })

    beforeEach((): void => {
    })

    afterAll((): void => {
    })

    afterEach((): void => {
    })

    it('findWindowTest', Level.LEVEL0, async () => {
      let result = false;
      try {
        WindowManager.getInstance().findWindow('name');
      } catch (error) {
        result = true;
      }
      expect(result).assertTrue();
    });

    it('windowNotFound', Level.LEVEL0, async () => {
      let result = WindowManager.isWindowShowing('name');
      expect(result).assertFalse();
    })

    it('closePluginWindow', Level.LEVEL0, async () => {
      WindowManager.closePluginWindow('test', true);
      expect(true).assertTrue();
    });

    it('WindowManagerTest_offKeyboardHeightChange', 0, () => {
      WindowManager.getInstance().offKeyboardHeightChange()
      expect(true).assertEqual(true);
    })

  })
}


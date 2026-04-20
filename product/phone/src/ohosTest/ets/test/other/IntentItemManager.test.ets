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

import { afterAll, afterEach, beforeAll, beforeEach, describe, expect, it, MockKit } from '@ohos/hypium';
import { SettingItemProperty } from '@ohos/settings.intent/Index';
import { IntentItemManager } from '@ohos/settings.intent/src/main/ets/manager/IntentItemManager';


export default function intentItemManagerTest() {
  describe('intentItemManagerTest', (): void => {

    beforeAll((): void => {
    })

    beforeEach((): void => {

    })

    afterAll((): void => {
    })

    afterEach((): void => {
    })

    it('TestIntentItemManager_getItem_cached', 0, async () => {
      let itemName: string = 'wifi';
      let result: SettingItemProperty = await IntentItemManager.getItem(itemName);
      expect(result).not().assertUndefined();
    });
    it('TestIntentItemManager_getItem_no_cached', 0, async () => {
      let itemName: string = 'TestIntentItemManager_getItem_no_cached';
      let result: SettingItemProperty = await IntentItemManager.getItem(itemName);
      expect(result).assertUndefined();
    });

  })
}

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
import { SettingsBaseMenu } from '@ohos/settings.common';
import { extraType } from '@ohos/settings.common/src/main/ets/core/model/menu/SettingsMenu';
import { WifiTextInputBaseController } from '@ohos/settings.wifi/src/main/ets/controller/WifiTextInputBaseController';


export default function wifiTextInputBaseControllerTest() {
  describe('wifiTextInputBaseControllerTest', (): void => {

    beforeAll((): void => {
    })

    beforeEach((): void => {
    })

    afterAll((): void => {
    })

    afterEach((): void => {
    })

    it('WifiTextInputBaseControllerTest_constructor', 0, () => {
      let menu: SettingsBaseMenu = new SettingsBaseMenu();
      menu.extra = {
        isCurrentVisible: true,
        supportMethod: [1],
        listenMenuKey: 'test',
        isClearTitle: true
      } as extraType;
      let wifiTextInputBaseController = new WifiTextInputBaseController(menu);
      expect(wifiTextInputBaseController.isClearTitle).assertTrue();
    })

  })
}


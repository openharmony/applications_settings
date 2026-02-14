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
import { SettingsBaseMenu } from '@ohos/settings.common';
import { ShowTouchActionsController } from '@ohos/settings.developeroptions';

class ShowTouchActionsSon extends ShowTouchActionsController {
  constructor(menu: SettingsBaseMenu) {
    super(menu);
  }

  public handleCheckedChange(isChecked: boolean): boolean {
    return super.handleCheckedChange(isChecked);
  }
}

export default function ShowTouchActionsControllerTest() {
  let menu: SettingsBaseMenu = new SettingsBaseMenu();
  let ShowTouchActions = new ShowTouchActionsSon(menu);
  describe('ShowTouchActionsControllerTest', () => {
    it('test_handleCheckedChange', 0, (): void => {
      let resA = ShowTouchActions.handleCheckedChange(true);
      expect(resA === null).assertFalse();
      let resB = ShowTouchActions.handleCheckedChange(false);
      expect(resB === null).assertFalse();
    })

  })
}
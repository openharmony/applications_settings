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
import { TraceRecordController } from '@ohos/settings.developeroptions';

class TraceRecordSon extends TraceRecordController {
  constructor(menu: SettingsBaseMenu) {
    super(menu);
  }

  public handleCheckedChange(isChecked: boolean): boolean {
    return super.handleCheckedChange(isChecked);
  }
}

export default function TraceRecordControllerTest() {
  let menu: SettingsBaseMenu = new SettingsBaseMenu();
  let TraceRecord = new TraceRecordSon(menu);
  describe('TraceRecordControllerTest', () => {
    it('test_handleCheckedChange', 0, (): void => {
      let resA = TraceRecord.handleCheckedChange(true);
      expect(resA === null).assertFalse();
      let resB = TraceRecord.handleCheckedChange(false);
      expect(resB === null).assertFalse();
    })

  })
}
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

import { describe, it, expect, TestType } from '@ohos/hypium';
import { LogUtil } from '@ohos/settings.common/src/main/ets/utils/LogUtil';
import { UiRefresher } from '@ohos/settings.common/src/main/ets/core/controller/Controller';
import { Constant } from '../../../constant/Constant';

export default function ControllerTest() {
  describe('ControllerTest', () => {

    /*
    * @tc.number: ControllerTest_001
    * @tc.name: 页的弹框取消回调
    * @tc.type: TestType.FUNCTION
    * @tc.desc: return true
    */
    it('ControllerTest_001', TestType.FUNCTION, async () => {
      LogUtil.info(`${Constant.TAG} ControllerTest_001 start`);
      let uiRefresher = new UiRefresher();
      let result = uiRefresher.refreshFontStyle();
      expect(result !== null).assertTrue();
      let setRender = uiRefresher.setRender(false);
      expect(setRender !== null).assertTrue();
      LogUtil.info(`${Constant.TAG} ControllerTest_001 end`);
    });
  });
}
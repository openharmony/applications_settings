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
import {
  SecurityPatchLabelController
} from '@ohos/settings.aboutdevice/src/main/ets/controller/SecurityPatchLabelController';

export default function SecurityPatchLabelControllerTest() {
  describe('SecurityPatchLabelControllerTest', (): void => {
    it('SecurityPatchLabelControllerTest_getUriAddress_001', 0,  (done: Function) => {
      try {
        let securityPatchLabelController = new SecurityPatchLabelController();
         (securityPatchLabelController as object)['getUriAddress']();
      } catch (e) {
      } finally {
        done()
      }
    });
    it('SecurityPatchLabelControllerTest_getUriAddress_002', 0,  (done: Function) => {
      try {
        let securityPatchLabelController = new SecurityPatchLabelController();
        (securityPatchLabelController as object)['ccmConfigStr'] = '';
        (securityPatchLabelController as object)['getUriAddress']();
      } catch (e) {
      } finally {
        done()
      }
    });
  })
}


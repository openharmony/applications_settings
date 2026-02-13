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

import { describe } from '@ohos/hypium';
import commonSimUtils from './common/aboutdevice/CommonSimUtils.test';
import commonMenuControllerTest from './common/core/controller/CommonMenuController.test';
import commonBaseUtilsTest from './common/utils/CommonBaseUtils.test';
import commonStringUtilTest from './common/utils/CommonStringUtil.test';
import commonTimeUtilTest from './common/utils/CommonTimeUtil.test';
import abilityUtilsTest from './other/AbilityUtils.test';
import bluetoothUtilsTest from './other/BluetoothUtils.test';
import passwordUtilTest from './other/PasswordUtil.test';
import commonCheckEmptyUtilsTest from './common/utils/CommonCheckEmptyUtils.test';

export default function PipelineDemoSuite() {

  describe("settings_framework", () => {
    abilityUtilsTest();
    bluetoothUtilsTest();
    passwordUtilTest();
    commonBaseUtilsTest();
    commonTimeUtilTest();
    commonMenuControllerTest();
    commonSimUtils();
    commonStringUtilTest();
    commonCheckEmptyUtilsTest();
  });
}
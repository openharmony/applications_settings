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

import { describe, it } from '@ohos/hypium';
import { LogUtil } from '@ohos/settings.common/index';
import { RestoreSystemSoundConfig } from '@ohos/settings.reset/src/main/ets/controller/RestoreSystemSoundConfig';
import { RestoreAccessibilityConfig  } from '@ohos/settings.reset/src/main/ets/controller/RestoreAccessibilityConfig';

const TAG: string = 'SettingsRestoreConfigTest: ';

export default function SettingsRestoreConfigTest() {
  describe('SettingsRestoreConfigTest', () => {

    /*
    * @tc.number: settingsRestoreConfig_002
    * @tc.name: restoreSettingsConfig
    * @tc.type: 0 || TestType.FUNCTION  || Level.LEVEL0
    * @tc.desc:restoreSettingsConfig分支覆盖
    */
    it('SettingsRestoreConfigTest_002', 0, () => {
      LogUtil.info(`${TAG}SettingsRestoreConfigTest_002 begin`);
      let restoreSystemSoundConfig: RestoreSystemSoundConfig = new RestoreSystemSoundConfig();
      restoreSystemSoundConfig.restoreSystemSoundConfig();
      LogUtil.info(`${TAG}SettingsRestoreConfigTest_002 end`);
    })

    /*
    * @tc.number: settingsRestoreConfig_003
    * @tc.name: restoreSettingsConfig
    * @tc.type: 0 || TestType.FUNCTION  || Level.LEVEL0
    * @tc.desc:restoreSettingsConfig分支覆盖
    */
    it('settingsRestoreConfig_003', 0, () => {
      LogUtil.info(`${TAG}settingsRestoreConfig_003 begin`);
      let restoreAccessibilityConfig: RestoreAccessibilityConfig = new RestoreAccessibilityConfig();
      restoreAccessibilityConfig.restoreAccessibilityConfig();
      LogUtil.info(`${TAG}settingsRestoreConfig_003 end`);
    })
  })
}
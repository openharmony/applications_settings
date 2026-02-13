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

import uiAppearance from '@ohos.uiAppearance';
import connection from '@ohos.net.connection';
import { LogUtil } from '@ohos/settings.common/src/main/ets/utils/LogUtil';
import { SettingsDataUtils } from '@ohos/settings.common/src/main/ets/utils/SettingsDataUtils';
import { SettingsRestoreBase } from './SettingsRestoreBase';
import { RestoreSystemSoundConfig } from './RestoreSystemSoundConfig';
import { RestoreAccessibilityConfig } from './RestoreAccessibilityConfig';

const TAG: string = 'SettingsRestoreConfigDeal : ';

export class SettingsRestoreConfigDeal implements SettingsRestoreBase {
  private restoreSystemSoundConfig: RestoreSystemSoundConfig = new RestoreSystemSoundConfig();
  private restoreAccessibilityConfig: RestoreAccessibilityConfig = new RestoreAccessibilityConfig();
  constructor() {
  }

  restoreConfig(): void {
    this.restoreAppearanceMode();
    this.restoreAirplaneMode();
    this.restoreSystemSoundConfig.restoreSystemSoundConfig();
    this.restoreAccessibilityConfig.restoreAccessibilityConfig();
  }

  private restoreAppearanceMode(): void {
    try {
      uiAppearance.setDarkMode(uiAppearance.DarkMode.ALWAYS_LIGHT);
      LogUtil.info(`${TAG} system color factoryReset success`);
      SettingsDataUtils.setSecureValue('ui_night_mode', '1');
    } catch (error) {
      LogUtil.error(`appearance mode factoryReset error: ${error?.message}`);
    }
  }

  private restoreAirplaneMode(): void {
    try {
      connection.disableAirplaneMode();
      LogUtil.info(`${TAG} airplane mode restore success`);
    } catch (error) {
      LogUtil.error(`airplane mode restore error: ${error.message}`);
    }
  }
}

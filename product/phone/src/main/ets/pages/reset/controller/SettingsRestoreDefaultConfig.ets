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

import { LogUtil } from '@ohos/settings.common/src/main/ets/utils/LogUtil';
import { SettingsRestoreConfigDeal } from '@ohos/settings.reset/src/main/ets/controller/SettingsRestoreConfigDeal';
import { SettingsDataRestoreConfigDeal } from '@ohos/settings.reset/src/main/ets/controller/SettingsDataRestoreConfigDeal';
import { SettingsRestoreBase } from '@ohos/settings.reset/src/main/ets/controller/SettingsRestoreBase';
import { PhoneSettingsRestoreConfig } from '../controller/PhoneSettingsRestoreConfig';

/* instrument ignore file */
const TAG: string = 'SettingsRestoreDefaultConfig : ';
const SETTINGSDATA_RESTORE_CONFIG: string = 'settingsdata_restore_config';
const SETTINGS_RESTORE_CONFIG: string = 'settings_restore_config';
const PHONE_RESTORE_CONFIG: string = 'phone_restore_config';

export class SettingsRestoreDefaultConfig {
  private readonly restoreMap: Map<string, Object> | null = null;
  private static instance: SettingsRestoreDefaultConfig | null = null;


  constructor() {
    this.restoreMap = new Map<string, Object>([
      [SETTINGSDATA_RESTORE_CONFIG, new SettingsDataRestoreConfigDeal()],
      [SETTINGS_RESTORE_CONFIG, new SettingsRestoreConfigDeal()],
      [PHONE_RESTORE_CONFIG, new PhoneSettingsRestoreConfig()],
    ]);
  }

  public static getInstance(): SettingsRestoreDefaultConfig {
    if (!SettingsRestoreDefaultConfig.instance) {
      SettingsRestoreDefaultConfig.instance = new SettingsRestoreDefaultConfig();
    }
    return SettingsRestoreDefaultConfig.instance;
  }

  restoreSettingsConfig(): void {
    this.restoreMap?.forEach((value, key) => {
      (value as SettingsRestoreBase).restoreConfig();
      LogUtil.debug(`${TAG} The setting item has been restored, key: ${key}`);
    })
  }
}

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

import I18n from '@ohos.i18n';
import { SettingsDataUtils } from '@ohos/settings.common/src/main/ets/utils/SettingsDataUtils';
import systemParameter from '@ohos.systemparameter';
import { displayDataManager } from '@ohos/settings.common/src/main/ets/data/DisplayDataManager';
import { LogUtil } from '@ohos/settings.common/src/main/ets/utils/LogUtil';
import { DisplayConstant } from '@ohos/settings.common/src/main/ets/constant/DisplayConstant';
import { SettingsRestoreBase } from './SettingsRestoreBase';

const TAG: string = 'SettingsDataRestoreConfigDeal : ';

export class SettingsDataRestoreConfigDeal implements SettingsRestoreBase {
  private readonly AIRPLANE_MODE: string = 'settings.telephony.airplanemode';
  private readonly NFC_STATE: string = 'data_key_nfc_state';
  private readonly SCREEN_BRIGHTNESS: string = 'settings.display.screen_brightness_status';
  private readonly AUTO_BRIGHTNESS: string = 'settings.display.auto_screen_brightness';
  private readonly EYESHIEDLD_MODE: string = 'settings.eyeshield.enable';
  private readonly SCREEN_TIMEOUT: string = 'settings.display.screen_off_timeout';
  private readonly SCREEN_FREQ: string = 'settings.display.hw_screen_freq';
  private readonly SCREEN_RESOLUTION: string = 'settings.display.resolution_smart_switch';
  private readonly COLOR_MODE: string = 'settings.color_mode';
  private readonly COLOR_TEMPERATURE: string = 'settings.color_temperature';
  private readonly ATUO_TIMEZONE: string = 'auto_timezone';
  private readonly HAPTIC_FEEDBACK: string = 'physic_navi_haptic_feedback_enabled';
  private readonly TIME_FORMAT_KEY: string = 'settings.date.TIME_FORMAT';
  private readonly TIME_FORMAT_DEFAULT: string = '12';

  constructor() {
  }

  restoreConfig(): void {
    LogUtil.info(`${TAG} settingsdata start recovery`);
    SettingsDataUtils.setSettingsData(this.AIRPLANE_MODE, '0');
    SettingsDataUtils.setSettingsData(this.NFC_STATE, '1');
    SettingsDataUtils.setSettingsData(this.SCREEN_BRIGHTNESS, this.getDefaultBrightness());
    SettingsDataUtils.setSettingsData(this.AUTO_BRIGHTNESS, '1');
    SettingsDataUtils.setSettingsData(this.EYESHIEDLD_MODE, '0');
    SettingsDataUtils.setSettingsData(this.SCREEN_TIMEOUT, '30000');
    SettingsDataUtils.setSettingsData(this.SCREEN_FREQ, '-1');
    SettingsDataUtils.setSettingsData(this.SCREEN_RESOLUTION, '0');
    SettingsDataUtils.setSettingsData(this.COLOR_MODE, 'standard');
    SettingsDataUtils.setSettingsData(this.COLOR_TEMPERATURE, 'default');
    SettingsDataUtils.setSettingsData(this.ATUO_TIMEZONE, '1');
    SettingsDataUtils.setSettingsData(this.HAPTIC_FEEDBACK, '1');
    this.setDefaultTimeFormat();
    this.setDefaultDpi();
    // 刷新缓存信息，避免数据项改变了之后页面值没有刷新
    displayDataManager.getDisplaySettingData();
  }

  private getDefaultBrightness(): string {
    return systemParameter.getSync('const.display.brightness.default', '62');
  }

  private setDefaultDpi(): void {
    let defaultDpi: string = displayDataManager.getDefaultDPI();
    LogUtil.showInfo(TAG, `dpi default value: ${defaultDpi}`);
    SettingsDataUtils.setSettingsData(DisplayConstant.SETTINGS_DATA_USER_SET_DPI_VALUE, defaultDpi);
  }

  private setDefaultTimeFormat(): void {
    SettingsDataUtils.setSettingsData(this.TIME_FORMAT_KEY, this.TIME_FORMAT_DEFAULT);
    I18n.set24HourClock(false);
  }
}

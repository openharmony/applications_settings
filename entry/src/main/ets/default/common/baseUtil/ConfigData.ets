/**
 * Copyright (c) 2021 Huawei Device Co., Ltd.
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

export class ConfigData {
  FILE_URI = '/data/accounts/account_0/applications/com.ohos.settings'
  + '/com.ohos.settings/assets/entry/resources/rawfile/';
  PREFERENCES_PATH = '/data/accounts/account_0/appdata/com.ohos.settings/sharedPreference/SettingPreferences';
  BRIGHTNESS_SAVE_VALUE_KEY = 'BrightnessSaveValue';
  VOLUME_SAVE_VALUE_KEY = 'VolumeSaveValue';
  SENT_EVENT_BROADCAST_BRIGHTNESS_VALUE = 'BRIGHTNESS_VALUE';
  SENT_EVENT_BROADCAST_VOLUME_VALUE = 'VOLUME_VALUE';
  SENT_EVENT_WIFI_CONNECT_NAME = 'WIFI_CONNECT_NAME';
  BRIGHTNESS_DEFAULT_VALUE = 50;
  DEFAULT_BUNDLE_NAME = 'com.ohos.settings';
  DATE_AND_TIME_YEAR='DATE_AND_TIME_YEAR'
  DATE_AND_TIME_MONTH='DATE_AND_TIME_MONTH'
  DATE_AND_TIME_DAY='DATE_AND_TIME_DAY'
  TAG='Settings '

  WH_100_100 = '100%';
  WH_30_100 = '30%';
  WH_35_100 = '35%';
  WH_40_100 = '40%';
  WH_45_100 = '45%';
  WH_50_100 = '50%';
  WH_55_100 = '55%';
  WH_83_100 = '83%';
  WH_90_100 = '90%';

  value_20 = 20;
  font_20 = 20;

  MAX_LINES_1 = 1;
  MAX_LINES_2 = 2;
  MAX_LINES_3 = 3;
  DURATION_TIME = 200;
}

let configData = new ConfigData();
export default configData as ConfigData
;
/**
 * Copyright (c) 2021-2022 Huawei Device Co., Ltd.
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

import settings from '@ohos.settings';

export class ConfigData {
  FILE_URI = '/data/accounts/account_0/applications/com.ohos.settings'
  + '/com.ohos.settings/assets/phone/resources/rawfile/';
  PREFERENCES_PATH = '/data/accounts/account_0/appdata/com.ohos.settings/sharedPreference/SettingPreferences';
  BRIGHTNESS_SAVE_VALUE_KEY = 'BrightnessSaveValue';

  SENT_EVENT_BROADCAST_BRIGHTNESS_VALUE = 'BRIGHTNESS_VALUE';
  SENT_EVENT_BROADCAST_VOLUME_VALUE = 'VOLUME_VALUE';
  SENT_EVENT_WIFI_CONNECT_NAME = 'WIFI_CONNECT_NAME';
  SENT_EVENT_AUDIO_RINGER_MODE = 'AUDIO_RINGER_MODE';
  SENT_EVENT_AUDIO_VOLUME_VALUE = 'AUDIO_VOLUME_VALUE';

  BRIGHTNESS_DEFAULT_VALUE = 50;
  DEFAULT_BUNDLE_NAME = 'com.ohos.settings';
  DATE_AND_TIME_YEAR = 'DATE_AND_TIME_YEAR';
  DATE_AND_TIME_MONTH = 'DATE_AND_TIME_MONTH';
  DATE_AND_TIME_DAY = 'DATE_AND_TIME_DAY';
  TAG = 'Settings ';

  // page request
  PAGE_REQUEST_CODE_KEY = 'pageRequestCode';
  PAGE_RESULT_KEY = 'pageResult';
  PAGE_RESULT_OK = -1;
  PAGE_RESULT_NG = 0;

  // password request code
  PAGE_REQUEST_CODE_PASSWORD_CREATE = 20001;
  PAGE_REQUEST_CODE_PASSWORD_CHANGE = 20003;
  PAGE_REQUEST_CODE_PASSWORD_DISABLE = 20004;

  WH_100_100 = '100%';
  WH_25_100 = '25%';
  WH_30_100 = '30%';
  WH_33_100 = '33%';
  WH_35_100 = '35%';
  WH_40_100 = '40%';
  WH_45_100 = '45%';
  WH_50_100 = '50%';
  WH_55_100 = '55%';
  WH_83_100 = '83%';
  WH_90_100 = '90%';

  GRID_CONTAINER_GUTTER_24 = 24;
  GRID_CONTAINER_MARGIN_24 = 24;

  LAYOUT_WEIGHT_1 = 1;

  value_20 = 20;
  font_20 = 20;

  MAX_LINES_1 = 1;
  MAX_LINES_2 = 2;
  MAX_LINES_3 = 3;
  DURATION_TIME = 200;
  FUNCTION_TYPE_HDC = 4;

  TIME_FORMAT_24 = "24";
  TIME_FORMAT_12 = "12";
  TIME_FORMAT_KEY = settings.date.TIME_FORMAT;
  SETTINGSDATA_DEVICE_NAME = settings.general.DEVICE_NAME;
  SETTINGSDATA_BRIGHTNESS = settings.display.SCREEN_BRIGHTNESS_STATUS;
  SLIDER_CHANG_MODE_MOVING = 1;
  SLIDER_CHANG_MODE_END = 2;

  //Language And Region
  ADDLANGUAGES = 'addedLanguages';
  CURRENTREGION = 'currentRegion';

  //Key of StoragePath
  STORAGEPATHKEY = 'storagePath';

  //StartAbility
  FACEAUTH_BUNDLE_NAME = 'com.ohos.settings.faceauth';
  FACEAUTH_ABILITY_NAME = 'com.ohos.settings.faceauth.enrollmentstartview';
  PERMISSION_MANAGER_BUNDLE_NAME = 'com.ohos.permissionmanager';
  PERMISSION_MANAGER_ABILITY_NAME = 'com.ohos.permissionmanager.MainAbility';
  MOBILE_DATA_BUNDLE_NAME = 'com.ohos.callui';
  MOBILE_DATA_ABILITY_NAME = 'com.ohos.mobiledatasettings.MainAbility';
  SOFTWARE_UPDATES_BUNDLE_NAME = 'com.hmos.ouc';
  SOFTWARE_UPDATES_ABILITY_NAME = 'com.hmos.ouc.MainAbility';
  SECURITY_BUNDLE_NAME = 'com.ohos.certmanager';
  SECURITY_ABILITY_NAME = 'MainAbility';

  DEVICE_NAME = 'OpenHarmony 2.0 Canary';
}

let configData = new ConfigData();
export default configData as ConfigData;
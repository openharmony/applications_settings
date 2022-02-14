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
import ConfigData from '../../../../../../../../common/utils/src/main/ets/default/baseUtil/ConfigData.ets';
import LogUtil from '../../../../../../../../common/utils/src/main/ets/default/baseUtil/LogUtil.ets';
import BaseParseConfModel from '../../../../../../../../common/utils/src/main/ets/default/model/BaseParseConfModel.ets';
import BaseModel from '../../../../../../../../common/utils/src/main/ets/default/model/BaseModel.ets';

/**
 * app setting homepage service class
 */
export class SettingListModel extends BaseModel {
  private settingsList = [
    [
      {
        "settingIcon": "/res/image/ic_settings_wifi.svg",
        "settingTitle": $r('app.string.wifiTab'),
        "settingAlias": '',
        "settingValue": "",
        "settingArrow": "/res/image/ic_settings_arrow.svg",
        "settingSummary": "",
        "settingUri": "pages/wifi"
      },
    ],
    [
      {
        "settingIcon": "/res/image/ic_settings_display.svg",
        "settingTitle": $r('app.string.brightnessTab'),
        "settingAlias": '',
        "settingValue": "",
        "settingArrow": "/res/image/ic_settings_arrow.svg",
        "settingSummary": "",
        "settingUri": "pages/screenAndBrightness"
      }
    ],
    [
      {
        "settingIcon": "/res/image/ic_settings_volume.svg",
        "settingTitle": $r('app.string.volumeControlTab'),
        "settingAlias": '',
        "settingValue": "",
        "settingArrow": "/res/image/ic_settings_arrow.svg",
        "settingSummary": "",
        "settingUri": "pages/volumeControl"
      }
    ],
    [
      {
        "settingIcon": "/res/image/ic_settings_password.svg",
        "settingTitle": $r('app.string.biometricsAndPassword'),
        "settingAlias": '',
        "settingValue": "",
        "settingArrow": "/res/image/ic_settings_arrow.svg",
        "settingSummary": "",
        "settingUri": "pages/passwordSetting"
      },
      {
        "settingIcon": "res/image/ic_settings_applications.svg",
        "settingTitle": $r('app.string.applyTab'),
        "settingAlias": '',
        "settingValue": "",
        "settingArrow": "res/image/ic_settings_arrow.svg",
        "settingSummary": "",
        "settingUri": "pages/application"
      },
      {
        "settingIcon": "/res/image/ic_settings_storage.svg",
        "settingTitle": $r('app.string.storageTab'),
        "settingAlias": '',
        "settingValue": "",
        "settingArrow": "/res/image/ic_settings_arrow.svg",
        "settingSummary": "",
        "settingUri": "pages/storage"
      },
      {
        "settingIcon": "/res/image/ic_settings_privacy.svg",
        "settingTitle": $r('app.string.privacy'),
        "settingAlias": '',
        "settingValue": "",
        "settingArrow": "/res/image/ic_settings_arrow.svg",
        "settingSummary": "",
        "settingUri": "pages/privacy"
      }
    ],
    [
      {
        "settingIcon": "/res/image/ic_settings_users.svg",
        "settingTitle": $r("app.string.usersAccountsTab"),
        "settingAlias": '',
        "settingValue": "",
        "settingArrow": "/res/image/ic_settings_arrow.svg",
        "settingSummary": "",
        "settingUri": "pages/usersAccounts"
      },
      {
        "settingIcon": "/res/image/ic_settings_about.svg",
        "settingTitle": $r('app.string.systemTab'),
        "settingAlias": '',
        "settingValue": "",
        "settingArrow": "/res/image/ic_settings_arrow.svg",
        "settingSummary": "",
        "settingUri": "pages/system/homePage"
      },
      {
        "settingIcon": "/res/image/ic_settings_about.svg",
        "settingTitle": $r('app.string.aboutTab'),
        "settingAlias": '',
        "settingValue": "",
        "settingArrow": "/res/image/ic_settings_arrow.svg",
        "settingSummary": "",
        "settingUri": "pages/aboutDevice"
      }
    ]
  ];

  getSettingList() {
    return this.settingsList;
  }

}

let settingListModel = new SettingListModel();

export default settingListModel as SettingListModel
;

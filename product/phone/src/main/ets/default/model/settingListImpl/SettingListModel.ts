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
import ConfigData from '../../../../../../../../common/utils/src/main/ets/default/baseUtil/ConfigData';
import LogUtil from '../../../../../../../../common/utils/src/main/ets/default/baseUtil/LogUtil';
import Log from '../../../../../../../../common/utils/src/main/ets/default/baseUtil/LogDecorator';
import BaseModel from '../../../../../../../../common/utils/src/main/ets/default/model/BaseModel';
import wifi from '@ohos.wifi';
import prompt from '@system.prompt';
import Router from '@system.router';
import FeatureAbility from '@ohos.ability.featureAbility';

/**
 * app setting homepage service class
 */
export class SettingListModel extends BaseModel {
  private TAG = `${ConfigData.TAG} SettingListModel`;
  private settingsList = [
    [
      {
        "settingIcon": "/res/image/wlan.svg",
        "settingTitle": $r('app.string.wifiTab'),
        "settingAlias": 'wlanTab',
        "settingValue": "",
        "settingArrow": "/res/image/ic_settings_arrow.svg",
        "settingSummary": "",
        "settingUri": "pages/wifi"
      },
      {
        "settingIcon": "/res/image/blueTooth.svg",
        "settingTitle": $r('app.string.bluetoothTab'),
        "settingAlias": 'blueToothTab',
        "settingValue": "",
        "settingArrow": "/res/image/ic_settings_arrow.svg",
        "settingSummary": "",
        "settingUri": "pages/bluetooth"
      },
      {
        "settingIcon": "/res/image/mobileData.svg",
        "settingTitle": $r('app.string.mobileData'),
        "settingAlias": "mobileDataTab",
        "settingValue": "",
        "settingArrow": "/res/image/ic_settings_arrow.svg",
        "settingSummary": "",
        "settingUri": ""
      }
    ],
    [
      {
        "settingIcon": "/res/image/displayAndBrightness.svg",
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
        "settingIcon": "/res/image/volume.svg",
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
        "settingIcon": "/res/image/biometricsAndPassword.svg",
        "settingTitle": $r('app.string.biometricsAndPassword'),
        "settingAlias": '',
        "settingValue": "",
        "settingArrow": "/res/image/ic_settings_arrow.svg",
        "settingSummary": "",
        "settingUri": "pages/passwordSetting"
      },
      {
        "settingIcon": "res/image/application.svg",
        "settingTitle": $r('app.string.applyTab'),
        "settingAlias": '',
        "settingValue": "",
        "settingArrow": "res/image/ic_settings_arrow.svg",
        "settingSummary": "",
        "settingUri": "pages/application"
      },
      {
        "settingIcon": "/res/image/storage.svg",
        "settingTitle": $r('app.string.storageTab'),
        "settingAlias": '',
        "settingValue": "",
        "settingArrow": "/res/image/ic_settings_arrow.svg",
        "settingSummary": "",
        "settingUri": "pages/storage"
      },
      {
        "settingIcon": "/res/image/privacy.svg",
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
        "settingIcon": "/res/image/userAccounts.svg",
        "settingTitle": $r("app.string.usersAccountsTab"),
        "settingAlias": '',
        "settingValue": "",
        "settingArrow": "/res/image/ic_settings_arrow.svg",
        "settingSummary": "",
        "settingUri": "pages/usersAccounts"
      },
      {
        "settingIcon": "/res/image/system.svg",
        "settingTitle": $r('app.string.systemTab'),
        "settingAlias": '',
        "settingValue": "",
        "settingArrow": "/res/image/ic_settings_arrow.svg",
        "settingSummary": "",
        "settingUri": "pages/system/homePage"
      },
      {
        "settingIcon": "/res/image/aboutDevice.svg",
        "settingTitle": $r('app.string.aboutTab'),
        "settingAlias": '',
        "settingValue": "",
        "settingArrow": "/res/image/ic_settings_arrow.svg",
        "settingSummary": "",
        "settingUri": "pages/aboutDevice"
      }
    ]
  ];

  /**
   * Get settingsList
   */
  @Log
  getSettingList() {
    return this.settingsList;
  }

  /**
   * Item on click
   */
  @Log
  onClick(item): void{
    if(item.settingAlias === 'mobileDataTab'){
      FeatureAbility.startAbility({
        want: {
          bundleName: ConfigData.MOBILE_DATA_BUNDLE_NAME,
          abilityName: ConfigData.MOBILE_DATA_ABILITY_NAME,
        }
      })
        .then((data) => {
          LogUtil.info(`${this.TAG}, ${ConfigData.MOBILE_DATA_BUNDLE_NAME} start successful. Data: ${JSON.stringify(data)}`);
        })
        .catch((error) => {
          prompt.showToast({
            message: $r("app.string.mobileDataFailed"),
            duration: 2000,
          });
          LogUtil.error(`${this.TAG}, ${ConfigData.MOBILE_DATA_BUNDLE_NAME} start failed. Cause: ${JSON.stringify(error)}`);
        })
    } else {
      Router.push({
        uri: item.settingUri,
      });
    }
  }

  /**
   * Register Observer
   */
  @Log
  registerObserver(){
    wifi.on('wifiStateChange', (code) => {
      AppStorage.SetOrCreate('wifiStatus', wifi.isWifiActive());
    })
  }

}

let settingListModel = new SettingListModel();

export default settingListModel as SettingListModel;

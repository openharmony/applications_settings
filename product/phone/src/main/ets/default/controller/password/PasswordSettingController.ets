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
import BaseSettingsController from '../../../../../../../../common/component/src/main/ets/default/controller/BaseSettingsController.ets';
import ConfigData from '../../../../../../../../common/utils/src/main/ets/default/baseUtil/ConfigData.ets';
import ISettingsController from '../../../../../../../../common/component/src/main/ets/default/controller/ISettingsController';
import LogUtil from '../../../../../../../../common/utils/src/main/ets/default/baseUtil/LogUtil.ets';
import {LogAll} from '../../../../../../../../common/utils/src/main/ets/default/baseUtil/LogDecorator.ets';
import PasswordModel from '../../model/passwordImpl/PasswordModel.ets';

@LogAll
export default class PasswordSettingController extends BaseSettingsController {
  private TAG = ConfigData.TAG + 'PasswordSettingController ';
  private pinChallenge: string = '';
  private passwordList: any[] = [];

  subscribe(): ISettingsController {
    PasswordModel.closeSession();
    PasswordModel.openSession((data) => {
      LogUtil.info(`${this.TAG}subscribe->openSession data:${data}`);
      if (data === '0') {
        LogUtil.info(`${this.TAG}subscribe->openSession failed`);
      } else {
        LogUtil.info(`${this.TAG}subscribe->openSession success`);
      }
      this.pinChallenge = data;
    });
    return this;
  };

  unsubscribe(): ISettingsController {
    PasswordModel.closeSession();
    return this;
  };

/**
   * Load page data.
   * Get password from api. create data list of
   */
  loadData() {
    // get password
    PasswordModel.hasPinPassword((passwordHasSet) => {

      // update password settings list
      this.getListData(passwordHasSet , (list) => {
        LogUtil.info(this.TAG + 'getListData callback : list = ' + JSON.stringify(list));
        this.passwordList = list
        LogUtil.info(this.TAG + 'getListData callback : end ');
      });
    });
  }

/**
   * When receive next page's result is ok, do here.
   *
   * @param routerParam : next page's result
   */
  getListData(passwordHasSet: boolean, callback) {
    let list = this.getPageData();

    for (let key in list) {
      let settingAlias = list[key].settingAlias;
      let shouldDisplay = true;
      let title;
      let requestCode = -1;
      switch (settingAlias) {
        case 'biometrics_section_title':
          shouldDisplay = passwordHasSet;
          title = $r('app.string.biometrics');
          break;

        case 'face_recognition':
          title = $r('app.string.face_recognition')
          requestCode = ConfigData.PAGE_REQUEST_CODE_PASSWORD_FACE;
          break;

        case 'password_section_title':
          shouldDisplay = passwordHasSet;
          title = $r('app.string.password');
          break;

        case 'password_lock_screen':
          shouldDisplay = !passwordHasSet;
          title = $r('app.string.password_lock_screen');
          requestCode = ConfigData.PAGE_REQUEST_CODE_PASSWORD_CREATE;
          break;

        case 'password_change_password':
          shouldDisplay = passwordHasSet;
          title = $r('app.string.password_change_password')
          requestCode = ConfigData.PAGE_REQUEST_CODE_PASSWORD_CHANGE;
          break;

        case 'password_disable_password':
          shouldDisplay = passwordHasSet;
          title = $r('app.string.password_disable_password')
          requestCode = ConfigData.PAGE_REQUEST_CODE_PASSWORD_DISABLE;
          break;
      }

      list[key].settingShouldDisplay = shouldDisplay;
      list[key].settingTitle = title;
      list[key].settingRequestCode = requestCode;

    }
    callback(list)

  }

  getPageData(): any[] {
    let list = [
      {
        settingIsSectionTitle: true,
        settingShouldDisplay: false,
        settingTitle: "",
        settingAlias: "biometrics_section_title",
        settingValue: "",
        settingArrow: "",
        settingRequestCode: "",
        settingUri: ""
      },
      {
        settingIsSectionTitle: false,
        settingShouldDisplay: true,
        settingTitle: "",
        settingAlias: "face_recognition",
        settingValue: "",
        settingArrow: "/res/image/ic_settings_arrow.svg",
        settingRequestCode: "",
        settingUri: ""
      },
      {
        settingIsSectionTitle: true,
        settingShouldDisplay: false,
        settingTitle: "",
        settingAlias: "password_section_title",
        settingValue: "",
        settingArrow: "",
        settingRequestCode: "",
        settingUri: ""
      },
      {
        settingIsSectionTitle: false,
        settingShouldDisplay: true,
        settingTitle: "",
        settingAlias: "password_lock_screen",
        settingValue: "",
        settingArrow: "/res/image/ic_settings_arrow.svg",
        settingRequestCode: "",
        settingUri: "pages/passwordInput"
      },
      {
        settingIsSectionTitle: false,
        settingShouldDisplay: false,
        settingTitle: "",
        settingAlias: "password_change_password",
        settingValue: "",
        settingArrow: "/res/image/ic_settings_arrow.svg",
        settingRequestCode: "",
        settingUri: "pages/passwordCheck"
      },
      {
        settingIsSectionTitle: false,
        settingShouldDisplay: false,
        settingTitle: "",
        settingAlias: "password_disable_password",
        settingValue: "",
        settingArrow: "",
        settingRequestCode: "",
        settingUri: "pages/passwordCheck"
      }
    ]

    return list
  }

}
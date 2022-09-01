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
import BaseSettingsController from '../../../../../../../common/component/src/main/ets/default/controller/BaseSettingsController';
import { PasswordSettingItem } from '../../../../../../../common/utils/src/main/ets/default/bean/PasswordSettingItem';
import ConfigData from '../../../../../../../common/utils/src/main/ets/default/baseUtil/ConfigData';
import ISettingsController from '../../../../../../../common/component/src/main/ets/default/controller/ISettingsController';
import LogUtil from '../../../../../../../common/utils/src/main/ets/default/baseUtil/LogUtil';
import {LogAll} from '../../../../../../../common/utils/src/main/ets/default/baseUtil/LogDecorator';
import PasswordModel from '../../model/passwordImpl/PasswordModel';

@LogAll
export default class PasswordSettingController extends BaseSettingsController {
  private TAG = ConfigData.TAG + 'PasswordSettingController ';
  private pinChallenge: string = '';
  private passwordList: PasswordSettingItem[][] = [];

  subscribe(): ISettingsController {
    return this;
  };

  unsubscribe(): ISettingsController {
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
      this.getListData(passwordHasSet , (list: PasswordSettingItem[][]) => {
        this.passwordList = undefined
        this.passwordList = list
      });
    });
  }

/**
   * Get password list data
   *
   * @param boolean
   * @param callback
   */
  getListData(passwordHasSet: boolean, callback: (list: PasswordSettingItem[][]) => void): void {
    let list: PasswordSettingItem[][] = PasswordModel.getPageData();

    list.forEach(group => {
      group.forEach(item => {
        let shouldDisplay = true;
        switch (item.settingAlias) {
          case 'biometrics_section_title':
          case 'password_section_title':
          case 'password_change_password':
          case 'password_disable_password':
            shouldDisplay = passwordHasSet;
            break;
          case 'password_lock_screen':
            shouldDisplay = !passwordHasSet;
            break;
        }

        item.settingShouldDisplay = shouldDisplay;
      });
    });
    callback(list)

  }
}


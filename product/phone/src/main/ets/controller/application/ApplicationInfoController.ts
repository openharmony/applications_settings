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

import {LogAll} from '../../../../../../../common/utils/src/main/ets/default/baseUtil/LogDecorator';
import AppManagementModel from '../../model/appManagementImpl/AppManagementModel';
import BaseSettingsController from '../../../../../../../common/component/src/main/ets/default/controller/BaseSettingsController';
import LogUtil from '../../../../../../../common/utils/src/main/ets/default/baseUtil/LogUtil';
import ConfigData from '../../../../../../../common/utils/src/main/ets/default/baseUtil/ConfigData';

const MODULE_TAG = ConfigData.TAG + 'application-> ';

@LogAll
export default class ApplicationInfoController extends BaseSettingsController {

  /**
   * Get Uninstall api
   */
   uninstall(bundleName: string) {
    LogUtil.info(ConfigData.TAG + "start uninstall in controller");
    AppManagementModel.uninstall(bundleName, (err, data) => {
      LogUtil.info(ConfigData.TAG + 'uninstall in controller' + ' bundleName: ' + bundleName
      +' err: ' + JSON.stringify(err) +' data: ' + JSON.stringify(data));
    });
    LogUtil.info(ConfigData.TAG + "end uninstall in controller");
  }

 /**
  * Kill processes by bundle name
  */
  killProcessesByBundleName(bundleName: string) {
    AppManagementModel.killProcessesByBundleName(bundleName, (err) => {
      LogUtil.info(ConfigData.TAG + 'killProcessesByBundleName err : ' + JSON.stringify(err) + 'bundleName:' + bundleName);
    });
  }

  getBundleInfo(bundleName, callback) {
    LogUtil.info(MODULE_TAG + 'start get bundle info at controller');
    AppManagementModel.getBundleInfo(bundleName, callback);
    LogUtil.info(MODULE_TAG + 'end get bundle info  at controller');
  }
}
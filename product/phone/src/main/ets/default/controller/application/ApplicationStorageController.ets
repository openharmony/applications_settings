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

import {LogAll} from '../../../../../../../../common/utils/src/main/ets/default/baseUtil/LogDecorator.ets';
import AppManagementModel from '../../model/appManagementImpl/AppManagementModel.ets';
import BaseSettingsController from '../../../../../../../../common/component/src/main/ets/default/controller/BaseSettingsController.ets';
import LogUtil from '../../../../../../../../common/utils/src/main/ets/default/baseUtil/LogUtil.ets';
import ConfigData from '../../../../../../../../common/utils/src/main/ets/default/baseUtil/ConfigData.ets';

@LogAll
export default class ApplicationStorageController extends BaseSettingsController {

  /**
   * Clear up application data by bundle name
   * @param bundleName bundle name
   */
  clearUpApplicationData(bundleName: string) {
    AppManagementModel.clearUpApplicationData(bundleName, (err) => {
      LogUtil.info(ConfigData.TAG + 'clearUpApplicationData err : ' + JSON.stringify(err) + 'bundleName:' + bundleName);
    });
  }

  /**
   * Clears cache data of a specified application
   * @param bundleName bundle name
   */
  cleanBundleCacheFiles(bundleName: string) {
    AppManagementModel.cleanBundleCacheFiles(bundleName, (err) => {
      LogUtil.info(ConfigData.TAG + 'cleanBundleCacheFiles err : ' + JSON.stringify(err) + 'bundleName:' + bundleName);
    });
  }

  /**
   * Get storageList
   */
  getStorageList() {
    return AppManagementModel.getStorageList();
  }
}
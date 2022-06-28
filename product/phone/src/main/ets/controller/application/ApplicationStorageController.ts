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
import ISettingsController from '../../../../../../../common/component/src/main/ets/default/controller/ISettingsController'
import { BaseData } from '../../../../../../../common/utils/src/main/ets/default/bean/BaseData';

@LogAll
export default class ApplicationStorageController extends BaseSettingsController {
  private storageList: BaseData[]= [];

  initData(): ISettingsController{
    super.initData();
    this.getStorageList();
    return this;
  }

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

    let totalTab = new BaseData()
    totalTab.settingTitle = $r('app.string.totalTab');
    let applyTab = new BaseData()
    applyTab.settingTitle = $r('app.string.applyTab');
    let dataTab = new BaseData()
    dataTab.settingTitle = $r('app.string.dataTab');

    let list: BaseData[] = []
    list.push(totalTab)
    list.push(applyTab)
    list.push(dataTab)

    this.storageList = list


  }

/**
  * Set titleValue
  */
  setTitleValue(baseData) {
    let titleValue;
    for (let key in baseData) {
      let settingAlias = baseData[key].settingAlias;
      if ('totalTab' === settingAlias) {
        titleValue = $r('app.string.totalTab')
      } else if ('applyTab' === settingAlias) {
        titleValue = $r('app.string.applyTab')
      } else if ('dataTab' === settingAlias) {
        titleValue = $r('app.string.dataTab')
      }
      baseData[key].settingTitle = titleValue
    }
    return baseData;
  }

}
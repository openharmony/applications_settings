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
import StorageModel from '../../model/StorageImpl/StorageModel.ets'
import {LogAll} from '../../../../../../../../common/utils/src/main/ets/default/baseUtil/LogDecorator.ets';
import LogUtil from '../../../../../../../../common/utils/src/main/ets/default/baseUtil/LogUtil.ets';
import ConfigData from '../../../../../../../../common/utils/src/main/ets/default/baseUtil/ConfigData.ets';
import BaseSettingsController from '../../../../../../../../common/component/src/main/ets/default/controller/BaseSettingsController.ets';
import ISettingsController from '../../../../../../../../common/component/src/main/ets/default/controller/ISettingsController'

enum Space {
  /**
  * Total space
  */
  TOTAL_SPACE = '0',
  /**
  * Used space
  */
  USED_SPACE = '1',
  /**
  * Remaining space
  */
  REMAINING_SPACE = '2'
}

@LogAll
export default class storageController  extends BaseSettingsController {
  private storageList: any[] = [];
  private totalSpace: number;
  private freeBytes: number;
  private usedSpace: number;

  initData(): ISettingsController{
    super.initData();
    this.getTotalSpace();
    return this;
  }

  /**
   * get TotalSpace
   */
  getTotalSpace() {
    StorageModel.getStorageDataDir((err, data: string) => {
      LogUtil.info(ConfigData.TAG + 'getStorageDataDir err: ' + JSON.stringify(err));
      LogUtil.info(ConfigData.TAG + 'getStorageDataDir data: ' + JSON.stringify(data));
      if (data && data.length > 0) {
        StorageModel.getTotalSpace(data, (err, data) => {
          LogUtil.info(ConfigData.TAG + 'getTotalSpace err: ' + JSON.stringify(err));
          LogUtil.info(ConfigData.TAG + 'getTotalSpace data: ' + JSON.stringify(data));
          if (data && data >= 0) {
            LogUtil.info(ConfigData.TAG + 'getTotalSpace success');
            this.totalSpace = data;
            this.getFreeBytes();
          }
        });
      }
    });
  }

  /**
   * get RemainingSpace
   */
  getFreeBytes() {
    StorageModel.getStorageDataDir((err, data) => {
      LogUtil.info(ConfigData.TAG + 'getStorageDataDir err: ' + JSON.stringify(err));
      LogUtil.info(ConfigData.TAG + 'getStorageDataDir data: ' + JSON.stringify(data));
      if (data && data.length > 0) {
        StorageModel.getFreeBytes(data, (err, data) => {
          LogUtil.info(ConfigData.TAG + 'getFreeBytes err: ' + JSON.stringify(err));
          LogUtil.info(ConfigData.TAG + 'getFreeBytes data: ' + JSON.stringify(data));
          if (data && data >= 0) {
            this.storageList = [];
            LogUtil.info(ConfigData.TAG + 'getFreeBytes success');
            this.freeBytes = data;
            this.getUsedSpace();
            this.storageList = this.getStorageList();
          }
        });
      }
    });
  }

  /**
   * get UsedSpace
   */
  getUsedSpace(){
    this.usedSpace = this.totalSpace - this.freeBytes;
  }

  /**
   * Get storage List
   */
  getStorageList() {
    let storageList =  StorageModel.getStorageItemList();
    for (let key in storageList) {
      LogUtil.info(ConfigData.TAG + 'Storage getStorageList key:' + key);
      switch (key) {
        case Space.TOTAL_SPACE:
          storageList[key].settingTitle = $r('app.string.totalSpace')
          storageList[key].settingValue = this.formatData(this.totalSpace);
          break;
        case Space.USED_SPACE:
          storageList[key].settingTitle = $r('app.string.usedSpace');
          storageList[key].settingValue = this.formatData(this.usedSpace);
          break;
        case Space.REMAINING_SPACE:
          storageList[key].settingTitle = $r('app.string.remainingSpace');
          storageList[key].settingValue = this.formatData(this.freeBytes);
          break;
      }
    }
    LogUtil.info(ConfigData.TAG + 'Storage getStorageList storageTitleValue out:' + JSON.stringify(storageList));
    return storageList;
  }

  /**
   * format data
   */
  formatData(val) {
    let result = '';
    if (val < 1024) {
      result = `${val} B`;
    } else if (val < 1024 * 1024) {
      result = `${(val / 1024).toFixed(2)} KB`;
    } else if (val < 1024 * 1024 * 1024) {
      result = `${(val / (1024 * 1024)).toFixed(2)} MB`;
    } else if (val < 1024 * 1024 * 1024 * 1024) {
      result = `${(val / (1024 * 1024 * 1024)).toFixed(2)} GB`;
    }
    return result;
  }
}
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
import DataRdbModel from './DataRdbModel';
import Stable from '../../../../../../common/utils/src/main/ets/default/baseUtil/Global';
import LogUtil from '../../../../../../common/utils/src/main/ets/default/baseUtil/LogUtil';
import ConfigData from '../../../../../../common/utils/src/main/ets/default/baseUtil/ConfigData';

class DataRdbService {
  /**
   * query
   */
  queryAllData(callback) {
    DataRdbModel.queryAllData(Stable.tableName.Global, res => {
      LogUtil.info(ConfigData.TAG + 'get data query model result: ' + JSON.stringify(res));
      callback(res);
    });
  }
  /**
   * query
   */
  querySingleData(key, callback) {
    DataRdbModel.querySingleData(Stable.tableName.Global, key, res => {
      LogUtil.info(ConfigData.TAG + 'get data query model querySingleData result: ' + JSON.stringify(res));
      callback(res);
    });
  }
  /**
   * insert
   */
  insertDataService(valueBucket) {
    LogUtil.info(ConfigData.TAG + 'get data insert service start');
    DataRdbModel.insertDataModel(Stable.tableName.Global, valueBucket, res => {
      LogUtil.info(ConfigData.TAG + 'get data insert service result: ' + JSON.stringify(res));
    });
    LogUtil.info(ConfigData.TAG + 'get data insert service end');
  }

  /**
   * delete
   */
  async deleteData(keys) {
    LogUtil.info(ConfigData.TAG + 'get data delete service start' + keys);
    for (let key of keys) {
      LogUtil.info(ConfigData.TAG + 'get data delete key:' + key);
      await DataRdbModel.deleteData(Stable.tableName.Global, key);
      LogUtil.info(ConfigData.TAG + 'get data delete service end');
    }
  }
  /**
   * update
   */
  async updateData(keys, valueBucket) {
    LogUtil.info(ConfigData.TAG + 'get data update service start' + keys);
    for (let key of keys) {
      LogUtil.info('get data update key:' + key);
      await DataRdbModel.updateData(Stable.tableName.Global, key, valueBucket);
      LogUtil.info(ConfigData.TAG + 'get data update service end');
    }
  }
}

let service = new DataRdbService();
export default service;
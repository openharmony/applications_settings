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
import Stable from '../../../../../../common/utils/src/main/ets/default/baseUtil/Global';
import rdbStore from '../../../../../../common/utils/src/main/ets/default/baseUtil/RdbStoreUtil';
import LogUtil from '../../../../../../common/utils/src/main/ets/default/baseUtil/LogUtil';
import ConfigData from '../../../../../../common/utils/src/main/ets/default/baseUtil/ConfigData';

class DataRdbModel {
  insertValues: any[] = [
    {
      "settingTitle": "systemName",
      "settingValue": "OpenHarmony"
    },
    {
      "settingTitle": "model",
      "settingValue": 11111
    },
    {
      "settingTitle": "companyInfo",
      "settingValue": 2222
    },
    {
      "settingTitle": "deviceId",
      "settingValue": 3333
    },
    {
      "settingTitle": "softwareVersion",
      "settingValue": 4444
    }
  ]

/**
   * query
   */
  async queryAllData(tableName, callback) {
    LogUtil.info(ConfigData.TAG + 'get data queryAllData start')
    let predicates = rdbStore.getRdbPredicates(tableName)
    let results = []
    LogUtil.info(ConfigData.TAG + 'get data queryAllData predicates:' + JSON.stringify(predicates))
    let resultSet = await rdbStore.getRdbStore().query(predicates)
    while (resultSet.goToNextRow()) {
      let result = {
        key: '',
        value: ''
      };
      result.value = resultSet.getString(resultSet.getColumnIndex(Stable.Global.value))
      result.key = resultSet.getString(resultSet.getColumnIndex(Stable.Global.key))
      results.push(result)
    }
    LogUtil.info(ConfigData.TAG + 'get data queryAllData end' + JSON.stringify(results))
    callback(results)
  }

/**
   * insert
   */
  async insertDataModel(tableName, rowValue, callback) {
    LogUtil.info(ConfigData.TAG + 'get data insert model start rowValue:' + JSON.stringify(rowValue));
    let result = {
      rowId: -1
    }
    let insertPromise = rdbStore.insert(tableName, rowValue);
    insertPromise.then(rowId => {
      LogUtil.info(ConfigData.TAG + 'get data insert model num' + rowId);
      result.rowId = rowId;
      callback(result);
    })
      .catch((err) => {
      LogUtil.info(ConfigData.TAG + 'get data insert model err' + err);
      callback(result);
    })
    LogUtil.info(ConfigData.TAG + 'get data insert model end');
  }
/**
   * delete
   */
  async deleteData(tableName, key) {
    LogUtil.info(ConfigData.TAG + 'get data delete model start: ' + key);
    let predicates = rdbStore.getRdbPredicates(tableName);
    await predicates.equalTo(Stable.Global.key, key);
    rdbStore.deleteItem(predicates);
    LogUtil.info(ConfigData.TAG + 'get data delete model end ');
  }
/**
   * update
   */
  async updateData(tableName, key, rowValue) {
    LogUtil.info(ConfigData.TAG + 'get data update model start: ' + key);
    let predicates = rdbStore.getRdbPredicates(tableName);
    await predicates.equalTo(Stable.Global.key, key);
    rdbStore.update(predicates, rowValue);
    LogUtil.info(ConfigData.TAG + 'get data update model end ');
  }

/**
   * query
   */
  async querySingleData(tableName, key, callback) {
    LogUtil.info(ConfigData.TAG + 'get data querySingleData start key:' + key);
    let predicates = rdbStore.getRdbPredicates(tableName);
    let results = [];
    LogUtil.info(ConfigData.TAG + 'get data querySingleData predicates:' + JSON.stringify(predicates));
    if (null !== key) {
      LogUtil.info(ConfigData.TAG + 'get data querySingleData equalTo predicates:' + JSON.stringify(predicates));
      await predicates.equalTo(Stable.Global.key, key);
    }
    let resultSet = await rdbStore.getRdbStore().query(predicates);
    LogUtil.info(ConfigData.TAG + 'get data querySingleData resultSet:' + JSON.stringify(resultSet));
    while (resultSet.goToNextRow()) {
      let result = {
        key: '',
        value: ''
      };
      result.value = resultSet.getString(resultSet.getColumnIndex(Stable.Global.value));
      result.key = resultSet.getString(resultSet.getColumnIndex(Stable.Global.key));
      results.push(result);
    }
    LogUtil.info(ConfigData.TAG + 'get data querySingleData results ' + JSON.stringify(results));
    callback(results);
  }
}


let dataRdbModel = new DataRdbModel();
export default dataRdbModel;
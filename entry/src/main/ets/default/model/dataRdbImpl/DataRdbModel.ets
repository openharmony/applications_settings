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
import Stable from '../../common/baseUtil/settings_table.ets'
import rdbStore from '../../common/baseUtil/RdbStoreUtil.ets'
import LogUtil from '../../common/baseUtil/LogUtil.ets';
 class DataRdbModel {
  specifyNumbers: any[] = [
    {
      "settingAlias": "systemName",
      "settingTitle": "",
      "settingValue": "OpenHarmony"
    },
    {
      "settingAlias": "model",
      "settingTitle": "",
      "settingValue": ""
    },
    {
      "settingAlias": "companyInfo",
      "settingTitle": "",
      "settingValue": ""
    },
    {
      "settingAlias": "deviceId",
      "settingTitle": "",
      "settingValue": "00000000000000"
    },
    {
      "settingAlias": "softwareVersion",
      "settingTitle": "",
      "settingValue": ""
    }
  ]

/**
   * query
   */
  async querySpecifyNumber(tableName, callback) {
    LogUtil.info("get data query data start")
    let predicates = rdbStore.getRdbPredicates(tableName)
    let results = []
    let resultSet = await rdbStore.getRdbStore().query(predicates)
    while(resultSet.goToNextRow()) {
      let result = {
        id: -1,
        settingAlias: '',
        settingTitle: '',
        settingValue: ''
      };
      result.id = resultSet.getLong(resultSet.getColumnIndex(Stable.aboutDevice.id))
      result.settingAlias = resultSet.getString(resultSet.getColumnIndex(Stable.aboutDevice.settingAlias))
      result.settingTitle = resultSet.getString(resultSet.getColumnIndex(Stable.aboutDevice.settingTitle))
      result.settingValue = resultSet.getString(resultSet.getColumnIndex(Stable.aboutDevice.settingValue))
      results.push(result)
    }
    LogUtil.info("get data query data end" + JSON.stringify(results))
    callback(results)
  }

/**
   * insert
   */
  insertDataModel(tableName, valueBucket, callback) {
    LogUtil.info("get data insert model start")
    let insertPromise = rdbStore.insert(tableName, valueBucket)
    let result = {
      rowId: -1
    }
    insertPromise.then(number => {
      LogUtil.info("get data insert model num" + number)
      result.rowId = number
      callback(result)
    }).catch((err) => {
      callback(result)
    })
    LogUtil.info("get data insert model end")
  }
/**
   * delete
   */
  async deleteSpecifyNumber(tableName, number) {
    LogUtil.info("get data delete model start: " + number)
    let predicates = rdbStore.getRdbPredicates(tableName)
    await predicates.equalTo(Stable.aboutDevice.settingAlias, number)
    rdbStore.deleteItem(predicates)
    LogUtil.info("get data delete model end ")
  }
/**
   * update
   */
   async updateSpecifyNumber(tableName, number, valueBucket) {
     LogUtil.info("get data update model start: " + number)
     let predicates = rdbStore.getRdbPredicates(tableName);
     await predicates.equalTo(Stable.aboutDevice.settingAlias, number)
     rdbStore.update(predicates,valueBucket)
     LogUtil.info("get data update model end ")
   }
}


let dataRdbModel = new DataRdbModel();
export default dataRdbModel
;
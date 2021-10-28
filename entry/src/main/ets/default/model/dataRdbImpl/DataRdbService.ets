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
import DataRdbModel from './DataRdbModel.ets';
import Stable from '../../common/baseUtil/settings_table.ets';
import LogUtil from '../../common/baseUtil/LogUtil.ets';
class DataRdbService {
/**
   * query
   */
  querySpecifyNumber(callback) {
    DataRdbModel.querySpecifyNumber(Stable.tableName.aboutDevice, res => {
      console.info("get data query model result: " + JSON.stringify(res))
      callback(res)
    })
  }
/**
   * insert
   */
  insertDataService(valueBucket) {
    LogUtil.info('get data insert service start')
    DataRdbModel.insertDataModel(Stable.tableName.aboutDevice, valueBucket, res => {
      LogUtil.info("get data insert service result: " + JSON.stringify(res))
    })
    LogUtil.info('get data insert service end')
  }

/**
   * delete
   */
  async deleteSpecifyNumber(numbers) {
    LogUtil.info('get data delete service start'+ numbers)
    for (let number of numbers) {
      LogUtil.info('get data delete number' + number)
      await DataRdbModel.deleteSpecifyNumber(Stable.tableName.aboutDevice, number)
      LogUtil.info('get data delete service end')
    }
  }
/**
   * update
   */
  async updateSpecifyNumber(numbers,valueBucket) {
    LogUtil.info('get data update service start'+ numbers)
    for (let number of numbers) {
      LogUtil.info('get data update number' + number)
      await DataRdbModel.updateSpecifyNumber(Stable.tableName.aboutDevice,number,valueBucket)
      LogUtil.info('get data update service end')
    }
  }
}

let service = new DataRdbService()
export default service
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

import BaseModel from '../../../../../../../common/utils/src/main/ets/default/model/BaseModel';
import {LogAll} from '../../../../../../../common/utils/src/main/ets/default/baseUtil/LogDecorator';
import { BaseData } from '../../../../../../../common/utils/src/main/ets/default/bean/BaseData';
import storage from '@ohos.statfs';
import Environment from '@ohos.file.environment'

/**
  * read local file
  */
@LogAll
export class StorageModel extends BaseModel {

  /**
   * Get Storage ItemList
   */
  getStorageItemList(): any[] {
    return [ new BaseData(), new BaseData() ]
  }

  /**
   * Get storage dataDir
   */
  getStorageDataDir(callback){
    Environment.getStorageDataDir(callback);
  }

  /**
   * get TotalSpace
   */
  getTotalSpace(storageDataDir, callback){
    storage.getTotalBytes(storageDataDir, callback);
  }

  /**
   * get FreeBytes
   */
  getFreeBytes(storageDataDir, callback){
    storage.getFreeBytes(storageDataDir, callback);
  }

}

let storageModel = new StorageModel();

export default storageModel as StorageModel
;
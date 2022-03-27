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
import BaseModel from './BaseModel';
import LogUtil from '../baseUtil/LogUtil';
import FileIo from '@ohos.fileio';
import { BaseData } from '../bean/BaseData';

const DFAULT_SIZE = 4096;
const CHAR_CODE_AT_INDEX = 0;

/**
  * read local file
  */
export class BaseParseConfModel extends BaseModel {
  public getJsonData(fileName: string): BaseData[]{
    LogUtil.info('settings BaseParseConfModel getJsonData in');
    return this.readLocalFile(fileName);
    LogUtil.info('settings BaseParseConfModel getJsonData end');
  }

  public getJsonDataBase(fileName, callback) {
    LogUtil.info('settings BaseParseConfModel getJsonDataBase in');
    callback(this.readLocalFile(fileName));
    LogUtil.info('settings BaseParseConfModel getJsonDataBase end');
  }
  /**
   * read local file
   * @param fileName - file name
   */
  readLocalFile(fileName): BaseData[]{
    try {
      let stream = FileIo.createStreamSync(fileName, 'r');
      LogUtil.info('settings BaseParseConfModel getJsonData try stream:' + stream);
      let buf = new ArrayBuffer(DFAULT_SIZE);
      let len = stream.readSync(buf);
      LogUtil.info('settings BaseParseConfModel getJsonData try len:' + len);
      let arr = new Uint8Array(buf);
      let charAt = ' '.charCodeAt(CHAR_CODE_AT_INDEX);
      for (let i = len;i < DFAULT_SIZE; i++) {
        arr[i] = charAt;
      }
      let content = String.fromCharCode.apply(null, arr);
      stream.closeSync();
      LogUtil.info('settings BaseParseConfModel getJsonData try content:' + JSON.stringify(content));
      return JSON.parse(content);
    } catch (jsonError) {
      LogUtil.info('settings BaseParseConfModel getJsonData catch jsonError:' + jsonError);
    }
  }
}

let baseParseConfModel = new BaseParseConfModel();

export default baseParseConfModel as BaseParseConfModel
;
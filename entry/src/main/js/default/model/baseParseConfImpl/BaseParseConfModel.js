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
import BaseModel from '../BaseModel.js';
import fileio from '@ohos.fileio';

export default class BaseParseConfModel extends BaseModel {
    getJsonData(fileName) {
        console.info('settings dateAndTime BaseParseConfModel getJsonData start')
        try {
            console.info('settings dateAndTime BaseParseConfModel getJsonDat start try');
            var ss = fileio.createStreamSync(fileName, "r")
            var buf = new ArrayBuffer(4096)
            var len = ss.readSync(buf)
            console.info('settings dateAndTime BaseParseConfModel getJsonData len' + JSON.stringify(len) + len);
            var content = String.fromCharCode.apply(null, new Uint8Array(buf));
            console.info('settings dateAndTime BaseParseConfModel getJsonData content:' + content);
            ss.closeSync();
            return JSON.parse(content);
        } catch (jsonError) {
            console.info('settings dateAndTime BaseParseConfModel getJsonData catch jsonError:' + jsonError);
        }
    }
}
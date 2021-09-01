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
import LogUtil from '../../common/baseUtil/LogUtil.js';
import Fileio from '@ohos.fileio';

let mLogUtil = null;

export default class BaseParseConfModel extends BaseModel {
    constructor() {
        super();
        mLogUtil = new LogUtil();
    }

    getJsonData(fileName) {
        mLogUtil.info('settings dateAndTime BaseParseConfModel getJsonData start');
        try {
            mLogUtil.info('settings dateAndTime BaseParseConfModel getJsonDat start try');
            let ss = Fileio.createStreamSync(fileName, 'r');
            let buf = new ArrayBuffer(4096);
            let len = ss.readSync(buf);
            mLogUtil.info('settings dateAndTime BaseParseConfModel getJsonData len' + JSON.stringify(len) + len);
            let arr = new Uint8Array(buf);
            let charAt = ' '.charCodeAt(0);
            for (let i = len; i < 4096; i++) {
                arr[i] = charAt;
            }
            let content = String.fromCharCode.apply(null, arr);
            mLogUtil.info('settings dateAndTime BaseParseConfModel getJsonData content:' + content);
            ss.closeSync();
            return JSON.parse(content);
        } catch (jsonError) {
            mLogUtil.info('settings dateAndTime BaseParseConfModel getJsonData catch jsonError:' + jsonError);
        }
    }
}
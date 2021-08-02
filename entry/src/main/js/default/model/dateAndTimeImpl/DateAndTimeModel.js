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
import SystemTime from '@ohos.systemTime';

let mLogUtil = null;

export default class DateAndTimeModel extends BaseModel {
    constructor() {
        super();
        mLogUtil = new LogUtil();
    }

    setTime(time) {
        mLogUtil.info('setting dateAndTime setTime start');
        SystemTime.setTime(time).then(data => {
            mLogUtil.info('setting dateAndTime AceApplication promise1::then ' + data);
        })
            .catch(error => {
                mLogUtil.info('setting dateAndTime AceApplication promise1::catch ' + error);
            }
        );
        mLogUtil.info('setting dateAndTime setTime end');
    }
}
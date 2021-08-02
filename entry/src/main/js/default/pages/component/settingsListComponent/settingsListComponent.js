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
import router from '@system.router';
import LogUtil from '../../../common/baseUtil/LogUtil.js';

let mLogUtil = null;

export default {
    props: {
        parentData: {
            default: '',
        },
        listShow: {
            default: true,
        }
    },
    data: {},

    onInit() {
        mLogUtil = new LogUtil();
    },

    onclick(data) {
        mLogUtil.info('setting settingsListComponent onclick start: ' + JSON.stringify(data.detail.text));
        router.push({
            uri: data.detail.text.settingUri,
            params: {
                dataParam: data.detail.text,
            }
        });
        mLogUtil.info('setting settingsListComponent onclick end: ');
    },

    switchClick(e) {
        mLogUtil.info('setting settingsListComponent switchClick start: ');
        this.switchChangeValue = e.detail.text;
        this.switchDefaultChangeValue = e.detail.defaultText;
        mLogUtil.info('ListComponent switchClick end:' + this.switchChangeValue + '|' + this.switchDefaultChangeValue);
    }
};


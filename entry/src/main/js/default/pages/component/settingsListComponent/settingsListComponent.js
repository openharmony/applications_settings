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

let logUtil = new LogUtil();

export default {
    props: {
        //Receive the value passed by the parent component
        parentData: {
            default: '',
        },
        listShow: {
            default: true,
        }
    },
    data: {},

    /**
     * Jump to the corresponding lower menu
     */
    onclick(e) {
        logUtil.info('setting settingsListComponent onclick start: ' + JSON.stringify(e.detail.text));
        router.push({
            uri: e.detail.text.settingUri,
            params: {
                dataParam: e.detail.text,
            }
        });
        logUtil.info('setting settingsListComponent onclick end: ');
    },
    /**
     * switch Onchange get the value
     * @param e
     * @return
     */
    switchClick(e) {
        logUtil.info('setting settingsListComponent switchClick start: ');
        this.switchChangeValue = e.detail.text,
        this.switchDefaultChangeValue = e.detail.defaultText
        logUtil.info('setting settingsListComponent switchClick end:' + this.switchChangeValue + '|' + this.switchDefaultChangeValue);
    }
}


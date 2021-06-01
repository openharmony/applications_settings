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

const DATA_PAGE_SOURCE_HOME_PAGE = 'homePage';
const DATA_PAGE_SOURCE_APP_PAGE = 'appPage';

export default {
    data: {
        /**
         * setting homepage date list
         */
        settingsList: [],
         /**
         * Application management list
         */
        appList: [],
         /**
         * search result list
         */
        searchList: [],
        /**
         * Page source
         * homePage：homePage, appManage：appPage
         */
        type: null,
    },
    onInit() {
        this.settingsList = this.data;
        this.appList = this.appData;
        this.type = this.type;
    },

    /**
     * Get the value in the search box
     */
    getValue: function (e) {
        this.clickSearch(e.text);
    },

    /**
     * Search app
     * @param e
     * @return
     */
    clickSearch(e) {
        if (e == null) {
            return;
        }
        this.searchList = [];
        if (this.type == DATA_PAGE_SOURCE_HOME_PAGE) {
            this.settingsList.forEach((element) => {
                if ((element.settingTitle).includes(e) && '' != e) {
                    this.searchList.push(element);
                }
            })
        }
        else if (this.type == DATA_PAGE_SOURCE_APP_PAGE) {
            this.appList.forEach((element) => {
                if ((element.settingTitle).includes(e) && '' != e) {
                    this.searchList.push(element);
                }
            })
        }
    },
    searchBack() {
        router.back();
    },
    onBackPress() {
        router.back();
    }
}
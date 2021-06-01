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
import BaseParseConfModel from '../../model/baseParseConfImpl/BaseParseConfModel.js';
import LogUtil from '../../common/baseUtil/LogUtil.js';
import DateAndTimeUtil from '../../common/baseUtil/DateAndTimeUtil.js';
import systemTime from '@ohos.systemTime';

let logUtil = new LogUtil();
let dateAndTimeUtil = null;
let baseParseConfModel = new BaseParseConfModel();

globalThis.$globalT = null;

export default {
    data: {
        date: '', //The date displayed on the current page
        time: '', //The time displayed on the current page
        currentDate: '',
        currentTime: '',
        inner_title: '', //Title information on the time frame
        intervalFlag: '', //Timer flag
        dateAndTimeList: [],
        dateAndTimeListData: 'dateAndTimeList',
    },
    /**
     * init
     */
    onInit() {
        logUtil.info('settings dateAndTime onInit start')
        globalThis.$globalT = this.$t.bind(this);
        dateAndTimeUtil = new DateAndTimeUtil();
        this.dateAndTimeList = baseParseConfModel.getJsonData('/data/accounts/account_0/applications/com.ohos.settings/com.ohos.settings/assets/entry/resources/rawfile/dateAndTime.json');
        for (let key in this.dateAndTimeList) {
            var settingAlias = this.dateAndTimeList[key].settingAlias
            this.dateAndTimeList[key].settingTitle = this.$t('strings.'.concat(settingAlias))
        }
        logUtil.info('settings dateAndTime onInit dateAndTimeList：' + JSON.stringify(this.dateAndTimeList));
        const dateTime = new Date();
        const year = dateTime.getFullYear();
        const month = dateTime.getMonth() + 1;
        const day = dateTime.getDate();
        this.date = dateAndTimeUtil.concatDate(year, month, day);
        this.time = dateAndTimeUtil.now();
        this.changeValue();
        let that = this
        this.intervalFlag = setInterval(function () {
            that.time = dateAndTimeUtil.now();
            that.changeValue();
        }, 1000);
        logUtil.info('settings dateAndTime onInit  end：' + JSON.stringify(this.dateAndTimeList));
    },
    /**
     * Stop refresh
     */
    onDestroy() {
        logUtil.info('setting dateAndTime onDestroy start')
        clearInterval(this.intervalFlag)
        logUtil.info('setting dateAndTime onDestroy end')
    },
    /**
     * Assignment conversion
     */
    changeValue() {

        for (let key in this.dateAndTimeList) {
            let settingAlias = this.dateAndTimeList[key].settingAlias;
            if (settingAlias == 'date') {
                this.dateAndTimeList[key].settingValue = this.date;
            } else if (settingAlias == 'time') {
                this.dateAndTimeList[key].settingValue = this.time;
            }
        }
    },
    /**
     * Enter to select sub-page details
     * @param index
     * @return
     */
    clickToDetail(index) {
        logUtil.info('setting dateAndTime clickToDetail start')
        let settingAlias = this.dateAndTimeList[index].settingAlias;
        if (settingAlias == 'date') {
            const datetime = new Date();
            const y = datetime.getFullYear();
            const m = datetime.getMonth() + 1;
            const d = datetime.getDate();
            this.currentDate = this.date;
            this.inner_title = this.currentDate + dateAndTimeUtil.convert(y, m, d);
            this.$element('dateDialog').show();
        }
        else if (settingAlias == 'time') {
            this.currentTime = this.time;
            this.$element('timeDialog').show();
        }
        else {
        }
        logUtil.info('setting dateAndTime clickToDetail end')
    },
    /**
     * Cancel the bullet box
     * @return
     */
    cancelSchedule() {
        logUtil.info('setting dateAndTime cancelSchedule start')
        this.$element('dateDialog').close()
        this.$element('timeDialog').close()
        logUtil.info('setting dateAndTime cancelSchedule end')
    },
    /**
     * Modify date
     * @return
     */
    setDateSchedule() {
        logUtil.info('setting dateAndTime setDateSchedule start')
        this.$element('dateDialog').close();
        if (this.currentDate != this.date) {
            logUtil.info('dateDialog init start:: current date is' + this.currentDate);
            this.date = this.currentDate;
            this.inner_title = this.date + this.week;
            this.changeValue();
        }
        logUtil.info('setting dateAndTime setDateSchedule end')
    },
    /**
     * Modify time
     * @return
     */
    setTimeSchedule() {
        logUtil.info('setting dateAndTime setTimeSchedule start')
        this.$element('timeDialog').close();
        if (this.currentTime != this.time) {
            logUtil.info('timeDialog init start:: current time is' + this.currentTime);
            const datetime = new Date();
            const y = datetime.getFullYear();
            const m = datetime.getMonth() + 1;
            const d = datetime.getDate();
            const str = y + "/" + dateAndTimeUtil.fill(m) + "/" + dateAndTimeUtil.fill(d) + " " + this.currentTime + ":" + "00"
            logUtil.info('timeDialog init start::' + str);
            const s = (new Date(str)).getTime();
            logUtil.info('timeDialog time::' + s);
            this.setTime(s);
            this.time = this.currentTime;
            logUtil.info('timeDialog time::' + this.time);
            this.changeValue();
        }
        logUtil.info('setting dateAndTime setTimeSchedule end')
    },
    setTime(time) {
        console.log('setting dateAndTime setTime start');
        systemTime.setTime(time).then(data =>
        console.log('setting dateAndTime AceApplication promise1::then ' + data))
            .catch(error =>
        console.log('setting dateAndTime AceApplication promise1::catch ' + error));
        console.log('setting dateAndTime setTime end');
    },
    /**
     * Date drag
     * @param data
     * @return
     */
    handleDateChange(data) {
        logUtil.info('setting dateAndTime handleDateChange start')
        this.currentDate = dateAndTimeUtil.concatDate(data.year, data.month + 1, data.day);
        this.inner_title = this.currentDate + dateAndTimeUtil.convert(data.year, data.month + 1, data.day);
        logUtil.info('setting dateAndTime handleDateChange end')
    },
    /**
     * Time drag
     * @param data
     * @return
     */
    handleTimeChange(data) {
        logUtil.info('setting dateAndTime handleTimeChange start')
        this.currentTime = dateAndTimeUtil.concatTime(data.hour, data.minute);
        logUtil.info('setting dateAndTime handleTimeChange end')
    },
    /**
     * Return to the previous menu
     */
    back() {
        logUtil.info('settings dateAndTime back start:')
        router.back();
        logUtil.info('settings dateAndTime back end:')
    },
    onCreate() {
        logUtil.info('settings dateAndTime onCreate')
    },
    onReady() {
        logUtil.info('settings dateAndTime onReady')
    },
    onHide() {
        logUtil.info('settings dateAndTime onHide')
    }
}






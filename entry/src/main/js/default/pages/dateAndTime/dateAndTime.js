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
import Router from '@system.router';
import BaseParseConfModel from '../../model/baseParseConfImpl/BaseParseConfModel.js';
import LogUtil from '../../common/baseUtil/LogUtil.js';
import DateAndTimeUtil from '../../common/baseUtil/DateAndTimeUtil.js';
import DateAndTimeModel from '../../model/dateAndTimeImpl/DateAndTimeModel.js';

let mLogUtil = null;
let mDateAndTimeUtil = null;
let mBaseParseConfModel = null;
let mDateAndTimeModel = null;
globalThis.$globalT = null;

export default {
    data: {
        date: '', //The date displayed on the current page
        time: '', //The time displayed on the current page
        currentDate: '',
        currentTime: '',
        innerTitle: '', //Title information on the time frame
        intervalFlag: '', //Timer flag
        dateAndTimeList: [],
        dateAndTimeListData: 'dateAndTimeList',
    },

    onInit() {
        mLogUtil = new LogUtil();
        mLogUtil.info('settings dateAndTime onInit start');
        globalThis.$globalT = this.$t.bind(this);
        mDateAndTimeUtil = new DateAndTimeUtil();
        mBaseParseConfModel = new BaseParseConfModel();
        mDateAndTimeModel = new DateAndTimeModel();
        this.dateAndTimeList = mBaseParseConfModel.getJsonData('/data/accounts/account_0/applications'
            + '/com.ohos.settings/com.ohos.settings/assets/entry/resources/rawfile/dateAndTime.json');
        for (let key in this.dateAndTimeList) {
            let settingAlias = this.dateAndTimeList[key].settingAlias;
            this.dateAndTimeList[key].settingTitle = this.$t('strings.'.concat(settingAlias));
        }
        mLogUtil.info('settings dateAndTime onInit dateAndTimeList：' + JSON.stringify(this.dateAndTimeList));
        const dateTime = new Date();
        const year = dateTime.getFullYear();
        const month = dateTime.getMonth() + 1;
        const day = dateTime.getDate();
        this.date = mDateAndTimeUtil.concatDate(year, month, day);
        this.time = mDateAndTimeUtil.now();
        this.changeValue();
        let that = this;
        this.intervalFlag = setInterval(function () {
            that.time = mDateAndTimeUtil.now();
            that.changeValue();
        }, 1000);
        mLogUtil.info('settings dateAndTime onInit  end：' + JSON.stringify(this.dateAndTimeList));
    },

    onDestroy() {
        mLogUtil.info('setting dateAndTime onDestroy start');
        clearInterval(this.intervalFlag);
        mLogUtil.info('setting dateAndTime onDestroy end');
    },

    changeValue() {

        for (let key in this.dateAndTimeList) {
            let settingAlias = this.dateAndTimeList[key].settingAlias;
            if (settingAlias === 'date') {
                this.dateAndTimeList[key].settingValue = this.date;
            } else if (settingAlias === 'time') {
                this.dateAndTimeList[key].settingValue = this.time;
            }
        }
    },

    clickToDetail(index) {
        mLogUtil.info('setting dateAndTime clickToDetail start');
        let settingAlias = this.dateAndTimeList[index].settingAlias;
        if (settingAlias === 'date') {
            const datetime = new Date();
            const y = datetime.getFullYear();
            const m = datetime.getMonth() + 1;
            const d = datetime.getDate();
            this.currentDate = this.date;
            this.innerTitle = this.currentDate + mDateAndTimeUtil.convert(y, m, d);
            this.$element('dateDialog').show();
        } else if (settingAlias === 'time') {
            this.currentTime = this.time;
            this.$element('timeDialog').show();
        }
        mLogUtil.info('setting dateAndTime clickToDetail end');
    },

    cancelSchedule() {
        mLogUtil.info('setting dateAndTime cancelSchedule start');
        this.$element('dateDialog').close();
        this.$element('timeDialog').close();
        mLogUtil.info('setting dateAndTime cancelSchedule end');
    },

    setDateSchedule() {
        mLogUtil.info('setting dateAndTime setDateSchedule start');
        this.$element('dateDialog').close();
        if (this.currentDate !== this.date) {
            mLogUtil.info('dateDialog init start:: current date is' + this.currentDate);
            this.date = this.currentDate;
            this.innerTitle = this.date + this.week;
            this.changeValue();
        }
        mLogUtil.info('setting dateAndTime setDateSchedule end');
    },

    setTimeSchedule() {
        mLogUtil.info('setting dateAndTime setTimeSchedule start');
        this.$element('timeDialog').close();
        if (this.currentTime !== this.time) {
            mLogUtil.info('timeDialog init start:: current time is' + this.currentTime);
            const datetime = new Date();
            const y = datetime.getFullYear();
            const m = datetime.getMonth() + 1;
            const d = datetime.getDate();
            const str = y + '/' + mDateAndTimeUtil.fill(m) + '/' + mDateAndTimeUtil.fill(d)
                + ' ' + this.currentTime + ':' + '00';
            mLogUtil.info('timeDialog init start::' + str);
            const s = (new Date(str)).getTime();
            mLogUtil.info('timeDialog time::' + s);
            mDateAndTimeModel.setTime(s);
            this.time = this.currentTime;
            mLogUtil.info('timeDialog time::' + this.time);
            this.changeValue();
        }
        mLogUtil.info('setting dateAndTime setTimeSchedule end');
    },

    handleDateChange(data) {
        mLogUtil.info('setting dateAndTime handleDateChange start');
        this.currentDate = mDateAndTimeUtil.concatDate(data.year, data.month + 1, data.day);
        this.innerTitle = this.currentDate + mDateAndTimeUtil.convert(data.year, data.month + 1, data.day);
        mLogUtil.info('setting dateAndTime handleDateChange end');
    },

    handleTimeChange(data) {
        mLogUtil.info('setting dateAndTime handleTimeChange start');
        this.currentTime = mDateAndTimeUtil.concatTime(data.hour, data.minute);
        mLogUtil.info('setting dateAndTime handleTimeChange end');
    },

    back() {
        mLogUtil.info('settings dateAndTime back start');
        Router.back();
        mLogUtil.info('settings dateAndTime back end');
    },
    onCreate() {
        mLogUtil.info('settings dateAndTime onCreate');
    },
    onReady() {
        mLogUtil.info('settings dateAndTime onReady');
    },
    onHide() {
        mLogUtil.info('settings dateAndTime onHide');
    },
};






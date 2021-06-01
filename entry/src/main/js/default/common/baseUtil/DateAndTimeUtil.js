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
const twelve = 12;
/**
 * date package tool class
 */
export default class DateAndTimeUtil{
    constructor() {
        console.log('DateAndTimeUtil constructor start globalThis.$globalT:'+globalThis.$globalT);
        if (globalThis.$globalT) {
            this.monday = globalThis.$globalT('strings.monday');
            this.tuesday = globalThis.$globalT('strings.tuesday');
            this.wednesday = globalThis.$globalT('strings.wednesday');
            this.thursday = globalThis.$globalT('strings.thursday');
            this.friday = globalThis.$globalT('strings.friday');
            this.saturday = globalThis.$globalT('strings.saturday');
            this.sunday = globalThis.$globalT('strings.sunday');
            this.morning = globalThis.$globalT('strings.morning');
            this.afternoon = globalThis.$globalT('strings.afternoon');
            this.year = globalThis.$globalT('strings.year');
            this.month = globalThis.$globalT('strings.month');
            this.day = globalThis.$globalT('strings.day');
            console.log('DateAndTimeUtil constructor this.monday:' + this.monday);
        }
        console.log('DateAndTimeUtil constructor end');
    }
    /**
     *
     * Get the current time
     */
    now() {
        const datetime = new Date();
        const hours = datetime.getHours();
        const minutes = datetime.getMinutes();
        return this.concatTime(hours, minutes);
    };
    /**
     * format
     * @param value
     * @return
     */
    fill(value) {
        return (value > 9 ? "" : "0") + value;
    };
    /**
     * concat date
     * @param year m d
     * @return
     */
    concatDate(year, month, date) {
        return year + this.year + month + this.month + date + this.day;
    };

    concatTime(hours, minutes) {
        return `${this.fill(hours)}:${this.fill(minutes)}`;
    };
    /**
     * Turn to 24-hour clock
     * @param str
     * @return
     */
    transform24(str) {
        const timeFlag = str.substr(0, 2);
        if (timeFlag == this.morning) {
            const h = str.substr(2).split(":")[0];
            if (h == twelve) {
                const time = "0" + ":" + str.substr(2).split(":")[1];
                return time;
            } else {
                return h + ":" + str.substr(2).split(":")[1];
            }
        } else {
            const h = str.substr(2).split(":")[0];
            const h1 = parseInt(h) + twelve;
            if (h != twelve) {
                const time = h1 + ":" + str.substr(2).split(":")[1];
                return time;
            }
        }
    };
    /**
     * Turn to 12-hour clock
     * @param str
     * @return
     */
    transform12(str) {
        const hours = str.substring(0, str.indexOf(":"));
        const minutes = str.split(":")[1];
        if (hours < twelve) {
            return this.morning.concat(`${hours}:${minutes}`);
        }
        if (hours == twelve) {
            return this.afternoon.concat(`${hours}:${minutes}`);
        } else {
            const reduceHours = parseInt(hours) - twelve;
            return this.afternoon.concat(`${reduceHours}:${minutes}`);
        }
    };
    /**
     * Calculate the week base on date
     * @param y
     * @param m
     * @param d
     * @return
     */
    convert(y, m, d) {
        if (!globalThis.$globalT) {
            return;
        }
        const week = (d + 2 * m + parseInt(3 * (m + 1) / 5) + y + parseInt(y / 4)
        - parseInt(y / 100) + parseInt(y / 400)) % 7;
        switch (week) {
            case 0:
                return this.monday;
                break;
            case 1:
                return this.tuesday;
                break;
            case 2:
                return this.wednesday;
                break;
            case 3:
                return this.thursday;
                break;
            case 4:
                return this.friday;
                break;
            case 5:
                return this.saturday;
                break;
            case 6:
                return this.sunday;
                break;
            default:
                break;
        }
    };
}

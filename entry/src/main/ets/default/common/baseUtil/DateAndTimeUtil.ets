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
/**
 * date package tool class
 */
export class DateAndTimeUtil{
    /**
     *
     * Get the current time
     */
    getSystemTime() {
        let datetime = new Date();
        let hours = datetime.getHours();
        let minutes = datetime.getMinutes();
        let time = this.concatTime(hours, minutes)
        return time;
    }
    /**
     *
     * Get the current date
     */
    getSystemDate() {
        let dateTime = new Date();
        let year = dateTime.getFullYear();
        let month = dateTime.getMonth() + 1;
        let day = dateTime.getDate();
        let date = this.concatDate(year,month,day)
        return date
    }
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
        return year + '年' + month + '月' + date + '日';
    };
    /**
     * concat time
     * @param hours minutes
     * @return
     */
    concatTime(hours, minutes) {
        return `${this.fill(hours)}:${this.fill(minutes)}`;
    };

    /**
     * Calculate the week base on date
     * @param y
     * @param m
     * @param d
     * @return
     */
    convert(y, m, d) {
        console.info('DateAndTimeUtil come in')
        if (m == 1||m == 2) {
            m += 12;
            y--;
        }
        let a = 3 * (m + 1) / 5;
        let b = y / 4
        let c = y / 100
        let e = y / 400
        const week = (d + 2 * m + Math.floor(a) + y + Math.floor(b)
        - Math.floor(c) + Math.floor(e) + 1) % 7;
        console.info('DateAndTimeUtil get week ' + week);
        switch (week) {
            case 0:
                return '星期日';
                break;
            case 1:
                return '星期一';
                break;
            case 2:
                return '星期二';
                break;
            case 3:
                return '星期三';
                break;
            case 4:
                return '星期四';
                break;
            case 5:
                return '星期五';
                break;
            case 6:
                return '星期六';
                break;
            default:
                break;
        }
    };
}

let dateAndTimeUtil = new DateAndTimeUtil();
export default dateAndTimeUtil as DateAndTimeUtil

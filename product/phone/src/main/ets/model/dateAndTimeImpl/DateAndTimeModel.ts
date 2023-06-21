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

import BaseModel from '../../../../../../../common/utils/src/main/ets/default/model/BaseModel';
import BaseParseConfModel from '../../../../../../../common/utils/src/main/ets/default/model/BaseParseConfModel';
import ConfigData from '../../../../../../../common/utils/src/main/ets/default/baseUtil/ConfigData';
import LogUtil from '../../../../../../../common/utils/src/main/ets/default/baseUtil/LogUtil';
import SystemTime from '@ohos.systemTime';
import settings from '@ohos.settings';
import data_dataShare from '@ohos.data.dataShare';
import CatchError from '../../../../../../../common/utils/src/main/ets/default/baseUtil/CatchError';
import i18n from '@ohos.i18n';

/**
 * Set date and time
 */
export class DateAndTimeModel extends BaseModel {
  private timeFormat = '';
  private dataShareHelper;
  private readonly listenUri = 'datashare:///com.ohos.settingsdata/entry/settingsdata/SETTINGSDATA?Proxy=true&key=' + ConfigData.TIME_FORMAT_KEY;

  constructor() {
    super();
    if(!globalThis.settingsAbilityContext){
      return;
      LogUtil.info("globalThis.settingsAbilityContext is null");
    }
    data_dataShare.createDataShareHelper(globalThis.settingsAbilityContext, this.listenUri)
      .then((dataHelper) => {
        this.dataShareHelper = dataHelper;
        LogUtil.info("createDataShareHelper success");
      });
  }

  /**
   * Get Uri
   */
  public getUri(){
    return this.listenUri;
  }

  setTime(time) {
    LogUtil.info(ConfigData.TAG + 'DateAndTimeModel setTime in ：' + time);
    SystemTime.setTime(time).then(data => {
      LogUtil.info(ConfigData.TAG + `DateAndTimeModel setTime promise then : ${data}`);
    })
      .catch(error => {
        LogUtil.info(ConfigData.TAG + `DateAndTimeModel setTime promise1 catch : ${error}`);
      }
      );
    LogUtil.info(ConfigData.TAG + 'DateAndTimeModel setTime out');
  }

  @CatchError('24')
  getTimeFormat() : string {
    if (i18n.is24HourClock()) {
      this.timeFormat = settings.getValueSync(globalThis.settingsAbilityContext, ConfigData.TIME_FORMAT_KEY, ConfigData.TIME_FORMAT_24);
      LogUtil.info(ConfigData.TAG + 'DateAndTimeModel get time format is ' + this.timeFormat);
    }
    return this.timeFormat;
  }

  setTimeFormatAs12H() : boolean {
    return this.setTimeFormat(ConfigData.TIME_FORMAT_12);
  }

  setTimeFormatAs24H() : boolean {
    return this.setTimeFormat(ConfigData.TIME_FORMAT_24);
  }

  public dateAndTimeListener(): any[] {
    LogUtil.info(ConfigData.TAG + 'getAboutDeviceInfoListener come in');
    return BaseParseConfModel.getJsonData(ConfigData.FILE_URI.concat('dateAndTime.json'));
  }

  @CatchError(false)
  private setTimeFormat(format: string) : boolean {
    LogUtil.info(ConfigData.TAG + 'DateAndTimeModel set time format to ' + format);
    if (format != ConfigData.TIME_FORMAT_12 && format != ConfigData.TIME_FORMAT_24) {
      return false;
    }

    if (format === this.timeFormat) {
      return true;
    }

    let ret24HourClock;
    if (format === ConfigData.TIME_FORMAT_24) {
      ret24HourClock = i18n.set24HourClock(true)
    } else {
      ret24HourClock = i18n.set24HourClock(false)
    }
    LogUtil.info(ConfigData.TAG + 'DateAndTimeModel i18n set24HourClock ' + JSON.stringify(ret24HourClock));

    settings.setValueSync(globalThis.settingsAbilityContext, ConfigData.TIME_FORMAT_KEY, format);
    this.timeFormat = format;
    return true;
  }

  /**
   * Register observer
   */
  public registerObserver(callback: () => {}){
    return;
  }

  /**
   * Unregister observer
   */
  public unregisterObserver() {
    LogUtil.info(`${ConfigData.TAG} unregisterObserver`);
    if(!this.dataShareHelper){
      LogUtil.info(`${ConfigData.TAG} this.dataShareHelper is null`);
      return;
    }
    this.dataShareHelper.off("dataChange", this.listenUri, (err) => {
      LogUtil.info(`${ConfigData.TAG} unregisterObserver success`);
    })
    return;
  }
}

let dateAndTimeModel = new DateAndTimeModel();
export default dateAndTimeModel as DateAndTimeModel;
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
import BaseModel from '../../../../../../../../common/utils/src/main/ets/default/model/BaseModel.ets';
import BaseParseConfModel from '../../../../../../../../common/utils/src/main/ets/default/model/BaseParseConfModel.ets';
import ConfigData from '../../../../../../../../common/utils/src/main/ets/default/baseUtil/ConfigData.ets';
import LogUtil from '../../../../../../../../common/utils/src/main/ets/default/baseUtil/LogUtil.ets';
import SystemTime from '@ohos.systemTime';
import settings from '@ohos.settings';
import featureAbility from '@ohos.ability.featureAbility'

/**
 * Set date and time
 */
export class DateAndTimeModel extends BaseModel {
  timeFormat = null;

  setTime(time) {
    LogUtil.info('DateAndTimeModel setTime  in ：' + time);
    SystemTime.setTime(time).then(data => {
      LogUtil.info(`DateAndTimeModel setTime promise then : ${data}`);
    })
      .catch(error => {
      LogUtil.info(`DateAndTimeModel setTime promise1 catch : ${error}`);
    }
    );
    LogUtil.info('DateAndTimeModel setTime out');
  }

  getTimeFormat() : string {
    if (this.timeFormat === null) {
      let dataAbilityHelper = featureAbility.acquireDataAbilityHelper(ConfigData.TIME_FORMAT_URI);
      this.timeFormat = settings.getValue(dataAbilityHelper, ConfigData.TIME_FORMAT_KEY, ConfigData.TIME_FORMAT_24);
      LogUtil.info('DateAndTimeModel get time format is ' + this.timeFormat);
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
    LogUtil.info('getAboutDeviceInfoListener come in');
    return BaseParseConfModel.getJsonData(ConfigData.FILE_URI.concat('dateAndTime.json'));
  }

  private setTimeFormat(format: string) : boolean {
    LogUtil.info('DateAndTimeModel set time format to ' + format);
    if (format != ConfigData.TIME_FORMAT_12 && format != ConfigData.TIME_FORMAT_24) {
      return false;
    }
    if (format === this.timeFormat) {
      return true;
    }
    let dataAbilityHelper = featureAbility.acquireDataAbilityHelper(ConfigData.TIME_FORMAT_URI);
    let ret = settings.setValue(dataAbilityHelper, ConfigData.TIME_FORMAT_KEY, format);
    if (ret === true) {
      this.timeFormat = format;
    }
    return ret;
  }
}

let dateAndTimeModel = new DateAndTimeModel();
export default dateAndTimeModel as DateAndTimeModel
;
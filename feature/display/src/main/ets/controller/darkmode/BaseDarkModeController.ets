/*
 * Copyright (c) Huawei Technologies Co., Ltd. 2024-2025. All rights reserved.
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

import dataShare from '@ohos.data.dataShare';
import { BusinessError } from '@kit.BasicServicesKit';
import { SearchDataController } from '@ohos/settings.search/src/main/ets/controller/SearchController';
import {
  CompCtrlParam,
  ComponentControl,
} from '@ohos/settings.common/src/main/ets/framework/model/SettingBaseModel';
import { LogUtil } from '@ohos/settings.common/src/main/ets/utils/LogUtil';
import { SettingsDataUtils } from '@ohos/settings.common/src/main/ets/utils/SettingsDataUtils';
import Settings from '@ohos.settings';
import { CheckEmptyUtils } from '@ohos/settings.common/src/main/ets/utils/CheckEmptyUtils';
import { HiSysDisplayBrightnessEventGroup } from '@ohos/settings.common/src/main/ets/systemEvent/BehaviorEventConsts';
import { HiSysEventUtil } from '@ohos/settings.common/src/main/ets/systemEvent/HiSysEventUtil';
import {
  DARK_MODE_TIMED_ON,
  DEFAULT_DARK_MODE_END_TIME,
  DEFAULT_DARK_MODE_START_TIME,
  DEFAULT_DARK_MODE_STATE,
  SETTINGS_UI_APPEARANCE_DARK_MODE,
  SETTINGS_UI_APPEARANCE_DARK_MODE_ENDTIME,
  SETTINGS_UI_APPEARANCE_DARK_MODE_STARTTIME,
} from '../../constant/DarkModeConstant';
import { MIN_60, STR_CUSTOM, STR_END_TIME, STR_START_TIME } from '../../constant/DisplayConstant';
import { TimeUtil } from '../../utils/TimeUtil';

export class BaseDarkModeController implements ComponentControl {
  protected compId: string = '';
  protected tag: string = 'BaseDarkModeController: ';
  protected dataHelper?: dataShare.DataShareHelper;
  protected darkModeChangeCallback = () => {
    LogUtil.info(`${this.tag} darkModeChangeCallback`);
  };

  init(compParam: CompCtrlParam): void {
    if (!compParam || !compParam.compId) {
      LogUtil.error(`${this.tag} init fail, compParam is invalid`);
      return;
    }
    this.compId = compParam.compId;
  }

  protected registerDataHelper(): void {
    LogUtil.info(`${this.tag} registerDataHelper`);
    /* instrument ignore if*/
    if (this.dataHelper) {
      SettingsDataUtils.registerUserDataChange(this.dataHelper, SETTINGS_UI_APPEARANCE_DARK_MODE,
        this.darkModeChangeCallback);
    } else {
      (SettingsDataUtils.createDataHelper(SETTINGS_UI_APPEARANCE_DARK_MODE) as Promise<dataShare.DataShareHelper>)
        .then((dataShareHelper?:dataShare.DataShareHelper | undefined) => {
          LogUtil.info(`${this.tag} createDataHelper success, ${dataShareHelper !== undefined}`);
          if (dataShareHelper) {
            this.dataHelper = dataShareHelper;
            SettingsDataUtils.registerUserDataChange(this.dataHelper, SETTINGS_UI_APPEARANCE_DARK_MODE,
              this.darkModeChangeCallback);
          }
        })
        .catch((err: BusinessError) => {
          LogUtil.error(`${this.tag} createDataHelper err: ${err?.code}`);
        })
    }
  }

  protected unRegisterDataHelper(): void {
    /* instrument ignore if*/
    if (!this.dataHelper) {
      return;
    }
    SettingsDataUtils.unRegisterUserDataChange(this.dataHelper, SETTINGS_UI_APPEARANCE_DARK_MODE);
  }

  protected isInDarkModeOnTime(): boolean {
    let darkModeType: string = this.getDarkModeType();
    LogUtil.info(`${this.tag} isInDarkModeOnTime ${darkModeType}`);
    if (darkModeType !== DARK_MODE_TIMED_ON) {
      return false;
    }
    let date: Date = new Date();
    let hour: number = date.getHours();
    let minute: number = date.getMinutes();
    let startTime: string = this.getStartTime();
    let endTime: string = this.getEndTime();
    LogUtil.info(`${this.tag} isInDarkModeOnTime ${hour}, ${minute}, ${startTime}, ${endTime}`);
    /* instrument ignore if*/
    if (CheckEmptyUtils.checkStrIsEmpty(startTime) || CheckEmptyUtils.checkStrIsEmpty(endTime)) {
      LogUtil.error(`${this.tag} isInDarkModeOnTime time invalid`);
      return false;
    }
    let currentTime: number = hour * MIN_60 + minute;
    /* instrument ignore if*/
    if (currentTime < Number.parseInt(startTime)) {
      let nextCurrentTime: number = currentTime + TimeUtil.getNextDayTime();
      return nextCurrentTime >= Number.parseInt(startTime) && nextCurrentTime <= Number.parseInt(endTime);
    }
    return currentTime >= Number.parseInt(startTime) && currentTime <= Number.parseInt(endTime);
  }

  protected getStartTime(): string {
    let startTime: string = SettingsDataUtils
      .getSettingsData(SETTINGS_UI_APPEARANCE_DARK_MODE_STARTTIME, DEFAULT_DARK_MODE_START_TIME,
        Settings.domainName.USER_PROPERTY);
    LogUtil.info(`${this.tag} getStartTime ${startTime}`);
    return startTime;
  }

  protected getEndTime(): string {
    let endTime: string = SettingsDataUtils
      .getSettingsData(SETTINGS_UI_APPEARANCE_DARK_MODE_ENDTIME, DEFAULT_DARK_MODE_END_TIME,
        Settings.domainName.USER_PROPERTY);
    LogUtil.info(`${this.tag} getEndTime ${endTime}`);
    return endTime;
  }

  protected getDarkModeType(): string {
    let darkMode: string = SettingsDataUtils
      .getSettingsData(SETTINGS_UI_APPEARANCE_DARK_MODE, DEFAULT_DARK_MODE_STATE, Settings.domainName.USER_PROPERTY);
    return darkMode;
  }

  protected getDarkModeTypeAsync(): Promise<string> {
    return SettingsDataUtils
      .getSettingsDataAsync(SETTINGS_UI_APPEARANCE_DARK_MODE, DEFAULT_DARK_MODE_STATE,
        Settings.domainName.USER_PROPERTY);
  }

  protected setStartTime(startTime: string): void {
    HiSysEventUtil.serviceStatusDefaultBehaviorEventByUE(HiSysDisplayBrightnessEventGroup.EYE_MODE_SCHEDULED_SWITCH,
      STR_START_TIME, startTime, STR_CUSTOM);
    SettingsDataUtils
      .setSettingsData(SETTINGS_UI_APPEARANCE_DARK_MODE_STARTTIME, startTime, Settings.domainName.USER_PROPERTY);
  }

  protected setEndTime(endTime: string): void {
    HiSysEventUtil.serviceStatusDefaultBehaviorEventByUE(HiSysDisplayBrightnessEventGroup.EYE_MODE_SCHEDULED_SWITCH,
      STR_END_TIME, endTime, STR_CUSTOM);
    SettingsDataUtils
      .setSettingsData(SETTINGS_UI_APPEARANCE_DARK_MODE_ENDTIME, endTime, Settings.domainName.USER_PROPERTY);
  }

  /* instrument ignore next*/
  destroy(): void {
    LogUtil.showInfo(this.tag, 'onDestroy eventbus');
    this.unRegisterDataHelper();
  }

  updateDarkTimeSearchItemStatus(state: boolean): void {
    SearchDataController.getInstance().updateSearchItemStatus('dark_start_time', state);
    SearchDataController.getInstance().updateSearchItemStatus('dark_end_time', state);
  }
}
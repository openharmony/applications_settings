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
import settings from '@ohos.settings';
import { displayDataManager } from '@ohos/settings.common/src/main/ets/data/DisplayDataManager';
import { CompCtrlParam, ComponentControl } from '@ohos/settings.common/src/main/ets/framework/model/SettingBaseModel';
import { ItemResultType } from '@ohos/settings.common/src/main/ets/framework/model/SettingItemModel';
import {
  notifyCompStateChange,
  SettingBaseState,
  SettingResultState,
  SettingSelectMenuState,
  SettingStateType,
} from '@ohos/settings.common/src/main/ets/framework/model/SettingStateModel';
import { HiSysDisplayEventGroup } from '@ohos/settings.common/src/main/ets/systemEvent/BehaviorEventConsts';
import { HiSysEventUtil } from '@ohos/settings.common/src/main/ets/systemEvent/HiSysEventUtil';
import { CheckEmptyUtils } from '@ohos/settings.common/src/main/ets/utils/CheckEmptyUtils';
import { LogUtil } from '@ohos/settings.common/src/main/ets/utils/LogUtil';
import { ResourceUtil } from '@ohos/settings.common/src/main/ets/utils/ResourceUtil';
import { PreferencesUtil } from '@ohos/settings.common/src/main/ets/utils/PreferencesUtil';
import { SettingsDataUtils } from '@ohos/settings.common/src/main/ets/utils/SettingsDataUtils';
import {
  SLEEP_TIME_MAP,
  SLEEP_TIME_STR,
  SleepTime,
  sleepTimeArr,
  SleepTimeNum,
  sleepTimeNumArr
} from '../Constant/Constant';
import { SCREEN_OFF_TIMEOUT_PREF } from '../utils/DisplayPreferencesUtils';

/* instrument ignore file */
const TAG: string = 'DormancySettingController';
const DATA_SCREEN_OFF_TIMEOUT = settings.display.SCREEN_OFF_TIMEOUT;
const RADIO_VALUE_MAP: Map<string, string> = new Map([
  [SleepTime.FIFTEEN_SECONDS, '15seconds'],
  [SleepTime.THIRTY_SECONDS, '30seconds'],
  [SleepTime.ONE_MINUTE, '1minute'],
  [SleepTime.TWO_MINUTES, '2minutes'],
  [SleepTime.FIVE_MINUTES, '5minutes'],
  [SleepTime.TEN_MINUTES, '10minutes'],
]);
const DEFAULT_THIRTY_SECONDS_INDEX: number = 1;

export class DormancySettingController implements ComponentControl {
  private dataHelper: dataShare.DataShareHelper | null = null;
  public static sleepTimeIndex: number = 0;
  public NEW_SLEEP_TIME_STR: string[] = [];
  public onDataChange = () => {
    LogUtil.info(`${TAG} onDataChange`);
    displayDataManager.updateSleepTime();
    this.updateStatus();
  }

  public static onMenuChange(index: number): void {
    LogUtil.info(`${TAG} onMenuChange: ${index} time is ${sleepTimeArr[index]}`);
    DormancySettingController.sleepTimeIndex = index;
    const value = sleepTimeArr[index];
    SettingsDataUtils.setSettingsData(DATA_SCREEN_OFF_TIMEOUT, value);
    PreferencesUtil.putSync(SCREEN_OFF_TIMEOUT_PREF, value);
    displayDataManager.updateSleepTime();
  }

  init(compParam: CompCtrlParam): void {
    SLEEP_TIME_STR.forEach(async (item, index) => {
      let result = await ResourceUtil.getString(item);
      this.NEW_SLEEP_TIME_STR[index] = result.replace('%d', sleepTimeNumArr[index]);
    });
    this.updateStatus()
    this.registerDataChange();
  }

  destroy(): void {
    this.unRegisterDataChange();
  }

  onPageShow(): void {
    LogUtil.info(`${TAG} onPageShow`);
  }

  onPageHide(): void {
    LogUtil.info(`${TAG} onPageHide`);
  }

  private refreshUi(result: ResourceStr): void {
    notifyCompStateChange('Setting.Display.screen_group.dormancy_settings',
      new Map<SettingStateType, SettingResultState>([[SettingStateType.STATE_TYPE_ITEM_RESULT,
        { type: ItemResultType.RESULT_TYPE_TEXT, result: { content: result } } as SettingResultState]]));
    // 刷新菜单列表
    notifyCompStateChange('Setting.Display.screen_group.dormancy_settings', new Map<SettingStateType, SettingBaseState>(
      [[SettingStateType.STATE_TYPE_ITEM_MENU, {
        items: this.NEW_SLEEP_TIME_STR,
        selectIcon: $r('app.media.ic_selected_ok'),
        onSelected: (index) => {
          LogUtil.info(`${TAG} onSelect color filter index: ${index}`);
          DormancySettingController.onMenuChange(index);
        },
        defaultFocus: DormancySettingController.sleepTimeIndex,
      } as SettingSelectMenuState]]));
  }

  private registerDataChange(): void {
    if (this.dataHelper) {
      SettingsDataUtils.registerDataChange(this.dataHelper, DATA_SCREEN_OFF_TIMEOUT, this.onDataChange);
    } else {
      (SettingsDataUtils.createDataHelper(DATA_SCREEN_OFF_TIMEOUT) as Promise<dataShare.DataShareHelper>)
        .then((dataShareHelper?: dataShare.DataShareHelper) => {
          if (dataShareHelper) {
            this.dataHelper = dataShareHelper;
            SettingsDataUtils.registerDataChange(this.dataHelper, DATA_SCREEN_OFF_TIMEOUT, this.onDataChange);
          }
        })
    }
    LogUtil.info(`${TAG} registerDataChange`);
  }

  private unRegisterDataChange(): void {
    SettingsDataUtils.unRegisterDataChange(this.dataHelper as dataShare.DataShareHelper, DATA_SCREEN_OFF_TIMEOUT);
    LogUtil.info(`${TAG} unRegisterDataChange`);
  }

  private updateStatus(): void {
    LogUtil.info(`${TAG} updateStatus`);
    let radioValue: string = '';
    let sleepTime = SettingsDataUtils.getSettingsData(settings.display.SCREEN_OFF_TIMEOUT,
      SleepTime.THIRTY_SECONDS);
    const prefTime = String(PreferencesUtil.getSync(SCREEN_OFF_TIMEOUT_PREF, ''));
    if (prefTime !== '' && prefTime !== sleepTime) {
      LogUtil.info(`${TAG} DB and preference inconsistent, sync preference to DB. pref: ${prefTime}, db: ${sleepTime}`);
      SettingsDataUtils.setSettingsData(DATA_SCREEN_OFF_TIMEOUT, prefTime);
      displayDataManager.updateSleepTime();
      sleepTime = prefTime;
    }
    let idx: number = sleepTimeArr.findIndex(item => item === sleepTime);
    LogUtil.info(`${TAG} sleepTime is ${sleepTime} idx is ${idx}`);
    if (!this.isValidValue(sleepTime)) {
      LogUtil.info(`${TAG} sleepTime is invalid values, set default 30 seconds`);
      sleepTime = SleepTime.THIRTY_SECONDS;
      SettingsDataUtils.setSettingsData(DATA_SCREEN_OFF_TIMEOUT, SleepTime.THIRTY_SECONDS);
      displayDataManager.updateSleepTime();
      radioValue = '30seconds';
      idx = DEFAULT_THIRTY_SECONDS_INDEX;
    }
    DormancySettingController.sleepTimeIndex = idx;

    let sleepTimeNumber: string = '';
    if (SLEEP_TIME_MAP.has(sleepTime)) {
      sleepTimeNumber = SLEEP_TIME_MAP.get(sleepTime) as string;
      radioValue = RADIO_VALUE_MAP.get(sleepTime) as string;
      let formatStr: ResourceStr;
      if (sleepTimeNumber === SleepTimeNum.SLEEP_TIME_FIFTEEN_SECONDS ||
        sleepTimeNumber === SleepTimeNum.SLEEP_TIME_THIRTY_SECONDS) {
        formatStr = $r('app.string.after_fifteen_seconds');
      } else if (sleepTimeNumber === SleepTimeNum.SLEEP_TIME_ONE_MINUTE) {
        formatStr = $r('app.string.after_one_minute');
      } else if (sleepTimeNumber === SleepTimeNum.SLEEP_TIME_TWO_MINUTES) {
        formatStr = $r('app.string.after_two_minutes');
      } else if (sleepTimeNumber === SleepTimeNum.SLEEP_TIME_FIVE_MINUTES ||
        sleepTimeNumber === SleepTimeNum.SLEEP_TIME_TEN_MINUTES) {
        formatStr = $r('app.string.after_ten_minutes');
      } else {
        LogUtil.info(`${TAG} sleepTimeNumber is invalid values`);
        formatStr = $r('app.string.after_two_minutes');
      }
      ResourceUtil.getNumberFormatString(formatStr, sleepTimeNumber).then((value) => {
        this.refreshUi(value);
      });
    } else {
      radioValue = 'other';
      ResourceUtil.getString($r('app.string.other_time')).then(result => {
        this.refreshUi(result);
      })
    }
    HiSysEventUtil.reportDefaultBehaviorEventByUE(HiSysDisplayEventGroup.SCREEN_TIMEOUT_VALUE, radioValue);
  }

  private isValidValue(value: string): boolean {
    if (CheckEmptyUtils.checkStrIsEmpty(value)) {
      return false;
    }
    let number = Number(value);
    return Number.isInteger(number) && number >= 0;
  }
}
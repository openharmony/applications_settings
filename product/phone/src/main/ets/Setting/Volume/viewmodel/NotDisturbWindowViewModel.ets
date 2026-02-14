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

/* instrument ignore file */
import commonEventManager from '@ohos.commonEventManager';
import dataShare from '@ohos.data.dataShare';
import settings from '@ohos.settings';
import { AccessibilityUtils } from '@ohos/settings.common/src/main/ets/utils/AccessibilityUtils';
import { CommonEventHelper } from '@ohos/settings.common/src/main/ets/utils/CommonEventHelper';
import { GlobalContext } from '@ohos/settings.common/src/main/ets/utils/GlobalContext';
import { LogUtil } from '@ohos/settings.common/src/main/ets/utils/LogUtil';
import { ResourceUtil } from '@ohos/settings.common/src/main/ets/utils/ResourceUtil';
import { SettingsDataUtils } from '@ohos/settings.common/src/main/ets/utils/SettingsDataUtils';
import {
  NotDisturbReportSources,
  NotDisturbTimerId,
  NotDisturbTimerPararm,
  NotDisturbTimerRepeatType,
  PresetOnceType
} from '@ohos/settings.notDisturb/src/main/ets/model/NotDisturbTimerPararm';
import {
  DISTURB_MODE_TRIGGER_END_TIME,
  DISTURB_MODE_TRIGGER_START_TIME,
  FOCUS_MODE_TIMER,
  NotDisturbTimerManager
} from '@ohos/settings.notDisturb/src/main/ets/NotDisturbTimerManager';
import {
  FOCUS_MODE_ENABLED,
  FOCUS_MODE_MANUAL_ENABLE,
  NOT_DISTURB_NUMBER_MINUS,
  NOT_DISTURB_VALUE_DISABLE,
  NOT_DISTURB_VALUE_ENABLE,
  NOT_DISTURB_VALUE_ERROR,
  NotDisturbUtils
} from '@ohos/settings.notDisturb/src/main/ets/utils/NotDisturbUtils';
import { NotDisturbMenuEntry } from '../view/NotDisturbMenuEntry';

const INDEX_PRESET_ONCE: number = 0;
const INDEX_ONE_HOUR_OPEN: number = 1;
const INDEX_TWO_HOUR_OPEN: number = 2;
const INDEX_UNTIL_TONIGHT: number = 3;
const KEY_TURN_ON: string = 'key_turn_on';
const KEY_ONE_HOUR: string = 'key_one_hour';
const KEY_TWO_HOUR: string = 'key_two_hour';
const KEY_UNTIL_TONIGHT: string = 'key_until_tonight';
const ONE_HOUR_MILLISECONDS: number = 1 * 60 * 60 * 1000;
const TWO_HOUR_MILLISECONDS: number = 2 * 60 * 60 * 1000;
const TONIGHT_TIME: number = 19;
const NEXT_DAY_TIME: number = 0;
const TONIGHT_TIME_STRING: string = '19:00';
const TAG: string = 'NotDisturbWindowViewModel: ';

/**
 * 控制中心免打扰二级面板ViewModel
 */
export class NotDisturbWindowViewModel {
  private readonly timeFormat: Intl.DateTimeFormat = NotDisturbUtils.getFormat();
  private readonly subscribeInfo: commonEventManager.CommonEventSubscribeInfo = {
    events: [commonEventManager.Support.COMMON_EVENT_TIME_TICK]
  };
  private readonly timeCommonEvent = new CommonEventHelper(this.subscribeInfo, (err, data) => {
    if (err.code) {
      LogUtil.error(`${TAG} subscribe failed ${err.code}`);
    } else {
      this.refreshTimeUi(NotDisturbTimerManager.getInstance().getTimers(getContext()));
    }
  });
  private notDisturbMenusArray: NotDisturbMenuEntry[] = [];
  private hasTonightItem: boolean = false;
  private tonightItem: NotDisturbMenuEntry | undefined;
  private dataHelper: dataShare.DataShareHelper | null = null;

  public init(notDisturbMenusArray: NotDisturbMenuEntry[]): void {
    if (notDisturbMenusArray === null || notDisturbMenusArray === undefined) {
      return;
    }
    GlobalContext.getInstance().set('TimerContext', getContext());
    this.notDisturbMenusArray = notDisturbMenusArray;
    let isDisturbOn: boolean = NotDisturbTimerManager.getInstance().isNotDisturbOpen(getContext());
    LogUtil.showInfo(TAG, `isDisturbOn: ${isDisturbOn}`);
    // 添加立即开启
    this.notDisturbMenusArray.push(new NotDisturbMenuEntry({
      key: KEY_TURN_ON,
      id: NotDisturbTimerId.PRESET_ONCE,
      title: $r('app.string.not_disturb_turn_on_now'),
      subTitle: $r('app.string.not_disturb_until_close'),
      isSelected: isDisturbOn
    }));

    // 添加1小时
    this.notDisturbMenusArray.push(new NotDisturbMenuEntry({
      key: KEY_ONE_HOUR,
      id: NotDisturbTimerId.PRESET_ONCE,
      title: $r('app.string.not_disturb_one_hour'),
    }));

    // 添加2小时
    this.notDisturbMenusArray.push(new NotDisturbMenuEntry({
      key: KEY_TWO_HOUR,
      id: NotDisturbTimerId.PRESET_ONCE,
      title: $r('app.string.not_disturb_two_hour')
    }));
    let timers: NotDisturbTimerPararm[] = NotDisturbTimerManager.getInstance().getTimers(getContext());
    this.refreshTimeUi(timers);
    timers.forEach((timer) => {
      if (timer.id < NotDisturbTimerId.USER_SET_START) {
        return;
      }
      this.notDisturbMenusArray.push(new NotDisturbMenuEntry({
        key: `KEY_DEFAULT_TIMER${timer.id}`,
        id: timer.id,
        title: NotDisturbUtils.getZenModeScheduleRepeatText(timer.repeat),
        subTitle: NotDisturbUtils.getTimerSummary(this.timeFormat, timer.startTime, timer.endTime),
        isSelected: timer.isOpen
      }));
    });
    let isDisable: boolean = isDisturbOn &&
      NotDisturbTimerManager.getInstance().getTimerId(getContext()) === NOT_DISTURB_NUMBER_MINUS;
    LogUtil.showInfo(TAG, `isDisable: ${isDisable}`);
    this.disableTimer(isDisable);
  }

  public registerListener(): void {
    LogUtil.info(`${TAG} register listener`);
    this.timeCommonEvent.registerCommonEvent();
    this.registerDataChange();
  }

  public unregisterListener(): void {
    LogUtil.info(`${TAG} unregister listener`);
    this.timeCommonEvent.unRegisterCommonEvent();
    this.unRegisterDataChange();
  }

  private refreshTimeUi(timers: NotDisturbTimerPararm[]): void {
    const currentDateNumber: number = Date.now();
    const currentDate: Date = new Date(currentDateNumber);
    let isOpen: boolean = timers && timers[INDEX_PRESET_ONCE] &&
      timers[INDEX_PRESET_ONCE].id === NotDisturbTimerId.PRESET_ONCE && timers[INDEX_PRESET_ONCE].isOpen;
    if (isOpen) {
      const onceTimer: NotDisturbTimerPararm = timers[INDEX_PRESET_ONCE];
      const type: PresetOnceType = onceTimer.onceType ?? PresetOnceType.DEFAULT;
      if (type === PresetOnceType.ONE_HOUR) {
        this.notDisturbMenusArray[INDEX_ONE_HOUR_OPEN].subTitle =
          NotDisturbUtils.getTimerSummary(this.timeFormat, onceTimer.startTime, onceTimer.endTime);
        const twoHourLaterDate: Date = new Date(currentDateNumber + TWO_HOUR_MILLISECONDS);
        this.notDisturbMenusArray[INDEX_TWO_HOUR_OPEN].subTitle =
          NotDisturbUtils.getTimerSummaryForDate(this.timeFormat, currentDate, twoHourLaterDate);
      } else if (type === PresetOnceType.TWO_HOUR) {
        const oneHourLaterDate: Date = new Date(currentDateNumber + ONE_HOUR_MILLISECONDS);
        this.notDisturbMenusArray[INDEX_ONE_HOUR_OPEN].subTitle =
          NotDisturbUtils.getTimerSummaryForDate(this.timeFormat, currentDate, oneHourLaterDate);
        this.notDisturbMenusArray[INDEX_TWO_HOUR_OPEN].subTitle =
          NotDisturbUtils.getTimerSummary(this.timeFormat, onceTimer.startTime, onceTimer.endTime);
      } else {
        this.setCurrentDateSummary(currentDateNumber, currentDate);
      }
    } else {
      this.setCurrentDateSummary(currentDateNumber, currentDate);
    }
    this.refreshTonight(currentDate);
    if (isOpen) {
      this.refreshOnceTimer(timers[INDEX_PRESET_ONCE].onceType ?? PresetOnceType.DEFAULT);
    } else {
      this.refreshOnceTimer(PresetOnceType.DEFAULT);
    }
  }

  private setCurrentDateSummary(currentDateNumber: number, currentDate: Date): void {
    const oneHourLaterDate: Date = new Date(currentDateNumber + ONE_HOUR_MILLISECONDS);
    const twoHourLaterDate: Date = new Date(currentDateNumber + TWO_HOUR_MILLISECONDS);
    this.notDisturbMenusArray[INDEX_ONE_HOUR_OPEN].subTitle =
      NotDisturbUtils.getTimerSummaryForDate(this.timeFormat, currentDate, oneHourLaterDate);
    this.notDisturbMenusArray[INDEX_TWO_HOUR_OPEN].subTitle =
      NotDisturbUtils.getTimerSummaryForDate(this.timeFormat, currentDate, twoHourLaterDate);
  }

  public async handleClickEvent(key: string, id: number) {
    const index: number = this.notDisturbMenusArray.findIndex((item) => {
      return item.key === key;
    });
    if (index < 0) {
      return;
    }
    let currentItem = this.notDisturbMenusArray[index];
    currentItem.isSelected = !currentItem.isSelected;
    if (key === KEY_TURN_ON) {
      this.setModeStatus(currentItem.isSelected);
    } else if (key === KEY_ONE_HOUR) {
      await this.setScheduled(PresetOnceType.ONE_HOUR, currentItem.isSelected);
    } else if (key === KEY_TWO_HOUR) {
      await this.setScheduled(PresetOnceType.TWO_HOUR, currentItem.isSelected);
    } else if (key === KEY_UNTIL_TONIGHT) {
      await this.setScheduled(PresetOnceType.TONIGHT, currentItem.isSelected);
    } else {
      this.setScheduledOpen(id, currentItem.isSelected);
    }
    AccessibilityUtils.announceRadioSelected(currentItem.isSelected);
  }

  private setModeStatus(isOpen: boolean): void {
    SettingsDataUtils.setSettingsData(FOCUS_MODE_MANUAL_ENABLE,
      isOpen ? NOT_DISTURB_VALUE_ENABLE : NOT_DISTURB_VALUE_DISABLE, settings.domainName.USER_PROPERTY);
    SettingsDataUtils.setSecureValue(FOCUS_MODE_ENABLED,
      isOpen ? NOT_DISTURB_VALUE_ENABLE : NOT_DISTURB_VALUE_DISABLE);
    const status = isOpen ? 'on' : 'off';
    NotDisturbUtils.reportNotDisturb(status, NotDisturbReportSources.CONTROL_CENTRE_SETTING);
    if (isOpen) {
      NotDisturbTimerManager.getInstance().stopAlarm();
      SettingsDataUtils.setSettingsData(
        DISTURB_MODE_TRIGGER_START_TIME, NOT_DISTURB_VALUE_ERROR, settings.domainName.USER_PROPERTY);
      SettingsDataUtils.setSettingsData(
        DISTURB_MODE_TRIGGER_END_TIME, NOT_DISTURB_VALUE_ERROR, settings.domainName.USER_PROPERTY);
    } else {
      NotDisturbTimerManager.getInstance().closeNowChange(new Date().getTime());
    }
    this.refreshTimeUi(NotDisturbTimerManager.getInstance().getTimers(getContext()));
    this.disableTimer(isOpen);
  }

  private async setScheduled(endType: PresetOnceType, isOpen: boolean): Promise<void> {
    LogUtil.info(`${TAG} setScheduled endType:${endType},isOpen:${isOpen}`);
    let zenTimers: NotDisturbTimerPararm[] = NotDisturbTimerManager.getInstance().getTimers(getContext());
    if (isOpen) {
      this.setScheduledWhenOpen(endType, zenTimers);
    } else {
      let index: number = zenTimers.findIndex((item) => {
        return item.id === NotDisturbTimerId.PRESET_ONCE;
      });
      if (index < 0) {
        return;
      }
      zenTimers[index].isOpen = false;
      SettingsDataUtils.setSettingsDataWithContext(getContext(), FOCUS_MODE_TIMER, JSON.stringify(zenTimers),
        settings.domainName.USER_PROPERTY);
      this.refreshOnceTypeSummary(endType);
      await NotDisturbTimerManager.getInstance().refreshTimer();
    }
  }

  private setScheduledWhenOpen(endType: PresetOnceType, zenTimers: NotDisturbTimerPararm[]): void {
    const currentDateNumber: number = Date.now();
    const currentDate: Date = new Date(currentDateNumber);
    let endTime: string = '';
    if (endType === PresetOnceType.ONE_HOUR) {
      const oneHourLaterDate: Date = new Date(currentDateNumber + ONE_HOUR_MILLISECONDS);
      endTime = `${oneHourLaterDate.getHours()}:${oneHourLaterDate.getMinutes()}`;
    } else if (endType === PresetOnceType.TWO_HOUR) {
      const twoHourLaterDate: Date = new Date(currentDateNumber + TWO_HOUR_MILLISECONDS);
      endTime = `${twoHourLaterDate.getHours()}:${twoHourLaterDate.getMinutes()}`;
    } else {
      endTime = TONIGHT_TIME_STRING;
    }
    let zen: NotDisturbTimerPararm = {
      id: NotDisturbTimerId.PRESET_ONCE,
      startTime: `${currentDate.getHours()}:${currentDate.getMinutes()}`,
      endTime: endTime,
      repeat: '',
      isOpen: true,
      repeatType: NotDisturbTimerRepeatType.ONES,
      skipEndTime: 0,
      onceType: endType
    };
    let index: number = zenTimers.findIndex((item) => {
      return item.id === NotDisturbTimerId.PRESET_ONCE;
    });
    if (index < 0) {
      zenTimers.splice(0, 0, zen);
    } else {
      if (zenTimers[index].isOpen) {
        this.refreshOnceTypeSummary(zenTimers[index].onceType as number);
      }
      zenTimers[index] = zen;
    }
    this.refreshOnceTimer(endType);
    SettingsDataUtils.setSettingsDataWithContext(getContext(), FOCUS_MODE_TIMER, JSON.stringify(zenTimers),
      settings.domainName.USER_PROPERTY);
    const onceStartTime = NotDisturbTimerManager.getInstance().getForMatTime(zen.startTime as string);
    let onceEndTime = NotDisturbTimerManager.getInstance().getForMatTime(zen.endTime as string);
    if (onceStartTime >= onceEndTime) {
      onceEndTime = NotDisturbTimerManager.getInstance().getForMatNextTime(zen.endTime as string);
    }
    NotDisturbTimerManager.getInstance().closeNowChange(onceEndTime, true);
  }

  private refreshOnceTypeSummary(type: PresetOnceType): void {
    LogUtil.info(`${TAG} refreshOnceTypeSummary type: ${type}`);
    if (type === PresetOnceType.ONE_HOUR || type === PresetOnceType.TWO_HOUR) {
      const currentDateNumber: number = Date.now();
      const currentDate: Date = new Date(currentDateNumber);
      const laterDate: Date = new Date(
        currentDateNumber + (type == PresetOnceType.ONE_HOUR ? ONE_HOUR_MILLISECONDS : TWO_HOUR_MILLISECONDS));
      this.notDisturbMenusArray[(type == PresetOnceType.ONE_HOUR ? INDEX_ONE_HOUR_OPEN : INDEX_TWO_HOUR_OPEN)]
        .subTitle = NotDisturbUtils.getTimerSummaryForDate(this.timeFormat, currentDate, laterDate);
    }
  }

  private setScheduledOpen(id: number, isOpen: boolean) {
    let zenTimers: NotDisturbTimerPararm[] = NotDisturbTimerManager.getInstance().getTimers(getContext());
    let index: number = zenTimers.findIndex((item) => {
      return item.id === id;
    });
    if (index < 0) {
      LogUtil.error(`${TAG} index error: ${index}`);
      return;
    }
    zenTimers[index].isOpen = isOpen;
    zenTimers[index].skipEndTime = 0;
    SettingsDataUtils.setSettingsDataWithContext(getContext(), FOCUS_MODE_TIMER, JSON.stringify(zenTimers),
      settings.domainName.USER_PROPERTY);
    NotDisturbTimerManager.getInstance().refreshTimer();
  }

  private registerDataChange(): void {
    if (this.dataHelper) {
      SettingsDataUtils.registerSecurityDataChange(this.dataHelper, FOCUS_MODE_ENABLED, this.onDataChange);
    } else {
      (SettingsDataUtils.createDataHelper(FOCUS_MODE_ENABLED) as Promise<dataShare.DataShareHelper>)
        .then((dataShareHelper?: dataShare.DataShareHelper) => {
          if (dataShareHelper) {
            this.dataHelper = dataShareHelper;
            SettingsDataUtils.registerSecurityDataChange(this.dataHelper, FOCUS_MODE_ENABLED, this.onDataChange);
          }
        })
    }
    LogUtil.info(`${TAG} registerDataChange`);
  }

  private unRegisterDataChange(): void {
    SettingsDataUtils.unRegisterSecurityDataChange(this.dataHelper as dataShare.DataShareHelper, FOCUS_MODE_ENABLED);
    LogUtil.info(`${TAG} unRegisterDataChange`);
  }

  private onDataChange = () => {
    let isChecked: boolean = NotDisturbTimerManager.getInstance().isNotDisturbOpen(getContext());
    LogUtil.info(`${TAG} onDataChange: ${isChecked}`);
    if (this.notDisturbMenusArray[0].isSelected === isChecked) {
      return;
    }
    this.notDisturbMenusArray[0].isSelected = isChecked;
  }

  private disableTimer(isOpen: boolean): void {
    this.notDisturbMenusArray.forEach((item) => {
      if (item.key === KEY_TURN_ON) {
        return;
      }
      item.isEnabled = !isOpen;
    });
  }

  private refreshTonight(currentDate: Date): void {
    const hour: number = currentDate.getHours();
    const shouldShow: boolean = hour < TONIGHT_TIME && hour >= NEXT_DAY_TIME;
    if (shouldShow === this.hasTonightItem) {
      return;
    }
    if (shouldShow) {
      if (!this.tonightItem) {
        this.tonightItem = new NotDisturbMenuEntry({
          key: KEY_UNTIL_TONIGHT,
          id: NotDisturbTimerId.PRESET_ONCE,
          title: $r('app.string.not_disturb_until_tonight')
        })
      }
      const tonightDate: Date = new Date(Date.now());
      tonightDate.setHours(TONIGHT_TIME, 0, 0, 0);
      this.tonightItem.subTitle = ResourceUtil.getAnyStrFormatStringSync(
        $r('app.string.not_disturb_tonight_time'), this.timeFormat.format(tonightDate));
      this.notDisturbMenusArray.splice(INDEX_UNTIL_TONIGHT, 0, this.tonightItem);
    } else {
      this.notDisturbMenusArray.splice(INDEX_UNTIL_TONIGHT, 1);
    }
    this.hasTonightItem = shouldShow;
  }

  private refreshOnceTimer(endType: PresetOnceType): void {
    this.notDisturbMenusArray[INDEX_ONE_HOUR_OPEN].isSelected = endType === PresetOnceType.ONE_HOUR ? true : false;
    this.notDisturbMenusArray[INDEX_TWO_HOUR_OPEN].isSelected = endType === PresetOnceType.TWO_HOUR ? true : false;
    if (this.hasTonightItem) {
      this.notDisturbMenusArray[INDEX_UNTIL_TONIGHT].isSelected = endType === PresetOnceType.TONIGHT ? true : false;
    }
  }
}
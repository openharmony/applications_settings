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

import settings from '@ohos.settings';
import systemTimer from '@ohos.systemTimer';
import { BusinessError } from '@ohos.base';
import notificationManager from '@ohos.notificationManager';
import bundleManager from '@ohos.bundle.bundleManager';
import { LogUtil } from '@ohos/settings.common/src/main/ets/utils/LogUtil';
import { SettingsDataUtils } from '@ohos/settings.common/src/main/ets/utils/SettingsDataUtils';
import { GlobalContext } from '@ohos/settings.common/src/main/ets/utils/GlobalContext';
import { DeviceUtil } from '@ohos/settings.common/src/main/ets/utils/BaseUtils';
import {
  NotDisturbUtils,
  FOCUS_MODE_ENABLED,
  ONE_DAY,
  NOT_DISTURB_VALUE_ENABLE,
  NOT_DISTURB_VALUE_DISABLE,
  NOT_DISTURB_VALUE_ERROR,
  FOCUS_MODE_CALL_MESSAGE_POLICY,
  FOCUS_MODE_REPEATE_CALLERS_ENABLE,
  ALLOW_FAVORITE_CONTACTS,
  NOT_DISTURB_NUMBER_ONE,
  FOCUS_MODE_MANUAL_ENABLE,
  EVENT_SET_NOT_DISTURB_TIMER_COMPLETE
} from './utils/NotDisturbUtils';
import {
  NotDisturbTimerPararm,
  NotDisturbTimerRepeatType,
  NotDisturbReportSources,
  AppBundleAndUid
} from './model/NotDisturbTimerPararm';
import common from '@ohos.app.ability.common';
import { AbilityContextManager } from '@ohos/settings.common/src/main/ets/ability/AbilityContextManager';
import { CheckEmptyUtils } from '@ohos/settings.common/src/main/ets/utils/CheckEmptyUtils';
import { EventBus } from '@ohos/settings.common/src/main/ets/framework/common/EventBus';

/* instrument ignore file */
const TAG: string = 'NotDisturbTimerManager';
const DISTURB_MODE_TIMER_ID: string = 'disturb_mode_timer_id';
export const DISTURB_MODE_TRIGGER_START_TIME = 'disturb_mode_trigger_start_time';
export const DISTURB_MODE_TRIGGER_END_TIME = 'disturb_mode_trigger_end_time';
export const FOCUS_MODE_TIMER = 'focus_mode_timer';
const FOCUS_MODE_PROFILE = 'focus_mode_profile';
export const FOCUS_MODE_CLOCK_BUNDLE_NAME: string = 'com.ohos.clock';
export const FOCUS_MODE_CALLUI_BUNDLE_NAME: string = 'com.ohos.callui';
export const FOCUS_MODE_SHARE_BUNDLE_NAME: string = 'com.ohos.instantshare';
const NO_TIMER: number = -1;
const NOT_DISTURB_MODE: number = 1;

/*
 * 免打扰的定时规则处理
 * */
export class NotDisturbTimerManager {
  private static menuManager: NotDisturbTimerManager | undefined = undefined;

  public static getInstance(): NotDisturbTimerManager {
    if (NotDisturbTimerManager.menuManager) {
      return NotDisturbTimerManager.menuManager;
    }
    NotDisturbTimerManager.menuManager = new NotDisturbTimerManager();
    return NotDisturbTimerManager.menuManager;
  }

  public static getContext(): common.Context {
    let context = AbilityContextManager.getContext();
    if (CheckEmptyUtils.isEmpty(context)) {
      context = AbilityContextManager.getExtContext();
    }
    if (CheckEmptyUtils.isEmpty(context)) {
      context = AbilityContextManager.getBackgroundIntentContext();
    }
    if (CheckEmptyUtils.isEmpty(context)) {
      // 免打扰单升单 StaticSubscriberExtensionAbility context
      context = GlobalContext.getInstance().get('TimerContext') as Context;
      LogUtil.showWarn(TAG, `get timer context`);
    }
    LogUtil.showInfo(TAG, 'get context');
    return context;
  }

  //启动定时timer
  async startTimeAlarm(alarmtime: number): Promise<void> {
    let setTimerSuccess: boolean = true;
    try {
      let context = NotDisturbTimerManager.getContext();
      let timerid = this.getTimerId(context);
      this.stopAlarmSelf(timerid);
      const timerId = await systemTimer.createTimer({
        type: systemTimer.TIMER_TYPE_EXACT | systemTimer.TIMER_TYPE_WAKEUP,
        repeat: false,
        wantAgent: await NotDisturbUtils.getAlarmWantAgent(),
        autoRestore: true
      });
      SettingsDataUtils.setSettingsDataWithContext(context,
        DISTURB_MODE_TIMER_ID, String(timerId), settings.domainName.USER_PROPERTY);
      await systemTimer.startTimer(timerId, alarmtime as number);
      LogUtil.info(`${TAG} startTimeAlarm timerId: ${timerId} alarmtime: ${alarmtime} nowtime: ${new Date().getTime()}`);
    } catch (error) {
      LogUtil.error(`${TAG} startTimeAlarm Start timer failed : ${(error as BusinessError).message}`);
      setTimerSuccess = false;
    }
    EventBus.getInstance().emit(EVENT_SET_NOT_DISTURB_TIMER_COMPLETE, setTimerSuccess);
  }

  /**
   * 获取当前生效的定时器的 ID
   *
   * @param context
   * @return 当前生效的定时器的 ID
   */
  getTimerId(context: Context): number {
    const timerIdFromStorage = SettingsDataUtils.getSettingsDataWithContext(context, DISTURB_MODE_TIMER_ID,
      NOT_DISTURB_VALUE_ERROR, settings.domainName.USER_PROPERTY);
    return Number(timerIdFromStorage);
  }

  //停止当前timer
  private stopAlarmSelf(timerId: number): void {
    if (!timerId || timerId === NO_TIMER) {
      return;
    }
    try {
      systemTimer.stopTimer(timerId);
      LogUtil.info(`${TAG} Stop timerId: ${timerId}`);
    } catch (error) {
      LogUtil.error(`${TAG} Stop timer failed: ${(error as BusinessError).message}`);
    }
  }

  /**
   * 停止当前timer
   */
  public stopAlarm(): void {
    let context = NotDisturbTimerManager.getContext();
    let timerid = this.getTimerId(context);
    this.stopAlarmSelf(timerid);
    SettingsDataUtils.setSettingsDataWithContext(context, DISTURB_MODE_TIMER_ID,
      NOT_DISTURB_VALUE_ERROR, settings.domainName.USER_PROPERTY);
  }

  /**
   * 获取定时规则列表
   *
   * @param context
   * @returns 返回所有的定时规则列表
   */
  getTimers(context: Context): Array<NotDisturbTimerPararm> {
    let zenTimersArrays: NotDisturbTimerPararm[] = [];
    let savedTimers = SettingsDataUtils.getSettingsDataWithContext(context,
      FOCUS_MODE_TIMER, '', settings.domainName.USER_PROPERTY);
    if (savedTimers === '') {
      zenTimersArrays = this.setDefaultTimers(context);
      return zenTimersArrays;
    }
    LogUtil.info(`${TAG} getTimers getSettingsData ${savedTimers}`);
    try {
      const arr: NotDisturbTimerPararm[] = JSON.parse(savedTimers);
      if (Array.isArray(arr) && arr.length > 0) {
        zenTimersArrays = arr.filter((item) => {
          return item?.id >= 0;
        })
      } else {
        zenTimersArrays = [];
      }
    } catch (e) {
      LogUtil.error(`${TAG} zenTimersArrays parse error`);
    }
    if (zenTimersArrays.length === 0) {
      zenTimersArrays = this.setDefaultTimers(context);
    }
    return zenTimersArrays;
  }

  /**
   * 设置默认定时规则
   *
   * @param context
   */
  setDefaultTimers(context: Context): Array<NotDisturbTimerPararm> {
    const zenTimersArrays: NotDisturbTimerPararm[] = [{
      id: 1,
      startTime: '22:00',
      endTime: '07:00',
      repeat: '1,7',
      isOpen: false,
      repeatType: 1,
      skipEndTime: 0
    }];
    SettingsDataUtils.setSettingsDataWithContext(context, FOCUS_MODE_TIMER, JSON.stringify(zenTimersArrays),
      settings.domainName.USER_PROPERTY);
    let isSet = SettingsDataUtils.getSettingsDataWithContext(context, FOCUS_MODE_MANUAL_ENABLE,
      NOT_DISTURB_VALUE_DISABLE, settings.domainName.USER_PROPERTY) === NOT_DISTURB_VALUE_ENABLE;
    if (!isSet) {
      SettingsDataUtils.setSettingsDataWithContext(context, FOCUS_MODE_MANUAL_ENABLE, NOT_DISTURB_VALUE_DISABLE,
        settings.domainName.USER_PROPERTY);
    }
    this.initOtherConfig(context);
    return zenTimersArrays;
  }

  /**
   * 获取指定Id的定时规则
   *
   * @param context
   * @param id 定时规则的id
   * @returns 返回指定的定时规则
   */
  getTimerById(context: Context, id: Number): NotDisturbTimerPararm | null {
    try {
      let zenTimersArrays: NotDisturbTimerPararm[] = [];
      let savedTimers = SettingsDataUtils.getSettingsDataWithContext(context, FOCUS_MODE_TIMER, '', settings.domainName.USER_PROPERTY);
      zenTimersArrays = JSON.parse(savedTimers);
      for (let i = 0; i < zenTimersArrays.length; i++) {
        if (zenTimersArrays[i].id === id) {
          return zenTimersArrays[i];
        }
      }
    } catch (e) {
      LogUtil.error(`${TAG} getTimerById fail: ${e?.code}`);
    }
    return null;
  }

  /**
   * 初始化模式类型，以及默认运行打扰的通知应用列表
   *
   * @param context 上下文
   * @param forRestore 是否用于数据恢复，默认false
   */
  async initOtherConfig(context: Context, forRestore: boolean = false): Promise<void> {
    if (CheckEmptyUtils.isEmpty(context)) {
      LogUtil.showError(TAG, `context is null`);
      return;
    }
    let isSet = await this.hasSetNotDisturbWhiteList();
    LogUtil.showInfo(TAG, `isSet: ${isSet}`);
    if (!isSet) {
      if (!forRestore) {
        SettingsDataUtils.setSettingsDataWithContext(context, FOCUS_MODE_CALL_MESSAGE_POLICY, ALLOW_FAVORITE_CONTACTS,
          settings.domainName.USER_PROPERTY);
        SettingsDataUtils.setSettingsDataWithContext(context, FOCUS_MODE_REPEATE_CALLERS_ENABLE,
          NOT_DISTURB_VALUE_ENABLE, settings.domainName.USER_PROPERTY);
      }
      let appFlags = bundleManager.ApplicationFlag.GET_APPLICATION_INFO_DEFAULT;
      let trustList: notificationManager.BundleOption[] = [];
      try {
        let clockAppInfo = await bundleManager.getApplicationInfo(FOCUS_MODE_CLOCK_BUNDLE_NAME, appFlags);
        if (clockAppInfo && clockAppInfo.systemApp) {
          trustList.push({ bundle: FOCUS_MODE_CLOCK_BUNDLE_NAME, uid: clockAppInfo.uid });
        }
      } catch (error) {
        LogUtil.error(`${TAG} getApplicationInfo clockAppInfo : ${(error as BusinessError).message}`);
      }
      try {
        let calluiAppInfo = await bundleManager.getApplicationInfo(FOCUS_MODE_CALLUI_BUNDLE_NAME, appFlags);
        if (calluiAppInfo && calluiAppInfo.systemApp) {
          trustList.push({ bundle: FOCUS_MODE_CALLUI_BUNDLE_NAME, uid: calluiAppInfo.uid });
        }
      } catch (error) {
        LogUtil.error(`${TAG} getApplicationInfo calluiAppInfo : ${(error as BusinessError).message}`);
      }
      let templates: notificationManager.DoNotDisturbProfile[] = [
        {
          id: 1,
          name: 'Not disturb',
          trustlist: trustList
        }
      ]
      notificationManager.addDoNotDisturbProfile(templates).then(() => {
        SettingsDataUtils.setSettingsDataWithContext(context, FOCUS_MODE_PROFILE, NOT_DISTURB_VALUE_ENABLE,
          settings.domainName.USER_SECURITY);
        LogUtil.info(`${TAG} addDoNotDisturbProfile success.`);
      }).catch((error: BusinessError) => {
        LogUtil.error(`${TAG} addDoNotDisturbProfile fail: ${error?.message}`);
      });
    }
  }

  private async hasSetNotDisturbWhiteList(): Promise<boolean> {
    let profile: notificationManager.DoNotDisturbProfile;
    try {
      profile = await notificationManager.getDoNotDisturbProfile(NOT_DISTURB_MODE);
    } catch (err) {
      LogUtil.error(`${TAG} getDoNotDisturbProfile error message: ${err?.message},code:${err?.code}`);
      return false;
    }
    if (!profile || !profile.trustlist || profile.trustlist.length <= 0) {
      return false;
    }
    return true;
  }

  /**
   * 从ANS查询已经添加进白名单的应用
   *
   * @returns 通知白名单应用列表
   */
  async queryTrustAppDataInfo(): Promise<AppBundleAndUid[]> {
    let appInfoDataList: AppBundleAndUid[] = [];
    let profile: notificationManager.DoNotDisturbProfile;
    try {
      profile = await notificationManager.getDoNotDisturbProfile(NOT_DISTURB_MODE);
    } catch (err) {
      LogUtil.error(`${TAG} queryTrustAppDataInfo error: ${err?.message}`);
      return appInfoDataList;
    }
    if (!profile || !profile.trustlist) {
      return appInfoDataList;
    }
    let itemInfo: notificationManager.BundleOption;
    for (let i = 0; i < profile.trustlist.length; i++) {
      itemInfo = profile.trustlist[i];
      if (!itemInfo || !itemInfo.bundle || !itemInfo.uid) {
        continue;
      }
      if (await this.isNotDisturbWhiteApp(itemInfo.bundle)) {
        continue;
      }
      appInfoDataList.push({
        bundleName: itemInfo.bundle,
        uid: itemInfo.uid as number
      });
    }
    return appInfoDataList;
  }

  /**
   * 从ANS查询已经添加进白名单的应用 与允许通知的应用取并集
   *
   * @returns 通知白名单应用数量
   */
  async getCurrentTrustAppListCount(): Promise<number> {
    let trustAppListCount = 0;
    try {
      const appInfoDataList = await this.queryTrustAppDataInfo();
      if (appInfoDataList.length <= 0) {
        return trustAppListCount;
      }
      const data = await notificationManager.getAllNotificationEnabledBundles();
      if (data.length <= 0) {
        return trustAppListCount;
      }
      appInfoDataList?.forEach((item: AppBundleAndUid) => {
        data?.forEach((i) => {
          if (item.bundleName === i.bundle && item.uid === i.uid) {
            trustAppListCount++;
          }
        })
      })
    } catch (err) {
      LogUtil.error(`${TAG} getCurrentTrustAppListCount  error code: ${err?.code} message:${err?.message}`);
    }
    LogUtil.info(`${TAG} trustAppListCount ${trustAppListCount}`);
    return trustAppListCount;
  }


  private async isNotDisturbWhiteApp(bundleName: string): Promise<boolean> {
    if (bundleName !== FOCUS_MODE_CLOCK_BUNDLE_NAME &&
      bundleName !== FOCUS_MODE_CALLUI_BUNDLE_NAME ) {
      return false;
    }
    try {
      let bundleInfo: bundleManager.ApplicationInfo =
        await bundleManager.getApplicationInfo(bundleName,
          bundleManager.ApplicationFlag.GET_APPLICATION_INFO_DEFAULT);
      if (bundleInfo && bundleInfo.systemApp) {
        return true;
      }
    } catch (err) {
      LogUtil.error(`${TAG} isNotDisturbWhiteApp fail: ${err?.message}`);
    }
    return false;
  }

  /**
   * 关闭单次类型timer定时规则
   *
   * @param isClose
   * @param context
   */
  closeTypeOncesDb(isClose: boolean = false): void {
    LogUtil.info(`${TAG} closeTypeOncesDb  start`);
    const context: Context = NotDisturbTimerManager.getContext();
    let zenTimersArrays: NotDisturbTimerPararm[] = this.getTimers(context);
    let isChange = false;
    for (let index = 0; index < zenTimersArrays.length; index++) {
      let zenTimerParam = zenTimersArrays[index];
      if (zenTimerParam.repeatType != NotDisturbTimerRepeatType.ONES) {
        continue;
      }
      if (!zenTimerParam.isOpen) {
        continue;
      }
      if (isClose && zenTimerParam.id < NOT_DISTURB_NUMBER_ONE) {
        let startTime = this.getForMatTime(zenTimerParam.startTime as string);
        let endTime = this.getForMatTime(zenTimerParam.endTime as string);
        let nowtime = new Date().getTime();
        if (endTime <= nowtime || startTime > nowtime) {
          zenTimersArrays[index].isOpen = false;
          isChange = true;
        }
      } else {
        let endTime = this.getForMatTime(zenTimerParam.endTime as string);
        if (endTime <= new Date().getTime()) {
          zenTimersArrays[index].isOpen = false;
          isChange = true;
        }
      }
    }
    if (isChange) {
      SettingsDataUtils.setSettingsDataWithContext(context, FOCUS_MODE_TIMER,
        JSON.stringify(zenTimersArrays), settings.domainName.USER_PROPERTY);
    }
  }

  getForMatTime(time: string): number {
    const timeArray = NotDisturbUtils.forMatTime(time);
    const timeNumber = new Date();
    timeNumber.setHours(timeArray[0]);
    timeNumber.setMinutes(timeArray[1]);
    timeNumber.setSeconds(0);
    timeNumber.setMilliseconds(0);
    return timeNumber.getTime();
  }

  getForMatNextTime(time: string): number {
    const timeArray = NotDisturbUtils.forMatTime(time);
    const timeNumber = new Date();
    timeNumber.setHours(timeArray[0]);
    timeNumber.setMinutes(timeArray[1]);
    timeNumber.setSeconds(0);
    timeNumber.setMilliseconds(0);
    timeNumber.setDate(timeNumber.getDate() + ONE_DAY);
    return timeNumber.getTime();
  }

  /**
   * 手动关闭立即开启开关场景，更新数据库并启动下一次timer
   *
   * @param nowTime
   * @param isSkipOnce
   */
  closeNowChange(nowTime: number, isSkipOnce: boolean = false): void {
    const context: Context = NotDisturbTimerManager.getContext();
    let zenTimersArrays: NotDisturbTimerPararm[] = this.getTimers(context);
    let isChange = false;
    for (let index = 0; index < zenTimersArrays.length; index++) {
      if (isSkipOnce && zenTimersArrays[index].repeatType == NotDisturbTimerRepeatType.ONES) {
        continue;
      }
      if (!zenTimersArrays[index].isOpen) {
        continue;
      }
      if (zenTimersArrays[index].repeatType == NotDisturbTimerRepeatType.ONES) {
        zenTimersArrays[index].isOpen = false;
        isChange = true;
        continue;
      }
      let arrayTime: number[] = NotDisturbUtils.getNextTime(zenTimersArrays[index]);
      if (nowTime > arrayTime[1] || nowTime < arrayTime[0]) {
        continue;
      }
      zenTimersArrays[index].skipEndTime = arrayTime[1];
      LogUtil.info(`${TAG} closeNowChange set skipEndTime : ${zenTimersArrays[index].startTime} --- ${zenTimersArrays[index].endTime}`);
      isChange = true;
    }
    if (isChange) {
      SettingsDataUtils.setSettingsDataWithContext(context, FOCUS_MODE_TIMER,
        JSON.stringify(zenTimersArrays), settings.domainName.USER_PROPERTY);
    }
    this.updateTimer(zenTimersArrays);
  }

  /**
   * 根据定时规则更新timer的启动、关闭
   *
   * @param isNeedClose
   */
  async refreshTimer(isNeedClose: boolean = false, zenTimers: NotDisturbTimerPararm[] = []) {
    let zenTimersArrays: NotDisturbTimerPararm[] = [];
    if (zenTimers.length == 0) {
      zenTimersArrays = this.getTimers(GlobalContext.getInstance().get('TimerContext') as Context);
    } else {
      zenTimersArrays = zenTimers;
    }
    if (isNeedClose) {
      this.updateTimer(zenTimersArrays, true);
    } else {
      this.updateTimer(zenTimersArrays);
    }
  }

  async updateTimer(zenTimersArrays: Array<NotDisturbTimerPararm>, isNeedClose: boolean = false): Promise<void> {
    LogUtil.info(`${TAG} updateTimer start`);
    let timeArray: number[] = this.calNextTime(zenTimersArrays);
    let startTime = timeArray[0];
    let endTime = timeArray[1];
    LogUtil.info(`${TAG} updateTimer all startTime: ${startTime}, endTime: ${endTime}`);
    const context: Context = NotDisturbTimerManager.getContext();
    let start = Number(SettingsDataUtils.getSettingsDataWithContext(context, DISTURB_MODE_TRIGGER_START_TIME,
      NOT_DISTURB_VALUE_ERROR, settings.domainName.USER_PROPERTY));
    let end = Number(SettingsDataUtils.getSettingsDataWithContext(context, DISTURB_MODE_TRIGGER_END_TIME,
      NOT_DISTURB_VALUE_ERROR, settings.domainName.USER_PROPERTY));
    LogUtil.info(`${TAG} updateTimer start: ${start}   end: ${end}}  nowtime: ${new Date().getTime()}`);
    if (startTime == 0 && endTime == 0) {
      this.stopAlarm();
      SettingsDataUtils.setSettingsDataWithContext(context, DISTURB_MODE_TRIGGER_START_TIME,
        NOT_DISTURB_VALUE_ERROR, settings.domainName.USER_PROPERTY);
      SettingsDataUtils.setSettingsDataWithContext(context, DISTURB_MODE_TRIGGER_END_TIME,
        NOT_DISTURB_VALUE_ERROR, settings.domainName.USER_PROPERTY);
      SettingsDataUtils.setSettingsDataWithContext(context, FOCUS_MODE_ENABLED,
        NOT_DISTURB_VALUE_DISABLE, settings.domainName.USER_SECURITY);
      return;
    } else if (start != startTime || end != endTime) {
      SettingsDataUtils.setSettingsDataWithContext(context, DISTURB_MODE_TRIGGER_START_TIME,
        String(startTime), settings.domainName.USER_PROPERTY);
      SettingsDataUtils.setSettingsDataWithContext(context, DISTURB_MODE_TRIGGER_END_TIME,
        String(endTime), settings.domainName.USER_PROPERTY);
    }
    this.setTimerStatus(context, startTime, endTime, isNeedClose);
  }

  /**
   * 计算下一次生效的时间规则区间
   *
   * @param zenTimersArrays 所有定时规则列表
   * @returns 开启时间-结束时间
   */
  calNextTime(zenTimersArrays: Array<NotDisturbTimerPararm>): Array<number> {
    let startTime = 0;
    let endTime = 0;
    let isChange = false;
    LogUtil.info(`${TAG} calNextTime arraysize: ${zenTimersArrays.length}`);
    for (let i = 0; i < zenTimersArrays.length; i++) {
      if (!zenTimersArrays[i].isOpen) {
        continue;
      }
      LogUtil.info(`${TAG} calNextTime zenTimersArrays[${i}]: ${zenTimersArrays[i].startTime}  - ${zenTimersArrays[i].endTime}`);
      let skipEndTime = zenTimersArrays[i].skipEndTime as number;
      let newTime = new Date().getTime();
      if (skipEndTime != 0 && skipEndTime <= newTime ||
        skipEndTime != 0 && this.isCheckStartTimeWithNow(zenTimersArrays[i].startTime, skipEndTime)) {
        zenTimersArrays[i].skipEndTime = 0;
        LogUtil.info(`${TAG} calNextTime skipEndTime = 0`);
        isChange = true;
      }
      let arrayTime: number[] = NotDisturbUtils.getNextTime(zenTimersArrays[i]);
      LogUtil.info(`${TAG} calNextTime getNextTime [${i}]: ${arrayTime[0]} --- ${arrayTime[1]}`);
      if (arrayTime[1] <= newTime) {
        continue;
      }
      if (startTime == 0 && endTime == 0) {
        startTime = arrayTime[0];
        endTime = arrayTime[1];
      } else if (arrayTime[0] < startTime) {
        startTime = arrayTime[0];
        endTime = arrayTime[1];
      }
    }
    if (isChange) {
      const context: Context = NotDisturbTimerManager.getContext();
      SettingsDataUtils.setSettingsDataWithContext(context, FOCUS_MODE_TIMER,
        JSON.stringify(zenTimersArrays), settings.domainName.USER_PROPERTY);
    }
    return [startTime, endTime];
  }

  /**
   * 比较跳过的定时器规则，开始时间是否大于当前时间，如果大于则表示跳过的endskipTime置0，不跳过了，用于手动往前调整时间的时候
   *
   * @param startTime
   * @param endskipTime
   * @returns true:大于 false: 小于
   */
  isCheckStartTimeWithNow(startTime: string, endskipTime: number): boolean {
    const timeStart: number[] = NotDisturbUtils.forMatTime(startTime);
    const startAlarmTime = new Date();
    startAlarmTime.setHours(timeStart[0]);
    startAlarmTime.setMinutes(timeStart[1]);
    startAlarmTime.setSeconds(0);
    startAlarmTime.setMilliseconds(0);
    if (startAlarmTime.getTime() >= endskipTime) {
      startAlarmTime.setDate(startAlarmTime.getDate() - ONE_DAY);
    }
    if (startAlarmTime.getTime() > new Date().getTime()) {
      return true;
    }
    return false;
  }

  /**
   * 根据时间生效区间，判断设置免打扰开关状态及启动timer
   *
   * @param context
   * @param startTime
   * @param endTime
   * @param isNeedClose 最后是否需要关闭免打扰开关
   */
  setTimerStatus(context: Context, startTime: number, endTime: number, isNeedClose: boolean): void {
    let modeValue = SettingsDataUtils.getSettingsDataWithContext(context, FOCUS_MODE_ENABLED, '', settings.domainName.USER_SECURITY);
    LogUtil.info(`${TAG} updateTimer focus_mode_enable modeValue: ${modeValue}`);
    let nowTime = new Date().getTime();
    if (modeValue === NOT_DISTURB_VALUE_ENABLE && !isNeedClose) {
      // 已是开启状态，需判断当前时间与startTime-endTime，看是否需要开启
      if (startTime > nowTime) {
        // 不在区间内，需先关掉开关，然后定时开启
        SettingsDataUtils.setSettingsDataWithContext(context, FOCUS_MODE_ENABLED,
          NOT_DISTURB_VALUE_DISABLE, settings.domainName.USER_SECURITY);
        LogUtil.info(`${TAG} updateTimer open startTimeAlarm endTime: ${startTime}`);
        this.startTimeAlarm(startTime);
        NotDisturbUtils.reportNotDisturb('off', NotDisturbReportSources.TIMER);
      } else {
        // 已在区间内，直接定时关闭
        LogUtil.info(`${TAG} updateTimer open startTimeAlarm endTime: ${endTime}`);
        this.startTimeAlarm(endTime);
      }
    } else {
      if (startTime <= nowTime && endTime > nowTime) {
        // 立即开启
        SettingsDataUtils.setSettingsDataWithContext(context, FOCUS_MODE_ENABLED,
          NOT_DISTURB_VALUE_ENABLE, settings.domainName.USER_SECURITY);
        LogUtil.info(`${TAG} updateTimer close startTimeAlarm endTime: ${endTime}`);
        this.startTimeAlarm(endTime);
        NotDisturbUtils.reportNotDisturb('on', NotDisturbReportSources.TIMER);
      } else {
        if (isNeedClose) {
          SettingsDataUtils.setSettingsDataWithContext(context, FOCUS_MODE_ENABLED,
            NOT_DISTURB_VALUE_DISABLE, settings.domainName.USER_SECURITY);
          LogUtil.info(`${TAG} updateTimer close startTimeAlarm focus_mode_enable 0`);
        }
        LogUtil.info(`${TAG} updateTimer close startTimeAlarm startTime: ${startTime}`);
        this.startTimeAlarm(startTime);
      }
    }
  }

  /**
   * 免打扰开关状态
   *
   * @param context
   * @returns 是否开启了免打扰
   */
  isNotDisturbOpen(context: Context): boolean {
    if (context === null || context === undefined) {
      LogUtil.showError(TAG, `isNotDisturbOpen context is null`);
      return false;
    }
    return SettingsDataUtils.getSettingsDataWithContext(context, FOCUS_MODE_ENABLED, '',
      settings.domainName.USER_SECURITY) === NOT_DISTURB_VALUE_ENABLE;
  }
}
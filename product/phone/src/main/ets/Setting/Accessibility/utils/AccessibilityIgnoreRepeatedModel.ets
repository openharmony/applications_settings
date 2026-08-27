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
import config from '@ohos.accessibility.config';
import window from '@ohos.window';
import { EventBus } from '@ohos/settings.common/src/main/ets/framework/common/EventBus';
import { LogUtil } from '@ohos/settings.common/src/main/ets/utils/LogUtil';
import { DisplayUtils, SheetDialogStyle } from '@ohos/settings.common/src/main/ets/utils/DisplayUtils';
import { AccessibilitySettingModel } from '@ohos/settings.accessibility/src/main/ets/model/AccessibilitySettingModel';
import { SettingsDataUtils } from '@ohos/settings.common/src/main/ets/utils/SettingsDataUtils';
import {
  CLICK_SWITCH_OFF,
  CLICK_SWITCH_ON,
  IGNORE_REPEATED_CLICK_CACHE_FLAG,
  IGNORE_REPEATED_CLICK_EXCLUDE_FLAG,
  IGNORE_REPEATED_SHOW_DIALOG,
  IGNORE_REPEATED_TIME_NAME_MAP,
  IGNORE_REPEATED_TIMER_DOWN_EVENT,
  IGNORE_REPEATED_CLOSE_REFRESH_EVENT
} from '../constant/Constants';

const TAG: string = 'IgnoreRepeatedStateModel : ';

/**
 * 辅助功能忽略重复点击状态管理类
 *
 * @since 2025-06-30
 */
export class IgnoreRepeatedStateModel {
  /**
   * 单例对象
   */
  private static instance: IgnoreRepeatedStateModel;
  public ignoreRepeatClick: boolean = false;
  // 试用流程，需要关闭忽略重复点击，用来判断是否需要恢复原来状态
  public ignoreRepeatClickOriginal: boolean = false;
  public repeatClickIntervalValue: string = '';
  public repeatClickIntervalValueCache: string = '';
  public closeNotifyFlag: boolean = false;

  /**
   * 单例方法
   *
   * @returns 单例对象
   */
  public static getInstance(): IgnoreRepeatedStateModel {
    if (!IgnoreRepeatedStateModel.instance) {
      IgnoreRepeatedStateModel.instance = new IgnoreRepeatedStateModel();
    }
    return IgnoreRepeatedStateModel.instance;
  }

  static getSelectIgnoreRepeatClickIntervalName(repeatClickTime: config.RepeatClickInterval): string {
    let selectName: string = IGNORE_REPEATED_TIME_NAME_MAP['Shortest'];
    IGNORE_REPEATED_TIME_NAME_MAP.forEach((value, key) => {
      if (repeatClickTime.toString() === key) {
        selectName = value;
      }
    });
    IgnoreRepeatedStateModel.getInstance().repeatClickIntervalValue = selectName;
    IgnoreRepeatedStateModel.getInstance().repeatClickIntervalValueCache = '';
    LogUtil.info(`${TAG} getSelectIgnoreRepeatClickIntervalName result : ${selectName}`);
    return selectName;
  }

  static getSelectIgnoreRepeatClickIntervalKey(): config.RepeatClickInterval {
    let repeatClickTime: config.RepeatClickInterval = 'Shortest';
    let IgnoreRepeatedInstance: IgnoreRepeatedStateModel = IgnoreRepeatedStateModel.getInstance();
    IGNORE_REPEATED_TIME_NAME_MAP.forEach((value, key) => {
      if (IgnoreRepeatedInstance.ConvertIntervalValue(IgnoreRepeatedInstance.repeatClickIntervalValue) ===
      IgnoreRepeatedInstance.ConvertIntervalValue(value)) {
        repeatClickTime = key as config.RepeatClickInterval;
      }
    });
    LogUtil.info(`${TAG} getSelectIgnoreRepeatClickIntervalKey result : ${repeatClickTime}`);
    return repeatClickTime;
  }

  /**
   * 判断缓存数据是否变更，变更则赋值给原数据
   * @returns true: 变更; false: 未变更
   */
  public saveRepeatClickIntervalValue(): boolean {
    LogUtil.info(`${TAG} saveRepeatClickIntervalValue repeatClickIntervalValue : ${this.repeatClickIntervalValue},
     repeatClickIntervalValueCache: ${this.repeatClickIntervalValueCache}`);
    if (!this.ignoreRepeatClick) {
      this.repeatClickIntervalValue = this.repeatClickIntervalValueCache;
      EventBus.getInstance().emit(IGNORE_REPEATED_SHOW_DIALOG, true, 'open');
      return true;
    }
    // 与初始值不一致，弹出确认弹框，否则不弹框
    if (this.repeatClickIntervalValue !== this.repeatClickIntervalValueCache) {
      EventBus.getInstance().emit(IGNORE_REPEATED_SHOW_DIALOG, true, 'change');
      return true;
    }
    return false;
  }

  /**
   * 进入试用流程，关闭忽略重复点击，数据缓存在settingsData里
   */
  public cacheIgnoreClickState(): void {
    if (this.ignoreRepeatClick) {
      this.ignoreRepeatClickOriginal = true;
      AccessibilitySettingModel.accessibilityConfigSetting('ignoreRepeatTouches', false);
      SettingsDataUtils.setSecureValue(IGNORE_REPEATED_CLICK_CACHE_FLAG, CLICK_SWITCH_ON);
    }
    SettingsDataUtils.setSecureValue(IGNORE_REPEATED_CLICK_EXCLUDE_FLAG, CLICK_SWITCH_ON);
  }

  /**
   * 试用流程结束，恢复SettingsData历史状态
   */
  public recoveryIgnoreClickData(): void {
    let ignoreRepeatFlag: boolean = SettingsDataUtils.getSecureValue(
      IGNORE_REPEATED_CLICK_CACHE_FLAG, CLICK_SWITCH_OFF) === CLICK_SWITCH_ON;
    if (ignoreRepeatFlag) {
      SettingsDataUtils.setSecureValue(IGNORE_REPEATED_CLICK_CACHE_FLAG, CLICK_SWITCH_OFF);
    }
    SettingsDataUtils.setSecureValue(IGNORE_REPEATED_CLICK_EXCLUDE_FLAG, CLICK_SWITCH_OFF);
  }

  /**
   * 试用流程结束，恢复工具类历史状态
   */
  public recoveryIgnoreClickState(pageType: string = ''): void {
    IgnoreRepeatedStateModel.getInstance().repeatClickIntervalValueCache = '';
    if (IgnoreRepeatedStateModel.getInstance().ignoreRepeatClickOriginal) {
      IgnoreRepeatedStateModel.getInstance().ignoreRepeatClick = true;
      if (pageType === 'OriginalClear') {
        IgnoreRepeatedStateModel.getInstance().ignoreRepeatClickOriginal = false;
      }
      AccessibilitySettingModel.accessibilityConfigSetting('ignoreRepeatTouches', true);
    }
  }

  public closeRepeatClickState(): void {
    LogUtil.info(`${TAG} closeRepeatClickState.`);
    IgnoreRepeatedStateModel.getInstance().ignoreRepeatClick = false;
    AccessibilitySettingModel.accessibilityConfigSetting('ignoreRepeatTouches', false);
    IgnoreRepeatedStateModel.getInstance().ignoreRepeatClickOriginal = false;
    IgnoreRepeatedStateModel.getInstance().repeatClickIntervalValueCache = '';
  }

  /**
   * 第一次开机，关闭忽略重复点击时，刷新状态
   */
  public closeNotifyRefreshState(): void {
    if (!this.closeNotifyFlag) {
      EventBus.getInstance().emit(IGNORE_REPEATED_CLOSE_REFRESH_EVENT, false);
      this.closeNotifyFlag = true;
    }
  }

  /**
   * 查询设置窗口是否为指定模式
   */
  public checkWindowStatusType(state: window.WindowStatusType): boolean {
    try {
      let mainWindow: window.Window | undefined = AppStorage.get<window.Window>('mainWindow');
      if (!mainWindow) {
        mainWindow = AppStorage.get<window.WindowStage>('windowStage')?.getMainWindowSync();
      }
      if (!mainWindow) {
        LogUtil.error(`${TAG} isFloatScreenStatus get mainWindow failed.`);
        return false;
      }
      let windowStatusType: window.WindowStatusType = mainWindow.getWindowStatus();
      LogUtil.debug(`${TAG} WindowStatusType ${windowStatusType}`);
      return windowStatusType === state;
    } catch (err) {
      LogUtil.error(`${TAG} isFloatScreenStatus failed. Error code: ${err?.code} message: ${err?.message}`);
      return false;
    }
  }

  /**
   * 判断是否是半模态底部弹窗样式，或者分屏、悬浮窗模式
   *
   * @return true: 是  false: 不是
   */
  public isWideScreenMode(): boolean {
    if (DisplayUtils.getSheetStyle() === SheetDialogStyle.BOTTOM_DIALOG_STYLE ||
    this.checkWindowStatusType(window.WindowStatusType.FLOATING) ||
    this.checkWindowStatusType(window.WindowStatusType.SPLIT_SCREEN)) {
      return true;
    } else {
      return false;
    }
  }

  public ConvertIntervalValue(convertStr: string = ''): number {
    let intervalNum: string = '0';
    let intervalValue: string =
      !convertStr ? IgnoreRepeatedStateModel.getInstance().repeatClickIntervalValueCache : convertStr;
    try {
      if (intervalValue !== '') {
        intervalNum = intervalValue.replace(/[^\d.]/g, '');
      }
    } catch (err) {
      LogUtil.error(`${TAG} ConvertIntervalValue error: ${err?.code}`);
    }
    return Number(intervalNum);
  }

  public formatToOneDecimal(str: string): string {
    let num = Number(str);
    if (isNaN(num)) {
      return '0.1';
    }
    return num.toFixed(1);
  }
}

/**
 * 忽略重复点击，按钮倒计时
 *
 * @since 2025-07-01
 */
export class CountDownTimer {
  public tag: string = 'CountDownTimer: ';
  public timer: number | null = null;
  public timerType: string = '';
  public remainingTime: number;

  constructor(timerType: string, remainingTime: number) {
    this.remainingTime = remainingTime;
    this.timerType = timerType;
  }

  aboutToAppear(): void {
    LogUtil.info(`${this.tag} aboutToAppear`);
  }

  aboutToDisappear(): void {
    LogUtil.info(`${this.tag} aboutToDisappear`);
    clearInterval(this.timer);
  }

  stopTimer(): void {
    if (this.timer !== null) {
      clearInterval(this.timer);
    }
  }

  startCountdown() {
    this.timer = setInterval(() => {
      if (this.remainingTime > 0) {
        this.remainingTime -= 0.01;
      } else {
        EventBus.getInstance().emit(IGNORE_REPEATED_TIMER_DOWN_EVENT, this.timerType);
        clearInterval(this.timer);
      }
    }, 10); // 每隔10毫秒（即0.01秒）调用一次
  }
}


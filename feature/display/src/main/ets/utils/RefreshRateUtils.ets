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

import hgmnapi from '@ohos.libhgmnapi.z.so';
import systemParameter from '@ohos.systemparameter';
import emitter from '@ohos.events.emitter';
import { SettingsDataUtils } from '@ohos/settings.common/src/main/ets/utils/SettingsDataUtils';
import { LogUtil } from '@ohos/settings.common/src/main/ets/utils/LogUtil';
import { Trace } from '@ohos/settings.common/src/main/ets/utils/Trace';
import { HiSysEventUtil } from '@ohos/settings.common/src/main/ets/systemEvent/HiSysEventUtil';
import { HiSysDisplayBrightnessEventGroup } from '@ohos/settings.common/src/main/ets/systemEvent/BehaviorEventConsts';
import { ResourceUtil } from '@ohos/settings.common/src/main/ets/utils/ResourceUtil';
import { EVENT_ID_REFRESH_RATE, EVENT_ID_COLOR_MODE } from '@ohos/settings.common/src/main/ets/event/types';

const SCREEN_ID: number = 0;
const TAG: string = 'RefreshRateUtlls: ';

const CUSTOM_REFRESH_RATE_LEVEL_MAP: Map<number, string> = new Map([
  [1, 'app.string.screen_refresh_rate_standard'],
  [2, 'app.string.screen_refresh_rate_mid'],
  [3, 'app.string.screen_refresh_rate_high'],
  [0, 'app.string.screen_refresh_rate_dynamic'],
]);

// 屏幕刷新率
const REFRESH_TYPE: string = 'settings.display.hw_screen_freq';
const DYNAMIC_TYPE: string = '-1';
const HIGH_TYPE: string = '3';
const MID_TYPE: string = '2';
const STANDARD_TYPE: string = '1';
const REFRESH_RATE_INVALID: number = 0; //0Hz
const SETTINGS_SYSTEM_REFRESH_RATE_TEXT: string = 'settings.system.screen.refresh_rate_text';
const REFRESH_RATE_INVALID_TEXT: string = '0';
const SUPPORT_DYNAMIC_POLICY: number = -1;
const SORT_INDEX_TWO: number = 2;
const REFRESH_RATE_OPTIONS_NUM_TWICE: number = 2;
const REFRESH_RATE_OPTIONS_NUM_MULTI: number = 3;
const KEY_SUFFIX: string = 'Hz';

enum ScreenRefreshRate {
  'High' = 3,
  'Medium' = 2,
  'Standard' = 1,
  'Dynamic' = 0,
}

/**
 * 显示工具类
 */
export class RefreshRateUtils {

  /**
   * 获取支持的屏幕刷新率列表
   * @returns 屏幕刷新率列表
   */
  public static getScreenRefreshRates(): Array<number> {
    let refreshRates: number[] = [];
    try {
      refreshRates = hgmnapi.getScreenSupportedRefreshRates(SCREEN_ID);
    } catch (error) {
      LogUtil.error(`${TAG} getScreenRefreshRates failed, error ${error}`);
    }
    return refreshRates;
  }

  /**
   * 获取当前屏幕刷新率
   * @returns 当前屏幕刷新率
   */
  public static getCurrentScreenRefreshRate(): number {
    let refreshRate: number = REFRESH_RATE_INVALID;
    try {
      refreshRate = hgmnapi.getCurrentRefreshRateMode(SCREEN_ID);
    } catch (error) {
      LogUtil.error(`${TAG} getCurrentScreenRefreshRate failed, error ${error}, invalid mode: 0`);
    }
    return refreshRate;
  }

  /**
   * 设置屏幕刷新率
   * @param refreshRate 屏幕刷新率
   */
  public static setScreenRefreshRate(refreshRate: number): boolean {
    try {
      hgmnapi.setRefreshRateMode(refreshRate);
      return true;
    } catch (error) {
      LogUtil.error(`${TAG} setScreenRefreshRate failed, error ${error}`);
    }
    return false;
  }

  static supportRefreshRates(): boolean {
    try {
      let refreshRates: number[] = [];
      refreshRates = hgmnapi.getScreenSupportedRefreshRates(SCREEN_ID);
      LogUtil.info(`${TAG} refreshRates length is ${refreshRates.length}`);
      return refreshRates.length === 3;
    } catch (error) {
      LogUtil.error(`${TAG} getScreenSupportedRefreshRates ${error?.message} code: ${error?.code}`);
      return true;
    }
  }

  /**
   * 设置刷新率模式SCREEN_REFRESH_RATE
   */
  static setScreenRefreshRateValue(value: string) {
    let refreshValue: string = value.toLowerCase();
    let refreshType: number = Number(DYNAMIC_TYPE);
    switch (refreshValue) {
      case 'high':
        refreshType = RefreshRateUtils.supportRefreshRates() ? Number(MID_TYPE) : Number(HIGH_TYPE);
        break;
      case 'standard':
        refreshType = Number(STANDARD_TYPE);
        break;
      case 'medium':
        refreshType = Number(MID_TYPE);
        break;
      default:
        refreshType = Number(DYNAMIC_TYPE);
        break;
    }
    try {
      SettingsDataUtils.setSettingsData(REFRESH_TYPE, String(refreshType));
      hgmnapi.setRefreshRateMode(refreshType);
      emitter.emit({
        eventId: EVENT_ID_REFRESH_RATE
      });
      LogUtil.info(`${TAG} refreshType is ${refreshType}`);
    } catch (error) {
      LogUtil.error(`${TAG} setRefreshRateMode fail ${error?.code} msg ${error?.message}`);
    }
  }

  /**
   * 查询“屏幕刷新率”的实时状态
   */
  static getRefreshType(): string {
    let refreshType: string = SettingsDataUtils.getSettingsData(REFRESH_TYPE, '-1');
    LogUtil.info(`${TAG} getRefreshType ${refreshType}`);
    let refreshText: string = '';
    switch (refreshType) {
      case DYNAMIC_TYPE:
        refreshText = 'Dynamic';
        break;
      case MID_TYPE:
        refreshText = RefreshRateUtils.supportRefreshRates() ? 'High' : 'Medium';
        break;
      case STANDARD_TYPE:
        refreshText = 'Standard';
        break;
      case HIGH_TYPE:
        refreshText = 'High';
        break;
      default:
        refreshText = 'Dynamic';
        break;
    }
    return refreshText;
  }

  /**
   * 屏幕刷新率--展示的title
   */
  static getRefreshTypeTitle(): string {
    let refreshType: string = SettingsDataUtils.getSettingsData(REFRESH_TYPE, '-1');
    LogUtil.info(`${TAG} getRefreshTypeTitle ${refreshType}`);
    let refreshTitle: string = '';
    switch (refreshType) {
      case STANDARD_TYPE:
        refreshTitle = ResourceUtil.getStringByName('screen_refresh_rate_standard');
        break;
      case MID_TYPE:
        refreshTitle = RefreshRateUtils.supportRefreshRates() ? ResourceUtil.getStringByName('screen_refresh_rate_high') :
              ResourceUtil.getStringByName('screen_refresh_rate_mid');
        break;
      case DYNAMIC_TYPE:
        refreshTitle = ResourceUtil.getStringByName('screen_refresh_rate_dynamic');
        break;
      case HIGH_TYPE:
        refreshTitle = ResourceUtil.getStringByName('screen_refresh_rate_high');
        break;
      default:
        refreshTitle = ResourceUtil.getStringByName('screen_refresh_rate_dynamic');
        break;
    }
    return refreshTitle;
  }
}

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

import { config } from '@kit.AccessibilityKit';
import { uiAppearance } from '@kit.ArkUI';
import { i18n } from '@kit.LocalizationKit';
import { BusinessError } from '@ohos.base';
import sensor from '@ohos.sensor';
import settings from '@ohos.settings';
import { displayDataManager } from '@ohos/settings.common/src/main/ets/data/DisplayDataManager';
import { SystemParamUtils } from '@ohos/settings.common/src/main/ets/screenReader/utils/SystemParamUtils';
import { CapabilitySupportUtils } from '@ohos/settings.common/src/main/ets/utils/CapabilitySupportUtils';
import { LogUtil } from '@ohos/settings.common/src/main/ets/utils/LogUtil';
import { PreferencesUtil } from '@ohos/settings.common/src/main/ets/utils/PreferencesUtil';
import { ResourceUtil } from '@ohos/settings.common/src/main/ets/utils/ResourceUtil';
import { SettingsDataUtils } from '@ohos/settings.common/src/main/ets/utils/SettingsDataUtils';
import {
  DEFAULT_DARK_MODE_END_TIME,
  DEFAULT_DARK_MODE_START_TIME,
  SETTINGS_UI_APPEARANCE_DARK_MODE_ENDTIME,
  SETTINGS_UI_APPEARANCE_DARK_MODE_STARTTIME
} from '@ohos/settings.display/src/main/ets/constant/DarkModeConstant';
import { HOUR_24, MIN_60 } from '@ohos/settings.display/src/main/ets/constant/DisplayConstant';
import { DisplayMeunShowUtils } from '@ohos/settings.display/src/main/ets/utils/DisplayMenuShowUtils';
import { CUTOUTS_PARAM, HideCutoutsNum, SMART_RESOLUTION_TYPE, } from '../Constant/Constant';
/* instrument ignore file */
const TAG: string = 'DisplayUtils';
const EYE_PROTECT_SWITCH: string = 'settings.display.eyeProtectSwitch';
const COLOR_TEMPERATURE_SWITCH: string = 'settings.display.colorTemperatureSwitch';
const SUPPORT_RESOLUTION_CHANGE_KEY: string = 'settings.display.supportResolutionChange';
const NOT_SUPPORT_RESOLUTION_CHANGE: string = 'false';
const SUPPORT_RESOLUTION_CHANGE: string = 'true';

export class DisplayUtils {

  public static isEyeProtectedSupport(): boolean {
    let isSupport: boolean = PreferencesUtil.getSync(EYE_PROTECT_SWITCH, false) as boolean;
    LogUtil.info(`${TAG} PreferencesUtil getSupported eyeProtectSwitch : ${isSupport}`);
    return isSupport;
  }

  public static isColorModeSupport(): boolean {
    let isSupport: boolean = PreferencesUtil.getSync(COLOR_TEMPERATURE_SWITCH, false) as boolean;
    LogUtil.info(`${TAG} PreferencesUtil getSupported colorTemperatureSwitch : ${isSupport}`);
    return isSupport;
  }

  public static async isAutoAdjustSupport(): Promise<boolean> {
    let data: sensor.Sensor;
    try {
      data = await sensor.getSingleSensor(sensor.SensorId.AMBIENT_LIGHT);
      LogUtil.info(`${TAG} get sensor result ${data?.sensorName}`);
      if (data?.sensorName) {
        return true;
      } else {
        return false;
      }
    } catch (err) {
      LogUtil.error(`${TAG} get singleSensor failed. Error code: ${err?.code} message: ${err?.message}`);
      return false;
    }
  }

  /**
   * 设备是否支持强制横屏设置项显示
   *
   * @returns boolean
   */
  public static isDeviceSupportForcedLandscape(): boolean {
    return CapabilitySupportUtils.isSupportForcedLandscape();
  }

  public static isCurrentSupportForcedLandscape(): boolean {
    let isCurrentSupportForcedLandscape: boolean = SettingsDataUtils.getSettingsData('window_pcmode_switch_status',
      'false', settings.domainName.USER_PROPERTY) === 'false';
    LogUtil.info(`${TAG} isCurrentSupportForcedLandscape: ${isCurrentSupportForcedLandscape}`)
    return isCurrentSupportForcedLandscape;
  }

  /**
   * 设备是否支持高级设置显示
   *
   * @returns true 表示支持 false 表示不支持
   */
  public static isAdvanceSettingSupport(): boolean {
    return DisplayMeunShowUtils.isHdrSupport() || DisplayMeunShowUtils.isBionicVisionSupport() ||
    CapabilitySupportUtils.isSupportAiHDRVideo();
  }

  /**
   * 获取定时时间段
   *
   * @returns string 表示当前选中的定时时间
   */
  public static getScheduleTimeframe(): string {
    const startTime: number =
      Number.parseInt(SettingsDataUtils.getSettingsDataDomain(SETTINGS_UI_APPEARANCE_DARK_MODE_STARTTIME,
        DEFAULT_DARK_MODE_START_TIME,
        settings.domainName.USER_PROPERTY));
    const endTime: number =
      Number.parseInt(SettingsDataUtils.getSettingsDataDomain(SETTINGS_UI_APPEARANCE_DARK_MODE_ENDTIME,
        DEFAULT_DARK_MODE_END_TIME,
        settings.domainName.USER_PROPERTY));
    const startTimeContent: string = DisplayUtils.formatScheduleTime(startTime);
    const endTimeContent: string = DisplayUtils.formatScheduleTime(endTime);
    let resource: Resource =
      endTime / MIN_60 >= HOUR_24 ? $r('app.string.zen_mode_ruletime_nextday') : $r('app.string.timer_between');
    return ResourceUtil.getAnyStrFormatStringSync(resource, startTimeContent, endTimeContent);
  }

  /**
   * 将分钟数转化为 上午/下午 hh:mm形式
   *
   * @param minutesNumber 分钟数
   * @returns 上午/下午 hh:mm 时间
   */
  private static formatScheduleTime(minutesNumber: number): string {
    let hour: number = Math.floor(minutesNumber / MIN_60);
    let minute: number = minutesNumber % MIN_60;
    const currentDate: Date = new Date();
    currentDate.setHours(hour, minute);
    let dateFormat = new Intl.DateTimeFormat(i18n.System.getSystemLanguage(), {
      timeStyle: 'short',
      hour12: !i18n.System.is24HourClock(),
      timeZone: i18n.getTimeZone().getID()
    });
    return dateFormat.format(currentDate);
  }

  /**
   * 手动改变深浅色的时候需要让字体显示不同的颜色
   *
   * @returns ResourceColor
   */
  public static getColor(): ResourceColor {
    try {
      return uiAppearance.getDarkMode() === 0 ? $r('app.color.dark_color') : $r('app.color.base_color');
    } catch (e) {
      LogUtil.error(`${TAG} getDarkMode err err.code ${e?.code} err.message ${e?.message}}`);
      return $r('app.color.base_color');
    }
  }

  /**
   * 开启深色模式的时候需要关闭高对比度
   *
   * @returns void
   */
  public static closeHighContrastTextMode(): void {
    config.highContrastText.set(false).then(() => {
      LogUtil.info(`${TAG} highContrastText set success`);
    }).catch((error: BusinessError) => {
      LogUtil.error(`${TAG} highContrastText set err: ${error?.message} ${error?.code}`);
    });
  }
}
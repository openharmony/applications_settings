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

import Settings from '@ohos.settings';
import { LogUtil } from '../utils/LogUtil';
import { SettingsDataUtils } from '../utils/SettingsDataUtils';
import { PreferencesUtil } from '../utils/PreferencesUtil';
import { DisplayArrayIndex } from './types';

const SETTINGS_DISPLAY_DATA_KEY: string = 'settings.display.allData';
const DISPLAY_EYESHIELD: string = 'settings.eyeshield.enable';
const DISPLAY_DPI: string = 'system_default_dpi_value';
const EXTEND_DPI: string = 'extend_dpi_value';
const DISPLAY_SLEEP_TIME: string = Settings.display.SCREEN_OFF_TIMEOUT;
const DISPLAY_RESOLUTION_STYLE: string = 'settings.display.resolution_style';
const DISPLAY_RESOLUTION_MODE: string = 'settings.display.resolution_mode';
const SETTINGS_CLONED: string = 'settingsCloned';
const THIRTY_SECONDS: string = '30000';
const SMART_RESOLUTION_TYPE: string = '0';
const SCREEN_RESOLUTION_HIGH: string = '3';
const TAG = 'DisplayDataManager : ';

/**
 * 设置显示与亮度数据库工具类，用于优化加载显示和亮度数据时耗时过长问题
 *
 * @author openharmony
 * @since 2023-12-29
 */
export class DisplayDataManager {
  /**
   * 设置数据库-默认DPI数值
   */
  public defaultDpiValue: string = '';
  /**
   * 设置数据库-外屏默认DPI数值
   */
  public extendDpiValue: string = '';
  /**
   * 设置数据库-休眠时间数值
   */
  public sleepTime: string = '';
  /**
   * 设置数据库-屏幕分辨率
   */
  public resolutionStyle: string = '';
  /**
   * 设置数据库-屏幕刷新率
   */
  public resolutionMode: string = '';
  /**
   * 设置数据库-设置搬迁标志
   */
  public flagClone: boolean = false;

  /**
   * 从preference中获取显示与亮度所有数据
   */
  public async getDisplayAllSettingsData(): Promise<void> {
    LogUtil.info(`${TAG} getDisplayAllSettingsData`);
    let keyExist: boolean = await PreferencesUtil.has(SETTINGS_DISPLAY_DATA_KEY);
    LogUtil.info(`${TAG} keyExist: ${keyExist}`);
    if (!keyExist) {
      this.getDisplaySettingData();
      SettingsDataUtils.setSettingsData(SETTINGS_CLONED, '0');
      return;
    }
    this.flagClone = SettingsDataUtils.getSettingsData(SETTINGS_CLONED, '1') === '1';
    LogUtil.info(`${TAG} flagClone: ${this.flagClone}`);
    if (this.flagClone) {
      this.getDisplaySettingData();
      SettingsDataUtils.setSettingsData(SETTINGS_CLONED, '0');
      return;
    }
    let allData: string = String(await PreferencesUtil.get(SETTINGS_DISPLAY_DATA_KEY, ''));
    LogUtil.info(`${TAG} allData: ${allData}`);
    let dataArray: string[] = [];
    dataArray = allData.split('_');
    if (dataArray.length < DisplayArrayIndex.INDEX_6) {
      this.getDisplaySettingData();
      return;
    }
    this.defaultDpiValue = dataArray[DisplayArrayIndex.INDEX_1];
    this.sleepTime = dataArray[DisplayArrayIndex.INDEX_2];
    this.resolutionStyle = dataArray[DisplayArrayIndex.INDEX_3];
    this.resolutionMode = dataArray[DisplayArrayIndex.INDEX_4];
    this.extendDpiValue = dataArray[DisplayArrayIndex.INDEX_5];
  }


  public getDefaultDPI(): string {
    if (this.defaultDpiValue === '') {
      this.defaultDpiValue = SettingsDataUtils.getSettingsData(DISPLAY_DPI, '');
    }
    return this.defaultDpiValue;
  }

  public updateDefaultDPI(): void {
    this.defaultDpiValue = SettingsDataUtils.getSettingsData(DISPLAY_DPI, '');
    PreferencesUtil.put(SETTINGS_DISPLAY_DATA_KEY, this.handleSettingData());
    return;
  }

  public getExtendDPI(): string {
    if (this.extendDpiValue === '') {
      this.extendDpiValue = SettingsDataUtils.getSettingsData(EXTEND_DPI, '');
    }
    return this.extendDpiValue;
  }

  public updateExtendDPI(): void {
    this.extendDpiValue = SettingsDataUtils.getSettingsData(EXTEND_DPI, '');
    PreferencesUtil.put(SETTINGS_DISPLAY_DATA_KEY, this.handleSettingData());
    return;
  }

  public getSleepTime(): string {
    if (this.sleepTime === '') {
      this.getDisplaySettingData();
    }
    return this.sleepTime;
  }

  public updateSleepTime(): void {
    this.sleepTime = SettingsDataUtils.getSettingsData(DISPLAY_SLEEP_TIME, THIRTY_SECONDS);
    PreferencesUtil.put(SETTINGS_DISPLAY_DATA_KEY, this.handleSettingData());
    return;
  }

  public getSettingsDataResolutionStyle(): string {
    this.updateResolutionStyle();
    return this.resolutionStyle;
  }

  public getResolutionStyle(): string {
    if (this.resolutionStyle === '') {
      this.getDisplaySettingData();
    }
    return this.resolutionStyle;
  }

  public updateResolutionStyle(): void {
    this.resolutionStyle = SettingsDataUtils.getSettingsData(DISPLAY_RESOLUTION_STYLE, SMART_RESOLUTION_TYPE);
    PreferencesUtil.put(SETTINGS_DISPLAY_DATA_KEY, this.handleSettingData());
    return;
  }

  public getResolutionMode(): string {
    if (this.resolutionMode === '') {
      this.getDisplaySettingData();
    }
    return this.resolutionMode;
  }

  public updateResolutionMode(): void {
    this.resolutionMode = SettingsDataUtils.getSettingsData(DISPLAY_RESOLUTION_MODE, SCREEN_RESOLUTION_HIGH);
    PreferencesUtil.put(SETTINGS_DISPLAY_DATA_KEY, this.handleSettingData());
    return;
  }

  public getDisplaySettingData(): void {
    this.defaultDpiValue = SettingsDataUtils.getSettingsData(DISPLAY_DPI, '');
    this.sleepTime = SettingsDataUtils.getSettingsData(DISPLAY_SLEEP_TIME, THIRTY_SECONDS);
    this.resolutionStyle = SettingsDataUtils.getSettingsData(DISPLAY_RESOLUTION_STYLE, SMART_RESOLUTION_TYPE);
    this.resolutionMode = SettingsDataUtils.getSettingsData(DISPLAY_RESOLUTION_MODE, SCREEN_RESOLUTION_HIGH);
    this.extendDpiValue = SettingsDataUtils.getSettingsData(EXTEND_DPI, '');
    PreferencesUtil.put(SETTINGS_DISPLAY_DATA_KEY, this.handleSettingData());
    return;
  }

  private handleSettingData(): string {
    let dataArray: string[] = [];
    dataArray.push(this.defaultDpiValue);
    dataArray.push(this.sleepTime);
    dataArray.push(this.resolutionStyle);
    dataArray.push(this.resolutionMode);
    dataArray.push(this.extendDpiValue);
    LogUtil.info(`${TAG} handleSettingData: ${dataArray.join('_')}`);
    return dataArray.join('_');
  }
}

export let displayDataManager = new DisplayDataManager();

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
import { LogUtil } from '@ohos/settings.common/src/main/ets/utils/LogUtil';
import { ResourceUtil } from '@ohos/settings.common/src/main/ets/utils/ResourceUtil';
import { SettingsDataUtils } from '@ohos/settings.common/src/main/ets/utils/SettingsDataUtils';
import { DATA_LIMIT_KEY, GB_STR, HotSpotUtils, MAX_MB_NUM, MB_STR } from './utils/HotspotUtils';

const TAG: string = 'HotspotLimitDataManager';
const INPUT_MAX_LENGTH: number = 6;
export const LAST_INPUT_UNIT_KEY: string = 'wifiap_limit_last_input_unit';
export const USER_DATA_DEFAULT_LIMIT: number = 0;
export const USER_DATA_NO_LIMIT: number = -1;
export const USER_DATA_LIMIT_100: number = 100;
export const USER_DATA_LIMIT_500: number = 500;
export const USER_DATA_LIMIT_1024: number = 1024;
export const limitList: number[] = [USER_DATA_LIMIT_100, USER_DATA_LIMIT_500, USER_DATA_LIMIT_1024];

export class HotspotLimitDataManager {
  private static instance: HotspotLimitDataManager;
  public curLimit: number = USER_DATA_DEFAULT_LIMIT;
  public curUnit: string = MB_STR;

  /**
   * 获取数据管理类实例
   */
  public static getInstance(): HotspotLimitDataManager {
    if (!HotspotLimitDataManager.instance) {
      HotspotLimitDataManager.instance = new HotspotLimitDataManager();
    }
    return HotspotLimitDataManager.instance;
  }

  /**
   * 更新数据库
   */
  public updateSettingData(): void {
    let limit: number = this.curUnit === GB_STR ? this.curLimit * MAX_MB_NUM : this.curLimit
    LogUtil.info(`${TAG} updateSettingData usage limit: ${limit} MB`);
    SettingsDataUtils.setSecureValue(DATA_LIMIT_KEY, limit.toString())
  }

  /**
   * 更新本地内存数据
   */
  public updateCurrentLimit(value: number, unit: string): void {
    if (!this.checkInputValue(value)) {
      LogUtil.warn(`${TAG} updateCurrentLimit input invalid`);
      return;
    }
    this.curLimit = value;
    this.curUnit = unit;
  }

  /**
   * 更新数字部分
   */
  public updateLimitNumber(value: number): void {
    if (!this.checkInputValue(value)) {
      LogUtil.warn(`${TAG} updateLimitNumber input invalid`);
      return;
    }
    LogUtil.info(`${TAG} updateLimitNumber ${value}`);
    this.curLimit = value;
  }

  /**
   * 更新单位部分
   */
  public updateLimitUnit(unit: string): void {
    if (unit !== MB_STR && unit !== GB_STR) {
      LogUtil.warn(`${TAG} updateLimitUnit input invalid: ${unit}`);
      return;
    }
    LogUtil.info(`${TAG} updateLimitUnit ${unit}`);
    this.curUnit = unit;
  }

  /**
   * 数据初始化
   */
  public initData(): void {
    let settingDataValue: number =
      parseInt(SettingsDataUtils.getSecureValue(DATA_LIMIT_KEY, USER_DATA_NO_LIMIT.toString()));
    if (!this.checkInputValue(settingDataValue)) {
      LogUtil.warn(`${TAG} initData settingDataValue invalid`);
      this.updateCurrentLimit(USER_DATA_DEFAULT_LIMIT, MB_STR);
      return;
    }
    let unit: string = MB_STR;
    let lastInputUnit: string = SettingsDataUtils.getSecureValue(LAST_INPUT_UNIT_KEY, MB_STR);
    if (this.needConvertMb2Gb(settingDataValue, lastInputUnit)) {
      settingDataValue = HotSpotUtils.convertMb2GbNumber(settingDataValue);
      unit = GB_STR;
    }
    LogUtil.info(`${TAG} init current limit: ${settingDataValue} ${unit}`);
    this.updateCurrentLimit(settingDataValue, unit);
  }

  /**
   * 获取当前内存中保存的限额对应字符串
   */
  public getCurLimitString(): string {
    if (this.curLimit === USER_DATA_NO_LIMIT) {
      return ResourceUtil.getStringSync($r('app.string.no_limit'));
    }
    LogUtil.info(`${TAG} getCurLimitString: ${this.curLimit} ${this.curUnit}`);
    return this.curLimit + ' ' + this.curUnit;
  }

  /**
   * 获取当前保存的MB值
   */
  public getCurLimitNumberMb(): number {
    if (this.curUnit === GB_STR) {
      return this.curLimit * MAX_MB_NUM;
    }
    return this.curLimit;
  }

  /**
   * 判断当前是否为自定义的值
   */
  public isCustomized(): boolean {
    if (this.curLimit === USER_DATA_NO_LIMIT) {
      return false;
    }
    if (this.curLimit === USER_DATA_LIMIT_1024 && this.curUnit === MB_STR) {
      // 用户输入1024MB，归为自定义
      return true;
    }
    let limitNum: number = this.curLimit;
    if (this.curUnit === GB_STR) {
      limitNum *= MAX_MB_NUM;
    }
    LogUtil.info(`${TAG} isCustomized: ${!limitList.includes(limitNum)}`)
    return !limitList.includes(limitNum);
  }

  private checkInputValue(value: number): boolean {
    if (Number.isNaN(value) || value < USER_DATA_NO_LIMIT) {
      return false;
    }
    return true;
  }

  private needConvertMb2Gb(value: number, lastInputUnit: string): boolean {
    if (value >= MAX_MB_NUM && value % MAX_MB_NUM === 0 && lastInputUnit === GB_STR) {
      return true;
    }
    return false;
  }
}
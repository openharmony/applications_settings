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

import { intl } from '@kit.LocalizationKit';
import { LanguageUtils } from '@ohos/settings.common/src/main/ets/utils/LanguageUtils';
import { LogUtil } from '@ohos/settings.common/src/main/ets/utils/LogUtil';

const units: string[] = ['B', 'KB', 'MB', 'GB', 'TB'];
const unitsTran: string[] = ['byte', 'kilobyte', 'megabyte', 'gigabyte', 'terabyte'];
const TAG: string = 'StorageSizeUtil : ';

interface FormatSizeModel {
  size: number,
  unitIndex: number
}

/**
 * 存储空间工具类
 *
 * @since 2023-08-11
 */
export class StorageSizeUtil {

  /**
   * format data
   */
  static formatData(val: number, count: number): string {
    let result = '';
    let unitIndex: number = 0;
    let numbers = Math.pow(10, count);
    LogUtil.info(`${TAG} val is: ${val}`);
    if (val < 1000) {
      result = `${Number(val).valueOf()}`;
      unitIndex = 0;
    } else if (val < 1000 * 1000) {
      result = `${((Math.floor(Number(val / 1000 * numbers)) / numbers).valueOf())}`;
      unitIndex = 1;
    } else if (val < 1000 * 1000 * 1000) {
      result = `${((Math.floor(Number(val / (1000 * 1000) * numbers)) / numbers).valueOf())}`;
      unitIndex = 2;
    } else if (val < 1024 * 1000 * 1000 * 1000) {
      result = `${((Math.floor(Number(val / (1000 * 1000 * 1000) * numbers)) / numbers).valueOf())}`;
      unitIndex = 3;
    } else if (val < 1000 * 1000 * 1000 * 1000 * 1000) {
      result = `${((Math.floor(Number(val / (1024 * 1000 * 1000 * 1000) * numbers)) / numbers).valueOf())}`;
      unitIndex = 4;
    } else {
      result = `${((Math.floor(Number(val / (1024 * 1000 * 1000 * 1000) * numbers)) / numbers).valueOf())}`;
      unitIndex = 4;
    }
    if (LanguageUtils.isLtrDirection()) {
      result = result + ' ';
      LogUtil.info(`${TAG} result is ${result}`);
    }
    LogUtil.info(`${TAG} go to here`);
    result = result + units[unitIndex];
    LogUtil.info(`${TAG} final result: ${result} units: ${units[unitIndex]}`);
    return result;
  }

  // 处理存储应用数据 APP size信息，大于100整数（四舍五入），小于100带两位小数
  static formatDataRound(val: number, count: number): string {
    let result: string = '';
    let unitIndex: number = 0;
    let numbers: number = Math.pow(10, count);
    if (numbers === 0) {
      return result;
    }
    LogUtil.info(`${TAG} val is: ${val}`);
    if (val < 1000) {
      result = `${StorageSizeUtil.handleData(Number(val))}`;
      unitIndex = 0;
    } else if (val < 1000 * 1000) {
      result = `${StorageSizeUtil.handleData((Number(val / 1000 * numbers)) / numbers)}`;
      unitIndex = 1;
    } else if (val < 1000 * 1000 * 1000) {
      result = `${StorageSizeUtil.handleData((Number(val / (1000 * 1000) * numbers)) / numbers)}`;
      unitIndex = 2;
    } else if (val < 1024 * 1000 * 1000 * 1000) {
      result = `${StorageSizeUtil.handleData((Number(val / (1000 * 1000 * 1000) * numbers)) / numbers)}`;
      unitIndex = 3;
    } else if (val < 1000 * 1000 * 1000 * 1000 * 1000) {
      result = `${StorageSizeUtil.handleData((Number(val / (1024 * 1000 * 1000 * 1000) * numbers)) / numbers)}`;
      unitIndex = 4;
    } else {
      result = `${StorageSizeUtil.handleData((Number(val / (1024 * 1000 * 1000 * 1000) * numbers)) / numbers)}`;
      unitIndex = 4;
    }

    if (LanguageUtils.isLtrDirection()) {
      result = result + ' ';
    }
    result = result + units[unitIndex];

    return result;
  }

  // 数据处理，大于100整数（四舍五入），小于100带两位小数
  static handleData(data: number): number {
    if (data > 100) {
      return Math.round(data);
    } else {
      return (Math.round(data * 100) / 100);
    }
  }

  /**
   * 根据当前语言 对存储数据单位格式化，大于100整数（四舍五入），小于100带两位小数
   *
   * @param val 待格式化的大小
   * @param count 精度，保留的位数
   * @param isRound 是否对结果做近似处理
   *
   * @returns 格式化后的结果
   */
  static formatDataIntl(val: number, count: number, isRound: boolean = false): string {
    let numbers: number = Math.pow(10, count);
    let formatNumByte: string = '';
    if (numbers === 0) {
      return formatNumByte;
    }
    const formatSize = StorageSizeUtil.getFormatSize(val, numbers, isRound);
    const uintFormat: intl.NumberFormat = new intl.NumberFormat(LanguageUtils.getLanguage(),
      { style: 'unit', unit: unitsTran[formatSize.unitIndex], unitDisplay: 'short' });
    try {
      formatNumByte = uintFormat.format(formatSize.size);
    } catch (err) {
      LogUtil.error(`${TAG} formatDataIntl failed, code: ${err?.code}, msg: ${err?.message}`);
    }
    LogUtil.info(`${TAG} formatDataIntl val: ${val}, res: ${formatNumByte}`);
    return formatNumByte;
  }

  private static getFormatSize(val: number, numbers: number, isRound: boolean): FormatSizeModel {
    let index: number;
    let result: number;
    if (val < 1000) {
      result = Number(val * numbers);
      index = 0;
    } else if (val < 1000 * 1000) {
      result = Number(val / 1000 * numbers);
      index = 1;
    } else if (val < 1000 * 1000 * 1000) {
      result = Number(val / (1000 * 1000) * numbers);
      index = 2;
    } else if (val < 1024 * 1000 * 1000 * 1000) {
      result = Number(val / (1000 * 1000 * 1000) * numbers);
      index = 3;
    } else if (val < 1000 * 1000 * 1000 * 1000 * 1000) {
      result = Number(val / (1024 * 1000 * 1000 * 1000) * numbers);
      index = 4;
    } else {
      result = Number(val / (1024 * 1000 * 1000 * 1000) * numbers);
      index = 4;
    }
    let size =
      isRound ? StorageSizeUtil.handleData(result / numbers) : (Math.floor(result) / numbers).valueOf();
    return { size: size, unitIndex: index } as FormatSizeModel;
  }
}
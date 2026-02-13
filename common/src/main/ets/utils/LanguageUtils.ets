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

import I18n from '@ohos.i18n';
import { LogUtil } from './LogUtil';
import { StringUtil } from './StringUtil';

const TAG = 'LanguageUtils : '

export class LanguageUtils {
  static getLanguage(): string {
    try {
      return I18n.System.getSystemLanguage();
    } catch (error) {
      LogUtil.error(`${TAG} catch exception when getLanguage, errmsg: ${error?.message}`);
      return '';
    }
  }

  static getRegion(): string {
    try {
      return I18n.System.getSystemRegion();
    } catch (error) {
      LogUtil.error(`${TAG} catch exception when getRegion, errmsg: ${error?.message}`);
      return '';
    }
  }

  static isChinaArea(): boolean {
    let language: string = LanguageUtils.getLanguage();
    let region: string = LanguageUtils.getRegion();
    return language === 'zh-Hans' && region === 'CN';
  }

  static getSystemLanguage(): string {
    let language: string = '';
    let systemLanguageArr: string[] = ['zh-Hans', 'en-Latn-US', 'bo', 'ug', 'zh-HK', 'zh-TW'];
    try {
      language = I18n.I18NUtil.getBestMatchLocale(I18n.System.getSystemLocale(), systemLanguageArr);
      LogUtil.info(`${TAG} getBestMatchLocale: ${language}`);
    } catch (err) {
      LogUtil.error(`${TAG} getBestMatchLocale failed, msg: ${err?.message}, code: ${err?.code}`);
    }
    return StringUtil.isEmpty(language) ? 'en-Latn-US' : language;
  }

  /**
   * 是否是从左到右读的语言
   * @returns true：是； false：不是
   */
  static isLtrDirection(): boolean {
    try {
      LogUtil.info(`${TAG} isLtrDirection`);
      return !I18n.isRTL(I18n.System.getSystemLocale());
    } catch (err) {
      LogUtil.error(`${TAG} isLtrDirection error: ${err?.message} code: ${err?.code}`);
      return false;
    }
  }

  /**
   * 数字国际化接口NumberFormat获取数字，格式化数字
   *
   * @param num 需要格式化的数值
   * @returns string 国际化数字
   */
  static getNumberFormat(num: number): string {
    let formatNum: string = '';
    const currentLanguage: string = LanguageUtils.getLanguage();
    try {
      const numberUnitFormat: Intl.NumberFormat = new Intl.NumberFormat(currentLanguage);
      formatNum = numberUnitFormat.format(num);
    } catch (err) {
      LogUtil.error(`${TAG} getNumberFormat: get number error: ${err?.message} code: ${err?.code}`);
    }
    return formatNum;
  }

  /**
   * 数字国际化接口NumberFormat获取数字,格式化百分比
   *
   * @param num 需要格式化的数值
   * @returns string 国际化数字
   */
  static getPercentFormat(num: number): string {
    let percentFormatNum: string = '';
    const currentLanguage: string = LanguageUtils.getLanguage();
    try {
      const percentFormat: Intl.NumberFormat = new Intl.NumberFormat(currentLanguage, { style: 'percent' });
      percentFormatNum = percentFormat.format(num / 100);
    } catch (err) {
      LogUtil.error(`${TAG} getPercentFormat: get number error: ${err?.message} code: ${err?.code}`);
    }
    return percentFormatNum;
  }
}
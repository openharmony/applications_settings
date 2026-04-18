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

import i18n from '@ohos.i18n';
import { LogUtil } from '@ohos/settings.common/src/main/ets/utils/LogUtil';
import { CountryAndRegion } from './CountryAndRegion';

/**
 * Language And Region Model
 */
class LanguageAndRegionModel {
  private addedLanguages: Array<string> = [];
  private addStr:string = 'addedLanguages';
  private regionStr:string = 'currentRegion';
  private TAG:string = 'Setting LanguageAndRegionModel: ';
  // 添加语言时是否选择了切换当前语言
  private addLanguageChange: boolean = false;

  constructor() {
    LogUtil.info(`${this.TAG} init in`);
    this.initAppStorage();
    LogUtil.info(`${this.TAG} init sucess`);
  }

  /**
   * 记录添加语言后是否切换当前语言的状态
   *
   * @param languageChange 是否切换语言
   */
  setAddLanguageChange(languageChange: boolean) {
    this.addLanguageChange = languageChange;
  }

  /**
   * 返回添加语言后是否有切换语言的状态
   *
   * @returns 添加语言后切换了语言返回true
   */
  isAddLanguageChange() {
    return this.addLanguageChange;
  }

  /**
   * Get added languages
   */
  getAddedLanguages(): Array<string> {
    LogUtil.info(`${this.TAG} getAddedLanguages`);
    return i18n.System.getPreferredLanguageList();
  }

  /**
   * Get all languages
   */
  getAllLanguages(): Array<string> {
    LogUtil.info(`${this.TAG} getAllLanguages`);
    try {
      return i18n.System.getSystemLanguages();
    } catch (err) {
      LogUtil.error(`${this.TAG} getAllLanguages error code: ${err?.code}, message: ${err?.message}`);
      return [''];
    }
  }

  /**
   * Get current languages
   */
  getSystemLanguage(): string {
    LogUtil.info(`${this.TAG} getSystemLanguage`);
    try {
      return i18n.System.getSystemLanguage();
    } catch (err) {
      LogUtil.error(`${this.TAG} getSystemLanguage err code: ${err?.code}, message: ${err?.message}`);
      return '';
    }
  }

  /**
   * Init App Storage
   */
  initAppStorage(): void {
    LogUtil.info(`${this.TAG} initAppStorage in`);
    if (!AppStorage.has(this.addStr)) {
      const addedLanguages = this.getAddedLanguages();
      LogUtil.info(`${this.TAG} initAppStorage addedLanguage`);
      AppStorage.setOrCreate(this.addStr, addedLanguages);
      LogUtil.info(`${this.TAG} initAppStorage addedLanguage sucess`);
    }
    if (!AppStorage.has(this.regionStr)) {
      LogUtil.info(`${this.TAG} initAppStorage currentRegion`);
      AppStorage.setOrCreate(this.regionStr, this.getSysDisplayRegion());
      LogUtil.info(`${this.TAG} initAppStorage currentRegion sucess`);
    }
    LogUtil.info(`${this.TAG} initAppStorage out`);
    return;
  }

  /**
   * Set system language
   */

  setSystemLanguage(language: string): void {
    LogUtil.info(`${this.TAG} setSystemLanguage in`);
    this.addedLanguages = this.getAddedLanguages();
    // 如果切换的语言不存在，则需要添加该语言
    if (this.addedLanguages.indexOf(language) === -1) {
      this.addLanguage(language);
    }
    this.addedLanguages.splice(this.addedLanguages.indexOf(language), 1);
    this.addedLanguages.unshift(language);
    let currentLanguage: string = this.getSystemLanguage();
    if (currentLanguage === language) {
      LogUtil.info(`${this.TAG} set same language`);
      return;
    }
    try {
      i18n.System.setSystemLanguage(language);
      AppStorage.setOrCreate(this.regionStr, this.getSysDisplayRegion());
      AppStorage.setOrCreate(this.addStr, this.addedLanguages);
      LogUtil.info(`${this.TAG} setSystemLanguage sucess`);
    } catch (err) {
      LogUtil.error(`${this.TAG} setSystemLanguage err ${err?.code}, message: ${err?.message}`);
    }
  }

  setSystemLanguageEffects(language: string): void {
    LogUtil.info(`${this.TAG} setSystemLanguageEffects in`);
    this.addedLanguages = this.getAddedLanguages();
    this.addedLanguages.splice(this.addedLanguages.indexOf(language), 1);
    this.addedLanguages.unshift(language);
    AppStorage.set(this.regionStr, this.getSysDisplayRegion());
    LogUtil.info(`${this.TAG} setSystemLanguageEffects sucess`);
    return;
  }
  /**
   * Add language to the addedLanguages list
   */
  addLanguage(language: string): void {
    LogUtil.info(`${this.TAG} addLanguage in, language: ${language}`);
    this.addedLanguages = languageAndRegionModel.getAddedLanguages();
    this.addedLanguages.push(language);
    try {
      i18n.System.addPreferredLanguage(language, this.addedLanguages.indexOf(language));
      LogUtil.info(`${this.TAG} addLanguage sucess`);
    } catch (err) {
      LogUtil.error(`${this.TAG} addPreferredLanguage errorMsg: ${err?.message} errorCode: ${err?.code}`);
    }
  }

  /**
   * Remove language from the addedLanguages list
   */
  deleteLanguage(language: string): void {
    LogUtil.info(`${this.TAG} deleteLanguage in`);
    this.addedLanguages = AppStorage.get(this.addStr) as Array<string>;
    this.addedLanguages.splice(this.addedLanguages.indexOf(language), 1);
    this.setSystemLanguage(this.addedLanguages[0]);
    AppStorage.set(this.addStr, this.addedLanguages);
    LogUtil.info(`${this.TAG} deleteLanguage sucess`);
    return;
  }

  /**
   * Set current added languages.
   *
   * @param addedLanguages Language list
   */
  setAddedLanguages(addedLanguages: Array<string>): void {
    if (!addedLanguages || addedLanguages.length < 1) {
      return;
    }
    LogUtil.info(`${this.TAG} setAddedLanguages in`);
    this.addedLanguages = addedLanguages;
    this.setSystemLanguage(this.addedLanguages[0]);
    AppStorage.set(this.addStr, addedLanguages);
    LogUtil.info(`${this.TAG} setAddedLanguages sucess`);
  }

  /**
   * Display in the system language
   */
  getSysDisplayLanguage(language: string) {
    LogUtil.info(`${this.TAG} getSysDisplayLanguage`);
    try {
      return i18n.System.getDisplayLanguage(language, i18n.System.getSystemLanguage(), true);
    } catch (err) {
      LogUtil.error(`${this.TAG} setSystemRegion error code: ${err?.code}, message: ${err?.message}`);
      return '';
    }
  }

  /**
   * Display the language
   */
  getDisplayLanguage(language: string): string {
    LogUtil.info(`${this.TAG} getDisplayLanguage`);
    try {
      return i18n.System.getDisplayLanguage(language, language, true);
    } catch (err) {
      LogUtil.error(`${this.TAG} getDisplayLanguage error code: ${err?.code}, message: ${err?.message}`);
      return '';
    }
  }

  /**
   * Display the region
   */
  getDisplayRegion(country: string): string {
    try {
      return i18n.System.getDisplayCountry(country, i18n.System.getSystemLanguage(), true);
    } catch (err) {
      LogUtil.error(`${this.TAG} getDisplayCountry error code: ${err?.code}, message: ${err?.message}`);
      return '';
    }
  }

  /**
   * Display the system region
   */
  getSysDisplayRegion(region?: string): string {
    LogUtil.info(`${this.TAG} getSysDisplayRegion`);
    try {
      if (region) {
        LogUtil.info(`${this.TAG}  SysDisplayRegion select is: ${region}`);
        return i18n.System.getDisplayCountry(region, i18n.System.getSystemLanguage(), true);
      } else {
        let currentRegion = i18n.System.getSystemRegion();
        LogUtil.info(`${this.TAG}  SysDisplayRegion currentRegion is: ${currentRegion}`);
        return i18n.System.getDisplayCountry(currentRegion, i18n.System.getSystemLanguage(), true);
      }
    } catch (err) {
      LogUtil.error(`${this.TAG} getSysDisplayRegion error code: ${err?.code}, message: ${err?.message}`);
      return '';
    }
  }

  /**
   * get system countries
   */
  getSystemCountries(): Array<string> {
    LogUtil.info(`${this.TAG} getSystemCountries`);
    try {
      return i18n.System.getSystemCountries(i18n.System.getSystemLanguage());
    } catch (err) {
      LogUtil.error(`${this.TAG} getSystemCountries err ${err?.code}, message: ${err?.message}`);
      return [''];
    }
  }

  /**
   * get system regions
   */
  getSystemRegions(): Array<CountryAndRegion> {
    LogUtil.info(`${this.TAG} getSystemRegions`);
    try {
      let language = i18n.System.getSystemLanguage();
      return i18n.System.getSystemCountries(language).map((country =>
      new CountryAndRegion(country, this.getDisplayRegion(country)))).sort((a, b) => {
        return a.getRegion().localeCompare(b.getRegion(), language);
      });
    } catch (err) {
      LogUtil.error(`${this.TAG} getSystemRegions error code: ${err?.code}, message: ${err?.message}`);
      return [];
    }
  }

  getSystemRegion(): string {
    LogUtil.info(`${this.TAG} getSystemRegion`);
    try {
      return i18n.System.getSystemRegion();
    } catch (err) {
      LogUtil.error(`${this.TAG} getSystemRegion error code: ${err?.code}, message: ${err?.message}`);
      return '';
    }
  }

  /**
   * set system region
   */
  setSystemRegion(region: string): void {
    LogUtil.info(`${this.TAG} setSystemRegion`);
    try {
      i18n.System.setSystemRegion(region);
      AppStorage.set(this.regionStr, this.getSysDisplayRegion(region));
    } catch (err) {
      LogUtil.error(`${this.TAG} setSystemRegion error code: ${err?.code}, message: ${err?.message}`);
    }
  }

  /**
   * Determine if it is the system language
   */
  isSystemLanguage(language: string): boolean {
    try {
      return language === i18n.System.getSystemLanguage();
    } catch (err) {
      LogUtil.error(`${this.TAG} isSystemLanguage error code: ${err?.code}, message: ${err?.message}`);
      return false;
    }
  }

  /**
   * Determine if it is in the addedLanguages
   */
  isInAddedLanguage(language: string): boolean {
    this.addedLanguages = languageAndRegionModel.getAddedLanguages();
    if (this.addedLanguages.indexOf(language) === -1) {
      return false;
    } else {
      return true;
    }
  }

  /**
   * Determine if it is the system region
   */
  isSystemRegion(region: string): boolean {
    try {
      return region === i18n.System.getSystemRegion();
    } catch (err) {
      LogUtil.error(`${this.TAG} isSystemRegion error code: ${err?.code}, message: ${err?.message}`);
      return false;
    }
  }
}

export let languageAndRegionModel = new LanguageAndRegionModel();
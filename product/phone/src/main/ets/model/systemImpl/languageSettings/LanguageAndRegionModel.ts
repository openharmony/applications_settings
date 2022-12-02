/**
 * Copyright (c) 2021 Huawei Device Co., Ltd.
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
//import data_storage from '@ohos.data.storage';
import dataStorage from '@ohos.data.preferences';
import LogUtil from '../../../../../../../../common/utils/src/main/ets/default/baseUtil/LogUtil';
import BaseModel from '../../../../../../../../common/utils/src/main/ets/default/model/BaseModel';
import ConfigData from '../../../../../../../../common/utils/src/main/ets/default/baseUtil/ConfigData';
import Log from '../../../../../../../../common/utils/src/main/ets/default/baseUtil/LogDecorator';

/**
 * Language And Region Model
 */
class LanguageAndRegionModel extends BaseModel {
  private addedLanguages: Array<string> = [];
  private allLanguages: Array<string> = [];
  private addStr  = ConfigData.ADDLANGUAGES;
  private regionStr = ConfigData.CURRENTREGION;
  private storage;
  private TAG = `${ConfigData.TAG} LanguageAndRegionModel`;

  constructor(){
    super();
    LogUtil.info(`${this.TAG} init in`);
    this.initAppStorage();
    LogUtil.info(`${this.TAG} init sucess`);
  }

  /**
     * Get added languages
     */
  @Log
  getAddedLanguages():Array<string>{
    if (!AppStorage.Has(this.addStr)) {
      AppStorage.SetOrCreate(this.addStr, [i18n.System.getSystemLanguage()]);
    }
    LogUtil.info(`${this.TAG} getAddedLanguages`);
    console.info("gshhshs" + AppStorage.Get(this.addStr))
    return AppStorage.Get(this.addStr);
  }

  /**
     * Get all languages
     */
  @Log
  getAllLanguages():Array<string>{
    LogUtil.info(`${this.TAG} getAllLanguages`);
    return i18n.System.getSystemLanguages();
  }

  /**
     * Init App Storage
     */
  @Log
  async initAppStorage():Promise<void>{
    this.storage = await dataStorage.getPreferences(globalThis.settingsAbilityContext, 'languageAndRegion')
    LogUtil.info(`${this.TAG} initAppStorage in` + JSON.stringify(this.storage));
    if(!(await this.storage.has(this.addStr))){
      LogUtil.info(`${this.TAG} initStorage addStr` + !await this.storage.has(this.addStr));
      await this.storage.put(this.addStr, JSON.stringify([i18n.System.getSystemLanguage()]))
      await this.storage.flush();
      LogUtil.info(`${this.TAG} initStorage addStr sucess` + JSON.stringify(this.addStr));
    }
    if((await this.storage.has(this.addStr))){
      AppStorage.SetOrCreate(this.addStr, JSON.parse(<string>await this.storage.get(this.addStr, 'fail')));
    }
    if(!AppStorage.Has(this.regionStr)){
      LogUtil.info(`${this.TAG} initAppStorage currentRegion` + !AppStorage.Has(this.regionStr));
      AppStorage.SetOrCreate(this.regionStr, this.getSysDisplayRegion());
      LogUtil.info(`${this.TAG} initAppStorage currentRegion sucess`);
    }
    LogUtil.info(`${this.TAG} initAppStorage out` + this.addStr);
    return;
  }

  /**
     * Set system language
     */
  @Log
  async setSystemLanguage(language:string):Promise<void>{
    LogUtil.info(`${this.TAG} setSystemLanguage in`);
    this.addedLanguages = this.getAddedLanguages();
    this.addedLanguages.splice(this.addedLanguages.indexOf(language), 1);
    this.addedLanguages.unshift(language);
    i18n.System.setSystemLanguage(language);
    AppStorage.Set(this.regionStr, this.getSysDisplayRegion());
    AppStorage.Set(this.addStr, this.addedLanguages);
    await this.storage.put(this.addStr, JSON.stringify(AppStorage.Get(this.addStr)));
    await this.storage.flush();
    LogUtil.info(`${this.TAG} setSystemLanguage sucess`);
    return;
  }

  /**
     * Add language to the addedLanguages list
     */
  @Log
  async addLanguage(language:string):Promise<void>{
    LogUtil.info(`${this.TAG} addLanguage in, language: ${language}` );
    this.addedLanguages = AppStorage.Get(this.addStr);
    this.addedLanguages.push(language);
    AppStorage.Set(this.addStr, this.addedLanguages);
    await this.storage.put(this.addStr, JSON.stringify(AppStorage.Get(this.addStr)));
    await this.storage.flush();
    LogUtil.info(`${this.TAG} addLanguage sucess`);
    return;
  }

  /**
     * Remove language from the addedLanguages list
     */
  @Log
  async deleteLanguage(language:string):Promise<void>{
    LogUtil.info(`${this.TAG} deleteLanguage in`);
    this.addedLanguages = AppStorage.Get(this.addStr);
    this.addedLanguages.splice(this.addedLanguages.indexOf(language), 1);
    this.setSystemLanguage(this.addedLanguages[0]);
    AppStorage.Set(this.addStr, this.addedLanguages);
    await this.storage.put(this.addStr, JSON.stringify(AppStorage.Get(this.addStr)));
    await this.storage.flush();
    LogUtil.info(`${this.TAG} deleteLanguage sucess`);
    return;
  }

  /**
     * Display in the system language
     */
  @Log
  getSysDisplayLanguage(language:string){
    LogUtil.info(`${this.TAG} getSysDisplayLanguage`);
    return i18n.System.getDisplayLanguage(language, i18n.System.getSystemLanguage(), true);
  }

  /**
     * Display the language
     */
  @Log
  getDisplayLanguage(language:string):string{
    LogUtil.info(`${this.TAG} getDisplayLanguage`);
    return i18n.System.getDisplayLanguage(language, language, true);
  }

  /**
     * Display the region
     */
  @Log
  getDisplayRegion(country:string):string{
    LogUtil.info(`${this.TAG} getDisplayRegion`);
    return i18n.System.getDisplayCountry(country, i18n.System.getSystemLanguage(),true);
  }

  /**
     * Display the system region
     */
  @Log
  getSysDisplayRegion():string{
    LogUtil.info(`${this.TAG} getSysDisplayRegion`);
    return i18n.System.getDisplayCountry(i18n.System.getSystemRegion(), i18n.System.getSystemLanguage(),true);
  }

  /**
     * get system countries
     */
  @Log
  getSystemCountries():Array<string>{
    LogUtil.info(`${this.TAG} getSystemCountries`);
    return i18n.System.getSystemCountries(i18n.System.getSystemLanguage());
  }

  /**
     * set system region
     */
  @Log
  setSystemRegion(region:string):void{
    LogUtil.info(`${this.TAG} setSystemRegion`);
    i18n.System.setSystemRegion(region);
    AppStorage.Set(this.regionStr, this.getSysDisplayRegion());
    return;
  }

  /**
     * Determine if it is the system language
     */
  @Log
  isSystemLanguage(language:string):boolean{
    return language === i18n.System.getSystemLanguage();
  }

  /**
     * Determine if it is in the addedLanguages
     */
  @Log
  isInAddedLanguage(language:string):boolean{
    this.addedLanguages = AppStorage.Get(this.addStr);
    if(this.addedLanguages.indexOf(language) === -1){
      return false;
    }else{
      return true;
    }
  }

  /**
     * Determine if it is the system region
     */
  @Log
  isSystemRegion(region:string):boolean{
    return region === i18n.System.getSystemRegion();
  }

}

let languageAndRegionModel = new LanguageAndRegionModel();
export default languageAndRegionModel as LanguageAndRegionModel;
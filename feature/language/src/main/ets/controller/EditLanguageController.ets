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
import { BusinessError } from '@ohos.base';
import { LogUtil } from '@ohos/settings.common/src/main/ets/utils/LogUtil';
import { languageAndRegionModel } from '../model/LanguageAndRegionModel';

/**
 * 编辑语言的通用逻辑
 *
 * @since 2023-02-09
 */
@Observed
export class EditLanguageController {
  private TAG = 'EditLanguageController: ';
  public languageList: Array<string>;
  public languageListBackup: Array<string>;
  public deleteLanguageList: Array<string> = [];
  private changeFlag: boolean = false;
  public pathInfos: NavPathStack | null = null;
  constructor() {
    this.languageList = Array.from(languageAndRegionModel.getAddedLanguages());
    this.languageListBackup = Array.from(languageAndRegionModel.getAddedLanguages());
  }

  getDelAfterLanguages(): string[] {
    LogUtil.info(`${this.TAG} getDelAfterLanguages in`);
    this.languageList = languageAndRegionModel.getAddedLanguages();
    AppStorage.set('addedLanguages', this.languageList);
    return this.languageList;
  }

  // 单个语言删除
  deleteSingleLanguage(language: string): void {
    LogUtil.info(`${this.TAG} deleteSingleLanguage in`);
    let index = this.languageList.indexOf(language);
    if (index === -1) {
      return;
    }
    this.deleteLanguageList.push(language);
    this.languageListBackup.splice(index, 1);
    try {
      // 如果删除首选项选中的语言需要更新系统语言为下一个语言
      if (i18n.System.getSystemLanguage() === language && (index + 1) < this.languageList.length) {
        LogUtil.info(`${this.TAG} deleteSingleLanguage current language is delete language`);
        let nextLanguage: string = this.languageList[index + 1];
        i18n.System.setSystemLanguage(nextLanguage);
        index = languageAndRegionModel.getAddedLanguages().indexOf(language);
      }
      // 删除偏好语言
      i18n.System.removePreferredLanguage(index);
      LogUtil.info(`${this.TAG} removePreferredLanguage success ${this.languageList.indexOf(language)}`);
    } catch (error) {
      LogUtil.error(`removePreferredLanguage errMessage: ${(error as BusinessError).message} errCode:${(error as BusinessError).code}`);
    }
    LogUtil.info(`${this.TAG} deleteSingleLanguage out`);
    this.notifyChange();
  }

  // 取消删除
  cancelDeleteLanguage() {
    this.deleteLanguageList.forEach(item => {
      languageAndRegionModel.addLanguage(item);
    });
    this.notifyChange();
  }

  notifyChange() {
    this.changeFlag = !this.changeFlag;
  }
}

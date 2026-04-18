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
import { BusinessError } from '@ohos.base';
import fs from '@ohos.file.fs';
import picker from '@ohos.file.picker';
import { MenuController } from '@ohos/settings.common/src/main/ets/core/controller/MenuController';
import { SettingsBaseMenu } from '@ohos/settings.common/src/main/ets/core/model/menu/SettingsMenu';
import { Controller } from '@ohos/settings.common/src/main/ets/core/controller/Controller';
import { LogUtil } from '@ohos/settings.common/src/main/ets/utils/LogUtil';

const TAG: string = 'SelectCertificateFileController :';

export class SelectCertificateFileController extends MenuController {
  static CreateSelectCertificateFileController(menu: SettingsBaseMenu): Controller {
    return new SelectCertificateFileController(menu);
  }

  public tag: string = 'SelectCertificateFileController : ';

  constructor(menu: SettingsBaseMenu) {
    super(menu);
    this.menu.state = $r('app.string.unassigned');
    this.publishDataChange('');
  }

  onPageShow() {
    LogUtil.info(`${TAG} onPageShow`);
  }

  onPageHide() {
    LogUtil.info(`${TAG} onPageHide`);
  }

  onMenuClick(): boolean {
    const documentViewPicker = new picker.DocumentViewPicker();
    const documentSelectOptions = new picker.DocumentSelectOptions();
    documentSelectOptions.maxSelectNumber = 1;
    documentSelectOptions.fileSuffixFilters = ['.cer'];
    documentViewPicker.select(documentSelectOptions).then((documentSelectResult: Array<string>) => {
      const filePath = documentSelectResult[0] || '';
      LogUtil.info(`${TAG} documentViewPicker.select filePath:${filePath}`);
      if (!filePath) {
        return;
      }
      let file: fs.File | undefined = undefined;
      try {
        file = fs.openSync(filePath);
        const text: string = fs.readTextSync(file.path);
        this.publishDataChange(text);
        this.menu.state = file.name;
        this.refreshUi();
      } catch (err) {
        LogUtil.error(`${TAG} fs.readfile catch code:${err.code} message:${err.message}`);
      } finally {
          try {
            file && fs.closeSync(file);
          } catch (err) {
            LogUtil.error(`${TAG} fs.closeSync catch code:${err.code} message:${err.message}`);
          }
      }
    }).catch((err: BusinessError) => {
      LogUtil.error(`${TAG} documentViewPicker.select catch code:${err.code} message:${err.message}`);
    });
    return true;
  }
}
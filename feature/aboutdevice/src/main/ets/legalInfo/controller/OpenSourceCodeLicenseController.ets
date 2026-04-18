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

import fs, { ListFileOptions } from '@ohos.file.fs';
import { LogUtil } from '@ohos/settings.common/src/main/ets/utils/LogUtil';
import { PreferencesUtil } from '@ohos/settings.common/src/main/ets/utils/PreferencesUtil';
import { AboutDeviceUtils } from '../../utils/AboutDeviceUtils';
import { NoticeParser } from '../parser/NoticeParser';
/* instrument ignore file */
const TAG: string = 'OpenSourceCodeLicenseController:';

/**
 * 开放源代码许可控制器
 *
 * @since 2023-09-12
 */
class OpenSourceCodeLicenseController {
  private noticeFiles: Array<string> = [`/system/etc/NOTICE.txt`, `/vendor/etc/passthrough/noticeFile/NOTICE.txt`,
    `/cust/etc/NOTICE.txt`, `/sys_prod/etc/NOTICE.txt`, `/version/etc/NOTICE.txt`];
  private noticeHtml: string = 'NOTICE-all.html';
  private noticePaths: Array<string> = ['/system/etc/noticeFile', '/vendor/etc/passthrough/noticeFile/noticeFile',
    '/cust/etc/noticeFile', '/sys_prod/etc/noticeFile', '/version/etc/noticeFile'];
  private fileSuffix: string = '.txt';

  private buildFilePaths(): void {
    LogUtil.showInfo(TAG, 'buildFilePaths');
    for (let pathPrefix of this.noticePaths) {
      let listFileOption: ListFileOptions = {
        recursion: false,
        listNum: 0,
        filter: { suffix: [this.fileSuffix] }
      }
      try {
        let fileNames = fs.listFileSync(pathPrefix, listFileOption);
        LogUtil.showInfo(TAG, `listFile ${pathPrefix} succeed`);
        for (let fileName of fileNames) {
          NoticeParser.getInstance().parseOpenSourceText(`${pathPrefix}/${fileName}`);
        }
      } catch (err) {
        LogUtil.showError(TAG, `listFile ${pathPrefix} failed with error message: ${err?.message}, ${err?.code}`);
      }
    }
  }

  /**
   * 构建开放源码许可文件
   * @returns 开放源码许可文件路径
   */
  public async rebuildLicenseFile(): Promise<string> {
    LogUtil.showInfo(TAG, 'start to rebuildLicenseFile');
    let cacheDir: string = AppStorage.get<Context>('pageContext')?.cacheDir ?? '';
    LogUtil.showInfo(TAG, `start to rebuildLicenseFile in cacheDir: ${cacheDir}`);
    if (!cacheDir) {
      LogUtil.showError(TAG, 'cacheDir is null');
      return '';
    }
    const noticeHtmlPath: string = cacheDir + '/' + this.noticeHtml;
    const noticeParser: NoticeParser = NoticeParser.getInstance();
    const softVersion: string = AboutDeviceUtils.getSoftwareVersion();
    let softVersionCache = PreferencesUtil.getSync('softVersionCache', '') as String;
    if (!softVersionCache || softVersionCache !== softVersion) {
      try {
        fs.unlinkSync(noticeHtmlPath);
      } catch (error) {
        LogUtil.showError(TAG, `unlinkSync noticeHtmlPath failed`);
      }
    }
    if (noticeParser.isFileExist(noticeHtmlPath)) {
      LogUtil.showInfo(TAG, `noticeHtmlPath : ${noticeHtmlPath} has been Existed`);
      return 'file://' + noticeHtmlPath;
    }
    for (let noticeFile of this.noticeFiles) {
      if (!noticeParser.isFileExist(noticeFile)) {
        LogUtil.showInfo(TAG, `file not exist, index: ${this.noticePaths.indexOf(noticeFile)}`);
        continue;
      }
      noticeParser.parseText(noticeFile);
    }
    await this.buildFilePaths();
    PreferencesUtil.put('softVersionCache', softVersion);
    await noticeParser.writeToHtml(noticeHtmlPath, this.noticeHtml);
    return 'file://' + noticeHtmlPath;
  }
}

export default new OpenSourceCodeLicenseController();
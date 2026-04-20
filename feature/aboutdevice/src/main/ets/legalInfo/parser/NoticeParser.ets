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

import fs from '@ohos.file.fs';
import intl from '@ohos.intl';
import { LogUtil } from '@ohos/settings.common/src/main/ets/utils/LogUtil';
import { RawFileUtil } from '@ohos/settings.common/src/main/ets/utils/RawFileUtil';

const LINE_SPLIT_MARK = '\n';
const TAG_FILES: string = '============================================================';
const TAG_LICENSE: string = '------------------------------------------------------------';
const TAG_FILE_SUBJECT: string = 'Notices for file(s):';
const TAG_SOFT_SUBJECT: string = 'Notices for software(s):';
const VERSION_PREFIX: string = 'Version:';
const PATH_PREFIX: string = 'Path:';
const OPENSOURCE_SOFTWARE_PREFIX = 'Software:';
const MODE_FILES: number = 0;
const MODE_SOFT: number = 1;
const MODE_LICENCES: number = 2;
const MODE_INTERVAL: number = 3;

export class NoticeParser {
  private static noticeParser: NoticeParser;
  public tag: string = 'NoticeParser:';
  // 保存开源文件名称和协议内容之间的映射关系
  public mFileMaps: Map<string, string> = new Map<string, string>();
  // 保存开源软件名称和协议内容之间的映射关系
  public mSoftwareMaps: Map<string, string> = new Map<string, string>();
  // 保存协议内容
  public mLicenses: string[] = [];

  /**
   * 获取单例
   */
  public static getInstance(): NoticeParser {
    if (NoticeParser.noticeParser) {
      return NoticeParser.noticeParser;
    }
    NoticeParser.noticeParser = new NoticeParser();
    return NoticeParser.noticeParser;
  }

  /**
   * 判断文件是否存在
   * @param filePath 文件路径
   * @returns
   */
  public isFileExist(filePath: string): boolean {
    let isExist: boolean = false;
    try {
      isExist = fs.accessSync(filePath);
    } catch (error) {
      LogUtil.showError(this.tag, `accessSync error: ${error?.code}, ${error?.message}`);
    }
    return isExist
  }

  /**
   * 解析OpenSource.txt文件
   * @param filePath 文件路径
   */
  parseOpenSourceText(filePath: string): void {
    try {
      const fileContent: string = fs.readTextSync(filePath);
      let fileContentLines: string[] = fileContent.split(LINE_SPLIT_MARK);
      let content: string = '';
      let readCount: number = 0;
      for (const line of fileContentLines) {
        readCount = readCount + 1;
        if (!line.startsWith(OPENSOURCE_SOFTWARE_PREFIX) && content === '') {
          continue;
        }
        if (readCount === fileContentLines.length) {
          content = content + line;
          if (this.mLicenses.indexOf(content) < 0) {
            this.mLicenses.push(content);
          }
          content = '';
          break;
        } else if (line.startsWith(OPENSOURCE_SOFTWARE_PREFIX) && content !== '') {
          if (this.mLicenses.indexOf(content) < 0) {
            this.mLicenses.push(content);
          }
          content = '';
        }
        content = content + line + LINE_SPLIT_MARK;
      }
      LogUtil.showInfo(this.tag, `this.mLicenses size: ${this.mLicenses.length}`);
    } catch (error) {
      LogUtil.showError(this.tag, `parseOpenSourceText error: ${error?.code}, ${error?.message}`);
    }
  }


  /**
   * 解析notice.txt文件
   * @param filePath 文件路径
   */
  parseText(filePath: string): void {
    try {
      const fileContent: string = fs.readTextSync(filePath);
      let fileContentLines: string[] = fileContent.split(LINE_SPLIT_MARK);
      let mode: number = -1;
      let tmpFiles: string[] = [];
      let tmpSoftware: string[] = [];
      let content: string = '';
      let readCount: number = 0;
      for (const line of fileContentLines) {
        readCount = readCount + 1;
        if (TAG_FILES === line || (readCount === fileContentLines.length)) {
          if (!content) {
            mode = MODE_INTERVAL;
            continue;
          }

          if (this.mLicenses.indexOf(content) < 0) {
            this.mLicenses.push(content);
          }
          const len: number = tmpFiles.length;
          for (let index = 0; index < len; index++) {
            this.mFileMaps.set(tmpFiles[index], content);
          }
          for (let index = 0; index < tmpSoftware.length; index++) {
            this.mSoftwareMaps.set(tmpSoftware[index], content);
          }
          // clear content and array
          if (content.length > 0) {
            content = '';
          }
          tmpFiles = [];
          tmpSoftware = [];
          mode = MODE_INTERVAL;
          continue;
        } else if (TAG_LICENSE === line) {
          mode = MODE_INTERVAL;
          continue;
        } else if (MODE_INTERVAL === mode) {
          if (TAG_FILE_SUBJECT === line) {
            mode = MODE_FILES;
          } else if (TAG_SOFT_SUBJECT === line) {
            mode = MODE_SOFT;
          } else {
            mode = MODE_LICENCES;
            content = content + line + LINE_SPLIT_MARK;
          }
        } else {
          if (mode === MODE_FILES) {
            LogUtil.debug(`${this.tag} this.MODE_FILES line: ${line}`);
            if (tmpFiles.indexOf(line) < 0) {
              tmpFiles.push(line);
            }
          } else if (mode === MODE_SOFT) {
            LogUtil.debug(`${this.tag} this.MODE_SOFT line: ${line}`);
            if (line.startsWith(VERSION_PREFIX) || line.startsWith(PATH_PREFIX)) {
              continue;
            }
            tmpSoftware.push(line);
          } else if (mode === MODE_LICENCES) {
            LogUtil.debug(`${this.tag} this.MODE_LICENCES line: ${line}`);
            content = content + line + LINE_SPLIT_MARK;
          }
        }
      }
      LogUtil.info(`${this.tag} this.mLicenses size: ${this.mLicenses.length}`);
      LogUtil.info(`${this.tag}  this.mFileMaps size: ${this.mFileMaps.size}`);
    } catch (error) {
      LogUtil.error(`${this.tag} readTextSync error: ${error?.message}`);
    }
  }

  /**
   * 将notice.txt文件内容写入html
   * @param filePath 文件路径
   * @param fileName 文件名
   */
  async writeToHtml(filePath: string, fileName: string): Promise<void> {
    let streamOutput: fs.Stream | null = null;
    try {
      const rawContent: string = await RawFileUtil.getStringByFile((AppStorage.get<Context>('pageContext') as Context)?.resourceManager, fileName);
      LogUtil.info(`${this.tag} rawHtmlContent: ${rawContent}`);
      const isExist: boolean = fs.accessSync(filePath);
      if (isExist) {
        LogUtil.info(`${this.tag} filePath isExist`);
        fs.unlinkSync(filePath);
      }
      LogUtil.info(`${this.tag} write files and licence to Html`);
      streamOutput = fs.createStreamSync(filePath, 'a+');
      streamOutput.writeSync(rawContent);
      let fileNames: string[] = [];
      this.mFileMaps.forEach((value, key) => {
        fileNames.push(key);
      })

      //写开源文件列表
      streamOutput.writeSync('<div class="toc">');
      streamOutput.writeSync('<ul>');
      if (fileNames.length > 0) {
        let collator = new intl.Collator();
        fileNames.sort((a, b) => collator.compare(a, b));
        for (const fileName of fileNames) {
          const fileLicense: string | undefined = this.mFileMaps.get(fileName);
          if (!fileLicense) {
            continue;
          }
          const id: number = this.mLicenses.indexOf(fileLicense);
          let fileContentModel: string = '<li><a href="#id%d">%s</a></li>';
          fileContentModel = fileContentModel.replace(new RegExp('%d', 'gm'), id.toString());
          fileContentModel = fileContentModel.replace(new RegExp('%s', 'gm'), fileName);
          streamOutput.writeSync(fileContentModel);
        }
      }
      streamOutput.writeSync('</ul>');
      streamOutput.writeSync('</div><!-- table of contents -->');

      // 写协议内容
      streamOutput.writeSync('<table cellpadding="0" cellspacing="0" border="0">');
      const licenseSize: number = this.mLicenses.length;
      for (let index = 0; index < licenseSize; index++) {
        const license: string = this.mLicenses[index];
        if (!license) {
          continue;
        }
        let licenseContentModel = '<tr id="id%d"><td class="same-license" style="padding:0">';
        licenseContentModel = licenseContentModel.replace(new RegExp('%d', 'gm'), index.toString());
        streamOutput.writeSync(licenseContentModel);
        streamOutput.writeSync('<div class="label">Notices for file(s):</div>');
        streamOutput.writeSync('<div class="file-list" style="word-break:break-all;max-width:96vw;margin-right:2vw;">');

        this.mFileMaps.forEach((value, key) => {
          if (value === license) {
            streamOutput?.writeSync('%s <br/>'.replace('%s', key));
          }
        })
        streamOutput.writeSync('</div><!-- file-list -->');
        streamOutput.writeSync('<div class="label">Notices for software(s):</div>');
        streamOutput.writeSync('<div class="software-list" style="word-break:break-all;max-width:96vw;margin-right:2vw;">');

        this.mSoftwareMaps.forEach((value, key) => {
          LogUtil.info(`${this.tag} this.mSoftwareMaps key: ${key}`);
          if (value === license) {
            streamOutput?.writeSync('%s <br/>'.replace('%s', key));
          }
        })
        streamOutput.writeSync('</div><!-- software-list -->');
        streamOutput.writeSync('<pre class="license-text" style="white-space:pre-wrap;">');
        streamOutput.writeSync(this.htmlEscapeLicense(license));
        streamOutput.writeSync('</pre><!-- license-text -->');
        streamOutput.writeSync('</td></tr><!-- same-license -->');
      }
      streamOutput.writeSync('</table>');
      streamOutput.writeSync('</body></html>');
    } catch (error) {
      LogUtil.error(`${this.tag} writeToHtml error: ${error?.message}`);
    } finally {
      if (streamOutput) {
        streamOutput.closeSync();
      }
    }
  }

  private htmlEscapeLicense(license: string): string {
    let result: string = license;
    result = result.replace('&', '&amp;');
    result = result.replace('\\"', '&quot;');
    result = result.replace('\'', '&apos;');
    result = result.replace('>', '&gt;');
    result = result.replace('<', '&lt;');
    return result;
  }
}
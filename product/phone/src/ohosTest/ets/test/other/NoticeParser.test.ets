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

import { afterAll, afterEach, beforeAll, beforeEach, describe, expect, it } from '@ohos/hypium';
import { NoticeParser } from '@ohos/settings.aboutdevice/src/main/ets/legalInfo/parser/NoticeParser';

export default function noticeParserTest() {
  describe('noticeParserTest', (): void => {

    beforeAll((): void => {
    })

    beforeEach((): void => {
    })

    afterAll((): void => {
    })

    afterEach((): void => {
    })

    it('getInstanceTest', 0, () => {
      expect(NoticeParser.getInstance()).not().assertNull();
    })

    it('isFileExistTest', 0, () => {
      let noticeParser: NoticeParser = NoticeParser.getInstance();
      expect(noticeParser.isFileExist('aaa')).not().assertNull();
    })

    it('noticeParserTest_parseText_001', 0, (done: Function) => {
      try {
        let noticeParser = new NoticeParser;
        let filePath: string = '/system/etc/NOTICE.txt';
        let result = noticeParser.parseText(filePath);
        expect(result !== null).assertTrue();
      } catch (e) {
      } finally {
        done()
      }
    });
    it('noticeParserTest_parseText_002', 0, async (done: Function) => {
      try {
        let noticeParser = new NoticeParser;
        let filePath: string = '/system/etc/NOTICE.txt';
        let result = await noticeParser.writeToHtml(filePath, 'NOTICE-all.html');
        expect(result !== null).assertTrue();
      } catch (e) {
      } finally {
        done()
      }
    });
    it('noticeParserTest_parseText_003', 0, async (done: Function) => {
      try {
        let noticeParser = new NoticeParser;
        let cacheDir: string = AppStorage.get<Context>('pageContext')?.cacheDir ?? '';
        let noticeHtmlPath: string = cacheDir + '/' + 'NOTICE-all.html';
        noticeParser.mFileMaps = new Map([['key', 'value'], ['key2', 'value2'], ['key3', 'value3']]);
        noticeParser.mLicenses = ['11', '22', '33'];
        let result = await noticeParser.writeToHtml(noticeHtmlPath, 'NOTICE-all.html');
        expect(result !== null).assertTrue();
      } catch (e) {
      } finally {
        done()
      }
    });
  })
}


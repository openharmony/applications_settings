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
import { LinkTextParser } from '@ohos/settings.aboutdevice/src/main/ets/legalInfo/parser/LinkTextParser';
import { BaseText } from '@ohos/settings.aboutdevice/src/main/ets/legalInfo/parser/TextModel';

export default function linkTextParserTest() {
  describe('linkTextParserTest', (): void => {

    beforeAll((): void => {
    })

    beforeEach((): void => {
    })

    afterAll((): void => {
    })

    afterEach((): void => {
    })

    it('getInstanceTest', 0, () => {
      expect(LinkTextParser.getInstance()).not().assertNull();
    })
    it('getInstanceTest_001', 0, (done: Function) => {
      try {
        let result = LinkTextParser.getInstance().parseText([]);
        expect(result.length === 0).assertTrue();
      } catch (e) {
      } finally {
        done()
      }
    });
    it('getInstanceTest_002', 0, (done: Function) => {
      try {
        let textArr: Array<BaseText> = [new BaseText('<a>test</a>')];
        let result = LinkTextParser.getInstance().parseText(textArr);
        expect(result !== null).assertTrue();
      } catch (e) {
      } finally {
        done()
      }
    });
    it('getInstanceTest_003', 0, (done: Function) => {
      try {
        let textArr: Array<BaseText> = [new BaseText('test')];
        let result = LinkTextParser.getInstance().parseText(textArr);
        expect(result !== null).assertTrue();
      } catch (e) {
      } finally {
        done()
      }
    });
  })
}


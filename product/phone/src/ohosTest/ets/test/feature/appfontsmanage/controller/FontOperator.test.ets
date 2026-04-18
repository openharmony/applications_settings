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

import { describe, expect, it } from '@ohos/hypium';
import { FontOperator } from '@ohos/settings.font-manager/src/main/ets/controller/FontOperator';
import { HashMap, HashSet, TreeMap, TreeSet, util } from '@kit.ArkTS';
class FontFileInfo {
  fileUri: string = '';
  fileName: string = '';
  fileSha256: string = '';
  fontInfos: TreeMap<string, TreeSet<string>> = new TreeMap<string, TreeSet<string>>();

  constructor(fileUri: string, fileName: string) {
    this.fileUri = fileUri;
    this.fileName = fileName;
  }
}

export default function FontOperatorTest() {
  let fontOperator = FontOperator.getInstance();
  describe('FontOperatorTest', () => {

    it('test_startInitTask_return', 0, (): void => {
      let resA =  fontOperator.startInitTask();
      expect(resA === null).assertFalse();
    })

    it('test_installFonts_return', 0, async (): Promise<void> => {
      let resA =  await fontOperator.installFonts([]);
      expect(resA === null).assertFalse();
      let resB =  await fontOperator.installFonts(['Settings\\report']);
      expect(resB === null).assertFalse();
    })

    it('test_uninstallFonts_return', 0, async (): Promise<void> => {
      let resA =  await fontOperator.uninstallFonts('');
      expect(resA === null).assertFalse();
      let resB =  await fontOperator.uninstallFonts('familyName');
      expect(resB === null).assertFalse();
    })

    it('test_loadFontCards_return', 0, async (): Promise<void> => {
      let resA: Object = await (fontOperator as object)['loadFontCards']();
      expect(resA === null).assertFalse();
    })

    it('test_refreshUiFontCards_return', 0, (): void => {
      let resA: Object = (fontOperator as object)['refreshUiFontCards'](false);
      expect(resA === null).assertFalse();
      let resB: Object = (fontOperator as object)['refreshUiFontCards'](true);
      expect(resB === null).assertFalse();
    })

    it('test_processDuplicates_return', 0, async (): Promise<void> => {
      let par: string[] = ['a', 'b', 'c'];
      let resA: Object = await (fontOperator as object)['processDuplicates'](par);
      expect(resA === null).assertFalse();
    })

    it('test_processDuplicate_return', 0, async (): Promise<void> => {
      let resA: Object = await (fontOperator as object)['processDuplicate']('a');
      expect(resA === null).assertFalse();
    })

    it('test_tryInstallFonts_return', 0, async (): Promise<void> => {
      let resA: Object = await (fontOperator as object)['tryInstallFonts']([]);
      expect(resA === true).assertFalse();
      let resB: Object = await (fontOperator as object)['tryInstallFonts'](['a', 'b', 'c']);
      expect(resB === true).assertFalse();
    })

    it('test_uninstallFontFiles_return', 0, async (): Promise<void> => {
      let fontFileInfosArr: FontFileInfo[] = []
      let resA: Object = await (fontOperator as object)['uninstallFontFiles'](fontFileInfosArr);
      expect(resA === true).assertTrue();
    })

    it('test_tryUninstallFonts_return', 0, async (): Promise<void> => {
      let resA: Object = await (fontOperator as object)['tryUninstallFonts']('');
      expect(resA === true).assertFalse();
      let resB: Object = await (fontOperator as object)['tryUninstallFonts']('a');
      expect(resB === true).assertFalse();
    })

  });
}
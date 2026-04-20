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

import { describe, expect, it, TestType } from '@ohos/hypium';
import { TreeMap, TreeSet } from '@kit.ArkTS';
import { FontReader } from '@ohos/settings.font-manager/src/main/ets/controller/FontReader';
class NameRecord {
  public platformID: number = 0;
  public platformSpecificID: number = 0;
  public languageID: number = 1;
  public nameID: number = 1;
  public length: number = 0;
  public offset: number = 0;
  public content: string = 'text';

  constructor(platformID: number, platformSpecificID: number, languageID: number, nameID: number,
    length: number, offset: number, content: string ) {
    this.platformID = platformID;
    this.platformSpecificID = platformSpecificID;
    this.languageID = languageID;
    this.nameID = nameID;
    this.length = length;
    this.offset = offset;
    this.content = content;
  }
}
async function FontReaderTest_001() {
  let ns: ESObject = await import('@ohos/settings.font-manager/src/main/ets/controller/FontReader');
  let data: Uint8Array = new Uint8Array();
  let result: number = ns.FontReader.parseNumber(data, 0, 0, false);
  expect(result).assertEqual(0);

  result = ns.FontReader.parseNumber(data, 1, -1, false);
  expect(result).assertEqual(0);

  result = ns.FontReader.parseNumber(data, 1, 0, false);
  expect(result).assertEqual(0);

  data = new Uint8Array([1]);
  result = ns.FontReader.parseNumber(data, 1, 0, false);
  expect(result).assertEqual(1);

  result = ns.FontReader.parseNumber(data, 1, 0, true);
  expect(result).assertEqual(1);
}

async function FontReaderTest_002() {
  let ns: ESObject = await import('@ohos/settings.font-manager/src/main/ets/controller/FontReader');
  let data: Uint8Array = new Uint8Array();
  let result: TreeMap<string, TreeSet<string>> | undefined = ns.FontReader.readTtc(data);
  expect(result).assertEqual(undefined);

  data = new Uint8Array([0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0]);
  result = ns.FontReader.readTtc(data);
  expect(result).assertEqual(undefined);

  data = new Uint8Array([0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1]);
  result = ns.FontReader.readTtc(data);
  expect(result).assertEqual(undefined);

  const NAME_TABLE_START_POS: number = 16;
  data = new Uint8Array([0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, NAME_TABLE_START_POS, 0, 0, 0, 0]);
  result = ns.FontReader.readTtc(data);
  expect(result).assertEqual(undefined);

  data = new Uint8Array([0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, NAME_TABLE_START_POS,
    0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0]);
  result = ns.FontReader.readTtc(data);
  expect(result).assertEqual(undefined);

  data = new Uint8Array([0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, NAME_TABLE_START_POS,
    0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0]);
  result = ns.FontReader.readTtc(data);
  expect(result).assertEqual(undefined);

  data = new Uint8Array([0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, NAME_TABLE_START_POS,
    0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0]);
  result = ns.FontReader.readTtc(data);
  expect(result).assertEqual(undefined);

  const CHAR_A: number = 65;
  data = new Uint8Array([0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, NAME_TABLE_START_POS,
    0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, CHAR_A, CHAR_A, CHAR_A, CHAR_A, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0]);
  result = ns.FontReader.readTtc(data);
  expect(result).assertEqual(undefined);

  data = new Uint8Array([0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, NAME_TABLE_START_POS,
    0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, CHAR_A, CHAR_A, CHAR_A, CHAR_A, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0]);
  result = ns.FontReader.readTtc(data);
  expect(result).assertEqual(undefined);

  data = new Uint8Array([0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, NAME_TABLE_START_POS,
    0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, CHAR_A, CHAR_A, CHAR_A, CHAR_A, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 1]);
  result = ns.FontReader.readTtc(data);
  expect(result).assertEqual(undefined);
}

export default function FontReaderTest() {
  let data: Uint8Array = new Uint8Array();
  describe('FontReaderTest', () => {
    it('FontReaderTest_001', TestType.FUNCTION, async () => {
      await FontReaderTest_001();
    });

    it('FontReaderTest_002', TestType.FUNCTION, async () => {
      await FontReaderTest_002();
    });

    it('FontReaderTest_003', TestType.FUNCTION, async () => {
      // data = new Uint8Array([0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0]);
      // let resB:Object = (FontReader as object)['parseNumber'](data, 2, 2, false);
      // console.log('lp---------------------:'+resB)
      let resA: Object = (FontReader as object)['readNameRecords'](data);
      expect(resA === undefined).assertTrue();
      data = new Uint8Array([0x12, 0x34, 0x56, 0x78]);
      let resB: Object = (FontReader as object)['readNameRecords'](data);
      expect(resB === undefined).assertTrue();
      data = new Uint8Array([0, 1, 255, 128]);
      let resC: Object = (FontReader as object)['readNameRecords'](data);
      expect(resC === undefined).assertTrue();
    });

    it('FontReaderTest_004', TestType.FUNCTION, async () => {
      let data: Uint8Array = new Uint8Array([32, 32, 32, 32]);
      let resA: Object = (FontReader as object)['readTableHeader'](data);
      expect(resA === undefined).assertTrue();
    });

    it('FontReaderTest_005', TestType.FUNCTION, async () => {
      let records: NameRecord[] = [];
      for(let i: number=0; i<5; i++){
        let itemObj: NameRecord = new NameRecord(i, i, i, i, i, i, 'text');
        records.push(itemObj)
      }
      let resA: Object = (FontReader as object)['readNameInfo'](records);
      expect(resA !== null).assertTrue();
      records = [];
      for(let i: number=0; i<2; i++){
        let itemObj: NameRecord = new NameRecord(i, i, i, 1, i, i, 'text');
        records.push(itemObj)
      }
      let resB: Object = (FontReader as object)['readNameInfo'](records);
      expect(resB !== null).assertTrue();
    });

    it('FontReaderTest_006', TestType.FUNCTION, async () => {
      let resA: Object = (FontReader as object)['readFontInfo'](data);
      expect(resA === undefined).assertTrue();
      data = new Uint8Array([
        0x00, 0x00, 0x00, 0x00,  // 假设这是TableHeader对象的长度
        0x6e, 0x61, 0x6d, 0x65  // 'name'的字节表示
      ]);
      let resB: Object = (FontReader as object)['readFontInfo'](data);
      expect(resB === undefined).assertTrue();
    });

    it('FontReaderTest_007', TestType.FUNCTION, async () => {
      let resA: Object = (FontReader as object)['readFontData']('');
      expect(resA === undefined).assertTrue();
    });

    it('FontReaderTest_008', TestType.FUNCTION, async () => {
      let path: string = 'a.otf';
      let resA: Object = (FontReader as object)['readFontType'](path);
      expect(resA).assertEqual(0);
      path = 'a.ttf';
      let resB: Object = (FontReader as object)['readFontType'](path);
      expect(resB).assertEqual(1);
      path = 'a.ttc';
      let resC: Object = (FontReader as object)['readFontType'](path);
      expect(resC).assertEqual(2);
      path = 'a.ttt';
      let resD: Object = (FontReader as object)['readFontType'](path);
      expect(resD === undefined).assertTrue();
    });

    it('FontReaderTest_009', TestType.FUNCTION, async () => {
      let path: string = 'a.ttt';
      let resA: Object = (FontReader as object)['readFontInfos'](path);
      expect(resA === undefined).assertTrue();
      path = 'a.ttc';
      let resB: Object = (FontReader as object)['readFontInfos'](path);
      expect(resB === undefined).assertTrue();
    });


  });
}

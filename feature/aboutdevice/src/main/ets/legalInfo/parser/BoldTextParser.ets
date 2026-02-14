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

import { IParser } from './IParser';
import { BaseText, BoldText, NormalText } from './TextModel';
import { ArrayUtil } from '../util/ArrayUtil';
import { StringUtil } from '../util/StringUtil';
/* instrument ignore file */
const FLAG_BEGIN: string = '<b>';
const FLAG_END: string = '</b>';
const FIRST_ITEM: number = 0;
const NOT_FOUND: number = -1;

/**
 * 加粗文本解析器
 */
export class BoldTextParser implements IParser {
  private static boldTextInstance: BoldTextParser;

  /**
   * 构造函数
   */
  private constructor() {
  }

  /**
   * 获取解析器单例
   */
  public static getInstance(): BoldTextParser {
    if (BoldTextParser.boldTextInstance) {
      return BoldTextParser.boldTextInstance;
    }
    return BoldTextParser.boldTextInstance;
  }

  /**
   * 解析文本
   * @param texts 待解析文本
   */
  parseText(textArr: Array<BaseText>): Array<BaseText> {
    if (ArrayUtil.isEmpty(textArr)) {
      return [];
    }
    let result: BaseText[] = [];
    for (let textItem of textArr) {
      if (!(textItem instanceof NormalText)) {
        result.push(textItem);
        continue;
      }
      let text: string = textItem.getText();
      let beginIndex: number = text.indexOf(FLAG_BEGIN);
      while (beginIndex !== NOT_FOUND) {
        if (beginIndex !== FIRST_ITEM) {
          result.push(new NormalText(text.substr(FIRST_ITEM, beginIndex)));
        }
        text = text.substr(beginIndex + FLAG_BEGIN.length, text.length);
        let endIndex = text.indexOf(FLAG_END);
        if (endIndex === NOT_FOUND) {
          beginIndex = text.indexOf(FLAG_BEGIN);
          continue;
        }
        let boldText = text.substr(FIRST_ITEM, endIndex);
        if (StringUtil.isNotEmpty(boldText)) {
          result.push(new BoldText(boldText));
        }
        text = text.substr(endIndex + FLAG_END.length, text.length);
        beginIndex = text.indexOf(FLAG_BEGIN);
      }
      if (StringUtil.isNotEmpty(text)) {
        result.push(new NormalText(text));
      }
    }
    return result;
  }
}

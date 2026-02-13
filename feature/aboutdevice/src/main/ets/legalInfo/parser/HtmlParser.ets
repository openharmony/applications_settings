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
import { BaseText, NormalText } from './TextModel';
import { ArrayUtil } from '../util/ArrayUtil';
import { StringUtil } from '../util/StringUtil';


/**
 * Html特殊字符解析器
 */
export class HtmlParser implements IParser {
  private static htmlParserInstance: HtmlParser;
  private mSpecialCharMap: Map<string, string> = new Map<string, string>();
  private str: string = '';

  /**
   * 获取单例
   */
  public static getInstance(): HtmlParser {
    if (HtmlParser.htmlParserInstance) {
      return HtmlParser.htmlParserInstance;
    }
    HtmlParser.htmlParserInstance = new HtmlParser();
    return HtmlParser.htmlParserInstance;
  }

  /**
   * 初始化
   * @param string
   */
  public init(string: string): void {
    this.str = string;
  }

  /**
   * 构造函数
   */
  private constructor() {
    this.mSpecialCharMap.set('&lt;', '<');
    this.mSpecialCharMap.set('&gt;', '>');
  }

  /**
   * 文本解析
   * @param textArr 待解析文本
   */
  parseText(textArr: Array<BaseText>): Array<BaseText> {
    if (StringUtil.isEmpty(this.str)) {
      return [];
    }
    if (ArrayUtil.isEmpty(textArr)) {
      textArr = [];
    }
    this.mSpecialCharMap.forEach((value, key) => {
      let index: number = this.str.indexOf(key);
      while (index >= 0) {
        this.str = this.str.replace(key, value);
        index = this.str.indexOf(key);
      }
    });
    textArr.push(new NormalText(this.str));
    return textArr;
  }
}

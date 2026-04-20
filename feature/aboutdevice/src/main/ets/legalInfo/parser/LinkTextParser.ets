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

import Want from '@ohos.app.ability.Want';
import { LogUtil } from '@ohos/settings.common/src/main/ets/utils/LogUtil';
import { IParser } from './IParser';
import { BaseText, LinkText, NormalText } from './TextModel';
import { ArrayUtil } from '../util/ArrayUtil';
import { StringUtil } from '../util/StringUtil';

const TAG: string = 'LinkTextParser : ';
const FLAG_BEGIN: string = '<a';
const FLAG_BEGIN_END: string = '>';
const FLAG_END: string = '</a>';
const LINK_KEY_BEGIN: string = 'link="';
const FIRST_ITEM: number = 0;
const NOT_FOUND: number = -1;

/**
 * 跳转链接解析
 */
export class LinkTextParser implements IParser {
  private static linkTextParserInstance: LinkTextParser;
  private abilities: Map<string, Want> = new Map();

  /**
   * 构造函数
   */
  private constructor() {
  }

  /**
   * 获取LinkTextParser单例
   */
  public static getInstance(): LinkTextParser {
    if (LinkTextParser.linkTextParserInstance) {
      return LinkTextParser.linkTextParserInstance
    }
    LinkTextParser.linkTextParserInstance = new LinkTextParser();
    return LinkTextParser.linkTextParserInstance;
  }

  /**
   * 设置跳转信息
   * @param abilities
   */
  initAbilities(abilities: Map<string, Want>): void {
    this.abilities = abilities;
  }

  /**
   * 解析文本
   * @param textArr 待解析文本
   */
  parseText(textArr: Array<BaseText>): Array<BaseText> {
    if (ArrayUtil.isEmpty(textArr)) {
      return [];
    }
    let result: BaseText[] = [];
    for (let textItem of textArr) {
      // 当前仅BoldText
      if (!(textItem instanceof NormalText)) {
        result.push(textItem);
        continue;
      }
      let text: string = textItem.getText();
      let beginIndex: number = text.indexOf(FLAG_BEGIN);
      // instrument ignore next
      while (beginIndex !== NOT_FOUND) {
        if (beginIndex !== FIRST_ITEM) {
          result.push(new NormalText(text.substr(FIRST_ITEM, beginIndex)));
          text = text.substr(beginIndex, text.length);
        }
        let beginEndIndex = text.indexOf(FLAG_BEGIN_END);
        if (beginEndIndex === NOT_FOUND) {
          result.push(new NormalText(text));
          break;
        }
        let linkStr = this.parseLinkKey(text.substring(FIRST_ITEM, beginEndIndex + FLAG_BEGIN_END.length));
        LogUtil.info(`${TAG} linkStr is:${linkStr}`);
        text = text.substr(beginEndIndex + FLAG_BEGIN_END.length, text.length);
        let endIndex = text.indexOf(FLAG_END);
        if (endIndex === NOT_FOUND) {
          beginIndex = text.indexOf(FLAG_BEGIN);
          continue;
        }
        let linkTextStr = text.substr(FIRST_ITEM, endIndex);
        if (StringUtil.isNotEmpty(linkTextStr)) {
          let linkText = new LinkText(linkTextStr);
          if (this.abilities && this.abilities.has(linkStr)) {
            linkText.setWant(this.abilities.get(linkStr));
          }
          result.push(linkText);
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

  /**
   * 解析link的key
   * @param text
   */
  private parseLinkKey(text: string): string {
    let regex: RegExp = new RegExp('\\s*', 'g');
    text = text.replace(regex, '');
    let indexBegin = text.indexOf(LINK_KEY_BEGIN);
    /* instrument ignore file */
    if (indexBegin > FIRST_ITEM) {
      let indexEnd = text.indexOf(FLAG_BEGIN_END);
      if (indexEnd - indexBegin > LINK_KEY_BEGIN.length) {
        return text.substring(indexBegin + LINK_KEY_BEGIN.length, indexEnd - 1);
      } else {
        LogUtil.error(`${TAG} invalid indexEnd:${indexEnd} for ${text}}`);
      }
    } else {
      LogUtil.error(`${TAG} invalid indexBegin :${indexBegin}  for ${text}}`);
    }
    return '';
  }
}

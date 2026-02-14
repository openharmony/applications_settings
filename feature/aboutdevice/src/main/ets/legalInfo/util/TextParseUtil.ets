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

import { LogUtil } from '@ohos/settings.common/src/main/ets/utils/LogUtil';
import { ServiceEntity } from '../model/ServiceEntity';
import { BaseText, HtmlParser, IParser, LinkTextParser } from '../parser';

const TAG: string = 'TextParseUtil';

/**
 * 文本解析工具
 */
export class TextParseUtil {
  private textParserList: IParser[] = [];

  constructor() {
    this.textParserList.push(HtmlParser.getInstance());
    this.textParserList.push(LinkTextParser.getInstance());
  }

  /**
   * 添加解析器
   * @param iParser 解析器
   */
  public addParser(iParser: IParser) {
    this.textParserList.push(iParser);
  }

  /**
   * 清理解析器
   */
  public clearParser() {
    if (this.textParserList.length > 0) {
      this.textParserList = [];
    }
  }

  /**
   * 解析文本
   * @param serviceEntity 服务实体
   * @returns 解析结果
   */
  public parseText(serviceEntity: ServiceEntity): Array<BaseText> {
    let curResult: BaseText[] = [];
    let text: string = serviceEntity.getContent();
    if (!text) {
      LogUtil.warn(`${TAG} parseText is null!`);
      return curResult;
    }
    LogUtil.debug(`${TAG} serviceEntity parseText: ${text}`);
    this.textParserList.forEach((parser: IParser) => {
      if (parser instanceof HtmlParser) {
        HtmlParser.getInstance().init(text);
      }
      if (parser instanceof LinkTextParser) {
        LinkTextParser.getInstance().initAbilities(serviceEntity?.getAbilities());
      }
      curResult = parser.parseText(curResult);
    })
    return curResult;
  }
}
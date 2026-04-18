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

import xml from '@ohos.xml';
import util from '@ohos.util';
import { LogUtil } from '../utils/LogUtil';

const TAG = 'ParseXml';

export class SpanNodeInfo {
  content: string = '';
  textStyle: string = '';
}

export function ParseXml(src: string): SpanNodeInfo[] {
  const CONTENT_DEPTH = 2;
  let currentNode : SpanNodeInfo;
  let spanNodeArray : SpanNodeInfo[] = [];
  let onAttributeValue = (name: string, value: string): boolean => {
    if (name === 'style' && currentNode !== undefined) {
      currentNode.textStyle = value;
    }
    return true;
  };

  let onTokenValue = (eventType: xml.EventType, value: xml.ParseInfo): boolean => {
    if (value.getDepth() !== CONTENT_DEPTH) {
      return true;
    }
    switch (eventType) {
      case xml.EventType.START_TAG:
        currentNode = new SpanNodeInfo();
        break;
      case xml.EventType.TEXT:
        if (currentNode !== undefined) {
          currentNode.content = value.getText();
        }
        break;
      case xml.EventType.END_TAG:
        if (currentNode !== undefined) {
          spanNodeArray.push(currentNode);
        }
        break;
      default:
    }
    return true;
  };

  let parse = (src: string): void => {
    try {
      let textEncoder = new util.TextEncoder();
      let arrbuffer = textEncoder.encodeInto(src);
      let xmlParser = new xml.XmlPullParser(arrbuffer.buffer, 'UTF-8');
      let options: xml.ParseOptions = {
        supportDoctype: true,
        ignoreNameSpace: true,
        attributeValueCallbackFunction: onAttributeValue,
        tokenValueCallbackFunction: onTokenValue
      };
      xmlParser.parse(options);
    } catch (err) {
      LogUtil.error(`TAG, xml parse falied, reason: err code: ${err?.code}, err message: ${err?.message}`);
    }
  };

  parse(src);
  return spanNodeArray;
}
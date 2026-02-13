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

import { util } from '@kit.ArkTS';
import { JSON } from '@kit.ArkTS';
import buffer from '@ohos.buffer';
import { CheckEmptyUtils } from './CheckEmptyUtils';
import { LogUtil } from './LogUtil';

/**
 * 字符串工具类
 */
export class StringUtil {
  private static readonly DEFAULT_LEN_OF_COMMON_STR: number = 10;
  private static readonly HALF_LEN_OF_COMMON_STR: number = 5;
  private static readonly LINK_OF_COMMON_STR: string = '****';
  public static readonly EMPTY_STRING: string = '';

  /**
   * 判断字串是否是空字串
   * @param stringValue 字符串
   */
  public static isEmpty(stringValue: string | null | undefined): boolean {
    return stringValue === undefined || stringValue === null || stringValue.length === 0;
  }

  /**
   * 判断字串是否是非空字串
   * @param stringValue 字符串
   */
  public static isNotEmpty(stringValue: string | null | undefined): boolean {
    return stringValue !== undefined && stringValue !== null && stringValue.length !== 0;
  }

  /**
   * 检查页面参数是否相同
   *
   * @param targetPageParams target page params.
   * @param curPageParams current page params.
   * @returns true: same page
   */
  public static isSameParams(targetPageParams: string, curPageParams: string): boolean {
    /* instrument ignore if*/
    if (CheckEmptyUtils.checkStrIsEmpty(curPageParams)) {
      return CheckEmptyUtils.checkStrIsEmpty(targetPageParams);
    } else {
      let newParam = curPageParams.replace(',isShowBack:false', '');
      return newParam === targetPageParams || curPageParams === targetPageParams;
    }
  }

  /**
   * 将字符串转码为 Uint8Array
   *
   * @return Uint8Array
   */
  static stringToUint8Array(val: string): Uint8Array {
    if (CheckEmptyUtils.checkStrIsEmpty(val)) {
      return new Uint8Array([]);
    }
    let textEncoder = new util.TextEncoder();
    try {
      return textEncoder.encodeInto(val);
    } catch (error) {
      LogUtil.error(`stringToUint8Array error, ${error?.message}`);
    }
    return new Uint8Array([]);
  }

  /**
   * 通过json方法将 Uint8Array 转码为字符串
   *
   * @param val Uint8Array
   * @return 字符串
   */
  static uint8ArrayToStringByJson(val: Uint8Array): string {
    if (!val) {
      return '';
    }

    let arrNumber: number[] = [];
    for (const element of val) {
      arrNumber.push(element);
    }

    return JSON.stringify(arrNumber);
  }

  /**
   * 将base64转换的字符串转码为 Uint8Array
   *
   * @return Uint8Array
   */
  static base64StringToUint8Array(val: string): Uint8Array {
    if (CheckEmptyUtils.checkStrIsEmpty(val)) {
      return new Uint8Array([]);
    }
    let buf: buffer.Buffer = buffer.from(val, 'base64');
    return Uint8Array.from(buf.values());
  }

  /**
   * 将Uint8Array转换为base64字符串
   *
   * @return Uint8Array
   */
  static uint8ArrayToBase64String(array: Uint8Array): string {
    if (!array || array.length === 0) {
      return '';
    }
    return buffer.from(Array.from(array)).toString('base64');
  }

  /**
   * 从JSON中获取对应的数
   *
   * @return number
   */
  static getNumberFromJson(json: Uint8Array, key: string): number | undefined {
    let obj: Object = StringUtil.uint8ArrayToObject(json);
    if (obj === null || obj === undefined) {
      LogUtil.error(`obj is null or undefined`);
      return undefined;
    }
    if (key in obj) {
      return obj[key];
    }
    LogUtil.error(`key is not in parsed object`);
    return undefined;
  }

  /**
   * 将Uint8Array转换成Object对象
   *
   * @return number
   */
  static uint8ArrayToObject(array: Uint8Array): Object {
    if (!array) {
      LogUtil.error('array is not valid');
      return {};
    }

    try {
      let str = String.fromCharCode.apply(null, array);
      let obj = JSON.parse(str);
      return obj;
    } catch (err) {
      LogUtil.error(`uint8ArrayToObject failed. err code: ${err?.code}, err message:${err?.message}`);
      return {};
    }
  }

  /**
   * 通过TextEncoder方法将字符串转码为 Uint8Array
   *
   * @param val 待转换字符串
   * @return Uint8Array 字串对应的Uint8Array
   */
  static stringToUint8ArrayTextEncoder(val: string): Uint8Array {
    if (!val) {
      return new Uint8Array([]);
    }
    let textEncoder = new util.TextEncoder();
    try {
      return textEncoder.encodeInto(val);
    } catch (error) {
      LogUtil.error(`stringToUint8Array error, ${error?.message}`);
    }
    return new Uint8Array([]);
  }
  /**
   * 将uint8Array转换成Json
   * @param extraInfo
   * @returns
   */
  static uint8ArrayToJson(extraInfo: Uint8Array): object {
    try {
      let str: string = String.fromCharCode.apply(null, extraInfo);
      if (CheckEmptyUtils.isEmpty(str)) {
        return null;
      }
      let jsonObject = JSON.parse(str);
      return jsonObject;
    } catch (error) {
      LogUtil.error(`uint8ArrayToJson error code is ${error?.code}`);
      return null;
    }
  }

  /**
   * 获得字符串的字符数
   * @param value 字符串
   * @returns  字符数
   */
  static getStringLength(value: string): number {
    if (value === undefined || value === null) {
      return 0;
    }

    return buffer.from(value, 'utf8')?.length;
  }

  /**
   * get anonymization string
   *
   * @param {string} originStr - string
   * @return {string} - anonymization string
   */
  public static anonymizeString(originStr: string): string {
    if (!originStr) {
      return originStr;
    }
    if (originStr.length <= this.DEFAULT_LEN_OF_COMMON_STR) {
      return originStr;
    }
    return originStr.substring(0, this.HALF_LEN_OF_COMMON_STR) + this.LINK_OF_COMMON_STR +
      originStr.substring(originStr.length - this.HALF_LEN_OF_COMMON_STR);
  }

  /**
   * 使用反斜杠转义的特殊字符 "\", ";", ":", ","
   */
  static escapeSpecialCharacters(str: string): string {
    if (CheckEmptyUtils.checkStrIsEmpty(str)) {
      LogUtil.error('escapeSpecialCharacters : str is empty');
      return str;
    }
    let temp: string = '';
    for (let index = 0; index < str.length; index++) {
      let char: string = str[index];
      if (char === '\\' || char === ',' || char === ';' || char === ':') {
        temp = temp.concat('\\');
      }
      temp = temp.concat(char);
    }
    return temp;
  }

  /**
   * 获取字串的前size个字节子串
   *
   * @param value 字串
   * @param size 字节数
   * @returns 前size字节子串
   */
  public static getSubstringByBytes(value: string, size: number): string {
    if (!value || StringUtil.getStringLength(value) <= size) {
      return value;
    }

    let tempString: string = '';
    let result: string = '';
    for (let index = 0; index < value.length; index++) {
      tempString = tempString + value[index];
      if (StringUtil.isFourBytesChar(value, index)) {
        index++;
        tempString = tempString + value[index];
      }
      if (StringUtil.getStringLength(tempString) <= size) {
        result = tempString;
      } else {
        return result;
      }
    }
    return result;
  }

  private static isFourBytesChar(value: string, index: number): boolean {
    if (!value) {
      return false;
    }
    let code: number | undefined = value.codePointAt(index);
    if (code == undefined) {
      return false;
    }
    return code > 0xFFFF ? true : false;
  }
}
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

import { Context } from '@kit.AbilityKit';
import { BusinessError } from '@ohos.base';
import i18n from '@ohos.i18n';
import intl from '@ohos.intl';
import { AbilityContextManager } from '../ability/AbilityContextManager';
import { LogUtil } from './LogUtil';
import { ThreadUtils } from './ThreadUtils';

const TAG = 'ResourceUtil'

/**
 * 资源工具类
 */
export class ResourceUtil {
  /**
   * 获取string资源值
   *
   * @param resource Resource资源类
   */
  static async getString(resource: Resource): Promise<string> {
    if (!resource) {
      LogUtil.error(`${TAG} getString error, resource is invalid`);
      return '';
    }
    let resourceManager = ResourceUtil.getContext()?.resourceManager;
    if (!resourceManager) {
      LogUtil.warn(`${TAG} resourceManager is null`);
      return '';
    }
    return await resourceManager.getString(resource.id);
  }

  /**
   * 获取大写的string值
   *
   * @param resource Resource资源类
   */
  static async getCapitalString(resource: ResourceStr): Promise<string> {
    if (!resource) {
      return '';
    }
    if (typeof resource === 'string') {
      return resource;
    }
    let result = await ResourceUtil.getString(resource);
    return result;
  }

  /**
   * 获取string资源值并格式化
   *
   * @param resource Resource资源类
   * @param subStr 格式替换子串(%s)
   */
  static async getFormatString(resource: Resource, subStr: string): Promise<string> {
    let result = await ResourceUtil.getString(resource);
    return result.replace(new RegExp('%s', 'gm'), subStr);
  }

  /**
   * 获取string资源值并格式化
   *
   * @param resource Resource资源类
   * @param subStr 格式替换子串(%s)
   */
  static getFormatStringSync(resource: Resource, subStr: string): string {
    let result = ResourceUtil.getStringSync(resource);
    return result.replace(new RegExp('%s', 'gm'), subStr);
  }

  /**
   * 获取string资源值并格式化
   *
   * @param resource Resource资源类
   * @param subStr 格式替换子串(%s)
   */
  static getFormatStringByNameSync(resource: string, subStr: string): string {
    let result: string = ResourceUtil.getStringByName(resource);
    return result.replace(new RegExp('%s', 'gm'), subStr);
  }

  /**
   * number类型替换
   *
   * @param subStr 格式替换子串(%d)
   */
  static async getNumberFormatString(resource: Resource, subStr: string): Promise<string> {
    let result = await ResourceUtil.getString(resource);
    if (!result) {
      return '';
    }
    return result.replace(new RegExp('%d', 'gm'), subStr);
  }

  /**
   * number类型替换
   *
   * @param subStr 格式替换子串(%d)
   */
  static getNumberFormatStringSync(resource: Resource, subStr: string): string {
    let result = ResourceUtil.getStringSync(resource);
    if (!result) {
      return '';
    }
    return result.replace(new RegExp('%d', 'gm'), subStr);
  }

  /**
   * number类型替换
   *
   * @param subStr 格式替换子串(%d)
   */
  static getNumberFormatStringByName(stringName: string, subStr: string): string {
    let result: string = ResourceUtil.getStringByName(stringName);
    if (!result) {
      return '';
    }
    return result.replace(new RegExp('%d', 'gm'), subStr);
  }

  /**
   * 任意数量替换
   *
   * @param resource Resource资源类
   * @param ...subStrs 任意数量替换子串
   */
  static async getAnyFormatString(resource: Resource, ...subStrs: Array<string>): Promise<string> {
    let result = await ResourceUtil.getString(resource);
    if (!result) {
      return '';
    }
    return ResourceUtil.replaceAnyFormatString(result, subStrs);
  }

  static replaceAnyFormatString(result: string, subStrs: string[]): string {
    for (let i = 0; i < subStrs.length; i++) {
      result = result.replace(new RegExp('%' + (i + 1) + '\\$s', 'gm'), subStrs[i]);
      result = result.replace(new RegExp('%' + (i + 1) + '\\$d', 'gm'), subStrs[i]);
    }
    return result;
  }

  /**
   * 任意数量string类型替换
   *
   * @param resource Resource资源类
   * @param ...subStrs 任意数量替换子串
   */
  static async getAnyStrFormatString(resource: Resource, ...subStrs: Array<string>): Promise<string> {
    let result = await ResourceUtil.getString(resource);
    if (!result) {
      return '';
    }
    for (let i = 0; i < subStrs.length; i++) {
      result = result.replace(new RegExp('%' + (i + 1) + '\\$s', 'gm'), subStrs[i]);
    }
    return result;
  }

  /**
   * 任意数量number类型替换
   *
   * @param resource Resource资源类
   * @param ...numbers 任意数量替换数字
   */
  static async getAnyNumFormatString(resource: Resource, ...numbers: Array<number>): Promise<string> {
    let result = await ResourceUtil.getString(resource);
    if (!result) {
      return '';
    }
    for (let i: number = 0; i < numbers.length; i++) {
      result = result.replace(new RegExp('%' + (i + 1) + '\\$d', 'gm'), String(numbers[i]));
    }
    return result;
  }

  /**
   * 以同步方式获取string资源值
   *
   * @param resource Resource资源类
   * @param context Context 上下文
   */
  static getStringSync(resource: ResourceStr | undefined, context?: Context): string {
    let resourceString: string = '';
    if (!resource) {
      return resourceString;
    }
    if (typeof resource === 'string') {
      return resource;
    }
    let resourceManager = (context ?? ResourceUtil.getContext())?.resourceManager;
    if (!resourceManager) {
      return resourceString;
    }
    try {
      resourceString = resourceManager.getStringSync(resource.id);
    } catch (err) {
      LogUtil.error(`${TAG} getStringSync error, BusinessError code is ${(err as BusinessError).code}`);
    }
    return resourceString;
  }

  /**
   * 以同步方式并传入数据的方式获取string资源值
   *
   * @param resource Resource资源类
   * @param data string 传入的数据
   * @param context Context 上下文
   */
  static getStringSyncWithData(resource: ResourceStr | undefined, data: string, context?: Context): string {
    let resourceString: string = '';
    if (!resource) {
      return resourceString;
    }
    if (typeof resource === 'string') {
      return resource;
    }
    let resourceManager = (context ?? ResourceUtil.getContext())?.resourceManager;
    if (!resourceManager) {
      return resourceString;
    }
    try {
      resourceString = resourceManager.getStringSync(resource.id, data);
    } catch (err) {
      LogUtil.error(`${TAG} getStringSyncWithData error, code: ${err?.code}, msg: ${err?.message}`);
    }
    return resourceString;
  }

  static getPixelMap(resName: string, density?: number, type?: number): PixelMap | undefined {
    let resourceManager = ResourceUtil.getContext()?.resourceManager;
    if (!resourceManager) {
      return undefined;
    }
    let pixelMap: PixelMap | undefined;
    try {
      pixelMap = resourceManager.getDrawableDescriptorByName(resName, density, type).getPixelMap();
    } catch (err) {
      LogUtil.error(`${TAG} getDrawableDescriptor failed, code is ${err?.code}, msg is ${err?.message} resName: ${resName}`);
    }
    return pixelMap;
  }

  /**
   * 以同步方式获取color资源值
   *
   * @param resource Resource资源类
   */
  static getColorSync(resource: Resource | undefined): number | undefined {
    let resourceColor: number | undefined = undefined;
    if (!resource) {
      return resourceColor;
    }
    let resourceManager = ResourceUtil.getContext()?.resourceManager;
    if (!resourceManager) {
      return resourceColor;
    }
    try {
      resourceColor = resourceManager.getColorSync(resource.id);
    } catch (err) {
      LogUtil.error(`${TAG} getColorSync error, BusinessError code is ${(err as BusinessError).code}`);
    }
    return resourceColor;
  }

  static getStringByName(stringName: string) {
    try {
      let resourceManager = ResourceUtil.getContext()?.resourceManager;
      let LINK_STRING_FLAG: string = '$string:';
      let name = stringName.replace(LINK_STRING_FLAG, '');
      return resourceManager.getStringByNameSync(name);
    } catch (error) {
      let code = (error as BusinessError).code;
      let message = (error as BusinessError).message;
      LogUtil.error(`${TAG} getStringByName failed, error code: ${code}, message: ${message}.`);
      return '';
    }
  }

  static getFormatStringByName(resource: string, ...subStrs: Array<string>): string {
    let result = ResourceUtil.getStringByName(resource);
    if (!result) {
      return '';
    }
    for (let i = 0; i < subStrs.length; i++) {
      result = result.replace(new RegExp('%' + (i + 1) + '\\$s', 'gm'), subStrs[i]);
    }
    return result;
  }

  static getWindowsStringSync(resource: ResourceStr | undefined): string {
    if (!resource) {
      return '';
    }
    if (typeof resource === 'string') {
      return resource;
    }

    let resourceManager = AbilityContextManager.getContext()?.resourceManager;
    if (!resourceManager) {
      return '';
    }
    return resourceManager.getStringSync(resource.id);
  }

  static windowGetAnyStrFormatStringSync(resource: Resource, ...subStrs: Array<string>): string {
    let result = ResourceUtil.getWindowsStringSync(resource);
    if (!result) {
      return '';
    }
    for (let i = 0; i < subStrs.length; i++) {
      result = result.replace(new RegExp('%' + (i + 1) + '\\$s', 'gm'), subStrs[i]);
    }
    return result;
  }

  static getSystemLanguage(): string {
    let locale = new intl.Locale(i18n.System.getSystemLanguage());
    return locale.toString();
  }

  /**
   * 同步方式任意数量string类型替换
   *
   * @param resource Resource资源类
   * @param ...subStrs 任意数量替换子串
   */
  static getAnyStrFormatStringSync(resource: Resource, ...subStrs: Array<string>): string {
    let result = ResourceUtil.getStringSync(resource);
    if (!result) {
      return '';
    }
    for (let i = 0; i < subStrs.length; i++) {
      result = result.replace(new RegExp('%' + (i + 1) + '\\$s', 'gm'), subStrs[i]);
    }
    return result;
  }

  /**
   * 同步方式任意数量string类型替换
   *
   * @param stringName Resource资源id
   * @param ...subStrs 任意数量替换子串
   */
  static getAnyStrFormatStringByName(stringName: string, ...subStrs: Array<string>): string {
    let result: ResourceStr | undefined = ResourceUtil.getStringByName(stringName);
    if (!result) {
      return '';
    }
    for (let i = 0; i < subStrs.length; i++) {
      result = result.replace(new RegExp('%' + (i + 1) + '\\$s', 'gm'), subStrs[i]);
    }
    return result;
  }

  /**
   * 同步方式任意数量string类型替换
   *
   * @param resource Resource资源类
   * @param ...numbers 任意数量替换数字
   */
  static getAnyNumFormatStringSync(resource: Resource, ...numbers: Array<number>): string {
    let result = ResourceUtil.getStringSync(resource);
    if (!result) {
      return '';
    }
    for (let i: number = 0; i < numbers.length; i++) {
      result = result.replace(new RegExp('%' + (i + 1) + '\\$d', 'gm'), String(numbers[i]));
    }
    return result;
  }

  /**
   * 同步方式获取大写的string值
   *
   * @param resource Resource资源类
   */
  static getCapitalStringSync(resource: ResourceStr): string {
    if (!resource) {
      return '';
    }
    if (typeof resource === 'string') {
      return resource;
    }
    let result = ResourceUtil.getStringSync(resource);
    return result;
  }

  /**
   * 根据指定数量获取指定resource对象表示的单复数字符串，使用同步方式返回全大写的字符串。
   *
   * @param resource Resource资源类
   */
  static getCapitalPluralStringValueSync(resource: Resource, num: number): string {
    if (!resource) {
      return '';
    }
    try {
      let resourceManager = ResourceUtil.getContext()?.resourceManager;
      return resourceManager.getPluralStringValueSync(resource, num);
    } catch (error) {
      let code = (error as BusinessError).code;
      let message = (error as BusinessError).message;
      LogUtil.error(`getPluralStringValueSync failed, error code: ${code}, message: ${message}.`);
      return '';
    }
  }

  /**
   * 根据指定数量获取指定resource对象表示的单复数字符串，使用同步方式返回字符串。
   *
   * @param resource Resource资源类
   */
  static getPluralStringValueSync(resource: Resource, num: number): string {
    if (!resource) {
      return '';
    }
    try {
      let resourceManager = ResourceUtil.getContext()?.resourceManager;
      return resourceManager.getPluralStringValueSync(resource, num);
    } catch (error) {
      let code = (error as BusinessError).code;
      let message = (error as BusinessError).message;
      LogUtil.error(`getPluralStringValueSync failed, error code: ${code}, message: ${message}.`);
      return '';
    }
  }

  /**
   * 根据指定数量获取指定resource对象表示的单复数字符串，使用同步方式返回字符串。
   * 后续建议都使用该方法，上方旧方法getPluralStringValueSync未使用resource的id，耗时会很长，不建议使用
   *
   * @param resource Resource资源类
   * @param num 复数值
   *
   * @returns 复数字符串
   */
  static getPluralStringValueSyncById(resource: Resource, num: number): string {
    if (!resource) {
      LogUtil.error(`getPluralStringValueSyncById invalid resource.`);
      return '';
    }
    try {
      let resourceManager = ResourceUtil.getContext()?.resourceManager;
      if (resourceManager) {
        return resourceManager.getPluralStringValueSync(resource.id, num);
      }
    } catch (error) {
      LogUtil.error(`getPluralStringValueSyncById failed, error code: ${error?.code}, message: ${error?.message}.`);
    }
    LogUtil.error(`getPluralStringValueSyncById return default empty.`);
    return '';
  }

  /**
   * 根据指定数量获取指定resource对象表示的单复数字符串，使用同步方式返回字符串。
   *
   * @param resource Resource资源类
   */
  static getPluralStringByNameSync(resName: string, num: number): string {
    try {
      let resourceManager = ResourceUtil.getContext()?.resourceManager;
      return resourceManager.getPluralStringByNameSync(resName, num);
    } catch (err) {
      LogUtil.error(`getPluralStringValueSync failed, error code: ${err?.code}, message: ${err?.message}`);
      return '';
    }
  }

  static getContext(): Context {
    if (!ThreadUtils.isMainThread()) {
      return AbilityContextManager.getSubThreadContext();
    }
    return AbilityContextManager.getStageContext();
  }

  /**
   * 国际化数字接口
   *
   * @param num 需要国际化数字的值
   * @returns 返回国际化数字的值
   */
  static getLocalNumberFormat(num: number): string {
    let value: string = '';
    try {
      let curLocale: string = i18n.System.getSystemLocale();
      value = new Intl.NumberFormat(curLocale).format(num);
    } catch (err) {
      LogUtil.error(`${TAG} getLocalNumberFormat: error: ${err?.message} code: ${err?.code}`);
    }
    return value;
  }

  /**
   * 国际化日期接口
   *
   * @param date 需要国际化的日期
   * @returns 返回国际化后的日期
   */
  static getLocalDataFormat(date: string) : string{
    let options : Intl.DateTimeFormatOptions = {
      year: 'numeric',
      month: 'long',
      day: 'numeric',
    };
    let value: string = '';
    try {
      let parseDate: number = Date.parse(date);
      let curLocale: string = i18n.System.getSystemLocale();
      value = new Intl.DateTimeFormat(curLocale, options).format(parseDate)
    } catch (err) {
      LogUtil.error(`${TAG} getLocalDataFormat: error: ${err?.message} code: ${err?.code}`);
    }
    return value;
  }
}
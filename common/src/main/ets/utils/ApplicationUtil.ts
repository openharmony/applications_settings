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

import { i18n } from '@kit.LocalizationKit';
import { bundleManager, common, Context, dialogRequest, Want } from '@kit.AbilityKit';
import { CheckEmptyUtils } from './CheckEmptyUtils';
import { LogUtil } from './LogUtil';
import { AbilityContextManager } from '../ability/AbilityContextManager';

const TAG: string = 'ApplicationUtil :';

export const HIGHLIGHT_DEFAULT_INDEX: number = -1;

/**
 * 首页通过拼音搜索元服务时记录拼音对应的索引位置
 */
export interface HighlightIndex {
  startIndex: number,
  endIndex: number
}

/**
 * 匹配搜索词方法
 *
 * @param name 待匹配的字符串
 * @param keyWord 搜索关键词
 * @param highlightIndex 记录匹配到的关键词索引位置
 * @returns 关键词能匹配上名称返回 true, 否则返回 false
 */
export function isMatchKeyWord(name: string, keyWord: string, highlightIndex?: HighlightIndex): boolean {
  if (CheckEmptyUtils.checkStrIsEmpty(name) || CheckEmptyUtils.checkStrIsEmpty(keyWord)) {
    LogUtil.showWarn(TAG, `name: ${name} or keyWord: ${keyWord} is empty`);
    return false;
  }
  let pinyin = i18n.Transliterator.getInstance('Any-Latn; Latin-ASCII')
    .transform(name);
  // 去除关键词的所有空格
  keyWord = keyWord.replace(/\s+/g, '');
  return name.toLowerCase().includes(keyWord.toLowerCase()) || matchPinyin(pinyin, keyWord, highlightIndex);
}

/**
 * 当输入的关键词是拼音时，匹配对应的中文
 *
 * @param name 待匹配的名称
 * @param keyWord 关键词
 * @param highlightIndex 记录匹配到的关键词索引位置
 * @returns boolean, 能匹配成功返回 true
 */
function matchPinyin(name: string, keyWord: string, highlightIndex?: HighlightIndex): boolean {
  if (CheckEmptyUtils.checkStrIsEmpty(name) || CheckEmptyUtils.checkStrIsEmpty(keyWord)) {
    LogUtil.showWarn(TAG, `matchPinyin name: ${name} or keyWord: ${keyWord} is empty`);
    return false;
  }
  // 拆分 name 为拼音数组并过滤空字符串
  const nameArr: string[] = name.split(' ').filter(s => s.length > 0);
  const nLength: number = nameArr.length;
  // 预处理每个拼音的长度
  const lengths: number[] = nameArr.map(s => s.length);
  // 判断总长度是否不足，提前返回 false
  const totalLength = lengths.reduce((acc, len) => acc + len, 0);
  if (totalLength < keyWord.length) {
    LogUtil.showWarn(TAG, `totalLength: ${totalLength}, keyLength: ${keyWord.length}`);
    return false;
  }
  // 滑动窗口寻找目标长度的拼接
  let left: number = 0;
  let currentLength: number = 0;
  for (let right: number = 0; right < nLength; right++) {
    currentLength += lengths[right];
    // 如果当前窗口和超过目标长度，则收缩左侧
    while (currentLength > keyWord.length && left < nLength) {
      currentLength -= lengths[left];
      left++;
    }
    if (currentLength !== keyWord.length) {
      continue;
    }
    // 如果窗口长度正好等于目标，拼接判断字符串
    let concatenated: string = '';
    for (let i: number = left; i <= right; i++) {
      concatenated += nameArr[i];
    }
    if (concatenated.toLowerCase() === keyWord.toLowerCase()) {
      if (highlightIndex) {
        highlightIndex.startIndex = left;
        highlightIndex.endIndex = right;
      }
      return true;
    }
  }
  // 未匹配到
  return false;
}

/**
 * 在待匹配的字符串中对搜索关键词进行特殊处理,用于首页搜索结果关键字标蓝处理
 *
 * @param name 待匹配的字符串
 * @param key 搜索关键词
 * @param highlightIndex 记录匹配到的关键词索引位置
 * @returns 处理后的搜索结果名称
 */
export function highLightKeyWord(name: string, key: string, highlightIndex: HighlightIndex): string[] {
  if (CheckEmptyUtils.checkStrIsEmpty(name) || CheckEmptyUtils.checkStrIsEmpty(key)) {
    LogUtil.showWarn(TAG, `highLightKeyWord name: ${name} or keyWord: ${key} is empty`);
    return [];
  }
  LogUtil.showInfo(TAG, `name: ${name}, key: ${key}, index: ${highlightIndex.startIndex}-${highlightIndex.endIndex}`);
  // 通过拼音搜索成功的,高亮时需要将拼音转换成中文进行高亮展示
  if (highlightIndex.startIndex > HIGHLIGHT_DEFAULT_INDEX && highlightIndex.endIndex < name.length) {
    key = name.substring(highlightIndex.startIndex, highlightIndex.endIndex + 1);
  }
  const escapedKeyword: string = escapeRegExp(key);
  const regex: RegExp = new RegExp(escapedKeyword, 'gi');
  const dealName: string = name.replace(regex, (match) => {
    return match.split('').map(charName => `<em>${charName}</em>`).join('');
  });
  return dealName.split(new RegExp(`<|>`, 'gi'));
}

/**
 * 特殊字符串转义
 *
 * @param value 原始字符串
 * @returns 转义后的字符串
 */
function escapeRegExp(value: string): string {
  if (CheckEmptyUtils.checkStrIsEmpty(value)) {
    LogUtil.showWarn(TAG, `escapeRegExp value is empty`);
    return '';
  }
  // 特殊字符转义
  return value.replace(/[.*+?^${}()|[\]\\]/g, '\\$&');
}

export const CODE_RECOVERY_FAILED: number = -999999;

export const CODE_RECOVERY_SUCCESS: number = 1;

export const CODE_RECOVERY_CANCELED: number = 0;

/**
 * 应用工具类
 *
 * @since 2025-07-12
 */
export class ApplicationUtil {
  /**
   * 应用是否可访问
   *
   * @param bundleName 应用bundleName
   * @returns 应用是否可访问
   */
  public static isApplicationAvailable(bundleName: string): boolean {
    try {
      bundleManager.getBundleInfoSync(bundleName, bundleManager.BundleFlag.GET_BUNDLE_INFO_DEFAULT);
      return true;
    } catch (err) {
      LogUtil.error(`${TAG} get ${bundleName} bundleInfo failed: ${err?.message}`);
    }
    return false;
  }

  /**
   * 请求恢复应用
   *
   * @param bundleName 应用bundleName
   * @returns 恢复应用结果 CODE_RECOVERY_FAILED: 恢复失败  CODE_RECOVERY_SUCCESS：恢复成功 CODE_RECOVERY_CANCELED：取消恢复
   */
  public static async requestRecoveryApplication(bundleName: string): Promise<number> {
    try {
      let want: Want = {
        bundleName: 'com.ohos.restores',
        abilityName: 'RestoresDialogServiceAbility',
        parameters: {
          restoresBundleName: bundleName,
        }
      };
      let context: common.UIAbilityContext = AbilityContextManager.getMainAbilityContext() as common.UIAbilityContext;
      if (context === undefined) {
        LogUtil.warn(`${TAG} settingsAbilityContext is undefined`);
        context = AppStorage.get<Context>('pageContext') as common.UIAbilityContext;
      }
      let result: dialogRequest.RequestResult = await context.requestDialogService(want);
      LogUtil.info(`${TAG} requestDialogService succeed, result = ${result?.want?.parameters?.resultCode ?? ''}`);
      return (result?.want?.parameters?.resultCode as number) ?? CODE_RECOVERY_FAILED;
    } catch (err) {
      LogUtil.error(`${TAG} handleRequestDialogService failed: ${err?.message}`);
    }
    return CODE_RECOVERY_FAILED;
  }
}
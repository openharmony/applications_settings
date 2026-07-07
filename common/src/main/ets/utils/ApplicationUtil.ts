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

import { bundleManager, common, Context, dialogRequest, Want } from '@kit.AbilityKit';
import { CheckEmptyUtils } from './CheckEmptyUtils';
import { LogUtil } from './LogUtil';
import { AbilityContextManager } from '../ability/AbilityContextManager';

const TAG: string = 'ApplicationUtil :';

export const HIGHLIGHT_DEFAULT_INDEX: number = -1;

/**
 * 记录匹配到的关键词在原文中的索引位置，用于高亮
 */
export interface HighlightIndex {
  startIndex: number;
  endIndex: number;
}

/**
 * 匹配搜索词方法（仅原文子串匹配，不支持拼音/英文转写匹配）
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
  keyWord = keyWord.replace(/\s+/g, '');
  const idx = name.toLowerCase().indexOf(keyWord.toLowerCase());
  if (idx >= 0 && highlightIndex) {
    highlightIndex.startIndex = idx;
    highlightIndex.endIndex = idx + keyWord.length - 1;
  }
  return idx >= 0;
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
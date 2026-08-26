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
import { SuggestionInfo } from '../model/SuggestionInfo';

@Sendable
export class SuggestionController {
  public QUERY_SUGGESTION_TIMEOUT: number = 1500;
  public bundleName: string = '';
  public isKeepConnect: boolean = false;
  public tag: string = 'SuggestionController';

  /**
   * 获取推荐列表（含超时机制）
   *
   * @param context 上下文
   * @returns 推荐列表
   */
  async getSuggestionList(context: Context): Promise<SuggestionInfo[]> {
    let isQueryDataSuccess = false;
    let promise: Promise<SuggestionInfo[]> = new Promise((resolve: Function, reject: Function) => {
      let startTime = new Date().getTime();
      this.getSuggestionListAsync(context).then(suggestionInfoList => {
        resolve(suggestionInfoList);
        LogUtil.info(`${this.tag} getSuggestionList finish, cost ${new Date().getTime() - startTime}`);
        isQueryDataSuccess = true;
      });
    });
    let timeOutPromise: Promise<Array<SuggestionInfo>> = new Promise((resolve: Function, reject: Function) => {
      setTimeout(() => {
        if (!isQueryDataSuccess) {
          LogUtil.warn(`${this.tag} query suggestion timeout`);
        }
        resolve([]);
      }, this.QUERY_SUGGESTION_TIMEOUT);
    })
    return Promise.race([promise, timeOutPromise]);
  }

  /**
   * 获取推荐列表
   *
   * @param context 上下文
   * @returns 推荐列表
   */
  async getSuggestionListAsync(context: Context): Promise<SuggestionInfo[]> {
    return [];
  }

  /**
   * 点击推荐卡片
   *
   * @param suggestion 推荐信息
   * @param context 上下文
   */
  async clickSuggestion(suggestion: SuggestionInfo, context: Context): Promise<void> {
  }

  /**
   * 初始化
   *
   * @param context 上下文
   */
  async init(context: Context): Promise<void> {
  }

  /**
   * 销毁
   *
   * @param context 上下文
   */
  async destroy(context: Context): Promise<void> {
  }
}
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

import display from '@ohos.display';
import { LogUtil } from '@ohos/settings.common/src/main/ets/utils/LogUtil';

const TAG: string = 'IntelligentSceneDisplayUtil: ';
export const FOLD_TOOLBAR_HEIGHT: number = 84;
export const EXPEND_TOOLBAR_HEIGHT: number = 66;
export const FULL_DISPLAY_MODE: number = 5;
export const FOLD_PADDING_BOTTOM: number = 54;
export const EXPEND_PADDING_BOTTOM: number = 72;
export const SYSTEM_TOOLBAR_HEIGHT: number = px2vp(91);

/**
 * 情景模式显示处理类
 */
export class IntelligentSceneDisplayUtil {
  /**
   * 注册折叠显示状态监听
   *
   * @param callback 监听回调
   */
  public static registerFoldStatusChangeListener(callback: (foldStatus: display.FoldDisplayMode) => void): void {
    try {
      display.on('foldDisplayModeChange', callback);
    } catch (e) {
      LogUtil.error(`${TAG} on foldDisplayModeChange error error.code ${e?.code} error.message ${e?.message}`);
    }
  }

  /**
   * 解注册折叠显示状态监听
   *
   * @param callback 监听回调
   */
  public static unRegisterFoldStatusChangeListener(callback: (foldStatus: display.FoldDisplayMode) => void): void {
    try {
      display.off('foldDisplayModeChange', callback);
      LogUtil.info(`${TAG} off foldDisplayModeChange success`);
    } catch (e) {
      LogUtil.error(`${TAG} off foldDisplayModeChange error`);
    }
  }
}

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

// @ts-nocheck
import lazy { default as apsManager } from '@hms.graphic.apsManager';
import { LogUtil } from '@ohos/settings.common/src/main/ets/utils/LogUtil';

const TAG = 'ResolutionHelper';

const SMART_RESOLUTION_ON = 0;

const SMART_RESOLUTION_OFF = 1;

const ILLEGAL_STATE = -1;

/**
 * 分辨率辅助类
 */
export class ResolutionHelper {
  static async changeSmartResolution(isCheck: boolean): Promise<void> {
    LogUtil.info(`${TAG} + changeSmartResolution mode: isCheck = ${isCheck}`);
    try {
      return apsManager.enableSmartResolution(isCheck ? SMART_RESOLUTION_ON : SMART_RESOLUTION_OFF);
    } catch (error) {
      LogUtil.info(`${TAG} changeSmartResolution error ${error?.message}`);
      return ILLEGAL_STATE;
    }
  }

  static async changeScreenResolutionMode(state: string): Promise<number> {
    try {
      LogUtil.info(`${TAG} changeScreenResolutionMode state ${state}`);
      return apsManager.changeResolutionMode(Number(state), 1);
    } catch (error) {
      LogUtil.info(`${TAG} changeScreenResolutionMode error ${error?.message}`);
    }
    return ILLEGAL_STATE;
  }
}
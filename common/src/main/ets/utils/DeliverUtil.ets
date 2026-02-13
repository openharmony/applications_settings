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

import systemParameterEnhance from '@ohos.systemParameterEnhance';
import { LogUtil } from './LogUtil';

const TAG: string = 'DeliverUtil : ';
const DEFAULT_ERROR_CODE: string = '-1';
const KEY_NOT_FOUND_ERROR_CODE = 14700101;

export class DeliverUtil {
  public static DELIVER_START_FINISHED_CODE: string = '1000';

  static getDeliverStartStatus(): string {
    let paramStartVirtService: string = DEFAULT_ERROR_CODE;
    try {
      paramStartVirtService = systemParameterEnhance.getSync('hmos_fusion_mgr.container.start.phase', '');
    } catch (error) {
      LogUtil.showError(TAG, `get systemParameterEnhance error ${error?.code}, ${error?.message}`);
      if (error.code !== KEY_NOT_FOUND_ERROR_CODE) {
        paramStartVirtService = DeliverUtil.DELIVER_START_FINISHED_CODE;
      }
    }
    LogUtil.showInfo(TAG, `get getDeliverStartStatus ${paramStartVirtService}`);
    return paramStartVirtService;
  }
}
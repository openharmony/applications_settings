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

import { AbilityContextManager } from '../../ability/AbilityContextManager';
import { CheckEmptyUtils } from '../CheckEmptyUtils';
import { LogUtil } from '../LogUtil';
import { ThreadUtils } from '../ThreadUtils';

const TAG: string = 'ContextUtils';

export class ContextUtils {
  static getContext(): Context {
    let context: Context = AbilityContextManager.getMainAbilityContext();
    if (CheckEmptyUtils.isEmpty(context)) {
      LogUtil.info(`${TAG}, mainbilityContext is null, get serviceExtensionContext`);
      context = AbilityContextManager.getExtContext();
    }
    if (CheckEmptyUtils.isEmpty(context)) {
      LogUtil.info(`${TAG}, serviceExtensionContext is null, get stageContext`);
      context = AbilityContextManager.getStageContext();
    }
    if (CheckEmptyUtils.isEmpty(context) && !ThreadUtils.isMainThread()) {
      return AbilityContextManager.getSubThreadContext();
    }
    return context;
  }
}
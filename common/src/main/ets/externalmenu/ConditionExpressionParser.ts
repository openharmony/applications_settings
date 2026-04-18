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

import { LogUtil } from '../utils/LogUtil';
import { PackagesConstant } from '../constant/PackagesConstant';
import { AppVersionCondition, DeviceTypeCondition, SettingsDataCondition, OsAccountTypeCondition } from './Condition';
import type { Condition } from './Condition';
import { BooleanExpressionParser } from './BooleanExpressionParser';

const IS_DEBUG = false;

const SETTINGS_VERSION = 'settings_version';

const DEVICE_TYPE = 'device_type';

const SETTINGS_DATA = 'settings.';

const OS_ACCOUNT_TYPE = 'os_account_type';

const TAG = 'ConditionExpressionParser : ';

const MAX_SINGLE_EXPRESSION_LENGTH = 200;

const CONDITIONS: Map<string, Condition> = new Map([
  [SETTINGS_VERSION, new AppVersionCondition().setBundleName(PackagesConstant.SETTINGS_BUNDLE_NAME)],
  [DEVICE_TYPE, new DeviceTypeCondition()],
  [SETTINGS_DATA, new SettingsDataCondition()],
  [OS_ACCOUNT_TYPE, new OsAccountTypeCondition()],
]);

/**
 * 条件表达式解析器
 *
 * @since 2022-06-29
 */
export class ConditionExpressionParser extends BooleanExpressionParser {
  constructor(expression: string) {
    super(expression);
  }

  private getConditions(): Map<string, Condition> {
    return CONDITIONS;
  }

  protected async isSingleExpressionMatch(expression: string): Promise<boolean> {
    if (!expression) {
      LogUtil.error(`${TAG} Single expression empty!`);
      throw new Error('invalid');
    }

    if (expression.length > MAX_SINGLE_EXPRESSION_LENGTH) {
      LogUtil.error(`${TAG} Single expression too long!`);
      throw new Error('invalid');
    }

    let conditions = this.getConditions();
    if (conditions === null) {
      return false;
    }

    for (let key of Array.from(conditions.keys())) {
      if (expression.startsWith(key)) {
        if (IS_DEBUG) {
          LogUtil.info(`${TAG} condition match, key : ${key}`);
        }

        let condition = conditions.get(key);

        let isMeet = await condition?.isMeet(expression) ?? false;

        if (IS_DEBUG) {
          LogUtil.info(`${TAG} expression isMeet : ${isMeet}`);
        }
        return isMeet;
      }
    }

    LogUtil.error(`${TAG} no condition match!`);
    throw new Error('invalid');
  }
}

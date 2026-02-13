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

import bundle from '@ohos.bundle';
import deviceInfo from '@ohos.deviceInfo';
import OsAccount from '@ohos.account.osAccount';
import { LogUtil } from '../utils/LogUtil';
import { SettingsDataUtils } from '../utils/SettingsDataUtils';
import { CheckEmptyUtils } from '../utils/CheckEmptyUtils';

const IS_DEBUG = false;
const TAG = 'Condition : ';
const DEFAULT_VALUE_SPLITTER = '|';
const PARSE_VERSION_CONDITION_ERROR = 'parse version condition error!';
const SUB_EXPRESSIONS_SIZE = 2;

/**
 * 操作符枚举
 *
 * @since 2020-06-29
 */
export enum Operator {
  EQUAL_OPERATOR = '==',

  GREATER_OPERATOR = '>',

  GREATER_OR_EQUAL_OPERATOR = '>=',

  LESS_OPERATOR = '<',

  LESS_OR_EQUAL_OPERATOR = '<=',

  REVERSE_EQUAL_OPERATOR = '!='
}

/**
 * Base condition interface.
 *
 * @since 2022-06-27
 */
export class Condition {
  /**
   * Is meet current condition.
   *
   * @param context Context from caller
   * @return True if meet
   */
  async isMeet(expression?: string, data?: Object): Promise<boolean> {
    return true;
  }

  protected getOperator(expression: string): Operator {
    if (expression.indexOf(Operator.EQUAL_OPERATOR)) {
      return Operator.EQUAL_OPERATOR;
    } else if (expression.indexOf(Operator.GREATER_OPERATOR)) {
      return Operator.GREATER_OPERATOR;
    } else if (expression.indexOf(Operator.GREATER_OR_EQUAL_OPERATOR)) {
      return Operator.GREATER_OR_EQUAL_OPERATOR;
    } else if (expression.indexOf(Operator.LESS_OPERATOR)) {
      return Operator.LESS_OPERATOR;
    } else if (expression.indexOf(Operator.LESS_OR_EQUAL_OPERATOR)) {
      return Operator.LESS_OR_EQUAL_OPERATOR;
    } else if (expression.indexOf(Operator.REVERSE_EQUAL_OPERATOR)) {
      return Operator.REVERSE_EQUAL_OPERATOR;
    }

    LogUtil.error(TAG + PARSE_VERSION_CONDITION_ERROR);
    throw new Error('invalid');
  }
}

/**
 * 版本条件因子
 *
 * @since 2022-06-29
 */
export class VersionCondition extends Condition {
  async isMeet(expression?: string, data?: string): Promise<boolean> {
    let operator: Operator = this.getOperator(expression as string);
    if (IS_DEBUG) {
      LogUtil.error(TAG + 'operator : ' + operator);
    }
    let subExpressions = expression?.split(operator);
    if (CheckEmptyUtils.isEmptyArr(subExpressions) || subExpressions.length !== SUB_EXPRESSIONS_SIZE) {
      LogUtil.error(TAG + 'VersionCondition subExpressions invalid');
      throw new Error('invalid');
    }
    if (IS_DEBUG) {
      LogUtil.info(TAG + 'subExpressions[1] : ' + subExpressions[1]);
    }
    let version = Number.parseInt(subExpressions[1]);
    let currentVersion = await this.getCurrentVersion();

    if (IS_DEBUG) {
      LogUtil.info(TAG + 'version : ' + version + ', currentVersion : ' + currentVersion);
    }

    if (operator === Operator.EQUAL_OPERATOR) {
      return version === currentVersion;
    } else if (operator === Operator.GREATER_OPERATOR) {
      return currentVersion > version;
    } else if (operator === Operator.LESS_OPERATOR) {
      return currentVersion < version;
    } else {
      return false;
    }
  }

  async getCurrentVersion(): Promise<number> {
    return 0;
  }
}

/**
 * 应用版本条件因子
 *
 * @since 2022-06-29
 */
export class AppVersionCondition extends VersionCondition {
  public bundleName: string = '';
  public versionCode: number | undefined;

  setBundleName(bundleName: string): AppVersionCondition {
    this.bundleName = bundleName;
    this.versionCode = undefined;
    return this;
  }

  async getCurrentVersion(): Promise<number> {
    if (this.versionCode) {
      return this.versionCode;
    }
    let bundleInfo = await bundle.getBundleInfo(this.bundleName, bundle.BundleFlag.GET_BUNDLE_DEFAULT);
    this.versionCode = bundleInfo.versionCode;
    return this.versionCode;
  }
}

/**
 * 设备类型条件因子
 *
 * @since 2022-06-29
 */
export class DeviceTypeCondition extends Condition {
  async isMeet(expression?: string, data?: string): Promise<boolean> {
    let subExpressions = expression?.split(Operator.EQUAL_OPERATOR);
    if (CheckEmptyUtils.isEmptyArr(subExpressions) || subExpressions.length !== SUB_EXPRESSIONS_SIZE) {
      LogUtil.error(TAG + PARSE_VERSION_CONDITION_ERROR);
      throw new Error('invalid');
    }
    if (IS_DEBUG) {
      LogUtil.info(TAG + 'subExpressions[1] : ' + subExpressions[1]);
    }
    let deviceType = subExpressions[1].trim();
    let currentDeviceType = deviceInfo.deviceType.trim();

    if (IS_DEBUG) {
      LogUtil.info(TAG + 'deviceType : ' + deviceType + ', currentDeviceType : ' + currentDeviceType);
    }

    return deviceType === currentDeviceType;
  }
}

/**
 * 设置数据库值条件因子
 *
 * @since 2022-06-29
 */
export class SettingsDataCondition extends Condition {
  async isMeet(expression?: string, data?: string): Promise<boolean> {
    let operator: Operator = this.getOperator(expression as string);
    if (IS_DEBUG) {
      LogUtil.error(TAG + 'operator : ' + operator);
    }
    let subExpressions = expression?.split(operator);
    if (CheckEmptyUtils.isEmptyArr(subExpressions) || subExpressions.length !== SUB_EXPRESSIONS_SIZE) {
      LogUtil.error(TAG + 'SettingsDataCondition subExpressions invalid');
      throw new Error('invalid');
    }
    if (IS_DEBUG) {
      LogUtil.info(TAG + 'subExpressions[1] : ' + subExpressions[1]);
    }
    let value = subExpressions[1].trim();

    let dataKeyExpressions = subExpressions[0].split(DEFAULT_VALUE_SPLITTER);
    if (!dataKeyExpressions || dataKeyExpressions.length <= 0) {
      LogUtil.error(TAG + 'SettingsDataCondition dataKeyExpressions invalid');
      throw new Error('invalid');
    }

    let defaultValue = dataKeyExpressions.length > 1 ? dataKeyExpressions[1].trim() : '';
    let currentValue = SettingsDataUtils.getSettingsData(dataKeyExpressions[0].trim(), defaultValue);

    if (IS_DEBUG) {
      LogUtil.info(TAG + 'value : ' + value + ', currentValue : ' + currentValue);
    }

    if (operator === Operator.EQUAL_OPERATOR) {
      return value === currentValue;
    } else if (operator === Operator.GREATER_OPERATOR) {
      return Number.parseInt(value) > Number.parseInt(currentValue);
    } else if (operator === Operator.LESS_OPERATOR) {
      return Number.parseInt(value) < Number.parseInt(currentValue);
    } else {
      return false;
    }
  }
}

/**
 * 用户类型条件因子
 *
 * @since 2022-06-29
 */
export class OsAccountTypeCondition extends Condition {
  async isMeet(expression?: string, data?: string): Promise<boolean> {
    let subExpressions = expression?.split(Operator.EQUAL_OPERATOR);
    if (CheckEmptyUtils.isEmptyArr(subExpressions) || subExpressions.length !== SUB_EXPRESSIONS_SIZE) {
      LogUtil.error(TAG + 'OsAccountType subExpressions invalid');
      throw new Error('invalid');
    }
    if (IS_DEBUG) {
      LogUtil.info(TAG + 'subExpressions[1] : ' + subExpressions[1].trim());
    }
    let osAccountType = subExpressions[1].trim();
    let curAccountInfo: OsAccount.OsAccountInfo | null = null;
    try {
      curAccountInfo = await OsAccount.getAccountManager().queryCurrentOsAccount();
    } catch (error) {
      LogUtil.error(`${TAG} queryCurrentOsAccount failed: ${error?.message}`);
    }
    let currentOsAccountType = curAccountInfo?.type;

    if (IS_DEBUG) {
      LogUtil.info(TAG + 'osAccountType : ' + osAccountType);
    }

    if (OsAccount.OsAccountType.ADMIN === currentOsAccountType) {
      return osAccountType === 'ADMIN';
    }
    if (OsAccount.OsAccountType.NORMAL === currentOsAccountType) {
      return osAccountType === 'NORMAL';
    }
    if (OsAccount.OsAccountType.GUEST === currentOsAccountType) {
      return osAccountType === 'GUEST';
    }
    return false;
  }
}


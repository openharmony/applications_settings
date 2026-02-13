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

import taskpool from '@ohos.taskpool';
import { BusinessError } from '@ohos.base';
import { NavEntryKey } from '../utils/Consts';
import { LogUtil } from '../utils/LogUtil';
import { StringUtil } from '../utils/StringUtil';

const TAG = 'PasswordManager : ';

/**
 * 密码强度策略
 */
interface PasswordPolicy {
  /**
   * 密码强度正则表达式
   */
  complexityRegex?: string;

  /**
   * 密码有效期
   */
  validityPeriod?: number;

  /**
   * 密码强度策略描述
   */
  additionalDescription?: string;
}

@Concurrent
async function updateTaskFun(): Promise<PasswordPolicy> {
  try {
    let securityManager = await import('@ohos.enterprise.securityManager');
    return securityManager.default.getPasswordPolicy();
  } catch (err) {
    LogUtil.error(`edmPolicy updateTaskFun error:${err?.message}`);
    return {};
  }
}

/**
 * 密码设置管理类，当前主要用于管理企业定制场景
 */
export class PasswordManager {
  private static edmPolicy: PasswordPolicy = {};

  /**
   * 企业密码强度不符合提示语
   *
   * @returns 密码强度不符合策略
   */
  static getEdmPasswordWarningMessage(): ResourceStr {
    return $r('app.string.edm_password_warning_message');
  }

  /**
   * 获取企业设置的密码策略提示
   *
   * @returns 密码策略提示
   */
  static getEdmPasswordTipMessage(): string {
    if (!PasswordManager.hasEdmPolicy()) {
      LogUtil.warn(`${TAG} edmPolicy or complexityRegex undefine`);
      return '';
    }
    if (!PasswordManager.edmPolicy.additionalDescription) {
      LogUtil.warn(`${TAG} edmPolicy additionalDescription undefine`);
      return '';
    }
    return PasswordManager.edmPolicy.additionalDescription;
  }

  /**
   * 判断设置的密码是否符合企业密码强度策略管控
   *
   * @param password 用户输入的密码
   * @returns true 表示密码符合企业设置的策略
   */
  static isMatchEdmPolicy(password: string): boolean {
    if (!password) {
      LogUtil.warn(`${TAG} password undefine`);
      return false;
    }
    if (!PasswordManager.hasEdmPolicy()) {
      LogUtil.warn(`${TAG} edmPolicy or complexityRegex undefine`);
      return false;
    }
    let regexp: RegExp = new RegExp(`${PasswordManager.edmPolicy.complexityRegex}`);
    let result: RegExpExecArray | null = regexp.exec(password);
    return result !== null && result[0] === password;
  }

  /**
   * 判断是否有企业密码强度策略管控
   *
   * @returns true 表示有企业密码强度策略管控
   */
  static hasEdmPolicy(): boolean {
    if (!PasswordManager.edmPolicy) {
      return false;
    }
    return StringUtil.isNotEmpty(PasswordManager.edmPolicy.complexityRegex);
  }

  /**
   * 更新企业密码强度管控策略
   */
  static updateEdmPolicy(): void {
    try {
      let updateTask: taskpool.Task = new taskpool.Task(updateTaskFun);
      taskpool.execute(updateTask, taskpool.Priority.MEDIUM).then((result) => {
        PasswordManager.edmPolicy = result as PasswordPolicy;
      }).catch((err: BusinessError) => {
        LogUtil.error(`${TAG} failed to updateEdmPolicy. error: ${err?.message}`);
        PasswordManager.edmPolicy = {};
      });
    } catch (error) {
      PasswordManager.edmPolicy = {};
      LogUtil.error(`${TAG} getPasswordPolicy error: ${error?.message}`);
    }
  }

  /**
   * 获取跳转设置密码界面的NavEntryKey，企业定制场景下跳转混合密码界面
   */
  static getEntryKey(): string {
    if (PasswordManager.hasEdmPolicy()) {
      return NavEntryKey.CREATE_MIX_PSD_ENTRY;
    } else {
      return NavEntryKey.LOCK_SCREEN_PASSWORD_ENTRY;
    }
  }
}
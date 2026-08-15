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

import settings from '@ohos.settings';
import { languageAndRegionModel } from '@ohos/settings.language';
import { AbilityContextManager } from '@ohos/settings.common/src/main/ets/ability/AbilityContextManager';
import { LogUtil } from '@ohos/settings.common/src/main/ets/utils/LogUtil';

const TAG: string = 'UserSwitchConfigRestorer: ';
/** 切用户后强制恢复的系统语言：简体中文 */
const FORCE_SYSTEM_LANGUAGE: string = 'zh-Hans';
/**
 * 加速度计自动旋转状态：'0' 关闭自动旋转 = 控制中心旋转锁定开启。
 */
const AUTO_ROTATE_OFF: string = '0';

/**
 * 切用户后在目标用户上下文恢复部分配置。
 */
export class UserSwitchConfigRestorer {
  /**
   * 切用户成功后统一恢复配置。
   */
  public static restoreAfterUserSwitch(): void {
    UserSwitchConfigRestorer.restoreToSimplifiedChinese();
    UserSwitchConfigRestorer.keepRotationLockOn();
  }

  /**
   * 切用户成功后调用：强制恢复为简体中文。
   */
  public static restoreToSimplifiedChinese(): void {
    LogUtil.info(`${TAG} restoreToSimplifiedChinese start`);
    try {
      const current: string = languageAndRegionModel.getSystemLanguage();
      LogUtil.info(`${TAG} restore language, current=${current}, target=${FORCE_SYSTEM_LANGUAGE}`);
      if (current === FORCE_SYSTEM_LANGUAGE || current?.startsWith(`${FORCE_SYSTEM_LANGUAGE}-`)) {
        LogUtil.info(`${TAG} already simplified Chinese, skip set`);
        return;
      }
      languageAndRegionModel.setSystemLanguage(FORCE_SYSTEM_LANGUAGE);
      LogUtil.info(`${TAG} restoreToSimplifiedChinese done`);
    } catch (err) {
      LogUtil.error(`${TAG} restoreToSimplifiedChinese failed: ${err?.code}, ${err?.message}`);
    }
  }

  /**
   * 切用户成功后调用：保持旋转锁定开启（关闭自动旋转）。
   */
  public static keepRotationLockOn(): void {
    LogUtil.info(`${TAG} keepRotationLockOn start`);
    try {
      const context = AbilityContextManager.getContext();
      if (!context) {
        LogUtil.error(`${TAG} keepRotationLockOn failed: context is null`);
        return;
      }
      const key: string = settings.general.ACCELEROMETER_ROTATION_STATUS;
      const current: string = settings.getValueSync(context, key, AUTO_ROTATE_OFF);
      LogUtil.info(`${TAG} keepRotationLockOn current=${current}, target=${AUTO_ROTATE_OFF}`);
      if (current === AUTO_ROTATE_OFF) {
        LogUtil.info(`${TAG} rotation lock already on, skip set`);
        return;
      }
      const result: boolean = settings.setValueSync(context, key, AUTO_ROTATE_OFF);
      LogUtil.info(`${TAG} keepRotationLockOn done, result=${result}`);
    } catch (err) {
      LogUtil.error(`${TAG} keepRotationLockOn failed: ${err?.code}, ${err?.message}`);
    }
  }
}

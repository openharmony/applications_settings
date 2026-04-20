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

import { common, UIExtensionContentSession } from '@kit.AbilityKit';
import { AbilityUtils } from '@ohos/settings.common/src/main/ets/utils/AbilityUtils';
import MdmDisable from '@ohos/settings.common/src/main/ets/other/MdmDisable';
import { NavEntryKey } from '@ohos/settings.common/src/main/ets/utils/Consts';
import { LogUtil } from '@ohos/settings.common/src/main/ets/utils/LogUtil';
/* instrument ignore file */
const BIOMETRICS_AND_SCREENLOCK_DISABLE: string = 'persist.edm.set_biometrics_and_screenLock_disable';
const RESULT_CODE: number = -1;

export default class BiometricsDisable extends MdmDisable {
  private static instance?: BiometricsDisable;

  private constructor() {
    super(BIOMETRICS_AND_SCREENLOCK_DISABLE, [
      // 锁屏密码
      NavEntryKey.LOCK_SCREEN_PASSWORD_ENTRY,
      NavEntryKey.CHANGE_LOCK_SCREEN_PASSWORD_ENTRY,
      NavEntryKey.CLOSE_LOCK_SCREEN_PASSWORD_ENTRY,
      NavEntryKey.DISABLE_OLD_LOCK_SCREEN_PASSWORD_ENTRY,
    ]);
  }

  /**
   * 给予用户禁用提示
   *
   * @param context 上下文
   * @param session 会话
   * @param isTopMost 是否为TopMost
   */
  public disableToastHandler(context: common.UIExtensionContext | common.UIAbilityContext,
    session?: UIExtensionContentSession, isTopMost: boolean = false): void {
    try {
      context.startServiceExtensionAbility({
        bundleName: 'com.ohos.settings',
        abilityName: 'DisableToastService',
        parameters: {
          topMost: isTopMost
        }
      });
      if (session) {
        AbilityUtils.closeUiExtension(session, RESULT_CODE);
      }
    } catch (err) {
      LogUtil.error(`disableHandler code: ${err?.code} message: ${err?.message}`);
    }
  }

  public static getInstance(): BiometricsDisable {
    if (!BiometricsDisable.instance) {
      BiometricsDisable.instance = new BiometricsDisable();
    }
    return BiometricsDisable.instance;
  }
}
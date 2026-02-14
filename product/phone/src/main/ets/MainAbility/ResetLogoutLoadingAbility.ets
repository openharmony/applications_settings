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

import UIExtensionAbility from '@ohos.app.ability.UIExtensionAbility';
import Want from '@ohos.app.ability.Want';
import UIExtensionContentSession from '@ohos.app.ability.UIExtensionContentSession';
import { LogUtil } from '@ohos/settings.common/src/main/ets/utils/LogUtil';
import { AbilityContextManager } from '@ohos/settings.common/src/main/ets/ability/AbilityContextManager';
import { CheckEmptyUtils } from '@ohos/settings.common/src/main/ets/utils/CheckEmptyUtils';

/* instrument ignore file */
const TAG: string = 'ResetLogoutLoadingAbility : ';

/**
 * Ability for ResetLogoutLoading
 *
 * @since 2025-03-18
 */
export default class ResetLogoutLoadingAbility extends UIExtensionAbility {
  onCreate() {
    LogUtil.showInfo(TAG, 'onCreate is called');
    AbilityContextManager.addContext(this.context);
  }

  onDestroy(): void {
    LogUtil.showInfo(TAG, 'onDestroy is called');
    AbilityContextManager.removeContext(this.context);
  }

  onForeground(): void {
    LogUtil.showInfo(TAG, 'onForeground is called');
  }

  onBackground(): void {
    LogUtil.showInfo(TAG, 'onBackground is called');
  }

  onSessionCreate(want: Want, session: UIExtensionContentSession): void {
    LogUtil.showInfo(TAG, 'onSessionCreate is called');
    try {
      let dialogSession: UIExtensionContentSession =
        (AppStorage.get<UIExtensionContentSession>('ResetLogoutLoadingSession') as UIExtensionContentSession);
      if (dialogSession) {
        dialogSession.terminateSelf();
      }
      if (CheckEmptyUtils.isEmpty(session)) {
        LogUtil.showError(TAG, 'session is empty');
        return;
      }
      AppStorage.setOrCreate<UIExtensionContentSession>('ResetLogoutLoadingSession', session);
      session.loadContent('Setting/System/Reset/ResetLogoutLoadingComponent');
      session.setWindowBackgroundColor('#000000');
    } catch (err) {
      LogUtil.showError(TAG, `onSessionCreate failed, err is code: ${err?.code} message: ${err?.message}`);
      session.terminateSelf();
    }
    LogUtil.showInfo(TAG, 'onSessionCreate end');
  }
}
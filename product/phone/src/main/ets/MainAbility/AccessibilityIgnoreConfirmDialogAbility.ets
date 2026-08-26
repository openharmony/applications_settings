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

import Want from '@ohos.application.Want';
import UIExtensionAbility from '@ohos.app.ability.UIExtensionAbility';
import UIExtensionContentSession from '@ohos.app.ability.UIExtensionContentSession';
import { BusinessError } from '@ohos.base';
import { AbilityContextManager } from '@ohos/settings.common/src/main/ets/ability/AbilityContextManager';
import { LogUtil } from '@ohos/settings.common/src/main/ets/utils/LogUtil';
import { FontScaleUtils } from '@ohos/settings.common/src/main/ets/utils/FontScaleUtils';

/* instrument ignore file */
const TAG: string = 'AccessibilityIgnoreConfirmDialogAbility: ';

export default class AccessibilityIgnoreConfirmDialogAbility extends UIExtensionAbility {
  onCreate(): void {
    LogUtil.info(`${TAG} onCreate is called`);
    AbilityContextManager.addContext(this.context);
    FontScaleUtils.setConfig(this.context.config.fontSizeScale as number);
  }

  onDestroy(): void {
    LogUtil.info(`${TAG} onDestroy is called`);
    AbilityContextManager.removeContext(this.context);
  }

  onSessionCreate(want: Want, session: UIExtensionContentSession): void {
    LogUtil.info(`${TAG} onSessionCreate is called`);
    AppStorage.setOrCreate<UIExtensionContentSession>('accessibilityDialogSession', session);
    try {
      (AppStorage.get<UIExtensionContentSession>('accessibilityDialogSession') as UIExtensionContentSession)
        ?.loadContent('Setting/Accessibility/dialog/view/AccessibilityIgnoreConfirmDialog');
      (AppStorage.get<UIExtensionContentSession>('accessibilityDialogSession') as UIExtensionContentSession)
        ?.setWindowBackgroundColor('#00FFFFFF');
    } catch (errData) {
      LogUtil.error(`${TAG} loadContent errData is errCode: ${(
        errData as BusinessError)?.code}  message:${(errData as BusinessError)?.message}`);
      (AppStorage.get<UIExtensionContentSession>(
        'accessibilityDialogSession') as UIExtensionContentSession)?.terminateSelf();
      return;
    }
    LogUtil.info(`${TAG} onSessionCreate is end`);
  }
}
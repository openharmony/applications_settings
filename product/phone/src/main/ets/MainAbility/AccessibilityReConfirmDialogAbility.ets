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

import { LogUtil } from '@ohos/settings.common/src/main/ets/utils/LogUtil';
import { AbilityContextManager } from '@ohos/settings.common/src/main/ets/ability/AbilityContextManager';
import UIExtensionContentSession from '@ohos.app.ability.UIExtensionContentSession';
import UIExtensionAbility from '@ohos.app.ability.UIExtensionAbility';
import { FontScaleUtils } from '@ohos/settings.common/src/main/ets/utils/FontScaleUtils';
import Want from '@ohos.application.Want';

/* instrument ignore file */
const TAG: string = 'AccessibilityReConfirmDialogAbility: ';

export default class AccessibilityReConfirmDialogAbility extends UIExtensionAbility {
  onCreate(): void {
    LogUtil.info(`${TAG} onCreate is called`);
    AbilityContextManager.addContext(this.context);
    FontScaleUtils.setConfig(this.context.config.fontSizeScale as number);
  }

  onDestroy(): void {
    LogUtil.info(`${TAG} onDestroy is called`);
  }

  onSessionCreate(want: Want, session: UIExtensionContentSession): void {
    LogUtil.info(`${TAG} onSessionCreate is called`);

    AppStorage.setOrCreate<UIExtensionContentSession>('accessibilityDialogSession', session);
    session?.loadContent('Setting/Accessibility/dialog/view/AccessibilityReConfirmDialog');
    session?.setWindowBackgroundColor('#00FFFFFF');

    LogUtil.info(`${TAG} onSessionCreate is end`);
  }
}
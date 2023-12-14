/**
 * Copyright (c) 2021 Huawei Device Co., Ltd.
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
import LogUtil from '../../../../../../common/utils/src/main/ets/default/baseUtil/LogUtil';
import { AbilityContextManager } from './AbilityContextManager';

const TAG: string = 'AccessibilityShortKeyDialogAbility : ';

export default class AccessibilityShortKeyDialogAbility extends UIExtensionAbility {
  onCreate(): void {
    LogUtil.info(`${TAG} MainAbility onCreate`);
    AbilityContextManager.addContext(this.context);
  }

  onDestroy(): void {
    LogUtil.info(`${TAG} MainAbility onDestroy`);
  }

  onSessionCreate(want: Want, session: UIExtensionContentSession): void {
    LogUtil.info(`${TAG} onSessionCreate is called`);
    AppStorage.setOrCreate<UIExtensionContentSession>('accessibilityDialogSession', session);

    try {
      (AppStorage.get<UIExtensionContentSession>('accessibilityDialogSession') as UIExtensionContentSession).loadContent('pages/abilityDialog/accessibilityWindowShortKeyDialog');
      (AppStorage.get<UIExtensionContentSession>('accessibilityDialogSession') as UIExtensionContentSession).setWindowBackgroundColor('#00FFFFFF');
    } catch (errData) {
      LogUtil.error(`${TAG} loadContext errData is errCode: ${(errData as BusinessError).code} message:${(errData as BusinessError).message}`);
      (AppStorage.get<UIExtensionContentSession>('accessibilityDialogSession') as UIExtensionContentSession).terminateSelf();
      return;
    }
    LogUtil.info(`${TAG} onSessionCreate is end`);
  }
};
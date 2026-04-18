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
import { AbilityContextManager } from '@ohos/settings.common/src/main/ets/ability/AbilityContextManager';
import { LogUtil } from '@ohos/settings.common/src/main/ets/utils/LogUtil';

/* instrument ignore file */
const TAG: string = 'UsbDebugDialogAbility';

export default class UsbDebugDialogAbility extends UIExtensionAbility {
  onCreate(): void {
    LogUtil.info(`${TAG} onCreate is called`);
    AbilityContextManager.addContext(this.context);
  }

  onDestroy(): void {
    LogUtil.info(`${TAG} onDestroy is called`);
    AbilityContextManager.removeContext(this.context);
  }

  onSessionCreate(want: Want, session: UIExtensionContentSession): void {
    LogUtil.info(`${TAG} onSessionCreate is called`);

    try {
      let dialogSession: UIExtensionContentSession = (AppStorage.get<UIExtensionContentSession>('dialogSession') as
      UIExtensionContentSession);
      if (dialogSession) {
        dialogSession.terminateSelf();
      }
      AppStorage.setOrCreate<UIExtensionContentSession>('dialogSession', session);
      (AppStorage.get<UIExtensionContentSession>('dialogSession') as UIExtensionContentSession)
        .loadContent('pages/developeroptionsDialog/model/UsbDebugDialog');
      (AppStorage.get<UIExtensionContentSession>('dialogSession') as UIExtensionContentSession)
        .setWindowBackgroundColor('#00FFFFFF');
    } catch (err) {
      LogUtil.error(`${TAG} onSessionCreate failed, err is code: ${err?.code} message: ${err?.message}`);
      (AppStorage.get<UIExtensionContentSession>('dialogSession') as UIExtensionContentSession).terminateSelf();
    }



    LogUtil.info(`${TAG} onSessionCreate is end`);
  }
}
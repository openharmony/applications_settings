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
import { CheckEmptyUtils } from '@ohos/settings.common/src/main/ets/utils/CheckEmptyUtils';
import { LogUtil } from '@ohos/settings.common/src/main/ets/utils/LogUtil';

/* instrument ignore file */
const TAG: string = 'BluetoothAutoPlayAuthDialogAbility';

export default class BluetoothAutoPlayAuthDialogAbility extends UIExtensionAbility {
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
    if (!this.isParamsValid(want) || CheckEmptyUtils.isEmpty(session)) {
      LogUtil.error(`${TAG} want or session is invalid`);
      session?.terminateSelf();
      return;
    }

    AppStorage.setOrCreate<UIExtensionContentSession>('dialogSession', session);
    AppStorage.setOrCreate<string>('bt_autoPlay_deviceId', want.parameters?.deviceId);
    AppStorage.setOrCreate<string>('bt_autoPlay_deviceName', want.parameters?.deviceName);
    session.loadContent('Setting/Bluetooth/dialog/view/BluetoothAutoPlayAuthDialog');
    session.setWindowBackgroundColor('#00FFFFFF');
    LogUtil.info(`${TAG} onSessionCreate is end`);
  }

  private isParamsValid(want: Want): boolean {
    if (CheckEmptyUtils.isEmpty(want) || typeof want.parameters?.deviceId === 'undefined' ||
      typeof want.parameters?.deviceName === 'undefined') {
      LogUtil.error(`${TAG} params is invalid.`);
      return false;
    }
    return true;
  }
}
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
import { LogUtil, LogMaskUtil } from '@ohos/settings.common/src/main/ets/utils/LogUtil';
import { BluetoothUtils } from '@ohos/settings.common/src/main/ets/utils/BluetoothUtils';
import { BluetoothAdapter, MapMseProfile } from '@ohos/settings.bluetooth/src/main/ets/BluetoothAdapter';
import { CheckEmptyUtils } from '@ohos/settings.common/src/main/ets/utils/CheckEmptyUtils';

/* instrument ignore file */
const TAG: string = 'BluetoothMapAuthDialogAbility';

export default class BluetoothMapAuthDialogAbility extends UIExtensionAbility {
  onCreate(): void {
    LogUtil.info(`${TAG} onCreate is called`);
    AbilityContextManager.addContext(this.context);
  }

  onDestroy(): void {
    LogUtil.info(`${TAG} onDestroy is called`);
  }

  onSessionCreate(want: Want, session: UIExtensionContentSession): void {
    LogUtil.info(`${TAG} onSessionCreate is called`);
    if (!this.isParamsValid(want) || CheckEmptyUtils.isEmpty(session)) {
      LogUtil.error(`${TAG} want or session is invalid`);
      session?.terminateSelf();
      return;
    }

    AppStorage.setOrCreate<MapMseProfile>('mapProfile', BluetoothAdapter.getInstance().profileManager.mapProfile);
    AppStorage.setOrCreate<UIExtensionContentSession>('mapAuthDialogSession', session);
    AppStorage.setOrCreate<string>('MapAuthDeviceId', want.parameters?.deviceId);
    AppStorage.setOrCreate<string>('MapAuthDeviceName', want.parameters?.deviceName);
    session.loadContent('Setting/Bluetooth/dialog/view/BluetoothMapAuthDialog');
    session.setWindowBackgroundColor('#00FFFFFF');
    LogUtil.info(`${TAG} onSessionCreate is end`);
  }

  private isParamsValid(want: Want): boolean {
    if (CheckEmptyUtils.isEmpty(want) || typeof want.parameters?.deviceId === 'undefined' || typeof want.parameters?.deviceName === 'undefined') {
      LogUtil.error(`${TAG} deviceId: ${BluetoothUtils.getLogMAC(want?.parameters?.deviceId)},deviceName: ${LogMaskUtil.getLogNickNameString(want?.parameters?.deviceName)}`);
      return false;
    }
    return true;
  }
}
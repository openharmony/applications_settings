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
import { PinType } from '@ohos/settings.bluetooth/src/main/ets/model/BluetoothModel';
import { LogUtil } from '@ohos/settings.common/src/main/ets/utils/LogUtil';
import { BluetoothUtils } from '@ohos/settings.common/src/main/ets/utils/BluetoothUtils';
import { AbilityContextManager } from '@ohos/settings.common/src/main/ets/ability/AbilityContextManager';
import { CheckEmptyUtils } from '@ohos/settings.common/src/main/ets/utils/CheckEmptyUtils';

/* instrument ignore file */
const TAG: string = 'BluetoothPairDialogAbility';

export default class BluetoothPairDialogAbility extends UIExtensionAbility {
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

    AppStorage.setOrCreate<UIExtensionContentSession>('bluetoothPairDialogSession', session);
    AppStorage.setOrCreate<string>('PairDeviceId', want.parameters?.deviceId);
    AppStorage.setOrCreate<string>('PairPinCode', want.parameters?.pinCode);
    AppStorage.setOrCreate<number>('PairPinType', Number.parseInt(want.parameters?.pinType));

    try {
      session.loadContent('Setting/Bluetooth/dialog/view/BluetoothDialog');
      session.setWindowBackgroundColor('#00FFFFFF');
    } catch (err) {
      LogUtil.error(`${TAG} onSessionCreate failed`);
    }

    LogUtil.info(`${TAG} onSessionCreate is end`);
  }

  private isParamsValid(want: Want): boolean {
    if (CheckEmptyUtils.isEmpty(want) || typeof want.parameters?.deviceId === 'undefined' || typeof want.parameters?.pinCode === 'undefined' || typeof want.parameters?.pinType === 'undefined') {
      LogUtil.error(`${TAG} deviceId: ${BluetoothUtils.getLogMAC(want?.parameters?.deviceId)}, pinType:${want?.parameters?.pinType}`);
      return false;
    }

    let type: string = want.parameters?.pinType;
    switch (Number.parseInt(type)) {
      case PinType.PAIRING_VARIANT_PIN:
      case PinType.PAIRING_VARIANT_PASSKEY:
      case PinType.PAIRING_VARIANT_PASSKEY_CONFIRMATION:
      case PinType.PAIRING_VARIANT_CONSENT:
      case PinType.PAIRING_VARIANT_DISPLAY_PASSKEY:
      case PinType.PAIRING_VARIANT_DISPLAY_PIN:
      case PinType.PAIRING_VARIANT_OOB_CONSENT:
      case PinType.PAIRING_VARIANT_PIN_16_DIGITS:
        break
      default:
        LogUtil.error(`${TAG} pin type invalid: ${type}`);
        return false;
    }
    return true;
  }
}
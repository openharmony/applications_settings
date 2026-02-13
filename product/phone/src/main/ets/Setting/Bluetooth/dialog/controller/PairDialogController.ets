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

/* instrument ignore file */
import UIExtensionContentSession from '@ohos.app.ability.UIExtensionContentSession';
import connection from '@ohos.bluetooth.connection';
import { BluetoothAdapter, } from '@ohos/settings.bluetooth/src/main/ets/BluetoothAdapter';
import { AccessAuthorization, ShareType } from '@ohos/settings.bluetooth/src/main/ets/constants/BluetoothConstants';
import { BondState, BondStateParam, PinType } from '@ohos/settings.bluetooth/src/main/ets/model/BluetoothModel';
import { Utils } from '@ohos/settings.bluetooth/src/main/ets/utils/Utils';
import { HiSysEventUtil } from '@ohos/settings.common/src/main/ets/systemEvent/HiSysEventUtil';
import { BluetoothUtils } from '@ohos/settings.common/src/main/ets/utils/BluetoothUtils';
import { CheckEmptyUtils } from '@ohos/settings.common/src/main/ets/utils/CheckEmptyUtils';
import { LogUtil } from '@ohos/settings.common/src/main/ets/utils/LogUtil';
import { ResourceUtil } from '@ohos/settings.common/src/main/ets/utils/ResourceUtil';

const TAG: string = 'PairDialogController: ';
const CONFIRM_DEVICES_NAME: string = 'confirm_devices_name';

/**
 * 配对弹框控制器
 *
 * @since 2024-07-04
 */
export class PairDialogController {
  public content: ResourceStr = '';
  public deviceName: string = '';
  private controller?: CustomDialogController;
  private pinType: number = -1;
  private deviceId: string = '';
  private onBluetoothBondStateChange = (stateParam: BondStateParam) => {
    if (!stateParam) {
      return;
    }
    LogUtil.info(`${TAG} onBluetoothBondStateChange state: ${stateParam.state}, deviceId: ${BluetoothUtils.getLogMAC(stateParam.deviceId)}`);
    if (stateParam.deviceId !== this.deviceId) {
      LogUtil.info(`${TAG} device id not match, current id: ${BluetoothUtils.getLogMAC(this.deviceId)}`);
      return;
    }
    if (stateParam.state === BondState.BOND_STATE_INVALID || stateParam.state === BondState.BOND_STATE_BONDED) {
      this.closeDialog();
    }
  }

  constructor(pinType: number, controller?: CustomDialogController) {
    this.pinType = pinType
    this.controller = controller;
  }

  init(deviceId: string): void {
    let deviceName: string = BluetoothAdapter.getInstance().getDeviceName(deviceId);
    let replaceDeviceName: string = CheckEmptyUtils.checkStrIsEmpty(deviceName) ? deviceId : deviceName;
    BluetoothAdapter.getInstance().updateCacheDevices(deviceId, replaceDeviceName);
    this.deviceName = replaceDeviceName;
    this.deviceId = deviceId;
    if (this.pinType === PinType.PAIRING_VARIANT_PASSKEY_CONFIRMATION) {
      this.content = ResourceUtil.getAnyStrFormatStringSync($r('app.string.bt_pair_required_message'),
        replaceDeviceName, replaceDeviceName);
    } else if (this.pinType === PinType.PAIRING_VARIANT_CONSENT ||
      this.pinType === PinType.PAIRING_VARIANT_OOB_CONSENT ||
      this.pinType === PinType.PAIRING_VARIANT_DISPLAY_PASSKEY ||
      this.pinType === PinType.PAIRING_VARIANT_DISPLAY_PIN) {
      this.content = $r('app.string.bluetooth_pair_with_the_following_message');
    }
    try {
      connection.on('bondStateChange', this.onBluetoothBondStateChange as Callback<connection.BondStateParam>);
    } catch (error) {
      LogUtil.error(`${TAG} on bondStateChange failed, code: ${error?.code}, message: ${error?.message}`);
    }
  }

  destroy() : void {
    try {
      connection.off('bondStateChange', this.onBluetoothBondStateChange as Callback<connection.BondStateParam>);
    } catch (error) {
      LogUtil.error(`${TAG} off bondStateChange failed, code: ${error?.code}, message: ${error?.message}`);
    }
  }
  
  onPairClick(deviceId: string, checkBoxState: boolean, input?: string): void {
    LogUtil.info(`${TAG} onPairClick, deviceId: ${BluetoothUtils.getLogMAC(deviceId)}, checkBoxState: ${checkBoxState}, pinType: ${this.pinType}`);
    let pinType: number = this.pinType;
    if (pinType === PinType.PAIRING_VARIANT_PASSKEY_CONFIRMATION || pinType === PinType.PAIRING_VARIANT_CONSENT) {
      this.onPairClickForPinType236(deviceId, checkBoxState);
    } else if (pinType === PinType.PAIRING_VARIANT_OOB_CONSENT) {
      this.onPairClickForPinType36ForOther(deviceId, checkBoxState);
    } else if (pinType === PinType.PAIRING_VARIANT_DISPLAY_PASSKEY || pinType === PinType.PAIRING_VARIANT_DISPLAY_PIN) {
      this.onPairClickForPinType36ForOther(deviceId, checkBoxState);
    } else if (pinType === PinType.PAIRING_VARIANT_PIN || pinType === PinType.PAIRING_VARIANT_PIN_16_DIGITS ||
      pinType === PinType.PAIRING_VARIANT_PASSKEY) {
      this.onPairClickForPinType07(deviceId, checkBoxState, input);
    }
    this.closeDialog();
  }

  onCancelClick(deviceId: string, input?: string): void {
    LogUtil.info(`${TAG} onCancelClick, deviceId: ${BluetoothUtils.getLogMAC(deviceId)}, pinType: ${this.pinType}`);
    BluetoothAdapter.getInstance().connectTimestampManager.resetDeviceBondedFromLocal(deviceId);
    let pinType: number = this.pinType;
    if (pinType === PinType.PAIRING_VARIANT_PASSKEY_CONFIRMATION || pinType === PinType.PAIRING_VARIANT_CONSENT) {
      this.onCancelClickForPinType2(deviceId);
    } else if (pinType === PinType.PAIRING_VARIANT_OOB_CONSENT) {
      this.onCancelClickForPinType36ForOther(deviceId);
    } else if (pinType === PinType.PAIRING_VARIANT_DISPLAY_PASSKEY || pinType === PinType.PAIRING_VARIANT_DISPLAY_PIN) {
      this.onCancelClickForPinType36ForOther(deviceId);
    } else if (pinType === PinType.PAIRING_VARIANT_PIN || pinType === PinType.PAIRING_VARIANT_PIN_16_DIGITS ||
      pinType === PinType.PAIRING_VARIANT_PASSKEY) {
      this.onCancelClickForPinType07(deviceId, input);
    }
    this.closeDialog();
  }

  private onPairClickForPinType07(deviceId: string, checkBoxState: boolean, input?: string): void {
    let accessAuthorizationParams: AccessAuthorization;
    let shareTypeParams: ShareType;
    if (checkBoxState) {
      accessAuthorizationParams = AccessAuthorization.ALLOWED;
      shareTypeParams = ShareType.SHARE_NAME_AND_PHONE_NUMBER;
    } else {
      accessAuthorizationParams = AccessAuthorization.UNKNOWN;
      shareTypeParams = ShareType.SHARE_NOTHING;
    }

    Utils.setPhoneBookAccessAuthorization(BluetoothAdapter.getInstance().profileManager.pbapProfile, deviceId,
      accessAuthorizationParams);
    Utils.setShareType(BluetoothAdapter.getInstance().profileManager.pbapProfile, deviceId, shareTypeParams);
    LogUtil.info(`${TAG} setPinCodeDevicePairingConfirmation onButton3Click`);
    HiSysEventUtil.reportButtonEvent(CONFIRM_DEVICES_NAME, '');
    BluetoothAdapter.getInstance().setPinCodeDevicePairingConfirmation(deviceId, true, input ?? '');
  }

  private onPairClickForPinType36ForOther(deviceId: string, checkBoxState: boolean): void {
    let accessAuthorizationParams: AccessAuthorization;
    let shareTypeParams: ShareType;
    if (checkBoxState) {
      accessAuthorizationParams = AccessAuthorization.ALLOWED;
      shareTypeParams = ShareType.SHARE_NAME_AND_PHONE_NUMBER;
    } else {
      accessAuthorizationParams = AccessAuthorization.UNKNOWN;
      shareTypeParams = ShareType.SHARE_NOTHING;
    }

    Utils.setPhoneBookAccessAuthorization(BluetoothAdapter.getInstance().profileManager.pbapProfile, deviceId,
      accessAuthorizationParams);
    Utils.setShareType(BluetoothAdapter.getInstance().profileManager.pbapProfile, deviceId, shareTypeParams);

    HiSysEventUtil.reportButtonEvent(CONFIRM_DEVICES_NAME, '');
    BluetoothAdapter.getInstance().setDefaultPinCodeDevicePairingConfirmation(deviceId, true); // 其他场景
    BluetoothAdapter.getInstance().onCancelPair(deviceId);
  }

  private onPairClickForPinType236(deviceId: string, checkBoxState: boolean): void {
    let accessAuthorizationParams: AccessAuthorization;
    let shareTypeParams: ShareType;
    if (checkBoxState) {
      accessAuthorizationParams = AccessAuthorization.ALLOWED;
      shareTypeParams = ShareType.SHARE_NAME_AND_PHONE_NUMBER;
    } else {
      accessAuthorizationParams = AccessAuthorization.UNKNOWN;
      shareTypeParams = ShareType.SHARE_NOTHING;
    }

    Utils.setPhoneBookAccessAuthorization(BluetoothAdapter.getInstance().profileManager.pbapProfile, deviceId,
      accessAuthorizationParams);
    Utils.setShareType(BluetoothAdapter.getInstance().profileManager.pbapProfile, deviceId, shareTypeParams);

    HiSysEventUtil.reportButtonEvent(CONFIRM_DEVICES_NAME, '');
    BluetoothAdapter.getInstance().setDevicePairingConfirmation(deviceId, true);
  }

  private onCancelClickForPinType07(deviceId: string, input?: string): void {
    Utils.setPhoneBookAccessAuthorization(BluetoothAdapter.getInstance().profileManager.pbapProfile, deviceId,
      AccessAuthorization.REJECTED);
    Utils.setShareType(BluetoothAdapter.getInstance().profileManager.pbapProfile, deviceId, ShareType.SHARE_NOTHING);
    BluetoothAdapter.getInstance().setPinCodeDevicePairingConfirmation(deviceId, false, input ?? '');
    LogUtil.info(`${TAG} setPinCodeDevicePairingConfirmation onCancelPair`);
    BluetoothAdapter.getInstance().onCancelPair(deviceId);
  }

  private onCancelClickForPinType2(deviceId: string): void {
    Utils.setPhoneBookAccessAuthorization(BluetoothAdapter.getInstance().profileManager.pbapProfile, deviceId,
      AccessAuthorization.REJECTED);
    Utils.setShareType(BluetoothAdapter.getInstance().profileManager.pbapProfile, deviceId, ShareType.SHARE_NOTHING);

    BluetoothAdapter.getInstance().setDevicePairingConfirmation(deviceId, false);
    BluetoothAdapter.getInstance().onCancelPair(deviceId);
  }

  private onCancelClickForPinType36ForOther(deviceId: string): void {
    LogUtil.info(`${TAG} setShareType ${ShareType.SHARE_NOTHING}}`);
    Utils.setPhoneBookAccessAuthorization(BluetoothAdapter.getInstance().profileManager.pbapProfile, deviceId,
      AccessAuthorization.REJECTED);
    Utils.setShareType(BluetoothAdapter.getInstance().profileManager.pbapProfile, deviceId, ShareType.SHARE_NOTHING);

    BluetoothAdapter.getInstance().setDefaultPinCodeDevicePairingConfirmation(deviceId, false); // 其他场景
    BluetoothAdapter.getInstance().onCancelPair(deviceId);
  }

  private closeDialog(): void {
    this.controller?.close();
    (AppStorage.get<UIExtensionContentSession>('bluetoothPairDialogSession') as UIExtensionContentSession)?.terminateSelf();
  }
}
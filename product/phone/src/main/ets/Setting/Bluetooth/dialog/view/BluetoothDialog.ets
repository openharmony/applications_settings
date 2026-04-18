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

import commonEventManager from '@ohos.commonEventManager';
import UIExtensionContentSession from '@ohos.app.ability.UIExtensionContentSession';
import { BluetoothAdapter } from '@ohos/settings.bluetooth/src/main/ets/BluetoothAdapter';
import { CommonEventConstant } from '@ohos/settings.common/src/main/ets/constant/CommonEventConstant';
import { LogUtil } from '@ohos/settings.common/src/main/ets/utils/LogUtil';
import { CommonEventHelper } from '@ohos/settings.common/src/main/ets/utils/CommonEventHelper';
import { PUBLISHER_PERMISSION_ACCESS_SYSTEM_SETTINGS } from '@ohos/settings.common/src/main/ets/utils/Consts';
import { PairDialogComponent } from './PairDialogComponent';

const TAG: string = 'BluetoothPairDialog: ';
const PIN_REQUIRED_TIME_OUT: number = 30000;

@Entry
@Component
export struct BluetoothPairDialog {
  deviceId: string = '';
  pinCode: string = '';
  pinType: number = -1;
  public pinRequireTimerId: number | null = null;
  public subscribeInfo: commonEventManager.CommonEventSubscribeInfo = {
    events: [CommonEventConstant.EVENT_BLUETOOTH_CLOSE_PAIR_DIALOG],
    publisherPermission: PUBLISHER_PERMISSION_ACCESS_SYSTEM_SETTINGS,
  };
  private closeDialogEvent: CommonEventHelper = new CommonEventHelper(this.subscribeInfo, async (err, data) => {
    LogUtil.info(`${TAG} receive close dialog event`);
    this.closeDialog();
  });

  pairDialogController: CustomDialogController | null = new CustomDialogController({
    builder: PairDialogComponent({
      deviceId: this.deviceId,
      pinType: this.pinType,
      pinCode: this.pinCode,
    }),
    cancel: () => {
    },
    autoCancel: false,
    customStyle: true,
    alignment: DialogAlignment.Center,
    maskColor: $r('sys.color.mask_fourth'),
  });

  build() {
  }

  aboutToAppear(): void {
    LogUtil.info(`${TAG} aboutToAppear`);
    this.deviceId = AppStorage.get<string>('PairDeviceId') as string;
    this.pinCode = AppStorage.get<string>('PairPinCode') as string;
    this.pinType = AppStorage.get<number>('PairPinType') as number;
    this.pairDialogController?.open();

    this.pinRequireTimerId = setTimeout(() => {
      LogUtil.info(`${TAG} pinReqiure timeout`);
      this.closeDialog();
    }, PIN_REQUIRED_TIME_OUT);

    this.closeDialogEvent.registerCommonEvent();
  }

  aboutToDisappear(): void {
    LogUtil.info(`${TAG} aboutToDisappear`);
    clearTimeout(this.pinRequireTimerId);
    this.closeDialogEvent.unRegisterCommonEvent();
    BluetoothAdapter.getInstance().onQuit();
  }

  onPageShow(): void {
    LogUtil.info(`${TAG} onPageShow`);
    BluetoothAdapter.getInstance().setIsPairBluetoothAdapter(true);
    BluetoothAdapter.getInstance().start();
    BluetoothAdapter.getInstance().onBluetoothPinRequiredForPhone(this.deviceId);
  }

  onPageHide(): void {
    LogUtil.info(`${TAG} onPageHide`);
  }

  private closeDialog(): void {
    LogUtil.info(`${TAG} close bluetooth pair dialog`);
    this.pairDialogController?.close();
    (AppStorage.get<UIExtensionContentSession>('bluetoothPairDialogSession') as UIExtensionContentSession)?.terminateSelf();
  }
}
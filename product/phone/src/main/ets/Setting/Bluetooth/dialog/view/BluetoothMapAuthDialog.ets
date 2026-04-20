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

import map from '@ohos.bluetooth.map';
import UIExtensionContentSession from '@ohos.app.ability.UIExtensionContentSession';
import { AccessAuthorization } from '@ohos/settings.bluetooth/src/main/ets/constants/BluetoothConstants';
import { Utils } from '@ohos/settings.bluetooth/src/main/ets/utils/Utils';
import { LogUtil } from '@ohos/settings.common/src/main/ets/utils/LogUtil';
import { ResourceUtil } from '@ohos/settings.common/src/main/ets/utils/ResourceUtil';
import { NormalDialogComponent } from './NormalDialogComponent';

const TAG: string = 'BluetoothMapAuthDialog: ';
const DIALOG_OPEN_TIME_OUT: number = 30000;

@Component
@Entry
export struct BluetoothMapAuthDialog {
  public dialogOpenTimerId: number | null = null;
  deviceName: string = AppStorage.get<string>('MapAuthDeviceName') || '';
  deviceId: string = AppStorage.get<string>('MapAuthDeviceId') || '';
  content: ResourceStr = '';
  private mapProfile: map.MapMseProfile = map.createMapMseProfile();

  mapAuthDialogController: CustomDialogController = new CustomDialogController({
    builder: NormalDialogComponent({
      title: $r('app.string.bt_map_auth_dialog_title'),
      content: this.content,
      hint: $r('app.string.bt_pbap_pse_dialog_message2'),
      primaryButton: $r('app.string.bluetooth_not_allowed'),
      secondaryButton: $r('app.string.wifi_button_tittle_allow'),
      disallowed: () => {
        this.clickDisallowed();
      },
      allowed: () => {
        this.clickAllowed();
      },
    }),
    cancel: () => {
      LogUtil.info(`${TAG} on cancel is called.`);
      this.clickDisallowed();
    },
    autoCancel: true,
    customStyle: true,
    alignment: DialogAlignment.Center,
    maskColor: $r('sys.color.mask_fourth'),
  });

  build() {
  }

  aboutToAppear(): void {
    LogUtil.info(`${TAG} aboutToAppear`);
    this.content = ResourceUtil.getFormatStringSync($r('app.string.bt_map_auth_dialog_message'), this.deviceName);
    this.mapAuthDialogController?.open();

    this.dialogOpenTimerId = setTimeout(() => {
      LogUtil.info(`${TAG} dialog open timeout`);
      this.closeDialog();
    }, DIALOG_OPEN_TIME_OUT);
  }

  aboutToDisappear(): void {
    LogUtil.info(`${TAG} aboutToDisappear`);
    clearTimeout(this.dialogOpenTimerId);
  }

  onPageShow(): void {
    LogUtil.info(`${TAG} onPageShow`);
  }

  onPageHide(): void {
    LogUtil.info(`${TAG} onPageHide`);
  }

  private clickAllowed(): void {
    Utils.setMessageAccessAuthorization(this.mapProfile, this.deviceId, AccessAuthorization.ALLOWED);
    this.closeDialog();
  }

  private clickDisallowed(): void {
    Utils.setMessageAccessAuthorization(this.mapProfile, this.deviceId, AccessAuthorization.REJECTED);
    this.closeDialog();
  }

  private closeDialog(): void {
    this.mapAuthDialogController?.close();
    AppStorage.get<UIExtensionContentSession>('mapAuthDialogSession')?.terminateSelf();
  }
}


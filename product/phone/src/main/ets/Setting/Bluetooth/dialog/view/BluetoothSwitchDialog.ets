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
import access from '@ohos.bluetooth.access';
import { LogUtil } from '@ohos/settings.common/src/main/ets/utils/LogUtil';
import { ResourceUtil } from '@ohos/settings.common/src/main/ets/utils/ResourceUtil';
import { BluetoothUtils } from '@ohos/settings.common/src/main/ets/utils/BluetoothUtils';
import { SingleLineDialogComponent } from './SingleLineDialogComponent';

const TAG: string = 'BluetoothDialog: ';

@Component
@Entry
export struct BluetoothDialog {
  title: ResourceStr = '';
  content: ResourceStr = '';
  bundleName: string = AppStorage.get<string>('BluetoothBundleName') as string;
  switchState: string = AppStorage.get<string>('bluetoothSwitchType') as string;

  switchDialogController: CustomDialogController | null = new CustomDialogController({
    builder: SingleLineDialogComponent({
      title: this.title,
      content: this.content,
      primaryButton: $r('app.string.forbidding'),
      secondaryButton: this.switchState === 'enable' ?
      $r('app.string.accessibility_enable') : $r('app.string.dialog_disable'),
      disallowed: () => {
        this.clickRefuse();
      },
      allowed: () => {
        this.clickAllowed();
      },
    }),
    cancel: () => {
      LogUtil.info(`${TAG} on cancel is called.`);
      this.clickRefuse();
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
    if (this.switchState === 'enable') {
      this.title = ResourceUtil.getFormatStringSync($r('app.string.open_bluetooth_switch_message'), this.bundleName);
      this.content = ResourceUtil.getStringSync($r('app.string.bluetooth_has_closed'));
    } else if (this.switchState === 'disable') {
      this.title = ResourceUtil.getFormatStringSync($r('app.string.close_bluetooth_switch_message'), this.bundleName);
      this.content = ResourceUtil.getStringSync($r('app.string.bluetooth_has_opened'));
    } else {
      LogUtil.error(`${TAG} error switchState:${this.switchState}`);
      (AppStorage.get<UIExtensionContentSession>('dialogSession') as UIExtensionContentSession)?.terminateSelf();
      return;
    }
    this.switchDialogController?.open();
  }

  aboutToDisappear(): void {
    LogUtil.info(`${TAG} aboutToDisappear`);
  }

  onPageShow(): void {
    LogUtil.info(`${TAG} onPageShow`);
  }

  onPageHide(): void {
    LogUtil.info(`${TAG} onPageHide`);
  }

  private clickRefuse(): void {
    LogUtil.info(`${TAG} clickRefuse`);
    this.notifyDialogResult(false);
    this.closeDialog();
  }

  private clickAllowed(): void {
    LogUtil.info(`${TAG} clickAllowed`);
    this.notifyDialogResult(true);
    if (this.switchState === 'enable') {
      this.enableBluetooth();
    } else if (this.switchState === 'disable') {
      this.disableBluetooth();
    } else {
      LogUtil.error(`${TAG} onButton3Click error switchState:${this.switchState}`);
    }
    this.closeDialog();
  }

  private notifyDialogResult(result: boolean): void {
    let param: access.NotifyDialogResultParams = {
      dialogType: 0,
      dialogResult: result
    };
    try {
      access.notifyDialogResult(param);
    } catch (err) {
      LogUtil.error(`${TAG} notifyDialogResult err code: ${err?.code}, message: ${err?.message}`);
    }
  }

  private enableBluetooth(): boolean {
    if (BluetoothUtils.isBluetoothOn()) {
      LogUtil.info(`${TAG} bluetooth is already enable`);
      return true;
    }
    let isSuccess: boolean = BluetoothUtils.enableBlueTooth();
    LogUtil.info(`${TAG} enable bluetooth result is:${isSuccess}`);
    return isSuccess;
  }

  private disableBluetooth(): boolean {
    if (!BluetoothUtils.isBluetoothOn()) {
      LogUtil.info(`${TAG} bluetooth is already disable`);
      return true;
    }

    let isSuccess: boolean = BluetoothUtils.disableBlueTooth();
    LogUtil.info(`${TAG} disable bluetooth result is:${isSuccess}, state:${BluetoothUtils.isBluetoothOn()}`);
    return isSuccess;
  }

  private closeDialog(): void {
    this.switchDialogController?.close();
    (AppStorage.get<UIExtensionContentSession>('dialogSession') as UIExtensionContentSession)?.terminateSelf();
  }
}
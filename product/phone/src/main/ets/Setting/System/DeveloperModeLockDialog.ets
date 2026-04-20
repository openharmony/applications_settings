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

import { AlertDialog } from '@ohos.arkui.advanced.Dialog'
import UIExtensionContentSession from '@ohos.app.ability.UIExtensionContentSession';
import { LogUtil } from '@ohos/settings.common/src/main/ets/utils/LogUtil';
import DeveloperModeLock from '@ohos/settings.aboutdevice/src/main/ets/controller/DeveloperModeLock';

const TAG: string = 'DeveloperModeLockDialog : ';

const storage = LocalStorage.getShared();

@Entry(storage)
@Component
struct DeveloperModeLockDialog {
  dialogController?: CustomDialogController;

  aboutToAppear(): void {
    LogUtil.showInfo(TAG, 'aboutToAppear');
    this.dialogController = new CustomDialogController({
      builder: AlertDialog({
        primaryTitle: $r('app.string.developer_options_open_failed'),
        content: $r('app.string.network_not_connected'),
        primaryButton: {
          value: $r('app.string.dialog_cancel'),
          action: () => {
            LogUtil.showInfo(TAG, 'primary button pressed');
            this.closeDialog();
          },
          buttonStyle:ButtonStyleMode.TEXTUAL,
        },
        secondaryButton: {
          value: $r('app.string.unlock_device_offline'),
          action: () => {
            LogUtil.showInfo(TAG, 'secondary button pressed');
            let developerModeLock: DeveloperModeLock = new DeveloperModeLock();
            developerModeLock.openHsdrDialog();
            setTimeout(() => {
              this.closeDialog();
            }, 1000)
          },
          buttonStyle:ButtonStyleMode.TEXTUAL
        }
      }),
      cancel: () => {
        LogUtil.showInfo(TAG, 'cancel button pressed')
        this.closeDialog();
      },
      showInSubWindow: false,
      isModal: true,
      shadow: ShadowStyle.OUTER_DEFAULT_MD
    })
    this.dialogController.open();
  }

  aboutToDisappear(): void {
    LogUtil.showInfo(TAG, 'aboutToDisappear');
    // 手势上滑关闭走这里
    this.closeDialog();
  }

  onCancel() {
    LogUtil.showInfo(TAG, 'onCancel');
    this.closeDialog();
  }

  private closeDialog(): void {
    this.dialogController?.close();
    const session: UIExtensionContentSession | undefined = storage.get('session') as UIExtensionContentSession;
    session?.terminateSelf();
  }

  build() {
    Column() {
    }
    .width('100%')
    .height('100%')
  }
}
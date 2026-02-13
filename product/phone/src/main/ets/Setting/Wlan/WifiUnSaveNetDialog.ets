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

import { BusinessError } from '@ohos.base';
import UIExtensionContentSession from '@ohos.app.ability.UIExtensionContentSession';
import commonEventManager from '@ohos.commonEventManager';
import { LogUtil } from '@ohos/settings.common/src/main/ets/utils/LogUtil';
import { CommonEventConstant } from '@ohos/settings.common/src/main/ets/constant/CommonEventConstant';
import { CommonEventHelper } from '@ohos/settings.common/src/main/ets/utils/CommonEventHelper';
import UnSaveDialogConfirmComponent from '@ohos/settings.wifi/src/main/ets/component/UnSaveDialogConfirmComponent';
/* instrument ignore file */
const TAG: string = 'WifiUnSaveNetDialog : ';

@Entry
@Component
struct WifiUnSaveNetDialog {
  private hasClickButton: boolean = false;
  private subscribeInfo: commonEventManager.CommonEventSubscribeInfo = {
    events: [commonEventManager.Support.COMMON_EVENT_SCREEN_LOCKED],
  };
  private lockScreenEvent: CommonEventHelper = new CommonEventHelper(this.subscribeInfo, async (err, data) => {
    LogUtil.info(`${TAG} receive lockScreenEvent, hasClickButton: ${this.hasClickButton}`);
    if (!this.hasClickButton) {
      this.closeDialog(false);
    }
  });
  dialogController: CustomDialogController = new CustomDialogController({
    builder: UnSaveDialogConfirmComponent({
      cancel: () => {
        this.onCancel();
      },
      confirm: () => {
        this.onAccept();
      }
    }),
    cancel: undefined,
    autoCancel: false,
    alignment: DialogAlignment.Center,
  });

  onCancel() {
    LogUtil.info(`${TAG} onCancel`);
    this.hasClickButton = true;
    this.closeDialog(false);
  }

  onAccept() {
    LogUtil.info(`${TAG} onAccept`);
    this.hasClickButton = true;
    this.closeDialog(true);
  }

  closeDialog(continueJoin: boolean): void {
    try {
      commonEventManager.publish(CommonEventConstant.EVENT_WLAN_UN_SAVE_DIALOG, {
        parameters: {
          continueJoin: continueJoin,
        }
      }, (error: BusinessError) => {
        LogUtil.error(`${TAG} publish event error ${error?.message}`);
      });
      (AppStorage.get<UIExtensionContentSession>('wifiUnSaveDialogSession') as UIExtensionContentSession)?.terminateSelf();
    } catch (error) {
      LogUtil.error(`${TAG} destroyServiceExtensionAbility occur error ${error?.message}`);
    }
  }

  aboutToAppear(): void {
    LogUtil.info(`${TAG} aboutToAppear`);
    this.hasClickButton = false;
    this.lockScreenEvent.registerCommonEvent();
    this.dialogController.open();
  }

  aboutToDisappear(): void {
    LogUtil.info(`${TAG} aboutToDisappear, hasClickButton: ${this.hasClickButton}`);
    this.lockScreenEvent.unRegisterCommonEvent();
    // 手势上滑关闭走这里
    if (!this.hasClickButton) {
      this.closeDialog(false);
    }
  }

  build() {
    Column() {
    }
    .width('100%')
    .height('100%')
  }
}
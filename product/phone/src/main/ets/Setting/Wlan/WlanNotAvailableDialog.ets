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

import Base from '@ohos.base';
import commonEventManager from '@ohos.commonEventManager';
import type UIExtensionContentSession from '@ohos.app.ability.UIExtensionContentSession';
import { LogUtil } from '@ohos/settings.common/src/main/ets/utils/LogUtil';
import { PUBLISHER_PERMISSION_ACCESS_SYSTEM_SETTINGS } from '@ohos/settings.common/src/main/ets/utils/Consts';
import { CommonEventHelper } from '@ohos/settings.common/src/main/ets/utils/CommonEventHelper';
import lazy { AlertDialog } from '@ohos.arkui.advanced.Dialog';
/* instrument ignore file */
const TAG: string = 'WifiNotAvailableDialog :';

const WLAN_KEEP_CONNECTED: string = 'event.settings.wlan.keep_connected';

const DIALOG_CLOSE: string = 'event.settings.wlan.close_not_available_dialog';

const subscribeInfo: commonEventManager.CommonEventSubscribeInfo = {
  events: [DIALOG_CLOSE],
  publisherPermission: PUBLISHER_PERMISSION_ACCESS_SYSTEM_SETTINGS,
};

@Styles
function normalStateIconStyles() {
  .backgroundColor(Color.Transparent)
}

@Styles
function pressedStateIconStyles() {
  .backgroundColor($r('sys.color.interactive_click'))
  .borderRadius('12vp')
}

@CustomDialog
export struct dialogComponent {
  content: ResourceStr = '';
  cancelButtonText: ResourceStr = '';
  cancelButtonFunction: Function = () => {};
  confirmButtonText: ResourceStr = '';
  confirmButtonFunction: Function = () => {};
  controller: CustomDialogController;
  build() {
    Column() {
      Text(this.content)
        .fontFamily('HarmonyHeiTi')
        .fontSize($r('app.float.length_16'))
        .fontWeight(FontWeight.Regular)
        .fontColor($r('sys.color.font_primary'))
        .lineHeight('21vp')
        .margin({
          top: '24vp',
          right: '24vp',
          bottom: '8vp',
          left: '24vp',
        })
      Flex({
        justifyContent: FlexAlign.SpaceEvenly,
        alignItems: ItemAlign.Center
      }) {
        Button(this.cancelButtonText)
          .fontColor($r('sys.color.brand'))
          .fontSize($r('app.float.length_16'))
          .fontFamily('HarmonyHeiTi')
          .fontWeight(FontWeight.Regular)
          .width('calc(50% - 24vp)')
          .height('40vp')
          .stateStyles({
            normal: normalStateIconStyles,
            pressed: pressedStateIconStyles,
          })
          .onClick(() => {
            this.cancelButtonFunction();
          })
        Divider()
          .vertical(true)
          .strokeWidth(0.5)
          .margin({
            left: 7.5,
            right: 7.5,
          })
          .color($r('sys.color.comp_divider'))
          .height(24);
        Button(this.confirmButtonText)
          .fontColor($r('sys.color.brand'))
          .fontSize($r('app.float.length_16'))
          .fontFamily('HarmonyHeiTi')
          .fontWeight(FontWeight.Regular)
          .width('calc(50% - 24vp)')
          .height('40vp')
          .stateStyles({
            normal: normalStateIconStyles,
            pressed: pressedStateIconStyles,
          })
          .onClick(() => {
            this.confirmButtonFunction();
          })
      }.margin({ bottom: 16 })
    }
    .borderRadius('32vp')
  }
}

@Entry
@Component
export struct WifiNotAvailableDialog {
  dialogController: CustomDialogController = new CustomDialogController({
    builder: AlertDialog({
      content: $r('app.string.wifi_network_unavailable_text'),
      primaryButton: {
        value: $r('app.string.wifi_network_unavailable_not_use'),
        action: () => {
          this.onNotUseClick();
        },
      },
      secondaryButton: {
        value: $r('app.string.wifi_network_unavailable_use'),
        action: () => {
          this.onUseClick();
        }
      },
    }),
    cancel: () => {
    },
    onWillDismiss: (dismissDialogAction: DismissDialogAction) => {
      LogUtil.info(`${TAG} dialog onWillDismiss reason: ${dismissDialogAction.reason}`);
    },
    autoCancel: false,
    alignment: DialogAlignment.Center,
    maskColor: $r('sys.color.mask_fourth'),
  });

  private dialogCloseHelper: CommonEventHelper = new CommonEventHelper(subscribeInfo, (err, data) => {
    LogUtil.info(`${TAG} receive close dialog event.`);
    this.closeDialog();
  });

  build() {
  }

  aboutToAppear(): void {
    LogUtil.info(`${TAG} aboutToAppear`);
    this.dialogController?.open();
    this.dialogCloseHelper.registerCommonEvent();
  }

  aboutToDisappear(): void {
    LogUtil.info(`${TAG} aboutToDisappear`);
    this.dialogCloseHelper.unRegisterCommonEvent();
  }

  private onUseClick(): void {
    LogUtil.info(`${TAG} onUseClick`);
    const options: commonEventManager.CommonEventPublishData = {
      code: 1,
    };
    try {
      commonEventManager.publish(WLAN_KEEP_CONNECTED, options, (err: Base.BusinessError) => {
        if (err) {
          LogUtil.error(`${TAG} WLAN_KEEP_CONNECTED error. code:${err?.code} message:${err?.message}`);
          return;
        }
        LogUtil.info(`${TAG} WLAN_KEEP_CONNECTED success.`);
      });
    } catch (err) {
      LogUtil.error(`${TAG} WLAN_KEEP_CONNECTED catch error. code:${err?.code} message:${err?.message}`);
    }
    this.closeDialog();
  }

  private onNotUseClick(): void {
    LogUtil.info(`${TAG} onNotUseClick`);
    const options: commonEventManager.CommonEventPublishData = {
      code: 0,
    };
    try {
      commonEventManager.publish(WLAN_KEEP_CONNECTED, options, (err: Base.BusinessError) => {
        if (err) {
          LogUtil.error(`${TAG} WLAN_KEEP_CONNECTED error. code:${err?.code} message:${err?.message}`);
          return;
        }
        LogUtil.info(`${TAG} WLAN_KEEP_CONNECTED success.`);
      });
    } catch (err) {
      LogUtil.error(`${TAG} WLAN_KEEP_CONNECTED catch error. code:${err?.code} message:${err?.message}`);
    }
    this.closeDialog();
  }

  private closeDialog(): void {
    this.dialogController?.close();
    AppStorage.get<UIExtensionContentSession>('dialogSession')?.terminateSelf();
  }
}
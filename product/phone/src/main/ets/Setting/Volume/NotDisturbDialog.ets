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
import { LogUtil } from '@ohos/settings.common/src/main/ets/utils/LogUtil';
import UIExtensionContentSession from '@ohos.app.ability.UIExtensionContentSession';
import { NotDisturbUtils } from '@ohos/settings.notDisturb/src/main/ets/utils/NotDisturbUtils';
import { CommonEventHelper } from '@ohos/settings.common/src/main/ets/utils/CommonEventHelper';
/* instrument ignore file */
const TAG: string = 'NotDisturbDialog : ';

@Entry
@Component
struct NotDisturbDialog {
  private timerId: number | null = null;
  private delay: number = 500;
  private hasClickButton: boolean = false;
  private subscribeInfo: commonEventManager.CommonEventSubscribeInfo = {
    events: [commonEventManager.Support.COMMON_EVENT_SCREEN_LOCKED],
  };
  private lockScreenEvent: CommonEventHelper = new CommonEventHelper(this.subscribeInfo, async (err, data) => {
    LogUtil.info(`${TAG} receive lockScreenEvent, hasClickButton: ${this.hasClickButton}`);
    if (!this.hasClickButton) {
      this.closeDialog();
    }
  });

  dialogController: CustomDialogController = new CustomDialogController({
    builder: NotDisturbDialogPage({
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
    LogUtil.showInfo(TAG, 'onCancel');
    this.hasClickButton = true;
    this.closeDialog();
  }

  onAccept() {
    LogUtil.showInfo(TAG, 'onAccept');
    this.hasClickButton = true;
    NotDisturbUtils.setModeStatus(true);
    this.timerId = setTimeout(() => {
      this.timerId = null;
      this.closeDialog();
    }, this.delay);
  }

  private closeDialog(): void {
    try {
      (AppStorage.get<UIExtensionContentSession>('notDisturbDialogSession') as UIExtensionContentSession)?.terminateSelf();
    } catch (error) {
      LogUtil.error(`${TAG} destroyServiceExtensionAbility occur error ${error?.message}`);
    }
  }

  aboutToAppear(): void {
    LogUtil.showInfo(TAG, 'aboutToAppear');
    this.hasClickButton = false;
    this.lockScreenEvent.registerCommonEvent();
    this.dialogController.open();
  }

  aboutToDisappear(): void {
    LogUtil.info(`${TAG} aboutToDisappear`);
    this.lockScreenEvent.unRegisterCommonEvent();
    // 手势上滑关闭走这里
    if (!this.hasClickButton) {
      this.closeDialog();
    }
  }

  build() {
    Column() {
    }
    .width('100%')
    .height('100%')
  }
}


@CustomDialog
export default struct NotDisturbDialogPage {
  controller?: CustomDialogController;
  cancel: () => void = () => {
  };
  confirm: () => void = () => {
  };

  build() {
    Column() {
      Text($r('app.string.not_disturb_title'))
        .width('100%')
        .fontFamily('HarmonyHeiTi')
        .fontSize($r('sys.float.Title_S'))
        .constraintSize({
          minHeight: 56,
        })
        .padding({
          left: 24,
          right: 24,
        })
        .lineHeight(27)
        .maxFontScale(2)
        .fontColor($r('sys.color.font_primary'))
        .fontWeight(FontWeight.Bold)
        .textAlign(TextAlign.Center)
        .wordBreak(WordBreak.BREAK_WORD)

      Scroll() {
        Text($r('app.string.not_disturb_tips_dialog'))
          .fontFamily('HarmonyHeiTi')
          .fontWeight(FontWeight.Regular)
          .fontSize($r('sys.float.Body_L'))
          .fontColor($r('sys.color.font_primary'))
          .lineHeight(21)
          .width('100%')
          .textAlign(TextAlign.Start)
          .wordBreak(WordBreak.BREAK_WORD)
      }
      .scrollBar(BarState.Auto)
      .align(Alignment.TopStart)
      .edgeEffect(EdgeEffect.Spring)
      .constraintSize({
        maxHeight: '30%'
      })
      .padding({
        left: 24,
        right: 24
      })

      Row() {
        Button() {
          Text($r('app.string.dialog_cancel'))
            .fontFamily('HarmonyHeiTi')
            .fontSize($r('sys.float.Body_L'))
            .fontWeight(FontWeight.Medium)
            .maxFontScale(2)
            .fontColor($r('sys.color.font_emphasize'))
            .fontWeight(FontWeight.Bold)
            .textAlign(TextAlign.Center)
            .wordBreak(WordBreak.BREAK_WORD)
        }
        .constraintSize({
          minHeight: 40,
        })
        .layoutWeight(1)
        .backgroundColor(Color.Transparent)
        .onClick(() => {
          this.controller?.close();
          this.cancel();
        })

        Divider()
          .vertical(true)
          .strokeWidth(px2vp(2))
          .margin({
            left: 7.5,
            right: 7.5,
          })
          .color($r('sys.color.comp_divider'))
          .height(24);

        Button() {
          Text($r('app.string.dialog_enable'))
            .fontFamily('HarmonyHeiTi')
            .fontSize($r('sys.float.Body_L'))
            .fontWeight(FontWeight.Medium)
            .maxFontScale(2)
            .fontColor($r('sys.color.font_emphasize'))
            .fontWeight(FontWeight.Bold)
            .textAlign(TextAlign.Center)
            .wordBreak(WordBreak.BREAK_WORD)
        }
        .constraintSize({
          minHeight: 40,
        })
        .backgroundColor(Color.Transparent)
        .layoutWeight(1)
        .onClick(() => {
          this.controller?.close();
          this.confirm();
        })
      }
      .alignItems(VerticalAlign.Center)
      .width('100%')
      .constraintSize({
        minHeight: 40,
      })
      .padding({
        top: 8,
        left: 16,
        right: 16,
        bottom: 16
      })
    }
    .alignItems(HorizontalAlign.Center)
    .backgroundColor($r('sys.color.ohos_id_color_dialog_bg'))
    .backgroundBlurStyle(BlurStyle.COMPONENT_ULTRA_THICK)
  }
}
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
import { LogMaskUtil, LogUtil } from '@ohos/settings.common/src/main/ets/utils/LogUtil';
import { ResourceUtil } from '@ohos/settings.common/src/main/ets/utils/ResourceUtil';
import { DeviceUtil } from '@ohos/settings.common/src/main/ets/utils/BaseUtils';

const TAG: string = 'AutoPlayAuthDialog : ';

const DIALOG_WIDTH_PAD_PC: number = 400

const DIALOG_WIDTH_FOLD_EXPAND: number = 350;

@CustomDialog
export struct AutoPlayAuthDialog {
  controller?: CustomDialogController;
  private handleConfirmClick?: () => void;
  private handleForbiddenClick?: () => void;
  @State content: string = '';
  @State dialogWidth: number | string = '100%';

  build() {
    Column() {
      Column() {
        Text($r('app.string.auto_play_music'))
          .fontColor($r('sys.color.ohos_id_color_text_primary'))
          .fontSize($r('sys.float.ohos_id_text_size_headline8'))
          .fontWeight(FontWeight.Bold)
          .width('100%')
          .constraintSize({
            minHeight: '56vp',
          })
          .padding({
            left: '8vp',
            right: '8vp',
          })
          .fontWeight(FontWeight.Bold)
          .textAlign(TextAlign.Start)

        Text(this.content)
          .fontColor($r('sys.color.ohos_id_color_text_primary'))
          .fontSize($r('sys.float.ohos_id_text_size_body1'))
          .width('100%')
          .constraintSize({
            minHeight: '21vp',
          })
          .fontFamily('HarmonyHeiTi')
          .padding({
            left: '8vp',
            right: '8vp',
          })
          .fontWeight(FontWeight.Regular)
          .textAlign(TextAlign.Start)

        Text($r('app.string.auto_play_music_tips'))
          .fontColor($r('sys.color.ohos_id_color_text_secondary'))
          .opacity(0.6)
          .fontSize($r('sys.float.ohos_id_text_size_body2'))
          .width('100%')
          .lineHeight('19vp')
          .fontFamily('HarmonyHeiTi')
          .fontWeight(FontWeight.Regular)
          .padding({
            left: '8vp',
            right: '8vp',
          })
          .margin({
            top: '2vp',
          })
          .fontWeight(FontWeight.Regular)
          .textAlign(TextAlign.Start)

        Button($r('app.string.keep_auto_play'),
          {
            type: ButtonType.Capsule,
            stateEffect: true,
          })
          .fontColor($r('sys.color.ohos_id_color_foreground_contrary'))
          .fontSize('16vp')
          .fontFamily('HarmonyHeiTi')
          .fontWeight(FontWeight.Medium)
          .backgroundColor($r('sys.color.ohos_id_color_component_activated'))
          .width('100%')
          .height('40vp')
          .onClick(() => {
          })
          .margin({
            top: DeviceUtil.isDevicePc() ? '16vp' : '8vp',
          })
          .onClick(() => {
            LogUtil.info(`${TAG} click keep auto play.`);
            if (this.handleConfirmClick) {
              this.handleConfirmClick();
            }
            this.controller?.close();
          })

        Button($r('app.string.forbidding'),
          {
            type: ButtonType.Capsule,
            stateEffect: true,
          })
          .fontColor($r('sys.color.ohos_id_color_text_primary_activated'))
          .fontSize('16vp')
          .fontFamily('HarmonyHeiTi')
          .fontWeight(FontWeight.Medium)
          .width('100%')
          .backgroundColor(DeviceUtil.isDevicePc() ? $r('sys.color.ohos_id_color_button_normal') :
            $r('sys.color.ohos_id_color_dialog_bg'))
          .height('40vp')
          .onClick(() => {
          })
          .margin({
            top: DeviceUtil.isDevicePc() ? '8vp' : '4vp',
            bottom: DeviceUtil.isDevicePc() ? '24vp' : '8vp',
          })
          .onClick(() => {
            LogUtil.info(`${TAG} click forbidden auto play.`);
            if (this.handleForbiddenClick) {
              this.handleForbiddenClick();
            }
            this.controller?.close();
          })
      }
      .width(this.dialogWidth)
      .padding({
        left: '16vp',
        right: '16vp',
      })
      .borderRadius(DeviceUtil.isDevicePc() ? '16vp' : '32vp')
      .backgroundColor($r('sys.color.ohos_id_color_dialog_bg'))
    }
    .padding({
      left: '16vp',
      right: '16vp',
    })
  }

  async aboutToAppear(): Promise<void> {
    let deviceName = AppStorage.get<string>('bt_autoPlay_deviceName') || '';
    this.content = await ResourceUtil.getFormatString($r('app.string.bluetooth_connect_auto_play'), deviceName);
    LogUtil.info(`${TAG} aboutToAppear, deviceName: ${LogMaskUtil.getLogNickNameString(deviceName)}`);
    if (DeviceUtil.isDevicePc() || DeviceUtil.isDevicePad()) {
      this.dialogWidth = DIALOG_WIDTH_PAD_PC;
    } else if (DeviceUtil.isFoldExpand()) {
      this.dialogWidth = DIALOG_WIDTH_FOLD_EXPAND;
    }
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
}
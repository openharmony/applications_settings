/**
 * Copyright (c) 2024 Huawei Device Co., Ltd.
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
 * limitations under the License.   clickResponseTime   ignoreRepeatClick
 */

import UIExtensionContentSession from '@ohos.app.ability.UIExtensionContentSession';
import LogUtil from '../../../../../../../common/utils/src/main/ets/default/baseUtil/LogUtil';
import access from '@ohos.bluetooth.access';

const TAG = 'BluetoothDialog : 1';

@Entry
@Component
struct BluetoothSwitchWindowDialog {
  private bluetoothSwitchDialog: CustomDialogController = new CustomDialogController({
    builder: BluetoothSwitchDialog({}),
    alignment: DialogAlignment.Center,
    offset: ({ dx: 0, dy: '-40dp' }),
    autoCancel: true,
    customStyle: true,
    cancel: () => {
      let dialogSession: UIExtensionContentSession | undefined =
        AppStorage.get<UIExtensionContentSession>('accessibilityDialogSession');
      dialogSession?.terminateSelf();
    }
  });

  build() {
  }

  aboutToAppear(): void {
    this.bluetoothSwitchDialog.open();
  }
}


@CustomDialog
struct BluetoothSwitchDialog {
  controller?: CustomDialogController;
  @State allAbilityList: string[] = [];
  @State enabledAbilityList: string[] = [];
  title: ResourceStr = '';
  content: ResourceStr = '';
  bundleName: string = AppStorage.get<string>('BluetoothBundleName') as string;
  switchState: string = AppStorage.get<string>('bluetoothSwitchType') as string;

  build() {
    Column() {
      Text($r('app.string.bluetooth_app', this.bundleName))
        .fontFamily('HarmonyHeiTi')
        .textAlign(TextAlign.Center)
        .fontWeight(FontWeight.Bold)
        .fontSize(20)
        .lineHeight(27)
        .fontColor('#000000')
        .opacity(0.9)
        .constraintSize({
          minHeight: 27,
        })
        .width('100%')
        .padding({
          top: 15,
          bottom: 15,
        })
      Column() {
        Text($r('app.string.bluetooth_state', this.bundleName))
          .fontFamily('HarmonyHeiTi')
          .fontWeight(FontWeight.Regular)
          .fontSize(16)
          .lineHeight(21)
          .fontColor($r('sys.color.font_primary'))
          .constraintSize({
            minHeight: 21,
          })
      }
      .width('100%')
      .height(21)
      .margin({
        bottom: 8
      })
      .alignItems(HorizontalAlign.Center)


      Row() {
        Button() {
          Text($r('app.string.refuse'))
            .fontFamily('HarmonyHeiTi')
            .fontWeight(FontWeight.Medium)
            .fontSize($r('sys.float.Body_L'))
            .fontColor($r('sys.color.font_emphasize'))
            .lineHeight(21)
        }
        .layoutWeight(1)
        .backgroundColor(Color.Transparent)
        .onClick(() => {
          access.disableBluetooth();
          this.onDialogClose();
        })
        .width(140)
        .height(40)
        .margin({
          bottom: 16,
        })


        Button() {
          Text($r('app.string.open'))
            .fontFamily('HarmonyHeiIi')
            .fontWeight(FontWeight.Medium)
            .fontSize($r('sys.float.Body_L'))
            .fontColor($r('sys.color.font_emphasize'))
        }
        .onClick(() => {
          let state = access.getState();
          if (state == 2) {
            this.onDialogClose();
          } else {
            LogUtil.info(`${TAG} enableBluetooth before open `);
            access.enableBluetooth();
            LogUtil.info(`${TAG} enableBluetooth after open `);
            this.onDialogClose();
          }
        })
        .layoutWeight(1)
        .backgroundColor(Color.Transparent)
        .width(140)
        .height(40)
        .margin({
          bottom: 16,
        })

      }
    }
    .backgroundColor($r('sys.color.ohos_id_color_dialog_bg'))
    .backgroundBlurStyle(BlurStyle.COMPONENT_ULTRA_THICK)
    .saturate(0.9)
    .alignItems(HorizontalAlign.Start)
    .borderRadius($r('sys.float.corner_radius_level16'))
    .width(400)
  }

  onDialogClose(): void {
    LogUtil.info(`${TAG} onDialogClose in`);
    this.controller?.close();
    let dialogSession: UIExtensionContentSession | undefined =
      AppStorage.get<UIExtensionContentSession>('accessibilityDialogSession');
    dialogSession?.terminateSelf();
  }

  aboutToAppear(): void {
    LogUtil.info(`[${TAG}] aboutToAppear`);
  }

  aboutToDisappear(): void {
    LogUtil.info(`${TAG} dialog aboutToDisappear in`);
  }
}
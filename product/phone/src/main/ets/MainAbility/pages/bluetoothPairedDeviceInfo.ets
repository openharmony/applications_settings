/**
 * Copyright (c) 2021 Huawei Device Co., Ltd.
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

import ConfigData from '../../../../../../../common/utils/src/main/ets/default/baseUtil/ConfigData';
import HeadComponent from '../../../../../../../common/component/src/main/ets/default/headComponent';
import Router from '@system.router';
import LogUtil from '../../../../../../../common/utils/src/main/ets/default/baseUtil/LogUtil';
import BluetoothDevice from '../model/bluetoothImpl/BluetoothDevice';
import BluetoothDeviceController from '../controller/bluetooth/BluetoothDeviceController'
import Log from '../../../../../../../common/utils/src/main/ets/default/baseUtil/LogDecorator';

let param;
/**
 * BluetoothPairedDeviceInfo
 */
@Entry
@Component
struct BluetoothPairedDeviceInfo {
  @State bluetoothDevice: BluetoothDevice = undefined;
  private controller: BluetoothDeviceController = new BluetoothDeviceController()
  @State isTouched: boolean = false;

  @Log
  aboutToAppear() {
    param = Router.getParams();
    this.bluetoothDevice = JSON.parse(param.bluetoothDevice);
    LogUtil.log(ConfigData.TAG + "aboutToAppear bluetoothDevice: " + JSON.stringify(this.bluetoothDevice));
  }

  build() {
    Column() {
      GridContainer({
        columns: 12,
        sizeType: SizeType.Auto,
        gutter: vp2px(1) === 2 ? '12vp' : '0vp',
        margin: vp2px(1) === 2 ? '24vp' : '0vp'
      }) {
        Row({}) {
          Column() {
          }
          .width(ConfigData.WH_100_100)
          .height(ConfigData.WH_100_100)
          .useSizeType({
            xs: { span: 0, offset: 0 }, sm: { span: 0, offset: 0 },
            md: { span: 0, offset: 0 }, lg: { span: 2, offset: 0 }
          });
          Column() {
            HeadComponent({ headName: this.bluetoothDevice.deviceName, isActive: true });
            Blank()
            Row() {
              Button() {
                Text($r("app.string.cancelPairing"))
                  .fontSize($r('app.float.application_button_subtitle_size'))
                  .fontColor(Color.Blue)
              }
              .backgroundColor($r('app.color.color_E3E3E3_grey'))
              .width($r("app.float.paired_device_button_width"))
              .height($r("app.float.wh_value_40"))
              .align(Alignment.Center)
              .onTouch((event: TouchEvent) => {
                if (event.type === TouchType.Down) {
                  this.isTouched = true;
                }
                if (event.type === TouchType.Up) {
                  this.isTouched = false;
                }
              })
              .onClick(() => {
                LogUtil.log(ConfigData.TAG + "unpair onClick");
                if (this.controller.unpair(this.bluetoothDevice.deviceId)) {
                  Router.back();
                }
              })
            }.margin({ bottom: $r('app.float.distance_24'), top: $r("app.float.distance_8") });
          }
          .backgroundColor($r("sys.color.ohos_id_color_sub_background"))
          .padding({ left: $r('app.float.wh_24'), right: $r('app.float.wh_24') })
          .height(ConfigData.WH_100_100)
          .width(ConfigData.WH_100_100)
          .useSizeType({
            xs: { span: 12, offset: 0 }, sm: { span: 12, offset: 0 },
            md: { span: 12, offset: 0 }, lg: { span: 8, offset: 2 }
          });

          Column() {
          }
          .width(ConfigData.WH_100_100)
          .height(ConfigData.WH_100_100)
          .useSizeType({
            xs: { span: 0, offset: 12 }, sm: { span: 0, offset: 12 },
            md: { span: 0, offset: 12 }, lg: { span: 2, offset: 10 }
          })
        }
        .width(ConfigData.WH_100_100)
        .height(ConfigData.WH_100_100);
      }
      .width(ConfigData.WH_100_100)
      .height(ConfigData.WH_100_100);
    }
    .backgroundColor($r("sys.color.ohos_id_color_sub_background"))
    .width(ConfigData.WH_100_100)
    .height(ConfigData.WH_100_100);
  }
}




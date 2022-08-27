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

import ConfigData from '../../../../../../common/utils/src/main/ets/default/baseUtil/ConfigData';
import HeadComponent from '../../../../../../common/component/src/main/ets/default/headComponent';
import Router from '@system.router';
import LogUtil from '../../../../../../common/utils/src/main/ets/default/baseUtil/LogUtil';
import BluetoothDevice from '../model/bluetoothImpl/BluetoothDevice';
import BluetoothDeviceController from '../controller/bluetooth/BluetoothDeviceController'
import Log from '../../../../../../common/utils/src/main/ets/default/baseUtil/LogDecorator';

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
  }

  build() {
    Column() {
      GridContainer({ gutter: 12, margin: 12 }) {
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
        .width(ConfigData.WH_100_100)
        .height(ConfigData.WH_100_100)
        .useSizeType({
          sm: { span: 4, offset: 0 },
          md: { span: 6, offset: 1 },
          lg: { span: 8, offset: 2 }
        });
      }
    }
    .backgroundColor($r("sys.color.ohos_id_color_sub_background"))
    .width(ConfigData.WH_100_100)
    .height(ConfigData.WH_100_100);
  }
}




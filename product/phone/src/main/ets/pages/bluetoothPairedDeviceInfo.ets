/**
 * Copyright (c) 2021-2022 Huawei Device Co., Ltd.
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

import Router from '@system.router';
import BluetoothDevice from '../model/bluetoothImpl/BluetoothDevice';
import BluetoothDeviceController from '../controller/bluetooth/BluetoothDeviceController';
import LogUtil from '../../../../../../common/utils/src/main/ets/default/baseUtil/LogUtil';
import Log from '../../../../../../common/utils/src/main/ets/default/baseUtil/LogDecorator';
import ConfigData from '../../../../../../common/utils/src/main/ets/default/baseUtil/ConfigData';
import HeadComponent from '../../../../../../common/component/src/main/ets/default/headComponent';

let param;

/**
 * BluetoothPairedDeviceInfo
 */
@Entry
@Component
struct BluetoothPairedDeviceInfo {
  @State bluetoothDevice: BluetoothDevice = undefined;
  @State isTouched: boolean = false;
  private controller: BluetoothDeviceController = new BluetoothDeviceController()

  @Log
  aboutToAppear() {
    param = Router.getParams();
    this.bluetoothDevice = JSON.parse(param.bluetoothDevice);
  }

  build() {
    Column() {
      GridContainer({ gutter: ConfigData.GRID_CONTAINER_GUTTER_24, margin: ConfigData.GRID_CONTAINER_MARGIN_24 }) {
        Column() {
          HeadComponent({ headName: this.bluetoothDevice.deviceName, isActive: true });

          Blank()

          Button() {
            Text($r("app.string.cancelPairing"))
              .fontSize($r('app.float.application_button_subtitle_size'))
              .fontColor($r("app.color.font_color_007DFF"))
          }
          .backgroundColor($r('sys.color.ohos_id_color_button_normal'))
          .width($r("app.float.component_button_width"))
          .height($r("app.float.wh_value_40"))
          .align(Alignment.Center)
          .onClick(() => {
            LogUtil.log(ConfigData.TAG + "unpair onClick");
            if (this.controller.unpair(this.bluetoothDevice.deviceId)) {
              Router.back();
            }
          })
          .margin({ bottom: $r('app.float.distance_24'), top: $r("app.float.distance_8") });
        }
        .height(ConfigData.WH_100_100)
        .useSizeType({
          sm: { span: 4, offset: 0 },
          md: { span: 6, offset: 1 },
          lg: { span: 8, offset: 2 }
        })
      }
      .width(ConfigData.WH_100_100)
      .height(ConfigData.WH_100_100);
    }
    .backgroundColor($r("sys.color.ohos_id_color_sub_background"))
    .width(ConfigData.WH_100_100)
    .height(ConfigData.WH_100_100);
  }
}

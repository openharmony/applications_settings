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

import HeadComponent from '../../../../../../../common/component/src/main/ets/default/headComponent.ets';
import SwitchComponent from '../../../../../../../common/component/src/main/ets/default/switchComponent.ets';
import UsbDebuggingController from '../controller/developerOptions/UsbDebuggingController.ets'

/**
 * Developer options
 */
@Entry
@Component
struct developerOptions {
  @State isOn: boolean = false;
  private controller: UsbDebuggingController = new UsbDebuggingController();

  build() {
    Column() {
      HeadComponent({ headName: $r("app.string.developerOptionsTab"), isActive: true });
      SwitchComponent({
        title: $r("app.string.usbDebugging"),
        isOn: $isOn,
        controller: this.controller
      })
    }
  }
}
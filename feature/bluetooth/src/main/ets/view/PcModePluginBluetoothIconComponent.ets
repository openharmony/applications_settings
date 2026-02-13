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
import { LogUtil } from '@ohos/settings.common/src/main/ets/utils/LogUtil';
import { BlueToothState, IconMap } from '../constants/BluetoothConstants';
import { pcModeBlueToothViewModel } from '../model/PcModeBluetoothViewModel';

const TAG: string = 'PcModePluginBluetoothIconComponent : ';
const PLUGIN_BLUETOOTH_ICON: string = 'plugin_image_plugin_bluetooth_icon';

@Component
export struct PcModePluginBluetoothIconComponent {
  private isWhite: boolean = false;
  @State iconName: Resource =
    this.isWhite ? $r('app.media.ic_bluetooth_state_on_white') : $r('app.media.ic_bluetooth_state_on');

  build() {
    Row() {
      Image(this.iconName)
        .width('100%')
        .height('100%')
        .objectFit(ImageFit.Contain)
        .interpolation(ImageInterpolation.Medium)
        .id(PLUGIN_BLUETOOTH_ICON)
        .draggable(false);
    }
    .width('100%')
    .height('100%')
  }

  aboutToAppear(): void {
    // 初始化状态栏蓝牙图标
    LogUtil.info(`${TAG} register onBluetoothStateChange`);
    pcModeBlueToothViewModel.registerBluetoothStateChangeCallBack(this.bluetoothStateChangeCallBack);

    let iconState: BlueToothState | undefined = pcModeBlueToothViewModel.initState();
    if (iconState === undefined) {
      LogUtil.error(`${TAG} initIconState wrong`);
      return;
    }
    this.refreshIcon(iconState);
  }

  aboutToDisappear(): void {
    LogUtil.info(`${TAG} unregister onBluetoothStateChange`);
    pcModeBlueToothViewModel.unregisterBluetoothStateChangeCallBack(this.bluetoothStateChangeCallBack);
  }

  bluetoothStateChangeCallBack = (state: BlueToothState): void => {
    LogUtil.info(`${TAG} onBluetoothStateChange , status : ${state}`);
    this.refreshIcon(state);
  }

  private refreshIcon(iconState: BlueToothState) {
    this.iconName = this.isWhite ? IconMap.whiteIconStateMap.get(iconState) as Resource :
      IconMap.blackIconStateMap.get(iconState) as Resource;
  }
}
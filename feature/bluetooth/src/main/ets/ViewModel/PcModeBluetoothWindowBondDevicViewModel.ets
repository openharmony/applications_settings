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
import access from '@ohos.bluetooth.access';
import { BluetoothUtils } from '@ohos/settings.common/src/main/ets/utils/BluetoothUtils';
import { CheckEmptyUtils } from '@ohos/settings.common/src/main/ets/utils/CheckEmptyUtils';
import { LogUtil } from '@ohos/settings.common/src/main/ets/utils/LogUtil';
import StatusbarPanelUtil from '@ohos/settings.commonUikit/src/main/ets/utils/StatusbarPanelUtil';
import { WindowManager } from '@ohos/settings.common/src/main/ets/window/WindowManager';
import { BluetoothAdapter } from '../BluetoothAdapter';
import { BondStateParam } from '../model/BluetoothModel';
import { BluetoothWindowBondDeviceViewModel } from './BluetoothWindowBondDeviceViewModel';
import { MenuEntry } from '../model/MenuEntry';
import { PLUGIN_BLUETOOTH_ICON_URL } from '../constants/BluetoothConstants';

export const DEVICE_ITEM_SPACE: number = 2; // 两个设备item中间的间距
const TITLE_AND_SWITCH_HEIGHT: number = 56; // 标题栏高度
const NO_PAIRED_DEVICES_HEIGHT: number = 40; // “没有已配对设备”字串高度
const PAIRED_DEVICE_HEIGHT: number = 32; // “已配对设备”字串高度
const DIVIDER_HEIGHT: number = 9; // 分割线字串高度
const BUTTON_HEIGHT: number = 40; // “蓝牙设置”按钮高度
const BUTTON_BOTTOM_MARGIN: number = 4; // “蓝牙设置”按钮底部边距
const CONNECTED_DEVICE_ITEM_HEIGHT: number = 40; // 已连接设备item高度
const CONNECTING_DEVICE_ITEM_HEIGHT: number = 56; // 正在连接设备item高度
const DIALOG_MAX_HEIGHT: number = StatusbarPanelUtil.getWindowPanelMaxHeight();

@Observed
export class PcModeBluetoothWindowBondDeviceViewModel extends BluetoothWindowBondDeviceViewModel {
  public tag: string = 'PcModeBluetoothWindowBondDeviceViewModel : ';
  public currentPluginWindowHeight: number = 119;

  init(bondDevicesMenu: MenuEntry[]): void {
    LogUtil.info(`${this.tag} init`);
    super.init(bondDevicesMenu);
    this.updatePluginWindowHeight(BluetoothAdapter.getInstance().currentState);
  }

  onBluetoothStateChange(state: number) {
    LogUtil.info(`${this.tag} switch state change: ${state}`);
    super.onBluetoothStateChange(state);
    if (BluetoothUtils.isBluetoothStateOn(state) || BluetoothUtils.isBluetoothStateOff(state)) {
      this.updatePluginWindowHeight(state);
    }
  }

  onBluetoothBondStateChange(stateParam: BondStateParam) {
    if (!stateParam || !stateParam.deviceId) {
      LogUtil.error(`${this.tag} bond state change, stateParam is invalid`);
      return;
    }

    LogUtil.info(`${this.tag} bond state change: ${BluetoothUtils.getLogMAC(stateParam.deviceId)}, state: ${stateParam.state}`);
    super.onBluetoothBondStateChange(stateParam);
    this.updatePluginWindowHeight(access.BluetoothState.STATE_ON);
  }

  public updatePluginWindowHeight(state?: number): void {
    LogUtil.info(`${this.tag} updatePluginWindowHeight, state: ${state}, bondDevicesNumber: ${this.bondDevicesMenu?.length}`);
    let height: number;
    let isOn: boolean = this.isStateOn(state);
    if (isOn) { // 开关打开
      if (!this.bondDevicesMenu || this.bondDevicesMenu.length === 0) {
        height =
          TITLE_AND_SWITCH_HEIGHT + NO_PAIRED_DEVICES_HEIGHT + DIVIDER_HEIGHT + BUTTON_HEIGHT + BUTTON_BOTTOM_MARGIN;
      } else {
        height = this.getBondedDevicesHeight() + TITLE_AND_SWITCH_HEIGHT + PAIRED_DEVICE_HEIGHT + DIVIDER_HEIGHT +
          BUTTON_HEIGHT + BUTTON_BOTTOM_MARGIN;
      }
    } else { // 开关关闭
      height = TITLE_AND_SWITCH_HEIGHT + DIVIDER_HEIGHT + BUTTON_HEIGHT + BUTTON_BOTTOM_MARGIN;
    }
    // 限制面板最大高度
    height = Math.min(DIALOG_MAX_HEIGHT, height)
    if (height === this.currentPluginWindowHeight) {
      LogUtil.info(`${this.tag} not need to updatePluginWindowHeight, height not change ${height}`);
      return;
    }

    this.currentPluginWindowHeight = height;
    LogUtil.info(`${this.tag} updatePluginWindowHeight: ${height}, state: ${state}, isOn: ${isOn}`);
    WindowManager.updatePluginWindowHeight(PLUGIN_BLUETOOTH_ICON_URL, height);
  }

  getListenKey(): string {
    return 'pc_window_bond_device_view_model';
  }

  private getBondedDevicesHeight(): number {
    let hasSubtitleMenuNum: number = this.getHasSubtitleMenuNum();
    LogUtil.info(`${this.tag} getBondedDevicesHeight, hasSubtitleMenuNum: ${hasSubtitleMenuNum}`);
    return hasSubtitleMenuNum * CONNECTING_DEVICE_ITEM_HEIGHT +
      (this.bondDevicesMenu.length - hasSubtitleMenuNum) * CONNECTED_DEVICE_ITEM_HEIGHT +
      (this.bondDevicesMenu.length - 1) * DEVICE_ITEM_SPACE;
  }

  private getHasSubtitleMenuNum(): number {
    let num: number = 0;
    for (let menu of this.bondDevicesMenu) {
      if (!CheckEmptyUtils.isEmpty(menu.subTitle) && !menu.isConnect) {
        num++;
      }
    }
    return num;
  }

  private isStateOn(state?: number): boolean {
    if (!state) {
      return BluetoothUtils.isBluetoothOn();
    }

    return BluetoothUtils.isBluetoothStateOn(state);
  }
}
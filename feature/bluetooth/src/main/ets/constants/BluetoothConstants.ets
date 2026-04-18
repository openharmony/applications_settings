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

export enum AccessAuthorization {
  UNKNOWN = 0,
  ALLOWED = 1,
  REJECTED = 2,
}

export enum ShareType {
  SHARE_NAME_AND_PHONE_NUMBER = 0,
  SHARE_ALL = 1,
  SHARE_NOTHING = 2
}

/**
 * IconId为十六进制
 */
export const HEX_RADIX = 16;

/**
 * 无效资源名errorCode
 */
export const INVALID_RESOURCE_CODE = '9001003';

export const PLUGIN_BLUETOOTH_ICON_URL: string = 'Setting/Bluetooth/view/PcModePluginBluetoothIcon.js';

export const enum BlueToothState {
  ON,
  OFF,
  CONNECTED
};

/**
 * 助听器蓝牙profile特征值
 */
export const HEARING_AID_UUID: string = '0000FDF0-0000-1000-8000-00805F9B34FB';

export class IconMap {
  public static readonly blackIconStateMap: Map<BlueToothState, Resource> = new Map([
    [BlueToothState.ON, $r('app.media.ic_bluetooth_state_on')],
    [BlueToothState.OFF, $r('app.media.ic_bluetooth_state_off')],
    [BlueToothState.CONNECTED, $r('app.media.ic_bluetooth_state_connected')]
  ]);
  public static readonly whiteIconStateMap: Map<BlueToothState, Resource> = new Map([
    [BlueToothState.ON, $r('app.media.ic_bluetooth_state_on_white')],
    [BlueToothState.OFF, $r('app.media.ic_bluetooth_state_off_white')],
    [BlueToothState.CONNECTED, $r('app.media.ic_bluetooth_state_connected_white')]
  ]);
}
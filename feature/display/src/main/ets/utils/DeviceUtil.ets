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
import { LogUtil } from '@ohos/settings.common/src/main/ets/utils/LogUtil';

const TAG = 'DEVICE_UTIL ';

export enum DeviceType {
  TYPE_PC = 0x0C,
  TYPE_PHONE = 0x0E,
  TYPE_TABLET = 0x11,
  TYPE_2IN1 = 0xA2F,
  TYPE_UNKNOWN = 0x0
}

/**
 * 设备信息类
 */
export class RemoteDeviceInfo {
  public mDeviceName: string = '';
  public mDeviceId: string = '';
  public mNetworkId: string = '';
  public mDeviceType: number = 0;
  public mDeviceLocation: number = -1;
  public isSwitchOpen: boolean = false;
  public isLocalDevice: boolean = false;
  public isMainDevice: boolean = false; // 是否 首个发起建连的设备
  public isSupportThirdDevice: boolean = false;
  public mAddStatus: AddStatus = AddStatus.NOT_ADD;
  public mErrorCode: number = 0;
  public isScreenOn: boolean = true;
  public mErrorMessage: string = '';
  public isEstablished?: boolean;

  constructor(deviceName: string, deviceId: string, networkId: string, deviceType: number) {
    this.mDeviceName = deviceName;
    this.mDeviceId = deviceId;
    this.mNetworkId = networkId;
    this.mDeviceType = deviceType;
  }
}

export enum AddType {
  ADD = 0, // 添加
  REDUCE = 1, // 减少
}

export enum SwitchCode {
  WRITE_SWITCH = 0,
  SET_SETTING_STUB = 1,
  DATA_INIT_STATUS = 2,
  REFRESH_DEVICE_INFOS = 3,
  DRAG_POSITION = 4,
  GET_REMOTE_INFO = 5,
  MAIN_ABILITY_DESTORY = 6,
  GET_DEVICE_LIST = 7, // 本机、组网设备（包含已穿越设备）
  WRITE_EDGE_SWITCH = 8, // 变更 边缘穿越开关
  CLOSE_CAPSULE_DISCONNECT_DEVICE = 9, // 点击关闭胶囊，断开连接
  UPDATE_DEVICE_ADD_STATE = 10, // 更新设备添加状态
  REFRESH_ERROR_STATE = 11, // 刷新异常状态
  REFRESH_DEVICE_POSITION = 12, // 刷新设备坐标信息
  SET_SCREEN_SOURCE_MODE = 13, // 设置屏幕模式
  NOTICE_COLLABORATION_BIND_SERVICE = 18
}

export enum AddStatus {
  NOT_ADD = 0, // 未添加
  ADDING = 1, // 添加中
  ADDED = 2, // 已添加
  ERROR = 4 // 添加设备出错
}
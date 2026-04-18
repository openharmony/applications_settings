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
// import hearingAid from '@hms.bluetooth.hearingAid';
import { ArrayList } from '@kit.ArkTS';
import { BusinessError, Callback } from '@ohos.base';
import bluetooth from '@ohos.bluetooth';
import a2dp from '@ohos.bluetooth.a2dp';
import baseProfile from '@ohos.bluetooth.baseProfile';
import connection from '@ohos.bluetooth.connection';
import constant from '@ohos.bluetooth.constant';
import hfp from '@ohos.bluetooth.hfp';
import hid from '@ohos.bluetooth.hid';
import map from '@ohos.bluetooth.map';
import pbap from '@ohos.bluetooth.pbap';
import bluetoothManager from '@ohos.bluetoothManager';
import CommonEvent from '@ohos.commonEvent';
import commonEventManager from '@ohos.commonEventManager';
import { DeviceNameUtil } from '@ohos/settings.common';
import { Controller, PushParam } from '@ohos/settings.common/src/main/ets/core/controller/Controller';
import { SwitchMenuController } from '@ohos/settings.common/src/main/ets/core/controller/MenuController';
import { SwitchMenuStyle } from '@ohos/settings.common/src/main/ets/core/model/menu/BaseMenu';
import { ContainerStyle, TextStyle } from '@ohos/settings.common/src/main/ets/core/model/menu/ComponetStyle';
import { SettingsBaseMenu } from '@ohos/settings.common/src/main/ets/core/model/menu/SettingsMenu';
import { EventBus } from '@ohos/settings.common/src/main/ets/framework/common/EventBus';
import {
  HiSysAboutBluetoothEventGroup,
  HiSysBluetoothEventGroup
} from '@ohos/settings.common/src/main/ets/systemEvent/BehaviorEventConsts';
import { HiSysEventUtil } from '@ohos/settings.common/src/main/ets/systemEvent/HiSysEventUtil';
import { BluetoothUtils, DisconnectCause } from '@ohos/settings.common/src/main/ets/utils/BluetoothUtils';
import { CheckEmptyUtils } from '@ohos/settings.common/src/main/ets/utils/CheckEmptyUtils';
import { CommonEventHelper } from '@ohos/settings.common/src/main/ets/utils/CommonEventHelper';
import { LogMaskUtil, LogUtil } from '@ohos/settings.common/src/main/ets/utils/LogUtil';
import { BluetoothSwitchToggleStyle } from '@ohos/settings.uikit/src/main/ets/menus/Menu';
import {
  BluetoothDevice,
  BondState,
  BondStateParam,
  PinRequiredParam,
  ProfileConnectionState,
  ProfileId,
  StateChangeParam,
  VolumeSyncParam
} from './model/BluetoothModel';
import { Utils } from './utils/Utils';

const TAG: string = 'BluetoothAdapter : ';
const DELAY_DISCOVERY_STATE_TIME: number = 200;
const DELAY_DISCOVERY_START_TIME_PAIR_FINISH: number = 1000;
const DELAY_DISCOVERY_START_DISCOVERY_TIME: number = 2000;
const DELAY_DISCOVERY_STATE_RETRY_TIME: number = 3000;
const DISCOVERY_RETRY_COUNT: number = 5;
const PROFILE_A2DP_SOURCE: number = 1;
const PROFILE_HANDS_FREE_AUDIO_GATEWAY: number = 4;
const PROFILE_HID_HOST: number = 6;
const PROFILE_HEARING_AID: number = 21;
const CONNECT_RESULT_SUCCESS: number = 1;
const CONNECT_RESULT_FAILED: number = -1;
const A2DP_DEVICE_KEY: string = 'a2dp_device_key';
const HID_DEVICE_KEY: string = 'hid_device_key';
const HFP_DEVICE_KEY: string = 'hfp_device_key';
const HEIGHT_64: string = '64vp';
const HEIGHT_48: string = '48vp';
const FRESH_TITLE_TIME_OUT: number = 200;
const FRESH_PROFILE_TIME_OUT: number = 1000;
const CONNECT_TASK_TIME_OUT: number = 3000;
const HEARINGAID_CONNECT_TASK_TIME_OUT: number = 15000;

export type ConnectionProfile = a2dp.A2dpSourceProfile | hfp.HandsFreeAudioGatewayProfile | hid.HidHostProfile;

export type PbapServerProfile = pbap.PbapServerProfile

export type MapMseProfile = map.MapMseProfile

export enum ConnectionStrategy {
  CONNECTION_STRATEGY_UNSUPPORTED = 0,
  CONNECTION_STRATEGY_ALLOWED = 1,
  CONNECTION_STRATEGY_FORBIDDEN = 2,
}

export enum BluetoothPinRequiredConfirmType {
  DevicePinCode = 1,
  DevicePairingConfirmation = 2,
  DefaultConfirm = 3
}

enum SummaryStatus {
  OPERATING = 'operating',
  DONE = 'done',
}

/**
 * 蓝牙开关状态监听接口
 *
 * @since 2022-05-20
 */
export interface BluetoothStateChangeListener {

  getListenKey(): string;

  /**
   * 蓝牙开关状态变化回调
   */
  onBluetoothStateChange(state: number): void;
}

export interface BluetoothRemoveSummaryListener {

  getListenKey(): string;

  /**
   * 蓝牙开关状态变化回调
   */
  onRemoveSummary(deviceId: string): void;
}

/**
 * 蓝牙远端设备状态监听接口
 *
 * @since 2022-05-20
 */
export interface BluetoothDeviceChangeListener {

  getListenKey(): string;

  /**
   * 设备新增回调
   */
  onDeviceAdded(device: BluetoothDevice): void;

  /**
   * 设备属性刷新回调
   */
  onDeviceAttributesChanged(device: BluetoothDevice): void;

  /**
   * 设备删除回调
   */
  onDeviceDeleted(device: BluetoothDevice): void;

  /**
   * 可用设备刷新回调
   */
  onAvailableDevicesRefresh(): void;

  /**
   * 清空可用设备回调
   */
  onAvailableDeviceClear(): void;
}

/**
 * 已配对设备变化监听
 * @since 2025-07-15
 */
export interface BluetoothBondedDeviceChangeListener {

  getListenKey(): string;

  /**
   * 已配对的设备合并
   *
   * @param device 被合并的设备（指被删除）
   */
  onBondedDeviceMerged(device: BluetoothDevice): void;
}

export interface BluetoothDeviceNameUpdateListener {

  getListenKey(): string;

  /**
   * 设备名称更新回调
   */
  onDeviceNameUpdate(device: BluetoothDevice): void;
}

/**
 * 蓝牙设备配对状态监听接口
 *
 * @since 2022-05-20
 */
export interface BluetoothBondChangeListener {

  getListenKey(): string;

  /**
   * 蓝牙配对状态变化回调
   */
  onBluetoothBondStateChange(stateParam: BondStateParam): void;

  /**
   * 配对请求回退
   */
  onBluetoothPinRequired(pinRequiredParam: PinRequiredParam): void;

  /**
   * 配对结果回退
   */
  onPairResult(deviceId: string, result: number, isSuccess: boolean): void;
}

export interface BluetoothLoadStateChangeListener {

  getListenKey(): string;

  /**
   * 加载动画状态回调
   */
  onChangeLoadingStatus(status: boolean): void;
}

/**
 * 蓝牙设备协议连接状态监听接口
 *
 * @since 2022-05-20
 */
export interface BluetoothProfileStateChangeListener {

  getListenKey(): string;

  /**
   * 协议连接状态变化回退
   */
  onBluetoothProfileStateChange(profileId: ProfileId, stateChangeParam: StateChangeParam): void;

  /**
   * 连接结果回退
   */
  onConnectResult(deviceId: string, result: number, isSuccess: boolean): void;
}

/**
 * 蓝牙设备缓存管理
 *
 * @since 2022-05-20
 */
export class CachedBluetoothDeviceManager {
  private cachedDevices: Map<string, BluetoothDevice> = new Map();

  getCachedDevices(): IterableIterator<BluetoothDevice> {
    return this.cachedDevices.values();
  }

  findDevice(deviceId: string): BluetoothDevice {
    return this.cachedDevices.get(deviceId) as BluetoothDevice;
  }

  /**
   * 添加设备到缓存，是个新设备则返回true，附属设备返回false
   *
   * @param device 要添加的网络
   */
  addDevice(device: BluetoothDevice): boolean {
    if (device && device.deviceId) {
      this.cachedDevices.set(device.deviceId, device);
    }
    return true;
  }

  /**
   * 获取缓存列表的个数
   *
   * @returns 缓存列表的个数
   */
  getDeviceCount(): number {
    return this.cachedDevices.size;
  }

  removeDevice(deviceId: string): boolean {
    return this.cachedDevices.delete(deviceId);
  }

  clear(): void {
    this.cachedDevices.clear();
  }
}

/**
 * 标记设置主动配对的蓝牙外设
 *
 * @since 2024-10-09
 */
export class ConnectTimestampManager {
  private bondedFromLocalMap: Map<string, boolean> = new Map();
  private connectTimestampMap: Map<string, number> = new Map();

  getDeviceBondedFromLocalDevices(): IterableIterator<string> {
    return this.bondedFromLocalMap.keys();
  }

  setDeviceBondedFromLocal(deviceId: string): void {
    this.bondedFromLocalMap.set(deviceId, true);
  }

  checkIsBondedFromLocal(deviceId: string): boolean {
    return this.bondedFromLocalMap.has(deviceId);
  }

  resetDeviceBondedFromLocal(deviceId: string): void {
    this.bondedFromLocalMap.delete(deviceId);
  }

  setDeviceConnectTimestamp(deviceId: string, timestamp: number): void {
    this.connectTimestampMap.set(deviceId, timestamp);
  }

  getDeviceConnectTimestamp(deviceId: string): number {
    return this.connectTimestampMap.get(deviceId) ?? 0;
  }

  resetDeviceConnectTimestamp(deviceId: string): void {
    this.connectTimestampMap.delete(deviceId);
  }

  checkDeviceConnectTimestampValid(deviceId: string, checkedTimeout: number): boolean {
    if (!this.connectTimestampMap.has(deviceId)) {
      return false;
    }

    return new Date().getTime() - (this.connectTimestampMap.get(deviceId) ?? 0) <= checkedTimeout;
  }
}

/**
 * 蓝牙配对监听接口
 *
 * @since 2022-05-20
 */
export interface BluetoothPairListener {
  /**
   * 配对结果回退
   */
  onPairResult(deviceId: string, result: number, isSuccess: boolean): void;
}

/**
 * 蓝牙连接监听接口
 *
 * @since 2022-05-20
 */
export interface BluetoothConnectListener {
  /**
   * 连接结果回退
   */
  onConnectResult(deviceId: string, result: number, isSuccess: boolean): void;
}

/**
 * 蓝牙协议基类
 *
 * @since 2022-05-20
 */
export class BluetoothProfile {
  public lastState: ProfileConnectionState | null = null;
  public listener: BluetoothProfileStateChangeListener;
  public profile?: bluetoothManager.A2dpSourceProfile | bluetoothManager.HandsFreeAudioGatewayProfile |
  bluetoothManager.HidHostProfile | bluetoothManager.PanProfile;
  public tag: string = 'BluetoothProfile';
  public connectionStrategyProfile: ConnectionProfile | null = null;

  constructor(listener: BluetoothProfileStateChangeListener) {
    this.listener = listener;
    try {
      if (BluetoothUtils.isBluetoothStateOn(BluetoothAdapter.getInstance().currentState)) {
        this.lastState = bluetoothManager.getProfileConnectionState(this.getProfileId());
      }
    } catch (err) {
      LogUtil.error(`${TAG} getProfileConnectionState failed, err is code: ${err?.code} message: ${err?.message}`);
    }
    try {
      this.profile = bluetoothManager.getProfileInstance(this.getProfileId());
    } catch (err) {
      LogUtil.error(`${TAG} getProfileInstance failed, err is code: ${err?.code} message: ${err?.message}`);
    }
  }

  setLastState(): void {
    try {
      LogUtil.info(`${TAG} get lastState profileId : ${this.getProfileId()}`);
      this.lastState = bluetoothManager.getProfileConnectionState(this.getProfileId());
    } catch (err) {
      LogUtil.error(`${TAG} getProfileConnectionState failed, err is code: ${err?.code} message: ${err?.message}`);
    }
  }


  initConnectionProfile(): void {
    LogUtil.info(`${this.tag} default initConnectionProfile`);
    try {
      this.connectionStrategyProfile = a2dp.createA2dpSrcProfile();
    } catch (err) {
      LogUtil.error(`${TAG} createA2dpSrcProfile failed, err is code: ${err?.code} message: ${err?.message}`);
    }
  }

  public onProfileStateChange = (state: StateChangeParam) => {
    if (!state) {
      return;
    }
    LogUtil.info(`${this.tag} onProfileStateChange, deviceId: ${BluetoothUtils.getLogMAC(state?.deviceId)}, state : ${state?.state}`);
    this.listener.onBluetoothProfileStateChange(this.getProfileId(), state);
    this.lastState = state.state;
  }

  getProfileId(): number {
    return 0;
  }

  start(): void {
    try {
      if (!this.connectionStrategyProfile) {
        this.connectionStrategyProfile = a2dp.createA2dpSrcProfile();
      }
      this.connectionStrategyProfile.on('connectionStateChange',
        this.onProfileStateChange as Callback<baseProfile.StateChangeParam>);
    } catch (err) {
      LogUtil.error(`${TAG} start failed, err is code: ${err?.code} message: ${err?.message}`);
    }
  }

  stop(): void {
    try {
      if (!this.connectionStrategyProfile) {
        this.connectionStrategyProfile = a2dp.createA2dpSrcProfile();
      }
      this.connectionStrategyProfile.off('connectionStateChange',
        this.onProfileStateChange as Callback<baseProfile.StateChangeParam>);
    } catch (err) {
      LogUtil.error(`${TAG} stop failed, err is code: ${err?.code} message: ${err?.message}`);
    }
  }

  connect(deviceId: string): boolean {
    try {
      (this.profile as bluetoothManager.A2dpSourceProfile | bluetoothManager.HandsFreeAudioGatewayProfile |
      bluetoothManager.HidHostProfile)?.connect(deviceId);
      return true;
    } catch (err) {
      LogUtil.error(`${TAG} connect failed, err is code: ${err?.code} message: ${err?.message}`);
      return false;
    }
  }

  disconnect(deviceId: string): boolean {
    try {
      this.profile?.disconnect(deviceId);
      return true;
    } catch (err) {
      LogUtil.error(`${TAG} connect failed, code: ${err?.code} message: ${err?.message}`);
      return false;
    }
  }

  getDeviceState(deviceId: string): ProfileConnectionState {
    let deviceState: ProfileConnectionState = ProfileConnectionState.STATE_DISCONNECTED;
    try {
      if (this.profile) {
        deviceState = this.profile?.getDeviceState(deviceId);
      }
    } catch (err) {
      LogUtil.error(`${TAG} getDeviceState failed, code: ${err?.code} message: ${err?.message}`);
    }
    return deviceState;
  }

  getConnectionState(deviceId: string): ProfileConnectionState {
    let connectionState: ProfileConnectionState = ProfileConnectionState.STATE_DISCONNECTED;
    try {
      if (this.connectionStrategyProfile) {
        connectionState = this.connectionStrategyProfile?.getConnectionState(deviceId);
      }
    } catch (err) {
      LogUtil.error(`${TAG} getConnectionState failed, code: ${err?.code} message: ${err?.message}`);
    }
    return connectionState;
  }

  async getConnectionStrategy(deviceId: string): Promise<ConnectionStrategy> {
    let connectionStrategy: ConnectionStrategy = ConnectionStrategy.CONNECTION_STRATEGY_UNSUPPORTED;
    try {
      if (this.connectionStrategyProfile) {
        let status = this.getDeviceState(deviceId)
        if (status === 2) {
          return Promise.resolve(ConnectionStrategy.CONNECTION_STRATEGY_ALLOWED)
        } else {
          connectionStrategy = await this.connectionStrategyProfile?.getConnectionStrategy(deviceId);
        }
      }
    } catch (err) {
      LogUtil.error(`${TAG} getConnectionStrategy failed, code: ${err?.code} message: ${err?.message}`);
    }
    return connectionStrategy;
  }

  async setConnectionStrategy(deviceId: string, strategy: ConnectionStrategy): Promise<void> {
    if (this.connectionStrategyProfile) {
      return this.connectionStrategyProfile.setConnectionStrategy(deviceId, strategy);
    }
  }
}

/**
 * 助听器蓝牙协议类
 *
 * @since 2025-07-01
 */
// export class HearingAidProfile extends BluetoothProfile {
//   public tag: string = 'HearingAidProfile';
//   // public hearingAidProfile: hearingAid.HearingAidSourceProfile | null = null;
//   // public onHearingAidProfileChange = (hearingAidState: hearingAid.HearingAidStateChangeParam) => {
//   //   if (!hearingAidState) {
//   //     return;
//   //   }
//   //   LogUtil.info(`${this.tag} onProfileStateChange, deviceId: ${BluetoothUtils.getLogMAC(hearingAidState?.deviceId)}, state : ${hearingAidState?.state}`);
//   //   let profileState: ProfileConnectionState = this.convertFromHearingAidState(hearingAidState?.state);
//   //   let stateParam: StateChangeParam = {
//   //     deviceId: hearingAidState?.deviceId,
//   //     state: profileState,
//   //     cause: DisconnectCause.USER_DISCONNECT
//   //   }
//   //   this.listener.onBluetoothProfileStateChange(this.getProfileId(), stateParam);
//   //   this.lastState = profileState;
//   // }
//
//   constructor(listener: BluetoothProfileStateChangeListener) {
//     super(listener);
//   }
//
//   initConnectionProfile(): void {
//     LogUtil.info(`${this.tag} default initConnectionProfile`);
//     try {
//       // this.hearingAidProfile = hearingAid.createHearingAidSrcProfile();
//     } catch (err) {
//       LogUtil.error(`${TAG} createHearingAidSrcProfile failed, err is code: ${err?.code} message: ${err?.message}`);
//     }
//   }
//
//   getProfileId(): ProfileId {
//     return PROFILE_HEARING_AID;
//   }
//
//   // private convertFromHearingAidState(state: hearingAid.HearingAidConnectionState): ProfileConnectionState {
//   //   switch (state) {
//   //     case hearingAid.HearingAidConnectionState.STATE_DISCONNECTED:
//   //       return ProfileConnectionState.STATE_DISCONNECTED;
//   //     case hearingAid.HearingAidConnectionState.STATE_CONNECTING:
//   //       return ProfileConnectionState.STATE_CONNECTING;
//   //     case hearingAid.HearingAidConnectionState.STATE_CONNECTED:
//   //       return ProfileConnectionState.STATE_CONNECTED;
//   //     case hearingAid.HearingAidConnectionState.STATE_DISCONNECTING:
//   //       return ProfileConnectionState.STATE_DISCONNECTING;
//   //     default:
//   //       return ProfileConnectionState.STATE_DISCONNECTED;
//   //   }
//   // }
//
//   // private convertFromHearingAidStrategy(strategy: hearingAid.HearingAidConnectionStrategy): ConnectionStrategy {
//   //   switch (strategy) {
//   //     case hearingAid.HearingAidConnectionStrategy.CONNECTION_STRATEGY_UNSUPPORTED:
//   //       return ConnectionStrategy.CONNECTION_STRATEGY_UNSUPPORTED;
//   //     case hearingAid.HearingAidConnectionStrategy.CONNECTION_STRATEGY_ALLOWED:
//   //       return ConnectionStrategy.CONNECTION_STRATEGY_ALLOWED;
//   //     case hearingAid.HearingAidConnectionStrategy.CONNECTION_STRATEGY_FORBIDDEN:
//   //       return ConnectionStrategy.CONNECTION_STRATEGY_FORBIDDEN;
//   //     default:
//   //       return ConnectionStrategy.CONNECTION_STRATEGY_UNSUPPORTED;
//   //   }
//   // }
//
//   // private convertToHearingAidStrategy(strategy: ConnectionStrategy): hearingAid.HearingAidConnectionStrategy {
//   //   switch (strategy) {
//   //     case ConnectionStrategy.CONNECTION_STRATEGY_UNSUPPORTED:
//   //       return hearingAid.HearingAidConnectionStrategy.CONNECTION_STRATEGY_UNSUPPORTED;
//   //     case ConnectionStrategy.CONNECTION_STRATEGY_ALLOWED:
//   //       return hearingAid.HearingAidConnectionStrategy.CONNECTION_STRATEGY_ALLOWED;
//   //     case ConnectionStrategy.CONNECTION_STRATEGY_FORBIDDEN:
//   //       return hearingAid.HearingAidConnectionStrategy.CONNECTION_STRATEGY_FORBIDDEN;
//   //     default:
//   //       return hearingAid.HearingAidConnectionStrategy.CONNECTION_STRATEGY_UNSUPPORTED;
//   //   }
//   // }
//
//   start(): void {
//     // try {
//     //   if (!this.hearingAidProfile) {
//     //     this.hearingAidProfile = hearingAid.createHearingAidSrcProfile();
//     //   }
//     //   this.hearingAidProfile.on('connectionStateChange', this.onHearingAidProfileChange);
//     // } catch (err) {
//     //   LogUtil.error(`${TAG} start failed, err is code: ${err?.code} message: ${err?.message}`);
//     // }
//   }
//
//   stop(): void {
//     // try {
//     //   if (!this.hearingAidProfile) {
//     //     // this.hearingAidProfile = hearingAid.createHearingAidSrcProfile();
//     //   }
//     //   this.hearingAidProfile.off('connectionStateChange', this.onHearingAidProfileChange);
//     // } catch (err) {
//     //   LogUtil.error(`${TAG} stop failed, err is code: ${err?.code} message: ${err?.message}`);
//     // }
//   }
//
//   connect(deviceId: string): boolean {
//     try {
//       // this.hearingAidProfile?.connect(deviceId);
//       return true;
//     } catch (err) {
//       LogUtil.error(`${TAG} connect failed, err is code: ${err?.code} message: ${err?.message}`);
//       return false;
//     }
//   }
//
//   disconnect(deviceId: string): boolean {
//     try {
//       // this.hearingAidProfile?.disconnect(deviceId);
//       return true;
//     } catch (err) {
//       LogUtil.error(`${TAG} connect failed, code: ${err?.code} message: ${err?.message}`);
//       return false;
//     }
//   }
//
//   getDeviceState(deviceId: string): ProfileConnectionState {
//     let deviceState: ProfileConnectionState = ProfileConnectionState.STATE_DISCONNECTED;
//     try {
//       // if (this.hearingAidProfile) {
//       //   deviceState = this.convertFromHearingAidState(this.hearingAidProfile.getConnectionState(deviceId));
//       // }
//     } catch (err) {
//       LogUtil.error(`${TAG} getDeviceState failed, code: ${err?.code} message: ${err?.message}`);
//     }
//     return deviceState;
//   }
//
//   getConnectionState(deviceId: string): ProfileConnectionState {
//     let connectionState: ProfileConnectionState = ProfileConnectionState.STATE_DISCONNECTED;
//     try {
//       // if (this.hearingAidProfile) {
//       //   connectionState = this.convertFromHearingAidState(this.hearingAidProfile.getConnectionState(deviceId));
//       // }
//     } catch (err) {
//       LogUtil.error(`${TAG} getConnectionState failed, code: ${err?.code} message: ${err?.message}`);
//     }
//     return connectionState;
//   }
//
//   async getConnectionStrategy(deviceId: string): Promise<ConnectionStrategy> {
//     let connectionStrategy: ConnectionStrategy = ConnectionStrategy.CONNECTION_STRATEGY_UNSUPPORTED;
//     try {
//       // if (this.hearingAidProfile) {
//       //   connectionStrategy =
//       //     this.convertFromHearingAidStrategy(await this.hearingAidProfile.getConnectionStrategy(deviceId));
//       // }
//     } catch (err) {
//       LogUtil.error(`${TAG} getConnectionStrategy failed, code: ${err?.code} message: ${err?.message}`);
//     }
//     return connectionStrategy;
//   }
//
//   async setConnectionStrategy(deviceId: string, strategy: ConnectionStrategy): Promise<void> {
//     // if (this.hearingAidProfile) {
//     //   return this.hearingAidProfile.setConnectionStrategy(deviceId, this.convertToHearingAidStrategy(strategy));
//     // }
//   }
//
//   /**
//    * 设置助听器音量
//    *
//    * @param deviceId 设备mac地址
//    * @param volume 音量值
//    */
//   public setVolume(deviceId: string, volume: number): void {
//     try {
//       // this.hearingAidProfile?.setVolume(deviceId, volume);
//     } catch (err) {
//       LogUtil.error(`${TAG} setVolume failed, err is code: ${err?.code} message: ${err?.message}`);
//     }
//   }
//
//   /**
//    * 获取助听器设备信息
//    *
//    * @param deviceId 设备mac地址
//    * @returns 助听器设备信息
//    */
//   // public getHearingAidDeviceInfo(deviceId: string): hearingAid.HearingAidDeviceInfo | undefined {
//   //   let deviceInfo: hearingAid.HearingAidDeviceInfo | undefined = undefined;
//   //   try {
//   //     deviceInfo = this.hearingAidProfile?.getHearingAidDeviceInfo(deviceId);
//   //   } catch (err) {
//   //     LogUtil.error(`${TAG} setVolume failed, err is code: ${err?.code} message: ${err?.message}`);
//   //   }
//   //   return deviceInfo;
//   // }
//
//   /**
//    * 获取助听器左右耳
//    *
//    * @param deviceId 设备mac地址
//    * @returns 左耳或右耳
//    */
//   // public getHearingAidSide(deviceId: string): hearingAid.DeviceSide | undefined {
//   //   let deviceSide: hearingAid.DeviceSide | undefined = undefined;
//   //   try {
//   //     let deviceInfo: hearingAid.HearingAidDeviceInfo | undefined = this.getHearingAidDeviceInfo(deviceId);
//   //     if (deviceInfo) {
//   //       deviceSide = deviceInfo.deviceSide;
//   //     }
//   //   } catch (err) {
//   //     LogUtil.error(`${TAG} getHearingAidSide failed, err is code: ${err?.code} message: ${err?.message}`);
//   //   }
//   //   return deviceSide;
//   // }
//
//   /**
//    * 获取HearingAidId，用于判断两个设备是否为同一套
//    *
//    * @param deviceId 设备mac地址
//    * @returns 设备HearingAidId
//    */
//   public getHearingAidId(deviceId: string): number | undefined {
//     let hearingAidId: number | undefined = undefined;
//     try {
//       // let deviceInfo: hearingAid.HearingAidDeviceInfo | undefined = this.getHearingAidDeviceInfo(deviceId);
//       // if (deviceInfo) {
//       //   hearingAidId = deviceInfo.hearingAidId;
//       // }
//     } catch (err) {
//       LogUtil.error(`${TAG} getHearingAidSide failed, err is code: ${err?.code} message: ${err?.message}`);
//     }
//     return hearingAidId;
//   }
//
//   /**
//    * 本地设备是否支持助听器
//    *
//    * @returns 是否支持助听器
//    */
//   public isLocalDeviceSupportHearingAid(): boolean {
//     if (this.hearingAidProfile) {
//       return this.hearingAidProfile.isLocalDeviceSupportHearingAid()
//     }
//     return false;
//   }
// }

/**
 * A2dp蓝牙协议类
 *
 * @since 2022-05-20
 */
export class A2dpProfile extends BluetoothProfile {
  public tag: string = 'A2dpProfile';

  constructor(listener: BluetoothProfileStateChangeListener) {
    super(listener);
  }

  getProfileId(): ProfileId {
    return PROFILE_A2DP_SOURCE;
  }

  initConnectionProfile(): void {
    LogUtil.info(`${this.tag} initConnectionProfile`);
    try {
      this.connectionStrategyProfile = a2dp.createA2dpSrcProfile();
    } catch (err) {
      LogUtil.error(`${TAG} createA2dpSrcProfile failed, code: ${err?.code} message: ${err?.message}`);
    }
  }
}

/**
 * Hfp蓝牙协议类
 *
 * @since 2022-05-20
 */
export class HfpProfile extends BluetoothProfile {
  public tag: string = 'HfpProfile';

  constructor(listener: BluetoothProfileStateChangeListener) {
    super(listener);
  }

  getProfileId(): ProfileId {
    return PROFILE_HANDS_FREE_AUDIO_GATEWAY;
  }

  initConnectionProfile(): void {
    LogUtil.info(`${this.tag} default initConnectionProfile`);
    try {
      this.connectionStrategyProfile = hfp.createHfpAgProfile();
    } catch (err) {
      LogUtil.error(`${TAG} createHfpAgProfile failed, code: ${err?.code} message: ${err?.message}`);
    }
  }
}

/**
 * Hid蓝牙协议类
 *
 * @since 2022-06-06
 */
export class HidProfile extends BluetoothProfile {
  public tag: string = 'HidProfile';

  constructor(listener: BluetoothProfileStateChangeListener) {
    super(listener);
  }

  getProfileId(): ProfileId {
    return PROFILE_HID_HOST;
  }

  initConnectionProfile(): void {
    LogUtil.info(`${this.tag} default initConnectionProfile`);
    try {
      this.connectionStrategyProfile = hid.createHidHostProfile();
    } catch (err) {
      LogUtil.error(`${TAG} createHidHostProfile failed, code: ${err?.code} message: ${err?.message}`);
    }
  }
}

/**
 * 蓝牙协议管理类
 *
 * @since 2022-05-20
 */
export class BluetoothProfileManager implements BluetoothProfileStateChangeListener {
  public static readonly CONNECT_TIMEOUT: number = 60000; // 60秒
  public readonly tag: string = 'BluetoothProfileManager : ';
  public isStart: boolean = false;
  public profiles: Map<ProfileId, BluetoothProfile> = new Map();
  public pbapProfile: pbap.PbapServerProfile | null = null;
  public mapProfile: map.MapMseProfile | null = null;
  public listener: BluetoothProfileStateChangeListener | null = null;
  // 连接管理使用变量
  public connectDeviceId: ArrayList<string> = new ArrayList();
  public connectListener: BluetoothConnectListener | null = null;
  public timerId: number | null = null;

  /**
   * 发起连接
   *
   * @param deviceId 连接的设备ID
   * @param listener 连接结果回调
   */
  startConnect(deviceId: string, listener?: BluetoothConnectListener, subDeviceId?: string): boolean {
    LogUtil.info(`${this.tag} startConnect. deviceId:${BluetoothUtils.getLogMAC(deviceId)}`);
    if (!deviceId) {
      LogUtil.error(`${this.tag} startConnect empty param`);
      return false;
    }
    this.finishConnect();
    this.connectDeviceId.add(deviceId);
    if (subDeviceId) {
      this.connectDeviceId.add(subDeviceId);
    }
    this.connectListener = listener as BluetoothConnectListener;

    this.timerId = setTimeout(() => {
      LogUtil.info(`${this.tag} connect timeout`);
      this.timerId = null;
      this.handleConnectTimeout();
    }, BluetoothPairManager.PAIR_TIMEOUT);

    let result = this.connectToDeviceId(deviceId);
    if (!result) {
      this.dispatchConnectResult(deviceId, false, CONNECT_RESULT_FAILED);
    }
    if (subDeviceId) {
      let subResult = this.connectToDeviceId(subDeviceId);
      if (!subResult) {
        this.dispatchConnectResult(subDeviceId, false, CONNECT_RESULT_FAILED);
      }
      result = result || subResult;
    }
    return result;
  }

  getListenKey(): string {
    return this.tag;
  }

  private handleConnectTimeout() {
    this.connectDeviceId.forEach(connectId => {
      this.dispatchConnectResult(connectId, false, CONNECT_RESULT_FAILED);
    });
  }

  private dispatchConnectResult(deviceId: string, isSuccess: boolean, result: number): void {
    this.connectListener?.onConnectResult(deviceId, result, isSuccess);
    this.connectDeviceId.remove(deviceId);
    if (this.connectDeviceId.isEmpty()) {
      this.finishConnect();
    }
  }

  finishConnect(): void {
    if (this.timerId != null) {
      clearTimeout(this.timerId);
      this.timerId = null;
    }
    this.connectDeviceId.clear();
    this.connectListener = null;
  }

  getProfileState(profileId: ProfileId, deviceId: string): ProfileConnectionState {
    let deviceState = ProfileConnectionState.STATE_DISCONNECTED;
    try {
      deviceState =
        this.profiles.get(profileId)?.getConnectionState(deviceId) as ProfileConnectionState;
      LogUtil.info(`${this.tag} profileId ${profileId} deviceState ${deviceState}`);
    } catch (err) {
      LogUtil.error(`${this.tag} getDeviceState failed, code: ${err?.code} message: ${err?.message}`);
    }
    return deviceState;
  }

  isDeviceConnected(deviceId: string): boolean {
    LogUtil.info(`${this.tag} isDeviceConnected`);
    if (!deviceId) {
      LogUtil.error(`${this.tag} isDeviceConnected empty param`);
      return false;
    }
    let flag: boolean = false;
    this.profiles.forEach((bluetoothProfile: BluetoothProfile, key: ProfileId) => {
      if (bluetoothProfile.getDeviceState(deviceId) === ProfileConnectionState.STATE_CONNECTED) {
        flag = true
        return;
      }
    })
    LogUtil.info(`${this.tag} isDeviceConnected. flag:${flag}`);
    return flag;
  }

  isDeviceConnecting(deviceId: string): boolean {
    if (!deviceId) {
      LogUtil.error(`${this.tag} isDeviceConnecting empty param`);
      return false;
    }
    let flag: boolean = false;
    this.profiles.forEach((bluetoothProfile: BluetoothProfile, key: ProfileId) => {
      if (bluetoothProfile.getDeviceState(deviceId) === ProfileConnectionState.STATE_CONNECTING) {
        flag = true
      }
    })
    return flag;
  }

  isDeviceConnectedOrConnecting(deviceId: string): boolean {
    if (!deviceId) {
      LogUtil.error(`${this.tag} isDeviceConnectedOrConnecting empty param`);
      return false;
    }
    let flag: boolean = false;
    this.profiles.forEach((bluetoothProfile: BluetoothProfile, key: ProfileId) => {
      let state = bluetoothProfile.getDeviceState(deviceId);
      if (state === ProfileConnectionState.STATE_CONNECTED || state === ProfileConnectionState.STATE_CONNECTING) {
        flag = true
      }
    })
    return flag;
  }

  /**
   * 是否所有profile都断连
   *
   * @param deviceId deviceId
   * @returns true：全部断连
   */
  isAllProfileDisconnected(deviceId: string): boolean {
    let isAllDisconnected = true;
    this.profiles.forEach((bluetoothProfile: BluetoothProfile, key: ProfileId) => {
      if (bluetoothProfile.getDeviceState(deviceId) != ProfileConnectionState.STATE_DISCONNECTED) {
        isAllDisconnected = false;
      }
    })
    return isAllDisconnected;
  }

  private connectToDeviceId(deviceId: string): boolean {
    LogUtil.info(`${this.tag} connectToDeviceId, deviceId:${BluetoothUtils.getLogMAC(deviceId)}`);
    let result = false;
    try {
      // connection.connectAllowedProfiles(deviceId);
      this.profiles.forEach((profile, key) => {
        if (profile) {
          let profileConnectionState = profile.getDeviceState(deviceId);
          LogUtil.info(` connectToDeviceId , connectionState = ${profileConnectionState}`);
          try {
            profile.connect(deviceId);
          } catch (BusinessError) {
            LogUtil.info(` connectToDeviceId failed. BusinessError is  ` + JSON.stringify(BusinessError));
          }
        }
      })
      result = true;
    } catch (err) {
      LogUtil.error(`${this.tag} connectToDeviceId. connectAllowedProfiles failed. code:${err?.code} message:${err?.message}`);
    }
    LogUtil.info(`${TAG} connectToDeviceId. result:${result}`);
    return result;
  }

  /**
   * 断开连接
   *
   * @param deviceId 要断开的设备ID
   */
  disconnectDevice(deviceId: string): boolean {
    if (!deviceId) {
      LogUtil.error(`${this.tag} disconnectDevice empty param`);
      return false;
    }
    let result = false;
    try {
      LogUtil.info(`${this.tag} disconnectDevice. deviceId:${BluetoothUtils.getLogMAC(deviceId)}`);
      // connection.disconnectAllowedProfiles(deviceId);
      this.profiles.forEach((profile, key) => {
        if (profile) {
          let profileConnectionState = profile.getDeviceState(deviceId);
          LogUtil.info(` disconnectDevice , connectionState = ${profileConnectionState}`);
          if (profileConnectionState === 2 || profileConnectionState === 1) {
            try {
              profile.disconnect(deviceId);
            } catch (BusinessError) {
              LogUtil.info(` disconnect failed. BusinessError is  ` + JSON.stringify(BusinessError));
            }
          }
        }
      })
      result = true;
    } catch (err) {
      LogUtil.error(`${this.tag} disconnectDevice disconnectAllowedProfiles failed. code:${err?.code} message:${err?.message}`);
    }
    return result;
  }

  /**
   * disconnect profile.
   * @param deviceId device id
   * @param profileId profile id
   */
  disconnectProfile(deviceId: string | undefined, profileId: number): void {
    const profile = this.profiles.get(profileId)
    if (profile) {
      let profileConnectionState = profile.getDeviceState(deviceId!);
      LogUtil.info(` disconnectProfile , connectionState = ${profileConnectionState}`);
      if (profileConnectionState === 2 || profileConnectionState === 1) {
        try {
          profile.disconnect(deviceId!);
        } catch (BusinessError) {
          LogUtil.info(` disconnectProfile failed. BusinessError is  ` + JSON.stringify(BusinessError));
        }
      }
    }
  }

  connectProfile(deviceId: string, profileId: number): void {
    const profile = this.profiles.get(profileId)
    if (profile) {
      let profileConnectionState = profile.getDeviceState(deviceId!);
      LogUtil.info(` connectProfile , connectionState = ${profileConnectionState}`);
      try {
        if (profileConnectionState === ProfileConnectionState.STATE_DISCONNECTED || profileConnectionState === ProfileConnectionState.STATE_DISCONNECTING) {
          profile.connect(deviceId)
        }
      } catch (BusinessError) {
        LogUtil.info(` connectProfile failed. BusinessError is  ` + JSON.stringify(BusinessError));
      }
    }
  }


  onBluetoothProfileStateChange(profileId: ProfileId, stateChangeParam: StateChangeParam): void {
    if (!stateChangeParam) {
      return;
    }
    LogUtil.info(`${this.tag} onBluetoothProfileStateChange. deviceId:${BluetoothUtils.getLogMAC(stateChangeParam.deviceId)} profileId:${profileId} state:${stateChangeParam.state} cause:${stateChangeParam.cause}`);
    this.listener?.onBluetoothProfileStateChange(profileId, stateChangeParam);
    if (!this.connectDeviceId.has(stateChangeParam.deviceId)) {
      return;
    }
    if (stateChangeParam.state === ProfileConnectionState.STATE_CONNECTED) {
      this.dispatchConnectResult(stateChangeParam.deviceId, true, CONNECT_RESULT_SUCCESS);
      return;
    }
    if (stateChangeParam.cause === DisconnectCause.TOO_MANY_CONNECTED_DEVICES &&
      stateChangeParam.state === ProfileConnectionState.STATE_DISCONNECTED) {
      this.dispatchConnectResult(stateChangeParam.deviceId, false, DisconnectCause.TOO_MANY_CONNECTED_DEVICES);
      return;
    }
    let profile: BluetoothProfile = this.profiles.get(profileId) as BluetoothProfile;
    if (this.connectDeviceId.has(stateChangeParam.deviceId) &&
      stateChangeParam.state === ProfileConnectionState.STATE_DISCONNECTED) {
      if (this.isAllProfileDisconnected(stateChangeParam.deviceId)) {
        // 连接失败
        this.dispatchConnectResult(stateChangeParam.deviceId, false, stateChangeParam.cause);
      }
    }
  }

  onConnectResult(deviceId: string, result: number, isSuccess: boolean): void {
  }

  /**
   * 开始生命周期
   *
   * @param listener 连接结果监听者
   */
  start(listener: BluetoothProfileStateChangeListener): void {
    if (!this.isStart) {
      this.isStart = true;
      LogUtil.info(`${this.tag} start`);
      this.listener = listener;

      // 在此处添加HfpProfile或者其他协议;
      this.profiles.set(PROFILE_HANDS_FREE_AUDIO_GATEWAY, new HfpProfile(this));
      this.profiles.set(PROFILE_HID_HOST, new HidProfile(this));
      this.profiles.set(PROFILE_A2DP_SOURCE, new A2dpProfile(this));
      // this.profiles.set(PROFILE_HEARING_AID, new HearingAidProfile(this));

      this.profiles.forEach((bluetoothProfile: BluetoothProfile, key: ProfileId) => {
        try {
          bluetoothProfile.initConnectionProfile();
          bluetoothProfile?.start();
        } catch (errData) {
          LogUtil.error(`${this.tag} bluetoothProfile.start failed. code:${errData?.code} message:${errData?.message}`);
        }
      })
      try {
        this.pbapProfile = pbap.createPbapServerProfile();
        LogUtil.error(`${this.tag} createPbapServerProfile successed.`);
        this.mapProfile = map.createMapMseProfile();
        LogUtil.error(`${this.tag} createMapMseProfile successed.`);
      } catch (errData) {
        LogUtil.error(`${this.tag} createProfile failed. code:${errData?.code} message:${errData?.message}`);
      }
      LogUtil.info(`${this.tag} start end`);
    }
  }

  /**
   * 停止生命周期
   */
  stop(): void {
    if (this.isStart) {
      LogUtil.info(`${this.tag} BluetoothProfileManager stop`);
      this.listener = null;
      this.profiles.forEach((bluetoothProfile: BluetoothProfile, key: ProfileId) => {
        try {
          bluetoothProfile?.stop();
        } catch (errData) {
          LogUtil.error(`${this.tag} bluetoothProfile?.stop failed. code:${errData?.code} message:${errData?.message}`);
        }
      })
      this.profiles.clear();
      this.finishConnect();
      this.isStart = false;
      LogUtil.info(`${this.tag} BluetoothProfileManager stop end`);
    }
  }
}

/**
 * 蓝牙配对管理类
 *
 * @since 2022-05-20
 */
export class BluetoothPairManager {
  public static readonly PAIR_TIMEOUT: number = 60000; // 60秒
  public readonly tag: string = 'BluetoothPairManager : ';
  public pairDeviceId: string | null = null;
  public listener: BluetoothPairListener | null = null;
  public timerId: number | null = null;

  /**
   * 发起配对流程
   *
   * @param deviceId 要配对ed设备ID
   * @param listener 配对结果监听者
   */
  startPair(deviceId: string, listener?: BluetoothPairListener): boolean {
    if (!deviceId) {
      LogUtil.error(`${this.tag} startPair empty param`);
      return false;
    }
    this.finishPair();
    this.pairDeviceId = deviceId;
    this.listener = listener as BluetoothPairListener;

    this.timerId = setTimeout(() => {
      LogUtil.info(`${this.tag} pair timeout`);
      this.timerId = null;
      this.dispatchPairResult(false, -1);
    }, BluetoothPairManager.PAIR_TIMEOUT);
    try {
      connection.pairDevice(this.pairDeviceId);
    } catch (error) {
      LogUtil.error(`${this.tag} pairDevice error, ${error?.message}`);
      return false;
    }
    return true;
  }

  setPairDeviceId(deviceId: string): void {
    LogUtil.info(`${this.tag} setPairDeviceId. deviceId:${BluetoothUtils.getLogMAC(deviceId)}`);
    this.pairDeviceId = deviceId;
  }

  setListener(listener: BluetoothPairListener): void {
    LogUtil.info(`${this.tag} setListener`);
    if (this.listener === null) {
      this.listener = listener;
    }
  }

  onDevicePairingConfirmation(deviceId: string, isAccept: boolean): void {
    if (!this.pairDeviceId || deviceId != this.pairDeviceId) {
      return;
    }

    if (!isAccept) {
      this.finishPair();
    }
  }

  onBluetoothBondStateChange(stateParam: BondStateParam): void {
    if (!stateParam) {
      return;
    }
    if (!this.pairDeviceId || stateParam.deviceId != this.pairDeviceId) {
      LogUtil.info(`${this.tag} check false`);
      return;
    }

    if (stateParam.state === BondState.BOND_STATE_BONDED) {
      // 配对成功
      this.dispatchPairResult(true, 1);
      return;
    }

    if (stateParam.state === BondState.BOND_STATE_INVALID) {
      // 配对失败
      LogUtil.info(`${this.tag} onBluetoothBondStateChange. pair failed. code:${stateParam.cause}`);
      this.dispatchPairResult(false, stateParam.cause);
      return;
    }
  }

  private dispatchPairResult(isSuccess: boolean, result: number): void {
    this.listener?.onPairResult(this.pairDeviceId as string, result, isSuccess);
    LogUtil.info(`${this.tag} dispatchPairResult ${result}`);

    this.finishPair();
  }

  finishPair(): void {
    if (this.timerId != null) {
      clearTimeout(this.timerId);
      this.timerId = null;
    }
    this.pairDeviceId = null;
    this.listener = null;
  }
}

export let bluetoothPairManager = new BluetoothPairManager();

/**
 * 蓝牙功能使用管理类
 *
 * @since 2022-04-25
 */
export class BluetoothAdapter implements BluetoothPairListener, BluetoothProfileStateChangeListener,
BluetoothConnectListener {
  public isBluetoothPageShow: boolean = false;
  public isStart: boolean = false;
  public isDiscovering: boolean = false;
  public isAutoDiscover: boolean = false;
  public isPauseDiscover: boolean = false;
  public retryTime: number = DISCOVERY_RETRY_COUNT;
  public currentState: number = 0;
  public stateChangeListeners: BluetoothStateChangeListener[] = [];
  public deviceChangeListeners: BluetoothDeviceChangeListener[] = [];
  public deviceNameUpdateListeners: BluetoothDeviceNameUpdateListener[] = [];
  public bondChangeListeners: BluetoothBondChangeListener[] = [];
  public profileStateChangeListeners: BluetoothProfileStateChangeListener[] = [];
  public loadingStateChangerListeners: BluetoothLoadStateChangeListener[] = [];
  public bluetoothRemoveSummaryListeners: BluetoothRemoveSummaryListener[] = [];
  public bondedDeviceChangeListeners: BluetoothBondedDeviceChangeListener[] = [];
  public isPairing: boolean = false;
  public connectingIds: ArrayList<string> = new ArrayList();
  public isIgnoreDiscovery: boolean = false;
  public profileManager = new BluetoothProfileManager();
  public cachedManager: CachedBluetoothDeviceManager = new CachedBluetoothDeviceManager();
  public cachedBondedDevices: Map<string, BluetoothDevice> = new Map();
  public localProfileUuids: connection.ProfileUuids[] = [];
  public delayStartDiscoveryTimer: number | null = null;
  public delayStartDiscoveryAfterPairFinishTimer: number | null = null;
  public delayDispatchDeviceRefreshTimer: number | null = null;
  public isPairBluetoothAdapter: boolean = false;
  public bluetoothDevices: connection.DiscoveryResult[] = [];
  public connectTimestampManager: ConnectTimestampManager = new ConnectTimestampManager();

  setIsPairBluetoothAdapter(isPairBluetoothAdapter: boolean) {
    LogUtil.info(`${TAG} setIsPairBluetoothAdapter: ${isPairBluetoothAdapter}`);
    this.isPairBluetoothAdapter = isPairBluetoothAdapter;
  }

  setIsIgnoreDiscovery(isIgnoreDiscovery: boolean): void {
    LogUtil.info(`${TAG} setIsIgnoreDiscovery isIgnoreDiscovery: ${isIgnoreDiscovery}`);
    this.isIgnoreDiscovery = isIgnoreDiscovery;
  }

  getListenKey(): string {
    return TAG;
  }

  //订阅者信息
  public discoveryFinishedSubscribeInfo: commonEventManager.CommonEventSubscribeInfo = {
    events: [CommonEvent.Support.COMMON_EVENT_BLUETOOTH_HOST_DISCOVERY_FINISHED],
  };
  public discoveryStartedSubscribeInfo: commonEventManager.CommonEventSubscribeInfo = {
    events: [CommonEvent.Support.COMMON_EVENT_BLUETOOTH_HOST_DISCOVERY_STARTED],
  };
  public discoveryRemoteDeviceUUIDInfo: commonEventManager.CommonEventSubscribeInfo = {
    events: [CommonEvent.Support.COMMON_EVENT_BLUETOOTH_REMOTEDEVICE_UUID_VALUE],
  };
  public updateRemoteDeviceName: commonEventManager.CommonEventSubscribeInfo = {
    events: [CommonEvent.Support.COMMON_EVENT_BLUETOOTH_REMOTEDEVICE_NAME_UPDATE],
  };
  public updateRemoteDeviceNameCommonEvent =
    new CommonEventHelper(this.updateRemoteDeviceName, (err: BusinessError, data) => {
      if (err?.code) {
        LogUtil.error(`${TAG} updateDeviceName failed `);
        return;
      }
      if (CheckEmptyUtils.checkStrIsEmpty(data?.parameters?.remoteName)) {
        LogUtil.warn(`${TAG} device is null or remoteName is empty`);
        return;
      }
      let cachedBondedDevice: BluetoothDevice = BluetoothAdapter.getInstance()
        .cachedBondedDevices
        .get(data?.parameters?.deviceAddr) as BluetoothDevice;
      let cachedDevice: BluetoothDevice = this.cachedManager.findDevice(data?.parameters?.deviceAddr);
      if (cachedBondedDevice) {
        cachedBondedDevice.updateDeviceName(data?.parameters?.remoteName);
        this.dispatchDeviceNameUpdate(cachedBondedDevice);
      } else if (cachedDevice) {
        cachedDevice.updateDeviceName(data?.parameters?.remoteName);
        this.dispatchDeviceAdded(cachedDevice);
      } else {
        LogUtil.warn(`${TAG} device is not in the cache`);
      }
    });
  public discoveryFinishCommonEvent =
    new CommonEventHelper(this.discoveryFinishedSubscribeInfo, (err: BusinessError, data: object) => {
      if (err?.code) {
        LogUtil.error(`${TAG} subscribe discovery finish failed code: ${err?.code} message: ${err?.message}`);
      } else if (!this.isIgnoreDiscovery) {
        LogUtil.info(`${TAG} subscribe discovery finish success`);
        this.dispatchDiscoveryState(false);
        this.onDiscoveryFinish();
      }
    });
  public discoveryStartedCommonEvent =
    new CommonEventHelper(this.discoveryStartedSubscribeInfo, (err: BusinessError, data: object) => {
      if (err?.code) {
        LogUtil.error(`${TAG} subscribe discovery started failed code: ${err?.code} message: ${err?.message}`);
      } else if (!this.isIgnoreDiscovery) {
        LogUtil.info(`${TAG} subscribe discovery started success`);
        this.dispatchDiscoveryState(true);
      }
    });
  public discoveryRemoteDeviceUUIDInfoEvent = new CommonEventHelper(this.discoveryRemoteDeviceUUIDInfo,
    (err: BusinessError, data) => {
      LogUtil.info(`${TAG} receive discoveryRemoteDeviceUUIDInfoEvent deviceId:${BluetoothUtils.getLogMAC(data?.parameters?.deviceAddr)}`);
      if (err?.code) {
        LogUtil.error(`${TAG} discoveryRemoteDeviceUUIDInfoEvent failed ${err?.code}`);
      } else {
        this.setBondedDeviceRemoteUuids(data);
        let device: BluetoothDevice = this.getBondedDeviceOrSubDevice(data?.parameters?.deviceAddr) ??
        this.cachedManager.findDevice(data?.parameters?.deviceAddr);
        device?.update();
        this.dispatchDeviceAttributesChanged(device);
        if (!this.isStartConnect(device)) {
          LogUtil.warn(`${TAG} discoveryRemoteDeviceUUIDInfoEvent connect task timeout, ${this.cachedBondedDevices.has(device?.deviceId)}`);
          return;
        }
        this.connectToDeviceAfterPair(device.deviceId);
      }
    });

  private setBondedDeviceRemoteUuids(data: commonEventManager.CommonEventData) {
    let device: BluetoothDevice = this.getBondedDeviceOrSubDevice(data?.parameters?.deviceAddr) ??
    this.cachedManager.findDevice(data?.parameters?.deviceAddr);
    if (!device) {
      LogUtil.warn(`${TAG} do not find the device from cachedBondedDevices or cachedManager`);
      return;
    }
    LogUtil.info(`${TAG} Start set RemoteUuid for BondedDevice device`);
    device.setRemoteUuids(data?.parameters?.remoteUuids)
    device.updateProfilesAndConnectionStatusForRemoteUUID()
  }

  private isStartConnect(device: BluetoothDevice): boolean {
    if (!device) {
      LogUtil.error(`${TAG} device is empty, discoveryRemoteDeviceUUIDInfoEvent`);
      return false;
    }
    // 获取配对连接超时时长，助听器：15s,其他设备3s
    let checkedTimeout = device.isHearingAidDevice() ? HEARINGAID_CONNECT_TASK_TIME_OUT : CONNECT_TASK_TIME_OUT;

    // 设备主动配对且已配对且连接未超时，再发起连接。否则，不去连接
    return this.cachedBondedDevices.has(device.deviceId) &&
    this.connectTimestampManager.checkDeviceConnectTimestampValid(device.deviceId, checkedTimeout);
  }

  public onBluetoothStateChange = (state: number) => {
    LogUtil.info(`${TAG} onBluetoothStateChange, state : ${state}`);

    if (BluetoothUtils.isBluetoothStateOn(state) && this.localProfileUuids.length === 0) {
      LogUtil.info(`${TAG} onBluetoothStateChange setLocalProfileUuids`);
      this.setLocalProfileUuids();
    }

    if (BluetoothUtils.isBluetoothStateOn(state)) {
      // 蓝牙状态变为开启时，同步一次本机名称到蓝牙本地名称，保证广播名称正确
      this.syncLocalNameWithDeviceName();
      this.profileManager.profiles.forEach((bluetoothProfile: BluetoothProfile, key: ProfileId) => {
        if (!bluetoothProfile.lastState) {
          bluetoothProfile.setLastState();
        }
      })
    }

    if (state === null) {
      LogUtil.error(`${TAG} onBluetoothStateChange is null`);
      return;
    }

    this.currentState = state;
    LogUtil.info(`${TAG} onBluetoothStateChange : ${state} ,BluetoothCurrentState : ${this.currentState}`);

    if (BluetoothUtils.isBluetoothDiscoveryOn(state)) {
      this.updateAutoDiscovery();
    }

    if (BluetoothUtils.isBluetoothStateOn(state)) {
      this.updateBondedDevices();
    } else {
      if (BluetoothUtils.isBluetoothStateOff(this.currentState)) {
        // 清理配对中、连接中数据
        this.resetPairAndConnectStatus();
      }
    }
    this.dispatchBluetoothStateChange(state);
  }
  public onBluetoothDeviceFind = (devices: Array<connection.DiscoveryResult>) => {
    if (CheckEmptyUtils.isEmptyArr(devices)) {
      LogUtil.error(`${TAG} the devices is invalid, or deviceName is empty`);
      return;
    }
    LogUtil.info(`${TAG} onBluetoothDeviceFind, deviceId:${BluetoothUtils.getLogMAC(devices[0].deviceId)}`);
    if (CheckEmptyUtils.checkStrIsEmpty(devices[0].deviceName)) {
      LogUtil.warn(`${TAG} the deviceName is empty, add device to cache but not refresh device list`);
      let deviceId: string = devices[0].deviceId;
      let device: BluetoothDevice = this.cachedManager.findDevice(deviceId);
      if (!device) {
        device = BluetoothDevice.createDevice(deviceId, devices[0].deviceName, devices[0].rssi) as BluetoothDevice;
        this.cachedManager.addDevice(device);
      }
      return;
    }
    let device: BluetoothDevice = BluetoothAdapter.getInstance()
      .getBondedDeviceOrSubDevice(devices[0].deviceId) as BluetoothDevice;
    if (device) {
      return;
    }
    this.bluetoothDevices = devices;
    if (!devices) {
      return;
    }
    this.updateDeviceList();
  }

  updateDeviceList() {
    for (let deviceInfo of this.bluetoothDevices) {
      Promise.resolve(this.onDeviceFound(deviceInfo));
    }
  }

  private dispatchDeviceClear(): void {
    for (let listener of this.deviceChangeListeners) {
      listener?.onAvailableDeviceClear();
    }
  }

  public onBluetoothBondStateChange = (stateParam: BondStateParam) => {
    if (!stateParam) {
      return;
    }
    LogUtil.info(`${TAG} onBluetoothBondStateChange : ${stateParam?.state}, device : ${BluetoothUtils.getLogMAC(stateParam?.deviceId)}`);
    if (stateParam.state === BondState.BOND_STATE_BONDING) {
      if (!bluetoothPairManager.pairDeviceId) {
        bluetoothPairManager.setPairDeviceId(stateParam.deviceId);
      }
      if (!bluetoothPairManager.listener) {
        bluetoothPairManager.setListener(this);
      }
    }
    this.bondStateChangeInner(stateParam);
    this.dispatchBondStateChange(stateParam);
    bluetoothPairManager.onBluetoothBondStateChange(stateParam);
  }
  public onBluetoothPinRequired = (pinRequiredParam: PinRequiredParam) => {
    if (pinRequiredParam === null || pinRequiredParam.deviceId === null) {
      return;
    }
    bluetoothPairManager.setPairDeviceId(pinRequiredParam.deviceId);
    bluetoothPairManager.setListener(BluetoothAdapter.getInstance());
    LogUtil.info(`${TAG} onBluetoothPinRequired, device : ${BluetoothUtils.getLogMAC(pinRequiredParam.deviceId)}`);
    this.dispatchPinRequired(pinRequiredParam);
  }
  public onBluetoothPinRequiredForPhone = (deviceId: string) => {
    if (CheckEmptyUtils.checkStrIsEmpty(deviceId)) {
      return;
    }

    bluetoothPairManager.setPairDeviceId(deviceId);
    bluetoothPairManager.setListener(BluetoothAdapter.getInstance());
    LogUtil.info(`${TAG} onBluetoothPinRequiredForPhone, deviceId: ${BluetoothUtils.getLogMAC(deviceId)}`);
  };

  private bondStateChangeInner(stateParam: BondStateParam): void {
    if (!stateParam) {
      return;
    }
    let deviceId = stateParam.deviceId;
    if (stateParam.state !== BondState.BOND_STATE_BONDED && this.cachedBondedDevices.has(deviceId)) {
      LogUtil.info(`${TAG} bondStateChangeInner delete the device from cachedBondedDevices`);
      this.cachedBondedDevices.delete(deviceId);
    }

    if (stateParam.state === BondState.BOND_STATE_BONDED && !this.cachedBondedDevices.has(deviceId)) {
      this.cachedBondedDevices.set(deviceId,
        this.cachedManager.findDevice(deviceId) ?? BluetoothDevice.createDevice(deviceId));
    }

    this.isPairing = stateParam.state === BondState.BOND_STATE_BONDING;
  }

  private dispatchBondStateChange(stateParam: BondStateParam): void {
    for (let listener of this.bondChangeListeners) {
      listener?.onBluetoothBondStateChange(stateParam);
    }
  }

  getBondedDevices(): IterableIterator<BluetoothDevice> {
    return this.cachedBondedDevices.values();
  }

  getBondedDevicesCount(): number {
    return this.cachedBondedDevices.size;
  }

  isBondedDevice(deviceId: string): boolean {
    if (this.isBondedMainDevice(deviceId)) {
      return true;
    }
    return this.isBondedSubDevice(deviceId);
  }

  isBondedMainDevice(deviceId: string): boolean {
    return this.cachedBondedDevices.has(deviceId)
  }

  isBondedSubDevice(deviceId: string): boolean {
    for (let bondedDevice of this.cachedBondedDevices.values()) {
      if (bondedDevice?.getSubDevice()?.deviceId === deviceId) {
        return true;
      }
    }
    return false;
  }

  getBondedDevice(deviceId: string): BluetoothDevice {
    return this.cachedBondedDevices.get(deviceId) as BluetoothDevice;
  }

  getBondedDeviceOrSubDevice(deviceId: string): BluetoothDevice {
    let device = this.getBondedDevice(deviceId) as BluetoothDevice;
    if (device !== undefined) {
      return device;
    }
    for (let bondedDevice of this.cachedBondedDevices.values()) {
      if (bondedDevice?.getSubDevice()?.deviceId === deviceId) {
        return bondedDevice.getSubDevice() as BluetoothDevice;
      }
    }
    return device
  }

  setBondedDevice(deviceId: string, device: BluetoothDevice): void {
    this.setCachedBondedDevice(deviceId, device);
  }

  setBondedDeviceName(deviceId: string, deviceName: string): void {
    let device: BluetoothDevice = this.getBondedDevice(deviceId);
    if (!device) {
      device = BluetoothDevice.createDevice(deviceId) as BluetoothDevice;
    }
    device.deviceName = deviceName;
    this.setCachedBondedDevice(deviceId, device);
  }

  findMainDeviceBySubDevice(subDeviceId: string): BluetoothDevice | undefined {
    for (let bondedDevice of this.cachedBondedDevices.values()) {
      if (bondedDevice.getSubDevice()?.deviceId === subDeviceId) {
        return bondedDevice;
      }
    }
    return undefined;
  }

  updateBluetoothCaches(deviceId: string, deviceName: string): void {
    this.setBondedDeviceName(deviceId, deviceName);
    this.updateCacheDevices(deviceId, deviceName);
  }

  private setCachedBondedDevice(deviceId: string, device: BluetoothDevice): void {
    if (this.mergedHearingAidDevice(this.cachedBondedDevices, device)) {
      this.dispatchBondedDeviceMerged(device);
      return;
    }
    this.cachedBondedDevices.set(deviceId, device);
  }

  private dispatchPinRequired(pinRequiredParam: PinRequiredParam): void {
    for (let listener of this.bondChangeListeners) {
      listener?.onBluetoothPinRequired(pinRequiredParam);
    }
  }

  private dispatchBluetoothStateChange(state: number): void {
    for (let listener of this.stateChangeListeners) {
      listener?.onBluetoothStateChange(state);
    }
  }

  getDeviceName(deviceId: string): string {
    let deviceName: string = BluetoothDevice.getDeviceName(deviceId) as string;
    if (!deviceName) {
      deviceName = bluetooth.getRemoteDeviceName(deviceId);
      LogUtil.info(`${TAG} getDeviceName deviceName: ${LogMaskUtil.getLogNickNameString(deviceName)} , deviceId: ${BluetoothUtils.getLogMAC(deviceId)}`);
    }
    return deviceName;
  }

  updateCacheDevices(deviceId: string, deviceName: string, rssi?: number): void {
    let device: BluetoothDevice = this.cachedManager.findDevice(deviceId);
    if (!device) {
      device = BluetoothDevice.createDevice(deviceId, '', rssi) as BluetoothDevice;
    }
    device.deviceName = deviceName;
    this.cachedManager.addDevice(device);
  }

  private onDeviceFound(deviceInfo: connection.DiscoveryResult): void {
    LogUtil.info(`${TAG} onDeviceFound,deviceId: ${BluetoothUtils.getLogMAC(deviceInfo.deviceId)}`);
    let device = this.cachedManager.findDevice(deviceInfo.deviceId);
    if (!device) {
      // 新发现
      device = BluetoothDevice.createDevice(deviceInfo.deviceId, deviceInfo.deviceName,
        deviceInfo.rssi) as BluetoothDevice;
      LogUtil.info(`${TAG} find device, deviceId: ${BluetoothUtils.getLogMAC(deviceInfo.deviceId)}, rssi: ${deviceInfo.rssi}`);
      if (this.cachedManager.addDevice(device)) {
        this.dispatchDeviceAdded(device); // 只有新设备通知添加
      }
    } else {
      LogUtil.info(`${TAG} update device, deviceId: ${BluetoothUtils.getLogMAC(deviceInfo.deviceId)}, rssi: ${deviceInfo.rssi}`);
      device.update(deviceInfo.deviceName, deviceInfo.rssi);
      this.dispatchDeviceAttributesChanged(device); // 通知设备属性变更
    }
    device.setDiscover(true);
    this.delayRefreshAvailableDevice();
  }

  private delayRefreshAvailableDevice(delayTime: number = 1000): void {
    if (this.delayDispatchDeviceRefreshTimer) {
      return;
    }

    this.delayDispatchDeviceRefreshTimer = setTimeout(() => {
      this.delayDispatchDeviceRefreshTimer = null;
      this.dispatchDeviceRefresh();
    }, delayTime);
  }

  private dispatchDeviceRefresh(): void {
    for (let listener of this.deviceChangeListeners) {
      listener?.onAvailableDevicesRefresh();
    }
  }

  private dispatchDeviceAdded(device: BluetoothDevice): void {
    if (!device) {
      return;
    }
    for (let listener of this.deviceChangeListeners) {
      listener?.onDeviceAdded(device);
    }
  }

  private dispatchDeviceNameUpdate(device: BluetoothDevice): void {
    for (let listener of this.deviceNameUpdateListeners) {
      listener?.onDeviceNameUpdate(device);
    }
  }

  private dispatchDeviceAttributesChanged(device: BluetoothDevice): void {
    if (!device) {
      return;
    }
    for (let listener of this.deviceChangeListeners) {
      listener?.onDeviceAttributesChanged(device);
    }
  }

  private dispatchBondedDeviceMerged(device: BluetoothDevice): void {
    if (!device) {
      return;
    }
    for (let listener of this.bondedDeviceChangeListeners) {
      listener?.onBondedDeviceMerged(device);
    }
  }

  registerRemoveSummaryListener(listener: BluetoothRemoveSummaryListener): void {
    for (const bluetoothRemoveSummaryListener of this.bluetoothRemoveSummaryListeners) {
      if (bluetoothRemoveSummaryListener.getListenKey() === listener.getListenKey()) {
        return;
      }
    }
    this.bluetoothRemoveSummaryListeners.push(listener);
  }

  unRegisterRemoveSummaryListener(listener: BluetoothRemoveSummaryListener): void {
    for (let index = 0; index < this.bluetoothRemoveSummaryListeners.length; index++) {
      if (this.bluetoothRemoveSummaryListeners[index].getListenKey() === listener.getListenKey()) {
        this.bluetoothRemoveSummaryListeners.splice(index, 1);
        return;
      }
    }
  }

  registerStateChangeListener(listener: BluetoothStateChangeListener): void {
    for (const stateChangeListener of this.stateChangeListeners) {
      if (stateChangeListener.getListenKey() === listener.getListenKey()) {
        return;
      }
    }
    this.stateChangeListeners.push(listener);
  }

  // 需要使用到数组下角标因此使用for循环
  unRegisterStateChangeListener(listener: BluetoothStateChangeListener): void {
    for (let index = 0; index < this.stateChangeListeners.length; index++) {
      if (this.stateChangeListeners[index].getListenKey() === listener.getListenKey()) {
        this.stateChangeListeners.splice(index, 1);
        return;
      }
    }
  }

  registerDeviceChangeListener(listener: BluetoothDeviceChangeListener): void {
    for (const deviceChangeListener of this.deviceChangeListeners) {
      if (deviceChangeListener.getListenKey() === listener.getListenKey()) {
        return;
      }
    }
    this.deviceChangeListeners.push(listener);
  }

  unRegisterDeviceChangeListener(listener: BluetoothDeviceChangeListener): void {
    for (let index = 0; index < this.deviceChangeListeners.length; index++) {
      if (this.deviceChangeListeners[index].getListenKey() === listener.getListenKey()) {
        this.deviceChangeListeners.splice(index, 1);
        return;
      }
    }
  }

  registerDeviceNameUpdateListener(listener: BluetoothDeviceNameUpdateListener): void {
    for (const deviceNameUpdateListeners of this.deviceNameUpdateListeners) {
      if (deviceNameUpdateListeners.getListenKey() === listener.getListenKey()) {
        return;
      }
    }
    this.deviceNameUpdateListeners.push(listener);
  }

  unRegisterDeviceNameUpdateListener(listener: BluetoothDeviceNameUpdateListener): void {
    for (let index = 0; index < this.deviceNameUpdateListeners.length; index++) {
      if (this.deviceNameUpdateListeners[index].getListenKey() === listener.getListenKey()) {
        this.deviceNameUpdateListeners.splice(index, 1);
        return;
      }
    }
  }

  registerBondChangeListener(listener: BluetoothBondChangeListener): void {
    for (const bondChangeListener of this.bondChangeListeners) {
      if (bondChangeListener.getListenKey() === listener.getListenKey()) {
        return;
      }
    }
    this.bondChangeListeners.push(listener);
  }

  unRegisterBondChangeListener(listener: BluetoothBondChangeListener): void {
    for (let index = 0; index < this.bondChangeListeners.length; index++) {
      if (this.bondChangeListeners[index].getListenKey() === listener.getListenKey()) {
        this.bondChangeListeners.splice(index, 1);
        return;
      }
    }
  }

  registerLoadChangeListener(listener: BluetoothLoadStateChangeListener): void {
    for (const loadingStateChangerListener of this.loadingStateChangerListeners) {
      if (loadingStateChangerListener.getListenKey() === listener.getListenKey()) {
        return;
      }
    }
    this.loadingStateChangerListeners.push(listener);
  }

  unRegisterLoadChangeListener(listener: BluetoothLoadStateChangeListener): void {
    for (let index = 0; index < this.loadingStateChangerListeners.length; index++) {
      if (this.loadingStateChangerListeners[index].getListenKey() === listener.getListenKey()) {
        this.loadingStateChangerListeners.splice(index, 1);
        return;
      }
    }
  }

  registerProfileStateChangeListener(listener: BluetoothProfileStateChangeListener): void {
    for (const profileStateChangeListener of this.profileStateChangeListeners) {
      if (profileStateChangeListener.getListenKey() === listener.getListenKey()) {
        return;
      }
    }
    this.profileStateChangeListeners.push(listener);
  }

  unRegisterProfileStateChangeListener(listener: BluetoothProfileStateChangeListener): void {
    for (let index = 0; index < this.profileStateChangeListeners.length; index++) {
      if (this.profileStateChangeListeners[index].getListenKey() === listener.getListenKey()) {
        this.profileStateChangeListeners.splice(index, 1);
        return;
      }
    }
  }

  registerBondedDeviceChangeListener(listener: BluetoothBondedDeviceChangeListener): void {
    for (const bondedDeviceChangeListener of this.bondedDeviceChangeListeners) {
      if (bondedDeviceChangeListener.getListenKey() === listener.getListenKey()) {
        return;
      }
    }
    this.bondedDeviceChangeListeners.push(listener);
  }

  unregisterBondedDeviceChangeListener(listener: BluetoothBondedDeviceChangeListener): void {
    for (let index = 0; index < this.bondedDeviceChangeListeners.length; index++) {
      if (this.bondedDeviceChangeListeners[index].getListenKey() === listener.getListenKey()) {
        this.bondedDeviceChangeListeners.splice(index, 1);
        return;
      }
    }
  }

  public updateBondedDevices(): void {
    let bondedDevices: Map<string, BluetoothDevice> = new Map();
    let devices = bluetooth.getPairedDevices();
    LogUtil.info(`${TAG} updateBondedDevices length : ${devices.length}`);

    for (let deviceId of devices) {
      LogUtil.info(`${TAG} updateBondedDevices device : ${BluetoothUtils.getLogMAC(deviceId)}`);
      let device = this.getBondedDeviceOrSubDevice(deviceId);
      // 保存当前设备名称，避免被系统获取的原始名称覆盖
      let cachedDeviceName = device?.deviceName;
      device?.update();
      // 如果有缓存的设备名称，使用它而不是系统获取的名称
      if (cachedDeviceName) {
        device.deviceName = cachedDeviceName;
      }
      if (!device) {
        // 检查是否有缓存的设备名称
        let existingDevice = this.getBondedDevice(deviceId);
        let cachedDeviceName = existingDevice?.deviceName;
        device = BluetoothDevice.createDevice(deviceId) as BluetoothDevice;
        // 如果有缓存的设备名称，直接应用
        if (cachedDeviceName) {
          device.deviceName = cachedDeviceName;
        }
        device.updateProfilesAndConnectionStatus().then(() => {
          LogUtil.info(`${TAG}, updateBondedDevices createDevice update ${BluetoothUtils.getLogMAC(deviceId)}`);
          if (!device) {
            return;
          }
          // 在更新设备信息后再次检查并应用缓存的设备名称
          if (cachedDeviceName) {
            device.deviceName = cachedDeviceName;
          } else {
            device.update();
          }
          this.dispatchDeviceAttributesChanged(device);
          if (this.mergedHearingAidDevice(bondedDevices, device)) {
            this.cachedBondedDevices.delete(deviceId);
            this.dispatchBondedDeviceMerged(device);
          }
        });
      }
      if (this.mergedHearingAidDevice(bondedDevices, device)) {
        this.dispatchBondedDeviceMerged(device);
        continue;
      }
      bondedDevices.set(deviceId, device as BluetoothDevice);
    }

    this.cachedBondedDevices = bondedDevices;
  }

  public updateSwitchState(): void {
    this.currentState = BluetoothUtils.getCurrentBluetoothState();
  }

  public updatePairingState(): void {
    let state: BondState = Utils.getPairState(bluetoothPairManager.pairDeviceId ?? '');
    this.isPairing = state === BondState.BOND_STATE_BONDING;
    if (!this.isPairing) {
      bluetoothPairManager.finishPair();
      this.isPauseDiscover = false;
    }
  }

  start(): void {
    LogUtil.info(`${TAG} start. isStart:${this.isStart}`);
    if (!this.isStart) {
      this.isStart = true;
      this.currentState = bluetooth.getState();
      LogUtil.info(`${TAG} start,  currentState : ${this.currentState}`);
      bluetooth.on('stateChange', this.onBluetoothStateChange);
      try {
        connection.on('bondStateChange', this.onBluetoothBondStateChange as Callback<connection.BondStateParam>);
      } catch (error) {
        LogUtil.error(`${TAG} on bondStateChange failed, ${error?.message}`);
      }
      this.profileManager.start(this);
      if (this.isBluetoothOn()) {
        // 初始化时如果蓝牙已开启，立即同步一次本机名称到蓝牙本地名称
        this.syncLocalNameWithDeviceName();
        this.setLocalProfileUuids();
      }
      if (!this.isPairBluetoothAdapter) {
        LogUtil.info(`${TAG} is not pairDialog`);
        this.updateBondedDevices();
        if (!this.isIgnoreDiscovery) {
          try {
            connection.on('discoveryResult', this.onBluetoothDeviceFind);
          } catch (error) {
            LogUtil.error(`${TAG} is discoveryResult error, ${error?.message}`);
          }

          this.updateAutoDiscovery();
          this.discoveryStartedCommonEvent.registerCommonEvent();
          this.discoveryFinishCommonEvent.registerCommonEvent();
        }
        this.discoveryRemoteDeviceUUIDInfoEvent.registerCommonEvent();
        this.updateRemoteDeviceNameCommonEvent.registerCommonEvent();
      } else {
        LogUtil.info(`${TAG} is pairDialog , pass setting discovery`);
      }
    }
  }

  private async setLocalProfileUuids(): Promise<void> {
    try {
      this.localProfileUuids = await connection.getLocalProfileUuids();
      LogUtil.info(`${TAG} setLocalProfileUuids , size : ${this.localProfileUuids.length}`);
    } catch (err) {
      LogUtil.error(`${TAG} getLocalProfileUuids failed. code:${err?.code} message:${err?.message}`);
    }
  }

  private updateInitStates(): void {
    this.updateBondedDevices();
    this.updateAutoDiscovery();
  }

  stop(): void {
    if (this.isStart) {
      LogUtil.info(`${TAG} stop`);
      bluetooth.off('stateChange', this.onBluetoothStateChange);
      try {
        connection.off('bondStateChange', this.onBluetoothBondStateChange as Callback<connection.BondStateParam>);
      } catch (error) {
        LogUtil.error(`${TAG} off bondStateChange failed, ${error?.message}`);
      }
      if (!this.isPairBluetoothAdapter) {
        LogUtil.info(`${TAG} is not pairDialog`);
        try {
          connection.off('discoveryResult', this.onBluetoothDeviceFind);
        } catch (error) {
          LogUtil.error(`${TAG} off discoveryResult failed, ${error?.message}`);
        }
        this.stopDiscovery();
        this.discoveryStartedCommonEvent.unRegisterCommonEvent();
        this.discoveryFinishCommonEvent.unRegisterCommonEvent();
        this.discoveryRemoteDeviceUUIDInfoEvent.unRegisterCommonEvent();
        this.updateRemoteDeviceNameCommonEvent.unRegisterCommonEvent();
      } else {
        LogUtil.info(`${TAG} is pairDialog , pass setting discovery`);
      }
      this.closeScanTimer()
      this.isStart = false;
      this.resetPairAndConnectStatus();
      this.profileManager.stop();
    }
  }

  /**
   * 退出，清理数据
   */
  onQuit(): void {
    this.stop();
    this.releaseResource();
  }

  private resetPairAndConnectStatus(): void {
    LogUtil.info(`${TAG} resetPairAndConnectStatus`);
    this.profileManager.finishConnect();
    bluetoothPairManager.finishPair();
    this.isPauseDiscover = false;
    this.isPairing = false;
    this.connectingIds.clear();
    this.isDiscovering = false;
    EventBus.getInstance().emit('Setting.Bluetooth.AvailableDeviceGroup.isScanLoadingShow', false);

    this.dispatchDeviceClear();
    this.cachedManager.clear();
  }

  private releaseResource(): void {
    if (!this.isPairBluetoothAdapter) {
      LogUtil.info(`${TAG} is not pairDialog`);
      this.setAutoDiscovery(false);
    } else {
      LogUtil.info(`${TAG} is pairDialog , pass setting discovery`);
    }
    this.resetPairAndConnectStatus();
    this.stateChangeListeners = [];
    this.deviceChangeListeners = [];
    this.deviceNameUpdateListeners = [];
    this.bondChangeListeners = [];
  }

  private delayStartDiscovery(delayTime: number): void {
    LogUtil.info(`${TAG} delayStartDiscovery`);
    if (this.delayStartDiscoveryTimer) {
      LogUtil.info(`${TAG} already has delayStartDiscoveryTimer`);
      return;
    }
    if (!this.isNeedStartDiscovery()) {
      LogUtil.info(`${TAG} not need to discovery, return`);
      return;
    }
    this.delayStartDiscoveryTimer = null;
    this.delayStartDiscoveryAfterPairFinishTimer = null;
    this.resetDiscoverState();
    this.dispatchDeviceClear();
    this.cachedManager.clear();
    this.startDiscovery();
    this.delayStartDiscoveryTimer = setInterval(() => {
      LogUtil.info(`${TAG} startDiscovery after delay`);
      this.startDiscovery();
    }, 5000);
  }

  //关闭定时器
  closeScanTimer() {
    LogUtil.info(`${TAG} updateAutoDiscovery. closeTimer`);
    clearTimeout(this.delayStartDiscoveryTimer)
    this.delayStartDiscoveryTimer = null
  }

  private onDiscoveryFinish(): void {
    LogUtil.info(`${TAG} onDiscoveryFinish. isBluetoothPageShow:${this.isBluetoothPageShow}`);
    this.stopDiscovery();
    if (this.isBluetoothPageShow) {
      this.delayStartDiscovery(DELAY_DISCOVERY_START_DISCOVERY_TIME);
    }
  }

  /**
   * 设置自动扫描开始/停止
   *
   * @param isAutoDiscover true : 开始， false : 停止
   */
  setAutoDiscovery(isAutoDiscover: boolean): void {
    LogUtil.info(`${TAG} setAutoDiscovery. old:${this.isAutoDiscover} new:${isAutoDiscover}`);
    if (this.isAutoDiscover != isAutoDiscover) {
      this.isAutoDiscover = isAutoDiscover;
      this.updateAutoDiscovery();
    }
  }

  private updateAutoDiscovery(delayTime: number = DELAY_DISCOVERY_STATE_TIME): void {
    if (this.isAutoDiscover && this.isBluetoothOn() && this.isStart && this.isBluetoothPageShow) {
      LogUtil.info(`${TAG} updateAutoDiscovery. delayStartDiscovery`);
      this.delayStartDiscovery(delayTime);
    } else {
      LogUtil.info(`${TAG} updateAutoDiscovery. isBluetoothOn:${this.isBluetoothOn()}`);
      this.closeScanTimer()
      if (this.isBluetoothOn()) {
        this.stopDiscovery();
      } else {
        this.isDiscovering = false;
        EventBus.getInstance().emit('Setting.Bluetooth.AvailableDeviceGroup.isScanLoadingShow', false);
      }
    }
  }

  private dispatchDiscoveryState(status: boolean): void {
    for (let listener of this.loadingStateChangerListeners) {
      listener?.onChangeLoadingStatus(status);
    }
  }

  private isNeedStartDiscovery(): boolean {
    LogUtil.info(`${TAG} checkStartDiscovery ${this.isAutoDiscover}, ${this.isStart}, ${this.isDiscovering}, ${this.isBluetoothOn()}, ${this.isPauseDiscover}, ${this.isIgnoreDiscovery}, ${this.isPairBluetoothAdapter}`);
    return this.isAutoDiscover && this.isStart && !this.isDiscovering && this.isBluetoothOn() &&
      !this.isPauseDiscover && !this.isIgnoreDiscovery && !this.isPairBluetoothAdapter;
  }

  /**
   * 同步蓝牙本地名称与系统设备名称
   * 在蓝牙状态变为开启、开始扫描等场景统一调用，保证广播名称和“本机名称”一致。
   */
  private syncLocalNameWithDeviceName(): void {
    try {
      const deviceName: string = DeviceNameUtil.getDeviceNameAsync();
      if (CheckEmptyUtils.checkStrIsEmpty(deviceName)) {
        LogUtil.warn(`${TAG} syncLocalNameWithDeviceName, deviceName is empty`);
        return;
      }
      const localName: string = bluetooth.getLocalName();
      if (localName !== deviceName) {
        bluetooth.setLocalName(deviceName);
        LogUtil.info(`${TAG} syncLocalNameWithDeviceName, setLocalName success. localName: ${localName}, deviceName: ${deviceName}`);
      } else {
        LogUtil.info(`${TAG} syncLocalNameWithDeviceName, localName already up to date`);
      }
    } catch (error) {
      LogUtil.error(`${TAG} syncLocalNameWithDeviceName failed, error: ${error?.message}`);
    }
  }

  startDiscovery(): void {
    LogUtil.info(`${TAG} startDiscovery`);
    let result = bluetooth.startBluetoothDiscovery();

    // 每次开始扫描前，同步一次本地名称，避免辅助设备看到的名字落后
    this.syncLocalNameWithDeviceName();
    LogUtil.info(`${TAG} startBluetoothDiscovery, result : ${result}`);
    if (!result) {
      if (this.retryTime > 0) {
        this.retryTime--;
        bluetooth.stopBluetoothDiscovery();
        this.updateAutoDiscovery(DELAY_DISCOVERY_STATE_RETRY_TIME);
      } else {
        LogUtil.error(`${TAG} try startBluetoothDiscovery failed`);
        this.retryTime = DISCOVERY_RETRY_COUNT;
        this.dispatchDiscoveryState(false);
      }
      return;
    }
    this.retryTime = DISCOVERY_RETRY_COUNT;
    if (this.isBluetoothPageShow) {
      this.isDiscovering = true;
      EventBus.getInstance().emit('Setting.Bluetooth.AvailableDeviceGroup.isScanLoadingShow', true);
    }
  }

  private resetDiscoverState(): void {
    let devices = Array.from(this.cachedManager.getCachedDevices());
    for (let device of devices) {
      device?.setDiscover(false);
    }
  }

  private isBluetoothOn(): boolean {
    return BluetoothUtils.isBluetoothStateOn(this.currentState);
  }

  stopDiscovery(): boolean {
    LogUtil.info(`${TAG} stopDiscovery`);
    if (!this.isDiscovering) {
      LogUtil.info(`${TAG} not discovering, return`);
      return false;
    }

    this.isDiscovering = false;
    EventBus.getInstance().emit('Setting.Bluetooth.AvailableDeviceGroup.isScanLoadingShow', false);
    if (!this.isBluetoothOn()) {
      LogUtil.info(`${TAG} Bluetooth state off, stopDiscovery return`);
      this.dispatchDiscoveryState(false);
      return true;
    }

    let result = bluetooth.stopBluetoothDiscovery();
    LogUtil.info(`${TAG} stopBluetoothDiscovery, result : ${result}`);
    return true;
  }

  private updateCachedDeviceDiscover(): void {
    let devices = Array.from(this.cachedManager.getCachedDevices());
    for (let device of devices) {
      if (!device?.getDiscover()) {
        this.cachedManager.removeDevice(device?.deviceId);
      }
    }
  }

  private dispatchDeviceDeleted(device: BluetoothDevice): void {
    for (let listener of this.deviceChangeListeners) {
      listener?.onDeviceDeleted(device);
    }
  }

  private pauseDiscover(): void {
    LogUtil.info(`${TAG} pauseDiscover`);
    this.isPauseDiscover = true;
    this.stopDiscovery();
  }

  private restoreDiscover(): void {
    LogUtil.info(`${TAG} restoreDiscover. this.isAutoDiscover:${this.isAutoDiscover}`);
    this.isPauseDiscover = false;
    if (this.isAutoDiscover) {
      LogUtil.info(`${TAG} startDiscovery after restoreDiscover`);
      this.startDiscovery();
    }
  }

  /**
   * 发起配对流程
   *
   * @param deviceId 待配对的设备ID
   */
  pairDevice(deviceId: string): boolean {
    if (!deviceId) {
      LogUtil.error(`${TAG} pairDevice param empty`);
    }
    if (this.isPairing) {
      LogUtil.warn(`${TAG} isPairing, pairDevice return`);
      return false;
    }

    if (!this.isBluetoothOn()) {
      LogUtil.warn(`${TAG} Bluetooth off, pairDevice return`);
      return false;
    }

    this.pauseDiscover();
    // 标记设备为本地主动配对
    this.connectTimestampManager.setDeviceBondedFromLocal(deviceId);
    this.isPairing = true;
    LogUtil.info(`${TAG} pairDevice start, device :  ${BluetoothUtils.getLogMAC(deviceId)}`);
    // 底层蓝牙配对管理器发起实际配对
    let result = bluetoothPairManager.startPair(deviceId, this);
    LogUtil.info(`${TAG} pairDevice result : ${result}`);
    return result;
  }

  onPairResult(deviceId: string, result: number, isSuccess: boolean): void {
    LogUtil.info(`${TAG} onPairResult`);
    this.isPairing = false;
    this.isPauseDiscover = false;
    this.dispatchPairResult(deviceId, result, isSuccess);
    // 基于连接性能考虑，1s后再恢复扫描。若在1秒内有其他场景触发开始扫描，则按照对应逻辑开始扫描即可
    this.restoreDiscoverForPairFinish();
  }

  onCancelPair(deviceId: string): void {
    this.restoreDiscover();
    this.isPairing = false;
    this.removeSummary(deviceId);
  }

  private restoreDiscoverForPairFinish(): void {
    if (this.delayStartDiscoveryAfterPairFinishTimer) {
      LogUtil.info(`${TAG} already has delayStartDiscoveryAfterPairFinishTimer`);
      return;
    }
    this.delayStartDiscoveryAfterPairFinishTimer = setTimeout(() => {
      LogUtil.info(`${TAG} startDiscovery after 1s`);
      this.delayStartDiscoveryAfterPairFinishTimer = null;
      this.startDiscovery();
    }, DELAY_DISCOVERY_START_TIME_PAIR_FINISH);
  }

  removeSummary(deviceId: string): void {
    LogUtil.info(`${TAG} setPinCodeDevicePairingConfirmation removeSummary deviceId: ${BluetoothUtils.getLogMAC(deviceId)}`);
    this.bluetoothRemoveSummaryListeners.forEach((listener) => {
      listener.onRemoveSummary(deviceId);
    })
  }

  private dispatchPairResult(deviceId: string, result: number, isSuccess: boolean): void {
    LogUtil.info(`${TAG} dispatchPairResult`);
    for (let listener of this.bondChangeListeners) {
      listener?.onPairResult(deviceId, result, isSuccess);
    }
  }

  /**
   * 配对确认
   *
   * @param deviceId 正在配对的设备ID
   * @param isAccept 是否接受本次配对的设备
   */
  setDevicePairingConfirmation(deviceId: string, isAccept: boolean): void {
    if (!deviceId) {
      LogUtil.error(`${TAG} setDevicePairingConfirmation, param empty`);
      return;
    }
    if (!this.isBluetoothOn()) {
      LogUtil.warn(`${TAG} setDevicePairingConfirmation, bluetooth off, return`);
      return;
    }
    try {
      bluetooth.setDevicePairingConfirmation(deviceId, isAccept);
    } catch (error) {
      LogUtil.error(`${TAG} setDevicePairingConfirmation, error, error: ${error?.message}`);
    } finally {
      bluetoothPairManager.onDevicePairingConfirmation(deviceId, isAccept);
    }
  }

  setPinCodeDevicePairingConfirmation(deviceId: string, isAccept: boolean, code: string): void {
    if (!deviceId) {
      LogUtil.error(`${TAG} setDevicePairingConfirmation, param empty`);
      bluetoothPairManager.finishPair();
      return;
    }
    if (code === undefined) {
      LogUtil.error(`${TAG} setDevicePairingConfirmation, code is undefined`);
      bluetoothPairManager.finishPair();
      return;
    }
    if (!this.isBluetoothOn()) {
      LogUtil.warn(`${TAG} setDevicePairingConfirmation, bluetooth off, return`);
      bluetoothPairManager.finishPair();
      return;
    }
    try {
      if (!isAccept) {
        LogUtil.info(`${TAG} setPinCodeDevicePairingConfirmation cancelPairingDevice`);
        connection.cancelPairingDevice(deviceId).then(() => {
          LogUtil.info(`${TAG} setPinCodeDevicePairingConfirmation cancelPairingDevice end`);
          bluetoothPairManager.onDevicePairingConfirmation(deviceId, isAccept);
        })
        return;
      }

      connection.setDevicePinCode(deviceId, code).then(() => {
        bluetoothPairManager.onDevicePairingConfirmation(deviceId, isAccept);
      });
    } catch (error) {
      LogUtil.error(`${TAG} setPinCodeDevicePairingConfirmation, error, error: ${error?.message}`);
      bluetoothPairManager.finishPair();
    }
  }

  setDefaultPinCodeDevicePairingConfirmation(deviceId: string, isAccept: boolean): void {
    if (!deviceId) {
      LogUtil.error(`${TAG} setDefaultPinCodeDevicePairingConfirmation, param empty`);
      return;
    }
    if (!this.isBluetoothOn()) {
      LogUtil.warn(`${TAG} setDefaultPinCodeDevicePairingConfirmation, bluetooth off, return`);
      return;
    }
    try {
      connection.cancelPairingDevice(deviceId).then(() => {
        bluetoothPairManager.onDevicePairingConfirmation(deviceId, isAccept);
      })
    } catch (err) {
      LogUtil.error(`${TAG} setDefaultPinCodeDevicePairingConfirmation cancelPairingDevice error, code: ${err?.code} message: ${err?.message}`);
      bluetoothPairManager.onDevicePairingConfirmation(deviceId, isAccept);
    }
    return;
  }

  onBluetoothProfileStateChange(profileId: ProfileId, stateChangeParam: StateChangeParam): void {
    if (!stateChangeParam) {
      return;
    }
    LogUtil.info(`${TAG} onBluetoothProfileStateChange, deviceId: ${BluetoothUtils.getLogMAC(stateChangeParam.deviceId)}`);
    let deviceId: string = stateChangeParam.deviceId;
    if (this.isBondedDevice(deviceId)) {
      let device: BluetoothDevice = this.getBondedDeviceOrSubDevice(deviceId) as BluetoothDevice;
      if (stateChangeParam.state === ProfileConnectionState.STATE_CONNECTED) {
        device?.addProfile(profileId, this.profileManager.profiles.get(profileId) as BluetoothProfile);
        device?.updateConnectionStatus();
        this.connectingIds.remove(deviceId);
        // 连接成功，且属于助听器类型设备，且当前设备不属于其他设备的附属设备时，获取HearingAidId，遍历已配对设备列表，识别合并
        if (device !== undefined && device.isHearingAidDevice() && !this.isBondedSubDevice(deviceId)) {
          // device.setHearingAidId(
          //   (this.profileManager.profiles.get(PROFILE_HEARING_AID) as HearingAidProfile)?.getHearingAidId(deviceId));
          if (this.mergedHearingAidDevice(this.cachedBondedDevices, device)) {
            this.cachedBondedDevices.delete(device?.deviceId);
            this.dispatchBondedDeviceMerged(device);
          }
        }
      }
      LogUtil.info(`${TAG} setEnable status, state: ${stateChangeParam.state}, deviceId: ${BluetoothUtils.getLogMAC(stateChangeParam.deviceId)}`);
      if (stateChangeParam.state === ProfileConnectionState.STATE_CONNECTING) {
        device.setEnable(false);
      } else if (stateChangeParam.state === ProfileConnectionState.STATE_DISCONNECTED) {
        this.handleDisconnectedState(profileId, device);
        this.connectingIds.remove(deviceId);
      } else {
        device.setEnable(true);
      }
    } else {
      LogUtil.warn(`${TAG} onBluetoothProfileStateChange, cachedBondedDevices not contain, deviceId: ${BluetoothUtils.getLogMAC(stateChangeParam.deviceId)}`);
    }
    for (let listener of this.profileStateChangeListeners) {
      listener?.onBluetoothProfileStateChange(profileId, stateChangeParam);
    }
  }

  /**
   * 合并列表中的助听器设备
   *
   * @param cacheDevices 缓存的设备列表
   * @param targetDevice 目标设备
   * @returns 是否合并
   */
  private mergedHearingAidDevice(cacheDevices: Map<string, BluetoothDevice>, targetDevice: BluetoothDevice): boolean {
    for (let device of cacheDevices.values()) {
      if (!device || !device.isHearingAidDevice()) {
        continue;
      }
      if (device.deviceId === targetDevice.deviceId) {
        continue;
      }
      if (device.getHearingAidId() !== undefined && targetDevice.getHearingAidId() !== undefined &&
        device.getHearingAidId() === targetDevice.getHearingAidId()) {
        LogUtil.info(`${TAG} mergedHearingAidDevice findSubDevice ${BluetoothUtils.getLogMAC(targetDevice?.deviceId)}`);
        device.setSubDevice(targetDevice);
        return true;
      }
    }
    return false;
  }

  handleDisconnectedState(profileId: ProfileId, device: BluetoothDevice): void {
    if (!device) {
      return;
    }
    let profile: BluetoothProfile = this.profileManager.profiles.get(profileId) as BluetoothProfile;
    // 正在连接 -> 断连, 需等其他profile的连接结果
    if (profile?.lastState === ProfileConnectionState.STATE_CONNECTING) {
      // 只要有一个协议连接上了，不用关注其他协议的断连情况
      if (this.profileManager.isDeviceConnected(device?.deviceId)) {
        device.setEnable(true);
      } else {
        device.setEnable(this.profileManager.isAllProfileDisconnected(device?.deviceId));
      }
    } else {
      device.setEnable(true);
    }
  }

  getProfileState(profileId: ProfileId, deviceId: string): ProfileConnectionState {
    return this.profileManager.getProfileState(profileId, deviceId);
  }

  isDeviceConnected(deviceId: string): boolean {
    return this.profileManager.isDeviceConnected(deviceId);
  }

  isDeviceConnecting(deviceId: string): boolean {
    return this.profileManager.isDeviceConnecting(deviceId);
  }

  isDeviceConnectedOrConnecting(deviceId: string): boolean {
    return this.profileManager.isDeviceConnectedOrConnecting(deviceId);
  }

  /**
   * 发起连接流程
   *
   * @param deviceId 待连接的设备ID
   */
  startConnect(deviceId: string): boolean {
    if (!this.checkConnectConditionsValid(deviceId)) {
      LogUtil.warn(`${TAG} startConnect. can not connect device, this.isConnecting:${!this.connectingIds.has(deviceId)}`);
      return false;
    }
    if (!this.isBluetoothOn()) {
      LogUtil.warn(`${TAG} startConnect. Bluetooth off`);
      return false;
    }
    LogUtil.info(`${TAG} startConnect. deviceId:${BluetoothUtils.getLogMAC(deviceId)}`);
    this.pauseDiscover();
    this.connectingIds.add(deviceId);
    return this.profileManager.startConnect(deviceId, this);
  }

  /**
   * 点击已配对设备去连接
   */
  startConnectIfSupport(deviceId: string, subDeviceId?: string): boolean {
    LogUtil.info(`${TAG} startConnectIfSupport. deviceId : ${BluetoothUtils.getLogMAC(deviceId)} , subDeviceId : ${BluetoothUtils.getLogMAC(subDeviceId)}`);
    let deviceIdValid: boolean = this.checkConnectConditionsValid(deviceId);
    let subDeviceIdValid: boolean = false;
    if (subDeviceId) {
      subDeviceIdValid = this.checkConnectConditionsValid(subDeviceId);
      LogUtil.info(`${TAG} startConnectIfSupport. subDeviceIdValid : ${subDeviceIdValid}, this.isConnecting:${this.connectingIds.has(subDeviceId)}`);
    }
    if (!deviceIdValid && !subDeviceIdValid) {
      LogUtil.warn(`${TAG} startConnectIfSupport. can not connect all Device`);
      return false;
    }

    let deviceHasProfile: boolean = this.getBondedDeviceOrSubDevice(deviceId)?.profileMap.size !== 0;
    let subDeviceHasProfile: boolean = false;
    if (subDeviceId && subDeviceIdValid) {
      subDeviceHasProfile = this.getBondedDeviceOrSubDevice(subDeviceId)?.profileMap.size !== 0;
      LogUtil.info(`${TAG} startConnectIfSupport. is subDevice has profile:${subDeviceHasProfile}`);
    }
    if (!deviceHasProfile && !subDeviceHasProfile) {
      LogUtil.warn(`${TAG} startConnectIfSupport. the device do not support all profiles currently.`);
      return false;
    }
    LogUtil.info(`${TAG} startConnectIfSupport. deviceId:${BluetoothUtils.getLogMAC(deviceId)}`);
    this.pauseDiscover();
    if (deviceHasProfile && deviceIdValid && deviceId) {
      this.connectingIds.add(deviceId);
    }
    if (subDeviceHasProfile && subDeviceIdValid && subDeviceId) {
      this.connectingIds.add(subDeviceId);
    }
    return this.profileManager.startConnect(deviceId, this, subDeviceId);
  }


  /**
   * 配对完成后调用的连接方法
   */
  connectToDeviceAfterPair(deviceId: string): boolean {
    LogUtil.info(`${TAG} connectToDeviceAfterPair deviceId: ${BluetoothUtils.getLogMAC(deviceId)}`);
    if (!this.checkConnectConditionsValid(deviceId)) {
      LogUtil.warn(`${TAG} can not connect device, this.isConnecting: ${this.connectingIds.has(deviceId)}`);
      return false;
    }
    if (!this.connectTimestampManager.checkIsBondedFromLocal(deviceId)) {
      LogUtil.warn(`${TAG} the device is not bonded from local`);
      return false;
    }

    this.connectTimestampManager.setDeviceConnectTimestamp(deviceId, new Date().getTime()); // 设置时间戳
    if (this.cachedBondedDevices.get(deviceId)?.profileMap.size === 0) {
      LogUtil.warn(`${TAG} the device do not support all profiles currently.`);
      return false;
    }

    this.connectTimestampManager.resetDeviceBondedFromLocal(deviceId);
    this.pauseDiscover();

    this.connectingIds.add(deviceId);
    return this.profileManager.startConnect(deviceId, this);
  }

  private checkConnectConditionsValid(deviceId: string): boolean {
    return !CheckEmptyUtils.checkStrIsEmpty(deviceId) && !this.connectingIds.has(deviceId) &&
      !this.isDeviceConnected(deviceId);
  }

  /**
   * 断开连接
   *
   * @param deviceId 待断开连接的设备ID
   */
  disconnectDevice(deviceId: string): boolean {
    return this.profileManager.disconnectDevice(deviceId);
  }

  /**
   * disconnect profile.
   * @param deviceId device id
   * @param profileId profile id
   */
  disconnectProfile(deviceId: string | undefined, profileId: number): void {
    this.profileManager.disconnectProfile(deviceId, profileId)
  }

  /**
   * Connect profile.
   * @param deviceId device id
   * @param profileId profile id
   */
  connectProfile(deviceId: string, profileId: number): void {
    this.profileManager.connectProfile(deviceId, profileId);
  }

  onConnectResult(deviceId: string, result: number, isSuccess: boolean): void {
    LogUtil.info(`${TAG} onConnectResult. deviceId:${BluetoothUtils.getLogMAC(deviceId)} result:${result} isSuccess:${isSuccess}`);
    this.connectTimestampManager.resetDeviceConnectTimestamp(deviceId);
    this.dispatchConnectResult(deviceId, result, isSuccess);
    this.connectingIds.remove(deviceId);
    if (this.connectingIds.isEmpty()) {
      // 恢复扫描
      this.restoreDiscover();
    }
  }

  private dispatchConnectResult(deviceId: string, result: number, isSuccess: boolean): void {
    for (let listener of this.profileStateChangeListeners) {
      listener?.onConnectResult(deviceId, result, isSuccess);
    }
  }

  /**
   * 获取蓝牙管理类单例
   */
  static getInstance(): BluetoothAdapter {
    if (!Boolean(AppStorage.get<BluetoothAdapter>('bluetoothAdapter') as BluetoothAdapter).valueOf()) {
      AppStorage.setOrCreate<BluetoothAdapter>('bluetoothAdapter', new BluetoothAdapter());
    }
    return AppStorage.get<BluetoothAdapter>('bluetoothAdapter') as BluetoothAdapter;
  }
}


/**
 * 开关菜单控制器
 *
 * @since 2022-03-21
 */
export class BluetoothStrategySwitchMenuController extends SwitchMenuController implements BluetoothStateChangeListener,
BluetoothProfileStateChangeListener {
  public tag: string = 'BluetoothStrategySwitchMenuController';
  public isChecked: boolean = false;
  public device?: BluetoothDevice | null = null;
  public connectProfile: ConnectionProfile | null = null;
  public connectionProfile: ConnectionProfile | null = null;
  public lastSummaryStatus: SummaryStatus | null = null;
  public isRequestFocus: boolean = true;
  public refreshFromOther: boolean = false;
  public profileMap: Map<string, Map<ProfileId, ProfileConnectionState>> = new Map();

  getListenKey(): string {
    return this.getKey();
  }

  aboutToAppear(): void {
    LogUtil.info(`${this.tag} aboutToAppear`);
    super.aboutToAppear();
  }

  aboutToDisappear(): void {
    super.aboutToDisappear();
  }

  getConnectionProfile(): ConnectionProfile | null | undefined {
    return BluetoothAdapter.getInstance()
      .profileManager?.profiles?.get(this.getProfileId())?.connectionStrategyProfile;
  }

  onBluetoothStateChange(state: number): void {
    LogUtil.info(`${this.tag} onBluetoothStateChange, state :${state}`);
    this.updateToggleStatus(state, BluetoothUtils.isBluetoothDiscoveryOn(state) ?
      this.getConnectionProfile()?.getConnectionState(this.device!.deviceId as string) :
      ProfileConnectionState.STATE_DISCONNECTED);
  }

  onBluetoothProfileStateChange(profileId: ProfileId, stateChangeParam: StateChangeParam): void {
    if (!stateChangeParam) {
      return;
    }
    if (this.profileMap.has(stateChangeParam.deviceId)) {
      let deviceProfileMap: Map<ProfileId, ProfileConnectionState> | undefined =
        this.profileMap.get(stateChangeParam.deviceId);
      if (deviceProfileMap?.get(profileId)?.valueOf() === stateChangeParam.state.valueOf()) {
        LogUtil.info(`${this.tag} onBluetoothProfileStateChange , profileStateChange has changed`);
        return;
      }
    }
    if (this.profileMap.has(stateChangeParam.deviceId)) {
      let deviceProfileMap: Map<ProfileId, ProfileConnectionState> | undefined =
        this.profileMap.get(stateChangeParam.deviceId);
      if (deviceProfileMap) {
        deviceProfileMap.set(profileId, stateChangeParam.state);
      } else {
        deviceProfileMap = new Map();
        deviceProfileMap.set(profileId, stateChangeParam.state);
        this.profileMap.set(stateChangeParam.deviceId, deviceProfileMap);
      }
    } else {
      let deviceProfileMap: Map<ProfileId, ProfileConnectionState> = new Map();
      deviceProfileMap.set(profileId, stateChangeParam.state);
      this.profileMap.set(stateChangeParam.deviceId, deviceProfileMap);
    }
    LogUtil.info(`${this.tag} onBluetoothProfileStateChange, profileId: ${profileId},state :${stateChangeParam.state}`);
    if (profileId === this.getProfileId()) {
      this.refreshFromOther = false;
      this.updateToggleStatus(bluetooth.getState(), stateChangeParam.state);
    }
  }

  onConnectResult(deviceId: string, result: number, isSuccess: boolean): void {
  }

  protected getProfileId(): ProfileId {
    return ProfileId.PROFILE_A2DP_SOURCE;
  }

  protected getConnectProfileId(): constant.ProfileId {
    return constant.ProfileId.PROFILE_HID_HOST;
  }

  private getDevice(params: PushParam): BluetoothDevice | null {
    let device: BluetoothDevice | null = null;
    if (params) {
      device = params.config as BluetoothDevice;
    }
    if (!device) {
      LogUtil.info(`${this.tag} getDevice device invalid `);
      return null;
    }
    return device;
  }

  getProfileData(): void {
    LogUtil.info(`${this.tag} getProfileData`);
    this.device = this.getDevice(this.menu.navRouterParam as PushParam) as BluetoothDevice;
    if (!this.device) {
      LogUtil.error(`${this.tag} get device is null`);
    }
    let bluetoothProfile: BluetoothProfile =
      this.device.getConnectableProfiles()?.get(this.getProfileId()) as BluetoothProfile;
    this.connectProfile = bluetoothProfile?.connectionStrategyProfile;
  }

  updateStatus(): void {
    LogUtil.info(`${this.tag} updateStatus`);
    super.updateStatus();
    this.getProfileData();
    let state: number = bluetooth.getState();
    if (!this.device) {
      return;
    }
    let connectionState: ProfileConnectionState | undefined;
    try {
      connectionState = this.getConnectionProfile()?.getConnectionState(this.device!.deviceId as string);
    } catch (err) {
      LogUtil.error(`${this.tag} getConnectionState fail, err.code: ${err?.code}, err.message: ${err?.message}`);
    }

    if (BluetoothUtils.isBluetoothStateOff(state) || connectionState === ProfileConnectionState.STATE_DISCONNECTED) {
      this.isChecked = false;
      this.setSummary();
    } else if (BluetoothUtils.isBluetoothDiscoveryOn(state) &&
      connectionState === ProfileConnectionState.STATE_CONNECTED) {
      this.isChecked = this.device?.connectionStatusMap.get(this.getProfileId()) !==
      ConnectionStrategy.CONNECTION_STRATEGY_FORBIDDEN;
      if (this.isChecked) {
        this.setSelectorColor($r('app.color.profile_switch_color'));
      }
      this.setSummary();
    } else {
      if (connectionState !== ProfileConnectionState.STATE_DISCONNECTING) {
        this.setSummary($r('app.string.bt_connection_strategy_summary'));
      }
    }
    this.refreshUi();
  }

  protected registerDataChange(): void {
    BluetoothAdapter.getInstance().registerStateChangeListener(this);
    BluetoothAdapter.getInstance().registerProfileStateChangeListener(this);
  }

  protected unRegisterDataChange(): void {
    BluetoothAdapter.getInstance().unRegisterStateChangeListener(this);
    BluetoothAdapter.getInstance().unRegisterProfileStateChangeListener(this);
  }

  /**
   * 返回开关的实时状态
   */
  protected updateToggleStatus(state: number, profileState?: ProfileConnectionState, isInit: boolean = false): void {
    if (this.device) {
      let connectionState: ProfileConnectionState | undefined = profileState ??
      this.getConnectionProfile()?.getConnectionState(this.device.deviceId as string);
      LogUtil.info(`${this.tag} updateCheckedState start, blueState: ${state} , connectionState : ${connectionState}`);
      try {
        if (BluetoothUtils.isBluetoothStateOff(state) || connectionState ===
        ProfileConnectionState.STATE_DISCONNECTED) {
          LogUtil.info(`updateToggleStatus false, ProfileId ${this.getConnectProfileId()}, isOn: ${BluetoothUtils.isBluetoothStateOn(state)}`);
          this.isChecked = false;
          this.setSummary();
          if (!this.refreshFromOther) {
            this.refreshOtherSwitchStatus(true);
          }
          this.refreshFromOther = false;
          this.setToggleMenuStatus(true);
        } else if (BluetoothUtils.isBluetoothDiscoveryOn(state) &&
          connectionState === ProfileConnectionState.STATE_CONNECTED) {
          let timeOut: number = 0;
          if (!isInit) {
            timeOut = FRESH_PROFILE_TIME_OUT;
          }
          setTimeout(() => {
            (this.connectProfile as ConnectionProfile).getConnectionStrategy((this.device as BluetoothDevice).deviceId)
              .then((isCheck) => {
                LogUtil.info(`updateToggleStatus connectionStatusMap status : ${isCheck}`);
                if (!this.isChecked && isCheck === ConnectionStrategy.CONNECTION_STRATEGY_ALLOWED) {
                  if (!this.refreshFromOther) {
                    this.refreshALLSwitchStatus();
                  }
                }
                this.isChecked = isCheck === ConnectionStrategy.CONNECTION_STRATEGY_ALLOWED;
                if (this.isChecked) {
                  this.setSelectorColor($r('app.color.profile_switch_color'));
                }
                this.setSummary();
                if (!this.refreshFromOther) {
                  this.refreshOtherSwitchStatus(true);
                }
                this.refreshFromOther = false;
                this.setToggleMenuStatus(true);
              })
          }, timeOut)
        } else {
          if (connectionState !== ProfileConnectionState.STATE_DISCONNECTING) {
            this.setSummary($r('app.string.bt_connection_strategy_summary'));
          }
        }
        LogUtil.info(`refreshUi isChecked: ${this.isChecked} `);
        this.refreshUi();
      } catch (err) {
        LogUtil.info(`updateCheckedState error code: ${err?.code} message: ${err?.message}`)
      }
    }
  }

  setSelectorColor(resource: Resource): void {
    let style: SwitchMenuStyle = this.menu.style as SwitchMenuStyle;
    let toggleStyle: BluetoothSwitchToggleStyle = style.toggleStyle as BluetoothSwitchToggleStyle;
    toggleStyle.selectedColor = resource;
  }

  setToggleMenuStatus(status: boolean): void {
    if (!status) {
      this.setFontColor($r('app.color.color_E3E3E3_grey'));
      if (this.isChecked) {
        this.setSelectorColor($r('app.color.default_switch_color'));
      }
      this.refreshFontStyle();
      this.setToggleState(false, this.isRequestFocus);
      this.resetRequestFocus();
      return;
    } else {
      this.setFontColor();
      this.refreshFontStyle();
      this.setSelectorColor($r('app.color.profile_switch_color'));
      this.setToggleState(true, this.isRequestFocus);
      this.resetRequestFocus();
      return;
    }
  }

  setSummary(summaryMsg ?: Resource): void {
    LogUtil.info(`${this.tag} setSummary enter`);
    let style: SwitchMenuStyle = this.menu.style as SwitchMenuStyle;
    if (summaryMsg) {
      if (this.lastSummaryStatus === SummaryStatus.OPERATING) {
        return;
      }
      this.menu.summary = summaryMsg;
      ((style.rootContainer as ContainerStyle).size as SizeOptions).height = HEIGHT_64;
      this.setFontColor($r('app.color.color_E3E3E3_grey'));
      LogUtil.info(`${this.tag} setSummary is openning`);
      this.lastSummaryStatus = SummaryStatus.OPERATING;
      this.refreshFontStyle();
      this.setToggleState(false, this.isRequestFocus);
      this.resetRequestFocus();
    } else {
      let timeOut: number = 0;
      if (this.lastSummaryStatus === SummaryStatus.OPERATING) {
        timeOut = FRESH_TITLE_TIME_OUT;
      }
      if (timeOut === 0) {
        this.freshCompletedStatus(style);
      } else {
        setTimeout(() => {
          this.freshCompletedStatus(style);
        }, timeOut);
      }
      LogUtil.info(`${this.tag} setSummary is done`);
    }
  }

  private freshCompletedStatus(style: SwitchMenuStyle): void {
    this.menu.summary = this.isChecked ? $r('app.string.bt_connected_summary') : undefined;
    this.setFontColor();
    if (this.isChecked) {
      ((style.rootContainer as ContainerStyle).size as SizeOptions).height = HEIGHT_64;
    } else {
      ((style.rootContainer as ContainerStyle).size as SizeOptions).height = HEIGHT_48;
    }
    this.refreshFontStyle();
    this.lastSummaryStatus = SummaryStatus.DONE;
    this.setToggleState(true, this.isRequestFocus);
    this.resetRequestFocus();
  }

  resetRequestFocus(): void {
    this.isRequestFocus = true;
  }

  setFontColor(fontColor?: Resource): void {
    LogUtil.info(`${this.tag} setFontColor enter`);
    let style: SwitchMenuStyle = this.menu.style as SwitchMenuStyle;
    if (fontColor) {
      (style.title as TextStyle).fontColor = fontColor;
      (style.summary as TextStyle).fontColor = fontColor;
    } else {
      (style.title as TextStyle).fontColor = $r('sys.color.ohos_id_color_text_primary');
      (style.summary as TextStyle).fontColor = $r('sys.color.ohos_id_color_text_secondary');
    }
  }

  reportStrategySwitchChangeEvent(isOn: boolean): void {
    switch (this.getProfileId()) {
      case ProfileId.PROFILE_A2DP_SOURCE:
        HiSysEventUtil.reportDefaultBehaviorEvent(HiSysBluetoothEventGroup.A2DP_SWITCH_CHANGE, isOn ? 'on' : 'off');
        break;
      case ProfileId.PROFILE_HANDS_FREE_AUDIO_GATEWAY:
        HiSysEventUtil.reportDefaultBehaviorEvent(HiSysBluetoothEventGroup.HFP_SWITCH_CHANGE, isOn ? 'on' : 'off');
        break;
      default:
        break;
    }
  }

  onToggleChange(isOn: boolean): boolean {
    LogUtil.info(`${this.tag} onToggleChange ${isOn}`);
    if (isOn === this.isChecked) {
      return false;
    }
    if (!this.device) {
      return false;
    }
    this.reportStrategySwitchChangeEvent(isOn);
    let booleanValue = Boolean(isOn).valueOf();
    if (booleanValue === false) {
      if (BluetoothUtils.isBluetoothStateOff(bluetooth.getState()) ||
        this.getConnectionProfile()?.getConnectionState(this.device!.deviceId as string) ===
        ProfileConnectionState.STATE_DISCONNECTED) {
        LogUtil.info(`${this.tag} handleCheckedChange setCheck false , bluetooth is off or profile is not connected`);
        return false;
      }
    }
    if (isOn) {
      this.setSummary($r('app.string.bt_connection_strategy_summary'));
    } else {
      this.setToggleMenuStatus(false);
    }
    this.refreshOtherSwitchStatus(false);
    this.handleCheckedChange(booleanValue);
    return true;
  }

  /**
   * 刷新其他toggle的可使用状态
   */
  refreshOtherSwitchStatus(status: boolean): void {
    this.publishDataChange(new ProfileSwitchEventParam(this.getProfileId(), status));
  }

  /**
   * 返回开关的保存状态
   */
  getChecked(): boolean {
    LogUtil.info(`${this.tag} getChecked ${this.isChecked}`);
    return this.isChecked;
  }

  /**
   * 设置开关的状态
   */
  setChecked(isChecked: boolean): void {
    LogUtil.info(`${this.tag} setChecked ${isChecked}`);
    if (this.isChecked !== isChecked) {
      this.isChecked = isChecked;
      LogUtil.info(`${this.tag} setChecked, refresh : ${this.isChecked}`);
      this.refreshUi();
    }
  }

  /**
   * 再设置完某一协议值后需要刷新其他开关的状态值，看是否需要联动打开
   */
  refreshALLSwitchStatus(): void {
    this.publishDataChange(new ProfileSwitchEventParam(this.getProfileId(), undefined));
  }

  onDataChange(fromKey: string, data: object): void {
    let passData: ProfileSwitchEventParam = data as ProfileSwitchEventParam;
    if (this.device) {

      LogUtil.info(`${this.tag} onDataChange , profileId: ${passData.profileId}, status: ${this.getConnectionProfile()?.getConnectionState(this.device?.deviceId as string)}`);
      this.isRequestFocus = false;
      this.refreshFromOther = fromKey !== this.menu.key;
      if (passData.status !== undefined) {
        if (fromKey === this.menu.key) {
          this.isRequestFocus = true;
        }
        this.setToggleMenuStatus(passData.status as boolean);
      } else {
        if (this.isChecked) {
          return;
        }
        if (this.device && passData.profileId !== this.getProfileId()) {
          this.setSummary($r('app.string.bt_connection_strategy_summary'));
          this.updateToggleStatus(bluetooth.getState(),
            this.getConnectionProfile()?.getConnectionState(this.device!.deviceId as string));
        }
      }
    }
  }

  /**
   * 开关变化的回调
   */
  protected handleCheckedChange(isChecked: boolean): boolean {
    LogUtil.info(`${this.tag} handleCheckedChange ${isChecked}`);
    if (this.device && this.connectProfile) {
      try {
        this.connectProfile.setConnectionStrategy(this.device.deviceId, isChecked ?
          ConnectionStrategy.CONNECTION_STRATEGY_ALLOWED : ConnectionStrategy.CONNECTION_STRATEGY_FORBIDDEN)
          .then(() => {
            (this.connectProfile as ConnectionProfile).getConnectionStrategy((this.device as BluetoothDevice).deviceId)
              .then((isCheck) => {
                if (this.device) {
                  this.device.addConnectionStatus(this.getProfileId(), isCheck ?
                    ConnectionStrategy.CONNECTION_STRATEGY_ALLOWED :
                    ConnectionStrategy.CONNECTION_STRATEGY_FORBIDDEN);
                  this.updateToggleStatus(bluetooth.getState(),
                    this.getConnectionProfile()?.getConnectionState(this.device!.deviceId as string));
                }
              })
          })
        return true;
      } catch (err) {
        LogUtil.error(`${this.tag}handleCheckedChange code: ${err?.code} message: ${err?.message}`);
        return false;
      }
    }
    return false;
  }
}

export class A2dpStrategySwitchMenuController extends BluetoothStrategySwitchMenuController {
  public tag: string = 'A2dpStrategySwitchMenuController';

  static createA2dpStrategySwitchMenuController(menu: SettingsBaseMenu): Controller {
    return new A2dpStrategySwitchMenuController(menu);
  }

  aboutToAppear(): void {
    LogUtil.info(`${this.tag} aboutToAppear`);
    super.aboutToAppear();
  }

  aboutToDisappear(): void {
    LogUtil.info(`${this.tag} aboutToDisappear`);
    super.aboutToDisappear();
  }

  protected getProfileId(): ProfileId {
    return ProfileId.PROFILE_A2DP_SOURCE;
  }

  protected getConnectProfileId(): constant.ProfileId {
    return constant.ProfileId.PROFILE_A2DP_SOURCE;
  }

  protected registerDataChange(): void {
    this.registerControllerDataChange(HID_DEVICE_KEY);
    this.registerControllerDataChange(HFP_DEVICE_KEY);
    super.registerDataChange();
  }

  protected unRegisterDataChange(): void {
    this.unRegisterControllerDataChange(HID_DEVICE_KEY);
    this.unRegisterControllerDataChange(HFP_DEVICE_KEY);
    super.unRegisterDataChange();
  }
}

export class HfpStrategySwitchMenuController extends BluetoothStrategySwitchMenuController {
  static CreateHfpStrategySwitchMenuController(menu: SettingsBaseMenu): Controller {
    return new HfpStrategySwitchMenuController(menu);
  }

  public tag: string = 'HfpStrategySwitchMenuController';

  aboutToAppear(): void {
    LogUtil.info(`${this.tag} aboutToAppear`);
    super.aboutToAppear();
  }

  aboutToDisappear(): void {
    LogUtil.info(`${this.tag} aboutToDisappear`);
    super.aboutToDisappear();
  }

  protected getProfileId(): ProfileId {
    return ProfileId.PROFILE_HANDS_FREE_AUDIO_GATEWAY;
  }

  protected registerDataChange(): void {
    this.registerControllerDataChange(A2DP_DEVICE_KEY);
    this.registerControllerDataChange(HID_DEVICE_KEY);
    super.registerDataChange();
  }

  protected getConnectProfileId(): constant.ProfileId {
    return constant.ProfileId.PROFILE_HANDSFREE_AUDIO_GATEWAY;
  }

  protected unRegisterDataChange(): void {
    this.unRegisterControllerDataChange(A2DP_DEVICE_KEY);
    this.registerControllerDataChange(HID_DEVICE_KEY);
    super.unRegisterDataChange();
  }
}

export class HidStrategySwitchMenuController extends BluetoothStrategySwitchMenuController {
  public tag: string = 'HidStrategySwitchMenuController';

  static CreateHidStrategySwitchMenuController(menu: SettingsBaseMenu): Controller {
    return new HidStrategySwitchMenuController(menu);
  }

  aboutToAppear(): void {
    LogUtil.info(`${this.tag} aboutToAppear`);
    super.aboutToAppear();
  }

  aboutToDisappear(): void {
    LogUtil.info(`${this.tag} aboutToDisappear`);
    super.aboutToDisappear();
  }

  protected getProfileId(): ProfileId {
    return ProfileId.PROFILE_HID_HOST;
  }

  protected registerDataChange(): void {
    this.registerControllerDataChange(A2DP_DEVICE_KEY);
    this.registerControllerDataChange(HFP_DEVICE_KEY);
    super.registerDataChange();
  }

  protected getConnectProfileId(): constant.ProfileId {
    return constant.ProfileId.PROFILE_HID_HOST;
  }

  protected unRegisterDataChange(): void {
    this.unRegisterControllerDataChange(A2DP_DEVICE_KEY);
    this.unRegisterControllerDataChange(HFP_DEVICE_KEY);
    super.unRegisterDataChange();
  }
}

export class BluetoothDeviceVolumeSyncPhoneSwitchMenuController extends SwitchMenuController {
  public TAG: string = 'BluetoothDeviceVolumeSyncPhoneSwitchMenuController';
  public deviceId: string;
  public absoluteVolumeEnabled: boolean = false;

  static createBluetoothDeviceVolumeSyncPhoneSwitchMenuController(menu: SettingsBaseMenu): Controller {
    return new BluetoothDeviceVolumeSyncPhoneSwitchMenuController(menu);
  }

  constructor(menu: SettingsBaseMenu) {
    super(menu);
    this.deviceId = (this.menu?.extra as VolumeSyncParam)?.deviceId;
    this.absoluteVolumeEnabled = (this.menu?.extra as VolumeSyncParam)?.isOn;
    LogUtil.info(`${this.TAG} ${BluetoothUtils.getLogMAC(this.deviceId)} , absoluteVolumeEnabled =  ${this.absoluteVolumeEnabled}`);
    this.setChecked(this.absoluteVolumeEnabled);
  }

  aboutToAppear(): void {
    LogUtil.info(`${this.tag} aboutToAppear ${this.getLogKey()}`);
    this.updateCheckedState();
  }

  /**
   * 开关变化的回调
   */
  protected handleCheckedChange(isChecked: boolean): boolean {
    LogUtil.info(`${this.TAG} handleCheckedChange ${isChecked}`);
    if (isChecked) {
      this.enableAbsoluteVolume();
    } else {
      this.disableAbsoluteVolume();
    }
    return true;
  }

  /**
   * 开启蓝牙设备音量与手机同步开关
   */
  private async enableAbsoluteVolume(): Promise<void> {
    if (this.deviceId) {
      try {
        await a2dp.createA2dpSrcProfile()?.enableAbsoluteVolume(this.deviceId).then(() => {
          LogUtil.info(`${this.TAG} enableAbsoluteVolume success`);
          HiSysEventUtil.reportDefaultBehaviorEventByUE(HiSysAboutBluetoothEventGroup.BLUETOOTH_SYNC_VOLUME_SWITCH,
            'on');
          this.updateStatus();
        });
      } catch (err) {
        LogUtil.error(`${this.TAG}  : errCode: ${err?.code} , errMessage: ${err?.message}`);
        this.setChecked(false);
      }
    }
  }

  /**
   * 关闭蓝牙设备音量与手机同步开关
   */
  private async disableAbsoluteVolume(): Promise<void> {
    if (this.deviceId) {
      try {
        await a2dp.createA2dpSrcProfile()?.disableAbsoluteVolume(this?.deviceId).then(() => {
          LogUtil.info(`${this.TAG} disableAbsoluteVolume success`);
          HiSysEventUtil.reportDefaultBehaviorEventByUE(HiSysAboutBluetoothEventGroup.BLUETOOTH_SYNC_VOLUME_SWITCH,
            'off');
          this.updateStatus();
        });
      } catch (err) {
        LogUtil.error(`${this.TAG}  : errCode: ${err?.code} , errMessage: ${err?.message}`);
        this.setChecked(true);
      }
    }
  }

  aboutToDisappear(): void {
    LogUtil.info(`${this.TAG} aboutToDisappear`);
    super.aboutToDisappear();
  }
}

class ProfileSwitchEventParam {
  public profileId: number;
  public status?: boolean;

  constructor(profileId: number, status?: boolean) {
    this.profileId = profileId;
    this.status = status;
  }
}
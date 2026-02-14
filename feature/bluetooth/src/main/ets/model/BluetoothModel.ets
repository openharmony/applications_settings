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

import { BusinessError } from '@ohos.base';
import bluetooth from '@ohos.bluetooth';
import a2dp from '@ohos.bluetooth.a2dp';
import lazy { default as connection } from '@ohos.bluetooth.connection';
import constant from '@ohos.bluetooth.constant';
import dataShare from '@ohos.data.dataShare';
import dataSharePredicates from '@ohos.data.dataSharePredicates';
import DataShareResultSet from '@ohos.data.DataShareResultSet';
import { DeviceUtil, MenuUUID } from '@ohos/settings.common/src/main/ets/utils/BaseUtils';
import { BluetoothUtils, DisconnectCause, UnbondCause } from '@ohos/settings.common/src/main/ets/utils/BluetoothUtils';
import { CheckEmptyUtils } from '@ohos/settings.common/src/main/ets/utils/CheckEmptyUtils';
import { LogMaskUtil, LogUtil } from '@ohos/settings.common/src/main/ets/utils/LogUtil';
import { ResourceUtil } from '@ohos/settings.common/src/main/ets/utils/ResourceUtil';
import { StringUtil } from '@ohos/settings.common/src/main/ets/utils/StringUtil';
// import { BluetoothAdapter, BluetoothProfile, ConnectionStrategy, HearingAidProfile } from '../BluetoothAdapter';
import { BluetoothAdapter, BluetoothProfile, ConnectionStrategy } from '../BluetoothAdapter';
import {
  AccessAuthorization,
  HEARING_AID_UUID,
  HEX_RADIX,
  INVALID_RESOURCE_CODE,
  ShareType
} from '../constants/BluetoothConstants';
import { Utils } from '../utils/Utils';

/* instrument ignore file */
const TAG: string = 'BluetoothModel : ';
const IS_DEBUG: boolean = true;

const BT_ICONS: ResourceStr[] = [
  $r('sys.symbol.bluetooth'),
  $r('sys.symbol.earphone_bluetooth_fill'),
  $r('sys.symbol.phone_fill_1'),
  $r('sys.symbol.matebook_fill'),
  $r('sys.symbol.keyboard_fill'),
  $r('sys.symbol.mouse_fill'),
  $r('sys.symbol.watch_fill'),
  $r('sys.symbol.pencil_waveform_fill'),
  $r('sys.symbol.pad_fill'),
  $r('sys.symbol.soundx_fill'),
  $r('sys.symbol.audiphonen'),
  $r('sys.symbol.printer_fill')
];

const BT_READ_DETAIL: ResourceStr[] = [
  $r('app.string.bluetooth'),
  $r('app.string.device_type_headset'),
  $r('app.string.phone'),
  $r('app.string.matebook'),
  $r('app.string.keyboard'),
  $r('app.string.mouse'),
  $r('app.string.device_type_watch'),
  $r('app.string.pencil'),
  $r('app.string.pad'),
  $r('app.string.soundx'),
  $r('app.string.device_type_hearing'),
  $r('app.string.device_type_printer')
];

/**
 * 蓝牙搜索中提示消息类
 *
 * @since 2022-05-20
 */
export class SearchMessageChangeData {
  public isShowSearchMessage: boolean;

  constructor(isShowSearchMessage: boolean) {
    this.isShowSearchMessage = isShowSearchMessage;
  }
}

export enum BondState {
  /** Indicate the bond state is invalid */
  BOND_STATE_INVALID = 0,
  /** Indicate the bond state is bonding */
  BOND_STATE_BONDING = 1,
  /** Indicate the bond state is bonded*/
  BOND_STATE_BONDED = 2,
}

export interface BondStateParam {
  deviceId: string;
  state: BondState;
  cause: UnbondCause;
}

export class TaskOutPut {
  public deviceName: string = '';
  public deviceType: number = 0;
}

export interface PinRequiredParam {
  deviceId: string;
  pinCode: string;
  pinType: number;
}

export interface StateChangeParam {
  /** The address of device */
  deviceId: string;

  /** Profile state value */
  state: ProfileConnectionState;
  cause: DisconnectCause;
}

export class VolumeSyncParam {
  public deviceId: string = '';
  public isOn: boolean = false;
}

export enum ProfileConnectionState {
  /** the current profile is disconnected */
  STATE_DISCONNECTED = 0,
  /** the current profile is being connected */
  STATE_CONNECTING = 1,
  /** the current profile is connected */
  STATE_CONNECTED = 2,
  /** the current profile is being disconnected */
  STATE_DISCONNECTING = 3,
}

export enum ProfileId {
  PROFILE_A2DP_SOURCE = 1,
  PROFILE_HANDS_FREE_AUDIO_GATEWAY = 4,
  PROFILE_HID_HOST = 6,
  PROFILE_HEARING_AID = 21
}

export enum DeviceType {
  BLUETOOTH = 0,
  HEADPHONE = 1,
  PHONE = 2,
  COMPUTER = 3,
  KEYBOARD = 4,
  MOUSE = 5,
  WATCH = 6,
  PEN = 7,
  TABLET = 8,
  SPEAKER = 9,
  HEARING_AID = 10,
  PRINTER = 11
}

// export enum PinType {
//   PAIRING_VARIANT_PIN = 0,
//   PAIRING_VARIANT_PASSKEY = 1,
//   PAIRING_VARIANT_PASSKEY_CONFIRMATION = 2,
//   PAIRING_VARIANT_CONSENT = 3,
//   PAIRING_VARIANT_DISPLAY_PASSKEY = 4,
//   PAIRING_VARIANT_DISPLAY_PIN = 5,
//   PAIRING_VARIANT_OOB_CONSENT = 6,
//   PAIRING_VARIANT_PIN_16_DIGITS = 7,
// }
export enum PinType {
  PAIRING_VARIANT_DISPLAY_PIN = 0,
  PAIRING_VARIANT_PIN = 1,
  PAIRING_VARIANT_DISPLAY_PASSKEY = 2,
  PAIRING_VARIANT_PASSKEY = 3,
  PAIRING_VARIANT_PASSKEY_CONFIRMATION = 4,
  PAIRING_VARIANT_CONSENT = 5,
  PAIRING_VARIANT_OOB_CONSENT = 6,
  PAIRING_VARIANT_PIN_16_DIGITS = 7
}

/**
 * 蓝牙设备类
 *
 * @since 2022-05-20
 */
export class BluetoothDevice {
  public tag: string = 'BluetoothDevice';
  public deviceId: string;
  public deviceNum: string;
  public deviceName: string = '';
  public deviceType: DeviceType = 0;
  public profileMap: Map<ProfileId, BluetoothProfile> = new Map();
  public connectionStatusMap: Map<ProfileId, ConnectionStrategy> = new Map();
  public isPressedDisconnect: boolean = false;
  public isEnAble: boolean = true;
  private isDiscover: boolean = false;
  public remoteUuids: constant.ProfileUuids[] = [];
  private summaryStr: ResourceStr = '';
  public absoluteVolumeSupport: boolean = false;
  public volumeSyncParam: VolumeSyncParam = new VolumeSyncParam();
  private symbolEarphoneIcon: string = '';
  public defaultDeviceType: number = -1;
  public shareType: number = ShareType.SHARE_NAME_AND_PHONE_NUMBER;
  // 设备codec类型
  public codecType: a2dp.CodecType = a2dp.CodecType.CODEC_TYPE_INVALID;
  // 信号强度
  private rssi: number = 0;
  // 附属设备
  private subDevice?: BluetoothDevice;
  // 助听器识别id
  private hearingAidId?: number;

  constructor(deviceId: string, rssi?: number) {
    this.deviceId = deviceId;
    this.deviceNum = MenuUUID.uuid();
    this.rssi = rssi ?? 0;
    LogUtil.info(`${this.tag} setDeviceNum, deviceId: ${BluetoothUtils.getLogMAC(deviceId)}, rssi:${this.rssi}`);
  }

  setRssi(rssi: number): void {
    this.rssi = rssi;
  }

  getRssi(): number {
    return this.rssi;
  }

  setRemoteUuids(remoteUuids: Array<constant.ProfileUuids>): void {
    LogUtil.info(`${this.tag} setRemoteUuids , deviceId: ${BluetoothUtils.getLogMAC(this.deviceId)}`);
    this.remoteUuids = remoteUuids;
  }

  getRemoteUuids(): Array<constant.ProfileUuids> {
    LogUtil.info(`${this.tag} getRemoteUuids , deviceId: ${BluetoothUtils.getLogMAC(this.deviceId)}`);
    return this.remoteUuids;
  }

  setEnable(isEnAble: boolean): void {
    LogUtil.info(`${this.tag} setEnable: ${isEnAble} , deviceId: ${BluetoothUtils.getLogMAC(this.deviceId)}`);
    this.isEnAble = isEnAble;
  }

  getEnable(): boolean {
    LogUtil.info(`${this.tag} getEnable: ${this.isEnAble} , deviceId: ${BluetoothUtils.getLogMAC(this.deviceId)}`);
    return this.isEnAble;
  }

  async updateProfilesAndConnectionStatus(): Promise<void> {
    LogUtil.info(`${this.tag} updateProfilesAndConnectionStatus deviceId : ${BluetoothUtils.getLogMAC(this.deviceId)}`);
    try {
      let remoteUuids: constant.ProfileUuids[] = await connection.getRemoteProfileUuids(this.deviceId);
      this.updateStatus(remoteUuids);
      LogUtil.info(`${this.tag} after setProfileMap, profileMap keys length: ${Array.from(this.profileMap.keys())}`);
    } catch (err) {
      LogUtil.info(`${this.tag} getRemoteProfileUuids fail: ${err?.code}, ${err?.message}`);
    }
    this.updateConnectionStatus();
  }

  async updateProfilesAndConnectionStatusForRemoteUUID(): Promise<void> {
    LogUtil.info(`${this.tag} updateProfilesAndConnectionStatusForRemoteUUID deviceId : ${BluetoothUtils.getLogMAC(this.deviceId)}`);
    if (this.remoteUuids.length === 0) {
      return;
    }
    this.updateStatus(this.remoteUuids);
    LogUtil.info(`${this.tag} after setProfileMap, profileMap keys length: ${Array.from(this.profileMap.keys())}`);
    this.updateConnectionStatus();
  }

  private updateStatus(remoteUuids: constant.ProfileUuids[]) {
    let remoteUuidStrs: string[] = this.createUuidStrs(remoteUuids);
    let localUuids: constant.ProfileUuids[] = BluetoothAdapter.getInstance().localProfileUuids;
    let localUuidsStrs: string[] = this.createUuidStrs(localUuids);
    LogUtil.info(`${this.tag} updateStatus remoteUuidStrs: ${BluetoothUtils.getLogUuid(remoteUuidStrs)},localUuidsStrs: ${BluetoothUtils.getLogUuid(localUuidsStrs)}, deviceId:${BluetoothUtils.getLogMAC(this.deviceId)}`);
    let profileMap: Map<ProfileId, BluetoothProfile> = BluetoothAdapter.getInstance().profileManager?.profiles;
    let keys: IterableIterator<ProfileId> = profileMap?.keys();
    let keysarray = Array.from(keys);
    for (let profileId of keysarray) {
      if (profileId === ProfileId.PROFILE_A2DP_SOURCE) {
        this.setAd2pProfile(ProfileId.PROFILE_A2DP_SOURCE, remoteUuidStrs, profileMap);
      } else if (profileId === ProfileId.PROFILE_HID_HOST) {
        this.setHidProfile(ProfileId.PROFILE_HID_HOST, remoteUuidStrs, profileMap);
      } else if (profileId === ProfileId.PROFILE_HANDS_FREE_AUDIO_GATEWAY) {
        this.setHfpProfile(ProfileId.PROFILE_HANDS_FREE_AUDIO_GATEWAY, remoteUuidStrs, localUuidsStrs, profileMap);
      } else if (profileId === ProfileId.PROFILE_HEARING_AID) {
        this.setHearingAidProfile(ProfileId.PROFILE_HEARING_AID, remoteUuidStrs, profileMap)
      }
    }
  }

  createUuidStrs(remoteUuids: Array<constant.ProfileUuids>): Array<string> {
    let result: string[] = [];
    remoteUuids.forEach((uuid) => {
      result.push(uuid.toLowerCase());
    });
    return result;
  }

  setHfpProfile(profileId: ProfileId, remoteUuids: Array<string>, localUuids: Array<string>,
    profileMap: Map<ProfileId, BluetoothProfile>): void {
    let profile: BluetoothProfile = profileMap.get(profileId) as BluetoothProfile;
    if (!profile) {
      return;
    }
    let hfpStr: string = constant.ProfileUuids.PROFILE_UUID_HFP_AG;
    let hfStr: string = constant.ProfileUuids.PROFILE_UUID_HFP_HF;
    // if (profile.getConnectionState(this.deviceId) === ProfileConnectionState.STATE_CONNECTED ||
    //   (remoteUuids.indexOf(hfStr.toLowerCase()) !== -1 && localUuids.indexOf(hfpStr.toLowerCase()) !== -1)) {
    if (profile.getConnectionState(this.deviceId) === ProfileConnectionState.STATE_CONNECTED ||
      remoteUuids.indexOf(hfStr.toLowerCase()) !== -1) {
      this.addProfile(profileId, profileMap.get(profileId) as BluetoothProfile);
    }
  }

  setHidProfile(profileId: ProfileId, remoteUuids: Array<string>, profileMap: Map<ProfileId, BluetoothProfile>): void {
    let hidStr: string = constant.ProfileUuids.PROFILE_UUID_HID;
    let hogpStr: string = constant.ProfileUuids.PROFILE_UUID_HOGP;
    if (remoteUuids.indexOf(hidStr.toLowerCase()) !== -1 || remoteUuids.indexOf(hogpStr.toLowerCase()) !== -1) {
      this.addProfile(profileId, profileMap.get(profileId) as BluetoothProfile);
    }
  }

  setAd2pProfile(profileId: ProfileId, remoteUuids: Array<string>, profileMap: Map<ProfileId, BluetoothProfile>): void {
    let profile: BluetoothProfile = profileMap.get(profileId) as BluetoothProfile;
    if (!profile) {
      return;
    }
    let a2dpSinkStr: string = constant.ProfileUuids.PROFILE_UUID_A2DP_SINK;
    if (profile.getConnectionState(this.deviceId) ===
    ProfileConnectionState.STATE_CONNECTED || remoteUuids.indexOf(a2dpSinkStr.toLowerCase()) !== -1) {
      this.addProfile(profileId, profileMap.get(profileId) as BluetoothProfile);
    }
  }

  setHearingAidProfile(profileId: ProfileId, remoteUuids: Array<string>,
    profileMap: Map<ProfileId, BluetoothProfile>): void {
    let profile: BluetoothProfile = profileMap.get(profileId) as BluetoothProfile;
    if (!profile) {
      return;
    }
    let hearingAidStr: string = HEARING_AID_UUID;
    if (profile.getConnectionState(this.deviceId) ===
    ProfileConnectionState.STATE_CONNECTED || remoteUuids.indexOf(hearingAidStr.toLowerCase()) !== -1) {
      this.addProfile(profileId, profileMap.get(profileId) as BluetoothProfile);
    }
  }

  async updateConnectionStatus(): Promise<void> {
    let keys: IterableIterator<ProfileId> = this.profileMap?.keys();
    let keysArray = Array.from(keys);
    for (let profileId of keysArray) {
      let status: number =
        await (this.profileMap.get(profileId) as BluetoothProfile).getConnectionStrategy(this.deviceId) as number;
      this.connectionStatusMap.set(profileId, status);
    }
  }

  addConnectionStatus(profileId: ProfileId, status: ConnectionStrategy): void {
    this.connectionStatusMap.set(profileId, status);
  }

  addProfile(profileId: ProfileId, profile: BluetoothProfile): void {
    if (!this.profileMap.has(profileId)) {
      this.profileMap.set(profileId, profile);
      LogUtil.info(`${this.tag} addProfile : ${profileId}`);
    }
  }

  getConnectableProfiles(): Map<ProfileId, BluetoothProfile> {
    LogUtil.info(`${this.tag} getConnectableProfiles`);
    return this.profileMap;
  }

  /**
   * 刷新蓝牙设备信息
   */
  update(deviceName?: string, rssi?: number): void {
    LogUtil.info(`${TAG} createDevice update. deviceName:${LogMaskUtil.getLogNickNameString(deviceName)}`);
    if (!deviceName) {
      this.deviceName = BluetoothDevice.getDeviceName(this.deviceId) ?? this.deviceId;
    } else {
      this.deviceName = deviceName;
    }
    if (rssi !== undefined) {
      this.rssi = rssi;
    }
    if (this.isHearingAidDevice()) {
      this.deviceType = DeviceType.HEARING_AID;
    } else {
      this.deviceType = BluetoothDevice.getDeviceSpecificType(this.deviceId) as DeviceType;
    }
  }

  updateDeviceTypeIfNeed(): void {
    if (this.deviceType !== DeviceType.BLUETOOTH && !this.profileMap.has(ProfileId.PROFILE_A2DP_SOURCE) &&
      !this.profileMap.has(ProfileId.PROFILE_HANDS_FREE_AUDIO_GATEWAY)) {
      LogUtil.info(`${TAG} the device do not support the specific profile, or the deviceType is ${this.deviceType}`);
      return;
    }
    let deviceClass = bluetooth.getRemoteDeviceClass(this.deviceId);
    LogUtil.info(`${TAG} the deviceClass is ${deviceClass?.majorClass}`);
    if (!deviceClass || !deviceClass.majorClass) {
      return;
    }

    if (deviceClass.majorClass === bluetooth.MajorClass.MAJOR_UNCATEGORIZED) {
      LogUtil.info(`${TAG} the major class of the device is uncategorized, and it supports the profile`);
      this.deviceType = DeviceType.HEADPHONE;
    }
  }

  /**
   * 根据指定Mac地址判断是否为音频管家支持的设备
   * @param context 上下文
   * @returns true:支持 false:不支持
   */
  public isAudioDevice(context: Context): Promise<boolean> {
    return new Promise<boolean>(async (resolve, reject) => {
      let uri = ('datashareproxy://com.ohos.audioaccessorymanager/deviceInfo');
      await dataShare.createDataShareHelper(context, uri, { isProxy: true }).then(helper => {
        let predicates = new dataSharePredicates.DataSharePredicates();
        predicates.equalTo('DEVICE_MAC', this.deviceId);
        helper.query(uri, predicates, ['*']).then((data: DataShareResultSet) => {
          LogUtil.info(`${this.tag} dshelper query success: ${data.rowCount}`);
          resolve(data.rowCount > 0);
          data.close();
        }).catch((err: BusinessError) => {
          LogUtil.error(`${this.tag} dshelper query fail: ${err?.code}, errMsg: ${err?.message}`);
          reject(err)
        })
      }).catch((err: BusinessError) => {
        LogUtil.error(`${this.tag} createDataShareHelper fail: ${err?.code}, errMsg: ${err?.message}`);
        reject(err)
      })
    })
  }

  async isAbsoluteVolumeSupportedAndEnabled(): Promise<void> {
    try {
      let supported = await a2dp.createA2dpSrcProfile().isAbsoluteVolumeSupported(this.deviceId);
      LogUtil.info(`${this.tag} : device support absolute volume ${supported}`);
      this.absoluteVolumeSupport = supported.valueOf() as boolean;
      if (this.absoluteVolumeSupport) {
        try {
          let enabled = await a2dp.createA2dpSrcProfile().isAbsoluteVolumeEnabled(this.deviceId);
          LogUtil.info(`${this.tag} : device absolute volume enable ${enabled}`);
          this.volumeSyncParam.deviceId = this.deviceId;
          this.volumeSyncParam.isOn = enabled.valueOf() as boolean;
        } catch (err) {
          LogUtil.error(`${this.tag}  : errCode: ${err?.code} , errMessage: ${err?.message}`);
        }
      }
    } catch (err) {
      LogUtil.error(`${this.tag}  : errCode: ${err?.code} , errMessage: ${err?.message}`);
    }
  }

  async getDefaultDeviceType(): Promise<void> {
    if (this.profileMap.has(ProfileId.PROFILE_A2DP_SOURCE) ||
    this.profileMap.has(ProfileId.PROFILE_HANDS_FREE_AUDIO_GATEWAY)) {
      Utils.getRemoteDeviceType(this.deviceId).then((deviceType: number) => {
        LogUtil.info(`${this.tag} getRemoteDeviceType ${deviceType}`);
        this.defaultDeviceType = deviceType;
      });
    }
  }

  async getShareType(): Promise<void> {
    if (DeviceUtil.isDevicePhone()) {
      let permission = await Utils.getPhoneBookAccessAuthorization(this.deviceId);
      await this.setShareType(permission);
    }
  }

  private async setShareType(permission: AccessAuthorization): Promise<void> {
    let prem = (permission === AccessAuthorization.ALLOWED) ?
    ShareType.SHARE_NAME_AND_PHONE_NUMBER : ShareType.SHARE_NOTHING;
    let shareType = await Utils.getShareType(this.deviceId);
    this.shareType = (shareType !== null ? shareType : prem);
  }

  /**
   * 更新蓝牙设备名称信息
   */
  updateDeviceName(name: String): void {
    this.deviceName = name as string;
  }

  setDiscover(isDiscover: boolean): void {
    this.isDiscover = isDiscover;
  }

  getDiscover(): boolean {
    return this.isDiscover;
  }

  /**
   * 创建蓝牙设备实例
   *
   * @param deviceId 蓝牙设备ID
   */
  static createDevice(deviceId: string, deviceName?: string, rssi?: number): BluetoothDevice | null {
    if (CheckEmptyUtils.checkStrIsEmpty(deviceId)) {
      LogUtil.error(`${TAG} createDevice empty param`);
      return null;
    }
    let device = new BluetoothDevice(deviceId, rssi);
    device.update(deviceName);
    device.updateProfilesAndConnectionStatus();
    LogUtil.info(`${TAG} createDevice ${BluetoothUtils.getLogMAC(device.deviceId)}, deviceType ${device.deviceType}`);
    return device;
  }

  /**
   * 获取蓝牙设备名称
   *
   * @param deviceId 蓝牙设备ID
   */
  static getDeviceName(deviceId: string): string | null {
    if (CheckEmptyUtils.checkStrIsEmpty(deviceId)) {
      LogUtil.error(`${TAG} getDeviceName empty param`);
      return null;
    }
    let name: string = bluetooth.getRemoteDeviceName(deviceId);
    LogUtil.info(`${TAG} getDeviceName from getRemoteDeviceName. deviceId:${BluetoothUtils.getLogMAC(deviceId)} name:${LogMaskUtil.getLogNickNameString(name)}`);
    if (!name) {
      let device: BluetoothDevice = BluetoothAdapter.getInstance().cachedManager.findDevice(deviceId);
      LogUtil.info(`${TAG} getDeviceName from cache. name:${LogMaskUtil.getLogNickNameString(device?.deviceName)}`);
      if (device && device.deviceName) {
        return device.deviceName;
      } else {
        return deviceId;
      }
    }
    return name;
  }

  /**
   * 获取蓝牙设备类型
   *
   * @param deviceId 蓝牙设备ID
   */
  static getDeviceSpecificType(deviceId: string): DeviceType {
    if (CheckEmptyUtils.checkStrIsEmpty(deviceId)) {
      LogUtil.error(`${TAG} getDeviceSpecificType empty param`);
      return DeviceType.BLUETOOTH;
    }
    let deviceClass = bluetooth.getRemoteDeviceClass(deviceId);
    if (!deviceClass || !deviceClass.majorClass) {
      return DeviceType.BLUETOOTH;
    }
    if (IS_DEBUG) {
      LogUtil.info(`${TAG} getDeviceSpecificType. deviceId:${BluetoothUtils.getLogMAC(deviceId)} majorClass:${deviceClass.majorClass} majorMinorClass:${deviceClass.majorMinorClass}`);
    }
    switch (deviceClass.majorClass) {
      case bluetooth.MajorClass.MAJOR_COMPUTER:
      case bluetooth.MajorClass.MAJOR_PERIPHERAL:
      case bluetooth.MajorClass.MAJOR_WEARABLE:
      case bluetooth.MajorClass.MAJOR_IMAGING:
        return BluetoothDevice.getHidClass(deviceClass);
      case bluetooth.MajorClass.MAJOR_AUDIO_VIDEO:
        return BluetoothDevice.getAudioMajorMinorClass(deviceClass);
      case bluetooth.MajorClass.MAJOR_PHONE:
        return DeviceType.PHONE;
      default:
        return DeviceType.BLUETOOTH;
    }
  }

  static getAudioMajorMinorClass(deviceClass: bluetooth.DeviceClass): DeviceType {
    if (!deviceClass) {
      return DeviceType.HEADPHONE;
    }

    switch (deviceClass.majorMinorClass) {
      case bluetooth.MajorMinorClass.AUDIO_VIDEO_LOUDSPEAKER:
        return DeviceType.SPEAKER;
      default:
        return DeviceType.HEADPHONE;
    }
  }

  static getHidClass(deviceClass: bluetooth.DeviceClass): number {
    if (!deviceClass) {
      return DeviceType.BLUETOOTH;
    }
    switch (deviceClass.majorMinorClass) {
      case bluetooth.MajorMinorClass.PERIPHERAL_KEYBOARD:
      case bluetooth.MajorMinorClass.PERIPHERAL_KEYBOARD_POINTING:
        return DeviceType.KEYBOARD;
      case bluetooth.MajorMinorClass.PERIPHERAL_POINTING_DEVICE:
        return DeviceType.MOUSE;
      case bluetooth.MajorMinorClass.PERIPHERAL_DIGITAL_PEN:
        return DeviceType.PEN;
      case bluetooth.MajorMinorClass.WEARABLE_WRIST_WATCH:
        return DeviceType.WATCH;
      case bluetooth.MajorMinorClass.COMPUTER_TABLET:
        return DeviceType.TABLET;
      case bluetooth.MajorMinorClass.COMPUTER_LAPTOP:
        return DeviceType.COMPUTER;
      case bluetooth.MajorMinorClass.IMAGING_PRINTER:
        return DeviceType.PRINTER;
      default:
        return DeviceType.BLUETOOTH;
    }
  }

  isConnected(): boolean {
    let isMainDeviceConnected = BluetoothAdapter.getInstance().isDeviceConnected(this.deviceId);
    if (this.getSubDevice()) {
      return isMainDeviceConnected ||
      BluetoothAdapter.getInstance().isDeviceConnected((this.getSubDevice() as BluetoothDevice).deviceId);
    } else {
      return isMainDeviceConnected;
    }
  }

  /**
   * 获取蓝牙设备列表项状态辅助文本
   *
   * @param deviceId 蓝牙设备ID
   */
  getSummary(isShow: boolean = false): ResourceStr {
    if (!this.deviceId) {
      LogUtil.error(`${TAG} getSummary empty param`);
      return '';
    }
    this.buildProfileSwitchState(isShow);
    return this.summaryStr;
  }

  /**
   * 判断蓝牙提示信息
   * @returns
   */
  async buildProfileSwitchState(isShow: boolean = false): Promise<ResourceStr> {
    let promiseA2dpState = new Promise<ProfileConnectionState>((resolve) => {
      let state = BluetoothAdapter.getInstance().getProfileState(ProfileId.PROFILE_A2DP_SOURCE, this.deviceId);
      resolve(state);
    });
    let promiseHfpState = new Promise<ProfileConnectionState>((resolve) => {
      let state = BluetoothAdapter.getInstance()
        .getProfileState(ProfileId.PROFILE_HANDS_FREE_AUDIO_GATEWAY, this.deviceId);
      resolve(state);
    });
    let promiseHidState = new Promise<ProfileConnectionState>((resolve) => {
      let state = BluetoothAdapter.getInstance().getProfileState(ProfileId.PROFILE_HID_HOST, this.deviceId);
      resolve(state);
    });
    let promiseHearingAidSate = new Promise<ProfileConnectionState>((resolve) => {
      let mainDeviceState: ProfileConnectionState =
        BluetoothAdapter.getInstance().getProfileState(ProfileId.PROFILE_HEARING_AID, this.deviceId);
      if (this.getSubDevice()) {
        let subDeviceState: ProfileConnectionState = BluetoothAdapter.getInstance()
          .getProfileState(ProfileId.PROFILE_HEARING_AID, (this.getSubDevice() as BluetoothDevice).deviceId);
        LogUtil.info(`${TAG} buildProfileSwitchState mainDeviceState :${mainDeviceState}, subDeviceState : ${subDeviceState}`);
        resolve(BluetoothDevice.mergeHearingAidState(mainDeviceState, subDeviceState));
      } else {
        resolve(mainDeviceState);
      }
    });
    return Promise.all<ProfileConnectionState>([promiseA2dpState, promiseHfpState, promiseHidState,
      promiseHearingAidSate]).then(values => {
      let a2dpState = values[0];
      let hfpState = values[1];
      let hidState = values[2];
      let hearingAidState = values[3];
      LogUtil.info(`${TAG} buildProfileSwitchState. isShow:${isShow} a2dpState:${a2dpState} hfpState:${hfpState} hidState:${hidState} hearingAidState:${hearingAidState}`);
      if ([a2dpState, hfpState, hidState, hearingAidState].includes(ProfileConnectionState.STATE_CONNECTING)) {
        this.summaryStr = ResourceUtil.getWindowsStringSync($r('app.string.bt_connecting_summary'));
      } else if (a2dpState === ProfileConnectionState.STATE_CONNECTED &&
        hfpState === ProfileConnectionState.STATE_CONNECTED) {
        this.summaryStr = ResourceUtil.getWindowsStringSync($r('app.string.bt_hfp_a2dp_connect_summary'));
      } else if (a2dpState === ProfileConnectionState.STATE_CONNECTED &&
        hfpState === ProfileConnectionState.STATE_DISCONNECTED) {
        this.summaryStr = ResourceUtil.getWindowsStringSync($r('app.string.bt_a2dp_connect_summary'));
      } else if (a2dpState === ProfileConnectionState.STATE_DISCONNECTED &&
        hfpState === ProfileConnectionState.STATE_CONNECTED) {
        this.summaryStr = ResourceUtil.getWindowsStringSync($r('app.string.bt_hfp_connect_summary'));
      } else if (hidState === ProfileConnectionState.STATE_CONNECTED ||
        hearingAidState === ProfileConnectionState.STATE_CONNECTED) {
        this.summaryStr = ResourceUtil.getWindowsStringSync($r('app.string.bt_connected_summary'));
      } else if ([a2dpState, hfpState, hidState,
        hearingAidState].includes(ProfileConnectionState.STATE_DISCONNECTING)) {
        this.summaryStr = ResourceUtil.getWindowsStringSync($r('app.string.bt_disconnecting_summary'));
      } else if (isShow && a2dpState === ProfileConnectionState.STATE_DISCONNECTED &&
        hfpState === ProfileConnectionState.STATE_DISCONNECTED &&
        hidState === ProfileConnectionState.STATE_DISCONNECTED &&
        hearingAidState === ProfileConnectionState.STATE_DISCONNECTED) {
        this.summaryStr = ResourceUtil.getWindowsStringSync($r('app.string.bt_connect_failed_title'));
      } else {
        this.summaryStr = '';
      }
      LogUtil.info(`${TAG} buildProfileSwitchState. summaryStr:${this.summaryStr}`);
      return this.summaryStr;
    });
  }

  static mergeHearingAidState(mainState: ProfileConnectionState,
    subState: ProfileConnectionState): ProfileConnectionState {
    if (mainState === ProfileConnectionState.STATE_CONNECTED || subState === ProfileConnectionState.STATE_CONNECTED) {
      return ProfileConnectionState.STATE_CONNECTED;
    }
    if (mainState === ProfileConnectionState.STATE_DISCONNECTING ||
      subState === ProfileConnectionState.STATE_DISCONNECTING) {
      return ProfileConnectionState.STATE_DISCONNECTING;
    }
    if (mainState === ProfileConnectionState.STATE_DISCONNECTED ||
      subState === ProfileConnectionState.STATE_DISCONNECTED) {
      return ProfileConnectionState.STATE_DISCONNECTED;
    }
    if (mainState === ProfileConnectionState.STATE_CONNECTING || subState === ProfileConnectionState.STATE_CONNECTING) {
      return ProfileConnectionState.STATE_CONNECTING;
    }
    return ProfileConnectionState.STATE_DISCONNECTED;
  }

  getIcon(): ResourceStr {
    if (this.deviceType >= 0 && this.deviceType < BT_ICONS.length) {
      if (this.isEarphoneId()) {
        return $r(`${this.symbolEarphoneIcon}`);
      }
      return BT_ICONS[this.deviceType];
    }
    return BT_ICONS[0];
  }

  updateEarphoneIcon(): void {
    if (this.deviceType < 0 || this.deviceType > DeviceType.HEADPHONE) {
      LogUtil.warn(`${TAG} updateEarphoneIcon device is not earphone`);
      return;
    }
    this.symbolEarphoneIcon = this.getEarphoneIcon();
  }

  getReadDetail(): ResourceStr {
    if (this.deviceType >= 0 && this.deviceType < BT_ICONS.length) {
      if (this.isEarphoneId()) {
        return BT_READ_DETAIL[0];
      }
      return BT_READ_DETAIL[this.deviceType];
    }
    return BT_READ_DETAIL[0];
  }

  public isEarphoneId(): boolean {
    if (this.deviceType > DeviceType.HEADPHONE) {
      // 蓝牙类型可能是耳机，类型非蓝牙0或耳机1，不获取iconID
      return false;
    }
    if (StringUtil.isEmpty(this.symbolEarphoneIcon)) {
      // 当前设备资源未缓存，进行查询获取
      this.symbolEarphoneIcon = this.getEarphoneIcon();
    }
    return this.symbolEarphoneIcon.startsWith('sys.symbol.earphone');
  }

  /**
   * 获取耳机线性图
   *
   * @returns 线形图
   */
  private getEarphoneIcon(): string {
    try {
      // 不存在id时会返回FFFFFF_FF_FFFF，异常会走catch分支
      const productId: string = connection.getRemoteProductId(this.deviceId);
      const result: string[] = productId.split('_');
      // 最后的iconID为16进制,转为10进制
      const iconId: number = parseInt(result[result.length - 1], HEX_RADIX);
      const symbolName: string = `earphone_${iconId}_fill`;
      // 检查图标标识是否在Symbol中，不存在会走catch分支
      ResourceUtil.getContext().resourceManager.getSymbolByName(symbolName);
      // 耳机的资源文件在Symbol中，且id范围合法，按资源名返回
      LogUtil.info(`${TAG} getEarphoneIcon ${BluetoothUtils.getLogMAC(this.deviceId)} icon: ${symbolName}`);
      return `sys.symbol.${symbolName}`;
    } catch (e) {
      if (e?.code !== INVALID_RESOURCE_CODE) {
        LogUtil.info(`${TAG} getEarphoneIcon ${BluetoothUtils.getLogMAC(this.deviceId)} err: ${e?.code} ${e?.message}`);
      }
      // 异常，不缓存资源名，返回空串
      return '';
    }
  }

  /**
   * 获取标题右侧L2HC图标
   * @returns
   */
  public getTitleIcon(): ResourceStr {
    return this.codecType === a2dp.CodecType.CODEC_TYPE_L2HC ? $r('app.media.ic_l2hc_icon') : '';
  }

  /**
   * 初始化codec类型
   * @param context
   * @returns
   */
  public async updateL2HCIcon(context: Context): Promise<void> {
    let helper: dataShare.DataShareHelper | undefined;
    let data: DataShareResultSet | undefined;
    let uri = ('datashareproxy://com.ohos.audioaccessorymanager/deviceInfo');
    try {
      LogUtil.info(`${TAG} updateL2HCIcon starts ${BluetoothUtils.getLogMAC(this.deviceId)}.`);
      helper = await dataShare.createDataShareHelper(context, uri, { isProxy: true });
      const predicates = new dataSharePredicates.DataSharePredicates();
      predicates.equalTo('DEVICE_MAC', this.deviceId);
      data = await helper.query(uri, predicates, ['*']);
      if (data.goToFirstRow()) {
        const codecType: number = data.getLong(data.getColumnIndex('CODEC_TYPE'));
        LogUtil.info(`${TAG} updateL2HCIcon success codecType: ${codecType}.`);
        this.codecType = codecType as a2dp.CodecType;
      } else {
        LogUtil.error(`${TAG} updateL2HCIcon goToFirstRow failed.`);
        this.codecType = a2dp.CodecType.CODEC_TYPE_INVALID;
      }
    } catch (e) {
      LogUtil.error(`${TAG} updateL2HCIcon failed: ${e?.code} ${e?.message}`);
    } finally {
      data?.close();
      helper?.close();
    }
  }

  /**
   * 当前是否为助听器设备
   *
   * @returns 是否是助听器设备
   */
  public isHearingAidDevice(): boolean {
    let hearingAidProfile = this.profileMap.get(ProfileId.PROFILE_HEARING_AID);
    return hearingAidProfile !== null && hearingAidProfile !== undefined;
  }

  /**
   * 设置助听器识别id
   *
   * @param hearingId 助听器识别id
   */
  public setHearingAidId(hearingId?: number) {
    this.hearingAidId = hearingId;
  }

  /**
   * 获取助听器识别id
   *
   * @returns 助听器识别id
   */
  public getHearingAidId(): number | undefined {
    // if (!this.hearingAidId && this.isHearingAidDevice()) {
    //   this.hearingAidId =
    //     (this.profileMap.get(ProfileId.PROFILE_HEARING_AID) as HearingAidProfile).getHearingAidId(this.deviceId);
    // }
    return this.hearingAidId;
  }

  /**
   * 添加附属设备
   *
   * @param device 附属设备对象
   */
  public setSubDevice(device?: BluetoothDevice) {
    this.subDevice = device;
  }

  /**
   * 获取附属设备
   *
   * @returns 当前设备的附属设备
   */
  public getSubDevice(): BluetoothDevice | undefined {
    return this.subDevice;
  }
}
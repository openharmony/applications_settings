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

import bluetoothManager from '@ohos.enterprise.bluetoothManager';
import access from '@ohos.bluetooth';
import { BusinessError } from '@ohos.base';
import { ResourceUtil } from './ResourceUtil';
import { LogUtil } from './LogUtil';
import { CheckEmptyUtils } from './CheckEmptyUtils';
import { HiSysEventUtil } from '../systemEvent/HiSysEventUtil';
import { SettingsDataUtils } from './SettingsDataUtils';
import { LanguageUtils } from './LanguageUtils';
import { SWITCH_OFF_VAL, SWITCH_ON_VAL, }
  from './Consts';
import { HiSysBluetoothEventGroup } from '../systemEvent/BehaviorEventConsts';

const TAG: string = 'BluetoothUtils : ';

export const BLUETOOTH_SWITCH_KEY: string = 'bluetooth_switch';

export const BLUETOOTH_BONDED_DEVICES_GROUP_KEY: string = 'bluetooth_bonded_devices_group';

export const BLUETOOTH_LIST_GROUP_KEY: string = 'bluetooth_list_group';

export const BLUETOOTH_SEARCH_MESSAGE_KEY: string = 'bluetooth_search_message_menu_key';

export const BLUETOOTH_DEVICE_SYNC_VOLUME_WITH_PHONE_KEY: string = 'bluetooth_device_sync_volume_with_phone_menu_key';

export const BLUETOOTH_DEVICE_NAME_COMP_ID: string = 'Setting.Bluetooth.UpdateNameGroup.UpdateNameItem';

const AIR_PLANE_MODE: string = 'settings.telephony.airplanemode';

/**
 * 已配对蓝牙设备设备类型枚举值
 */
export enum BluetoothBondedDeviceType {
  // 默认值
  DEVICE_TYPE_DEFAULT = 0,
  // 汽车
  DEVICE_TYPE_CAR = 1,
  // 耳机
  DEVICE_TYPE_HEADSET = 2,
  // 助听器
  DEVICE_TYPE_HEARING = 3,
  // 眼镜
  DEVICE_TYPE_GLASSES = 4,
  // 手表
  DEVICE_TYPE_WATCH = 5,
  // 音响
  DEVICE_TYPE_SPEAKER = 6,
}

/**
 * 蓝牙工具类
 *
 * @since 2022-04-25
 */
export class BluetoothUtils {
  public static readonly MAC_REGEX_PATTERN: RegExp = new RegExp('([A-Fa-f0-9]{2}[-,:]){5}[A-Fa-f0-9]{2}');
  public static readonly MAC_WITH_HALF_DENOMINATOR: number = 2;
  public static readonly MAC_PRINT_WITH_PRE: number = 5;
  public static readonly MAC_PRINT_WITH_SUF: number = 3;
  public static readonly ANONYMOUS_MAC: string = ':**:**:**';
  public static enhancedServicesState: string | undefined = undefined;

  /**
   * 实时查蓝牙开关状态
   */
  static isBluetoothOn(): boolean {
    try {
      let bluetoothState = access.getState();
      LogUtil.info(`${TAG} bluetoothState: ${bluetoothState}`);
      return BluetoothUtils.isBluetoothStateOn(bluetoothState);
    } catch (error) {
      LogUtil.info(`${TAG} isBluetoothOn error: ${(error as BusinessError).message}`);
    }
    return false;
  }

  /**
   * 打开蓝牙开关
   */
  static enableBlueTooth(): boolean {
    try {
      access.enableBluetooth();
      return true;
    } catch (error) {
      LogUtil.info(`${TAG} enableBlueTooth error: ${error?.message}`);
    }
    return false;
  }

  static async enableBlueToothAsync(): Promise<boolean> {
    try {
      await access.enableBluetooth();
      return true;
    } catch (error) {
      LogUtil.info(`${TAG} enableBlueTooth error: ${error?.message}`);
    }
    return false;
  }

  /**
   * 关闭蓝牙开关
   */
  static disableBlueTooth(): boolean {
    // 飞行模式开启
    let value: string = SettingsDataUtils.getSettingsData(AIR_PLANE_MODE, '0');
    if (value !== '0') {
      try {
        access.disableBluetooth();
        HiSysEventUtil.reportDefaultBehaviorEventByUE(HiSysBluetoothEventGroup.CLICK_BLUETOOTH_BUTTON, 'false');
        LogUtil.info(`${TAG} airPlane on, Disabling Bluetooth.`);
        return true;
      } catch (error) {
        LogUtil.error(`${TAG} disable failed, ${error?.message}`);
        return false;
      }
    }
    try {
      access.disableBluetooth();
      HiSysEventUtil.reportDefaultBehaviorEventByUE(HiSysBluetoothEventGroup.CLICK_BLUETOOTH_BUTTON, 'false');
      LogUtil.info(`${TAG} Disabling Bluetooth.`);
      return true;
    } catch (error) {
      LogUtil.error(`${TAG} disable failed, ${error?.message}`);
      return false;
    }
  }

  /**
   * 实时查蓝牙开关状态值
   */
  static getCurrentBluetoothState(): number {
    try {
      let bluetoothState = access.getState();
      LogUtil.info(`${TAG} getState: ${bluetoothState}`);
      return bluetoothState;
    } catch (error) {
      LogUtil.error(`${TAG} isBluetoothOn error: $(error.message)`);
      return access.BluetoothState.STATE_OFF;
    }
  }

  static isBluetoothDiscoveryOn(bluetoothState: number): boolean {
    return bluetoothState === access.BluetoothState.STATE_ON;
  }

  /**
   * 判断当前给的状态是否开启过程中
   *
   * @param bluetoothState 待判断的状态
   */
  static isBluetoothStateOpening(bluetoothState: number): boolean {
    return bluetoothState === access.BluetoothState.STATE_TURNING_ON ||
      bluetoothState === access.BluetoothState.STATE_BLE_TURNING_ON;
  }

  /**
   * 判断当前状态值是否处于中间态（即开启或者关闭以外的状态）
   *
   * @param bluetoothState 待判断的状态
   * @returns 返回状态值
   */
  static isBluetoothMiddleState(bluetoothState: number): boolean {
    return bluetoothState !== access.BluetoothState.STATE_ON &&
      bluetoothState !== access.BluetoothState.STATE_BLE_ON &&
      bluetoothState !== access.BluetoothState.STATE_OFF;
  }

  /**
   * 判断当前给的状态是否开启状态
   *
   * @param bluetoothState 待判断的状态
   * @returns 返回状态值
   */
  static isBluetoothStateOn(bluetoothState: number): boolean {
    if (bluetoothState === access.BluetoothState.STATE_ON) {
      return true;
    }
    if (BluetoothUtils.enhancedServicesState === SWITCH_OFF_VAL &&
      bluetoothState == access.BluetoothState.STATE_BLE_ON) {
      return true;
    }
    return false;
  }

  /**
   * 判断当前给的状态是否关闭过程中
   *
   * @param bluetoothState 待判断的状态STATE_TURNING_OFF
   */
  static isBluetoothStateClosing(bluetoothState: number): boolean {
    return bluetoothState === access.BluetoothState.STATE_TURNING_OFF ||
      bluetoothState === access.BluetoothState.STATE_BLE_TURNING_OFF;
  }

  /**
   * 判断当前给的状态是否关闭状态
   *
   * @param bluetoothState 待判断的状态
   * @returns 返回状态值
   */
  static isBluetoothStateOff(bluetoothState: number): boolean {
    if (bluetoothState === access.BluetoothState.STATE_OFF) {
      return true;
    }
    return false
  }

  /**
   * 当前设备ID格式是否正常
   *
   * @param macStr 设备ID字符串
   */
  static isValidMac(macStr: string): boolean {
    if (!macStr) {
      return false;
    }

    return macStr.match(BluetoothUtils.MAC_REGEX_PATTERN) !== null;
  }

  /**
   * 获取可以打印的掩码后设备ID
   *
   * @param macStr 设备ID字符串
   */
  static getLogMAC(macStr: string): string {
    if (!BluetoothUtils.isValidMac(macStr)) {
      return '';
    }
    let substring: string | null = null;
    substring = macStr.substring(0, BluetoothUtils.MAC_PRINT_WITH_PRE);
    return substring + BluetoothUtils.ANONYMOUS_MAC +
      macStr.substring(macStr.length - BluetoothUtils.MAC_PRINT_WITH_SUF, macStr.length);
  }

  static getPreMac(macStr: string): string {
    if (!BluetoothUtils.isValidMac(macStr)) {
      return '';
    }

    return macStr.substring(0, BluetoothUtils.MAC_PRINT_WITH_PRE)?.replace(':', '');
  }

  static getSufMac(macStr: string): string {
    if (!BluetoothUtils.isValidMac(macStr)) {
      return '';
    }

    return macStr.substring(macStr.length - 2, macStr.length);
  }

  /**
   * 获取可以打印的掩码后设备uuid
   *
   * @param uuidStr 设备uuid字符串
   */
  static getLogUuid(uuidStr: string[]): string {
    if (CheckEmptyUtils.isEmptyArr(uuidStr)) {
      return '';
    }
    let result: string = '';
    uuidStr.forEach((uuid: string) => {
      let substring = uuid.substring(0, uuid.length / BluetoothUtils.MAC_WITH_HALF_DENOMINATOR);
      result += `${substring}${BluetoothUtils.ANONYMOUS_MAC}, `
    })
    return result;
  }

  /**
   * 根据设备类型枚举值，返回对应字串
   *
   * @param deviceType 设备类型枚举值
   * @returns 设备类型字串
   */
  static getBondDeviceType(deviceType: number): string {
    let deviceTypeString = '';
    switch (deviceType) {
      case BluetoothBondedDeviceType.DEVICE_TYPE_CAR:
        deviceTypeString = ResourceUtil.getStringSync($r('app.string.device_type_car'));
        break;
      case BluetoothBondedDeviceType.DEVICE_TYPE_HEADSET:
        deviceTypeString = ResourceUtil.getStringSync($r('app.string.device_type_headset'));
        break;
      case BluetoothBondedDeviceType.DEVICE_TYPE_HEARING:
        deviceTypeString = ResourceUtil.getStringSync($r('app.string.device_type_hearing'));
        break;
      case BluetoothBondedDeviceType.DEVICE_TYPE_GLASSES:
        deviceTypeString = ResourceUtil.getStringSync($r('app.string.device_type_glasses'));
        break;
      case BluetoothBondedDeviceType.DEVICE_TYPE_WATCH:
        deviceTypeString = ResourceUtil.getStringSync($r('app.string.device_type_watch'));
        break;
      case BluetoothBondedDeviceType.DEVICE_TYPE_SPEAKER:
        deviceTypeString = ResourceUtil.getStringSync($r('app.string.device_type_speaker'));
        break;
      default:
        deviceTypeString = '';
        break;
    }
    return deviceTypeString;
  }

  /**
   * 根据错误码返回对应的错误信息
   *
   * @param deviceName 设备名称
   * @param errorCode 错误码
   * @returns 错误信息
   */
  static getPairFailedMessage(deviceName: string, errorCode: number): string {
    let errorMessage = '';
    switch (errorCode) {
      case UnbondCause.USER_REMOVED:
        errorMessage = ResourceUtil.getFormatStringSync($r('app.string.blue_tooth_pair_failed2'), deviceName);
        break
      case UnbondCause.REMOTE_DEVICE_DOWN:
        errorMessage = ResourceUtil.getAnyStrFormatStringSync($r('app.string.blue_tooth_pair_failed1'),
          deviceName, LanguageUtils.getNumberFormat(1), LanguageUtils.getNumberFormat(2),
          LanguageUtils.getNumberFormat(10), LanguageUtils.getNumberFormat(3));
        break;
      case UnbondCause.AUTH_FAILURE:
        errorMessage = ResourceUtil.getFormatStringSync($r('app.string.blue_tooth_pair_failed2'), deviceName);
        break;
      case UnbondCause.AUTH_REJECTED:
        errorMessage = ResourceUtil.getFormatStringSync($r('app.string.blue_tooth_pair_failed3'), deviceName);
        break;
      default:
        errorMessage = ResourceUtil.getStringSync($r('app.string.bt_pair_failed_message'));
        break;
    }
    return errorMessage;
  }

  /**
   * 根据错误码返回对应的错误信息
   *
   * @param errorCode 错误码
   * @returns 错误信息
   */
  static getConnectFailedMessage(errorCode: number): string {
    let errorMessage = '';
    switch (errorCode) {
      case DisconnectCause.CONNECT_FROM_KEYBOARD:
        errorMessage = ResourceUtil.getStringSync($r('app.string.blue_tooth_connect_failed1'));
        break;
      case DisconnectCause.CONNECT_FROM_MOUSE:
        errorMessage = ResourceUtil.getStringSync($r('app.string.blue_tooth_connect_failed2'));
        break;
      case DisconnectCause.CONNECT_FROM_CAR:
        errorMessage = ResourceUtil.getStringSync($r('app.string.blue_tooth_connect_failed3'));
        break;
      case DisconnectCause.TOO_MANY_CONNECTED_DEVICES:
        errorMessage = ResourceUtil.getStringSync($r('app.string.blue_tooth_connect_failed4'));
        break;
      default:
        errorMessage = '';
        break;
    }
    return errorMessage;
  }

  /**
   * 外领域是否禁用蓝牙
   *
   * @returns 禁用状态
   */
  static isBluetoothManagerEnable(): boolean {
    let bluetoothDisabled: boolean = false;
    try {
      bluetoothDisabled = bluetoothManager?.isBluetoothDisabled(null);
      LogUtil.info(`${TAG} bluetoothManager Success result : ${bluetoothDisabled}`);
    } catch (err) {
      LogUtil.error(`${TAG} bluetoothManager Failed result, Code: ${err?.code}, message: ${err?.message}`);
    }
    return bluetoothDisabled;
  }
}

export enum UnbondCause {
  // 用户主动取消配对
  USER_REMOVED = 0,
  // 远端设备关闭
  REMOTE_DEVICE_DOWN = 1,
  // PIN 码或配对密钥错误
  AUTH_FAILURE = 2,
  // 远端设备鉴权拒绝
  AUTH_REJECTED = 3,
  // 其他原因
  INTERNAL_ERROR = 4
}

export enum DisconnectCause {
  // 用户主动断开连接
  USER_DISCONNECT = 0,
  // 手机发起向键盘重新连接请求
  CONNECT_FROM_KEYBOARD = 1,
  // 手机发起向鼠标重新连接请求
  CONNECT_FROM_MOUSE = 2,
  // 手机发起向车机重新连接请求
  CONNECT_FROM_CAR = 3,
  // 设备连接数超限
  TOO_MANY_CONNECTED_DEVICES = 4,
  // 其他
  CONNECT_FAIL_INTERNAL = 5
}

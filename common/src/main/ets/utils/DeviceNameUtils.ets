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

import { BusinessError, settings } from '@kit.BasicServicesKit';
import { distributedDeviceManager } from '@kit.DistributedServiceKit';
import { intl } from '@kit.LocalizationKit';
import distributedAccount from '@ohos.account.distributedAccount';
import common from '@ohos.app.ability.common';
import CommonEvent from '@ohos.commonEvent';
import deviceInfo from '@ohos.deviceInfo';
import Settings from '@ohos.settings';
import taskpool from '@ohos.taskpool';
import call from '@ohos.telephony.call';
import wifiManager from '@ohos.wifiManager';
import { AbilityContextManager } from '../ability/AbilityContextManager';
import { PackagesConstant } from '../constant/PackagesConstant';
import { CheckEmptyUtils } from './CheckEmptyUtils';
import { LanguageUtils } from './LanguageUtils';
import { LogMaskUtil, LogUtil } from './LogUtil';
import { ResourceUtil } from './ResourceUtil';
import { SettingsDataUtils } from './SettingsDataUtils';
import { StringUtil } from './StringUtil';
import { ToastUtil } from './ToastUtil';
import { AccountUtil } from './AccountUtil';
import { ContextUtils } from './baseutils/ContextUtils';
import connection from '@ohos.bluetooth.connection';
const TAG = 'DeviceNameUtils : ';
const units: string[] = ['B', 'KB', 'MB', 'GB', 'TB'];
const unitsTran: string[] = ['byte', 'kilobyte', 'megabyte', 'gigabyte', 'terabyte'];
const SETTINGS_DATA_DEVICE_NAME = 'settings.general.device_name';
const SETTINGS_DATA_DISPLAY_DEVICE_NAME = 'settings.general.display_device_name';
const SETTINGS_DATA_MIGRATED_DEVICE_NAME = 'settings.general.migrated_device_name';
const SETTINGS_DATA_USER_DEFINED_DEVICE_NAME = 'settings.general.user_defined_device_name';
const SETTINGS_DATA_DISPLAY_DEVICE_NAME_STATE = 'settings.general.display_device_name_state';
const INIT_DEVICE_NAME_STATE = 'init_device_name_state';
const CHINESE_APPEND_SYMBOL = '的';
const OTHER_APPEND_SYMBOL = '-';

export const HOTSPOT_NAME_MAX_LENGTH: number = 30;

export const HOTSPOT_NAME_ELLIPSIS: string = '...';

export const CHECK_SUCCESS: number = 0;

export const CHECK_FAIL_REASON_NETWORK: number = 1;

export const CHECK_FAIL_REASON_LOG_IN: number = 2;

export const ABOUT_DEVICE_NAME_COMP_ID: string = 'AboutDevice.device_name_group.device_name';

enum DeviceNameState {
  // 默认设备名
  DEVICE_NAME = 'device_name',
  // 用户自定义设备名
  USER_DEFINED_DEVICE_NAME = 'user_defined_device_name',
  // 显示设备名
  DISPLAY_DEVICE_NAME = 'display_device_name',
}

enum DeviceNameCheckErrCode {
  ERROR_CODE_RISK_CHECK_FAIL = 11600108,
}

const CHECK_FAIL_CODE: Set<number> = new Set([
  DeviceNameCheckErrCode.ERROR_CODE_RISK_CHECK_FAIL,
]);

@Concurrent
function setDefaultName(context: common.Context, name: string): void {
  try {
    const SETTINGS_DATA_DISPLAY_DEVICE_NAME = 'settings.general.display_device_name';
    const DISPLAY_DEVICE_NAME_STATE = 'settings.general.display_device_name_state';
    const DISPLAY_DEVICE_NAME = 'display_device_name';
    let state: string =
      SettingsDataUtils.getSettingsDataWithContext(context, DISPLAY_DEVICE_NAME_STATE, DISPLAY_DEVICE_NAME,
        Settings.domainName.USER_SECURITY);
    if (state === DISPLAY_DEVICE_NAME) {
      SettingsDataUtils.setSettingsDataWithContext(context, SETTINGS_DATA_DISPLAY_DEVICE_NAME, name,
        Settings.domainName.USER_SECURITY);
    }
  } catch (error) {
    LogUtil.error(`DeviceNameUtils setDefaultName failed ：${error?.code}`);
  }
}

@Concurrent
function getValue(context: common.Context, key: string, defaultValue: string, domain?: string): string {
  try {
    if (domain) {
      return SettingsDataUtils.getSettingsDataWithContext(context, key, defaultValue, domain);
    } else {
      return SettingsDataUtils.getSettingsDataWithContext(context, key, defaultValue);
    }
  } catch (error) {
    LogUtil.error(`DeviceNameUtils getValue failed ：${error?.code}`);
    return '';
  }
}

/**
 * 设备名称相关工具类
 *
 * @since 2024-3-30
 */
export class DeviceNameUtil {
  private static deviceManager: distributedDeviceManager.DeviceManager | undefined;

  /* instrument ignore next */
  static getDeviceManager(timeId?: string): distributedDeviceManager.DeviceManager | undefined {
    if (!DeviceNameUtil.deviceManager) {
      LogUtil.showInfo(TAG, 'createDeviceManager');
      try {
        const packageName: string = CheckEmptyUtils.isEmpty(timeId) ? PackagesConstant.SETTINGS_BUNDLE_NAME :
          PackagesConstant.SETTINGS_BUNDLE_NAME + timeId;
        DeviceNameUtil.deviceManager =
          distributedDeviceManager.createDeviceManager(packageName);
      } catch (err) {
        LogUtil.error(`${TAG} createDeviceManager fail: errCode ${err?.code}, errMessage ${err?.message}`);
      }
    }
    return DeviceNameUtil.deviceManager;
  }

  /**
   * 释放DeviceManager
   */
  static releaseDeviceManager(): void {
    /* instrument ignore if*/
    if (DeviceNameUtil.deviceManager) {
      LogUtil.showInfo(TAG, 'releaseDeviceManager');
      try {
        distributedDeviceManager.releaseDeviceManager(DeviceNameUtil.deviceManager);
        DeviceNameUtil.deviceManager = undefined;
      } catch (err) {
        LogUtil.error(`${TAG} releaseDeviceManager fail: errCode ${err?.code}, errMessage ${err?.message}`);
      }
    }
  }

  /* instrument ignore next */
  static async initDeviceName(): Promise<void> {
    let getInitStateTask: taskpool.Task =
      new taskpool.Task(getValue, DefaultName.getContext(), INIT_DEVICE_NAME_STATE, 'false');
    let initState: string = await taskpool.execute(getInitStateTask, taskpool.Priority.MEDIUM) as string;
    if (initState === 'true') {
      LogUtil.showInfo(TAG, 'no need initDeviceName');
      return;
    }
    LogUtil.showInfo(TAG, 'initDeviceName');
    let defaultName: string = DefaultName.getDefaultName();
    SettingsDataUtils.setSettingsDataAsync(SETTINGS_DATA_DEVICE_NAME, defaultName);
    SettingsDataUtils.setSettingsDataAsync(INIT_DEVICE_NAME_STATE, 'true');
  }

  static  getDeviceNameAsync(): string{
    const context: Context = ContextUtils.getContext()
    const deviceName = settings.getValueSync(context, settings.general.DEVICE_NAME,'');
    return deviceName
  }

  static async setDisplayDeviceNameAsync(deviceName: string): Promise<boolean> {
    LogUtil.info(`${TAG} setDisplayDeviceNameAsync ${LogMaskUtil.getLogNickNameString(deviceName)}`);
    let result: boolean = true;
    const context: Context = ContextUtils.getContext()
    const dev = settings.getValueSync(context, settings.general.DEVICE_NAME,'');
    try {
      settings.setValueSync(context, settings.general.DEVICE_NAME, deviceName);
      if (!dev) {
        let resource = CHECK_FAIL_CODE.has(DeviceNameCheckErrCode.ERROR_CODE_RISK_CHECK_FAIL) ?
          $r('app.string.device_name_check_fail') : $r('app.string.device_name_update_fail');
        ToastUtil.showToast(ResourceUtil.getStringSync(resource), ToastUtil.SHORT_DURATION);
        LogUtil.error(`${TAG} set local device name fail: errCode :, errMessage `);
        result = false;
      }
    } catch (err) {
      LogUtil.error(`${TAG} getDeviceManager fail: errCode ${err?.code}, errMessage ${err?.message}`);
      result = false;
    }
    LogUtil.info(`${TAG} setDisplayDeviceNameAsync result: ${result}`);
    if (result && call.hasVoiceCapability()) { // 支持个人热点
      DeviceNameUtil.updateHotspotName(deviceName);
    }
    return result;
  }

  static updateHotspotName(deviceName: string): void {
    /* instrument ignore next */
    try {
      let config: wifiManager.HotspotConfig = wifiManager.getHotspotConfig();
      let regex = /.*(CloudClone|SpaceClone|SubClone)$/;
      let isUpdateName = !regex.test(config.ssid);
      if (!isUpdateName) {
        LogUtil.info(`${TAG} now is cloning`);
        return;
      }
      if (!AccountUtil.isMainUser()) {
        LogUtil.info(`${TAG} is not main user`);
        return;
      }
      let newDeviceName: string = deviceName;
      if (StringUtil.getStringLength(deviceName) > HOTSPOT_NAME_MAX_LENGTH) {
        let ellipsisLength: number = StringUtil.getStringLength(HOTSPOT_NAME_ELLIPSIS);
        newDeviceName = StringUtil.getSubstringByBytes(deviceName, HOTSPOT_NAME_MAX_LENGTH - ellipsisLength) +
          HOTSPOT_NAME_ELLIPSIS;
      }
      if (config.ssid === newDeviceName) {
        return;
      }
      config.ssid = newDeviceName;
      LogUtil.info(`${TAG} hotspot name refresh`);
      if (wifiManager.isHotspotActive()) {
        wifiManager.disableHotspot();
        wifiManager.setHotspotConfig(config);
        wifiManager.enableHotspot();
      } else {
        wifiManager.setHotspotConfig(config);
      }
    } catch (error) {
      LogUtil.error(`${TAG} getHotspotConfig fail: ${error?.message}`);
    }
  }

  /**
   * 获取当前本机名称
   *
   * @returns 当前本机名称
   */
  static getDisplayDeviceName(): string {
    const context: Context = ContextUtils.getContext()
    let deviceName = settings.getValueSync(context, settings.general.DEVICE_NAME,'');
    return deviceName
  }

  static setMigratedDeviceName(migratedDeviceName: string): void {
    /* instrument ignore if*/
    if (CheckEmptyUtils.checkStrIsEmpty(migratedDeviceName)) {
      return;
    }
    SettingsDataUtils.setSettingsData(SETTINGS_DATA_MIGRATED_DEVICE_NAME, migratedDeviceName);
  }
}

/**
 * 设备默认名称类
 *
 * @since 2024-7-11
 */
export class DefaultName {
  static getDefaultName(): string {
    try {
      // 当前版本不出海，要出海时要隔离
      let defaultName: string = deviceInfo.marketName;
      return defaultName;
    } catch (error) {
      LogUtil.error(`${TAG} get getDisplayDeviceName failed ：${error?.code}`);
      return '';
    }
  }

  static getNickDefaultName(nickname: string): string {
    /* instrument ignore next */
    try {
      if (LanguageUtils.isChinaArea()) {
        return `${nickname}${CHINESE_APPEND_SYMBOL}${DefaultName.getDefaultName()}`;
      } else {
        return `${nickname}${OTHER_APPEND_SYMBOL}${DefaultName.getDefaultName()}`;
      }
    } catch (error) {
      LogUtil.error(`getNickDefaultName failed, error code: ${error?.code}`);
      return '';
    }
  }

  static setNameWithNick(nickname: string): void {
    let name: string = nickname ? DefaultName.getNickDefaultName(nickname) : DefaultName.getDefaultName();
    LogUtil.info(`${TAG} setNameWithNick: ${nickname ? 'nickname' : 'no nickname'}`);
    try {
      let setDefaultNameTask: taskpool.Task = new taskpool.Task(setDefaultName, DefaultName.getContext(), name);
      taskpool.execute(setDefaultNameTask, taskpool.Priority.MEDIUM);
    } catch (error) {
      LogUtil.error(`setNameWithNick failed, error code: ${error?.code}`);
    }
  }

  /* instrument ignore next */
  static async setDefaultName(event: string): Promise<void> {
    let deviceNameState: string =
      SettingsDataUtils.getSecureValue(SETTINGS_DATA_DISPLAY_DEVICE_NAME_STATE, DeviceNameState.DISPLAY_DEVICE_NAME);
    if (deviceNameState === DeviceNameState.DISPLAY_DEVICE_NAME) {
      LogUtil.showInfo(TAG, `setDefaultName`);
      if (event === CommonEvent.Support.COMMON_EVENT_HWID_LOGOUT) {
        const newDeviceName: string = DefaultName.getDefaultName();
        DeviceNameUtil.updateHotspotName(newDeviceName);
      } else {
        let info: distributedAccount.DistributedInfo =
          await distributedAccount.getDistributedAccountAbility()?.getOsAccountDistributedInfo();
        let newDeviceName: string =
          info?.nickname ? DefaultName.getNickDefaultName(info.nickname) : DefaultName.getDefaultName();
        DeviceNameUtil.updateHotspotName(newDeviceName);
      }
    } else {
      LogUtil.info(`${TAG} deviceName state: ${deviceNameState}`);
    }
  }

  static getContext(): common.Context {
    let context = AbilityContextManager.getContext();
    /* instrument ignore if*/
    if (CheckEmptyUtils.isEmpty(context)) {
      context = AbilityContextManager.getExtContext();
    }
    return context;
  }
}

interface FormatSizeModel {
  size: number,
  unitIndex: number
}

/**
 * 存储空间工具类
 *
 * @since 2024-03-21
 */
export class StorageSizeUtil {
  private static readonly TAG: string = 'StorageSizeUtil : ';

  /**
   * 根据当前语言 对存储数据单位格式化，大于100整数（四舍五入），小于100带两位小数
   *
   * @param val 待格式化的大小
   * @param count 精度，保留的位数
   * @param isRound 是否对结果做近似处理
   *
   * @returns 格式化后的结果
   */
  static formatDataIntl(val: number, count: number, isRound: boolean = false): string {
    let numbers: number = Math.pow(10, count);
    let formatNumByte: string = '';
    if (numbers === 0) {
      return formatNumByte;
    }
    const formatSize = StorageSizeUtil.getFormatSize(val, numbers, isRound);
    const uintFormat: intl.NumberFormat = new intl.NumberFormat(LanguageUtils.getLanguage(),
      { style: 'unit', unit: unitsTran[formatSize.unitIndex], unitDisplay: 'short' });
    try {
      formatNumByte = uintFormat.format(formatSize.size);
    } catch (err) {
      LogUtil.error(`${StorageSizeUtil.TAG} formatDataIntl failed, code: ${err?.code}, msg: ${err?.message}`);
    }
    LogUtil.info(`${StorageSizeUtil.TAG} formatDataIntl val: ${val}, res: ${formatNumByte}`);
    return formatNumByte;
  }

  private static getFormatSize(val: number, numbers: number, isRound: boolean): FormatSizeModel {
    let index: number;
    let result: number;
    if (val < 1000) {
      result = Number(val * numbers);
      index = 0;
    } else if (val < 1000 * 1000) {
      result = Number(val / 1000 * numbers);
      index = 1;
    } else if (val < 1000 * 1000 * 1000) {
      result = Number(val / (1000 * 1000) * numbers);
      index = 2;
    } else if (val < 1024 * 1000 * 1000 * 1000) {
      result = Number(val / (1000 * 1000 * 1000) * numbers);
      index = 3;
    } else if (val < 1000 * 1000 * 1000 * 1000 * 1000) {
      result = Number(val / (1024 * 1000 * 1000 * 1000) * numbers);
      index = 4;
    } else {
      result = Number(val / (1024 * 1000 * 1000 * 1000) * numbers);
      index = 4;
    }
    let size =
      isRound ? StorageSizeUtil.handleData(result / numbers) : (Math.floor(result) / numbers).valueOf();
    return { size: size, unitIndex: index } as FormatSizeModel;
  }

  // 数据处理，大于100整数（四舍五入），小于100带两位小数
  static handleData(data: number): number {
    if (data > 100) {
      return Math.round(data);
    } else {
      return (Math.round(data * 100) / 100);
    }
  }
}

/**
 * 毫秒转换成 xx : xx : xx
 * @param timeMillis
 * @returns 转换后时间字符串
 */
export class DeviceTimeUtil {
  private static readonly TAG: string = 'DeviceTimeUtil : ';

  static formatTimeMillis(timeMillis: number): string {
    let seconds = Math.floor(timeMillis / 1000);
    let minutes = Math.floor(seconds / 60);
    let hours = Math.floor(minutes / 60);
    let result: string = '';
    if (hours > 0) {
      result = hours + ':' + (minutes % 60).toString().padStart(2, '0') + ':' +
      (seconds % 60).toString().padStart(2, '0');
    } else if (minutes > 0) {
      result = minutes + ':' + (seconds % 60).toString().padStart(2, '0');
    } else {
      result = (seconds % 60).toString();
    }
    LogUtil.info(`${DeviceTimeUtil.TAG} val is: ${result}`);
    return result;
  }
}

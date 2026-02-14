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

import bundleManager from '@ohos.bundle.bundleManager';
import { BusinessError } from '@kit.BasicServicesKit';
import common from '@ohos.app.ability.common';
import dialogRequest from '@ohos.app.ability.dialogRequest';
import radio from '@ohos.telephony.radio';
import deviceInfo from '@ohos.deviceInfo';
import connection from '@ohos.net.connection';
import wifiManager from '@ohos.wifiManager';
// import infosec from '@hms.hiviewdfx.infosec';
import hidebug from '@ohos.hidebug';
import display from '@ohos.display';
import storageStatistics from '@ohos.file.storageStatistics';
import systemParameterEnhance from '@ohos.systemParameterEnhance';
import esim from '@ohos.telephony.esim'
import OpenLinkOptions from '@ohos.app.ability.OpenLinkOptions';
import { AbilityContextManager } from '@ohos/settings.common/src/main/ets/ability/AbilityContextManager';
import { AbilityUtils } from '@ohos/settings.common/src/main/ets/utils/AbilityUtils';
import { ResourceUtil } from '@ohos/settings.common/src/main/ets/utils/ResourceUtil';
import { SettingsDataUtils } from '@ohos/settings.common/src/main/ets/utils/SettingsDataUtils';
import { LogUtil } from '@ohos/settings.common/src/main/ets/utils/LogUtil';
import { KernelInfoType } from '@ohos/settings.native/src/main/ets/model/KernelInfoType';
import { SystemParamUtil } from '@ohos/settings.common/src/main/ets/utils/SystemParamUtil';
import { CheckEmptyUtils } from '@ohos/settings.common/src/main/ets/utils/CheckEmptyUtils';
import { TelephonyRadioUtils } from '@ohos/settings.common/src/main/ets/utils/TelephonyRadioUtils';
import { SimUtils } from '@ohos/settings.common/src/main/ets/utils/SimUtils';
import { SystemParamUtils } from '@ohos/settings.common/src/main/ets/screenReader/utils/SystemParamUtils';
import { StorageSizeUtil } from '@ohos/settings.common/src/main/ets/utils/DeviceNameUtils';
import { CARD_NUM_ONE, SLOTID_ONE, SLOTID_TWO } from '@ohos/settings.common/src/main/ets/constant/SimConstant';
import { PRECISION0, PRECISION2 } from '@ohos/settings.common/src/main/ets/constant/ViewConstant';
import { StringUtil } from '@ohos/settings.common/src/main/ets/utils/StringUtil';
import { LanguageUtils } from '@ohos/settings.common/src/main/ets/utils/LanguageUtils';
import { DeviceUtil } from '@ohos/settings.common/src/main/ets/utils/BaseUtils';
import { DisplayUtils } from '@ohos/settings.common/src/main/ets/utils/DisplayUtils';
import { WifiUtils } from '@ohos/settings.wifi/src/main/ets/WifiUtils';
import lazy { napi } from '@ohos/settings.native/src/main/ets/napi/NapiInstance';
import { PageRouter } from '@ohos/settings.common/src/main/ets/framework/common/PageRouter';
import { NavEntryKey } from '@ohos/settings.common/src/main/ets/utils/Consts';
import { HiSysEventUtil } from '@ohos/settings.common/src/main/ets/systemEvent/HiSysEventUtil';
import { HiSysAboutDeviceEventGroup } from '@ohos/settings.common/src/main/ets/systemEvent/BehaviorEventConsts';
import {
  DISPLAY_VERSION_SYS_PARAM_KEY,
  OS_SETTINGS_DISPLAY,
  IPV4_FAMILY,
  IPV6_FAMILY,
  NEWLINE_SEPARATOR,
  INFORMATION_HIDE,
  INFORMATION_VENDOR_DDRSIZE,
  HWMODULETRAIN_DISPLAY_VERSION,
  HWMODULETRAIN_DISPLAY_VERSION_REAL,
  BUILD_HIDE,
  ITSEC_EDITION_NUMBER_CCM_CONFIG,
} from '../const/AboutDeviceConst';

const TAG: string = 'AboutDeviceUtils';
const NETWORK_TYPE_GSM: number = 1;
const NETWORK_TYPE_CDMA: number = 2;
const NETWORK_TYPE_WCDMA: number = 3;
const NETWORK_TYPE_TDSCDMA: number = 4;
const NETWORK_TYPE_LTE: number = 5;
const NETWORK_TYPE_5GNR: number = 6;
const GB_IN_KB: number = 1024 * 1024;
const MCC_LENGTH: number = 3;
const CONST_OHOS_VERSION_CERTIFIED: string = 'const.ohos.version.certified';
const COM_ENTERPRISE_ENTERPRISE_CUSTOMIZATION_INFO: string = 'com.enterprise.enterprise_customization_info';
const REQUEST_DIALOG_ERROR: number = -999999;
const REQUEST_DIALOG_SUCCESS_CODE: number = 1;
const EID_SLOT_NUMBER: number = 1;
const PRODUCT_PROCESSOR_SHOW_PARAM_KEY: string = 'const.settings.processor_info_show';
const PRODUCT_PROCESSOR_NAME_PARAM_KEY: string = 'const.settings.processor_info_display';

export interface anonymizationArray {
  runningMemory: string,
  availableMemory: string,
  totalMemory: string,
  externalScreen: string,
  kernelVersion: string,
  hardwareModel: string,
  innerScreen: string,
  apiVersion: string,
  openHarmonyVersion: string,
  systemServiceVersion: string,
  processorVersion: string
}

export interface WifiStateParam {
  state: string;
  secondState: string;
}

/**
 * License版本类型信息
 */
export interface LicenseInfo {
  /**
   * 许可证类型: 0 Professional 专业版 10000 Enterprise 企业版
   */
  licenseType: string;

  /**
   * OS大版本号: 如5、6、7等
   */
  osMajorversion: string;
}

/**
 * License类型枚举
 */
export enum LicenseTypeEnum {
  PROFESSIONAL = '0',
  ENTERPRISE = '10000',
}

export class AboutDeviceUtils {
  private static isFirstAnonymization: boolean = true;
  private static anonymization: boolean = false;
  private static anonymizationInfoStr: string = '';
  public static anonymizationArry: anonymizationArray = {
    runningMemory: '',
    availableMemory: '',
    totalMemory: '',
    externalScreen: '',
    kernelVersion: '',
    hardwareModel: '',
    innerScreen: '',
    apiVersion: '',
    openHarmonyVersion: '',
    systemServiceVersion: '',
    processorVersion: ''
  }
  private static readonly SYSTEM_SERVICE_VERSION: string = SystemParamUtil.getParam(HWMODULETRAIN_DISPLAY_VERSION, '');
  private static readonly SYSTEM_SERVICE_VERSION_REAL: string =
    SystemParamUtil.getParam(HWMODULETRAIN_DISPLAY_VERSION_REAL, '');

  static getNetworkType(data: number) {
    switch (data) {
      case NETWORK_TYPE_GSM:
        return 'GSM';
      case NETWORK_TYPE_CDMA:
        return 'CDMA';
      case NETWORK_TYPE_WCDMA:
        return 'WCDMA';
      case NETWORK_TYPE_TDSCDMA:
        return 'TDSCDMA';
      case NETWORK_TYPE_LTE:
        return 'LTE';
      case NETWORK_TYPE_5GNR:
        return '5G NR';
      default:
        return '';
    }
  }

  /**
   * 判断是否伪装信息(匿名化)
   */
  static isAnonymization(): boolean {
    if (AboutDeviceUtils.isFirstAnonymization) {
      try {
        LogUtil.showInfo(TAG, 'isAnonymization in');
        // AboutDeviceUtils.anonymization = infosec.getInfoSecStatus(infosec.InfoSec.INFOSEC_FAKE_SETTINGS_INFO);
        AboutDeviceUtils.setAnonymizationInfo();
        AboutDeviceUtils.isFirstAnonymization = false;
        LogUtil.showInfo(TAG, `isAnonymization: ${AboutDeviceUtils.anonymization}`);
      } catch (error) {
        LogUtil.showError(TAG, `isAnonymization error: ${error?.message} code: ${error?.code}`);
      }
    }
    return AboutDeviceUtils.anonymization;
  }

  /**
   * 判断伪装信息是否有效
   */
  static isAnonymizationData(): boolean {
    return AboutDeviceUtils.isAnonymization() && !CheckEmptyUtils.isEmpty(AboutDeviceUtils.anonymizationInfoStr);
  }

  /**
   * 设置伪装信息
   */
  static setAnonymizationInfo(): void {
    LogUtil.showInfo(TAG, 'setAnonymizationInfo in');
    AboutDeviceUtils.anonymizationInfoStr = SystemParamUtils.getSystemParam(INFORMATION_HIDE, '');
    if (CheckEmptyUtils.checkStrIsEmpty(AboutDeviceUtils.anonymizationInfoStr)) {
      AboutDeviceUtils.anonymization = false;
      return;
    }
    let anonymizationInfo: string[] = AboutDeviceUtils.anonymizationInfoStr.split(';');
    AboutDeviceUtils.anonymizationArry.runningMemory = anonymizationInfo?.[0] ?? '';
    AboutDeviceUtils.anonymizationArry.availableMemory = anonymizationInfo?.[1] ?? '';
    AboutDeviceUtils.anonymizationArry.totalMemory = anonymizationInfo?.[2] ?? '';
    AboutDeviceUtils.anonymizationArry.externalScreen = anonymizationInfo?.[3] ?? '';
    AboutDeviceUtils.anonymizationArry.kernelVersion = anonymizationInfo?.[4] ?? '';
    AboutDeviceUtils.anonymizationArry.hardwareModel = anonymizationInfo?.[5] ?? '';
    AboutDeviceUtils.anonymizationArry.innerScreen = anonymizationInfo?.[6] ?? '';
    AboutDeviceUtils.anonymizationArry.apiVersion = anonymizationInfo?.[7] ?? '';
    AboutDeviceUtils.anonymizationArry.openHarmonyVersion = anonymizationInfo?.[8] ?? '';
    AboutDeviceUtils.anonymizationArry.systemServiceVersion = anonymizationInfo?.[9] ?? '';
    AboutDeviceUtils.anonymizationArry.processorVersion = anonymizationInfo?.[10] ?? '';
  }

  // 获取屏幕的伪装信息
  static getDefaultDisplayAnonymization(): string {
    if (DeviceUtil.isFoldable()) {
      if (AboutDeviceUtils.anonymizationArry.innerScreen) {
        let externalScreen: string[] = AboutDeviceUtils.anonymizationArry.externalScreen.split(' x ');
        let innerScreen: string[] = AboutDeviceUtils.anonymizationArry.innerScreen.split(' x ');
        let external: string = ResourceUtil.getAnyStrFormatStringSync($r('app.string.external'),
          externalScreen[0], externalScreen[1]);
        let inner: string = ResourceUtil.getAnyStrFormatStringSync($r('app.string.inner'),
          innerScreen[0], innerScreen[1]);
        return `${external}\n${inner}`;
      }
    }
    return AboutDeviceUtils.anonymizationArry.externalScreen;
  }

  /**
   * 获取运行内存
   */
  static getProductMemory(): number {
    // 优先读取系统参数中ddrSize
    try {
      let ddrMemSize = Number(SystemParamUtils.getSystemParam(INFORMATION_VENDOR_DDRSIZE, '0'));
      LogUtil.showInfo(TAG, `getProductMemory ddrSize  ${ddrMemSize} GB`);
      // instrument ignore else
      if (!Number.isNaN(ddrMemSize) && ddrMemSize != 0) {
        return ddrMemSize;
      } else {
        LogUtil.showError(TAG, 'getProductMemory ddrMemSize is invalid');
      }
    } catch (error) {
      LogUtil.showError(TAG, `getProductMemory ddrMemSize is invalid, error: ${error?.message} code: ${error?.code}`);
    }

    // 使用totalMem计算
    try {
      let totalMemSizeKB = Number(hidebug.getSystemMemInfo().totalMem);
      if (totalMemSizeKB > 0) {
        let totalMemSizeGB = Math.ceil(totalMemSizeKB / GB_IN_KB);
        LogUtil.showInfo(TAG, `getProductMemory totalMemSizeGB  ${totalMemSizeGB} GB`);
        return totalMemSizeGB;
      } else {
        LogUtil.showError(TAG, 'getProductMemory totalMemSizeKB is invalid');
      }
    } catch (error) {
      LogUtil.showError(TAG,
        `getProductMemory totalMemSizeKB is invalid, error: ${error?.message} code: ${error?.code}`);
    }
    return 0;
  }

  /**
   * 软件版本
   */
  static getSoftwareVersion(): string {
    let version: string = SystemParamUtil.getParam(DISPLAY_VERSION_SYS_PARAM_KEY, '');
    let releaseType: string = SystemParamUtil.getParam(OS_SETTINGS_DISPLAY, '');
    if (version) {
      LogUtil.showInfo(TAG, 'getDisplayVersion from persist.hwpatch.display.version');
      if (releaseType.length) {
        return version + '\n' + releaseType;
      }
      return version;
    }
    let displayVersion: string = deviceInfo.displayVersion ?? ' ';
    let versionStrArray: string[] = displayVersion.split(' ', 2);
    /* instrument ignore if*/
    if (!versionStrArray || versionStrArray.length <= 1) {
      LogUtil.showError(TAG, 'versionStrArray invalid');
      return displayVersion;
    }
    /* instrument ignore if*/
    if (!versionStrArray[1]) {
      LogUtil.showError(TAG, 'version invalid');
      return displayVersion;
    }
    if (releaseType.length) {
      return versionStrArray[1] + '\n' + releaseType;
    }
    return versionStrArray[1];
  }

  /**
   * IMEI
   */
  static async getImeiId(): Promise<string> {
    let imeiCardOne: string = await TelephonyRadioUtils.getImeiData(SLOTID_ONE);
    let imeiCardTwo: string = await TelephonyRadioUtils.getImeiData(SLOTID_TWO);
    if (SimUtils.getCardSlotNum() > CARD_NUM_ONE) {
      return `${imeiCardOne}\n${imeiCardTwo}`;
    }
    return imeiCardOne;
  }

  /**
   * 基带版本
   */
  static async getBasebandVersion(): Promise<string> {
    let basebandVersionOne: string | Resource = await TelephonyRadioUtils.getBaseBandVersion(SLOTID_ONE);
    let basebandVersionTwo: string | Resource = await TelephonyRadioUtils.getBaseBandVersion(SLOTID_TWO);
    if (SimUtils.getCardSlotNum() > CARD_NUM_ONE) {
      return `${basebandVersionOne}\n${basebandVersionTwo}`;
    }
    return basebandVersionOne;
  }

  /**
   * IP 地址
   */
  static async getIpAddress(netHandle: connection.NetHandle): Promise<string> {
    let ipAddress: string = '';
    try {
      let addressData: connection.ConnectionProperties = await connection.getConnectionProperties(netHandle);
      let linkAddresses: connection.LinkAddress[] = addressData.linkAddresses;
      let ipv4: string = '';
      let ipV6: string = '';
      /* instrument ignore next */
      linkAddresses.forEach(item => {
        if (item.address.family === IPV4_FAMILY) {
          ipv4 = item.address.address;
        }
        if (item.address.family === IPV6_FAMILY) {
          ipV6 += item.address.address + NEWLINE_SEPARATOR;
        }
      });
      if (CheckEmptyUtils.checkStrIsEmpty(ipV6)) {
        ipAddress = ipv4;
      } else if (CheckEmptyUtils.checkStrIsEmpty(ipv4)) {
        ipAddress = ipV6;
      } else {
        ipAddress = ipv4 + NEWLINE_SEPARATOR + ipV6.trim();
      }
    } catch (error) {
      LogUtil.showError(TAG, `connection.getDefaultNet error: ${error?.message} code: ${error?.code}`);
      ipAddress = ResourceUtil.getStringByName('wifi_state_off');
    }
    return ipAddress;
  }

  /**
   * WLAN MAC 地址
   */
  static async getWlanMacAddress(): Promise<WifiStateParam> {
    let wifiStateParam: WifiStateParam = { state: ResourceUtil.getStringByName('wifi_state_off'), secondState: '' };
    let state: Boolean = WifiUtils.isWifiActive();
    if (!state) {
      LogUtil.showError(TAG, 'getWlanMacAddress not open');
      return wifiStateParam;
    }
    let wifiName: string = await WifiUtils.wifiLinkedInfo();
    let lastLinkedInfo: wifiManager.WifiLinkedInfo = await wifiManager.getLinkedInfo();
    LogUtil.showInfo(TAG, `MAC type ${lastLinkedInfo.macType}`);
    /* instrument ignore if*/
    if (wifiName !== '') {
      if (lastLinkedInfo.macType === 0) {
        wifiStateParam.state = ResourceUtil.getFormatStringByName('random_mac', lastLinkedInfo.macAddress);
        wifiStateParam.secondState = ResourceUtil.getFormatStringByName('device_mac', WifiUtils.getDeviceMacAddress()
          .toString());
      } else {
        wifiStateParam.state = lastLinkedInfo.macAddress;
      }
    } else {
      wifiStateParam.state = WifiUtils.getDeviceMacAddress().toString();
    }
    return wifiStateParam;
  }

  /**
   * 运行内存
   */
  static getRunningMemory(): string {
    if (AboutDeviceUtils.isAnonymizationData() &&
      !CheckEmptyUtils.checkStrIsEmpty(AboutDeviceUtils.anonymizationArry.runningMemory)) {
      return AboutDeviceUtils.anonymizationArry.runningMemory;
    } else {
      let runningMemory: number = AboutDeviceUtils.getProductMemory();
      let memory: string = StorageSizeUtil.formatDataIntl(runningMemory * 1000 * 1000 * 1000, 0, true);
      return memory;
    }
  }

  /**
   * 总内存及已使用内存
   */
  static async getAppInfoStorage(): Promise<string> {
    try {
      let storage = await import('@ohos.file.storageStatistics');
      let storageDetail: storageStatistics.StorageStats = await storage.default.getUserStorageStats();
      let freeBytesNumber: number = await storage.default.getFreeSize();
      // instrument ignore else
      if (storageDetail && freeBytesNumber >= 0) {
        let availableBytes: string = StorageSizeUtil.formatDataIntl(freeBytesNumber, PRECISION2, false);
        if (AboutDeviceUtils.isAnonymizationData() &&
          !CheckEmptyUtils.checkStrIsEmpty(AboutDeviceUtils.anonymizationArry.availableMemory)) {
          availableBytes = AboutDeviceUtils.anonymizationArry.availableMemory;
        }
        let totalBytes: string = StorageSizeUtil.formatDataIntl(storageDetail.total, PRECISION0, false);
        if (AboutDeviceUtils.isAnonymizationData() &&
          !CheckEmptyUtils.checkStrIsEmpty(AboutDeviceUtils.anonymizationArry.totalMemory)) {
          totalBytes = AboutDeviceUtils.anonymizationArry.totalMemory;
        }
        LogUtil.showInfo(TAG, `availableBytes: ${availableBytes}, totalBytes: ${totalBytes}`);
        if (!LanguageUtils.isLtrDirection()) {
          availableBytes = '\u202A' + availableBytes + '\u202C';
          totalBytes = '\u202A' + totalBytes + '\u202C';
        }
        let availableMemory: string = ResourceUtil.getFormatStringByName('storage_total_used', availableBytes);
        let totalMemory: string = ResourceUtil.getFormatStringByName('storage_total', totalBytes);
        return `${availableMemory}\n${totalMemory}`;
      } else {
        LogUtil.showError(TAG, `getStorageTotalAndUsed error, free byte ${freeBytesNumber}`);
      }
    } catch (error) {
      LogUtil.showError(TAG, `getStorageTotalAndUsed failed, error reason: ${error?.code}`);
    }
    return '';
  }

  /**
   * 获取屏幕分辨率
   * @returns 屏幕分辨率
   */
  static async getDefaultDisplay(): Promise<string> {
    let screenResolution: string = '';
    let result: string = AboutDeviceUtils.getDefaultDisplayAnonymization();
    if (AboutDeviceUtils.isAnonymizationData() && !CheckEmptyUtils.checkStrIsEmpty(result)) {
      screenResolution = result;
    } else if (DeviceUtil.isThreeFoldable()) {
      let displayInfo: display.Display | undefined = DisplayUtils.getDefaultDisplaySyncInfo();
      let defaultScreenSolution = `${displayInfo?.height} x ${displayInfo?.width}`;
      let result: display.DisplayPhysicalResolution[] = await DisplayUtils.getAllDisplayPhysicalResolution();
      screenResolution =
        (result?.length > 2 && result[2]) ? `${result[2].physicalWidth} x ${result[2].physicalHeight}` :
          defaultScreenSolution;
    } else if (DeviceUtil.isFoldable()) {
      let external: string = '';
      let inner: string = '';
      let result: display.DisplayPhysicalResolution[] = await DisplayUtils.getAllDisplayPhysicalResolution();
      /* instrument ignore if*/
      if (result.length > 1) {
        external = ResourceUtil.getAnyStrFormatStringSync($r('app.string.external'),
          ResourceUtil.getLocalNumberFormat(result[0]?.physicalHeight),
          ResourceUtil.getLocalNumberFormat(result[0]?.physicalWidth));
        inner = ResourceUtil.getAnyStrFormatStringSync($r('app.string.inner'),
          ResourceUtil.getLocalNumberFormat(result[1]?.physicalWidth),
          ResourceUtil.getLocalNumberFormat(result[1]?.physicalHeight));
        screenResolution = `${external}\n${inner}`;
      } else {
        screenResolution =
          `${ResourceUtil.getLocalNumberFormat(result[0]?.physicalHeight)} x ${ResourceUtil.getLocalNumberFormat(result[0]?.physicalWidth)}`;
      }
    } else {
      let displayInfo: display.Display | undefined = DisplayUtils.getDefaultDisplaySyncInfo();
      if (displayInfo) {
        screenResolution =
          `${ResourceUtil.getLocalNumberFormat(displayInfo.height)} x ${ResourceUtil.getLocalNumberFormat(displayInfo.width)}`;
      }
    }
    return screenResolution;
  }

  /**
   * 获取内核版本
   * @returns 内核版本
   */
  static getKernelVersion(): string {
    let version: string = '';
    if (AboutDeviceUtils.isAnonymizationData() &&
      !CheckEmptyUtils.checkStrIsEmpty(AboutDeviceUtils.anonymizationArry.kernelVersion)) {
      version = AboutDeviceUtils.anonymizationArry.kernelVersion;
    } else {
      version = `${napi.getKernelInfo(KernelInfoType.KERNEL_RELEASE)}\n` +
        `${napi.getKernelInfo(KernelInfoType.KERNEL_SYS_NAME)}@` +
        `${napi.getKernelInfo(KernelInfoType.KERNEL_NODE_NAME)} ` +
        `${napi.getKernelInfo(KernelInfoType.KERNEL_VERSION)}`;
    }
    return version;
  }

  /**
   * 获取硬件版本
   * @returns 硬件版本
   */
  static getHardwareModel(): string {
    let hardwareModel = '';
    if (AboutDeviceUtils.isAnonymizationData() &&
      !CheckEmptyUtils.checkStrIsEmpty(AboutDeviceUtils.anonymizationArry.hardwareModel)) {
      hardwareModel = AboutDeviceUtils.anonymizationArry.hardwareModel;
    } else {
      hardwareModel = deviceInfo.hardwareModel;
    }
    return hardwareModel;
  }

  /**
   * 获取API 版本
   * @returns API 版本
   */
  static getApiVersion(): string {
    let apiVersion = AboutDeviceUtils.anonymizationArry.apiVersion;
    if (AboutDeviceUtils.isAnonymizationData() && !CheckEmptyUtils.checkStrIsEmpty(apiVersion)) {
      return apiVersion === 'hide' ? '' : apiVersion;
    }
    let version: string = '';
    let distributionOSApiName: string = deviceInfo.distributionOSApiName;
    let sdkApiVersion: number = deviceInfo.sdkApiVersion;
    let distributionOSReleaseType: string = deviceInfo.distributionOSReleaseType;
    LogUtil.showInfo(TAG,
      `getApiVersion, distributionOSApiName: ${distributionOSApiName}, sdkApiVersion: ${sdkApiVersion},
      distributionOSReleaseType: ${distributionOSReleaseType}`);
    // todo  distributionOSApiName为空导致API版本没展示 先注释 sdkMinorApiVersion sdkPatchApiVersion 在deviceInfo不存在
    // if (distributionOSApiName && sdkApiVersion) {
    let sdkMinorApiVersion: number | undefined = 0 //deviceInfo.sdkMinorApiVersion;
    let sdkPatchApiVersion: number | undefined = 0 //deviceInfo.sdkPatchApiVersion;
    let sdkInfo = deviceInfo.distributionOSVersion
    LogUtil.showInfo(TAG,
      `getApiVersion, sdkMinorApiVersion: ${sdkMinorApiVersion}, sdkPatchApiVersion: ${sdkPatchApiVersion}sdkInfo:${sdkInfo}`);
    // if (AboutDeviceUtils.isSdkVersionInvalid(sdkMinorApiVersion)
    //   || AboutDeviceUtils.isSdkVersionInvalid(sdkPatchApiVersion)
    //   || (sdkMinorApiVersion === 0 && sdkPatchApiVersion === 0)) {
    //   version = (`${distributionOSApiName}(${sdkApiVersion}) ${distributionOSReleaseType}`);
    // } else if (sdkPatchApiVersion === 0) {
    //   version = (`${distributionOSApiName}(${sdkApiVersion}.${sdkMinorApiVersion}) ${distributionOSReleaseType}`);
    // } else {
    //   version =
    //     (`${distributionOSApiName}(${sdkApiVersion}.${sdkMinorApiVersion}.${sdkPatchApiVersion}) ${distributionOSReleaseType}`);
    // }
    // }

    if (sdkInfo && sdkApiVersion) {
      const versionRegex = /-(\d+(\.\d+)*)\(/;
      sdkInfo = sdkInfo.match(versionRegex)?.[1] || '';
      version = (`${sdkInfo}(${sdkApiVersion})`)
    }
    return version.replace('Release', '').trim();
  }

  private static isSdkVersionInvalid(sdkVersion: number | undefined): boolean {
    return sdkVersion === undefined || sdkVersion < 0;
  }

  /**
   * OpenHarmony 版本
   */
  static getOpenHarmonyVersion(): string {
    let openHarmonyVersion = AboutDeviceUtils.anonymizationArry.openHarmonyVersion;
    /* instrument ignore if*/
    if (AboutDeviceUtils.isAnonymizationData() && !CheckEmptyUtils.checkStrIsEmpty(openHarmonyVersion)) {
      return openHarmonyVersion === 'hide' ? '' : openHarmonyVersion;
    }
    let version = SystemParamUtils.getSystemParam(CONST_OHOS_VERSION_CERTIFIED, '');
    /* instrument ignore if*/
    if (StringUtil.isEmpty(version)) {
      let osFullName: string = deviceInfo.osFullName;
      version = osFullName.replace('(', ' (').replace(')', ') ').trim();
    }
    return version;
  }

  /**
   * 获取运营商名称
   * @returns 运营商名称
   */
  static async getOperatorNameData(slotId: number): Promise<string | Resource> {
    if (SimUtils.isSimActivating(slotId) && await TelephonyRadioUtils.isRegStateInService(slotId)) {
      let operatorName: string = await TelephonyRadioUtils.getOperatorName(slotId);
      return StringUtil.isEmpty(operatorName) ? $r('app.string.unknown') : operatorName;
    }
    return $r('app.string.unknown');
  }

  /**
   * 获取信号强度（dBm）
   * @returns 信号强度（dBm）
   */
  static async getSignalStrengthDate(slotId: number): Promise<string | Resource> {
    /* instrument ignore if*/
    if (SimUtils.isSimActivating(slotId) && await TelephonyRadioUtils.isRegStateInService(slotId)) {
      let signalInformation = await TelephonyRadioUtils.getSignalInformation(slotId);
      let signalStrength = signalInformation[0]?.dBm;
      if (signalStrength) {
        return `${signalStrength} dBm`;
      }
    }
    return '0';
  }

  /**
   * 获取移动网络类型
   * @returns 移动网络类型
   */
  static async getMobileNetworkTypeDate(slotId: number): Promise<string | Resource> {
    if (SimUtils.isSimActivating(slotId)) {
      let signalInformation = await TelephonyRadioUtils.getSignalInformation(slotId);
      let signalType = signalInformation[0]?.signalType;
      if (signalType) {
        return AboutDeviceUtils.getNetworkType(signalType);
      }
    }
    return $r('app.string.unknown');
  }

  /**
   * 获取Cell ID
   * @returns Cell ID,
   */
  static async getCellId(slotId: number): Promise<string | Resource> {
    let cellId: string | ResourceStr = $r('app.string.unknown');
    if (SimUtils.isSimActivating(slotId)) {
      let cellInfo = await TelephonyRadioUtils.getCellInformation(slotId);
      let cellInfoData = cellInfo[0]?.data;
      if (typeof (cellInfoData as radio.GsmCellInformation)?.cellId === 'number') {
        cellId = String((cellInfoData as radio.GsmCellInformation)?.cellId);
      } else if (typeof (cellInfoData as radio.LteCellInformation)?.cgi === 'number') {
        cellId = String((cellInfoData as radio.LteCellInformation)?.cgi);
      } else if (typeof (cellInfoData as radio.TdscdmaCellInformation)?.cellId === 'number') {
        cellId = String((cellInfoData as radio.TdscdmaCellInformation)?.cellId);
      } else if (typeof (cellInfoData as radio.WcdmaCellInformation)?.cellId === 'number') {
        cellId = String((cellInfoData as radio.WcdmaCellInformation)?.cellId);
      }
    }
    return cellId;
  }

  /**
   * 获取短信中心号码
   * @returns 短信中心号码
   */
  static async getSmsCenterNumber(slotId: number): Promise<string | Resource> {
    if (SimUtils.isSimActivating(slotId)) {
      try {
        let sms = await import('@ohos.telephony.sms');
        let smsCenterNumber: string = await sms.default.getSmscAddr(slotId);
        return StringUtil.isEmpty(smsCenterNumber) ? $r('app.string.unknown') : smsCenterNumber;
      } catch (error) {
        LogUtil.showInfo(TAG, `getSmscAddr error: ${error?.message} code: ${error?.code}`);
      }
    }
    return $r('app.string.unknown');
  }

  /**
   * 获取MCC，MNC
   */
  static async getMccMncInfo(slotId: number): Promise<string | Resource> {
    if (SimUtils.isSimActivating(slotId)) {
      let networkState = await TelephonyRadioUtils.getNetworkState(slotId);
      if (networkState != undefined && await TelephonyRadioUtils.isRegStateInService(slotId, networkState) &&
      StringUtil.isNotEmpty(networkState?.plmnNumeric)) {
        let plmnNumeric = networkState.plmnNumeric;
        /* instrument ignore if*/
        if (plmnNumeric.length > MCC_LENGTH) {
          let mcc = plmnNumeric.substring(0, MCC_LENGTH);
          let mnc = plmnNumeric.substring(MCC_LENGTH);
          return `${mcc},${mnc}`;
        }
      }
    }
    return $r('app.string.unknown');
  }

  /**
   * 系统服务版本
   *
   * @returns 系统服务版本
   */
  static getSystemServiceVersion(): string {
    if (SystemParamUtil.getParam(BUILD_HIDE, 'false') === 'false') {
      LogUtil.showInfo(TAG, 'getSystemServiceVersion: productHide is false.');
      return AboutDeviceUtils.SYSTEM_SERVICE_VERSION_REAL;
    }

    if (AboutDeviceUtils.isAnonymizationData() && AboutDeviceUtils.anonymizationArry.systemServiceVersion === 'hide') {
      LogUtil.showInfo(TAG, 'systemServiceVersion is hide.');
      return '';
    }

    if (!AboutDeviceUtils.SYSTEM_SERVICE_VERSION) {
      LogUtil.showError(TAG, `getSystemServiceVersion failed, version is empty.`);
      return '';
    }
    return AboutDeviceUtils.SYSTEM_SERVICE_VERSION;
  }

  /**
   * 判断是否在关于本机里展示企业定制信息
   */
  static isDisplayEnterpriseCustomInfo(): boolean {
    let context: Context = AppStorage.get<Context>('pageContext') as Context;
    let enterpriseCustomizationInfo: string = 'false';
    enterpriseCustomizationInfo =
      SettingsDataUtils.getSettingsDataWithContext(context, COM_ENTERPRISE_ENTERPRISE_CUSTOMIZATION_INFO, 'false');
    LogUtil.showInfo(TAG,
      `isDisplayEnterpriseCustomInfo, enterpriseCustomizationInfo value: ${enterpriseCustomizationInfo}`);
    return enterpriseCustomizationInfo === 'true';
  }

  /**
   * 获取国测版本名称
   */
  static getItsecVersionName(): string {
    return SystemParamUtils.getSystemParam(ITSEC_EDITION_NUMBER_CCM_CONFIG, 'V1.0');
  }

  /**
   * 获取版本类型
   *
   */
  static getDeviceVersionType(): string {
    let versionType: string = ResourceUtil.getStringSync($r('app.string.version_type_professional'));
    const LICENSE_INFO_KEY: string = 'persist.license_manage_service.license_info';

    let licenseInfoStr: string = '';
    try {
      licenseInfoStr = systemParameterEnhance.getSync(LICENSE_INFO_KEY, '');
    } catch (err) {
      LogUtil.error(`${TAG} get getDeviceVersionType getSync fail, errCode: ${(err as BusinessError)?.code},
       errMsg: ${(err as BusinessError)?.message}`);
    }
    /* instrument ignore if*/
    if (licenseInfoStr.length === 0) {
      return versionType;
    }
    let licenseInfo: LicenseInfo | undefined = undefined;
    try {
      licenseInfo = JSON.parse(licenseInfoStr) as LicenseInfo;
    } catch (err) {
      LogUtil.error(`${TAG} get getDeviceVersionType parse fail, errCode: ${(err as BusinessError)?.code},
       errMsg: ${(err as BusinessError)?.message}`);
    }
    /* instrument ignore if*/
    if (licenseInfo?.licenseType === LicenseTypeEnum.ENTERPRISE) {
      versionType = ResourceUtil.getStringSync($r('app.string.version_type_enterprise'));
    }
    return versionType;
  }

  private static isBundleNameSupport(bundleName: string): boolean {
    try {
      bundleManager.getBundleInfoSync(bundleName, bundleManager.BundleFlag.GET_BUNDLE_INFO_DEFAULT);
      return true;
    } catch (err) {
      LogUtil.error(`${TAG} get ${bundleName} bundleInfo failed: ${err?.message}`);
    }
    return false;
  }

  /* instrument ignore next */
  private static async handleRequestDialogService(bundleName: string): Promise<number> {
    try {
      let want: Want = {
        bundleName: 'com.ohos.restores',
        abilityName: 'RestoresDialogServiceAbility',
        parameters: {
          restoresBundleName: bundleName,
        }
      };
      let context: common.UIAbilityContext = AbilityContextManager.getMainAbilityContext() as common.UIAbilityContext;
      if (context === undefined) {
        LogUtil.warn(`${TAG} settingsAbilityContext is undefined`);
        context = AppStorage.get<Context>('pageContext') as common.UIAbilityContext;
      }
      let result: dialogRequest.RequestResult = await context.requestDialogService(want);
      LogUtil.info(`${TAG} requestDialogService succeed, result = ${result?.want?.parameters?.resultCode ?? ''}`);
      return (result?.want?.parameters?.resultCode as number) ?? REQUEST_DIALOG_ERROR;
    } catch (err) {
      LogUtil.error(`${TAG} handleRequestDialogService failed: ${err?.message}`);
    }
    return REQUEST_DIALOG_ERROR;
  }

  static async openPCAccessoryManager(): Promise<void> {
    LogUtil.showInfo(TAG, 'on openPCAccessoryManager');
    HiSysEventUtil.reportDefaultBehaviorEventByUE(HiSysAboutDeviceEventGroup.DEVICE_INFO_ENTRY);
    let want: Want = {
      'bundleName': 'com.ohos.accessorymanager',
      'abilityName': 'DeviceManagerAbility',
    }
    AbilityUtils.startAbilityForResult(want, () => {
    });
  }

  /* instrument ignore next */
  static async getEID(): Promise<string> {
    if (!DeviceUtil.isSupportEsim()) {
      return StringUtil.EMPTY_STRING;
    }
    try {
      let result: string = await esim.getEid(EID_SLOT_NUMBER);
      LogUtil.info(`${TAG} get esim id success`);
      return result;
    } catch (err) {
      LogUtil.error(`${TAG} get esim id failed: ${err?.message}`);
    }
    return StringUtil.EMPTY_STRING;
  }

  /**
   * 是否显示处理器特性
   *
   * @returns 是否显示处理器特性
   */
  public static isShowProcessor(): boolean {
    let isShow: string = SystemParamUtil.getParam(PRODUCT_PROCESSOR_SHOW_PARAM_KEY, 'false');
    LogUtil.info(`${TAG} isShowProcessor ${isShow}`);
    return isShow === 'true';
  }

  /**
   * 获取CPU型号
   *
   * @returns CPU型号
   */
  public static getDeviceCPU(): string {
    if (AboutDeviceUtils.isAnonymizationData() &&
      !CheckEmptyUtils.checkStrIsEmpty(AboutDeviceUtils.anonymizationArry.processorVersion)) {
      LogUtil.info(`${TAG} getDeviceCPU anonymizationData: ${AboutDeviceUtils.anonymizationArry.processorVersion}`);
      return AboutDeviceUtils.anonymizationArry.processorVersion;
    } else {
      let processorVersion: string = SystemParamUtil.getParam(PRODUCT_PROCESSOR_NAME_PARAM_KEY, '');
      LogUtil.info(`${TAG} getDeviceCPU normal: ${processorVersion}`);
      return processorVersion;
    }
  }
}
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

import deviceInfo from '@ohos.deviceInfo';
import Display from '@ohos.display';
import resourceManager from '@ohos.resourceManager';
import { common } from '@kit.AbilityKit';
import { rpc } from '@kit.IPCKit';
import util from '@ohos.util';
import { BusinessError } from '@ohos.base';
import Settings from '@ohos.settings';
import systemParameterEnhance from '@ohos.systemParameterEnhance';
import taskpool from '@ohos.taskpool';
import { eSIM } from '@kit.TelephonyKit';
import { LogUtil } from './LogUtil';
import { SettingsDataUtils } from './SettingsDataUtils';
import { SatelliteHardwareUtils } from './SatelliteHardwareUtils';
import { SUPPORT_SIDEBAR_BLUR } from './Consts';
import { SystemParamUtil } from './SystemParamUtil';
import { power } from '@kit.BasicServicesKit';
const DEVICE_TYPE_DEFAULT = 'default';
const DEVICE_TYPE_PHONE = 'phone';
const DEVICE_TYPE_PC = '2in1';
const DEVICE_TYPE_PAD = 'tablet';
const DEVICE_TYPE_TV = 'tv';
const DEVICE_TYPE_WEARABLE = 'wearable';
const DEVICE_TYPE_EMULATOR = 'emulator';
const NFC_ANT_LOCATION: string = 'const.nfc.nfc_ant_location';
const TAG: string = 'BaseUtils';
const UNICODE: string = 'utf-8';
const SATELLITE_SUPPORT_TYPE: string = 'const.telephony.satellite.support_type';
const SATELLITE_SUPPORTED: string = 'const.telephony.satellite.supported';
const SATELLITE_SWITCH: string = 'satellite_mode_switch';
const SATELLITE_CACTUS: number = 3;
const PRODUCT_CPU_ABI_LIST_X86: string = 'x86_64';
const DEVICE_PROVISIONED_PARAM: string = 'device_provisioned';
const DEVICE_PROVISIONED: string = '1';
const DEVICE_UNPROVISIONED: string = '0';
const CAR_SATELLITE_ENABLE_KEY = 'car_satellite_enable';
const CCM_PENG_LAI_LIGHT_WEIGHT_MODE: string = 'const.penglai.feature_enable';
const DISPLAY_ID_MAX = 999;
const DISPLAY_ID_MIN = 0;
const DEFAULT_SLOT_ID = 1;

export enum SatelliteTypes {
  NONE = 0b00000000, // 不支持
  PALACE = 0b00000001, // 故宫
  YIHEYUAN = 0b00000010, // 颐和园
  DANDELION = 0b00000100, // 蒲公英
  CACTUS = 0b00001000, // 仙人掌
  TRIPARTITE_HYACINTH = 0b00010000, // 三方风信子
  SELF_HYACINTH = 0b00100000, // 自研风信子
}

export enum FoldPhoneTypeValue {
  /**
   * 无效值
   */
  INVALID_VALUE = -1,
  /**
   * 直板机
   */
  STRAIGHT = 0,
  /**
   * 大折（内折） X5
   */
  LARGE_FOLD = 1,
  /**
   * 小折叠（只有内折） pocket
   */
  SMALL_FOLD = 2,
  /**
   * 外折 XS2
   */
  EXTERNAL_FOLD = 3,
  /**
   * 扩展新形态
   */
  EXPANDING_NEX_FORMS = 4,
  /**
   * super fold
   */
  EXPANDING_SUPER_FOLD = 5,
  /**
   * 三折叠 GRL
   */
  THREE_FOLD_EXPANDING = 6,
}

enum FoldStatus {
  FOLD_STATUS_FOLDED = 2,
  FOLD_STATUS_FOLDED_WITH_SECOND_EXPAND = 12,
  FOLD_STATES_FOLDED_WITH_SECOND_HALF_FOLDED = 22,
  FOLD_STATUS_EXPANDED_WITH_SECOND_EXPANDED = 11,
  FOLD_STATUS_EXPANDED_WITH_SECOND_HALF_FOLDED = 21,
  FOLD_STATUS_HALF_FOLDED_WITH_SECOND_EXPANDED = 13,
  FOLD_STATUS_HALF_FOLDED_WITH_SECOND_HALF_FOLDED = 23,
}

/**
 * 折叠机状态
 */
export enum DeviceState {
  FOLDED_STATE = 0,
  EXPAND_STATE = 1,
  DEFAULT_STATE = FOLDED_STATE
}

@Concurrent
function isFoldableSync(): boolean {
  try {
    return Display.isFoldable();
  } catch (err) {
    LogUtil.showError('BaseUtils', `getDeviceFodable failed. error: ${err?.code} ${err?.message}`);
    return false;
  }
}

@Concurrent
function getEsimSupportSync(slotId: number): boolean {
  try {
    return eSIM.isSupported(slotId);
  } catch (err) {
    LogUtil.showError('BaseUtils', `getEsimSupport failed. error: ${err?.code} ${err?.message}`);
    return false;
  }
}

export class DeviceUtil {
  public static deviceType: string = deviceInfo.deviceType;

  public static productMode: string = deviceInfo.productModel;

  public static isDeviceFoldable: boolean = false;

  public static isEsimAvailable: boolean = false;

  private static sFoldProductTypeValue: FoldPhoneTypeValue = FoldPhoneTypeValue.INVALID_VALUE;

  private static is2In1DeviceStatus: boolean | undefined;

  public static abiList: string = deviceInfo.abiList;

  public static isBetaVersion: boolean = SystemParamUtil.getParam('const.logsystem.versiontype', '') === 'beta';

  static {
    DeviceUtil.getDeviceFodable().then((isDeviceFoldable: boolean) => {
      DeviceUtil.isDeviceFoldable = isDeviceFoldable;
    });

    DeviceUtil.getEsimSupport().then((isSupport: boolean) => {
      DeviceUtil.isEsimAvailable = isSupport;
    });
  }

  /**
   * Check whether the current device is a mobile phone.
   *
   * @return true: Phone  false: Not a phone
   */
  static isDevicePhone(): boolean {
    return DeviceUtil.deviceType === DEVICE_TYPE_PHONE;
    // 开发板 DeviceUtil.deviceType 返回的是default
    // return [DEVICE_TYPE_PHONE, DEVICE_TYPE_DEFAULT].includes(DeviceUtil.deviceType);
  }

  static isDevicePc(): boolean {
    return DeviceUtil.deviceType === DEVICE_TYPE_PC;
  }

  static isDevicePad(): boolean {
    return DeviceUtil.deviceType === DEVICE_TYPE_PAD;
  }

  static isDeviceTv(): boolean {
    return DeviceUtil.deviceType === DEVICE_TYPE_TV;
  }

  static isWearable(): boolean {
    return DeviceUtil.deviceType === DEVICE_TYPE_WEARABLE;
  }

  static isDeviceEmulator(): boolean {
    return DeviceUtil.productMode === DEVICE_TYPE_EMULATOR;
  }

  /**
   * 是否支持eSIM
   */
  static isSupportEsim(): boolean {
    return DeviceUtil.isEsimAvailable;
  }

  /**
   * 是否pad 2in1下的pad模式
   */
  static is2In1DevicePadType(): boolean {
    return DeviceUtil.is2In1Device() && !DeviceUtil.isPcMode();
  }

  /**
   * 是否pad 2in1下的pc模式
   */
  public static is2In1DevicePcType(): boolean {
    return DeviceUtil.is2In1Device() && DeviceUtil.isPcMode();
  }

  /**
   * 是否为 2in1 设备
   */
  static is2In1Device(): boolean {
    if (DeviceUtil.is2In1DeviceStatus !== undefined) {
      return DeviceUtil.is2In1DeviceStatus;
    }
    try {
      DeviceUtil.is2In1DeviceStatus =
        systemParameterEnhance.getSync('const.window.support_window_pcmode_switch', 'false') === 'true';
      LogUtil.showInfo(TAG, `suppport windwo pcmode switch: ${DeviceUtil.is2In1DeviceStatus}`);
      return DeviceUtil.is2In1DeviceStatus;
    } catch (e) {
      LogUtil.showError(TAG, 'Get switch supportWindowPcModeSwitch failed');
      return false;
    }
  }

  /**
   * 查询系统参数，判断当前是否处于pc模式
   * true: pc模式
   * false: pad模式
   */
  static isPcMode(): boolean {
    try {
      let res = systemParameterEnhance.getSync('persist.sceneboard.ispcmode', 'false');
      LogUtil.showInfo(TAG, `ispcmode, res: ${res}`);
      return res === 'true';
    } catch (e) {
      LogUtil.showError(TAG, `Get pc mode switch error: ${e?.message} - ${e?.code}`);
    }
    return false;
  }

  static isX86Environment(): boolean {
    return DeviceUtil.abiList === PRODUCT_CPU_ABI_LIST_X86;
  }

  static isDeviceDefaultSplit(): boolean {
    // 小折叠
    if (DeviceUtil.isSmallFoldProduct()) {
      return false;
    }
    return DeviceUtil.isDevicePad() || DeviceUtil.isFoldExpand() || DeviceUtil.isDevicePc();
  }

  /**
   * 是否折叠屏
   *
   * @returns boolean true: 是折叠屏, false: 不是折叠屏
   */
  static isFoldable(): boolean {
    return DeviceUtil.isDeviceFoldable;
  }

  /**
   * 是否折叠屏展开状态
   *
   * @return boolean true: 是折叠屏展开态, false: 不是折叠屏展开态
   */
  static isFoldExpand(): boolean {
    return DeviceUtil.isDeviceFoldable && Display.getFoldStatus() === Display.FoldStatus.FOLD_STATUS_EXPANDED;
  }

  /**
   * 是否折叠屏折叠状态
   *
   * @return boolean true: 是折叠屏折叠态, false: 不是折叠屏折叠态
   */
  static isFoldFold(): boolean {
    return DeviceUtil.isDeviceFoldable && Display.getFoldStatus() === Display.FoldStatus.FOLD_STATUS_FOLDED;
  }

  /**
   * 是否折叠屏半折叠状态
   *
   * @return boolean true: 是折叠屏半折叠态, false: 不是折叠屏半折叠态
   */
  static isFoldHalfFold(): boolean {
    return DeviceUtil.isDeviceFoldable && Display.getFoldStatus() === Display.FoldStatus.FOLD_STATUS_HALF_FOLDED;
  }

  /**
   * 当前设备是否为竖屏
   *
   * @return true: 竖屏  false: 横屏
   */
  static isDevicePortrait(): boolean {
    try {
      const orientation: Display.Orientation = Display.getDefaultDisplaySync().orientation;
      if (orientation === Display.Orientation.LANDSCAPE || orientation === Display.Orientation.LANDSCAPE_INVERTED) {
        return false;
      }
    } catch (err) {
      LogUtil.error(`isDevicePortrait failed. error: ${err?.code} ${err?.message}`);
    }
    return true;
  }

  /**
   * 获取当前屏幕显示方向
   *
   * @return 屏幕显示方向
   */
  static getDisplayOrientation(): Display.Orientation {
    try {
      return Display.getDefaultDisplaySync().orientation;
    } catch (e) {
      LogUtil.error(`getDisplayOrientation failed. error: ${e?.code}`);
    }
    return Display.Orientation.PORTRAIT;
  }

  private static async getDeviceFodable(): Promise<boolean> {
    const task = new taskpool.Task(isFoldableSync);
    return await taskpool.execute(task, taskpool.Priority.MEDIUM) as boolean;
  }

  private static async getEsimSupport(): Promise<boolean> {
    const task = new taskpool.Task(getEsimSupportSync, DEFAULT_SLOT_ID);
    return await taskpool.execute(task, taskpool.Priority.MEDIUM) as boolean;
  }

  /**
   * 是否是小内折产品 Lem
   *
   * @returns boolean 如果为小折叠产品返回true
   */
  static isSmallFoldProduct(): boolean {
    // 小折叠 + VDE
    return [
      FoldPhoneTypeValue.SMALL_FOLD,
      FoldPhoneTypeValue.EXPANDING_NEX_FORMS,
    ].includes(DeviceUtil.getFoldProductType());
  }

  /**
   * 是否是新形态小折叠 VDE
   *
   * @returns boolean 如果为新形态小折叠产品返回true
   */
  static isNexFormsProduct(): boolean {
    return FoldPhoneTypeValue.EXPANDING_NEX_FORMS === DeviceUtil.getFoldProductType();
  }

  /**
   * 是否是super fold
   *
   * @returns boolean 如果为super fold返回true
   */
  static isSuperFoldProduct(): boolean {
    return FoldPhoneTypeValue.EXPANDING_SUPER_FOLD === DeviceUtil.getFoldProductType();
  }

  /**
   * 通过芯片位置判断是否是VED
   *
   * @returns boolean 如果是芯片位置较低的VED返回true
   */
  static isNfcAntLocationLow(): boolean {
    // VDE
    try {
      let nfcAntLocation: string = systemParameterEnhance.getSync(NFC_ANT_LOCATION, '0');
      LogUtil.showInfo(TAG, `isNfcAntLocationLow: ${nfcAntLocation === '1' ? 'lower' : 'upper'}`);
      return nfcAntLocation === '1';
    } catch (err) {
      LogUtil.showError(TAG, `getNfcAntLocation: isNfcAntLocationLow failed. error: ${err?.code} ${err?.message}`);
    }
    return false;
  }

  /**
   * 是否是小内折产品 lem，不包含新形态小折叠
   *
   * @returns boolean 如果为小折叠产品返回true
   */
  static isOnlySmallFoldProduct(): boolean {
    return FoldPhoneTypeValue.SMALL_FOLD === DeviceUtil.getFoldProductType();
  }

  /**
   * 是否是大内折产品 X5
   *
   * @returns boolean
   */
  static isLargeInFoldProduct(): boolean {
    return FoldPhoneTypeValue.LARGE_FOLD === DeviceUtil.getFoldProductType();
  }

  /**
   * 是否三折叠屏 GRL
   *
   * @returns boolean true: 是三折叠屏, false: 不是三折叠屏
   */
  static isThreeFoldable(): boolean {
    return FoldPhoneTypeValue.THREE_FOLD_EXPANDING === DeviceUtil.getFoldProductType();
  }

  /**
   * 三折叠屏是否是G态
   *
   * @returns boolean true: 是G态, false: 不是G态
   */
  static isThreeFoldableGmodel(): boolean {
    return DeviceUtil.isDeviceFoldable &&
      (Display.getFoldStatus().valueOf() === FoldStatus.FOLD_STATUS_EXPANDED_WITH_SECOND_EXPANDED ||
        Display.getFoldStatus().valueOf() === FoldStatus.FOLD_STATUS_EXPANDED_WITH_SECOND_HALF_FOLDED ||
        Display.getFoldStatus().valueOf() === FoldStatus.FOLD_STATUS_HALF_FOLDED_WITH_SECOND_EXPANDED ||
        Display.getFoldStatus().valueOf() === FoldStatus.FOLD_STATUS_HALF_FOLDED_WITH_SECOND_HALF_FOLDED);
  }

  /**
   * 三折叠屏是否是N态和F态
   *
   * @returns boolean true: 是N或者F态, false: 不是这两种状态
   */
  static isThreeFoldableSingleScreenModel(): boolean {
    let foldStatusValue = Display.getFoldStatus().valueOf();
    const foldStatusArr = [FoldStatus.FOLD_STATUS_FOLDED,
      FoldStatus.FOLD_STATUS_FOLDED_WITH_SECOND_EXPAND, FoldStatus.FOLD_STATES_FOLDED_WITH_SECOND_HALF_FOLDED];
    return DeviceUtil.isDeviceFoldable && foldStatusArr.includes(foldStatusValue);
  }

  /**
   * 获取代表产品形态的配置项值
   *
   * @returns FoldPhoneTypeValue
   */
  static getFoldProductType(): number {
    if (DeviceUtil.sFoldProductTypeValue !== FoldPhoneTypeValue.INVALID_VALUE) {
      return DeviceUtil.sFoldProductTypeValue;
    }
    try {
      let productValue: string = systemParameterEnhance.getSync('const.window.foldscreen.type', '0,0,0,0');
      LogUtil.info(`${TAG} productValue: ${productValue}`);
      const result: string[] = productValue?.split(',');
      if (result.length > 0) {
        let res = Number.parseInt(result[0]);
        return res;
      }
    } catch (err) {
      LogUtil.showError(TAG, `getFoldProductType: isDevicePortrait failed. error: ${err?.code} ${err?.message}`);
    }
    return FoldPhoneTypeValue.INVALID_VALUE;
  }

  /**
   * 检查设备是否是支持侧边栏模糊
   *
   * @returns 设备是否支持侧边栏模糊
   */
  public static isSupportSidebarBlur(): boolean {
    let supportSidebarBlur: boolean = SystemParamUtil.getParam(SUPPORT_SIDEBAR_BLUR, 'true') === 'true'
    LogUtil.showInfo(TAG, `isSupportSidebarBlur: ${supportSidebarBlur}`);
    return supportSidebarBlur;
  }

  /**
   * 检查设备是否有接入其他外接设备
   *
   * @returns 设备是否接入了其他设备
   */
  public static async isConnectDevices(): Promise<boolean> {
    try {
      let displays = await Display.getAllDisplays();
      let connectDeviceCount = 
        displays.filter((display) => display.id >= DISPLAY_ID_MIN && display.id < DISPLAY_ID_MAX).length;
      LogUtil.showInfo(TAG, `current connect device : ${connectDeviceCount}`);
      return connectDeviceCount > 1;
    } catch (err) {
      LogUtil.showError(TAG, `get all displays error: ${err?.code}`);
      return false;
    }
  }
}

export class JsonUtil {
  /**
   * 获取指定JSON文件的对象
   * @param context 上下文
   */
  public static getStringByFileAsync(resourceManager: resourceManager.ResourceManager | undefined,
                                     fileName: string): Promise<string> {
    return new Promise((resolve, reject) => {
      if (!resourceManager || !fileName) {
        LogUtil.error(`getFileContent failed. resourceManager or fileName is null.`);
        reject();
        return;
      }
      try {
        resourceManager.getRawFileContent(fileName).then((value) => {
          let content = util.TextDecoder.create(UNICODE).decodeWithStream(value);
          resolve(content);
        }).catch((err: BusinessError) => {
          LogUtil.error(`${TAG} getFileContent of ${fileName} failed. ${err?.code} ${err?.message}`);
          reject(err);
        });
      } catch (jsonError) {
        LogUtil.error(`${TAG} JSON parse error:${jsonError?.code} ${jsonError?.message}`);
        reject();
      }
    });
  }
}

export class DeviceStateUtils {
  /**
   * 设备是否已激活
   *
   * @returns true:已激活，false:未激活
   */
  static isDeviceProvisioned(): boolean {
    let deviceProvisioned: String =
      SettingsDataUtils.getSettingsData(DEVICE_PROVISIONED_PARAM, DEVICE_UNPROVISIONED) as String;
    LogUtil.showInfo(TAG, `device provisioned state : ${deviceProvisioned}`);
    return deviceProvisioned === DEVICE_PROVISIONED;
  }
}

const UUID_TEMPLATE: string = 'xxxxxxxx-xxxx-4xxx-yxxx-xxxxxxxxxxxx';

const UUID_LENGTH: number = 16;

/**
 * 卫星网络类
 *
 * @since 2024-4-16
 */
export class SatelliteUtils {
  /**
   * 是否支持仙人掌或北斗卫星
   * 仙人掌和蒲公英都是天通系列，北斗就是故宫和颐和园，颐和园为移动定制，故宫的入口在畅连
   * 北斗属于畅连，支持故宫
   * 仙人掌需要判断硬件是否支持
   * @returns boolean true：支持  false：不支持
   */
  static isSupport(): boolean {
    try {
      // 判断是否支持车机卫星通信
      let supportCarSatellite: boolean = SatelliteUtils.isSupportCarSatellite();
      if (supportCarSatellite) {
        LogUtil.info(`SatelliteUtils support CarSatellite`);
        return true;
      }

      // 判断卫星通信总开关
      let supportSatelliteConfig: string = systemParameterEnhance.getSync(SATELLITE_SUPPORTED, '1');
      if (supportSatelliteConfig !== '1') {
        LogUtil.info(`SatelliteUtils not support Satellite`);
        return false;
      }

      let supportType: string = systemParameterEnhance.getSync(SATELLITE_SUPPORT_TYPE, '1');

      // 判断是否支持故宫
      let supportPalace: boolean = SatelliteUtils.isSupportMessage();

      // 判断是否支持颐和园
      let supportSummerPalace: boolean = ((Number(supportType) & SatelliteTypes.YIHEYUAN) === SatelliteTypes.YIHEYUAN);

      // 判断是否支持蒲公英
      let supportDandelion: boolean = (Number(supportType) & SatelliteTypes.DANDELION) === SatelliteTypes.DANDELION;

      // 判断是否支持仙人掌
      let supportCactus: boolean = (Number(supportType) & SatelliteTypes.CACTUS) === SatelliteTypes.CACTUS;

      // 判断是否支持三方风信子
      let supportTripartiteHyacinth: boolean = ((Number(supportType) & SatelliteTypes.TRIPARTITE_HYACINTH) ===
      SatelliteTypes.TRIPARTITE_HYACINTH);

      // 判断是否支持自研风信子
      let supportSelfHyacinth: boolean = ((Number(supportType) & SatelliteTypes.SELF_HYACINTH) ===
      SatelliteTypes.SELF_HYACINTH);

      LogUtil.info(`SatelliteUtils Type:${supportType} Palace:${supportPalace} SummerPalace:${supportSummerPalace} Dandelion:
      ${supportDandelion} Cactus:${supportCactus} TripartiteHyacinth:${supportTripartiteHyacinth} SelfHyacinth:${supportSelfHyacinth}`);
      const supportSatellite: boolean = supportPalace || supportSummerPalace || supportDandelion ||
        supportTripartiteHyacinth || supportSelfHyacinth;
      if (supportSatellite) {
        return true;
      }

      return supportCactus && SatelliteHardwareUtils.isSupportHard(SATELLITE_CACTUS);
    } catch (err) {
      LogUtil.error(`SatelliteUtils get support failed. error: ${err?.code} ${err?.message}`);
      return false;
    }
  }

  /**
   * 是否支持北斗卫星
   * 北斗就是故宫和颐和园，故宫的入口在畅连
   * 北斗属于畅连，支持故宫
   * @returns boolean true：支持  false：不支持
   */
  static isSupportMessage(): boolean {
    try {
      let supportType: string = systemParameterEnhance.getSync(SATELLITE_SUPPORT_TYPE, '1');
      let isSupportMessageConfig = systemParameterEnhance.getSync('const.meetime.support.message', 'true');
      let isSupportMessage = isSupportMessageConfig === 'true';
      let supportPalace: boolean = ((Number(supportType) & SatelliteTypes.PALACE) === SatelliteTypes.PALACE) &&
        isSupportMessage;

      LogUtil.showInfo(TAG, `SatelliteUtils Type: Palace:${supportPalace}`);

      return supportPalace;
    } catch (err) {
      LogUtil.showError(TAG, `SatelliteUtils isSupportMessage failed. error: ${err?.code} ${err?.message}`);
      return false;
    }
  }

  /**
   * 卫星通信是否开启
   * @returns boolean true：开启  false：关闭
   */
  static isCommunicationOpen(): boolean {
    try {
      // 0--关闭，1---开启
      let communicationSwitch: string = SettingsDataUtils.getSettingsData(SATELLITE_SWITCH, '0');
      LogUtil.info(`SatelliteUtils communicationSwitch: ${communicationSwitch}`);
      return Number(communicationSwitch) === 1 && SatelliteUtils.isSupport();
    } catch (err) {
      LogUtil.error(`SatelliteUtils get switch failed. error: ${err?.code} ${err?.message}`);
      return false;
    }
  }

  /**
   * 车机卫星通信是否开启
   * @returns boolean true：开启  false：关闭
   */
  static isSupportCarSatellite(): boolean {
    try {
      // 0--关闭，1---开启
      let carSatelliteSwitch: string = SettingsDataUtils.getSettingsData(CAR_SATELLITE_ENABLE_KEY, '0');
      LogUtil.info(`SatelliteUtils carSatelliteSwitch: ${carSatelliteSwitch}`);
      return Number(carSatelliteSwitch) === 1;
    } catch (err) {
      LogUtil.error(`SatelliteUtils carSatelliteSwitch failed. error: ${err?.code}`);
      return false;
    }
  }
}

/**
 * 唯一ID生成器，触发刷新
 */
export class MenuUUID {
  static uuid(): string {
    let d = new Date().getTime();
    let regex = new RegExp('[xy]', 'g');
    const uuid = UUID_TEMPLATE.replace(regex, (c) => {
      const r = (d + Math.random() * UUID_LENGTH) % UUID_LENGTH | 0;
      d = Math.floor(d / UUID_LENGTH);
      return (c == 'x' ? r : (r & 0x3 | 0x8)).toString(UUID_LENGTH);
    });
    return uuid;
  }
}

/**
 * hover 延时显示工具栏的时间
 */
const TIPS_APPEAR_DELAY: number = 750;

/**
 * hover 工具类
 */
export class TipsHelper {
  private static tipShowTimeOut: number = -1;

  /**
   * 延时显示tips
   * @param isHover 是否是hover状态：true是
   * @param onHover hover时的处理回调
   */
  public static timeOutForOnHover(isHover: boolean, onHover: (isHover: boolean)=> void) {
    clearTimeout(TipsHelper.tipShowTimeOut);
    if (isHover) {
      TipsHelper.tipShowTimeOut = setTimeout(() => {
        onHover && onHover(isHover);
        clearTimeout(TipsHelper.tipShowTimeOut);
      }, TIPS_APPEAR_DELAY);
    } else {
      onHover && onHover(isHover);
    }
  }
}

/**
 * 蓬莱模式通用工具类
 */
export class PenglaiUtil {
  /**
   * 蓬莱模式是否打开
   * @returns boolean true:支持 false：不支持
   */
  public static isPengLaiModeOpen(): boolean {
    let pengLaiBasicMode: boolean = PenglaiUtil.isPengLaiBasicModeOpen();
    if (pengLaiBasicMode) {
      return true;
    }
    return PenglaiUtil.isOutdoorPowerMode();
  }

  /**
   * 蓬莱模式一是否打开
   * @returns boolean true:支持 false：不支持
   */
  public static isPengLaiBasicModeOpen(): boolean {
    return SystemParamUtil.getParam('ohos.boot.minisys.mode', '') === 'penglai';
  }

  /**
   * 是否户外出行省电状态
   * @returns boolean true:是 false：否
   */
  public static isOutdoorPowerMode(): boolean {
    const powerMode: power.DevicePowerMode = power.getPowerMode();
    LogUtil.showInfo(TAG, `isOutdoorPowerMode. powerMode:${powerMode}`);
    return powerMode === power.DevicePowerMode.MODE_CUSTOM_POWER_SAVE;
  }

  /**
   * 蓬莱模式是否支持
   * @returns boolean true:支持 false：不支持
   */
  public static isPengLaiModeSupported(): boolean {
    let isPengLaiLightWeightModeOpen: boolean =
      SystemParamUtil.getParam(CCM_PENG_LAI_LIGHT_WEIGHT_MODE, '') === 'true';
    LogUtil.info(`${TAG} isPengLaiModeSupported ${isPengLaiLightWeightModeOpen}`);
    return isPengLaiLightWeightModeOpen;
  }
}

/**
 * 拉起外部系统弹框工具类
 */
export class DialogUtil {
  // 拉起系统弹窗的通用模板
  public static openSystemDialog(context: Context, bundleName: string, abilityName: string,
    parameter?: Record<string, Object>) {
    let newWant: Want = {
      bundleName: 'com.ohos.sceneboard',
      abilityName: 'com.ohos.sceneboard.systemdialog'
    }
    let connectOption: common.ConnectOptions = {
      onConnect(elementName, remote) {
        let option = new rpc.MessageOption();
        let data = rpc.MessageSequence.create();
        let reply = rpc.MessageSequence.create();
        // sysDialogZOrder = 2 显示在锁屏界面上
        if (!parameter) {
          parameter = {
            'ability.want.params.uiExtensionType': 'sysDialog/common',
            'sysDialogZOrder': 1
          }
        }
        LogUtil.showInfo(TAG, 'param ${JSON.stringify(parameter)}');
        data.writeInt(3);
        data.writeString('bundleName');
        // 业务方的bundleName
        data.writeString(bundleName);
        data.writeString('abilityName');
        // 业务方的abilityName
        data.writeString(abilityName);
        data.writeString('parameters');
        data.writeString(JSON.stringify(parameter));

        remote.sendMessageRequest(1, data, reply, option)
          .then(result => {
            LogUtil.showInfo(TAG, `Start System Dialog success ${result.errCode} ${result.reply.readInt()}`);
          })
          .catch((error: BusinessError) => {
            LogUtil.showError(TAG, `Start System Dialog error code:${error.code},message:${error.message}`);
          })
          .finally(() => {
            data.reclaim();
            reply.reclaim();
          });
      },
      onDisconnect(elementName) {
        LogUtil.showInfo(TAG, `DisConnect from System Dialog,elementName: ${elementName.bundleName}`);
      },
      onFailed(code) {
        LogUtil.showError(TAG, `Connect to System Dialog Failed,code: ${code}`);
      }
    }
    try {
      let uiContext: common.UIAbilityContext = context as common.UIAbilityContext;
      const connectionId = uiContext?.connectServiceExtensionAbility(newWant, connectOption);
    } catch (e) {
      LogUtil.showError(TAG, `Connect to System Dialog Failed,code: ${e?.code}`);
    }
  }
}
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

import Settings from '@ohos.settings';
import display from '@ohos.display';
import call from '@ohos.telephony.call';
import sim from '@ohos.telephony.sim';
import deviceInfo from '@ohos.deviceInfo';
import hgmnapi from '@ohos.libhgmnapi.z.so';
import osAccount from '@ohos.account.osAccount';
import systemParameterEnhance from '@ohos.systemParameterEnhance';
import fs from '@ohos.file.fs';
import bundleManager from '@ohos.bundle.bundleManager';
// import infosec from '@hms.hiviewdfx.infosec';
// import netQuality from '@hms.networkboost.netquality';
import systemParameter from '@ohos.systemparameter';
// import fusionConnectivityExt from '@hms.fusionConnectivityExt';
import { sensor } from '@kit.SensorServiceKit';
import { camera } from '@kit.CameraKit';
// import accountService from '@hms.core.account.extendservice';
import { VibratorUtil } from '@ohos/settings.common/src/main/ets/utils/VibratorUtil';
import { AbilityContextManager } from '@ohos/settings.common/src/main/ets/ability/AbilityContextManager';
import { LogUtil } from '@ohos/settings.common/src/main/ets/utils/LogUtil';
import { SimUtils } from '@ohos/settings.common/src/main/ets/utils/SimUtils';
import { AccountUtil } from '@ohos/settings.common/src/main/ets/utils/AccountUtil';
import { SystemParamUtil } from '@ohos/settings.common/src/main/ets/utils/SystemParamUtil';
import { SettingsDataUtils } from '@ohos/settings.common/src/main/ets/utils/SettingsDataUtils';
import { DeviceUtil } from '@ohos/settings.common/src/main/ets/utils/BaseUtils';
import { CapabilitySupportUtils } from '@ohos/settings.common/src/main/ets/utils/CapabilitySupportUtils';
import { PenglaiUtil } from '@ohos/settings.common/src/main/ets/utils/BaseUtils';
import { SystemParamUtils } from '@ohos/settings.common/src/main/ets/screenReader/utils/SystemParamUtils';
import { CheckEmptyUtils } from '@ohos/settings.common/src/main/ets/utils/CheckEmptyUtils';
import { DisplayUtils } from '@ohos/settings.common/src/main/ets/utils/DisplayUtils';

const TAG = 'SearchCheckUtil';
const DE_FEATURE_COLORMODE = 11;
const DE_FEATURE_3D_COLOR_TEMPERATURE = 18;
const DE_FEATURE_EYE_PROTECT_WITHGMP = 29;
const DE_LOW_FREQUENCY_FLASH_KEY = 32;
const DE_FEATURE_READING_GLOBAL = 34;
const DE_SWING_EYE = 50;
const DE_HDR_IMAGE_KEY = 51;
const SCREEN_ID: number = 0;
const SUPPORT_DYNAMIC_POLICY: number = -1;
const REFRESH_RATE_INVALID: number = 0;
const FINGERPRINT_SENSOR_TYPE: string = 'sensorType';
const UNDER_SCREEN_SENSOR: string = 'UNDER_SCREEN_SENSOR';
const OUT_OF_SCREEN_SENSOR: string = 'OUT_OF_SCREEN_SENSOR';
const FINGERPRINT_CRED_TYPE: number = 4;
const FINGERPRINT_CRED_KEY: [number] = [5];
const SIMCOUNT: number = 0;
const KEY_AUTO_TIMEZONE: string = 'auto_timezone'; //时区开关key
const EBOOK_SWITCH_KEY: string = 'settings.display.ebook_switch';
const EBOOK_SWITCH_ENABLED: string = '1';
const EBOOK_SWITCH_DISABLED: string = '0';
const EYE_MODE_KEY: string = 'settings.display.eye_comfort_mode';
const EYE_MODE_DEFAULT: string = '0';
const EYE_MODE_FULL: string = '1';
const EYE_MODE_TIME: string = '2';
const EYE_MODE_SUN: string = '3';
const EYE_ENABLE_KEY: string = 'settings.eyeshield.enable';
const INTELLIGENT_SCENE_ENABLE_CCM_CONFIG = 'const.intelligentscene.enable';
const ITSEC_EDITION_NUMBER_CCM_CONFIG = 'persist.pc_security.itsec_edition_number';
const EYE_ENABLE_ENABLED: string = '1';
const EYE_ENABLE_DISABLED: string = '0';
const SETTINGS_UI_APPEARANCE_DARK_MODE: string = 'settings.uiappearance.darkmode_mode';
const DEFAULT_DARK_MODE_STATE: string = '0';
const DARK_MODE_TIMED_ON: string = '2';
const DISTURB_CHOSE_ALL: string = '2';
const COM_ENTERPRISE_ENTERPRISE_CUSTOMIZATION_INFO: string = 'com.enterprise.enterprise_customization_info';
export const FOCUS_MODE_CALL_MESSAGE_POLICY: string = 'focus_mode_call_message_policy'; //来电策略
const SUPPORT_SHOW_PC_TOUCHPAD_PAGE: string = 'const.settings.use_new_touchpad_page';
enum SlotCount {
  slotIdOne = 0,
  slotIdTwo
}
const SETTINGS_DISPLAY_HDR_PIC_SWITCH: string = 'settings.display.hdr_picture_switch';
const BIONIC_VISION_SWITCH_DISABLED: string = '0';
const BIONIC_VISION_SWITCH_ENABLED: string = '1';
const INFORMATION_HIDE: string = 'const.product.hide.settings';
const API_VERSION_INDEX: number = 7;
const OPEN_HARMONY_INDEX: number = 8;
const HIDE_ITEM: string = 'hide';
// 虚拟内存CCM配置单位为MB，大于10GB时需要显示
const SHOW_VIRTUAL_MEMORY_THRESHOLD = 10240;
const LICENSE_ENABLE_CCM_CONFIG = 'const.pc_security.license_enable';
enum TouchpadSupportFeature { // 二进制格式存储触控板支持的特性
  PRESS_SHOCK = 1, // 振感、压力调节
  KNUCKLE_GESTURE = 2, // 指关节截图/录屏手势
  BRIGHTNESS_VOLUME = 4 // 音量/亮度调节手势
}

interface sensorInfoObj {
  type: string
}

export class SearchCheckUtil {
  private static userIdentityManager: osAccount.UserIdentityManager = new osAccount.UserIdentityManager();
  private static userAuth = new osAccount.UserAuth();

  static async hasPrivacyPassword(): Promise<boolean> {
    try {
      let credentials = await new osAccount.UserIdentityManager().getAuthInfo(osAccount.AuthType.PRIVATE_PIN);
      return credentials.length > 0;
    } catch (err) {
      LogUtil.error(`${TAG} hasPrivacyPassword error ${err?.code}`);
    }
    return false;
  }

  static async oldPasswordActive(): Promise<boolean> {
    try {
      let credentials = await new osAccount.UserIdentityManager().getAuthInfo(osAccount.AuthType.PIN);
      for (let i = 0; i < credentials.length; i++) {
        if (credentials[i].isAbandoned && (credentials[i].validityPeriod ?? 0) > 0) {
          return true;
        }
      }
    } catch (err) {
      LogUtil.error(`${TAG} oldPasswordActive error ${err?.code}`);
    }
    return false;
  }


  static async isDarkTimeSupport(): Promise<boolean> {
    let darkMode: string = SettingsDataUtils.getSettingsDataDomain(SETTINGS_UI_APPEARANCE_DARK_MODE,
      DEFAULT_DARK_MODE_STATE, Settings.domainName.USER_PROPERTY);
    LogUtil.showInfo(TAG, `isDarkTimeSupport: darkMode:${darkMode}`);
    return darkMode === DARK_MODE_TIMED_ON;
  }

  static async isHdrImageSupport(): Promise<boolean> {
    // try {
    //   let displayengineNapi = await import('@ohos.displayengine.displayengine_napi');
    //   let isShow: boolean = displayengineNapi.default.getSupported([DE_HDR_IMAGE_KEY])[0] === 1;
    //   LogUtil.showInfo(TAG, `isHdrImageSupport: isShow:${isShow}`);
    //   return isShow;
    // } catch (error) {
    //   LogUtil.showError(TAG, `displayengine_napi getSupported isEyeBlueSupport error: ${error?.message}`);
    //   return false;
    // }
    return false;
  }

  static async isBionicVisionSupport(): Promise<boolean> {
    try {
      let isShow: boolean = (SettingsDataUtils.getSettingsDataDomain(SETTINGS_DISPLAY_HDR_PIC_SWITCH,
        BIONIC_VISION_SWITCH_DISABLED, Settings.domainName.DEVICE_SHARED) == BIONIC_VISION_SWITCH_ENABLED) &&
        (systemParameterEnhance.getSync('const.photos.enable_pixelmap_readapt', 'false') === 'true');
      LogUtil.showInfo(TAG, `isBionicVisionSupport: isShow:${isShow}`);
      return isShow;
    } catch (error) {
      LogUtil.showError(TAG, `displayengine_napi getSupported isBionicVisionSupport error: ${error?.message}`);
      return false;
    }
  }

  static async isEbookColorSupport(): Promise<boolean> {
    // try {
    //   let displayengineNapi = await import('@ohos.displayengine.displayengine_napi');
    //   let readingGlobal = displayengineNapi.default.getSupported([DE_FEATURE_READING_GLOBAL])[0];
    //   LogUtil.showInfo(TAG, `isEbookColorSupport:readingGlobal: ${readingGlobal}`);
    //   let ebookColorSupport = readingGlobal === 2;
    //   let ebookSwitch: string = SettingsDataUtils.getSettingsDataDomain(EBOOK_SWITCH_KEY, EBOOK_SWITCH_DISABLED,
    //     Settings.domainName.USER_PROPERTY);
    //   LogUtil.showInfo(TAG, `isEbookColorSupport:${ebookColorSupport} ebookSwitch:${ebookSwitch}`);
    //   return ebookColorSupport && ebookSwitch === EBOOK_SWITCH_ENABLED;
    // } catch (error) {
    //   LogUtil.showError(TAG, `displayengine_napi getSupported isEbookColorSupport error: ${error?.message}`);
    //   return false;
    // }
    return false;
  }

  static async isEbookBlackSupport(): Promise<boolean> {
    // try {
    //   let displayengineNapi = await import('@ohos.displayengine.displayengine_napi');
    //   let readingGlobal = displayengineNapi.default.getSupported([DE_FEATURE_READING_GLOBAL])[0];
    //   LogUtil.showInfo(TAG, `isEbookBlackSupport:readingGlobal: ${readingGlobal}`);
    //   let ebookSupport = readingGlobal === 1 || readingGlobal === 2;
    //   let ebookSwitch: string = SettingsDataUtils.getSettingsDataDomain(EBOOK_SWITCH_KEY, EBOOK_SWITCH_DISABLED,
    //     Settings.domainName.USER_PROPERTY);
    //   LogUtil.showInfo(TAG, `isEbookSupport:${ebookSupport} ebookSwitch:${ebookSwitch}`);
    //   return ebookSupport && ebookSwitch === EBOOK_SWITCH_ENABLED;
    // } catch (error) {
    //   LogUtil.showError(TAG, `displayengine_napi getSupported isEbookBlackSupport error: ${error?.message}`);
    //   return false;
    // }
    return false;
  }

  static async isEbookSupport(): Promise<boolean> {
    // try {
    //   let displayengineNapi = await import('@ohos.displayengine.displayengine_napi');
    //   let readingGlobal = displayengineNapi.default.getSupported([DE_FEATURE_READING_GLOBAL])[0];
    //   LogUtil.showInfo(TAG, `isEbookSupport:readingGlobal: ${readingGlobal}`);
    //   let ebookSwitch = readingGlobal === 1 || readingGlobal === 2;
    //   LogUtil.showInfo(TAG, `isEbookSupport: ${ebookSwitch}`);
    //   return ebookSwitch;
    // } catch (error) {
    //   LogUtil.showError(TAG, `displayengine_napi getSupported isEbookSupport error: ${error?.message}`);
    //   return false;
    // }
    return false;
  }

  static async isEyeProtectSupport(): Promise<boolean> {
    // try {
    //   let displayengineNapi = await import('@ohos.displayengine.displayengine_napi');
    //   let isShow: boolean = displayengineNapi.default.getSupported([DE_FEATURE_EYE_PROTECT_WITHGMP])[0] === 1;
    //   LogUtil.showInfo(TAG, `isEyeProtectSupport: ${isShow}`);
    //   return isShow;
    // } catch (error) {
    //   LogUtil.showError(TAG, `displayengine_napi getSupported isEyeProtectSupport error: ${error?.message}`);
    //   return false;
    // }
    return false;
  }

  static async isSwingEyeSupport(): Promise<boolean> {
    // try {
    //   let displayengineNapi = await import('@ohos.displayengine.displayengine_napi');
    //   let isShow: boolean = displayengineNapi.default.getSupported([DE_SWING_EYE])[0] !== 0;
    //   LogUtil.showInfo(TAG, `isSwingEyeSupport: ${isShow}`);
    //   return isShow;
    // } catch (error) {
    //   LogUtil.showError(TAG, `displayengine_napi getSupported isSwingEyeSupport error: ${error?.message}`);
    //   return false;
    // }
    return false;
  }

  static async isEyeTimeSupport(): Promise<boolean> {
    // try {
    //   let displayengineNapi = await import('@ohos.displayengine.displayengine_napi');
    //   let isShow: boolean = displayengineNapi.default.getSupported([DE_FEATURE_EYE_PROTECT_WITHGMP])[0] === 1;
    //   let eyeMode: string = SettingsDataUtils.getSettingsDataDomain(EYE_MODE_KEY, EYE_MODE_DEFAULT,
    //     Settings.domainName.USER_PROPERTY);
    //   LogUtil.showInfo(TAG, `isEyeTimeSupport: isShow:${isShow} eyeMode:${eyeMode}`);
    //   return isShow && (eyeMode === EYE_MODE_TIME || eyeMode === EYE_MODE_SUN);
    // } catch (error) {
    //   LogUtil.showError(TAG, `displayengine_napi getSupported isEyeTimeSupport error: ${error?.message}`);
    //   return false;
    // }
    return false;
  }

  static async isEyeStartTimeSupport(): Promise<boolean> {
    // try {
    //   let displayengineNapi = await import('@ohos.displayengine.displayengine_napi');
    //   let isShow: boolean = displayengineNapi.default.getSupported([DE_FEATURE_EYE_PROTECT_WITHGMP])[0] === 1;
    //   let eyeMode: string = SettingsDataUtils.getSettingsDataDomain(EYE_MODE_KEY, EYE_MODE_DEFAULT,
    //     Settings.domainName.USER_PROPERTY);
    //   LogUtil.showInfo(TAG, `isEyeStartTimeSupport: isShow:${isShow} eyeMode:${eyeMode}`);
    //   return isShow && eyeMode === EYE_MODE_TIME;
    // } catch (error) {
    //   LogUtil.showError(TAG, `displayengine_napi getSupported isEyeStartTimeSupport error: ${error?.message}`);
    //   return false;
    // }
    return false;
  }

  static async isEyeBlueSupport(): Promise<boolean> {
    // try {
    //   let displayengineNapi = await import('@ohos.displayengine.displayengine_napi');
    //   let isShow: boolean = displayengineNapi.default.getSupported([DE_FEATURE_EYE_PROTECT_WITHGMP])[0] === 1;
    //   let eyeEnable: string = SettingsDataUtils.getSettingsDataDomain(EYE_ENABLE_KEY, EYE_ENABLE_DISABLED,
    //     Settings.domainName.USER_PROPERTY);
    //   LogUtil.showInfo(TAG, `isEyeProtectSupport: isShow:${isShow} eyeEnable:${eyeEnable}`);
    //   return isShow && eyeEnable === EYE_ENABLE_ENABLED;
    // } catch (error) {
    //   LogUtil.showError(TAG, `displayengine_napi getSupported isEyeBlueSupport error: ${error?.message}`);
    //   return false;
    // }
    return false;
  }

  static async isLowFrequencySupport(): Promise<boolean> {
    // try {
    //   let displayengineNapi = await import('@ohos.displayengine.displayengine_napi');
    //   let isShow: boolean = displayengineNapi.default.getSupported([DE_LOW_FREQUENCY_FLASH_KEY])[0] === 1;
    //   LogUtil.showInfo(TAG, `isLowFrequencySupport: isShow:${isShow}`);
    //   return isShow;
    // } catch (error) {
    //   LogUtil.showError(TAG, `displayengine_napi getSupported isEyeBlueSupport error: ${error?.message}`);
    //   return false;
    // }
    return false;
  }

  /*
   * 设置搜索判断当前设备是否只支持色彩调节
   */
  static async isColorAdjustmentSupport(): Promise<boolean> {
    try {
      let colorModeAdjustmentSupport: boolean = await DisplayUtils.isColorModeSupport();
      let colorTemperatureAdjustmentSupport: boolean = await DisplayUtils.isColorTemperatureAdjustmentSupport();
      let supportState: boolean = colorModeAdjustmentSupport && !colorTemperatureAdjustmentSupport;
      LogUtil.showInfo(TAG, `isColorAdjustmentSupport supportState: ${supportState}`);
      return supportState;
    } catch (err) {
      LogUtil.showError(TAG, `displayengine_napi getSupported error: ${err?.code} ${err?.message}`);
    }
    return false;
  }

  /*
   * 设置搜索判断当前设备是否只支持色温调节
   */
  static async isColorTemperatureAdjustmentSupport(): Promise<boolean> {
    try {
      let colorModeAdjustmentSupport: boolean = await DisplayUtils.isColorModeSupport();
      let colorTemperatureAdjustmentSupport: boolean = await DisplayUtils.isColorTemperatureAdjustmentSupport();
      let supportState: boolean = colorTemperatureAdjustmentSupport && !colorModeAdjustmentSupport;
      LogUtil.showInfo(TAG, `isColorTemperatureAdjustmentSupport supportState: ${supportState}`);
      return supportState;
    } catch (err) {
      LogUtil.showError(TAG, `displayengine_napi getSupported error: ${err?.code} ${err?.message}`);
    }
    return false;
  }

  /*
   * 设置搜索判断当前设备是否支持色彩和色温调节
   */
  static async isColorAndColorTemperatureAdjustmentSupport(): Promise<boolean> {
    try {
      let colorModeAdjustmentSupport: boolean = await DisplayUtils.isColorModeSupport();
      let colorTemperatureAdjustmentSupport: boolean = await DisplayUtils.isColorTemperatureAdjustmentSupport();
      let supportState: boolean = colorModeAdjustmentSupport && colorTemperatureAdjustmentSupport;
      LogUtil.showInfo(TAG, `isColorAndColorTemperatureAdjustmentSupport supportState: ${supportState}`);
      return supportState;
    } catch (err) {
      LogUtil.showError(TAG, `displayengine_napi getSupported error: ${err?.code} ${err?.message}`);
    }
    return false;
  }

  /*
   * 设置搜索判断当前设备是否支持闪烁提醒
   */
  static async isFlashReminderSupport(): Promise<boolean> {
    let isSupport: boolean = false;
    let cameraManager: camera.CameraManager | undefined = undefined;
    try {
      cameraManager = camera.getCameraManager(AbilityContextManager.getContext());
      if (DeviceUtil.isDevicePhone() && cameraManager.isTorchSupported()) {
        isSupport = true;
      }
    } catch (err) {
      LogUtil.error(`${TAG} isSupportFlash failed, code: ${err?.code}, message: ${err?.message}`);
    }
    return isSupport;
  }

  /*
   * 设置搜索判断当前设备是否支持环境音识别
   */
  static async isSoundRecognitionSupport(): Promise<boolean> {
    let isSupport: boolean = systemParameterEnhance.getSync(
      'persist.accessibility.voiceRecognition', 'false') === 'true';
    return isSupport;
  }

  /*
 * 设置搜索判断当前设备是否支持助听器
 */
  static async isHearingAidSupport(): Promise<boolean> {
    let isSupport: boolean = DeviceUtil.isDeviceEmulator();
    return !isSupport;
  }

  /*
   * 色温-自然色温
   */
  static async isNatureColorTemperatureSupport(): Promise<boolean> {
    // try {
    //   let displayengineNapi = await import('@ohos.displayengine.displayengine_napi');
    //   let supportState: boolean = displayengineNapi.default.getSupported([23])[0] === 1;
    //   LogUtil.showInfo(TAG, `isNatureColorTemperatureSupport. supportState:${supportState}`);
    //   return supportState;
    // } catch (err) {
    //   LogUtil.showError(TAG, `isNatureColorTemperatureSupport catch error. code:${err?.code} message:${err?.message}`);
    //   return false;
    // }
    return false;
  }

  /*
   * 开发者选项-阳光下可读性提升
   */
  static async isSunlightReadabilitySupport(): Promise<boolean> {
    // const developModeSupportState: boolean = await SearchCheckUtil.isDevelopModeSupport();
    // LogUtil.showInfo(TAG, `isSunlightReadabilitySupport. developModeSupportState:${developModeSupportState}`);
    // if (developModeSupportState) {
    //   try {
    //     let displayengineNapi = await import('@ohos.displayengine.displayengine_napi');
    //     let supportState: boolean = displayengineNapi.default.getSupported([10])[0] === 1;
    //     LogUtil.showInfo(TAG, `isSunlightReadabilitySupport. supportState:${supportState}`);
    //     return supportState;
    //   } catch (err) {
    //     LogUtil.showError(TAG, `isSunlightReadabilitySupport catch error. code:${err?.code} message:${err?.message}`);
    //     return false;
    //   }
    // }
    return false;
  }

  static async isScreenRatesSupport(): Promise<boolean> {
    let refreshRates: number[] = [];
    let currentMode: number = REFRESH_RATE_INVALID;
    try {
      refreshRates = hgmnapi.getScreenSupportedRefreshRates(SCREEN_ID);
      LogUtil.showInfo(TAG, 'support refresh rates');

      try {
        currentMode = hgmnapi.getCurrentRefreshRateMode(SCREEN_ID) as number;
        LogUtil.showInfo(TAG, `current refresh mode: ${currentMode}`);
      } catch (error) {
        LogUtil.showError(TAG, `getCurrentRefreshRateMode failed, error ${error?.message}`);
      }
    } catch (error) {
      LogUtil.showError(TAG, `getScreenSupportedRefreshRates failed, error ${error?.message}`);
      return false;
    }

    if (!refreshRates || refreshRates.length === 0 || refreshRates.includes(REFRESH_RATE_INVALID)) {
      return false;
    }

    let refreshRatesExcludeDynamic: number[] = refreshRates.filter(item => item !== SUPPORT_DYNAMIC_POLICY);
    refreshRatesExcludeDynamic.sort((a: number, b: number) => a - b);
    if ((refreshRatesExcludeDynamic.length > 1 && currentMode > refreshRatesExcludeDynamic.length) ||
      (currentMode === SUPPORT_DYNAMIC_POLICY && !refreshRates.includes(SUPPORT_DYNAMIC_POLICY))) {
      return false;
    }
    return true;
  }

  static async isSupportWrc(): Promise<boolean> {
    try {
      let batteryInfo = await import('@ohos.batteryInfo');
      let isSupportWRC: boolean = batteryInfo.default.isBatteryConfigSupported('wireless_tx');
      LogUtil.showInfo(TAG, `isSupportWrc: ${isSupportWRC}`);
      // isSupportWRC 打印值为1 因此不能直接返回isSupportWRC
      if (isSupportWRC) {
        return true;
      }
      return false;
    } catch (err) {
      LogUtil.showInfo(TAG, `isSupportWrc error: ${err?.message}`);
      return false;
    }
  }

  static async isFingerPrintSupport(): Promise<boolean> {
    try {
      const request: osAccount.GetPropertyRequest = { authType: FINGERPRINT_CRED_TYPE, keys: FINGERPRINT_CRED_KEY };
      let property = await new osAccount.UserAuth().getProperty(request);
      if (property?.result === osAccount.ResultCode.SUCCESS) {
        LogUtil.showInfo(TAG, `support fingerprint, sensorInfo: ${property.sensorInfo}`);
        if (property.sensorInfo) {
          const dict: Record<string, Object> = JSON.parse(property.sensorInfo);
          return dict[FINGERPRINT_SENSOR_TYPE] === UNDER_SCREEN_SENSOR ||
            dict[FINGERPRINT_SENSOR_TYPE] === OUT_OF_SCREEN_SENSOR;
        } else {
          LogUtil.showError(TAG, 'miss sensor info');
          return false;
        }
      } else {
        LogUtil.showError(TAG, 'get property failed');
        return false;
      }
    } catch (e) {
      LogUtil.showError(TAG, 'get property exception');
      return false;
    }
  }

  static async isFaceAuthSupport(): Promise<boolean> {
    try {
      let getPropertyRequest : osAccount.GetPropertyRequest = {
        authType : osAccount.AuthType.FACE,
        keys : [osAccount.GetPropertyType.ENROLLMENT_PROGRESS, osAccount.GetPropertyType.SENSOR_INFO]
      };
      let property = await new osAccount.UserAuth().getProperty(getPropertyRequest);
      if (property.result === osAccount.ResultCode.SUCCESS) {
        LogUtil.showInfo(TAG, 'face auth is supported');
        return true;
      }
      LogUtil.showError(TAG, 'face auth is not supported');
      return false;
    } catch (err) {
      LogUtil.showError(TAG, 'getProperty has exception');
      return false;
    }
  }

  static async faceLoginAccount(): Promise<boolean> {
    LogUtil.info(`${TAG}, start faceLoginAccount`);
    try {
      // const request : accountService.QueryAccountBiometricStatusRequest = {
      //   biometricType: accountService.AccountBiometricType.FACE
      // }
      // const data : accountService.AccountBiometricVerificationResponse =
      //   await accountService.queryAccountBiometricVerificationStatus(request);
      // LogUtil.info(`${TAG}, getLoginAccountStatus : ${data?.status}`);
      // if (data?.status === accountService.AccountBiometricVerificationStatus.NOT_SUPPORTED) {
      //   return false;
      // }
      return true;
    } catch (e) {
      LogUtil.error(`${TAG}, getFaceLoginAccount: ${e?.code} , message: ${e?.message} `);
      return false;
    }
  }

  static async hasSetPinPassword(): Promise<boolean> {
    try {
      let authPinType: number = 1;
      let authInfo: osAccount.EnrolledCredInfo[] = await SearchCheckUtil.userIdentityManager.getAuthInfo(authPinType);
      return authInfo && authInfo.length > 0;
    } catch (err) {
      LogUtil.showError(TAG, 'getAuthInfo failed');
      return false;
    }
  }

  static async hasSim(): Promise<boolean> {
    let maxSimCount: number = SimUtils.getCardSlotNum();
    return maxSimCount === SIMCOUNT ? false : true;
  }

  static async hasVoiceCapability(): Promise<boolean> {
    let result: boolean = false;
    try {
      result = call.hasVoiceCapability();
      LogUtil.info(`${TAG} result ${result}`);
    } catch (err) {
      LogUtil.showError(TAG, `hasVoiceCapability error: ${err?.message}`);
    }
    return result;
  }

  static async isDevelopModeSupport(): Promise<boolean> {
    try {
      const isDevelopMode: boolean = SystemParamUtil.getParam('const.security.developermode.state', 'false') === 'true';
      if (isDevelopMode) {
        let isCurrentPrivateUser: boolean = await AccountUtil.isCurrentPrivate();
        return !isCurrentPrivateUser;
      }
      return false;
    } catch (error) {
      LogUtil.showError(TAG, `displayengine_napi getSupported isEyeProtectSupport error: ${error?.message}`);
      return false;
    }
  }

  static async isSupportKeyMouseHandEye(): Promise<boolean> {
    try {
      const isSwingEnabled: boolean = SystemParamUtil.getParam('const.config.swing_enabled', '0') === '1';
      const isSupportKeyMouseHandEye: boolean =
        isSwingEnabled &&
          (SystemParamUtil.getParam('const.keyMouse.handEye.enabled', 'false') === 'true');
        return isSupportKeyMouseHandEye;
    } catch (error) {
      LogUtil.showError(TAG, `isSupportKeyMouseHandEye error: ${error?.message}`);
      return false;
    }
  }

  /**
   * 开发者选项-外屏应用调试
   *
   * @returns 是否支持开启外屏应用调试
   */
  static async isOpenOuterAppListSupport(): Promise<boolean> {
    let isShowOuterAppMenu: string = SystemParamUtil.getParam('const.settings.debug_outer_app_show', 'false');
    return (await SearchCheckUtil.isDevelopModeSupport() && isShowOuterAppMenu === 'true');
  }

  static async isOpenOuterAppSupport(): Promise<boolean> {
    return SystemParamUtil.getParam('const.settings.debug_outer_app_show', 'false') === 'true';
  }

  /*
   * 开发者选项-显示刷新频率
   * */
  static async refreshShow(): Promise<boolean> {
    try {
      const isDevelopMode: boolean = SystemParamUtil.getParam('const.security.developermode.state', 'false') === 'true';
      if (!isDevelopMode) {
        return false;
      }
      let isCurrentPrivateUser: boolean = await AccountUtil.isCurrentPrivate();
      if (isCurrentPrivateUser) {
        return false;
      }
      return SystemParamUtil.getParam('const.settings.refresh_rate_seenable', 'true') === 'true';
    } catch (error) {
      LogUtil.showError(TAG, `displayengine_napi getSupported isEyeProtectSupport error: ${error?.message}`);
      return false;
    }
  }

  static async isEflForbidden(): Promise<boolean> {
    return !SystemParamUtil.isEflForbidden();
  }

  static async isNotDisturbCallShow(): Promise<boolean> {
    let isMainUser: boolean = !(await AccountUtil.isCurrentPrivate());
    let hasVoiceCapability:boolean = await SearchCheckUtil.hasVoiceCapability();
    return isMainUser && hasVoiceCapability;
  }

  static async isSupportSOS(): Promise<boolean> {
    try {
      if (DeviceUtil.isDevicePad() && !call.hasVoiceCapability()) {
        return false;
      }
    } catch (err) {
      LogUtil.error(`${TAG} get isDevicePad or hasVoiceCapability failed: ${err?.message}`);
    }
    return true;
  }

  static isCertificationNotSupport(): boolean {
    let buildHide: string = SystemParamUtil.getParam('const.settings.auth_logo_show', 'false');
    LogUtil.info(`${TAG} buildHide is ${buildHide}`)
    return buildHide !== 'false';
  }

  static async isAutoTimeZoneOpen(): Promise<boolean> {
    LogUtil.info(`${TAG} isNotAutoTimeZone start (SettingsDataUtils.getSettingsData(KEY_AUTO_TIMEZONE, '1') ${SettingsDataUtils.getSettingsData(KEY_AUTO_TIMEZONE, '1')}`);
    return (SettingsDataUtils.getSettingsData(KEY_AUTO_TIMEZONE, '1') !== '1') &&
      (systemParameter.getSync('persist.time.auto_time', 'ON') !== 'ON');
  }

  /**
   * 搜索项是否支持免打扰相关搜索项
   */
  static async isSupportNotDisturb(): Promise<boolean> {
    const isSupportIntelligentScene = CapabilitySupportUtils.isSupportIntelligentScene();
    return !isSupportIntelligentScene && !(await AccountUtil.isCurrentPrivate());
  }

  /**
   * 搜索项是否支持锁屏声音相关搜索项
   */
  static isScreenLockToneSupport(): boolean {
    // 2合1设备类型的pc模式，无锁屏声音，因此开关无实际意义
    return !DeviceUtil.is2In1DevicePcType();
  }

  /**
   * 是否主用户 (命名错误 但有外部项目使用 先不修改)
   */
  static async isPrivacyUser(): Promise<boolean> {
    return !(await AccountUtil.isCurrentPrivate());
  }

  static hasSimCard(): boolean {
    return SimUtils.hasSimCard();
  }

  static isWhiperAwakeSupport(): boolean {
    let accessible: boolean = false;
    let path = '/sys_prod/variant/region_comm/china/etc/intellvoice/wakeup/ap/kws2_acousticsModel6.pb';
    try {
      accessible = fs.accessSync(path);
    } catch (err) {
      LogUtil.info(`${TAG} szw accessSync failed, ${err?.message}`)
    }
    LogUtil.info(`${TAG} isSupportWhisper ${accessible}`)
    return accessible;
  }

  /**
   * 搜索跳转校验设备是否支持应用常驻管理
   */
  static async isSupportAppKeepAliveSettings(): Promise<boolean> {
    const SHOW_APP_KEEPALIVE_SETTINGS: string = 'const.settings.show_app_keepalive_settings';
    let isSupport: string = 'false';
    try {
      isSupport = systemParameterEnhance.getSync(SHOW_APP_KEEPALIVE_SETTINGS, 'false');
    } catch (err) {
      LogUtil.error(`${TAG} get isShowAppKeepAliveSettings fail, errCode: ${err?.code}, errMsg: ${err?.message}`);
    }
    return isSupport === 'true';
  }

  /**
   * 搜索跳转校验设备是否支持PC触控板页面

   * @returns { boolean } 是否支持PC触控板页面
   */
  static isSupportShowPcTouchpadPage(): boolean {
    if (DeviceUtil.isDevicePc()) {
      return true;
    }
    try {
      return systemParameterEnhance.getSync(SUPPORT_SHOW_PC_TOUCHPAD_PAGE, 'false') === 'true' &&
      DeviceUtil.isDevicePad();
    } catch (err) {
      LogUtil.error(`${TAG} get isSupportShowPcTouchpadPage fail, errCode: ${err?.code}, errMsg: ${err?.message}`);
      return false;
    }
  }

  /**
   * 搜索校验设备是否支持触控板特性
   * @param {number} 1:压力、振感调节; 2:指关节手势; 4:边缘手势
   * @returns { boolean } true, 支持触控板振感强度和按压灵敏度设置
   */
  static isSupportSearchTouchpadFeature(feature: number): boolean {
    if (!SearchCheckUtil.isSupportShowPcTouchpadPage() || isNaN(feature)) {
      return false;
    }
    let clickpadType: number = Number(SystemParamUtil.getParam('const.settings.clickpad_type', '0'));
    let isSupport: boolean = (clickpadType & feature) === feature;
    return isSupport;
  }

  
  static isSupportSearchPressAndShock(): boolean {
    return SearchCheckUtil.isSupportSearchTouchpadFeature(TouchpadSupportFeature.PRESS_SHOCK);
  }

  static isSupportSearchTouchpadEdgeGesture(): boolean {
    return SearchCheckUtil.isSupportSearchTouchpadFeature(TouchpadSupportFeature.BRIGHTNESS_VOLUME);
  }

  static isSupportSearchTouchpadKnuckleGesture(): boolean {
    return SearchCheckUtil.isSupportSearchTouchpadFeature(TouchpadSupportFeature.KNUCKLE_GESTURE);
  }

  /**
   * 设置搜索判断当前设备是否接入了外接设备
   *
   * @returns
   */
  static async isSupportDeviceItem(): Promise<boolean> {
    LogUtil.showInfo(TAG, `support search device item start`);
    return await DeviceUtil.isConnectDevices();
  }

  /**
   * 搜索跳转校验设备是否支持上下屏镜像模式
   */
  static async isSupportRegionMirrorMode(): Promise<boolean> {
    let isSupport: boolean = false;
    try {
      isSupport = display.isFoldable() && DeviceUtil.isDevicePc() && (await DeviceUtil.isConnectDevices());
    } catch (err) {
      LogUtil.error(`${TAG} get isSupportRegionMirrorMode fail, errCode: ${err?.code}, errMsg: ${err?.message}`);
    }
    return isSupport;
  }

  static async isSupportUseAs(): Promise<boolean> {
    let connectDevice = await SearchCheckUtil.isSupportDeviceItem();
    let regionMirrorMode = await SearchCheckUtil.isSupportRegionMirrorMode();
    return connectDevice && !regionMirrorMode;
  }

  public static isUserSettingsEnabled(): boolean {
    let enabled: boolean = true;
    try {
      const ESPACE_PARAM_KEY: string = 'persist.space_mgr_service.enterprise_space_enable';
      const DOMAIN_PARAM_KEY: string = 'domain';
      const DEFAULT_EPSACE_VALUE: string = 'empty';
      const eSpaceValue: string = systemParameterEnhance.getSync(ESPACE_PARAM_KEY, DEFAULT_EPSACE_VALUE);
      // 单企业空间会写入domain参数
      const domainValue: string = Settings.getValueSync(getContext(), DOMAIN_PARAM_KEY, DEFAULT_EPSACE_VALUE);
      LogUtil.info(`${TAG} isUserSettingsEnabled eSpaceValue ${eSpaceValue} domainValue ${domainValue}`);
      if (eSpaceValue === 'true') {
        enabled = false;
      }
    } catch (err) {
      LogUtil.error(`${TAG} isUserSettingsEnabled failed. Error ${err?.code} ${err?.message}`);
    }
    return enabled;
  }

  /**
   * 搜索跳转校验设备是否支持震动
   */
  static async isSupportVibrateAsync(): Promise<boolean> {
    try {
      const isSupportVibrate = systemParameterEnhance.getSync('const.vibrator.support_vibrator', 'true');
      LogUtil.info(`${TAG} isSupportVibrateAsync: ${isSupportVibrate}`);
      return isSupportVibrate === 'true';
    } catch (err) {
      LogUtil.error(`${TAG} isSupportVibrateAsync error ${err?.code}`);
      return false;
    }
  }

  /**
   * 搜索跳转校验是否显示重复来电响铃
   */
  static async isRepeatedCallRinging(): Promise<boolean> {
    const isSupportIntelligentScene = CapabilitySupportUtils.isSupportIntelligentScene();
    const isRepeatedCallRinging = SettingsDataUtils.getSettingsData(FOCUS_MODE_CALL_MESSAGE_POLICY, '1');
    const hasVoiceCapability = call.hasVoiceCapability();
    LogUtil.info(`${TAG} isRepeatedCallRinging:${isRepeatedCallRinging} hasVoiceCapability:${hasVoiceCapability}`);
    return !isSupportIntelligentScene && isRepeatedCallRinging !== DISTURB_CHOSE_ALL && hasVoiceCapability;
  }

  /**
   * 搜索跳转校验设备是否支持智能通话
   */
  static async isSupportAiVoice(): Promise<boolean> {
    try {
      const isNewAudioPage = systemParameterEnhance.getSync('const.settings.use_new_audio_page', 'false') === 'true';
      if (isNewAudioPage) {
        return false;
      }
      const isSupportAiVoice = systemParameterEnhance.getSync('const.multimedia.audio.ai_voice_noise_suppression_supported', 'true');
      LogUtil.info(`${TAG} isSupportAiVoice: ${isSupportAiVoice}`);
      return isSupportAiVoice === 'true';
    } catch (err) {
      LogUtil.error(`${TAG} isSupportAiVoice error ${err?.code}`);
      return false;
    }
  }

  /**
   * 搜索跳转校验设备是否支持铃声振动自适应
   *
   * @returns true: 支持； false：不支持
   */
  static isSupportRingtoneVibrationAdaptive(): boolean {
    return VibratorUtil.isSupportRingtoneVibrationAdaptive();
  }

  /**
   * 搜索跳转校验设备是否立体声增强
   */
  static async isStereoEnhancement(): Promise<boolean> {
    try {
      const isStereoEnhancement = systemParameterEnhance.getSync('const.multimedia.audio.show_stereo_enhancement_switch', 'false');
      LogUtil.info(`${TAG} isStereoEnhancement: ${isStereoEnhancement}`);
      return isStereoEnhancement === 'true';
    } catch (err) {
      LogUtil.error(`${TAG} isStereoEnhancement error ${err?.code}`);
      return false;
    }
  }


  /**
   * 搜索跳转校验设备是否支持关怀-骚扰拦截
   */
  static async isSupportCallFilter(): Promise<boolean> {
    let elderCareState: boolean = SettingsDataUtils.getSecureValue('accessibility_elder_care_switch_enabled', '0') === '1';
    let isCurrentPrivateUser: boolean = await AccountUtil.isCurrentPrivate();
    let hasSim: boolean = await SearchCheckUtil.hasSim();
    let isSupportCallFilter: boolean = elderCareState && !isCurrentPrivateUser && hasSim;
    LogUtil.info(`${TAG} isSupportCallFilter: ${isSupportCallFilter}`)
    return isSupportCallFilter;
  }

  static isTextAutoFillSyncEnabled(): boolean {
    let isInstalled: boolean = false;
    try {
      isInstalled = bundleManager.isApplicationEnabledSync('com.ohos.clouddrive');
    } catch (err) {
      LogUtil.error(`${TAG} isCloudSpaceInstalled error ${err?.code}`);
    }
    return isInstalled;
  }

   /**
   *  是否已录入人脸
   */
  static async isFaceEnrolled(): Promise<boolean> {
    try {
      if (!SearchCheckUtil.userIdentityManager) {
        LogUtil.error(`${TAG} userIdentityManager is not find`);
        return false;
      }

      const credentials = await SearchCheckUtil.userIdentityManager.getAuthInfo(osAccount.AuthType.FACE);
      return credentials.length > 0;
    } catch (err) {
      return false;
    }
  }

  /**
   *  设备是否支持3d人脸
   */
  static async isFaceAuthType3D(): Promise<boolean> {
    try {
      const getPropertyRequest : osAccount.GetPropertyRequest = {
        authType : osAccount.AuthType.FACE,
        keys : [osAccount.GetPropertyType.ENROLLMENT_PROGRESS, osAccount.GetPropertyType.SENSOR_INFO]
      };

      if (!SearchCheckUtil.userAuth) {
        LogUtil.error(`${TAG} userAuth is not find`);
        return false;
      }

      const property: osAccount.ExecutorProperty = await SearchCheckUtil.userAuth.getProperty(getPropertyRequest);
      if (property.result !== osAccount.ResultCode.SUCCESS) {
        LogUtil.info(`${TAG} getProperty fail`);
        return false;
      }

      if (property.sensorInfo === undefined) {
        LogUtil.info(`${TAG} property.sensorInfo is undefined`);
        return false;
      }

      let sensorInfoObj = JSON.parse(property.sensorInfo) as sensorInfoObj;
      return sensorInfoObj.type === '3D';
    } catch (err) {
      LogUtil.error(`${TAG} getProperty has exception: err code: ${err?.code}, err message: ${err?.message}`);
      return false;
    }
  }

  /**
   *  指纹是否支持访问应用锁
   */
  static async isFpSupportAppLock(): Promise<boolean> {
    try {
      const isFingerPrintSupport = await SearchCheckUtil.isFingerPrintSupport();
      const isSupportAppLock: boolean =
        systemParameterEnhance.getSync('const.appsecurityprivacy.applock.feature_enabled', '0') === '1';
      return isFingerPrintSupport && isSupportAppLock;
    } catch {
      LogUtil.error(`${TAG} get isFpSupportAppLock failed`);
      return false;
    }
  }

  /**
   *  人脸是否支持访问应用锁
   */
  static async isFaceSupportAppLock(): Promise<boolean> {
    try {
      const isFacePrintSupport = await SearchCheckUtil.isFaceAuthSupport();
      const isSupportAppLock: boolean =
        systemParameterEnhance.getSync('const.appsecurityprivacy.applock.feature_enabled', '0') === '1';
      return isFacePrintSupport && isSupportAppLock;
    } catch {
      LogUtil.error(`${TAG} get isFaceSupportAppLock failed`);
      return false;
    }
  }

  /**
   *  是否支持快捷启动和手势
   */
  static async isQuickGestureProductSupport(): Promise<boolean> {
    return !DeviceUtil.isDeviceEmulator();
  }

  /**
   *  是否支持快捷手势-亮屏显示
   */
  static async isWakeScreenProductSupport(): Promise<boolean> {
    try {
      let product = SystemParamUtil.getParam('const.build.product', '');
      return DeviceUtil.isDevicePc() && (product === 'HPR');
    } catch {
      LogUtil.error(`${TAG} get isWakeScreenProductSupport failed`);
      return false;
    }
  }

  /**
   * 搜索是否支持单手兼容模式
   */
  static isCompatibleMode(): boolean {
    return DeviceUtil.isNexFormsProduct();
  }

  /**
   * 搜索是否支持企业定制信息
   */
  static isEnterpriseCustomInfoSupport(): boolean {
    let context: Context = AppStorage.get<Context>('pageContext') as Context;
    let enterpriseCustomizationInfo: string = 'false';
    enterpriseCustomizationInfo = SettingsDataUtils.getSettingsDataWithContext(context, COM_ENTERPRISE_ENTERPRISE_CUSTOMIZATION_INFO, 'false');
    LogUtil.info(`${TAG} isEnterpriseCustomInfoSupport, enterpriseCustomizationInfo value: ${enterpriseCustomizationInfo}`);
    return enterpriseCustomizationInfo === 'true';
  }

  /**
   * 搜索是否支撑EID
   */
  static isSupportEID(): boolean {
    return DeviceUtil.isSupportEsim();
  }

  /**
   * 搜索是否支持国测版本名称
   */
  static isItsecVersionNameSupport(): boolean {
    let versionName: string = '';
    try {
      versionName = systemParameterEnhance.getSync(ITSEC_EDITION_NUMBER_CCM_CONFIG, '');
    } catch (err) {
      LogUtil.showError(TAG, `get itsec_edition_number failed, code: ${err?.code}, msg: ${err?.message}`);
    }
    return versionName.length !== 0;
  }

  /**
   * 搜索是否支持版本类型
   */
  static isVersionTypeSupport(): boolean {
    let isSupport: string = 'false';
    try {
      isSupport = systemParameterEnhance.getSync(LICENSE_ENABLE_CCM_CONFIG, 'false');
    } catch (err) {
      LogUtil.showError(TAG, `get const.pc_security.license_enable failed, code: ${err?.code}, msg: ${err?.message}`);
    }
    return isSupport === 'true';
  }

  /**
   * 搜索是否支持新鼠标页面设置项
   */
  static isUseNewMousePage(): boolean {
    try {
      const value = systemParameterEnhance.getSync('const.settings.use_new_mouse_page', 'false');
      LogUtil.showInfo(TAG, `isUseNewMousePage: ${value}`);
      return value === 'true';
    } catch (err) {
      LogUtil.showError(TAG, `isUseNewMousePage get value failed, code: ${err?.code}, msg: ${err?.message}`);
      return false;
    }
  }

  /**
   * 判断是否在搜索展示Pc关于本机设备信息
   *
   * @returns 是否在关于本机里展示设备信息
   */
  static isPcDeviceInfoSupportShow(): boolean {
    return !DeviceUtil.isDeviceEmulator();
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

  /**
   * 是否开启网络领航员列表项搜索
   */
  static async isNetSimulatorEnabled(): Promise<boolean> {
    const developModeSupportState: boolean = await SearchCheckUtil.isDevelopModeSupport();
    if (!developModeSupportState) {
      return false;
    }
    try {
      // return netQuality.isNetSimulatorEnabled();
    } catch (err) {
      LogUtil.error(`${TAG} isNetSimulatorEnabled err:${err?.code}-${err?.message}`);
      return false;
    }
    return false;
  }

  /**
   * 是否可添加网络领航员自定义场景
   */
  static async isNetSimulatorCustomAddEnabled(): Promise<boolean> {
    const developModeSupportState: boolean = await SearchCheckUtil.isDevelopModeSupport();
    if (!developModeSupportState) {
      return false;
    }
    try {
      // return netQuality.isNetSimulatorEnabled() &&
      //   netQuality.getNetSimulatorCustomScenarioList().length < 50;
    } catch (err) {
      LogUtil.error(`${TAG} isNetSimulatorEnabled err:${err?.code}-${err?.message}`);
      return false;
    }
    return false;
  }

  /**
   * 卡1是否支持wifi通话
   */
  static async isSupportVowifiCardOne(): Promise<boolean> {
    return await SearchCheckUtil.isSupportVowifi(SlotCount.slotIdOne);
  }

  /**
   * 卡2是否支持wifi通话
   */
  static async isSupportVowifiCardTwo(): Promise<boolean> {
    return await SearchCheckUtil.isSupportVowifi(SlotCount.slotIdTwo);
  }

  private static async isSupportVowifi(slotId: number): Promise<boolean> {
    let isSupportVowifi: boolean = false;
    try {
      const operatorConfigs: sim.OperatorConfig[] = await sim.getOperatorConfigs(slotId);
      if (Array.isArray(operatorConfigs) && operatorConfigs.length > 0) {
        let tempIndex = operatorConfigs.findIndex(item => item.field === 'vowifi_supported_bool');
        if (tempIndex > -1) {
          isSupportVowifi = operatorConfigs[tempIndex].value === 'true';
        }
        LogUtil.showInfo(TAG, `isSupportVowifi[slot ${slotId}]: ${isSupportVowifi}`);
      }
      return isSupportVowifi;
    } catch (err) {
      LogUtil.showError(TAG, `getOperatorConfigs[slot ${slotId}] failed, code: ${err?.code}, msg: ${err?.message}`);
      return false;
    }
  }

  /**
   * 搜索跳转校验设备是否支持接近光传感器
   */
  static isSupportProximitySensor(): boolean {
    try {
      let data: sensor.Sensor[] = sensor.getSensorListSync();
      if (data === undefined || data.length === 0) {
        return false;
      }
      for (let i = 0; i < data.length; i++) {
        if (data[i].sensorId === sensor.SensorId.PROXIMITY) {
          return true;
        }
      }
    } catch (err) {
      LogUtil.error(`${TAG} isSupportProximitySensor error ${err?.code}`);
    }
    return false;
  }

  /**
   * 搜索是否支持屏幕扣合警示音开关项
   */
  static isEnableScreenClosedWaringTone(): boolean {
    try {
      return systemParameterEnhance.getSync('const.settings.screen_snap_remind_enable', 'false') === 'true';
    } catch (err) {
      LogUtil.showError(TAG, `get screen_snap_remind_enable failed, code: ${err?.code}, msg: ${err?.message}`);
      return false;
    }
  }

  /**
   * 关于本机中部分菜单是否支持搜索
   *
   * @param index 菜单隐藏信息在const.product.hide.settings中的位置
   * @returns true: 支持, false： 不支持
   */
  private static isAboutDeviceItemSupport(index: number): boolean {
    // let isAnonymized: boolean = infosec.getInfoSecStatus(infosec.InfoSec.INFOSEC_FAKE_SETTINGS_INFO);
    // if (!isAnonymized) {
    //   return true;
    // }
    let anonymizationInfoStr: string = SystemParamUtils.getSystemParam(INFORMATION_HIDE, '');
    if (CheckEmptyUtils.checkStrIsEmpty(anonymizationInfoStr)) {
      return true;
    }
    let anonymizationInfo: string[] = anonymizationInfoStr.split(';');
    if (anonymizationInfo.length > index) {
      let value: string = anonymizationInfo[index];
      return !(value === HIDE_ITEM);
    }
    return true;
  }

  /**
   * 是否支持API 版本号搜索
   *
   * @returns true: 支持, false： 不支持
   */
  static isApiVersionSupport(): boolean {
    return SearchCheckUtil.isAboutDeviceItemSupport(API_VERSION_INDEX);
  }

  /**
   * 搜索是否支持OpenHarmony版本选项
   *
   * @returns true: 支持, false： 不支持
   */
  static isOpenHarmonySupport(): boolean {
    return SearchCheckUtil.isAboutDeviceItemSupport(OPEN_HARMONY_INDEX);
  }

  /**
   * 搜索是否显示鼠标圆形光标搜索项
   */
  static isEnableCircleCursor(): boolean {
    try {
      const isUseNewMousePage = systemParameterEnhance.getSync('const.settings.use_new_mouse_page', 'false') === 'true';
      if (isUseNewMousePage) {
        return false; // 新鼠标页面无圆形光标
      }
      const isEnableCircleCursor = systemParameterEnhance.getSync('const.settings.enable_circular_cursor', 'true');
      return isEnableCircleCursor === 'true';
    } catch (err) {
      LogUtil.showError(TAG, `isEnableCircleCursor get value failed, code: ${err?.code}, msg: ${err?.message}`);
      return false;
    }
  }

  /**
   * 校验操作搜索项的权限
   * @param optBundleName 操作包名
   * @param bundleName 搜索项包名
   * @returns true有权限
   */
  static checkPermissions(optBundleName: string, bundleName: string): boolean {
    return optBundleName === bundleName;
  }

  /**
   * 搜索是否支持新网络页面设置项
   */
  static isSupportNewNetworkPage(): boolean {
    return SystemParamUtil.getParam('const.settings.use_new_network_page', 'false') === 'true';
  }

  /**
   * 搜索是否支持移动网络页面设置项
   */
  static isSupportMobileNetworkPage(): boolean {
    return !SearchCheckUtil.isSupportNewNetworkPage();
  }

  /**
   * 搜索是否显示移动网络流量管理wlan排行设置项
   */
  static isShowMobileNetworkWlanRankingResult(): boolean {
    let isShow: boolean = SystemParamUtil.getParam('const.telephony.slotCount', '') === '0';
    return SearchCheckUtil.isSupportMobileNetworkPage() && isShow;
  }

  /**
   * 搜索是否显示星闪
   */
  static isShowNearlinkEntrance(): boolean {
    return !CapabilitySupportUtils.isSupportFusion() && CapabilitySupportUtils.isSupportNearLink();
  }

  /**
   * 搜索是否显示系统核心文件&系统文件
   */
  static isShowSystemFile(): boolean {
    return SearchCheckUtil.isShowVirtualMemory() || SearchCheckUtil.isShowHibernationFile();
  }

  /**
   * 搜索是否显示虚拟内存
   */
  static isShowVirtualMemory(): boolean {
    return Number(SystemParamUtil.getParam('const.resourceschedule.memmgr.eswapSize', '0')) >
      SHOW_VIRTUAL_MEMORY_THRESHOLD;
  }

  /**
   * 搜索是否显示休眠文件
   */
  static isShowHibernationFile(): boolean {
    return Number(SystemParamUtil.getParam('ohos.boot.vendor.ddrsize', '0')) > 0;
  }

  /**
   * 搜索是否显示星闪蓝牙融合页面
   */
  static isShowFusionEntrance(): boolean {
    return CapabilitySupportUtils.isSupportFusion() && CapabilitySupportUtils.isSupportNearLink();
  }

  /**
   * 搜索是否显示中轴个性化
   */
  static isShowVirtualBezel(): boolean {
    if (!DeviceUtil.isSuperFoldProduct()) {
      return false;
    }
    try {
      const isRed: string = systemParameterEnhance.getSync('ohos.boot.backcolor', '');
      return isRed === 'red';
    } catch (err) {
      LogUtil.showError(TAG, `error: ${err?.message}`);
    }
    return false;
  }

  /**
   * 搜索是否显示文件保密柜
   * 仅在手机全系列和平板中的MLR/MXH系列才显示文件保密柜的搜索结果项
   * @returns 返回true则表示可以显示文件保密柜的搜索结果
   */
  static isShowFileSafeBox(): boolean {
    const isPhone: boolean = DeviceUtil.isDevicePhone();
    const miniPadSeriesOfMLR: string = 'MLR';
    const miniPadSeriesOfMXH: string = 'MXH';
    const isMiniPad: boolean =
      deviceInfo.productSeries === miniPadSeriesOfMLR || deviceInfo.productSeries === miniPadSeriesOfMXH;
    LogUtil.showInfo(TAG, `isShowFileSafeBox, isPhone:${isPhone}, isMiniPad:${isMiniPad}`);
    return isPhone || isMiniPad;
  }

  /**
   * 是否显示处理器特性
   *
   * @returns 是否显示处理器特性
   */
  public static isShowProcessorSearch(): boolean {
    let isShow: string = SystemParamUtil.getParam('const.settings.processor_info_show', 'false');
    LogUtil.info(`${TAG} isShowProcessor ${isShow}`);
    if (isShow !== 'true') {
      return false;
    }
    let anonymization: boolean = false;
    try {
      // anonymization = infosec.getInfoSecStatus(infosec.InfoSec.INFOSEC_FAKE_SETTINGS_INFO);
      // LogUtil.showInfo(TAG, `isAnonymization: ${anonymization}`);
    } catch (error) {
      LogUtil.showError(TAG, `isAnonymization error: ${error?.message} code: ${error?.code}`);
    }
    if (!anonymization) {
      return true;
    }
    let anonymizationInfoStr: string = SystemParamUtils.getSystemParam(INFORMATION_HIDE, '');
    if (CheckEmptyUtils.checkStrIsEmpty(anonymizationInfoStr)) {
      LogUtil.showInfo(TAG, `anonymizationInfoStr isEmpty`);
      return true;
    }
    let anonymizationInfo: string[] = anonymizationInfoStr.split(';');
    LogUtil.showInfo(TAG, `anonymizationInfoStr processor: ${(anonymizationInfo?.[10] ?? '') !== 'hide'}`);
    return (anonymizationInfo?.[10] ?? '') !== 'hide';
  }
}
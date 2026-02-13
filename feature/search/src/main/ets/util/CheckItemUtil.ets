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

import systemParameterEnhance from '@ohos.systemParameterEnhance';
import type common from '@ohos.app.ability.common';
import { DeviceUtil, SatelliteUtils } from '@ohos/settings.common/src/main/ets/utils/BaseUtils';
import { CapabilitySupportUtils } from '@ohos/settings.common/src/main/ets/utils/CapabilitySupportUtils';
import { CheckEmptyUtils } from '@ohos/settings.common/src/main/ets/utils/CheckEmptyUtils';
import { DisplayUtils } from '@ohos/settings.common/src/main/ets/utils/DisplayUtils';
import { LogUtil } from '@ohos/settings.common/src/main/ets/utils/LogUtil';
import { PreferencesUtil } from '@ohos/settings.common/src/main/ets/utils/PreferencesUtil';
import { SettingsDataUtils } from '@ohos/settings.common/src/main/ets/utils/SettingsDataUtils';
import { CheckItem, SearchItem } from '../model/SearchPageConfig';
import { SearchCheckUtil } from './SearchCheckUtil';

enum CheckType {
  PARAM = 'param',
  PREFERENCE = 'preference',
  SETTINGDATA = 'settingData',
  FUNCTION = 'function'
}

/**
 * 查询开关状态方法映射
 */
const ITEM_STATUS_FUN_RECORD: Record<string, Function> = {
  'darkTimeSupport': SearchCheckUtil.isDarkTimeSupport,
  'hdrImageSupport': SearchCheckUtil.isHdrImageSupport,
  'ebookSupport': SearchCheckUtil.isEbookSupport,
  'ebookColorSupport': SearchCheckUtil.isEbookColorSupport,
  'ebookBlackSupport': SearchCheckUtil.isEbookBlackSupport,
  'eyeProtectSupport': SearchCheckUtil.isEyeProtectSupport,
  'eyeTimeSupport': SearchCheckUtil.isEyeTimeSupport,
  'eyeStartTimeSupport': SearchCheckUtil.isEyeStartTimeSupport,
  'eyeBlueSupport': SearchCheckUtil.isEyeBlueSupport,
  'lowFrequencySupport': SearchCheckUtil.isLowFrequencySupport,
  'isColorAdjustmentSupport': DisplayUtils.isColorModeSupport,
  'isOnlyColorAdjustmentSupport': SearchCheckUtil.isColorAdjustmentSupport,
  'natureColorTemperatureSupport': SearchCheckUtil.isNatureColorTemperatureSupport,
  'screenRefreshRatesSupport': SearchCheckUtil.isScreenRatesSupport,
  'wRCSupport': SearchCheckUtil.isSupportWrc,
  'fingerPrintSupport': SearchCheckUtil.isFingerPrintSupport,
  'oldPasswordActive': SearchCheckUtil.oldPasswordActive,
  'isFpSupportAppLock': SearchCheckUtil.isFpSupportAppLock,
  'faceAuthSupport': SearchCheckUtil.isFaceAuthSupport,
  'faceLoginAccount': SearchCheckUtil.faceLoginAccount,
  'isFaceEnrolled': SearchCheckUtil.isFaceEnrolled,
  'isFaceAuthType3D': SearchCheckUtil.isFaceAuthType3D,
  'isFaceSupportAppLock': SearchCheckUtil.isFaceSupportAppLock,
  'hasPinPassword': SearchCheckUtil.hasSetPinPassword,
  'hasSim': SearchCheckUtil.hasSim,
  'isSupportEID': SearchCheckUtil.isSupportEID,
  'hasVoiceCapability': SearchCheckUtil.hasVoiceCapability,
  'isPrivacyUser': SearchCheckUtil.isPrivacyUser,
  'isDevelopModeSupport': SearchCheckUtil.isDevelopModeSupport,
  'isSunlightReadabilitySupport': SearchCheckUtil.isSunlightReadabilitySupport,
  'isEflForbidden': SearchCheckUtil.isEflForbidden,
  'isNotDisturbCallShow': SearchCheckUtil.isNotDisturbCallShow,
  'isCertificationShow': SearchCheckUtil.isCertificationNotSupport,
  'isAutoTimeZoneOpen': SearchCheckUtil.isAutoTimeZoneOpen,
  'isSmallFoldProduct': DeviceUtil.isSmallFoldProduct,
  'isNexFormsProduct': DeviceUtil.isNexFormsProduct,
  'isSupportAppKeepAliveSettings': SearchCheckUtil.isSupportAppKeepAliveSettings,
  'isSupportShowPcTouchpadPage': SearchCheckUtil.isSupportShowPcTouchpadPage,
  'isSupportSearchPressAndShock': SearchCheckUtil.isSupportSearchPressAndShock,
  'isSupportSearchTouchpadEdgeGesture': SearchCheckUtil.isSupportSearchTouchpadEdgeGesture,
  'isSupportSearchTouchpadKnuckleGesture': SearchCheckUtil.isSupportSearchTouchpadKnuckleGesture,
  'isWhiperAwakeSupport': SearchCheckUtil.isWhiperAwakeSupport,
  'isUserSettingsEnable': SearchCheckUtil.isUserSettingsEnabled,
  'isSupportNotDisturb': SearchCheckUtil.isSupportNotDisturb,
  'isScreenLockToneSupport': SearchCheckUtil.isScreenLockToneSupport,
  'isSupportVibrate': SearchCheckUtil.isSupportVibrateAsync,
  'isRepeatedCallRinging': SearchCheckUtil.isRepeatedCallRinging,
  'isSupportAiVoice': SearchCheckUtil.isSupportAiVoice,
  'isSupportCallFilter': SearchCheckUtil.isSupportCallFilter,
  'isTextAutoFillSyncEnabled': SearchCheckUtil.isTextAutoFillSyncEnabled,
  'isOnlySmallFoldProduct': DeviceUtil.isOnlySmallFoldProduct,
  'hasPrivacyPassword': SearchCheckUtil.hasPrivacyPassword,
  'isStereoEnhancement': SearchCheckUtil.isStereoEnhancement,
  'isSupportRegionMirrorMode': SearchCheckUtil.isSupportRegionMirrorMode,
  'isSupportDeviceItem': SearchCheckUtil.isSupportDeviceItem,
  'isSupportUseAs': SearchCheckUtil.isSupportUseAs,
  'isSupportBootSoundSwitch': CapabilitySupportUtils.isSupportBootSoundSwitch,
  'isSupportMessage': SatelliteUtils.isSupportMessage,
  'isSupportSOS': SearchCheckUtil.isSupportSOS,
  // 开发者选项-显示刷新频率
  'refreshShow': SearchCheckUtil.refreshShow,
  'isQuickGestureProductSupport': SearchCheckUtil.isQuickGestureProductSupport,
  // 快捷手势-亮屏
  'isWakeScreenProductSupport': SearchCheckUtil.isWakeScreenProductSupport,
  // 支持国测版本名称展示
  'isItsecVersionNameSupport': SearchCheckUtil.isItsecVersionNameSupport,
  'isVersionTypeSupport': SearchCheckUtil.isVersionTypeSupport,
  // 单手兼容模式
  'isCompatibleMode': SearchCheckUtil.isCompatibleMode,
  'isEnterpriseCustomInfoSupport': SearchCheckUtil.isEnterpriseCustomInfoSupport,
  'hasSimCard': SearchCheckUtil.hasSimCard,
  // 使用新鼠标页面的配置
  'ifUseNewMousePage': SearchCheckUtil.isUseNewMousePage,
  'isPcDeviceInfoSupportShow': SearchCheckUtil.isPcDeviceInfoSupportShow,
  'isSupportSoundQuality': CapabilitySupportUtils.isSupportSoundQuality,
  'isNetSimulatorEnabled': SearchCheckUtil.isNetSimulatorEnabled,
  'isNetSimulatorCustomAddEnabled': SearchCheckUtil.isNetSimulatorCustomAddEnabled,
  'isSupportVowifiCardOne': SearchCheckUtil.isSupportVowifiCardOne,
  'isSupportVowifiCardTwo': SearchCheckUtil.isSupportVowifiCardTwo,
  'isOpenOuterAppListSupport': SearchCheckUtil.isOpenOuterAppListSupport,
  'isSupportKeyMouseHandEye': SearchCheckUtil.isSupportKeyMouseHandEye,
  'isSupportForcedLandscape': CapabilitySupportUtils.isSupportForcedLandscape,
  'isSwingEyeSupport': SearchCheckUtil.isSwingEyeSupport,
  'isSupportProximitySensor': SearchCheckUtil.isSupportProximitySensor,
  'isBionicVisionSupport': SearchCheckUtil.isBionicVisionSupport,
  'isOnlyColorTemperatureAdjustmentSupport': SearchCheckUtil.isColorTemperatureAdjustmentSupport,
  'isColorTemperatureAdjustmentSupport': DisplayUtils.isColorTemperatureAdjustmentSupport,
  'isColorAndColorTemperatureAdjustmentSupport': SearchCheckUtil.isColorAndColorTemperatureAdjustmentSupport,
  'isSupportAiHDRVideo': CapabilitySupportUtils.isSupportAiHDRVideo,
  'isEnableScreenClosedWaringTone': SearchCheckUtil.isEnableScreenClosedWaringTone,
  'isApiVersionSupport': SearchCheckUtil.isApiVersionSupport,
  'isOpenHarmonySupport': SearchCheckUtil.isOpenHarmonySupport,
  'isFlashReminderSupport': SearchCheckUtil.isFlashReminderSupport,
  'isSoundRecognitionSupport': SearchCheckUtil.isSoundRecognitionSupport,
  'isEnableCircleCursor': SearchCheckUtil.isEnableCircleCursor, // 使能圆形光标
  'isSupportNewNetworkPage': SearchCheckUtil.isSupportNewNetworkPage,
  'isSupportMobileNetworkPage': SearchCheckUtil.isSupportMobileNetworkPage,
  'isShowMobileNetworkWlanRankingResult': SearchCheckUtil.isShowMobileNetworkWlanRankingResult,
  'isShowNearlinkEntrance': SearchCheckUtil.isShowNearlinkEntrance,
  'isShowSystemFile': SearchCheckUtil.isShowSystemFile,
  'isShowVirtualMemory': SearchCheckUtil.isShowVirtualMemory,
  'isShowHibernationFile': SearchCheckUtil.isShowHibernationFile,
  'isShowFusionEntrance': SearchCheckUtil.isShowFusionEntrance,
  'isSupportRingtoneVibrationAdaptive': SearchCheckUtil.isSupportRingtoneVibrationAdaptive,
  'isHearingAidSupport': SearchCheckUtil.isHearingAidSupport,
  'isSuperFoldProduct': DeviceUtil.isSuperFoldProduct,
  'isShowFileSafeBox': SearchCheckUtil.isShowFileSafeBox,
  'isShowVirtualBezel': SearchCheckUtil.isShowVirtualBezel,
  'isShowProcessorSearch': SearchCheckUtil.isShowProcessorSearch
};

// 子项校验
const CHILD_ITEM_FUN_RECORD: Record<string, Function> = {
  'debug_outer_app': SearchCheckUtil.isOpenOuterAppSupport
}

const TAG = 'CheckItemUtil';

export class CheckItemUtil {
  static async checkItemEnable(searchItem: SearchItem, context?: common.Context): Promise<boolean> {
    if (CheckEmptyUtils.isEmpty(searchItem)) {
      return false;
    }

    let isItemEnable = searchItem.enable === '' || searchItem.enable === 'true' || searchItem.enable === undefined;
    if (CheckEmptyUtils.isEmpty(searchItem.checkItem) && CheckEmptyUtils.isEmpty(searchItem.checkItem?.type)) {
      LogUtil.showDebug(TAG, 'checkItemEnable item is empty');
      return isItemEnable;
    }

    let checkItem = searchItem.checkItem;
    if (CheckEmptyUtils.checkStrIsEmpty(checkItem.type) || CheckEmptyUtils.checkStrIsEmpty(checkItem.checkKey) ||
      CheckEmptyUtils.checkStrIsEmpty(checkItem.value)) {
      return isItemEnable;
    }

    switch (checkItem.type) {
      case CheckType.PARAM:
        return CheckItemUtil.getSystemParam(checkItem);
      case CheckType.PREFERENCE:
        return PreferencesUtil.getSync(checkItem.checkKey, '') === checkItem.value;
      case CheckType.SETTINGDATA:
        if (context) {
          return SettingsDataUtils.getSettingsDataWithContext(context, checkItem.checkKey, '') === checkItem.value;
        }
        return SettingsDataUtils.getSettingsData(checkItem.checkKey, '') === checkItem.value;
      case CheckType.FUNCTION: {
        if (ITEM_STATUS_FUN_RECORD[checkItem.checkKey]) {
          return await ITEM_STATUS_FUN_RECORD[checkItem.checkKey]() === (checkItem.value === 'true');
        }
        return isItemEnable;
      }
      default :
        return isItemEnable;
    }
  }

  private static getSystemParam(checkItem: CheckItem): boolean {
    try {
      let values: string[] = checkItem.value.split('|');
      let checkVaule: string = systemParameterEnhance.getSync(checkItem.checkKey);
      for (let value of values) {
        if (checkVaule === value) {
          LogUtil.showInfo(TAG, `checkKey: ${checkItem.checkKey}`);
          return true;
        }
      }
      return false;
    } catch (err) {
      LogUtil.showError(TAG, `getSystemParam error: ${err?.message}`);
      return false;
    }
  }

  /**
   * 检查子搜索项的使能状态
   * @param item 子项名称
   * @param value 默认值
   */
  static async checkChildItemEnable(item: string, value: boolean): Promise<boolean> {
    if (CHILD_ITEM_FUN_RECORD[item]) {
      return await CHILD_ITEM_FUN_RECORD[item]();
    }
    return value;
  }
}

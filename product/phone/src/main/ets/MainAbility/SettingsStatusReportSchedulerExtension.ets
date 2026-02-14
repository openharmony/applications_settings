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
import i18n from '@ohos.i18n';
import audio from '@ohos.multimedia.audio';
// import hgmnapi from '@ohos.libhgmnapi.z.so';
import Settings from '@ohos.settings';
import batteryInfo from '@ohos.batteryInfo';
import WorkSchedulerExtensionAbility from '@ohos.WorkSchedulerExtensionAbility';
import uiAppearance from '@ohos.uiAppearance';
import inputMethod from '@ohos.inputMethod';
import workScheduler from '@ohos.resourceschedule.workScheduler';
import systemParameter from '@ohos.systemparameter';
import power from '@ohos.power';
import wifiManager from '@ohos.wifiManager';
// import netQuality from '@hms.networkboost.netquality';
import { LogUtil } from '@ohos/settings.common/src/main/ets/utils/LogUtil';
import { SettingsDataUtils } from '@ohos/settings.common/src/main/ets/utils/SettingsDataUtils';
import { BrightnessController, SleepTime } from '@ohos/settings.display';
import { getNfcStatusForReport } from '@ohos/settings.moreconnection/src/main/ets/controller/NFCServiceController';
import { DisplayUtils } from '@ohos/settings.display/src/main/ets/DisplayUtils';
import { languageAndRegionModel } from '@ohos/settings.language/src/main/ets/model/LanguageAndRegionModel';
import { DateAndTimeUtil } from '@ohos/settings.datetime/src/main/ets/utils/DateAndTimeUtil';
import {
  SWITCH_OFF_VAL,
  SWITCH_ON_VAL
} from '@ohos/settings.common/src/main/ets/utils/Consts';
import { PreferencesUtil } from '@ohos/settings.common/src/main/ets/utils/PreferencesUtil';
import { CloneAppUtil } from '@ohos/settings.cloneapps/src/main/ets/util/CloneAppUtil';
import { AbilityContextManager } from '@ohos/settings.common/src/main/ets/ability/AbilityContextManager';
import { SystemParamUtil } from '@ohos/settings.common/src/main/ets/utils/SystemParamUtil';
import { HiSysEventUtil } from '@ohos/settings.common/src/main/ets/systemEvent/HiSysEventUtil';
import { SystemParamUtils } from '@ohos/settings.common/src/main/ets/screenReader/utils/SystemParamUtils';
import { DEFAULT_VOLUME_CONTROL_KEY, VOLUME_CONTROL_MEDIA_VALUE } from '../Setting/Volume/constant/VolumeConstant';
import {
  EventResultConsts,
  HotspotBandName,
  DEFAULT_CARD0_RINGTONE,
  DEFAULT_CARD0_RINGTONE_CN,
  DEFAULT_CARD1_RINGTONE,
  DEFAULT_CARD1_RINGTONE_CN,
  DEFAULT_MESSAGE_TONE,
  DEFAULT_MESSAGE_TONE_CN,
  DEFAULT_NOTIFICATION_TONE,
  DEFAULT_NOTIFICATION_TONE_CN,
  SimRingtoneKey
} from '@ohos/settings.common/src/main/ets/systemEvent/EventResultConsts';
import { SuperLauncherStateController } from
  '@ohos/settings.moreconnection/src/main/ets/controller/new/SuperLauncherStateController';
import {
  HiSysWlanStaticEventGroup,
  HiSysHotspotStaticEventGroup,
  HiSysNearLinkStaticEventGroup,
  HiSysBatteryStaticEventGroup,
  HiSysNfcStaticEventGroup,
  HiSysDisplayBrightnessStaticEventGroup,
  HiSysSystemAndUpdatesStaticEventGroup,
  HiSysMobileNetworkStaticEventGroup,
  HiSysBiometricsAndPwdStaticEventGroup,
  HiSysAccessibilityStaticEventGroup,
  HiSysModeConnectStaticEventGroup,
  HiSysSystemSettingsStaticEventGroup,
  HiSysVolumeGroup,
  HiSysAPBANDStaticEventGroup,
  HiSysMoreConnectionGroup,
  HiSysDeveloperOptionsGroup,
} from '@ohos/settings.common/src/main/ets/systemEvent/StaticEventConsts';
import { WifiUtils } from '@ohos/settings.wifi/src/main/ets/WifiUtils';
import {
  ColorPattern,
  ColorTemperaturePattern
} from '@ohos/settings.display/src/main/ets/DisplayUtils';
import { Constants } from '../pages/display/utils/Constants';
import {
  COVER_ENABLED,
  COVER_ENABLED_TRUE,
  COVER_MODE,
  COVER_TYPE,
  COVER_TYPE_ENABLED,
  SIMPLE_COVER,
  SMART_COVER
} from '../Setting/Display/Constant/Constant';
import { AccessibilityReportUtil } from '../Setting/Accessibility/utils/AccessibilityCommonModel';
import {
  ACCESSIBILITY_IGNORE_REPEAT_CLICK_ENABLED,
  ACCESSIBILITY_SHORTCUT_TARGETS_SERVICE,
  CLICK_SWITCH_OFF,
  CLICK_SWITCH_ON,
  SCREEN_MAGNIFICATION,
  SHORTCUT_ENABLED_ON_LOCK_SCREEN,
  ACCESSIBILITY_SOUND_RECOGNITION_SWITCH,
  ACCESSIBILITY_FLASH_REMINDER_SWITCH
} from '../Setting/Accessibility/constant/Constants';
import { HotSpotUtils } from '../Setting/MobileNetwork/HotSpot/utils/HotspotUtils';
// import { SettingsUtil } from '@hw-hmos/settings-face-auth/src/main/ets/faceauth/Utils/SettingsUtil';
import { TransitionAnimationValue } from '@ohos/settings.developeroptions';
import settings from '@ohos.settings';
import { SETTINGS_DISPLAY_BIONIC_VISION_SWITCH } from '@ohos/settings.display/src/main/ets/constant/DisplayConstant';
import IamHiSysPinEventUtils from '../pages/password/iambigdata/IamHiSysEventUtils';

/* instrument ignore file */
const KEY_AUTO_TIMEZONE: string = 'auto_timezone';
const KEY_WAKE_CLICK: string = 'settings.power.wakeup_double_click';
const KEY_WAKE_PICK_UP: string = 'settings.power.wakeup_pick_up';
const DEFAULT_PAY_APP = 'nfc_payment_default_app';
const NFC_NOT_DISTURB: string = 'settings.nfc.not_disturb';
const AUTOMATIC_SYSTEM_UPDATE_KEY: string = 'ota_disable_automatic_update';
const BOOT_SOUND_ENABLED: string = 'persist.graphic.bootsound.enabled';
const LOCKSCREEN_SOUNDS_ENABLED: string = 'lockscreen_sounds_enabled';
const ALWAYS_PLAY_SCREENSHOT_SOUND: string = 'always_play_screenshot_sound';
const PHYSIC_NAVI_HAPTIC_FEEDBACK_ENABLED: string = 'physic_navi_haptic_feedback_enabled';
const RINGTONE_VIBRATION_ADAPTIVE: string = 'ringtone_vibrate_adaptive_switch';
const HW_VIBRATE_WHEN_RINGING: string = 'hw_vibrate_when_ringing ';
const DIALPAD_TOUCH_TONE_TYPE: string = 'dialpad_touch_tone_type';
const FONT_WEIGHT_SCALE: string = 'font_weight_scale';
const DISPLAY_RESOLUTION_SWITCH: string = 'settings.display.resolution_smart_switch';
const INTELLIGENCE_NETWORK_SWITCHING: string = 'intelligence_network_switching';
const EYE_COMFORT_MODE: string = 'settings.display.eye_comfort_mode';
const EBOOK_SWITCH: string = 'settings.display.ebook_switch';
const EYE_COMFORT_LEVEL: string = 'settings.display.eye_comfort_level';
const EYE_DC_BRIGHTNESS_SWITCH: string = 'settings.display.eye_dc_brightness_switch';
const WAKEUP_GAZE_SWITCH: string = 'item_wakeup_gaze_switch';
const FORCED_LANDSCAPE_SWITCH: string = 'LandscapeWindow_Enable';
const PICTURE_HDR_SWITCH: string = 'settings.display.hdr_picture_switch';
const AIHDR_VIDEO_SWITCH: string = 'settings.display.AiHDR_video_switch';
const BIONIC_VISION_SWITCH: string = 'settings.display.prog_disp_switch';
const CUTOUTS_PARAM: string = 'persist.sys.graphic.hideNotch.status';
const VOLUME_INTELLIGENT_CALL_STATUS: string = 'ai_voice_noise_suppression_flag'
const SETTINGS_DEVELOPER_CHARGE_TEMPERATURE_CONTROLLER_ENABLE: string = 'settings.developer.charge_temperature_control_enable';

const SWITCH_DIRTYREGIONDEBUG_NAME: string = 'rosen.dirtyregiondebug.enabled';
const SWITCH_FREEZE_DETECTOR_NAME: string = 'persist.hiview.freeze_detector';
const SWITCH_LEAK_DETECTOR_NAME: string = 'persist.hiview.leak_detector';
const SWITCH_OVERDRAW_NAME: string = 'debug.graphic.overdraw';
const SWITCH_DRAWINGCACHE_NAME: string = 'rosen.drawingCache.enabledDfx';
const SETTINGS_INPUT_SHOW_TOUCH_HINT: string = 'settings.input.show_touch_hint';
const SETTINGS_DEVELOPER_SHOW_TOUCH_TRACK: string = 'settings.developer.show_touch_track';
export const NATURAL_LIGHT_SWITCHES_TABLE: string = 'settings.display.natural_light_switch';
const SYSTEM_PARAMETER_HIVIEWDFX_XPOWER_USB_STATE: string = 'persist.hiviewdfx.xpower.usb_state';
const SETTINGS_SWITCH_WLAN_LOGS: string = 'settings.switch_wlan_logs';
const SETTINGS_DEVELOPER_CHARGE_ATOMICSERVICE_DEBUG_ENABLE: string = 'settings.developer.atomicservice_debug_enable';
const SWITCH_TRACE_RECORDER_NAME: string = 'persist.hiview.trace_recorder';
const MULTI_WINDOW_DEBUG_PARAM_KEY = 'persist.debug.multi_window';
const ARKUI_ANIMATION_SCALE_NAME: string = 'persist.sys.arkui.animationscale';
const DEBUG_OUTER_APP_KEY: string = 'debug.outer.app';
const SWITCH_DISABLE: string = '0';
const SWITCH_ENABLE: string = '6';
const WEEK_REPEAT: string = '2';
const TAG: string = 'SettingsStatusReportSchedulerExtensionAbility : ';

export default class SettingsStatusReportSchedulerExtensionAbility extends WorkSchedulerExtensionAbility {
  // 延迟任务开始回调
  onWorkStart(workInfo?: workScheduler.WorkInfo) {
    LogUtil.info(`${TAG} onWorkStart, workInfo is.`);
    AbilityContextManager.addContext(this.context);
    this.getSmartCoverEvent();
    for (let eventName of statusValueMap.keys()) {
      let value: string = '';
      let valueFunc = statusValueMap.get(eventName);
      if (valueFunc) {
        try {
          value = valueFunc();
          HiSysEventUtil.reportUEStatisticEvent(eventName, value);
        } catch (e) {
          LogUtil.error(`${TAG} try to report status fail. eventName: ${eventName}, error: ${e}, value: ${value}`);
        }
      }
    }
    // 上报辅助功能应用开关状态数据
    AccessibilityReportUtil.reportStatisticEvent();
    // 上报phone端应用分身周期数据
    CloneAppUtil.reportCloneAppStatisticEvent();
    // 上报人脸用户配置数据
    // SettingsUtil.reportUserConfigStatus();
    // 上报用户pin码类型数据
    IamHiSysPinEventUtils.reportPasswordTypeStatus();
  }

  // 延迟任务结束回调
  onWorkStop(workInfo: workScheduler.WorkInfo) {
    AbilityContextManager.removeContext(this.context);
    LogUtil.info(`${TAG} onWorkStop, workInfo is.`);
  }

  private getSmartCoverEvent(): void {
    let coverMode: string = SystemParamUtil.getParam(COVER_MODE, '');
    if (coverMode == SMART_COVER) {
      statusValueMap.set(HiSysAccessibilityStaticEventGroup.SMART_COVER_STATUS, (): string => {
        return SettingsDataUtils.getSettingsData(COVER_ENABLED, COVER_ENABLED_TRUE) == COVER_ENABLED_TRUE ?
          EventResultConsts.SWITCH_ON : EventResultConsts.SWITCH_OFF;
      });
      statusValueMap.set(HiSysAccessibilityStaticEventGroup.SMART_COVER_WITH_WINDOW_STATUS, (): string => {
        return SettingsDataUtils.getSettingsData(COVER_TYPE, COVER_TYPE_ENABLED) == COVER_TYPE_ENABLED ?
          EventResultConsts.SWITCH_ON : EventResultConsts.SWITCH_OFF;
        ;
      });
    }
    if (coverMode == SIMPLE_COVER) {
      statusValueMap.set(HiSysAccessibilityStaticEventGroup.SMART_COVER_STATUS, (): string => {
        return SettingsDataUtils.getSettingsData(COVER_ENABLED, COVER_ENABLED_TRUE) == COVER_ENABLED_TRUE ?
          EventResultConsts.SWITCH_ON : EventResultConsts.SWITCH_OFF;
      });
    }
  }
}

let statusValueMap = new Map<string, () => string>([
  [HiSysVolumeGroup.VOLUME_INTELLIGENT_CALL_STATUS, (): string => {
    return SettingsDataUtils.getSettingsData(VOLUME_INTELLIGENT_CALL_STATUS, '0') === '1' ?
    EventResultConsts.SWITCH_ON : EventResultConsts.SWITCH_OFF;
  }],
  [HiSysVolumeGroup.CALL_RINGTONE_STATUS_CARD_ONE, (): string => {
    let curLocale: string = i18n.System.getSystemLocale();
    let defaultTone: string = curLocale === 'zh-Hans-CN' ? DEFAULT_CARD0_RINGTONE_CN : DEFAULT_CARD0_RINGTONE;
    let curToneForCard0: string = PreferencesUtil.getSync(SimRingtoneKey.CARD_0_RINGTONE_KEY, defaultTone) as string;
    return curToneForCard0;
  }],
  [HiSysVolumeGroup.CALL_RINGTONE_STATUS_CARD_TWO, (): string => {
    let curLocale: string = i18n.System.getSystemLocale();
    let defaultTone: string = curLocale === 'zh-Hans-CN' ? DEFAULT_CARD1_RINGTONE_CN : DEFAULT_CARD1_RINGTONE;
    let curToneForCard1: string = PreferencesUtil.getSync(SimRingtoneKey.CARD_1_RINGTONE_KEY, defaultTone) as string;
    return curToneForCard1;
  }],
  [HiSysVolumeGroup.INFORMATION_RINGTONE_STATUS_ONE, (): string => {
    let curLocale: string = i18n.System.getSystemLocale();
    let defaultTone: string = curLocale === 'zh-Hans-CN' ? DEFAULT_MESSAGE_TONE_CN : DEFAULT_MESSAGE_TONE;
    let curToneForCard0: string = PreferencesUtil.getSync(SimRingtoneKey.CARD_0_SMS_RINGTONE_KEY,
      defaultTone) as string;
    return curToneForCard0;
  }],
  [HiSysVolumeGroup.INFORMATION_RINGTONE_STATUS_TWO, (): string => {
    let curLocale: string = i18n.System.getSystemLocale();
    let defaultTone: string = curLocale === 'zh-Hans-CN' ? DEFAULT_MESSAGE_TONE_CN : DEFAULT_MESSAGE_TONE;
    let curToneForCard1: string = PreferencesUtil.getSync(SimRingtoneKey.CARD_1_SMS_RINGTONE_KEY,
      defaultTone) as string;
    return curToneForCard1;
  }],
  [HiSysVolumeGroup.NOTIFICATION_RINGTONE_STATUS, (): string => {
    let curLocale: string = i18n.System.getSystemLocale();
    let defaultTone: string = curLocale === 'zh-Hans-CN' ? DEFAULT_NOTIFICATION_TONE_CN : DEFAULT_NOTIFICATION_TONE;
    let curTone: string = PreferencesUtil.getSync(SimRingtoneKey.NOTIFICATION_RINGTONE_KEY,
      defaultTone) as string;
    return curTone;
  }],
  [HiSysDisplayBrightnessStaticEventGroup.EYE_MODE_ALL_DAY_STATUS, (): string => {
    return SettingsDataUtils.getSettingsDataDomain(EYE_COMFORT_MODE, '0',
      Settings.domainName.USER_PROPERTY) === '1' ? EventResultConsts.SWITCH_ON : EventResultConsts.SWITCH_OFF;
  }],
  [HiSysDisplayBrightnessStaticEventGroup.EYE_MODE_SCHEDULED_STATUS, (): string => {
    let eyeMode = SettingsDataUtils.getSettingsDataDomain(EYE_COMFORT_MODE, '0',
      Settings.domainName.USER_PROPERTY);
    return (eyeMode === '2' || eyeMode === '3') ? EventResultConsts.SWITCH_ON : EventResultConsts.SWITCH_OFF;
  }],
  [HiSysDisplayBrightnessStaticEventGroup.EYE_COMFORT_LEVEL_STATUS, (): string => {
    return SettingsDataUtils.getSettingsDataDomain(EYE_COMFORT_LEVEL, '0', Settings.domainName.USER_PROPERTY);
  }],
  [HiSysDisplayBrightnessStaticEventGroup.EYE_DC_BRIGHTNESS_STATUS, (): string => {
    return SettingsDataUtils.getSettingsDataDomain(EYE_DC_BRIGHTNESS_SWITCH, '0',
      Settings.domainName.USER_PROPERTY) === '1' ? EventResultConsts.SWITCH_ON : EventResultConsts.SWITCH_OFF;
  }],
  [HiSysDisplayBrightnessStaticEventGroup.EBOOK_MODE_STATUS, (): string => {
    return SettingsDataUtils.getSettingsDataDomain(EBOOK_SWITCH, '0',
      Settings.domainName.USER_PROPERTY) === '1' ? EventResultConsts.SWITCH_ON : EventResultConsts.SWITCH_OFF;
  }],
  [HiSysDisplayBrightnessStaticEventGroup.WAKEUP_GAZE_STATUS, (): string => {
    return SettingsDataUtils.getSettingsDataDomain(WAKEUP_GAZE_SWITCH, '0',
      Settings.domainName.USER_SECURITY) === '1' ? EventResultConsts.SWITCH_ON : EventResultConsts.SWITCH_OFF;
  }],
  [HiSysDisplayBrightnessStaticEventGroup.HIDE_SCREEN_CUTOUTS_STATUS, (): string => {
    return SystemParamUtil.getParam(CUTOUTS_PARAM, '0') === '2' ? EventResultConsts.SWITCH_ON : EventResultConsts.SWITCH_OFF;
  }],
  [HiSysDisplayBrightnessStaticEventGroup.FORCED_LANDSCAPE_STATUS, (): string => {
    return SettingsDataUtils.getSettingsDataDomain(FORCED_LANDSCAPE_SWITCH, '0',
      Settings.domainName.DEVICE_SHARED) === '1' ? EventResultConsts.SWITCH_ON : EventResultConsts.SWITCH_OFF;
  }],
  [HiSysDisplayBrightnessStaticEventGroup.PICTURE_HDR_STATUS, (): string => {
    return SettingsDataUtils.getSettingsDataDomain(PICTURE_HDR_SWITCH, '1',
      Settings.domainName.DEVICE_SHARED) === '1' ? EventResultConsts.SWITCH_ON : EventResultConsts.SWITCH_OFF;
  }],
  [HiSysDisplayBrightnessStaticEventGroup.AIVIDEO_HDR_STATUS, (): string => {
    return SettingsDataUtils.getSettingsDataDomain(AIHDR_VIDEO_SWITCH, '1',
      Settings.domainName.DEVICE_SHARED) === '1' ? EventResultConsts.SWITCH_ON : EventResultConsts.SWITCH_OFF;
  }],
  [HiSysDisplayBrightnessStaticEventGroup.SMART_RESOLUTION_STATUS, (): string => {
    return SettingsDataUtils.getSettingsData(DISPLAY_RESOLUTION_SWITCH, '0') === '1' ?
    EventResultConsts.SWITCH_ON : EventResultConsts.SWITCH_OFF;
  }],
  [HiSysDisplayBrightnessStaticEventGroup.FONT_WEIGHT_STATUS, (): string => {
    return SettingsDataUtils.getSettingsData(FONT_WEIGHT_SCALE, '1');
  }],
  [HiSysDisplayBrightnessStaticEventGroup.FONT_SIZE_STATUS, (): string => {
    return SettingsDataUtils.getSettingsData(Settings.display.FONT_SCALE, '1');
  }],
  [HiSysVolumeGroup.VOLUME_MODE_STATUS, (): string => {
    let audioRingMode = getRingMode();
    return String(audioRingMode);
  }],
  [HiSysVolumeGroup.DIAL_TONE_STATUS, (): string => {
    return SettingsDataUtils.getSettingsDataDomain(DIALPAD_TOUCH_TONE_TYPE, '1', Settings.domainName.USER_PROPERTY);
  }],
  [HiSysVolumeGroup.VIBRATE_WHEN_RING_STATUS, (): string => {
    return SettingsDataUtils.getSettingsDataDomain(HW_VIBRATE_WHEN_RINGING, '1', Settings.domainName.USER_PROPERTY) === '1' ?
      EventResultConsts.SWITCH_ON : EventResultConsts.SWITCH_OFF;
  }],
  [HiSysVolumeGroup.BOOT_SOUND_STATUS, (): string => {
    return SystemParamUtil.getParam(BOOT_SOUND_ENABLED, '1') === '1' ?
    EventResultConsts.SWITCH_ON : EventResultConsts.SWITCH_OFF;
  }],
  [HiSysVolumeGroup.SCREEN_LOCK_TONE_STATUS, (): string => {
    return SettingsDataUtils.getSettingsData(LOCKSCREEN_SOUNDS_ENABLED, '1') === '1' ?
      EventResultConsts.SWITCH_ON : EventResultConsts.SWITCH_OFF;
  }],
  [HiSysVolumeGroup.SCREENSHOT_PROMPT_TONE_STATUS, (): string => {
    return SettingsDataUtils.getSettingsData(ALWAYS_PLAY_SCREENSHOT_SOUND, '1') === '1' ?
      EventResultConsts.SWITCH_ON : EventResultConsts.SWITCH_OFF;
  }],
  [HiSysVolumeGroup.SYSTEM_TOUCH_FEEDBACK_STATUS, (): string => {
    return SettingsDataUtils.getSettingsData(PHYSIC_NAVI_HAPTIC_FEEDBACK_ENABLED, '1',) === '1' ?
      EventResultConsts.SWITCH_ON : EventResultConsts.SWITCH_OFF;
  }],
  [HiSysVolumeGroup.VOLUME_RINGTONE_VIBRATION_STATUS, (): string => {
    return SettingsDataUtils.getSettingsData(RINGTONE_VIBRATION_ADAPTIVE, 'true') === 'true' ?
    EventResultConsts.SWITCH_ON : EventResultConsts.SWITCH_OFF;
  }],
  [HiSysNfcStaticEventGroup.NFC_STATUS, (): string => {
    return getNfcStatusForReport() ? EventResultConsts.SWITCH_ON : EventResultConsts.SWITCH_OFF;
  }],
  [HiSysNfcStaticEventGroup.NFC_NOT_DISTURB_STATUS, (): string => {
    return SettingsDataUtils.getSettingsData(NFC_NOT_DISTURB, '1',) === '1' ? EventResultConsts.SWITCH_ON :
    EventResultConsts.SWITCH_OFF;
  }],
  [HiSysDisplayBrightnessStaticEventGroup.SCREEN_BRIGHTNESS_STATUS, (): string => {
    let brightness = Settings.getValueSync((AppStorage.get<Context>('pageContext') as Context),
      Settings.display.SCREEN_BRIGHTNESS_STATUS, BrightnessController.DEFAULT_BRIGHTNESS);
    return Math.min(Number(brightness), BrightnessController.MAX_BRIGHTNESS).toString();
  }],
  [HiSysDisplayBrightnessStaticEventGroup.AUTO_SCREEN_BRIGHTNESS_STATUS, (): string => {
    return SettingsDataUtils.getSettingsData(Settings.display.AUTO_SCREEN_BRIGHTNESS,
      '1') == '1' ? EventResultConsts.SWITCH_ON : EventResultConsts.SWITCH_OFF;
  }],
  [HiSysDisplayBrightnessStaticEventGroup.SCREEN_ZOOM_STATUS, (): string => {
    return DisplayUtils.getScreenZoom().toString();
  }],
  [HiSysDisplayBrightnessStaticEventGroup.SCREEN_REFRESH_TYPE_STATUS, (): string => {
    return DisplayUtils.getScreenRefreshType().toString();
  }],
  [HiSysDisplayBrightnessStaticEventGroup.SCREEN_OFF_TIMEOUT_STATUS, (): string => {
    return SettingsDataUtils.getSettingsData(Settings.display.SCREEN_OFF_TIMEOUT,
      SleepTime.THIRTY_SECONDS);
  }],
  [HiSysDisplayBrightnessStaticEventGroup.COLOR_MODE_STATUS, (): string => {
    return SettingsDataUtils.getSettingsDataDomain('settings.color_mode', ColorPattern.STANDARD,
      Settings.domainName.USER_PROPERTY);
  }],
  [HiSysDisplayBrightnessStaticEventGroup.COLOR_TEMPERATURE_STATUS, (): string => {
    return SettingsDataUtils.getSettingsDataDomain('settings.color_temperature', ColorTemperaturePattern.DEFAULT,
      Settings.domainName.USER_PROPERTY);
  }],
  [HiSysDisplayBrightnessStaticEventGroup.RESOLUTION_STATUS, (): string => {
    return SettingsDataUtils.getSettingsData('settings.display.resolution_mode', Constants.SCREEN_RESOLUTION_HIGH_KEY);
  }],
  [HiSysSystemAndUpdatesStaticEventGroup.LANGUAGE_STATUS, (): string => {
    return languageAndRegionModel.getSystemLanguage();
  }],
  [HiSysSystemAndUpdatesStaticEventGroup.REGION_STATUS, (): string => {
    return languageAndRegionModel.getSystemRegion();
  }],
  [HiSysSystemAndUpdatesStaticEventGroup.TIME_FORMAT_HOUR_STATUS, (): string => {
    return DateAndTimeUtil.get24HourTimeFormat() ? EventResultConsts.SWITCH_ON : EventResultConsts.SWITCH_OFF;
  }],
  [HiSysSystemAndUpdatesStaticEventGroup.AUTO_TIMEZONE_STATUS, (): string => {
    return systemParameter.getSync('persist.time.auto_time', 'ON') === 'ON' ? EventResultConsts.SWITCH_ON :
      EventResultConsts.SWITCH_OFF;
  }],
  [HiSysDisplayBrightnessStaticEventGroup.DARK_MODE_STATUS, (): string => {
    return uiAppearance.getDarkMode() === uiAppearance.DarkMode.ALWAYS_DARK ? EventResultConsts.SWITCH_ON :
      EventResultConsts.SWITCH_OFF;
  }],
  [HiSysDisplayBrightnessStaticEventGroup.EYE_COMFORT_STATUS, (): string => {
    return SettingsDataUtils.getSettingsDataDomain('settings.eyeshield.enable', '0',
      Settings.domainName.USER_PROPERTY) === '1' ? EventResultConsts.SWITCH_ON : EventResultConsts.SWITCH_OFF;
  }],
  [HiSysMobileNetworkStaticEventGroup.AIR_PLANE_MODE_STATUS, (): string => {
    return SettingsDataUtils.getSettingsData('settings.telephony.airplanemode', '0') !== '0' ?
      EventResultConsts.SWITCH_ON : EventResultConsts.SWITCH_OFF;
  }],
  [HiSysBiometricsAndPwdStaticEventGroup.FP_KEYGUARD_STATUS, (): string => {
    return Settings.getValueSync((AppStorage.get<Context>('pageContext') as Context),
      'fp_keyguard_enable', '0', Settings.domainName.USER_SECURITY) !== '0' ? EventResultConsts.SWITCH_ON :
        EventResultConsts.SWITCH_OFF;
  }],
  [HiSysSystemAndUpdatesStaticEventGroup.INPUT_METHOD_STATUS, (): string => {
    return inputMethod.getCurrentInputMethod()?.name ?? '';
  }],
  [HiSysSystemAndUpdatesStaticEventGroup.DOUBLE_CLICK_LOCK_SCREEN_STATUS, (): string => {
    return (SettingsDataUtils.getSettingsDataDomain('settings.double_click_lock_screen_switch', '0',
      settings.domainName.USER_PROPERTY) === '1') ? 'on' : 'off';
  }],
  [HiSysAccessibilityStaticEventGroup.WAKE_PICK_UP_SWITCH_UE, (): string => {
    return SettingsDataUtils.getSettingsData(KEY_WAKE_PICK_UP, '0', Settings.domainName.USER_SECURITY) === '1' ?
      EventResultConsts.SWITCH_ON : EventResultConsts.SWITCH_OFF;
  }],
  [HiSysAccessibilityStaticEventGroup.WAKE_DOUBLE_CLICK_SWITCH_UE, (): string => {
    return SettingsDataUtils.getSettingsData(KEY_WAKE_CLICK, '0', Settings.domainName.USER_SECURITY) === '1' ?
      EventResultConsts.SWITCH_ON : EventResultConsts.SWITCH_OFF;
  }],
  [HiSysAccessibilityStaticEventGroup.SHORTKEY_LOCK_SCREEN_STATUS, (): string => {
    return SettingsDataUtils.getSecureValue(SHORTCUT_ENABLED_ON_LOCK_SCREEN, CLICK_SWITCH_OFF) === CLICK_SWITCH_ON ?
      EventResultConsts.SWITCH_ON : EventResultConsts.SWITCH_OFF;
  }],
  [HiSysAccessibilityStaticEventGroup.A11Y_FUNCTION_SELECT_TARGETS, (): string => {
    return SettingsDataUtils.getSecureValue(ACCESSIBILITY_SHORTCUT_TARGETS_SERVICE, '');
  }],
  [HiSysAccessibilityStaticEventGroup.ZOOM_GESTURE_SWITCH_STATUS, (): string => {
    return SettingsDataUtils.getSecureValue(SCREEN_MAGNIFICATION, CLICK_SWITCH_OFF) === CLICK_SWITCH_ON ?
      EventResultConsts.SWITCH_ON : EventResultConsts.SWITCH_OFF;
  }],
  [HiSysAccessibilityStaticEventGroup.IGNORE_REPEAT_TOUCHES_STATUS, (): string => {
    return SettingsDataUtils.getSettingsData(ACCESSIBILITY_IGNORE_REPEAT_CLICK_ENABLED, CLICK_SWITCH_OFF) ===
      CLICK_SWITCH_ON ? EventResultConsts.SWITCH_ON : EventResultConsts.SWITCH_OFF;
  }],
  [HiSysAccessibilityStaticEventGroup.SOUND_RECOG_MAIN_SWITCH_STATUS, (): string => {
    return SettingsDataUtils.getSecureValue(ACCESSIBILITY_SOUND_RECOGNITION_SWITCH, CLICK_SWITCH_OFF) ===
      CLICK_SWITCH_ON ? EventResultConsts.SWITCH_ON : EventResultConsts.SWITCH_OFF;
  }],
  [HiSysAccessibilityStaticEventGroup.FLASH_REMIND_MAIN_SWITCH_STATUS, (): string => {
    return SettingsDataUtils.getSecureValue(ACCESSIBILITY_FLASH_REMINDER_SWITCH, CLICK_SWITCH_OFF) ===
      CLICK_SWITCH_ON ? EventResultConsts.SWITCH_ON : EventResultConsts.SWITCH_OFF;
  }],
  [HiSysHotspotStaticEventGroup.HOTSPOT_STATUS, (): string => {
    return wifiManager.isHotspotActive() ? EventResultConsts.SWITCH_ON : EventResultConsts.SWITCH_OFF;
  }],
  [HiSysWlanStaticEventGroup.WIFI_STATUS, (): string => {
    return WifiUtils.isWifiEnabled() ? EventResultConsts.SWITCH_ON : EventResultConsts.SWITCH_OFF;
  }],
  [HiSysBatteryStaticEventGroup.WIRELESS_REVERSE_STATUS, (): string => {
    return batteryInfo.getBatteryConfig('wireless_tx') === '1' ? EventResultConsts.SWITCH_ON :
      EventResultConsts.SWITCH_OFF;
  }],
  [HiSysBatteryStaticEventGroup.BATTERY_SAVE_MODE_STATUS, (): string => {
    return power.getPowerMode() === power.DevicePowerMode.MODE_POWER_SAVE ? EventResultConsts.SWITCH_ON :
      EventResultConsts.SWITCH_OFF;
  }],
  [HiSysNfcStaticEventGroup.DEFAULT_NFC_PAY_STATUS, (): string => {
    return SettingsDataUtils.getSettingsData(DEFAULT_PAY_APP, '');
  }],
  [HiSysSystemSettingsStaticEventGroup.AUTOMATIC_SYSTEM_UPDATE_STATUS, (): string => {
    return SettingsDataUtils.getSettingsData(AUTOMATIC_SYSTEM_UPDATE_KEY, '1') === '1' ? EventResultConsts.SWITCH_ON :
      EventResultConsts.SWITCH_OFF;
  }],
  [HiSysAPBANDStaticEventGroup.AP_BAND_STATUS, (): string => {
    return HotSpotUtils.getHotspotConfig()?.band === 0 ? HotspotBandName.HOTSPOT_BAND_2_4 :
    HotspotBandName.HOTSPOT_BAND_5;
  }],
  [HiSysBatteryStaticEventGroup.BATTERY_PERCENTAGE_STATUS, (): string => {
    return SettingsDataUtils.getSecureValue('status_bar_show_battery_soc', 'true') === 'true' ?
      EventResultConsts.SWITCH_ON : EventResultConsts.SWITCH_OFF;
  }],
  [HiSysMoreConnectionGroup.COLLABORATION_STATUS, (): string => {
    return SettingsDataUtils.getSettingsData('Continue_Switch_Status', '1',
      Settings.domainName.USER_SECURITY) === '1' ? EventResultConsts.SWITCH_ON : EventResultConsts.SWITCH_OFF;
  }],
  [HiSysMoreConnectionGroup.SUPER_DESKTOP_STATUS, (): string => {
    return SuperLauncherStateController.getInstance().getSuperLauncherEnable() ? EventResultConsts.SWITCH_ON :
      EventResultConsts.SWITCH_OFF;
  }],
  [HiSysMoreConnectionGroup.KEYBOARD_MOUSE_SHARE_STATUS, (): string => {
    return SettingsDataUtils.getSettingsData('associate_assistant_state',
      '0', Settings.domainName.USER_SECURITY) === '1' ? EventResultConsts.SWITCH_ON : EventResultConsts.SWITCH_OFF;
  }],
  [HiSysMobileNetworkStaticEventGroup.NETWORK_OPTIMIZATION_STATUS, (): string => {
    return SettingsDataUtils.getSettingsData(INTELLIGENCE_NETWORK_SWITCHING, '0') === '1' ?
      EventResultConsts.SWITCH_ON : EventResultConsts.SWITCH_OFF;
  }],


  // 开发者选项
  [HiSysDeveloperOptionsGroup.DEVELOPER_MODE_STATUS, (): string => {
    return SystemParamUtil.getParam('const.security.developermode.state', '0') === '1' ?
    EventResultConsts.SWITCH_ON : EventResultConsts.SWITCH_OFF;
  }],
  // 充电温度限制
  [HiSysDeveloperOptionsGroup.TURN_OFF_CHARGING_LIMIT_STATUS, (): string => {
    return SettingsDataUtils.getSettingsData(SETTINGS_DEVELOPER_CHARGE_TEMPERATURE_CONTROLLER_ENABLE, 'false') ===
      'false' ? EventResultConsts.SWITCH_OFF : EventResultConsts.SWITCH_ON;
  }],
  // 显示刷新频率
  [HiSysDeveloperOptionsGroup.DISPLAY_REFRESH_FREQUENCY_STATUS, (): string => {
    let state: number = 0
    try {
      //获取当前设置中 显示刷新频率的状态
      // let state: number = hgmnapi.getShowRefreshRateEnabled();
      LogUtil.info(`${TAG} getShowRefreshRateState : ${state}`);
    } catch (err) {
      state = 0
    }
    return state === 1 ?
    EventResultConsts.SWITCH_ON : EventResultConsts.SWITCH_OFF;
  }],
  // 关闭充电
  [HiSysDeveloperOptionsGroup.TURN_OFF_CHARGING_STATUS, (): string => {
    return systemParameter.getSync(SYSTEM_PARAMETER_HIVIEWDFX_XPOWER_USB_STATE, 'false') === 'true' ?
    EventResultConsts.SWITCH_ON : EventResultConsts.SWITCH_OFF;
  }],
  // 阳光下可读性
  [HiSysDeveloperOptionsGroup.READABILITY_IN_THE_SUN_STATUS, (): string => {
    return SettingsDataUtils.getSettingsData(NATURAL_LIGHT_SWITCHES_TABLE, '1', Settings.domainName.USER_PROPERTY) ===
      '1' ?
    EventResultConsts.SWITCH_ON : EventResultConsts.SWITCH_OFF;
  }],
  // 系统trace分析
  [HiSysDeveloperOptionsGroup.SYSTEM_TRACE_ANALYSIS_STATUS, (): string => {
    return systemParameter.getSync(SWITCH_TRACE_RECORDER_NAME, SWITCH_DISABLE) === 'true' ?
    EventResultConsts.SWITCH_ON : EventResultConsts.SWITCH_OFF;
  }],
  // 冻屏信息日志
  [HiSysDeveloperOptionsGroup.FROZEN_SCREEN_INFORMATION_STATUS, (): string => {
    return systemParameter.getSync(SWITCH_FREEZE_DETECTOR_NAME, SWITCH_DISABLE) === 'true' ?
    EventResultConsts.SWITCH_ON : EventResultConsts.SWITCH_OFF;
  }],
  // 系统资源泄漏日志
  [HiSysDeveloperOptionsGroup.SYSTEM_RESOURCE_LEAKAGE_STATUS, (): string => {
    return systemParameter.getSync(SWITCH_LEAK_DETECTOR_NAME, 'disable') === 'disable' ?
    EventResultConsts.SWITCH_ON : EventResultConsts.SWITCH_OFF;
  }],
  // 开启WLAN详细日志记录
  [HiSysDeveloperOptionsGroup.WLAN_DETAILED_LOG_RECORDING_STATUS, (): string => {
    return SettingsDataUtils.getSettingsData(SETTINGS_SWITCH_WLAN_LOGS, 'false') === 'true' ?
    EventResultConsts.SWITCH_ON : EventResultConsts.SWITCH_OFF;
  }],
  // 显示触摸操作
  [HiSysDeveloperOptionsGroup.SHOW_TOUCH_ACTIONS_STATUS, (): string => {
    return SettingsDataUtils.getSettingsData(SETTINGS_INPUT_SHOW_TOUCH_HINT, 'false') === 'true' ?
    EventResultConsts.SWITCH_ON : EventResultConsts.SWITCH_OFF;
  }],
  // 指针位置
  [HiSysDeveloperOptionsGroup.POINTER_POSITION_STATUS, (): string => {
    return SettingsDataUtils.getSettingsData(SETTINGS_DEVELOPER_SHOW_TOUCH_TRACK, 'false') === 'true' ?
    EventResultConsts.SWITCH_ON : EventResultConsts.SWITCH_OFF;
  }],
  // 显示布局界面
  [HiSysDeveloperOptionsGroup.DISPLAY_LAYOUT_INTERFACE_STATUS, (): string => {
    return systemParameter.getSync('persist.ace.debug.boundary.enabled') === 'true' ?
    EventResultConsts.SWITCH_ON : EventResultConsts.SWITCH_OFF;
  }],
  // 显示重绘刷新区域
  [HiSysDeveloperOptionsGroup.SHOW_REDRAW_REFRESH_REGION_STATUS, (): string => {
    return systemParameter.getSync(SWITCH_DIRTYREGIONDEBUG_NAME, SWITCH_DISABLE) === SWITCH_ENABLE ?
    EventResultConsts.SWITCH_ON : EventResultConsts.SWITCH_OFF;
  }],
  // 缓存是否命中检测
  [HiSysDeveloperOptionsGroup.CACHE_HIT_DETECTION_STATUS, (): string => {
    return systemParameter.getSync(SWITCH_DRAWINGCACHE_NAME, SWITCH_DISABLE) === '0' ?
    EventResultConsts.SWITCH_OFF : EventResultConsts.SWITCH_ON;
  }],
  // 过度绘制检测
  [HiSysDeveloperOptionsGroup.OVERDRAWING_DETECTION_STATUS, (): string => {
    return systemParameter.getSync(SWITCH_OVERDRAW_NAME, SWITCH_DISABLE) === 'false' ?
    EventResultConsts.SWITCH_OFF : EventResultConsts.SWITCH_ON;
  }],
  // 过度动画缩放
  [HiSysDeveloperOptionsGroup.OVER_ANIMATED_SCALING_STATUS, (): string => {
    return systemParameter.getSync(ARKUI_ANIMATION_SCALE_NAME,
      TransitionAnimationValue.ANIMATION_SCALE_1_0_VALUE)
  }],
  // 强制将应用界面设为可调整大小
  [HiSysDeveloperOptionsGroup.TO_BE_RESIZEABLE_STATUS, (): string => {
    return SystemParamUtils.getSystemParam(MULTI_WINDOW_DEBUG_PARAM_KEY, 'false') === 'true' ?
    EventResultConsts.SWITCH_ON : EventResultConsts.SWITCH_OFF;
  }],
  // 开发中元服务豁免管控
  [HiSysDeveloperOptionsGroup.SERVICE_EXEMPTION_CONTROL_STATUS, (): string => {
    return SettingsDataUtils.getSettingsData(SETTINGS_DEVELOPER_CHARGE_ATOMICSERVICE_DEBUG_ENABLE, 'false') === '1' ?
    EventResultConsts.SWITCH_ON : EventResultConsts.SWITCH_OFF;
  }],
  // 仿生视觉
  [HiSysDisplayBrightnessStaticEventGroup.BIONIC_VISION_STATUS, (): string => {
    return SettingsDataUtils.getSettingsDataDomain(SETTINGS_DISPLAY_BIONIC_VISION_SWITCH, '0',
      Settings.domainName.DEVICE_SHARED) === '1' ? EventResultConsts.SWITCH_ON : EventResultConsts.SWITCH_OFF;
  }],
  [HiSysDeveloperOptionsGroup.DEBUG_OUTER_APP_SWITCH_STATUS, (): string => {
    return SettingsDataUtils.getSettingsData(DEBUG_OUTER_APP_KEY, 'false') === 'true' ? EventResultConsts.SWITCH_ON :
    EventResultConsts.SWITCH_OFF;
  }],
  [HiSysVolumeGroup.VOLUME_KEY_DEFAULT_CONTROL_FIXED, (): string => {
    return SettingsDataUtils.getSettingsData(DEFAULT_VOLUME_CONTROL_KEY, VOLUME_CONTROL_MEDIA_VALUE,
      Settings.domainName.USER_PROPERTY);
  }],
  [HiSysDeveloperOptionsGroup.NETWORK_NAVIGATOR_SWITCH_STATUS, (): string => {
    return getNetworkNavigatorSwitch();
  }],
  [HiSysDeveloperOptionsGroup.NETWORK_NAVIGATOR_SCENE_STATUS, (): string => {
    return getNetworkNavigatorScene();
  }]
]);

function getRingMode(): number {
  let audioVolumeManager = audio.getAudioManager().getVolumeManager();
  let audioVolumeGroupManager: audio.AudioVolumeGroupManager | null = null;
  try {
    if (audioVolumeGroupManager) {
      audioVolumeGroupManager = audioVolumeManager.getVolumeGroupManagerSync(audio.DEFAULT_VOLUME_GROUP_ID);
    }
  } catch (error) {
    LogUtil.error(`${TAG} initVolumeGroupManager failed, ${error?.message}`);
  }
  let audioRingMode = (audioVolumeGroupManager as audio.AudioVolumeGroupManager)?.getRingerModeSync();
  return audioRingMode;
}

function getNetworkNavigatorSwitch(): string {
  let isNetSimulatorEnabled: boolean = false;
  // try {
  //   isNetSimulatorEnabled = netQuality.isNetSimulatorEnabled();
  // } catch (err) {
  //   LogUtil.error(`${TAG} isNetSimulatorEnabled err:${err?.code}-${err?.message}`);
  // }
  return isNetSimulatorEnabled ? 'on' : 'off';
}

function getNetworkNavigatorScene(): string {
  // let effectiveSceneType: netQuality.NetScenarioType = netQuality.NetScenarioType.SCENARIO_NONE;
  // try {
  //   effectiveSceneType = netQuality.getNetSimulatorActiveScenario();
  // } catch (err) {
  //   LogUtil.error(`${TAG} getNetSimulatorActiveScenario err:${err?.code}-${err?.message}`);
  // }
  // return String(effectiveSceneType);
  return String("effectiveSceneType");
}

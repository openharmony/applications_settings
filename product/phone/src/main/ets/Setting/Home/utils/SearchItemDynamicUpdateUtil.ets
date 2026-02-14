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

import { sensor } from '@kit.SensorServiceKit';
import { DeviceUtil } from '@ohos/settings.common/src/main/ets/utils/BaseUtils';
import { SearchDataController } from '@ohos/settings.search/src/main/ets/controller/SearchController';
import { SearchCheckUtil } from '@ohos/settings.search/src/main/ets/util/SearchCheckUtil';
import { LogUtil } from '@ohos/settings.common/src/main/ets/utils/LogUtil';
import { SettingsDataUtils } from '@ohos/settings.common/src/main/ets/utils/SettingsDataUtils';
import { VibratorUtil } from '@ohos/settings.common/src/main/ets/utils/VibratorUtil';

/* instrument ignore file */
const TAG: string = 'SearchItemDynamicUpdateUtil';

export class SearchItemDynamicUpdateUtil {
  private static instance: SearchItemDynamicUpdateUtil | undefined = undefined;
  private searchDataController: SearchDataController = SearchDataController.getInstance();
  private accessibilityItemsNeedBlockInPcMode: string[] = [
    'high_contrast_text', 'touch_duration', 'ignore_repeated_touches', 'accessibility_shortcut', 'shortKey_lock_screen',
    'function_select', 'zoom_gesture', 'zoom_zone_text', 'touchscreen_settings', 'allow_drop_down_control_center',
    'highContrast_text'
  ];
  private aiBarItemsNeedBlockInPcMode: string[] = [
    'ai_bar_setting', 'ai_bar_back', 'ai_bar_vassistant_dialogue', 'ai_bar_back_click_navigation',
    'ai_bar_vassistant_dialogue_longpress', 'ai_bar', 'floating_three_button_navigation'
  ];
  private screenReaderItemsNeedBlockInPcMode: string[] = [
    'screenreader_more_settings', 'screenreader_watermark', 'screenreader_subtitles', 'screenreader_unlocking_prompt',
    'screenreader_lock_screen_prompt', 'screenreader_in_call_Touch_guide_mode', 'screenreader_touch_audio_feedback',
    'screenreader_hide_screen_content', 'screenreader_speak_list_grid_positions', 'screenreader_single_click_mode',
    'screenreader_usageHint', 'screenreader_automatic_broadcast_of_notifications', 'screenreader_voice_settings',
    'screenreader_voice_tts_speed', 'screenreader_voice_tts_tone', 'screenreader_voice_tts_speed_reset',
    'screenreader_voice_tts_pitch_reset', 'screenreader_voice_tts_pitch_reset', 'screenreader_voice_tts_pitch_reset',
    'screenreader_intelligent_identification', 'screenreader_image_description', 'screenreader_ocr', 'screen reader',
    'screenreader_customize_shortcut_gestures', 'screenreader_gestures_reset', 'Shortcut_Menu_Configuration'
  ];
  private itemsNeedBlockInPadMode: string[] = [
    'Display the desktop', 'Go into multitasking', 'three finger slide up', 'three fingers up and stay',
    'attration_style'
  ];

  public static getInstance(): SearchItemDynamicUpdateUtil {
    if (!SearchItemDynamicUpdateUtil.instance) {
      SearchItemDynamicUpdateUtil.instance = new SearchItemDynamicUpdateUtil();
    }
    return SearchItemDynamicUpdateUtil.instance;
  }

  /**
   * 动态更新部分搜索项
   */
  public async updateSearchItems(): Promise<void> {
    this.updateSearchItemsOf2In1Device();
    // 系统导航
    this.updateSearchItemsOfFloatNavigationOptionIn2In1();
    // 屏幕朗读
    this.updateSearchItemsOfScreenReaderOptionIn2In1();
  }

  /**
   * 2In1设备下，根据PC和Pad模式对相关搜索项进行更新
   */
  private async updateSearchItemsOf2In1Device(): Promise<void> {
    let isAvailableInPcMode: boolean = !DeviceUtil.is2In1DevicePcType();
    let isAvailableInPadMode: boolean = !DeviceUtil.is2In1DevicePadType();
    this.accessibilityItemsNeedBlockInPcMode.concat(this.aiBarItemsNeedBlockInPcMode,
      this.screenReaderItemsNeedBlockInPcMode).forEach((itemName) => {
      this.updateSearchItem(itemName, isAvailableInPcMode);
    });
    this.itemsNeedBlockInPadMode.forEach((itemName) => {
      this.updateSearchItem(itemName, isAvailableInPadMode);
    });
    LogUtil.showInfo(TAG, `update search items of 2in1 device`);
  }

  /**
   * 异步更新2In1设备下的悬浮导航相关搜索项是否可用
   */
  private async updateSearchItemsOfFloatNavigationOptionIn2In1(): Promise<void> {
    LogUtil.showInfo(TAG, `update floating naviageion search items`);
    let supportFloatNav: boolean = SettingsDataUtils.getSettingsData('floating_navigation_ccm', '') === '0';
    let supportFloatNavBall: boolean = SettingsDataUtils.getSettingsData('floating_navigation_ball_ccm', '') === '0';
    let isPcMode: boolean = DeviceUtil.is2In1DevicePcType();
    this.updateSearchItem('floating_three_button_navigation_detail_new', supportFloatNav && !isPcMode);
    this.updateSearchItem('more_settings', supportFloatNav && !isPcMode);
    this.updateSearchItem('floating_navigation_ball_name', supportFloatNavBall && !isPcMode);
  }

  private async updateSearchItemsOfScreenReaderOptionIn2In1(): Promise<void> {
    LogUtil.showInfo(TAG, `update floating screen reader items`);
    let isSupportVibrate: boolean = VibratorUtil.isSupportVibrate();
    let isSupportProximitySensor: boolean = this.isSupportProximitySensor();
    let hasVoiceCapability: boolean = await SearchCheckUtil.hasVoiceCapability();
    let isPcMode: boolean = DeviceUtil.is2In1DevicePcType();
    this.updateSearchItem('screenreader_touch_vibration_feedback', isSupportVibrate && !isPcMode);
    this.updateSearchItem('screenreader_senor_control_voive', isSupportProximitySensor && !isPcMode);
    this.updateSearchItem('screenreader_in_call_gesture_custom', hasVoiceCapability && !isPcMode);
    this.updateSearchItem('screenreader_in_call_system_default_mode', hasVoiceCapability && !isPcMode);
    this.updateSearchItem('screenreader_in_call_Custom_Gesture_mode', hasVoiceCapability && !isPcMode);
  }

  /**
   * 是否支持接近光传感器
   */
  private isSupportProximitySensor(): boolean {
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
      return false;
    } catch (err) {
      LogUtil.showError(TAG, `isSupportProximitySensor error ${err?.code}`);
      return false;
    }
  }

  private updateSearchItem(itemName: string, status: boolean): void {
    this.searchDataController.updateSearchItemStatus(itemName, status);
    this.searchDataController.updateChildItemSearchStatus(itemName, status);
    LogUtil.showInfo(TAG, `search item ${itemName} change to ${status}`);
  }
}
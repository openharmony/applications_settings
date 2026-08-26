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

import config from '@ohos.accessibility.config';
import settings from '@ohos.settings';
import { BusinessError } from '@ohos.base';
import { LogUtil } from '@ohos/settings.common/src/main/ets/utils/LogUtil';
import { SettingsDataUtils } from '@ohos/settings.common/src/main/ets/utils/SettingsDataUtils';

const TAG: string = 'RestoreAccessibilityConfig : ';
const SCREEN_READER_NAME: string = 'com.ohos.screenreader/AccessibilityExtAbility';
const SCREEN_READER_KEY: string = 'accessibility_screenreader_enabled';
const SCREEN_MAGNIFICATION: string = 'accessibility_display_magnification_enabled';
const ZOOM_GESTURE_DIALOG_OPEN: string = 'accessibility_zoom_gesture_enabled_reconfirm';
const SCREEN_MAGNIFICATION_TYPE_KEY: string = 'accessibility_magnification_capability';
const VASSISTANT_VOICEFIX: string = 'vassistant_voicefix_on';
const VASSISTANT_VOICEFIX_CALL: string = 'vassistant_voicefix_call_on';
const SOUND_RECOGNITION_SWITCH: string = 'accessibility_sound_recognition_switch';
const SOUND_RECOGNITION_ENABLED: string = 'accessibility_sound_recognition_enabled';
const FLASH_REMINDER_SWITCH: string = 'accessibility_flash_reminder_switch';
const FLASH_REMINDER_ENABLED: string = 'accessibility_reminder_function_enabled';
const ANIMATIONS_NOTIFICATION: string = 'transition_animations_notification';
const ACCESSIBILITY_DISPLAY_MAGNIFICATION_SCALE: string = 'accessibility_display_magnification_scale';

const SWITCH_ON: string = '1';
const SWITCH_OFF: string = '0';
const DEFAULT_SCALE: string = '2';

enum SelectColorFilterCorrectionValue {
  DEUTERANOMALY = 'Deuteranomaly',
  PROTANOMALY = 'Protanomaly',
  TRITANOMALY = 'Tritanomaly',
  DEFAULT = 'Normal'
}

export class RestoreAccessibilityConfig {
  public readonly invertColorState: boolean = false;
  public readonly highContrastTextState: boolean = false;
  public readonly audioMonoState: boolean = false;
  public readonly daltonizationState: boolean = false;
  public readonly ignoreRepeatClick: boolean = false;
  public readonly audioBalanceState: number = 0;
  public readonly shortkey: boolean = false;
  public readonly repeatClickInterval: config.RepeatClickInterval = 'Shortest';
  public readonly clickResponseTime: config.ClickResponseTime = 'Short';
  public readonly shortkeyMultiTargets: Array<string> = [];
  public readonly animationOffState: boolean = false;

  constructor() {
  }

  public restoreAccessibilityConfig(): void {
    this.restoreHighContrastText();
    this.restoreInvertColor();
    this.restoreAudioMono();
    this.restoreShortkeyMultiTargets();
    this.restoreAudioBalance();
    this.restoreShortkey();
    this.restoreDaltonizationState();
    this.restoreIgnoreRepeatClick();
    this.restoreRepeatClickInterval();
    this.restoreClickResponseTime();
    this.disableScreenReader();
  }

  public restoreAccessibilityVisualConfig(): void {
    this.disableScreenReader();
    this.restoreDisplayMagnification();
    this.restoreHighContrastText();
    this.restoreInvertColor();
    this.restoreDaltonizationState();
    this.restoreAnimationOff();
  }

  public restoreAccessibilityHearingConfig(): void {
    this.restoreAudioMono();
    this.restoreAudioBalance();
    this.restoreSoundRepair();
    this.restoreSoundRecognition();
    this.restoreFlashReminder();
  }

  public restoreAccessibilityControlConfig(): void {
    this.restoreClickResponseTime();
    this.restoreIgnoreRepeatClick();
  }

  private restoreHighContrastText(): void {
    config.highContrastText.set(this.invertColorState).then(() => {
      LogUtil.info(`${TAG} highContrastText set success`);
    }).catch((error: BusinessError) => {
      LogUtil.error(`${TAG} highContrastText set err: ${error?.message}`);
    });
  }

  private restoreInvertColor(): void {
    config.invertColor.set(this.invertColorState).then(() => {
      LogUtil.info(`${TAG} invertColor set success`);
    }).catch((error: BusinessError) => {
      LogUtil.error(`${TAG} invertColor set err: ${error?.message}`);
    });
  }

  private restoreAudioMono(): void {
    config.audioMono.set(this.audioMonoState).then(() => {
      LogUtil.info(`${TAG} audioMono set success`);
    }).catch((error: BusinessError) => {
      LogUtil.error(`${TAG} audioMono set err: ${error?.message}`);
    });
  }

  private restoreShortkeyMultiTargets(): void {
    config.shortkeyMultiTargets.set(this.shortkeyMultiTargets).then(() => {
      LogUtil.info(`${TAG} ShortkeyMultiTargets set success`);
    }).catch((error: BusinessError) => {
      LogUtil.error(`${TAG} ShortkeyMultiTargets set err: ${error?.message}`);
    });
  }

  private restoreAudioBalance(): void {
    config.audioBalance.set(this.audioBalanceState).then(() => {
      LogUtil.info(`${TAG} audioBalance set success`);
    }).catch((error: BusinessError) => {
      LogUtil.error(`${TAG} audioBalance set err: ${error?.message}`);
    });
  }

  private restoreShortkey(): void {
    config.shortkey.set(this.shortkey).then(() => {
      LogUtil.info(`${TAG} shortkey set success`);
    }).catch((error: BusinessError) => {
      LogUtil.error(`${TAG} shortkey set err: ${error?.message}`);
    });
  }

  private restoreDaltonizationState(): void {
    config.daltonizationState.set(this.daltonizationState).then(() => {
      LogUtil.info(`${TAG} daltonizationState set success`);
    }).catch((error: BusinessError) => {
      LogUtil.error(`${TAG} daltonizationState set error ${error?.message}, code: ${error?.code}`);
    });
    config.daltonizationColorFilter.set(SelectColorFilterCorrectionValue.DEFAULT).then(() => {
      LogUtil.info(`accessibilityConfigSetting color filter success:`);
    }).catch((error: BusinessError) => {
      LogUtil.error(`${TAG} daltonizationColorFilter fail, error ${error?.message}, code: ${error?.code}`);
    });
  }

  private restoreIgnoreRepeatClick(): void {
    config.ignoreRepeatClick.set(this.ignoreRepeatClick).then(() => {
      LogUtil.info(`${TAG} ignoreRepeatClick set success`);
    }).catch((error: BusinessError) => {
      LogUtil.error(`${TAG} ignoreRepeatClick set err: ${error?.message}`);
    });
  }

  private restoreRepeatClickInterval(): void {
    config.repeatClickInterval.set(this.repeatClickInterval).then(() => {
      LogUtil.info(`${TAG} repeatClickInterval set success`);
    }).catch((error: BusinessError) => {
      LogUtil.error(`${TAG} repeatClickInterval set err: ${error?.message}`);
    });
  }

  private restoreClickResponseTime(): void {
    config.clickResponseTime.set(this.clickResponseTime).then(() => {
      LogUtil.info(`${TAG} clickResponseTime set success`);
    }).catch((error: BusinessError) => {
      LogUtil.error(`${TAG} clickResponseTime set err: ${error?.message}`);
    });
  }

  private disableScreenReader(): void {
    config.disableAbility(SCREEN_READER_NAME).then(() => {
      LogUtil.info(`${TAG} switch disable accessibility success`);
      SettingsDataUtils.setSettingsData(SCREEN_READER_KEY, SWITCH_OFF);
    }).catch((error: BusinessError) => {
      LogUtil.error(`${TAG} switch failed to disable accessibility service, error: ${error?.message}`);
    })
  }

  /**
   * ·Å´óÊÖÊÆ
   */
  private restoreDisplayMagnification(): void {
    SettingsDataUtils.setSecureValue(SCREEN_MAGNIFICATION, SWITCH_OFF);
    SettingsDataUtils.setSecureValue(ZOOM_GESTURE_DIALOG_OPEN, SWITCH_OFF);
    SettingsDataUtils.setSecureValue(SCREEN_MAGNIFICATION_TYPE_KEY, SWITCH_ON);
    SettingsDataUtils.setSecureValue(ACCESSIBILITY_DISPLAY_MAGNIFICATION_SCALE, DEFAULT_SCALE);
  }

  /**
   * ¹ý¶É¶¯»­
   */
  private restoreAnimationOff(): void {
    config.animationOff.set(this.animationOffState).then(() => {
      LogUtil.info(`${TAG} accessibilityConfigSetting animationOff success`);
    }).catch((error: BusinessError) => {
      LogUtil.error(`${TAG} accessibilityConfigSetting animationOff fail, error: ${error?.message}`);
    });
    SettingsDataUtils.setSecureValue(ANIMATIONS_NOTIFICATION, SWITCH_ON);
  }

  /**
   * ÉùÒôÐÞ¸´
   */
  private restoreSoundRepair(): void {
    const context: Context = getContext(this);
    try {
      settings.setValueSync(context, VASSISTANT_VOICEFIX, 'false', settings.domainName.DEVICE_SHARED);
      settings.setValueSync(context, VASSISTANT_VOICEFIX_CALL, 'false', settings.domainName.DEVICE_SHARED);
    } catch (err) {
      LogUtil.error(`${TAG} restoreSoundRepair error.${err?.code}-${err?.message}`);
    }
  }

  /**
   * ÉùÒôÊ¶±ð
   */
  private restoreSoundRecognition(): void {
    SettingsDataUtils.setSecureValue(SOUND_RECOGNITION_SWITCH, SWITCH_OFF);
    SettingsDataUtils.setSecureValue(SOUND_RECOGNITION_ENABLED, 'DEFAULT');
  }

  /**
   * ÉÁË¸ÌáÐÑ
   */
  private restoreFlashReminder(): void {
    SettingsDataUtils.setSecureValue(FLASH_REMINDER_SWITCH, SWITCH_OFF);
    SettingsDataUtils.setSecureValue(FLASH_REMINDER_ENABLED, 'DEFAULT');
  }
}
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
import { LogUtil } from '@ohos/settings.common/src/main/ets/utils/LogUtil';
import { SettingsDataUtils } from '@ohos/settings.common/src/main/ets/utils/SettingsDataUtils';
import { BusinessError } from '@ohos.base';
import accessibility from '@ohos.accessibility';
/* instrument ignore file */
const TAG: string = 'AccessibilitySettingModel : ';
const SCREEN_READER_ON_KEY = 'accessibility_enabled';

/**
 * 开关控制器
 *
 * @since 2022-06-02
 */
export class AccessibilitySettingModel {
  public static isScreenLockedState: boolean = false;

  static accessibilityConfigSetting(configValue: string, isOn: boolean): void {
    LogUtil.info(`${TAG} accessibilityConfigSetting config: ${configValue} isOn: ${isOn}`);
    switch (configValue) {
      case 'highContrastText':
        config.highContrastText.set(isOn).then(() => {
          LogUtil.info(`${TAG} highContrastText set ${isOn} success`);
        }).catch((err: BusinessError) => {
          LogUtil.error(`${TAG} highContrastText set ${isOn} err: ${err?.message}`);
        });
        break;
      case 'invertColor':
        config.invertColor.set(isOn).then(() => {
          LogUtil.info(`${TAG} invertColor set ${isOn} success`);
        }).catch((err: BusinessError) => {
          LogUtil.error(`${TAG} invertColor set ${isOn} err: ${err?.message}`);
        });
        break;
      case 'animationOff':
        config.animationOff.set(isOn).then(() => {
          LogUtil.info(`${TAG} animationOff set ${isOn} success`);
        }).catch((err: BusinessError) => {
          LogUtil.error(`${TAG} animationOff set ${isOn} err: ${err?.message}`);
        });
        break;
      case 'audioMono':
        config.audioMono.set(isOn).then(() => {
          LogUtil.info(`${TAG} audioMono set ${isOn} success`);
        }).catch((err: BusinessError) => {
          LogUtil.error(`${TAG} audioMono set ${isOn} err: ${err?.message}`);
        });
        break;
      case 'mouseKey':
        config.mouseKey.set(isOn).then(() => {
          LogUtil.info(`${TAG} mouseKey set ${isOn} success`);
        }).catch((err: BusinessError) => {
          LogUtil.error(`${TAG} mouseKey set ${isOn} err: ${err?.message}`);
        });
        break;
      case 'shortKey':
        config.shortkey.set(isOn).then(() => {
          LogUtil.info(`${TAG} shortkey set ${isOn} success`);
        }).catch((err: BusinessError) => {
          LogUtil.error(`${TAG} shortkey set ${isOn} err: ${err?.message}`);
        });
        break;
      case 'captions':
        config.captions.set(isOn).then(() => {
          LogUtil.info(`${TAG} captions set ${isOn} success`);
        }).catch((err: BusinessError) => {
          LogUtil.error(`${TAG} captions set ${isOn} err: ${err?.message}`);
        });
        break;
      case 'colorFilter':
        config.daltonizationState.set(isOn).then(() => {
          LogUtil.info(`${TAG} color filter state set ${isOn} success`);
        }).catch((err: BusinessError) => {
          LogUtil.error(`${TAG} color filter state set ${isOn} err: ${err?.message}`);
        });
        break;
      case 'ignoreRepeatTouches':
        config.ignoreRepeatClick.set(isOn).then(() => {
          LogUtil.info(`${TAG} ignore repeat touches state set ${isOn} success`);
        }).catch((err: BusinessError) => {
          LogUtil.error(`${TAG} ignore repeat touches state set ${isOn} err: ${err?.message}`);
        });
        break;
      default:
        break;
    }
  }

  static accessibilityIgnoreRepeatClickTimeSet(targetName: config.RepeatClickInterval): void {
    LogUtil.info(`${TAG} accessibilityIgnoreRepeatClickTimeSet config begin: ${targetName}`);
    config.repeatClickInterval.set(targetName).then(() => {
      LogUtil.info(`${TAG} accessibilityIgnoreRepeatClickTimeSet config success: ${targetName}`);
    }).catch((err: BusinessError) => {
      LogUtil.error(`${TAG} accessibilityIgnoreRepeatClickTimeSet config fail: ${targetName} err: ${err?.message}`);
    });
  }

  static accessibilityAudioBalanceSetting(audioBalance: number): void {
    LogUtil.info(`${TAG} AudioBalanceSetting config begin: ${audioBalance}`);
    config.audioBalance.set(audioBalance).then(() => {
      LogUtil.info(`${TAG} AudioBalanceSetting config success: ${audioBalance}`);
    }).catch((err: BusinessError) => {
      LogUtil.error(`${TAG} AudioBalanceSetting config fail: ${audioBalance} err: ${err?.message}`);
    });
  }

  static accessibilityShoetkeyStateSet(targetName: string): void {
    LogUtil.info(`${TAG} accessibilityShortkeyTarget config begin: ${targetName}`);
    config.shortkeyTarget.set(targetName).then(() => {
      LogUtil.info(`${TAG} accessibilityShortkeyTarget config success: ${targetName}`);
    }).catch((err: BusinessError) => {
      LogUtil.error(`${TAG} accessibilityShortkeyTarget config fail: ${targetName} err: ${err?.message}`);
    });
  }

  static accessibilityScreenReaderSetting(isOn: boolean) {
    LogUtil.info(`${TAG} accessibilityScreenReaderState begin: ${isOn}`);
    let name = 'com.ohos.screenreader/AccessibilityExtAbility';
    let capability: accessibility.Capability[] = ['retrieve', 'touchGuide', 'keyEventObserver', 'gesture'];
    if (isOn) {
      SettingsDataUtils.setSettingsData(SCREEN_READER_ON_KEY, 'true');
      try {
        config.enableAbility(name, capability, (err) => {
          if (err) {
            LogUtil.error(`${TAG} failed to enable ability, because ${err?.message}`);
            return;
          }
        });
      } catch (exception) {
        LogUtil.error(`${TAG} failed to enable ability, because ${exception?.message}`);
      }
    } else {
      SettingsDataUtils.setSettingsData(SCREEN_READER_ON_KEY, 'false');
      try {
        config.disableAbility(name).then(() => {
          LogUtil.info('disable ability succeed');
        }).catch((err: BusinessError) => {
          LogUtil.error(`${TAG} failed to disable ability, because ${err?.message}`);
        });
      } catch (exception) {
        LogUtil.error(`${TAG} failed to disable ability, because ${exception?.message}`);
      }
    }
  }
}
/**
 * Copyright (c) 2023-2023 Huawei Device Co., Ltd.
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
import LogUtil from '../../../../../../../common/utils/src/main/ets/default/baseUtil/LogUtil';
import { BusinessError } from '@ohos.base';

const TAG = 'AccessibilitySettingModel : ';

/**
 * 音量平衡控制器
 *
 * @since 2023-07-20
 */
export class AccessibilitySettingModel {
  static accessibilityConfigSetting(configValue: string, isOn: boolean): void {
    LogUtil.info(`${TAG} accessibilityConfigSetting config: ${configValue} isOn: ${isOn}`);
    switch (configValue) {
      case 'highContrastText':
        config.highContrastText.set(isOn).then(() => {
          LogUtil.info(`${TAG} highContrastText set ${isOn} success`);
        }).catch((err: BusinessError) => {
          LogUtil.error(`${TAG} highContrastText set ${isOn} err: ${JSON.stringify(err)}`);
        });
        break;
      case 'invertColor':
        config.invertColor.set(isOn).then(() => {
          LogUtil.info(`${TAG} invertColor set ${isOn} success`);
        }).catch((err: BusinessError) => {
          LogUtil.error(`${TAG} invertColor set ${isOn} err: ${JSON.stringify(err)}`);
        });
        break;
      case 'animationOff':
        config.animationOff.set(isOn).then(() => {
          LogUtil.info(`${TAG} animationOff set ${isOn} success`);
        }).catch((err: BusinessError) => {
          LogUtil.error(`${TAG} animationOff set ${isOn} err: ${JSON.stringify(err)}`);
        });
        break;
      case 'audioMono':
        config.audioMono.set(isOn).then(() => {
          LogUtil.info(`${TAG} audioMono set ${isOn} success`);
        }).catch((err: BusinessError) => {
          LogUtil.error(`${TAG} audioMono set ${isOn} err: ${JSON.stringify(err)}`);
        });
        break;
      case 'mouseKey':
        config.mouseKey.set(isOn).then(() => {
          LogUtil.info(`${TAG} mouseKey set ${isOn} success`);
        }).catch((err: BusinessError) => {
          LogUtil.error(`${TAG} mouseKey set ${isOn} err: ${JSON.stringify(err)}`);
        });
        break;
      case 'shortKey':
        config.shortkey.set(isOn).then(() => {
          LogUtil.info(`${TAG} shortkey set ${isOn} success`);
        }).catch((err: BusinessError) => {
          LogUtil.error(`${TAG} shortkey set ${isOn} err: ${JSON.stringify(err)}`);
        });
        break;
      case 'captions':
        config.captions.set(isOn).then(() => {
          LogUtil.info(`${TAG} captions set ${isOn} success`);
        }).catch((err: BusinessError) => {
          LogUtil.error(`${TAG} captions set ${isOn} err: ${JSON.stringify(err)}`);
        });
        break;
      case 'daltonizationState':
        config.daltonizationState.set(isOn).then(() => {
          LogUtil.info(`${TAG} daltonizationState set ${isOn} success`);
        }).catch((err: BusinessError) => {
          LogUtil.error(`${TAG} daltonizationState set ${isOn} err: ${JSON.stringify(err)}`);
        });
        break;
      case 'ignoreRepeatClick':
        config.ignoreRepeatClick.set(isOn).then(() => {
          LogUtil.info(`${TAG} ignoreRepeatClick set ${isOn} success`);
        }).catch((err: BusinessError) => {
          LogUtil.error(`${TAG} ignoreRepeatClick set ${isOn} err: ${JSON.stringify(err)}`);
        });
        break;
      default:
        break;
    }
  }

  static accessibilityAudioBalanceSetting(audioBalance: number): void {
    LogUtil.info(`${TAG} accessibilityConfigSetting config begin: ${audioBalance}`);
    config.audioBalance.set(audioBalance).then(() => {
      LogUtil.info(`${TAG} accessibilityConfigSetting config success: ${audioBalance}`);
    }).catch((err: BusinessError) => {
      LogUtil.error(`${TAG} accessibilityConfigSetting config fail: ${audioBalance} err: ${JSON.stringify(err)}`);
    });
  }

  static accessibilityShortKeyStateSet(targetName: string): void {
    LogUtil.info(`${TAG} accessibilityshortkeyTargete config begin: ${targetName}`);
    config.shortkeyTarget.set(targetName).then(() => {
      LogUtil.info(`${TAG} accessibilityshortkeyTargete config success: ${targetName}`);
    }).catch((err: BusinessError) => {
      LogUtil.error(`${TAG} accessibilityshortkeyTargete config fail: ${targetName} err: ${JSON.stringify(err)}`);
    });
  }

  static accessibilityColorCorrectionSet(targetName: config.DaltonizationColorFilter): void {
    LogUtil.info(`${TAG} accessibilityColorCorrection config begin: ${targetName}`);
    config.daltonizationColorFilter.set(targetName).then(() => {
      LogUtil.info(`${TAG} daltonizationColorFilter config success`);
    }).catch((err: object) => {
      console.error(`${TAG} failed to set daltonizationColorFilter`);
    });
  }

  static accessibilityClickResponseTimeSet(targetName: config.ClickResponseTime): void {
    LogUtil.info(`${TAG} accessibilityClickResponseTime config begin: ${targetName}`);
    config.clickResponseTime.set(targetName).then(() => {
      LogUtil.info(`${TAG} clickResponseTime config success`);
    }).catch((err: object) => {
      console.error(`${TAG} failed to set clickResponseTime`);
    });
  }

  static accessibilityIgnoreRepeatClickTimeSet(targetName: config.RepeatClickInterval): void {
    LogUtil.info(`${TAG} accessibilityIgnoreRepeatClickTime config begin: ${targetName}`);
    config.repeatClickInterval.set(targetName).then(() => {
      LogUtil.info(`${TAG} ignoreRepeatClickTime config success`);
    }).catch((err: object) => {
      console.error(`${TAG} failed to set ignoreRepeatClickTime`);
    });
  }

  static accessibilityShortKeyMultiTargetsSet(targetList: Array<string>): void {
    LogUtil.info(`${TAG} accessibilityShortKeyMultiTargets config begin: ${JSON.stringify(targetList)}`);
    config.shortkeyMultiTargets.set(targetList).then(() => {
      LogUtil.info(`${TAG} shortkeyMultiTargets config success`);
    }).catch((err: object) => {
      console.error(`${TAG} failed to set shortkeyMultiTargets`);
    });
  }
}
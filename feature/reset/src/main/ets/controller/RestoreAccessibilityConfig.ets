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
import { BusinessError } from '@ohos.base';
import { LogUtil } from '@ohos/settings.common/src/main/ets/utils/LogUtil';
import { SettingsDataUtils } from '@ohos/settings.common/src/main/ets/utils/SettingsDataUtils';

const TAG: string = 'RestoreAccessibilityConfig : ';
const SCREEN_READER_NAME: string = 'com.ohos.screenreader/AccessibilityExtAbility';
const SCREEN_READER_KEY: string = 'accessibility_screenreader_enabled';

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

  private restoreHighContrastText(): void {
    config.highContrastText.set(this.invertColorState).then(() => {
      LogUtil.info(`${TAG} highContrastText set success`);
    }).catch((error: BusinessError) => {
      LogUtil.error(`${TAG} highContrastText set err: ${error.message}`);
    });
  }

  private restoreInvertColor(): void {
    config.invertColor.set(this.invertColorState).then(() => {
      LogUtil.info(`${TAG} invertColor set success`);
    }).catch((error: BusinessError) => {
      LogUtil.error(`${TAG} invertColor set err: ${error.message}`);
    });
  }

  private restoreAudioMono(): void {
    config.audioMono.set(this.audioMonoState).then(() => {
      LogUtil.info(`${TAG} audioMono set success`);
    }).catch((error: BusinessError) => {
      LogUtil.error(`${TAG} audioMono set err: ${error.message}`);
    });
  }

  private restoreShortkeyMultiTargets(): void {
    config.shortkeyMultiTargets.set(this.shortkeyMultiTargets).then(() => {
      LogUtil.info(`${TAG} ShortkeyMultiTargets set success`);
    }).catch((error: BusinessError) => {
      LogUtil.error(`${TAG} ShortkeyMultiTargets set err: ${error.message}`);
    });
  }

  private restoreAudioBalance(): void {
    config.audioBalance.set(this.audioBalanceState).then(() => {
      LogUtil.info(`${TAG} audioBalance set success`);
    }).catch((error: BusinessError) => {
      LogUtil.error(`${TAG} audioBalance set err: ${error.message}`);
    });
  }

  private restoreShortkey(): void {
    config.shortkey.set(this.shortkey).then(() => {
      LogUtil.info(`${TAG} shortkey set success`);
    }).catch((error: BusinessError) => {
      LogUtil.error(`${TAG} shortkey set err: ${error.message}`);
    });
  }

  private restoreDaltonizationState(): void {
    config.daltonizationState.set(this.daltonizationState).then(() => {
      LogUtil.info(`${TAG} daltonizationState set success`);
    }).catch((error: BusinessError) => {
      LogUtil.error(`${TAG} daltonizationState set err: ${error.message}`);
    });
  }

  private restoreIgnoreRepeatClick(): void {
    config.ignoreRepeatClick.set(this.ignoreRepeatClick).then(() => {
      LogUtil.info(`${TAG} ignoreRepeatClick set success`);
    }).catch((error: BusinessError) => {
      LogUtil.error(`${TAG} ignoreRepeatClick set err: ${error.message}`);
    });
  }

  private restoreRepeatClickInterval(): void {
    config.repeatClickInterval.set(this.repeatClickInterval).then(() => {
      LogUtil.info(`${TAG} repeatClickInterval set success`);
    }).catch((error: BusinessError) => {
      LogUtil.error(`${TAG} repeatClickInterval set err: ${error.message}`);
    });
  }

  private restoreClickResponseTime(): void {
    config.clickResponseTime.set(this.clickResponseTime).then(() => {
      LogUtil.info(`${TAG} clickResponseTime set success`);
    }).catch((error: BusinessError) => {
      LogUtil.error(`${TAG} clickResponseTime set err: ${error.message}`);
    });
  }

  private disableScreenReader(): void {
    config.disableAbility(SCREEN_READER_NAME).then(() => {
      LogUtil.info(`${TAG} switch disable accessibility success`);
      SettingsDataUtils.setSettingsData(SCREEN_READER_KEY, '0');
    }).catch((error: BusinessError) => {
      LogUtil.error(`${TAG} switch failed to disable accessibility service, error: ${error.message}`);
    })
  }
}
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

import configPolicy from '@ohos.configPolicy';
import systemSoundManager from '@ohos.multimedia.systemSoundManager';
import { AbilityContextManager } from '@ohos/settings.common/src/main/ets/ability/AbilityContextManager';
import { LogUtil } from '@ohos/settings.common/src/main/ets/utils/LogUtil';

const TAG: string = 'RestoreSystemSoundConfig : ';
const DEFAULT_MODE: string = 'Sound';

export class RestoreSystemSoundConfig {
  private audioFilePath: string = '';
  private ringToneUri: string = '';
  private messageToneUri: string = '';
  private notificationsToneUri: string = '';
  private systemSoundManagerInstance: systemSoundManager.SystemSoundManager | undefined = undefined;

  constructor() {
    this.systemSoundManagerInstance = systemSoundManager.getSystemSoundManager();
  }

  public async restoreSystemSoundConfig(): Promise<void> {
    await this.getAudioFilePath();
    this.restoreRingToneconfig();
    this.restoreSystemToneconfig();
  }

  private restoreRingToneconfig(): void {
    let card0RingToneType: systemSoundManager.RingtoneType = systemSoundManager.RingtoneType.RINGTONE_TYPE_SIM_CARD_0;
    let card1RingToneType: systemSoundManager.RingtoneType = systemSoundManager.RingtoneType.RINGTONE_TYPE_SIM_CARD_1;
    try {
      const context: Context = AbilityContextManager.getExtContext();
      this.systemSoundManagerInstance?.setRingtoneUri(context, this.ringToneUri, card0RingToneType);
      this.systemSoundManagerInstance?.setRingtoneUri(context, this.ringToneUri, card1RingToneType);
      LogUtil.info(`${TAG}  restore RingTone config success`);
    } catch (error) {
      LogUtil.error(`Failed to restore system ringtone uri ${error?.code}  errorMessage  ${error?.message}`);
    }
  }

  private restoreSystemToneconfig(): void {
    let card0SystemToneType: systemSoundManager.SystemToneType = systemSoundManager.SystemToneType.
      SYSTEM_TONE_TYPE_SIM_CARD_0;
    let card1SystemToneType: systemSoundManager.SystemToneType = systemSoundManager.SystemToneType.
      SYSTEM_TONE_TYPE_SIM_CARD_1;
    let notificationType: systemSoundManager.SystemToneType = systemSoundManager.SystemToneType.
      SYSTEM_TONE_TYPE_NOTIFICATION;
    try {
      const context: Context = AbilityContextManager.getExtContext();
      this.systemSoundManagerInstance?.setSystemToneUri(context, this.messageToneUri, card0SystemToneType);
      this.systemSoundManagerInstance?.setSystemToneUri(context, this.messageToneUri, card1SystemToneType);
      this.systemSoundManagerInstance?.setSystemToneUri(context, this.notificationsToneUri, notificationType);
      LogUtil.info(`${TAG}  restore SystemTone config success`);
    } catch (error) {
      LogUtil.error(`Failed to restore system ringtone uri: ${error?.code}, errorMessage: ${error?.message}`);
    }
  }

  private async getAudioFilePath(): Promise<void> {
    try {
      this.audioFilePath = await configPolicy.getOneCfgFile('resource/media/audio/');
      this.ringToneUri = `${this.audioFilePath}ringtones/Tune.ogg`;
      this.messageToneUri = `${this.audioFilePath}notifications/Leap.ogg`;
      this.notificationsToneUri = `${this.audioFilePath}notifications/Rise.ogg`;
      LogUtil.info(`${TAG} get audio filepath success, filePath: ${this.audioFilePath}`);
    } catch (error) {
      LogUtil.error(`${TAG} get audio filepath failed, errorMessage  ${error.message}`);
    }
  }
}
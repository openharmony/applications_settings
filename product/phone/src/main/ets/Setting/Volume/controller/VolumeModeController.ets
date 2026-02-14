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
import audio from '@ohos.multimedia.audio';
import common from '@ohos.app.ability.common';
import systemSoundManager from '@ohos.multimedia.systemSoundManager';
import { CommonEventConstant } from '@ohos/settings.common/src/main/ets/constant/CommonEventConstant';
import { AudioRingMode } from '@ohos/settings.common/src/main/ets/core/model/menu/SettingsMenu';
import { EVENT_ID_BUNDLE_AUDIO_RING_MODE_CHANGED } from '@ohos/settings.common/src/main/ets/event/types';
import { EventBus } from '@ohos/settings.common/src/main/ets/framework/common/EventBus';
import { HiSysVolumeGroup } from '@ohos/settings.common/src/main/ets/systemEvent/BehaviorEventConsts';
import { HiSysEventUtil } from '@ohos/settings.common/src/main/ets/systemEvent/HiSysEventUtil';
import { DeviceUtil } from '@ohos/settings.common/src/main/ets/utils/BaseUtils';
import { LogUtil } from '@ohos/settings.common/src/main/ets/utils/LogUtil';
import { PreferencesUtil } from '@ohos/settings.common/src/main/ets/utils/PreferencesUtil';
import { SimUtils } from '@ohos/settings.common/src/main/ets/utils/SimUtils';
import { VibratorUtil } from '@ohos/settings.common/src/main/ets/utils/VibratorUtil';
import { RingtoneType, RINGTONE_TYPE_SYSTEM } from '../constant/VolumeConstant';
import { ToneType } from '../model/RingtoneParam';
import { MyToneHapticsSettings, VibrateParam } from '../model/VibrateParam';
import { RingtonesUtils } from '../utils/RingtonesUtils';
import { VibrateUtil } from '../utils/VibrateUtil';
import { AvplayerController } from './AvplayerController';
import {
  AUDIO_VOLUME_TYPE_MEDIA,
  AUDIO_VOLUME_TYPE_RINGTONE,
  RINGER_MODE_NORMAL,
  RINGER_MODE_SILENT,
  RINGER_MODE_VIBRATE,
  VolumeAdapter,
  VolumeListener
} from './VolumeAdapter';

const TAG: string = 'VolumeModeController : ';
const VIBRATE_DURATION: number = 50;
const VOLUME_RADIO_VOICE: Resource[] = [
  $r('app.string.ringer_mode_slient'),
  $r('app.string.ringer_mode_vibrate'),
  $r('app.string.ringer_mode_normal')
]
export const IS_SUPPORT_VIBRATE: boolean = VibratorUtil.isSupportVibrate();
export type ModeChangeEventCb = (mode: number) => void;

export class VolumeModeController implements VolumeListener {
  public audioRingMode: AudioRingMode = AudioRingMode.RINGER_MODE_NORMAL;
  private callbacks: ModeChangeEventCb[] = [];
  private onPageShowCallback =  () => {
    this.audioRingMode = this.getAudioRingerMode();
    this.dispatchModeChangeEvent(this.audioRingMode);
    this.onRingerModeChange(this.audioRingMode);
  }

  init(): void {
    this.audioRingMode = this.getAudioRingerMode();
    LogUtil.info(`${TAG} init audioRingMode: ${this.audioRingMode}`);
    this.dispatchModeChangeEvent(this.audioRingMode);
    VolumeAdapter.getInstance().addListener(this);
    EventBus.getInstance().on(CommonEventConstant.EVENT_VOLUME_PAGE_SHOW, this.onPageShowCallback);
  }

  private dispatchModeChangeEvent(mode: number): void {
    this.callbacks.forEach((callback) => {
      callback?.(mode);
    })
  }

  registerModeChangeListener(callback: ModeChangeEventCb): void {
    this.callbacks.push(callback);
  }

  unregisterModeChangeListener(callback: ModeChangeEventCb): void {
    this.callbacks = this.callbacks.filter((modeChangeCb: ModeChangeEventCb) => modeChangeCb !== callback);
  }

  private getAudioRingerMode(): AudioRingMode {
    let res: AudioRingMode;
    const currentRingMode = VolumeAdapter.getInstance().getRingerMode();
    if (currentRingMode === 1) {
      res = IS_SUPPORT_VIBRATE ? 1 : 0;
    } else {
      res = currentRingMode;
    }
    return res;
  }

  destroy(): void {
    this.callbacks = [];
    VolumeAdapter.getInstance().removeListener(this);
    EventBus.getInstance().detach(CommonEventConstant.EVENT_VOLUME_PAGE_SHOW, this.onPageShowCallback);
  }

  onRadioChange(ringMode: AudioRingMode): void {
    LogUtil.info(`${TAG} onRadioChange : ${ringMode}`);
    // 更新前的声音模式
    let beforeUpdateAudioRingMode: AudioRingMode = this.audioRingMode;
    this.setAudioRingMode(ringMode);
    this.updateToneHapticsSettings(beforeUpdateAudioRingMode, ringMode);
    HiSysEventUtil.reportDefaultBehaviorEventByUE(HiSysVolumeGroup.VOLUME_MODE_CHANGE, String(ringMode));
  }

  onVolumeChange(volumeEvent: audio.VolumeEvent): void {
    LogUtil.info(`${TAG} onVolumeChange volume: ${volumeEvent.volume}`);
    if (volumeEvent.volume === 0 && this.audioRingMode !== RINGER_MODE_NORMAL) {
      this.updateRingMode(this.audioRingMode);
    } else {
      if (IS_SUPPORT_VIBRATE) {
        this.updateRingMode(volumeEvent.volume === 0 ? RINGER_MODE_VIBRATE : RINGER_MODE_NORMAL);
      } else {
        this.updateRingMode(volumeEvent.volume === 0 ? RINGER_MODE_SILENT : RINGER_MODE_NORMAL);
      }
    }
  }

  onDeviceChange(audioDeviceDescriptors: audio.AudioDeviceDescriptors): void {
  }

  onRingerModeChange(audioRingMode: audio.AudioRingMode): void {
    LogUtil.info(`${TAG} onRingerModeChange ${audioRingMode}`);
    // 更新前的声音模式
    let beforeUpdateAudioRingMode: AudioRingMode = this.audioRingMode;
    this.updateToneHapticsSettings(beforeUpdateAudioRingMode, audioRingMode);
    if (!IS_SUPPORT_VIBRATE && audioRingMode === RINGER_MODE_VIBRATE) {
      this.updateRingMode(RINGER_MODE_SILENT);
    } else {
      this.updateRingMode(audioRingMode);
    }
  }

  getVolumeType(): number {
    return AUDIO_VOLUME_TYPE_RINGTONE;
  }

  getListenerName(): string {
    return 'VolumeModeController';
  }

  private setAudioRingMode(ringMode: audio.AudioRingMode): void {
    if (this.audioRingMode === ringMode) {
      LogUtil.showInfo(TAG, 'the audio ring mode is same, not set.');
      return;
    }
    this.audioRingMode = ringMode;
    this.dispatchModeChangeEvent(this.audioRingMode);
    // 切换声音模式时仅改变铃声行为，保存并恢复媒体音量，避免系统联动修改媒体音量
    const mediaVolumeBefore = VolumeAdapter.getInstance().getVolume(AUDIO_VOLUME_TYPE_MEDIA);
    VolumeAdapter.getInstance().setRingerMode(ringMode).then(() => {
      VolumeAdapter.getInstance().setVolume(AUDIO_VOLUME_TYPE_MEDIA, mediaVolumeBefore);
      LogUtil.showInfo(TAG, `restore media volume after setRingerMode: ${mediaVolumeBefore}`);
    }).catch(() => {
      VolumeAdapter.getInstance().setVolume(AUDIO_VOLUME_TYPE_MEDIA, mediaVolumeBefore);
    });
    LogUtil.showInfo(TAG, `set audio ring mode: ${this.audioRingMode}`);
    if (ringMode === RINGER_MODE_VIBRATE) {
      VibratorUtil.vibrateOnVibrateMode(VIBRATE_DURATION, 'touch');
    }

    if (this.audioRingMode === RINGER_MODE_NORMAL) {
      let ringtoneType = SimUtils.getCardSlotNum() > 0 ? RingtoneType.RINGTONE_TYPE_SIM
        : RingtoneType.RINGTONE_TYPE_NOTIFICATION;
      const key: string = RingtonesUtils.getRingtoneKey(true, ringtoneType);
      const flag = PreferencesUtil.getSync(key + '_type', RINGTONE_TYPE_SYSTEM);
      // 先用 PreferencesUtil 来区分系统铃声还是本地铃声
      LogUtil.showInfo(TAG, `onSliderChange. isCustomPlayer:${flag}`);
      if (flag) {
        // 如果是自定义播放器 在RingtoneVolumeSliderController里面去处理播放
      } else {
        RingtonesUtils.getRingtoneUri(ringtoneType, getContext(this)).then((ringToneUri) => {
          let volume = VolumeAdapter.getInstance().getVolume(this.getVolumeType());
          AvplayerController.avPlayerUrl(volume, this.getVolumeType(), ringToneUri, false);
        });
      }
    } else {
      AvplayerController.releaseAvplayer();
    }
  }

  private updateRingMode(ringMode: audio.AudioRingMode): void {
    if (this.audioRingMode === ringMode) {
      LogUtil.showInfo(TAG, 'the audio ring mode is same, not update.');
      return;
    }
    this.audioRingMode = ringMode;
    this.dispatchModeChangeEvent(this.audioRingMode);
  }

  /**
   * 改变audioRingMode对应的ToneHapticsSettings
   *
   * @param audioRingMode
   */
  private async updateToneHapticsSettings(beforeUpdateAudioRingMode: audio.AudioRingMode
    , audioRingMode: audio.AudioRingMode): Promise<void> {
    if (beforeUpdateAudioRingMode === audioRingMode) {
      LogUtil.showInfo(TAG, 'the audio ring mode is same, not update toneHapticsSettings.');
      return;
    }
    let isSameToneHapticsSettings: boolean = (beforeUpdateAudioRingMode !== audio.AudioRingMode.RINGER_MODE_VIBRATE) &&
      (audioRingMode !== audio.AudioRingMode.RINGER_MODE_VIBRATE);
    if (isSameToneHapticsSettings) {
      LogUtil.showInfo(TAG, 'the audio ring mode is silent or normal, not update toneHapticsSettings.');
      return;
    }
    await Promise.all([
      this.doUpdateToneHapticsSettings(ToneType.RINGTONE
        , systemSoundManager.ToneHapticsType.CALL_SIM_CARD_0, audioRingMode),
      this.doUpdateToneHapticsSettings(ToneType.RINGTONE
        , systemSoundManager.ToneHapticsType.CALL_SIM_CARD_1, audioRingMode),
      this.doUpdateToneHapticsSettings(ToneType.MESSAGE_TONE
        , systemSoundManager.ToneHapticsType.TEXT_MESSAGE_SIM_CARD_0, audioRingMode),
      this.doUpdateToneHapticsSettings(ToneType.MESSAGE_TONE
        , systemSoundManager.ToneHapticsType.TEXT_MESSAGE_SIM_CARD_1, audioRingMode),
      this.doUpdateToneHapticsSettings(ToneType.NOTIFICATION_TONE
        , systemSoundManager.ToneHapticsType.NOTIFICATION, audioRingMode),
    ]).then(() => {
      LogUtil.showInfo(TAG, `doUpdateToneHapticsSettings end`);
    }).catch((error: Error) => {
      LogUtil.showError(TAG, `doUpdateToneHapticsSettings failed, error: ${error}`);
    });
    EventBus.getInstance().emit(EVENT_ID_BUNDLE_AUDIO_RING_MODE_CHANGED, true);
  }

  private async doUpdateToneHapticsSettings(toneType: ToneType, toneHapticsType: systemSoundManager.ToneHapticsType
    , audioRingMode: audio.AudioRingMode): Promise<void> {
    LogUtil.showInfo(TAG, `doUpdateToneHapticsSettings, toneType: ${toneType}, toneHapticsType: ${toneHapticsType}, audioRingMode: ${audioRingMode}`);
    let vibrateParamKey: string = VibrateUtil.getVibrateParamKey(toneType, toneHapticsType, audioRingMode);
    let hasKey: boolean = PreferencesUtil.hasSync(vibrateParamKey);
    let context: common.Context = getContext(this);
    let vibrateParam: VibrateParam;
    let systemSoundManagerInstance: systemSoundManager.SystemSoundManager | undefined =
      VibrateUtil.getSystemSoundManagerInstance();

    if (hasKey) {
      let defaultVibrateParam: VibrateParam = new VibrateParam();
      vibrateParam = VibrateUtil.getVibrateParamInMemory(vibrateParamKey, defaultVibrateParam) as VibrateParam;
      vibrateParam = await this.updateVibrateParamInMemory(systemSoundManagerInstance, context, vibrateParamKey
        , vibrateParam);
      await VibrateUtil.setToneHapticsSettings(systemSoundManagerInstance, context, toneHapticsType
        , vibrateParam.toneHapticsSettings);
    } else {
      if (audioRingMode === audio.AudioRingMode.RINGER_MODE_VIBRATE && toneType === ToneType.RINGTONE) {
        let toneHapticsAttrsArray: systemSoundManager.ToneHapticsAttrsArray | undefined =
          await VibrateUtil.getToneHapticsList(systemSoundManagerInstance, context);
        let nonSyncDefaultFileName: string = VibrateUtil.getNonSyncDefaultFileName(toneType);
        let nonSyncDefaultToneHapticsAttrs: systemSoundManager.ToneHapticsAttrs | undefined =
          toneHapticsAttrsArray?.find((item: systemSoundManager.ToneHapticsAttrs) => {
            return item.getFileName() === nonSyncDefaultFileName;
          });
        let toneHapticsSettings: MyToneHapticsSettings = new MyToneHapticsSettings(
          systemSoundManager.ToneHapticsMode.NON_SYNC, nonSyncDefaultToneHapticsAttrs?.getUri());
        await VibrateUtil.setToneHapticsSettings(systemSoundManagerInstance, context, toneHapticsType
          , toneHapticsSettings);
      } else {
        let toneHapticsSettings: MyToneHapticsSettings = new MyToneHapticsSettings(
          systemSoundManager.ToneHapticsMode.SYNC);
        await VibrateUtil.setToneHapticsSettings(systemSoundManagerInstance, context, toneHapticsType
          , toneHapticsSettings);
      }
    }
  }

  /**
   * 更新内存中的振动参数
   *
   * @param sysSoundManager
   * @param context
   * @param vibrateParamKey
   * @param vibrateParam
   * @returns
   */
  private async updateVibrateParamInMemory(sysSoundManager: systemSoundManager.SystemSoundManager | undefined
    , context: Context, vibrateParamKey: string, vibrateParam: VibrateParam): Promise<VibrateParam> {
    if (vibrateParam.toneHapticsType === undefined || vibrateParam.toneHapticsType === null) {
      LogUtil.showWarn(TAG, 'vibrateParam has no toneHapticsType');
      return vibrateParam;
    }
    let defaultVibrateParam: VibrateParam = new VibrateParam();
    vibrateParam = VibrateUtil.getVibrateParamInMemory(vibrateParamKey, defaultVibrateParam) as VibrateParam;
    let isSystemRingTone: boolean = VibrateUtil.isSystemRingTone(vibrateParam.toneHapticsType);
    vibrateParam = await VibrateUtil.updateVibrateParam(sysSoundManager, context, vibrateParam, isSystemRingTone);
    await PreferencesUtil.putSync(vibrateParamKey, vibrateParam);
    return vibrateParam;
  }
}
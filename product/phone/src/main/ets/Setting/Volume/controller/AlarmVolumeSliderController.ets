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
import { audio } from '@kit.AudioKit';
import { BusinessError } from '@ohos.base';
import { EventBus } from '@ohos/settings.common/src/main/ets/framework/common/EventBus';
import { CommonEventConstant } from '@ohos/settings.common/src/main/ets/constant/CommonEventConstant';
import { HiSysEventUtil } from '@ohos/settings.common/src/main/ets/systemEvent/HiSysEventUtil';
import { LogUtil } from '@ohos/settings.common/src/main/ets/utils/LogUtil';
import { HiSysVolumeEventGroup } from '@ohos/settings.common/src/main/ets/systemEvent/BehaviorEventConsts';
import { MAX_VOLUME_SLIDER_VALUE, RingtoneType, VOLUME_PERCENT } from '../constant/VolumeConstant';
import { RingtonesUtils } from '../utils/RingtonesUtils';
import { AvplayerController } from './AvplayerController';
import { AUDIO_VOLUME_TYPE_ALARM } from './VolumeAdapter';
import { VolumeSliderController } from './VolumeSliderController';

const TAG = 'AlarmVolumeSliderController :';
let timerClock: number | null = null;

let audioManager = audio.getAudioManager();
let audioSessionManager: audio.AudioSessionManager = audioManager.getSessionManager();
let strategy: audio.AudioSessionStrategy = {
  concurrencyMode: audio.AudioConcurrencyMode.CONCURRENCY_MIX_WITH_OTHERS
};

export class AlarmVolumeSliderController extends VolumeSliderController {
  private readonly MIN_ALARM_VOLUME: number = 1;
  private minAlarmValue: number = 1;
  private curValue: number = -1;
  private isShowNow: boolean = true;
  private isActivated: boolean = false;

  init(): void {
    super.init();
    super.registerListener();
    EventBus.getInstance().on(CommonEventConstant.EVENT_VOLUME_PAGE_SHOW, this.onPageShowCallback);
    EventBus.getInstance().on(CommonEventConstant.EVENT_VOLUME_PAGE_HIDE, this.onPageHideCallback);
  }

  /*
  * pageShow
  */
  private onPageShowCallback = (() => {
    LogUtil.info(`${TAG} onPageShowCallback`);
    this.isShowNow = true;
  });

  /*
   * pageHide 暂停ringTonePlayer播放
   */
  private onPageHideCallback = (() => {
    LogUtil.info(`${TAG} onPageHideCallback`);
    this.isShowNow = false;
    AvplayerController.releaseAvplayer();
    clearTimeout(timerClock);
    this.deactivateAudioSession();
  });

  private deactivateAudioSession(): void {
    if (this.isActivated) {
      this.isActivated = false;
      // 停用音频会话
      audioSessionManager.deactivateAudioSession().then(() => {
        LogUtil.info(`${TAG} deactivateAudioSession success`);
      }).catch((err: BusinessError) => {
        LogUtil.error(`${TAG}  deactivateAudioSession error, code:${err?.code}, message:${err?.message}`);
      });
    }
  }

  private activateAudioSession(): void {
    if (!this.isActivated) {
      this.isActivated = true;
      // 激活音频会话
      audioSessionManager.activateAudioSession(strategy).then(() => {
        LogUtil.info(`${TAG} activateAudioSession success`);
      }).catch((err: BusinessError) => {
        LogUtil.error(`${TAG} activateAudioSession error, code:${err?.code}, message:${err?.message}`);
        this.isActivated = false;
      });
    }
  }

  destroy(): void {
    EventBus.getInstance().detach(CommonEventConstant.EVENT_VOLUME_PAGE_SHOW, this.onPageShowCallback);
    EventBus.getInstance().detach(CommonEventConstant.EVENT_VOLUME_PAGE_HIDE, this.onPageHideCallback);
    super.unRegisterListener();
    super.destroy();
  }

  getVolumeType(): number {
    return AUDIO_VOLUME_TYPE_ALARM;
  }

  onSliderChange(sliderValue: number, sliderChangeMode: number): boolean {
    let alarmVolume = sliderValue;
    if (timerClock) {
      clearTimeout(timerClock);
    }
    if (this.curValue === -1) {
      this.curValue = sliderValue;
    }
    if (this.curValue !== sliderValue && sliderChangeMode === SliderChangeMode.End) {
      this.curValue = sliderValue;
      if (sliderValue <= this.MIN_ALARM_VOLUME) {
        alarmVolume = this.MIN_ALARM_VOLUME;
        sliderValue = this.MIN_ALARM_VOLUME;
      }
      this.activateAudioSession();
      HiSysEventUtil.reportDefaultBehaviorEventByUE(HiSysVolumeEventGroup.VOLUME_ALARM_CONTROL, sliderValue.toString());
      EventBus.getInstance().emit(CommonEventConstant.EVENT_VOLUME_AVPLAYER_PLAYING);
      timerClock = setTimeout(() => {
        // 如果avplayer在播放先关闭
        AvplayerController.releaseAvplayer();
        RingtonesUtils.getRingtoneUri(RingtoneType.RINGTONE_TYPE_ALARM, getContext(this)).then((ringToneUri) => {
          if (this.isShowNow) {
            AvplayerController.avPlayerUrl(Math.floor((sliderValue / MAX_VOLUME_SLIDER_VALUE) * VOLUME_PERCENT) /
              VOLUME_PERCENT, this.getVolumeType(), ringToneUri, false);
          }
        });
        timerClock = null;
      }, this.getVolumeDelay());
    }
    return super.onSliderChange(alarmVolume, sliderChangeMode);
  }

  setSliderValue(sliderValue: number): void {
    if (this.sliderValue !== sliderValue) {
      this.sliderValue = sliderValue < this.minAlarmValue ? this.minAlarmValue : sliderValue;
      EventBus.getInstance().emit('slider_alarm_volume_value', this.sliderValue);
      return;
    }
    if (sliderValue === this.minAlarmValue) {
      EventBus.getInstance().emit('slider_alarm_volume_value', sliderValue);
    }
  }
}
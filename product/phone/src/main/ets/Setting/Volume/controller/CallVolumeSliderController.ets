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
import { EventBus } from '@ohos/settings.common/src/main/ets/framework/common/EventBus';
import { CommonEventConstant } from '@ohos/settings.common/src/main/ets/constant/CommonEventConstant';
import { HiSysEventUtil } from '@ohos/settings.common/src/main/ets/systemEvent/HiSysEventUtil';
import { AUDIO_VOLUME_TYPE_CALL } from './VolumeAdapter';
import { AvplayerController } from './AvplayerController';
import { VolumeSliderController } from './VolumeSliderController';
import { HiSysVolumeEventGroup } from '@ohos/settings.common/src/main/ets/systemEvent/BehaviorEventConsts';

export class CallVolumeSliderController extends VolumeSliderController {
  private readonly MIN_CALL_VOLUME = 1;

  init(): void {
    super.init();
    super.registerListener();
  }

  destroy(): void {
    super.unRegisterListener();
    super.destroy();
  }

  getVolumeType(): number {
    return AUDIO_VOLUME_TYPE_CALL;
  }

  onSliderChange(sliderValue: number, sliderChangeMode: number): boolean {
    let callVolume = sliderValue;
    if (sliderChangeMode === SliderChangeMode.End) {
      HiSysEventUtil.reportDefaultBehaviorEventByUE(HiSysVolumeEventGroup.VOLUME_CALL_CONTROL, sliderValue.toString());
      EventBus.getInstance().emit(CommonEventConstant.EVENT_VOLUME_AVPLAYER_PLAYING);
      // 通话音量的最小值为1，不能设为0
      if (sliderValue <= this.MIN_CALL_VOLUME) {
        callVolume = this.MIN_CALL_VOLUME;
      }
    }
    AvplayerController.releaseAvplayer();
    return super.onSliderChange(callVolume, sliderChangeMode);
  }

  setSliderValue(sliderValue: number): void {
    if (this.sliderValue !== sliderValue) {
      this.sliderValue = sliderValue <= this.MIN_CALL_VOLUME ? this.MIN_CALL_VOLUME : sliderValue;
      EventBus.getInstance().emit('slider_call_volume_value', this.sliderValue);
      return;
    }

    if (sliderValue === this.MIN_CALL_VOLUME) {
      EventBus.getInstance().emit('slider_call_volume_value', sliderValue);
    }
  }
}
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
import { LogUtil } from '@ohos/settings.common/src/main/ets/utils/LogUtil';
import { HiSysVolumeEventGroup } from '@ohos/settings.common/src/main/ets/systemEvent/BehaviorEventConsts';
import { HiSysEventUtil } from '@ohos/settings.common/src/main/ets/systemEvent/HiSysEventUtil';
import { AvplayerController } from './AvplayerController';
import { AUDIO_VOLUME_TYPE_VOICE_ASSISTANT } from './VolumeAdapter';
import { VolumeSliderController } from './VolumeSliderController';

const TAG: string = 'VassistantVolumeSliderController';

export class VassistantVolumeSliderController extends VolumeSliderController {
  private minValue: number = 0;

  init(): void {
    super.init();
    super.registerListener();
  }

  destroy(): void {
    super.unRegisterListener();
    super.destroy();
  }

  getVolumeType(): number {
    return AUDIO_VOLUME_TYPE_VOICE_ASSISTANT;
  }

  onSliderChange(sliderValue: number, sliderChangeMode: number): boolean {
    let volume = sliderValue;
    if (sliderChangeMode === SliderChangeMode.End) {
      HiSysEventUtil.reportDefaultBehaviorEventByUE(HiSysVolumeEventGroup.VOLUME_VASSISTANT_CONTROL,
        sliderValue.toString());
      if (sliderValue <= this.minValue) {
        volume = this.minValue;
      }
    }
    LogUtil.showInfo(TAG, `volume is ${volume}`);
    EventBus.getInstance().emit(CommonEventConstant.EVENT_VOLUME_AVPLAYER_PLAYING);
    AvplayerController.releaseAvplayer();
    return super.onSliderChange(volume, sliderChangeMode);
  }

  setSliderValue(sliderValue: number): void {
    if (this.sliderValue !== sliderValue) {
      this.sliderValue = sliderValue < this.minValue ? this.minValue : sliderValue;
      EventBus.getInstance().emit('slider_vassistant_volume_value', this.sliderValue);
      return;
    }
    if (sliderValue === this.minValue) {
      EventBus.getInstance().emit('slider_vassistant_volume_value', sliderValue);
    }
  }
}
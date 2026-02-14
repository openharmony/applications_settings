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
import { LogUtil } from '@ohos/settings.common/src/main/ets/utils/LogUtil';
import { TouchpadPointerSpeedController } from '../controller/TouchpadPointerSpeedController';
import { TouchPadConstants } from '../utils/Constants';

@Component
export struct TouchpadPointerSpeedComponent {
  private tag: string = 'TouchpadPointerSpeedComponent: ';
  private controller: TouchpadPointerSpeedController = new TouchpadPointerSpeedController();
  @StorageLink('touchpad_speed') sliderValue: number = TouchPadConstants.DEFAULT_SPEED;

  aboutToAppear(): void {
    LogUtil.info(`${this.tag} aboutToAppear`);
    this.sliderValue = this.controller.getPointerSpeed();
  }

  aboutToDisappear(): void {
    LogUtil.info(`${this.tag} aboutToDisappear`);
  }

  build() {
    Column() {
      Slider({
        value: this.sliderValue,
        min: TouchPadConstants.POINTER_MIN_SPEED,
        max: TouchPadConstants.POINTER_MAX_SPEED,
        step: TouchPadConstants.POINTER_SPEED_SIZE,
        style: SliderStyle.InSet
      })
        .onChange((value: number, mode: SliderChangeMode) => {
          this.controller.onSliderChange(value, mode);
        })
        .id('touchpad_pointer_speed_slider')
        .selectedColor($r('sys.color.brand'))
        .align(Alignment.Center)
        .width('100%')
    }
    .borderRadius($r('sys.float.corner_radius_level8'))
    .height($r('app.float.height_64'))
    .padding({
      left: $r('sys.float.padding_level6'),
      right: $r('sys.float.padding_level6'),
    })
    .justifyContent(FlexAlign.Center)
    .width('100%')
  }
}
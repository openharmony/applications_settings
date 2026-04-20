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
import { LogUtil } from '@ohos/settings.common/src/main/ets/utils/LogUtil';
import { MouseSettingsManager } from '../MouseSettingsManager';
import { MouseConstants, MouseSliderType } from '../utils/Constants';

export class MousePointerSliderController {
  private tag: string = 'MousePointerSliderController: ';
  private sliderValue: number = 0;
  private sliderType: number = MouseSliderType.DEFAULT;
  public maxValue: number = 0;
  public minValue: number = 0;

  public init(sliderType: number): void {
    this.sliderType = sliderType;
    switch (this.sliderType) {
      case MouseSliderType.MousePointerSize:
        this.maxValue = MouseConstants.MOUSE_MAX_SIZE;
        this.minValue = MouseConstants.MOUSE_MIN_SIZE;
        this.sliderValue = MouseSettingsManager.getInstance().getMousePointSize();
        break;
      case MouseSliderType.MousePointerSpeed:
        this.maxValue = MouseConstants.MOUSE_MAX_SPEED;
        this.minValue = MouseConstants.MOUSE_MIN_SPEED;
        this.sliderValue = MouseSettingsManager.getInstance().getPointerSpeed();
        break;
      default:
        break;
    }
  }

  public getSliderValue(): number {
    switch (this.sliderType) {
      case MouseSliderType.MousePointerSize:
        this.sliderValue = MouseSettingsManager.getInstance().getMousePointSize();
        break;
      case MouseSliderType.MousePointerSpeed:
        this.sliderValue = MouseSettingsManager.getInstance().getPointerSpeed();
      default:
        break;
    }
    return this.sliderValue;
  }

  public setSliderValue(sliderValue: number) {
    switch (this.sliderType) {
      case MouseSliderType.MousePointerSize:
        MouseSettingsManager.getInstance().setMousePointSize(sliderValue);
        break;
      case MouseSliderType.MousePointerSpeed:
        MouseSettingsManager.getInstance().setPointerSpeed(sliderValue);
      default:
        break;
    }
  }

  public onSliderChange(sliderValue: number, sliderChangeMode: number): void {
    if (sliderChangeMode === SliderChangeMode.Begin) {
      LogUtil.info(`${this.tag}, onSliderChange slider begin`);
      return;
    }
    if (sliderChangeMode === SliderChangeMode.End) {
      this.setSliderValue(sliderValue);
      LogUtil.info(`${this.tag} onSliderChange ${sliderValue}`);
    }
  }
}
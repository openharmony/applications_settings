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
import { SliderConstants } from '../constant/Constants';

export class SliderMenuController {
  public tag: string = 'SliderMenuController : ';

  protected sliderValue: number = SliderConstants.SLIDER_VALUE_0;

  init(): void {
  }

  destroy(): void {
  }

  getSliderMin(): number {
    return SliderConstants.MIN;
  }

  getSliderMax(): number {
    return SliderConstants.MAX;
  }

  getSliderStep(): number {
    return SliderConstants.STEP;
  }

  getSliderValue(): number {
    return this.sliderValue;
  }

  protected updateSliderValue(): number {
    return this.sliderValue;
  }

  setSliderValue(sliderValue: number): void {
    if (this.sliderValue !== sliderValue) {
      this.sliderValue = sliderValue;
      this.refreshUi();
    }
  }

  onSliderChange(sliderValue: number, sliderChangeMode: number): void {
    this.sliderValue = sliderValue;
  }

  updateStatus(): void {
    this.setSliderValue(this.updateSliderValue());
  }

  onStartIconClick(): void {
  }

  onEndIconClick(): void {
  }

  isShowSteps(): boolean {
    return false;
  }

  protected refreshUi():void {
  }
}
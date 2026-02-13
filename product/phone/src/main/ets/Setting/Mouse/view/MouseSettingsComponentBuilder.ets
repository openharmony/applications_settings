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
import {
  MouseImageComponent,
  MouseStyleRadioComponent,
  SplitMouseRadioComponent,
  SplitMouseSliderComponent
} from './MouseSettingsComponent';
import { MouseSettingsManager } from '../MouseSettingsManager';
import { MouseSliderType, MouseStyleType } from '../utils/Constants';

@Builder
export function mouseImageBuilder(param: object): void {
  MouseImageComponent();
}

@Builder
export function mouseDotStyleToggleBuilder(param: object): void {
  MouseStyleRadioComponent({
    mouseStyleType: MouseStyleType.MouseDotCursor,
    isChecked: MouseSettingsManager.getInstance().isCircleStyle()
  });
}

@Builder
export function mouseArrowStyleToggleBuilder(param: object): void {
  MouseStyleRadioComponent({
    mouseStyleType: MouseStyleType.MouseArrowCursor,
    isChecked: !MouseSettingsManager.getInstance().isCircleStyle()
  });
}

@Builder
export function mouseColorBuilder(param: object): void {
  SplitMouseRadioComponent();
}

@Builder
export function mouseSizeBuilder(param: object): void {
  SplitMouseSliderComponent({
    sliderValue: MouseSettingsManager.getInstance().getMousePointSize(),
    sliderType: MouseSliderType.MousePointerSize,
    title: $r('app.string.mouse_pointer_size')
  });
}

@Builder
export function mouseSpeedBuilder(param: object): void {
  SplitMouseSliderComponent({
    sliderValue: MouseSettingsManager.getInstance().getPointerSpeed(),
    sliderType: MouseSliderType.MousePointerSpeed,
    title: $r('app.string.cursor_tracking_speed')
  });
}
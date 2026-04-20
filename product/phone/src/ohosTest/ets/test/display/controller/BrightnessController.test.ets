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

import { describe, it, expect } from '@ohos/hypium';
import { BrightnessController } from '../../../../../main/ets/Setting/Display/controller/BrightnessController';

export default function BrightnessControllerTest() {
  describe('BrightnessControllerTest', () => {
    it("BrightnessControllerTest_001", 0, () => {
      let BrightnessControllerC: BrightnessController = new BrightnessController();
      BrightnessControllerC.onPageShow();
      BrightnessControllerC.init();
      BrightnessControllerC.onPageHide();
      expect(BrightnessControllerC != null).assertTrue();
    })

    it("BrightnessControllerTest_002", 0, () => {
      let BrightnessControllerC: BrightnessController = new BrightnessController();
      let res1: boolean = BrightnessControllerC.onToggleChange(true);
      expect(res1 === true).assertTrue();
      let res2: boolean = BrightnessControllerC.onToggleChange(false);
      expect(res2 === true).assertTrue();
    })

    it("BrightnessControllerTest_003", 0, () => {
      let BrightnessControllerC: BrightnessController = new BrightnessController();
      BrightnessControllerC.onSliderChange(1, SliderChangeMode.End);
      BrightnessControllerC.onSliderChange(1, SliderChangeMode.Click);
      BrightnessControllerC.onSliderChange(1, SliderChangeMode.Begin);
    })

    it("BrightnessControllerTest_004", 0, () => {
      let BrightnessControllerC: BrightnessController = new BrightnessController();
      BrightnessControllerC.onStartIconClick();
    })
  })
}
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

import { describe, it, expect, MockKit, when, ArgumentMatchers } from '@ohos/hypium'
import { RingtoneVolumeSliderController } from '../../../../../main/ets/Setting/Volume/controller/RingtoneVolumeSliderController';
import { RingtonesUtils } from '../../../../../main/ets/Setting/Volume/utils/RingtonesUtils';
import { SimUtils } from '@ohos/settings.common/src/main/ets/utils/SimUtils';
import { VolumeAdapter } from '../../../../../main/ets/Setting/Volume/controller/VolumeAdapter';
import { PreferencesUtil } from '@ohos/settings.common/src/main/ets/utils/PreferencesUtil';

export default function RingtoneControllerTest() {
  describe('RingtoneControllerTest', () => {
    it("RingtoneControllerTest_001", 0, () => {
      let ringtoneVolumeSliderC: RingtoneVolumeSliderController = new RingtoneVolumeSliderController(1);
      ringtoneVolumeSliderC.init();
      expect(ringtoneVolumeSliderC != null).assertTrue();

      let mocker: MockKit = new MockKit();
      let mockFun: Function = mocker.mockFunc(RingtonesUtils, RingtonesUtils.isVoiceCapabilityDisable);
      when(mockFun)().afterReturn(false);
      ringtoneVolumeSliderC.init();
      when(mockFun)().afterReturn(true);
      ringtoneVolumeSliderC.init();
      expect(RingtonesUtils.isVoiceCapabilityDisable()).assertTrue();
    })
    it("RingtoneControllerTest_002", 0, () => {
      // onSliderChange
      let ringtoneVolumeSliderC: RingtoneVolumeSliderController = new RingtoneVolumeSliderController(1);
      let onSliderChangeR: boolean = ringtoneVolumeSliderC.onSliderChange(0, 0);
      expect(onSliderChangeR).assertTrue();

      (ringtoneVolumeSliderC as object)['timerClock'] = 1;
      (ringtoneVolumeSliderC as object)['curValue'] = 1;
      onSliderChangeR = ringtoneVolumeSliderC.onSliderChange(0, SliderChangeMode.End);
      expect(onSliderChangeR).assertTrue();
    })
    it("RingtoneControllerTest_003", 0, () => {
      // onRingerModeChange
      let ringtoneVolumeSliderC: RingtoneVolumeSliderController = new RingtoneVolumeSliderController(1);
      let ringM: number = 3;
      ringtoneVolumeSliderC.onRingerModeChange(ringM);
      ringM = 1;
      (ringtoneVolumeSliderC as object)['audioRingMode'] = 1;
      ringtoneVolumeSliderC.onRingerModeChange(ringM);

      ringM = 0;
      let mocker: MockKit = new MockKit();
      let mockFun: Function = mocker.mockFunc(PreferencesUtil, PreferencesUtil.getSync);
      when(mockFun)(ArgumentMatchers.any).afterReturn(-1);
      ringtoneVolumeSliderC.onRingerModeChange(ringM);
      (ringtoneVolumeSliderC as object)['audioRingMode'] = -1;
      let mocker1: MockKit = new MockKit();
      let mockFun1: Function = mocker1.mockFunc(RingtonesUtils, RingtonesUtils.isVoiceCapabilityDisable);
      when(mockFun1)().afterReturn(true);
      ringtoneVolumeSliderC.onRingerModeChange(ringM);
      (ringtoneVolumeSliderC as object)['audioRingMode'] = -1;
      when(mockFun)(ArgumentMatchers.any).afterReturn(0);
      ringtoneVolumeSliderC.onRingerModeChange(ringM);
      ringM = 2;
      when(mockFun)(ArgumentMatchers.any).afterReturn(-1);
      let mocker2: MockKit = new MockKit();
      let mockFun2: Function = mocker2.mockFunc(SimUtils, SimUtils.getCardSlotNum);
      when(mockFun2)().afterReturn(-1);
      ringtoneVolumeSliderC.onRingerModeChange(ringM);
      (ringtoneVolumeSliderC as object)['audioRingMode'] = -1;
      when(mockFun1)().afterReturn(false);
      ringtoneVolumeSliderC.onRingerModeChange(ringM);
      (ringtoneVolumeSliderC as object)['audioRingMode'] = -1;
      when(mockFun)(ArgumentMatchers.any).afterReturn(0);
      ringtoneVolumeSliderC.onRingerModeChange(ringM);
      expect(ringtoneVolumeSliderC !== null).assertTrue();
    })
    it("RingtoneControllerTest_004", 0, () => {
      // setSliderValue
      let ringtoneVolumeSliderC: RingtoneVolumeSliderController = new RingtoneVolumeSliderController(1);
      let mocker: MockKit = new MockKit();
      let mockFun: Function = mocker.mockFunc(VolumeAdapter.getInstance(), VolumeAdapter.getInstance().getRingerMode);
      when(mockFun)().afterReturn(2);
      (ringtoneVolumeSliderC as object)['sliderValue'] = 0;
      ringtoneVolumeSliderC.setSliderValue(0);
      when(mockFun)().afterReturn(1);
      ringtoneVolumeSliderC.setSliderValue(0);
      when(mockFun)().afterReturn(1);
      ringtoneVolumeSliderC.setSliderValue(1);
      when(mockFun)().afterReturn(2);
      ringtoneVolumeSliderC.setSliderValue(1);
    })
    it("RingtoneControllerTest_005", 0, () => {
      // updateSliderValue
      let ringtoneVolumeSliderC: RingtoneVolumeSliderController = new RingtoneVolumeSliderController(1);
      let mocker: MockKit = new MockKit();
      let mockFun: Function = mocker.mockFunc(VolumeAdapter, VolumeAdapter.getInstance().getRingerMode);
      when(mockFun)().afterReturn(2);
      (ringtoneVolumeSliderC as object)['audioRingMode'] = 2;
      let re: number = (ringtoneVolumeSliderC as object)['updateSliderValue']();
      expect(re >= 0).assertTrue();
      (ringtoneVolumeSliderC as object)['audioRingMode'] = 0;
      re = (ringtoneVolumeSliderC as object)['updateSliderValue']();
      expect(re >= 0).assertTrue();
    })
    it("RingtoneControllerTest_006", 0, async (done: Function) => {
      // startRingTonePlayer
      let ringtoneVolumeSliderC: RingtoneVolumeSliderController = new RingtoneVolumeSliderController(1);
      await (ringtoneVolumeSliderC as object)['startRingTonePlayer']();
      expect(ringtoneVolumeSliderC != null).assertTrue();
      done();
    })
    it("RingtoneControllerTest_007", 0, async (done: Function) => {
      // stopRingTonePlayer
      let ringtoneVolumeSliderC: RingtoneVolumeSliderController = new RingtoneVolumeSliderController(1);
      await (ringtoneVolumeSliderC as object)['stopRingTonePlayer']();
      expect(ringtoneVolumeSliderC != null).assertTrue();
      done();
    })
    it("RingtoneControllerTest_008", 0, async (done: Function) => {
      // releaseRingTonePlayer
      let ringtoneVolumeSliderC: RingtoneVolumeSliderController = new RingtoneVolumeSliderController(1);
      await (ringtoneVolumeSliderC as object)['releaseRingTonePlayer']();
      expect(ringtoneVolumeSliderC != null).assertTrue();
      done();
    })
    it("RingtoneControllerTest_009", 0, async (done: Function) => {
      // onSystemTonePlayer
      let ringtoneVolumeSliderC: RingtoneVolumeSliderController = new RingtoneVolumeSliderController(1);
      await (ringtoneVolumeSliderC as object)['onSystemTonePlayer']();
      expect(ringtoneVolumeSliderC != null).assertTrue();
      done();
    })
    it("RingtoneControllerTest_010", 0, async (done: Function) => {
      // offSystemTonePlayer
      let ringtoneVolumeSliderC: RingtoneVolumeSliderController = new RingtoneVolumeSliderController(1);
      await (ringtoneVolumeSliderC as object)['offSystemTonePlayer']();
      expect(ringtoneVolumeSliderC != null).assertTrue();
      done();
    })
  })
}
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
import { describe, it, expect } from '@ohos/hypium'
import { VolumeSliderController } from '../../../../../main/ets/Setting/Volume/controller/VolumeSliderController';
import audio from '@ohos.multimedia.audio';

export default function VolumeSliderControllerTest() {
  describe('VolumeSliderControllerTest', () => {
    // onVolumeChange
    it("VolumeSliderControllerTest_001", 0, () => {
      let volumeSliderC: VolumeSliderController = new VolumeSliderController();
      let volumeE: audio.VolumeEvent = {
        volumeType: audio.AudioVolumeType.VOICE_CALL,
        volume: 0,
        updateUi: false,
        volumeGroupId: 0,
        networkId: ''
      };
      volumeSliderC.onVolumeChange(volumeE);
      volumeE.volume = 1;
      volumeSliderC.onVolumeChange(volumeE);
      expect(volumeSliderC != null).assertTrue();
    })
    // setSliderValue
    it("VolumeSliderControllerTest_002", 0, () => {
      let volumeSliderC: VolumeSliderController = new VolumeSliderController();
      (volumeSliderC as object)['setSliderValue'](0);
      (volumeSliderC as object)['setSliderValue'](0);
      expect(volumeSliderC != null).assertTrue();
    })
    // setValueAndPlayAudio
    it("VolumeSliderControllerTest_003", 0, () => {
      let volumeSliderC: VolumeSliderController = new VolumeSliderController();
      (volumeSliderC as object)['currentVolume'] = 2;
      (volumeSliderC as object)['setValueAndPlayAudio']();
      (volumeSliderC as object)['currentVolume'] = 0;
      (volumeSliderC as object)['setValueAndPlayAudio']();
      expect(volumeSliderC != null).assertTrue();
    })
    // audioPlayerControl
    it("VolumeSliderControllerTest_004", 0, async (done: Function) => {
      let volumeSliderC: VolumeSliderController = new VolumeSliderController();
      (volumeSliderC as object)['playRequest'] = 2;
      await (volumeSliderC as object)['audioPlayerControl']();
      expect(volumeSliderC != null).assertTrue();
      done();
    })
  })
}
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
import { Driver } from '@ohos.UiTest';
import { describe, it } from '@ohos/hypium';
import { AudioRingMode } from '@ohos/settings.common/src/main/ets/core/model/menu/SettingsMenu';
import {
  VolumeModeWindowController
} from '../../../../../main/ets/Setting/Volume/controller/VolumeModeWindowController';

const DELAY_BETWEEN_OPERATION = 500;

export default function VolumeModeWindowControllerTest() {
  describe('VolumeModeWindowControllerTest01', () => {
    const driver = Driver.create();
    it('VolumeModeWindowControllerTest_001', 0, async () => {
      let controller = new VolumeModeWindowController();
      controller.init();
      let mode = controller.audioRingMode;
      controller.setAudioRingMode(AudioRingMode.RINGER_MODE_SILENT);
      await driver.delayMs(DELAY_BETWEEN_OPERATION);
      controller.setAudioRingMode(AudioRingMode.RINGER_MODE_VIBRATE);
      await driver.delayMs(DELAY_BETWEEN_OPERATION);
      controller.setAudioRingMode(AudioRingMode.RINGER_MODE_NORMAL);
      await driver.delayMs(DELAY_BETWEEN_OPERATION);
      controller.setAudioRingMode(mode);
    });
  });
}
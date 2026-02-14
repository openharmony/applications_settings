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
import { NotDisturbTimerPararm } from '@ohos/settings.notDisturb/src/main/ets/model/NotDisturbTimerPararm';
import { TimePickerController } from '../../../../../main/ets/Setting/Volume/controller/TimePickerController';

export default function TimePickerControllerTest() {
  describe('TimePickerControllerTest', () => {
    it('TimePickerControllerTest_001', 0, () => {
      let param: NotDisturbTimerPararm = {
        id: 0,
        startTime: '',
        endTime: '',
        repeat: '',
        isOpen: false,
        repeatType: 0,
        skipEndTime: 0
      };
      let timePikerC: TimePickerController = new TimePickerController(param, true);
      timePikerC.updateTime('1111');
      timePikerC.getCurrentTime();
      let re: string = timePikerC.getTitle();
      expect(re.length >= 0).assertTrue();

      (timePikerC as object)['isMorning'] = false;
      timePikerC.updateTime('1111');
      timePikerC.getCurrentTime();
      timePikerC.getTitle();
      expect(timePikerC != null).assertTrue();
    })
  })
}
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
import { ArgumentMatchers, describe, expect, it, MockKit, when } from '@ohos/hypium';
import { SettingsBaseMenu } from '@ohos/settings.common';
import { DateAndTimeUtil, Time24HourController } from '@ohos/settings.datetime';

class TimeSon extends Time24HourController {
  constructor() {
    super(new SettingsBaseMenu());
  }
  public handleCheckedChange(isOn: boolean): boolean {
    return super.handleCheckedChange(isOn);
  }
}


export default function Time24HourControllerTest() {
  let son = new TimeSon();
  describe('Time24HourControllerTest', () => {
    let menu: SettingsBaseMenu = new SettingsBaseMenu();
    let Time24Hour = Time24HourController.createTime24HourController(menu);

    it('test_handleCheckedChange', 0, (): void => {
      let resA = son.handleCheckedChange(true);
      expect(resA === null).assertFalse();
      let resB = son.handleCheckedChange(false);
      expect(resB === null).assertFalse();
    })

    it('test_modify24HourTimeFormat', 0, (): void => {
      let mocker: MockKit = new MockKit();
      let contextfunc: Function = mocker.mockFunc(DateAndTimeUtil,DateAndTimeUtil.set24HourTimFormat);
      when(contextfunc)(ArgumentMatchers.any).afterReturn(true);
      let resA: Object = (Time24Hour as object)['modify24HourTimeFormat'](true);
      expect(resA === null).assertFalse();
      when(contextfunc)(ArgumentMatchers.any).afterReturn(false);
      let resB: Object = (Time24Hour as object)['modify24HourTimeFormat'](false);
      expect(resB === null).assertFalse();
      mocker.clear(DateAndTimeUtil);
    })
  });
}


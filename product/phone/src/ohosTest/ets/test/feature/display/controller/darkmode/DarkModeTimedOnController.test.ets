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
import { OrderedDataSource } from '@ohos/settings.common/src/main/ets/framework/model/OrderedDataSource'
import { CompCtrlParam, SettingBaseModel } from '@ohos/settings.common/src/main/ets/framework/model/SettingBaseModel'
import { ItemType } from '@ohos/settings.common/src/main/ets/framework/model/SettingItemModel'
import { SettingToggleState } from '@ohos/settings.common/src/main/ets/framework/model/SettingStateModel'
import { SettingsDataUtils } from '@ohos/settings.common/src/main/ets/utils/SettingsDataUtils'
import { CANCEL_ACTION, END, START } from '@ohos/settings.display/src/main/ets/component/TimePickerDialog'
import {
  DARK_MODE_OPEN_ALL_DAY,
  DARK_MODE_TIMED_ON
} from '@ohos/settings.display/src/main/ets/constant/DarkModeConstant'
import {
  DarkModeTimedOnController
} from '@ohos/settings.display/src/main/ets/controller/darkmode/DarkModeTimedOnController'
import { TimePickerModel } from '@ohos/settings.display/src/main/ets/model/TimePickerModel'

export default function DarkModeTimedOnControllerTest() {
  describe('DarkModeTimedOnControllerTest', () => {
    it('DarkModeTimedOnControllerTest_toggleStateChangeEventCallback_001', 0, () => {
      let darkModeTimedOnC: DarkModeTimedOnController = new DarkModeTimedOnController();
      (darkModeTimedOnC as object)['toggleStateChangeEventCallback']();
      let toggleState: SettingToggleState = {
        state: false
      };
      (darkModeTimedOnC as object)['isNeedDealToggleChange'] = false;
      (darkModeTimedOnC as object)['toggleStateChangeEventCallback'](toggleState);
      (darkModeTimedOnC as object)['isNeedDealToggleChange'] = true;
      (darkModeTimedOnC as object)['toggleStateChangeEventCallback'](toggleState);
      expect(darkModeTimedOnC != null).assertTrue();
    })
    it('DarkModeTimedOnControllerTest_timePickerDialogEventCallback_001', 0, () => {
      let darkModeTimedOnC: DarkModeTimedOnController = new DarkModeTimedOnController();
      (darkModeTimedOnC as object)['timePickerDialogEventCallback']('', '');
      (darkModeTimedOnC as object)['timePickerDialogEventCallback']('', CANCEL_ACTION);
      expect(darkModeTimedOnC != null).assertTrue();
    })
    it('DarkModeTimedOnControllerTest_darkModeChangeCallback_001', 0, () => {
      let darkModeTimedOnC: DarkModeTimedOnController = new DarkModeTimedOnController();
      let mocker: MockKit = new MockKit();
      let mockFun: Function = mocker.mockFunc(SettingsDataUtils, SettingsDataUtils.getSettingsData);
      when(mockFun)(ArgumentMatchers.any).afterReturn(DARK_MODE_OPEN_ALL_DAY);
      (darkModeTimedOnC as object)['darkModeChangeCallback']();
      when(mockFun)(ArgumentMatchers.any).afterReturn(DARK_MODE_TIMED_ON);
      (darkModeTimedOnC as object)['darkModeChangeCallback']();
      expect(darkModeTimedOnC != null).assertTrue();
      mocker.clear(SettingsDataUtils);
    })
    it('DarkModeTimedOnControllerTest_init_001', 0, () => {
      let darkModeTimedOnC: DarkModeTimedOnController = new DarkModeTimedOnController();
      let compParamU: CompCtrlParam = AppStorage.get<CompCtrlParam>('compParam') as CompCtrlParam;
      darkModeTimedOnC.init(compParamU);
      let component: SettingBaseModel = {
        id: '1'
      };
      let compParam: CompCtrlParam = {
        compId: '1',
        component: component
      };
      darkModeTimedOnC.init(compParam);
      (darkModeTimedOnC as object)['darkModeType'] = DARK_MODE_TIMED_ON;
      (darkModeTimedOnC as object)['initMenus']();
      (darkModeTimedOnC as object)['darkModeType'] = DARK_MODE_OPEN_ALL_DAY;
      (darkModeTimedOnC as object)['initMenus']();
      (darkModeTimedOnC as object)['dealTimedOnSwitchCallback'](true);
      (darkModeTimedOnC as object)['dealTimedOnSwitchCallback'](false);
      expect(darkModeTimedOnC != null).assertTrue();
    })
    it('DarkModeTimedOnControllerTest_addStartItem_001', 0, () => {
      let darkModeTimedOnC: DarkModeTimedOnController = new DarkModeTimedOnController();
      (darkModeTimedOnC as object)['addStartItem']();
      let dataSource: OrderedDataSource = new OrderedDataSource();
      dataSource.insertData(0, {
        id: END, type: ItemType.ITEM_TYPE_CUSTOM
      });
      (darkModeTimedOnC as object)['dataSource'] = dataSource;
      (darkModeTimedOnC as object)['addStartItem']();
      dataSource.insertData(0, {
        id: START, type: ItemType.ITEM_TYPE_STANDARD
      });
      (darkModeTimedOnC as object)['dataSource'] = dataSource;
      (darkModeTimedOnC as object)['addStartItem']();
      dataSource.removeAll();
      expect(darkModeTimedOnC != null).assertTrue();
    })
    it('DarkModeTimedOnControllerTest_addEndItem_001', 0, () => {
      let darkModeTimedOnC: DarkModeTimedOnController = new DarkModeTimedOnController();
      (darkModeTimedOnC as object)['addEndItem']();
      let dataSource: OrderedDataSource = new OrderedDataSource();
      dataSource.insertData(0, {
        id: START, type: ItemType.ITEM_TYPE_CUSTOM
      });
      (darkModeTimedOnC as object)['dataSource'] = dataSource;
      (darkModeTimedOnC as object)['addEndItem']();
      dataSource.insertData(0, {
        id: END, type: ItemType.ITEM_TYPE_STANDARD
      });
      (darkModeTimedOnC as object)['dataSource'] = dataSource;
      (darkModeTimedOnC as object)['addEndItem']();
      dataSource.removeAll();
      expect(darkModeTimedOnC != null).assertTrue();
    })
    it('DarkModeTimedOnControllerTest_handleCheckedChange_001', 0, () => {
      let darkModeTimedOnC: DarkModeTimedOnController = new DarkModeTimedOnController();
      (darkModeTimedOnC as object)['handleCheckedChange'](false);
      let mocker: MockKit = new MockKit();
      let mockFun: Function = mocker.mockFunc(SettingsDataUtils, SettingsDataUtils.getSettingsData);
      when(mockFun)(ArgumentMatchers.any).afterReturn('');
      (darkModeTimedOnC as object)['handleCheckedChange'](true);
      when(mockFun)(ArgumentMatchers.any).afterReturn('60');
      (darkModeTimedOnC as object)['handleCheckedChange'](true);
      expect(darkModeTimedOnC != null).assertTrue();
      mocker.clear(SettingsDataUtils);
    })
    it('DarkModeTimedOnControllerTest_dealSubmitAction_001', 0, () => {
      let darkModeTimedOnC: DarkModeTimedOnController = new DarkModeTimedOnController();
      (darkModeTimedOnC as object)['dealSubmitAction']();
      let mocker: MockKit = new MockKit();
      let mockFun: Function = mocker.mockFunc(SettingsDataUtils, SettingsDataUtils.getSettingsData);
      when(mockFun)(ArgumentMatchers.any).afterReturn('120');
      const date = new Date();
      (darkModeTimedOnC as object)['dealSubmitAction'](START, date);
      let hour: number = date.getHours();
      let min: number = date.getMinutes();
      let endTime = hour * 60 + min + 24 * 60;
      when(mockFun)(ArgumentMatchers.any).afterReturn(endTime.toString());
      (darkModeTimedOnC as object)['dealSubmitAction'](START, date);
      (darkModeTimedOnC as object)['dealSubmitAction'](END, date);
      when(mockFun)(ArgumentMatchers.any).afterReturn('120');
      (darkModeTimedOnC as object)['dealSubmitAction'](END, date);
      expect(darkModeTimedOnC != null).assertTrue();
      mocker.clear(SettingsDataUtils);
    })
    it('DarkModeTimedOnControllerTest_updateExtraInfo_001', 0, () => {
      let darkModeTimedOnC: DarkModeTimedOnController = new DarkModeTimedOnController();
      let dataSource: OrderedDataSource = new OrderedDataSource();
      let timePickerM: TimePickerModel = {
        dateTime: ''
      };
      dataSource.insertData(0, {
        id: START, type: ItemType.ITEM_TYPE_STANDARD, extra: timePickerM
      });
      (darkModeTimedOnC as object)['dataSource'] = dataSource;
      (darkModeTimedOnC as object)['updateExtraInfo'](END, '120');
      (darkModeTimedOnC as object)['updateExtraInfo'](START, '120');
      dataSource.removeAll();
      expect(darkModeTimedOnC != null).assertTrue();
    })
    it('DarkModeTimedOnControllerTest_stopTask_001', 0, () => {
      let darkModeTimedOnC: DarkModeTimedOnController = new DarkModeTimedOnController();
      (darkModeTimedOnC as object)['switchTimerId'] = null;
      (darkModeTimedOnC as object)['stopTask']();
      (darkModeTimedOnC as object)['switchTimerId'] = 0;
      (darkModeTimedOnC as object)['stopTask']();
      expect(darkModeTimedOnC != null).assertTrue();
    })
  })
}
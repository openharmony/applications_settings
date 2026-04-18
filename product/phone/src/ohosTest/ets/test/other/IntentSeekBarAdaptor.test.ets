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

import {
  afterAll,
  afterEach,
  ArgumentMatchers,
  beforeAll,
  beforeEach,
  describe,
  expect,
  it,
  Level,
  MockKit,
  when
} from '@ohos/hypium';
import { SettingItemProperty } from '@ohos/settings.intent';
import { IntentSeekBarAdaptor } from '@ohos/settings.intent/src/main/ets/adapter/IntentSeekBarAdaptor';
import { SeekBarActions } from '@ohos/settings.intent/src/main/ets/constant/IntentType';

export default function intentSeekBarAdaptorTest() {
  describe('intentSeekBarAdaptorTest', (): void => {

    beforeAll((): void => {
    })

    beforeEach((): void => {

    })

    afterAll((): void => {
    })

    afterEach((): void => {
    })

    it('convertRangeValueTest_1', Level.LEVEL0, () => {
      let result = IntentSeekBarAdaptor.convertRangeValue(10, 10, 1);
      expect(result).assertEqual(10);
    });
    it('convertRangeValueTest_2', Level.LEVEL0, () => {
      let result = IntentSeekBarAdaptor.convertRangeValue(10, 1, 10);
      expect(result).assertEqual(1);
    });
    it('convertRangeValueTest_3', Level.LEVEL0, () => {
      let result = IntentSeekBarAdaptor.convertRangeValue(10, 1, 5);
      expect(result).assertEqual(1);
    });
    it('convertRangeValueTest_4', Level.LEVEL0, () => {
      let result = IntentSeekBarAdaptor.convertRangeValue(10, 5, 1);
      expect(result).assertEqual(5);
    });
    it('AdapterIntentCheckAdaptorTest_005', 0, async (done: Function) => {
      try {
        let result = await IntentSeekBarAdaptor.getSettingSeekBar('GetSettingSeekBar')
        expect(result !== null).assertTrue();
      } catch (e) {
      } finally {
        done()
      }
    });
    it('AdapterIntentCheckAdaptorTest_006', 0, async (done: Function) => {
      try {
        let result = await IntentSeekBarAdaptor.setSettingSeekBar('GetSettingSeekBar', 12, 'GetSettingSeekBar')
        expect(result !== null).assertTrue();
      } catch (e) {
      } finally {
        done()
      }
    });
    it('AdapterIntentCheckAdaptorTest_007', 0, async (done: Function) => {
      try {
        let intentSeekBarAdaptor = IntentSeekBarAdaptor;
        await (intentSeekBarAdaptor as object)['setSettingsValue']('GetSettingSeekBar', 12, SeekBarActions.TURN_UP);
        await (intentSeekBarAdaptor as object)['setSettingsValue']('GetSettingSeekBar', 12, 'default');
      } catch (e) {
      } finally {
        done()
      }
    });
    it('AdapterIntentCheckAdaptorTest_007_01', 0, async (done: Function) => {
      try {
        let intentSeekBarAdaptor = IntentSeekBarAdaptor;
        await (intentSeekBarAdaptor as object)['setSettingsValue']('GetSettingSeekBar', 12, SeekBarActions.TURN_DOWN);
      } catch (e) {
      } finally {
        done()
      }
    });
    it('AdapterIntentCheckAdaptorTest_007_02', 0, async (done: Function) => {
      try {
        let intentSeekBarAdaptor = IntentSeekBarAdaptor;
        await (intentSeekBarAdaptor as object)['setSettingsValue']('GetSettingSeekBar', 12, SeekBarActions.MAXIMUM);
      } catch (e) {
      } finally {
        done()
      }
    });
    it('AdapterIntentCheckAdaptorTest_007_03', 0, async (done: Function) => {
      try {
        let intentSeekBarAdaptor = IntentSeekBarAdaptor;
        await (intentSeekBarAdaptor as object)['setSettingsValue']('GetSettingSeekBar', 12, SeekBarActions.MINIMAL);
      } catch (e) {
      } finally {
        done()
      }
    });
    it('AdapterIntentCheckAdaptorTest_007_04', 0, async (done: Function) => {
      try {
        let intentSeekBarAdaptor = IntentSeekBarAdaptor;
        await (intentSeekBarAdaptor as object)['setSettingsValue']('GetSettingSeekBar', 12, '');
      } catch (e) {
      } finally {
        done()
      }
    });

    it('AdapterIntentCheckAdaptorTest_008', 0, (done: Function) => {
      try {
        let intentSeekBarAdaptor = IntentSeekBarAdaptor;
        (intentSeekBarAdaptor as object)['setSettingsValue'](12, 12, 12);
      } catch (e) {
      } finally {
        done()
      }
    });
    it('AdapterIntentCheckAdaptorTest_009', 0, (done: Function) => {
      try {
        let result = IntentSeekBarAdaptor.getValue()
        expect(result !== null).assertTrue();
        let item: SettingItemProperty = {
          itemName: 'test',
          itemType: 'string',
          itemResourceId: ''
        };
        AppStorage.setOrCreate('intentItem', item);
        let result2 = IntentSeekBarAdaptor.getValue()
        expect(result2 !== null).assertTrue();
      } catch (e) {
      } finally {
        done()
      }
    });
    it('AdapterIntentCheckAdaptorTest_010', 0, async (done: Function) => {
      try {
        let result = await IntentSeekBarAdaptor.getAsyncValue()
        expect(result !== null).assertTrue();
        let item: SettingItemProperty = {
          itemName: 'BRIGHTNESS',
          itemType: 'string',
          itemResourceId: '',
        };
        AppStorage.setOrCreate('intentItem', item);
        let result2 = await IntentSeekBarAdaptor.getAsyncValue()
        expect(result2 !== null).assertTrue();
      } catch (e) {
      } finally {
        done()
      }
    });
    it('AdapterIntentCheckAdaptorTest_011', 0, (done: Function) => {
      try {
        let result = IntentSeekBarAdaptor.getSliderMin()
        expect(result !== null).assertTrue();
        let item: SettingItemProperty = {
          itemName: 'BRIGHTNESS',
          itemType: 'string',
          itemResourceId: '',
          itemMinValue: 0
        };
        AppStorage.setOrCreate('intentItem', item);
        let result2 = IntentSeekBarAdaptor.getSliderMin()
        expect(result2 !== null).assertTrue();
      } catch (e) {
      } finally {
        done()
      }
    });
    it('AdapterIntentCheckAdaptorTest_012', 0, (done: Function) => {
      try {
        let result = IntentSeekBarAdaptor.getSliderActualMin()
        expect(result !== null).assertTrue();
      } catch (e) {
      } finally {
        done()
      }
    });
    it('AdapterIntentCheckAdaptorTest_013', 0, (done: Function) => {
      try {
        let result = IntentSeekBarAdaptor.getSliderActualMax()
        expect(result !== null).assertTrue();
      } catch (e) {
      } finally {
        done()
      }
    });
    it('AdapterIntentCheckAdaptorTest_014', 0, (done: Function) => {
      try {
        let result = IntentSeekBarAdaptor.getSliderStep()
        expect(result !== null).assertTrue();
        let item: SettingItemProperty = {
          itemName: 'BRIGHTNESS',
          itemType: 'string',
          itemResourceId: '',
          itemStepValue: 10
        };
        AppStorage.setOrCreate('intentItem', item);
        let result2 = IntentSeekBarAdaptor.getSliderStep()
        expect(result2 !== null).assertTrue();
      } catch (e) {
      } finally {
        done()
      }
    });
    it('AdapterIntentCheckAdaptorTest_015', 0, async (done: Function) => {
      try {
        let intentSeekBarAdaptor = IntentSeekBarAdaptor;
        let mocker: MockKit = new MockKit();
        let mockfunc: Function =
          mocker.mockFunc(intentSeekBarAdaptor, await intentSeekBarAdaptor.getAsyncValue);
        when(mockfunc)(ArgumentMatchers.any).afterReturn(10);
        let mockfunc2: Function =
          mocker.mockFunc(intentSeekBarAdaptor, await intentSeekBarAdaptor.getSliderActualMax);
        when(mockfunc2)(ArgumentMatchers.any).afterReturn(10);
        let mockfunc3: Function =
          mocker.mockFunc(intentSeekBarAdaptor, await intentSeekBarAdaptor.getSliderActualMin);
        when(mockfunc3)(ArgumentMatchers.any).afterReturn(10);
        let result = await IntentSeekBarAdaptor.turnUp('brightness')
        expect(result !== null).assertTrue();
        mocker.clear(intentSeekBarAdaptor);
      } catch (e) {
      } finally {
        done()
      }
    });
    it('AdapterIntentCheckAdaptorTest_015_01', 0, async (done: Function) => {
      try {
        let intentSeekBarAdaptor = IntentSeekBarAdaptor;
        let mocker: MockKit = new MockKit();
        let mockfunc: Function =
          mocker.mockFunc(intentSeekBarAdaptor, await intentSeekBarAdaptor.getAsyncValue);
        when(mockfunc)(ArgumentMatchers.any).afterReturn(10);
        let mockfunc2: Function =
          mocker.mockFunc(intentSeekBarAdaptor, await intentSeekBarAdaptor.getSliderActualMax);
        when(mockfunc2)(ArgumentMatchers.any).afterReturn(20);
        let mockfunc3: Function =
          mocker.mockFunc(intentSeekBarAdaptor, await intentSeekBarAdaptor.getSliderActualMin);
        when(mockfunc3)(ArgumentMatchers.any).afterReturn(10);
        let result = await IntentSeekBarAdaptor.turnUp('brightness')
        expect(result !== null).assertTrue();
        mocker.clear(intentSeekBarAdaptor);
      } catch (e) {
      } finally {
        done()
      }
    });
    it('AdapterIntentCheckAdaptorTest_015_02', 0, async (done: Function) => {
      try {
        let intentSeekBarAdaptor = IntentSeekBarAdaptor;
        let mocker: MockKit = new MockKit();
        let mockfunc: Function =
          mocker.mockFunc(intentSeekBarAdaptor, await intentSeekBarAdaptor.getAsyncValue);
        when(mockfunc)(ArgumentMatchers.any).afterReturn(100);
        let mockfunc2: Function =
          mocker.mockFunc(intentSeekBarAdaptor, await intentSeekBarAdaptor.getSliderActualMax);
        when(mockfunc2)(ArgumentMatchers.any).afterReturn(1);
        let mockfunc3: Function =
          mocker.mockFunc(intentSeekBarAdaptor, await intentSeekBarAdaptor.getSliderActualMin);
        when(mockfunc3)(ArgumentMatchers.any).afterReturn(10);
        let result = await IntentSeekBarAdaptor.turnUp('brightness')
        expect(result !== null).assertTrue();
        mocker.clear(intentSeekBarAdaptor);
      } catch (e) {
      } finally {
        done()
      }
    });
    it('AdapterIntentCheckAdaptorTest_016', 0, (done: Function) => {
      try {
        let intentSeekBarAdaptor = IntentSeekBarAdaptor;
        (intentSeekBarAdaptor as object)['convertInputValue'](120, 10, 10);
        (intentSeekBarAdaptor as object)['convertInputValue'](-1, 10, 10);
        (intentSeekBarAdaptor as object)['convertInputValue'](1, 10, 10);
      } catch (e) {
      } finally {
        done()
      }
    });
    it('AdapterIntentCheckAdaptorTest_017', 0, async (done: Function) => {
      try {
        let intentSeekBarAdaptor = IntentSeekBarAdaptor;
        let mocker: MockKit = new MockKit();
        let mockfunc: Function =
          mocker.mockFunc(intentSeekBarAdaptor, await intentSeekBarAdaptor.getAsyncValue);
        when(mockfunc)(ArgumentMatchers.any).afterReturn(10);
        let mockfunc2: Function =
          mocker.mockFunc(intentSeekBarAdaptor, await intentSeekBarAdaptor.getSliderActualMax);
        when(mockfunc2)(ArgumentMatchers.any).afterReturn(10);
        let mockfunc3: Function =
          mocker.mockFunc(intentSeekBarAdaptor, await intentSeekBarAdaptor.getSliderActualMin);
        when(mockfunc3)(ArgumentMatchers.any).afterReturn(10);
        let result = await IntentSeekBarAdaptor.turnDown('brightness')
        expect(result !== null).assertTrue();
        let result2 = await IntentSeekBarAdaptor.turnDown('brightness1')
        expect(result2 !== null).assertTrue();
        mocker.clear(intentSeekBarAdaptor);
      } catch (e) {
      } finally {
        done()
      }
    });
    it('AdapterIntentCheckAdaptorTest_017_01', 0, async (done: Function) => {
      try {
        let intentSeekBarAdaptor = IntentSeekBarAdaptor;
        let mocker: MockKit = new MockKit();
        let mockfunc: Function =
          mocker.mockFunc(intentSeekBarAdaptor, await intentSeekBarAdaptor.getAsyncValue);
        when(mockfunc)(ArgumentMatchers.any).afterReturn(1);
        let mockfunc2: Function =
          mocker.mockFunc(intentSeekBarAdaptor, await intentSeekBarAdaptor.getSliderActualMax);
        when(mockfunc2)(ArgumentMatchers.any).afterReturn(20);
        let mockfunc3: Function =
          mocker.mockFunc(intentSeekBarAdaptor, await intentSeekBarAdaptor.getSliderActualMin);
        when(mockfunc3)(ArgumentMatchers.any).afterReturn(100);
        let result = await IntentSeekBarAdaptor.turnDown('brightness')
        expect(result !== null).assertTrue();
        mocker.clear(intentSeekBarAdaptor);
      } catch (e) {
      } finally {
        done()
      }
    });
    it('AdapterIntentCheckAdaptorTest_017_02', 0, async (done: Function) => {
      try {
        let intentSeekBarAdaptor = IntentSeekBarAdaptor;
        let mocker: MockKit = new MockKit();
        let mockfunc: Function =
          mocker.mockFunc(intentSeekBarAdaptor, await intentSeekBarAdaptor.getAsyncValue);
        when(mockfunc)(ArgumentMatchers.any).afterReturn(1000);
        let mockfunc2: Function =
          mocker.mockFunc(intentSeekBarAdaptor, await intentSeekBarAdaptor.getSliderActualMax);
        when(mockfunc2)(ArgumentMatchers.any).afterReturn(20);
        let mockfunc3: Function =
          mocker.mockFunc(intentSeekBarAdaptor, await intentSeekBarAdaptor.getSliderActualMin);
        when(mockfunc3)(ArgumentMatchers.any).afterReturn(100);
        let result = await IntentSeekBarAdaptor.turnDown('brightness')
        expect(result !== null).assertTrue();
        mocker.clear(intentSeekBarAdaptor);
      } catch (e) {
      } finally {
        done()
      }
    });
  })
}

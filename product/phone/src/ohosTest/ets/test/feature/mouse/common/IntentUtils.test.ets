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
  beforeAll,
  describe,
  expect,
  it,
  TestType,
} from "@ohos/hypium";
import {
  CardContentUtils,
  isIntentSupport,
  OptionUtils,
  SeekBarUtils,
  SwitchUtils,
} from "@ohos/settings.mouse/src/main/ets/common/IntentUtils";
import { LogUtil } from "@ohos/settings.common/src/main/ets/utils/LogUtil";
import {
  MAX_MOUSE_SCROLL_ROWS,
  MAX_POINTER_SIZE,
  MAX_POINTER_SPEED,
  MIN_MOUSE_SCROLL_ROWS,
  MIN_POINTER_SIZE,
  MIN_POINTER_SPEED,
  MOUSE_SCROLL_ROWS_SCALE,
  POINTER_SIZE_SCALE,
  POINTER_SPEED_SCALE,
} from "@ohos/settings.mouse/src/main/ets/common/Constants";

const TAG = 'IntentUtilsTest';

export default function IntentUtilsTest() {
  describe('IntentUtilsTest', () => {
    beforeAll(() => {
      LogUtil.showInfo(TAG, 'beforeAll');
    });

    afterAll(() => {
      LogUtil.showInfo(TAG, 'afterAll');
    });

    it('IntentUtilsTest_CardContentUtils_001', TestType.FUNCTION, () => {
      LogUtil.showInfo(TAG, 'IntentUtilsTest_CardContentUtils_001 it begin');
      CardContentUtils.getMousePrimaryBtnCardValue();
      expect().assertUndefined();
    });

    it('IntentUtilsTest_CardContentUtils_002', TestType.FUNCTION, () => {
      LogUtil.showInfo(TAG, 'IntentUtilsTest_CardContentUtils_002 it begin');
      CardContentUtils.getPointerStyleCardValue();
      expect().assertUndefined();
    });

    it('IntentUtilsTest_CardContentUtils_003', TestType.FUNCTION, () => {
      LogUtil.showInfo(TAG, 'IntentUtilsTest_CardContentUtils_003 it begin');
      CardContentUtils.getPointerColorCardValue();
      expect().assertUndefined();
    });

    it('IntentUtilsTest_OptionUtils_001', TestType.FUNCTION, async () => {
      LogUtil.showInfo(TAG, 'IntentUtilsTest_OptionUtils_001 it begin');
      OptionUtils.setMousePrimaryButton('LeftButton');
      const btn = await OptionUtils.getMousePrimaryButton();
      expect(btn !== null).assertTrue();
    });

    it('IntentUtilsTest_OptionUtils_002', TestType.FUNCTION, async () => {
      LogUtil.showInfo(TAG, 'IntentUtilsTest_OptionUtils_002 it begin');
      OptionUtils.setMousePrimaryButton('RightButton');
      const btn = await OptionUtils.getMousePrimaryButton();
      expect(btn !== null).assertTrue();
    });

    it('IntentUtilsTest_OptionUtils_003', TestType.FUNCTION, () => {
      LogUtil.showInfo(TAG, 'IntentUtilsTest_OptionUtils_003 it begin');
      OptionUtils.setPointerStyle('Arrow');
      const style = OptionUtils.getPointerStyle();
      expect(style !== null).assertTrue();
    });

    it('IntentUtilsTest_OptionUtils_004', TestType.FUNCTION, () => {
      LogUtil.showInfo(TAG, 'IntentUtilsTest_OptionUtils_004 it begin');
      OptionUtils.setPointerColor('Red');
      const color = OptionUtils.getPointerColor();
      expect(color !== null).assertTrue();
    });

    it('IntentUtilsTest_OptionUtils_005', TestType.FUNCTION, () => {
      LogUtil.showInfo(TAG, 'IntentUtilsTest_OptionUtils_005 it begin');
      OptionUtils.setPointerColor('Yellow');
      const color = OptionUtils.getPointerColor();
      expect(color !== null).assertTrue();
    });

    it('IntentUtilsTest_OptionUtils_006', TestType.FUNCTION, () => {
      LogUtil.showInfo(TAG, 'IntentUtilsTest_OptionUtils_006 it begin');
      OptionUtils.setPointerColor('Green');
      const color = OptionUtils.getPointerColor();
      expect(color !== null).assertTrue();
    });

    it('IntentUtilsTest_OptionUtils_007', TestType.FUNCTION, () => {
      LogUtil.showInfo(TAG, 'IntentUtilsTest_OptionUtils_007 it begin');
      OptionUtils.setPointerColor('Cyan');
      const color = OptionUtils.getPointerColor();
      expect(color !== null).assertTrue();
    });

    it('IntentUtilsTest_OptionUtils_008', TestType.FUNCTION, () => {
      LogUtil.showInfo(TAG, 'IntentUtilsTest_OptionUtils_008 it begin');
      OptionUtils.setPointerColor('Blue');
      const color = OptionUtils.getPointerColor();
      expect(color !== null).assertTrue();
    });

    it('IntentUtilsTest_OptionUtils_009', TestType.FUNCTION, () => {
      LogUtil.showInfo(TAG, 'IntentUtilsTest_OptionUtils_009 it begin');
      OptionUtils.setPointerColor('Purple');
      const color = OptionUtils.getPointerColor();
      expect(color !== null).assertTrue();
    });

    it('IntentUtilsTest_OptionUtils_010', TestType.FUNCTION, () => {
      LogUtil.showInfo(TAG, 'IntentUtilsTest_OptionUtils_010 it begin');
      OptionUtils.setPointerColor('White');
      const color = OptionUtils.getPointerColor();
      expect(color !== null).assertTrue();
    });

    it('IntentUtilsTest_OptionUtils_011', TestType.FUNCTION, () => {
      LogUtil.showInfo(TAG, 'IntentUtilsTest_OptionUtils_011 it begin');
      OptionUtils.setPointerColor('Black');
      const color = OptionUtils.getPointerColor();
      expect(color !== null).assertTrue();
    });

    it('IntentUtilsTest_SwitchUtils_001', TestType.FUNCTION, async () => {
      LogUtil.showInfo(TAG, 'IntentUtilsTest_SwitchUtils_001 it begin');
      SwitchUtils.setHoverScrollStateOn();
      const state = await SwitchUtils.getHoverScrollState();
      expect(state !== null).assertTrue();
    });

    it('IntentUtilsTest_SwitchUtils_002', TestType.FUNCTION, async () => {
      LogUtil.showInfo(TAG, 'IntentUtilsTest_SwitchUtils_002 it begin');
      SwitchUtils.setHoverScrollStateOff();
      const state = await SwitchUtils.getHoverScrollState();
      expect(state !== null).assertTrue();
    });

    it('IntentUtilsTest_SeekBarUtils_001', TestType.FUNCTION, () => {
      LogUtil.showInfo(TAG, 'IntentUtilsTest_SeekBarUtils_001 it begin');
      SeekBarUtils.setPointerSpeed(1);
      const speed = SeekBarUtils.getPointerSpeed();
      expect(speed !== null).assertTrue();
    });

    it('IntentUtilsTest_SeekBarUtils_002', TestType.FUNCTION, () => {
      LogUtil.showInfo(TAG, 'IntentUtilsTest_SeekBarUtils_002 it begin');
      SeekBarUtils.setPointerSpeed(20);
      const speed = SeekBarUtils.getPointerSpeed();
      expect(speed !== null).assertTrue();
    });

    it('IntentUtilsTest_SeekBarUtils_003', TestType.FUNCTION, () => {
      LogUtil.showInfo(TAG, 'IntentUtilsTest_SeekBarUtils_003 it begin');
      const max = SeekBarUtils.getMaxPointerSpeed();
      expect(max !== null).assertTrue();
    });

    it('IntentUtilsTest_SeekBarUtils_004', TestType.FUNCTION, () => {
      LogUtil.showInfo(TAG, 'IntentUtilsTest_SeekBarUtils_004 it begin');
      const min = SeekBarUtils.getMinPointerSpeed();
      expect(min !== null).assertTrue();
    });

    it('IntentUtilsTest_SeekBarUtils_005', TestType.FUNCTION, () => {
      LogUtil.showInfo(TAG, 'IntentUtilsTest_SeekBarUtils_005 it begin');
      const scale = SeekBarUtils.getPointerSpeedScale();
      expect(scale !== null).assertTrue();
    });

    it('IntentUtilsTest_SeekBarUtils_006', TestType.FUNCTION, async () => {
      LogUtil.showInfo(TAG, 'IntentUtilsTest_SeekBarUtils_006 it begin');
      SeekBarUtils.setMouseScrollRows(1);
      const rows = await SeekBarUtils.getMouseScrollRows();
      expect(rows !== null).assertTrue();
    });

    it('IntentUtilsTest_SeekBarUtils_007', TestType.FUNCTION, async () => {
      LogUtil.showInfo(TAG, 'IntentUtilsTest_SeekBarUtils_007 it begin');
      SeekBarUtils.setMouseScrollRows(100);
      const rows = await SeekBarUtils.getMouseScrollRows();
      expect(rows !== null).assertTrue();
    });

    it('IntentUtilsTest_SeekBarUtils_008', TestType.FUNCTION, () => {
      LogUtil.showInfo(TAG, 'IntentUtilsTest_SeekBarUtils_008 it begin');
      const max = SeekBarUtils.getMaxMouseScrollRows();
      expect(max !== null).assertTrue();
    });

    it('IntentUtilsTest_SeekBarUtils_009', TestType.FUNCTION, () => {
      LogUtil.showInfo(TAG, 'IntentUtilsTest_SeekBarUtils_009 it begin');
      const min = SeekBarUtils.getMinMouseScrollRows();
      expect(min !== null).assertTrue();
    });

    it('IntentUtilsTest_SeekBarUtils_010', TestType.FUNCTION, () => {
      LogUtil.showInfo(TAG, 'IntentUtilsTest_SeekBarUtils_010 it begin');
      const scale = SeekBarUtils.getMouseScrollRowsScale();
      expect(scale !== null).assertTrue();
    });

    it('IntentUtilsTest_SeekBarUtils_011', TestType.FUNCTION, () => {
      LogUtil.showInfo(TAG, 'IntentUtilsTest_SeekBarUtils_011 it begin');
      SeekBarUtils.setPointerSize(1);
      const size = SeekBarUtils.getPointerSize();
      expect(size !== null).assertTrue();
    });

    it('IntentUtilsTest_SeekBarUtils_012', TestType.FUNCTION, () => {
      LogUtil.showInfo(TAG, 'IntentUtilsTest_SeekBarUtils_012 it begin');
      SeekBarUtils.setPointerSize(7);
      const size = SeekBarUtils.getPointerSize();
      expect(size !== null).assertTrue();
    });

    it('IntentUtilsTest_SeekBarUtils_013', TestType.FUNCTION, () => {
      LogUtil.showInfo(TAG, 'IntentUtilsTest_SeekBarUtils_013 it begin');
      const max = SeekBarUtils.getMaxPointerSize();
      expect(max !== null).assertTrue();
    });

    it('IntentUtilsTest_SeekBarUtils_014', TestType.FUNCTION, () => {
      LogUtil.showInfo(TAG, 'IntentUtilsTest_SeekBarUtils_014 it begin');
      const min = SeekBarUtils.getMinPointerSize();
      expect(min !== null).assertTrue();
    });

    it('IntentUtilsTest_SeekBarUtils_015', TestType.FUNCTION, () => {
      LogUtil.showInfo(TAG, 'IntentUtilsTest_SeekBarUtils_015 it begin');
      const scale = SeekBarUtils.getPointerSizeScale();
      expect(scale !== null).assertTrue();
    });

    it('IntentUtilsTest_001', TestType.FUNCTION, () => {
      LogUtil.showInfo(TAG, 'IntentUtilsTest_001 it begin');
      const isSupport = isIntentSupport();
      expect(isSupport !== null).assertTrue();
    });
  });
}
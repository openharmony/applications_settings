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
import { pointer } from "@kit.InputKit";
import {
  getHoverScrollState,
  getMousePrimaryButton,
  getMouseScrollRows,
  getPointerColor,
  getPointerSize,
  getPointerSpeed,
  getPointerStyle,
  setHoverScrollState,
  setMousePrimaryButton,
  setMouseScrollRows,
  setPointerColor,
  setPointerSize,
  setPointerSpeed,
  setPointerStyle,
} from "@ohos/settings.mouse/src/main/ets/common/PointerUtils";
import { LogUtil } from "@ohos/settings.common/src/main/ets/utils/LogUtil";
import { PointerColor } from "@ohos/settings.mouse/src/main/ets/model/Models";

const TAG = 'PointerUtilsTest';

export default function PointerUtilsTest() {
  describe('PointerUtilsTest', () => {
    beforeAll(() => {
      LogUtil.showInfo(TAG, 'beforeAll');
    });

    afterAll(() => {
      LogUtil.showInfo(TAG, 'afterAll');
    });

    it('PointerUtilsTest_PrimaryButton_001', TestType.FUNCTION, async () => {
      LogUtil.showInfo(TAG, 'PointerUtilsTest_PrimaryButton_001 it begin');
      setMousePrimaryButton(pointer.PrimaryButton.LEFT);
      const button = await getMousePrimaryButton();
      expect(button !== null).assertTrue();
    });

    it('PointerUtilsTest_PrimaryButton_002', TestType.FUNCTION, async () => {
      LogUtil.showInfo(TAG, 'PointerUtilsTest_PrimaryButton_002 it begin');
      setMousePrimaryButton(pointer.PrimaryButton.RIGHT);
      const button = await getMousePrimaryButton();
      expect(button !== null).assertTrue();
    });

    it('PointerUtilsTest_HoverScrollState_001', TestType.FUNCTION, async () => {
      LogUtil.showInfo(TAG, 'PointerUtilsTest_HoverScrollState_001 it begin');
      setHoverScrollState(true);
      const state = await getHoverScrollState();
      expect(state !== null).assertTrue();
    });

    it('PointerUtilsTest_HoverScrollState_002', TestType.FUNCTION, async () => {
      LogUtil.showInfo(TAG, 'PointerUtilsTest_HoverScrollState_002 it begin');
      setHoverScrollState(false);
      const state = await getHoverScrollState();
      expect(state !== null).assertTrue();
    });

    it('PointerUtilsTest_PointerSpeed_001', TestType.FUNCTION, () => {
      LogUtil.showInfo(TAG, 'PointerUtilsTest_PointerSpeed_001 it begin');
      setPointerSpeed(1);
      const speed = getPointerSpeed();
      expect(speed !== null).assertTrue();
    });

    it('PointerUtilsTest_PointerSpeed_002', TestType.FUNCTION, () => {
      LogUtil.showInfo(TAG, 'PointerUtilsTest_PointerSpeed_002 it begin');
      setPointerSpeed(20);
      const speed = getPointerSpeed();
      expect(speed !== null).assertTrue();
    });

    it('PointerUtilsTest_MouseScrollRows_001', TestType.FUNCTION, async () => {
      LogUtil.showInfo(TAG, 'PointerUtilsTest_MouseScrollRows_001 it begin');
      setMouseScrollRows(1);
      const rows = await getMouseScrollRows();
      expect(rows !== null).assertTrue();
    });

    it('PointerUtilsTest_MouseScrollRows_002', TestType.FUNCTION, async () => {
      LogUtil.showInfo(TAG, 'PointerUtilsTest_MouseScrollRows_002 it begin');
      setMouseScrollRows(100);
      const rows = await getMouseScrollRows();
      expect(rows !== null).assertTrue();
    });

    it('PointerUtilsTest_PointerColor_001', TestType.FUNCTION, () => {
      LogUtil.showInfo(TAG, 'PointerUtilsTest_PointerColor_001 it begin');
      setPointerColor(PointerColor.RED);
      const color = getPointerColor();
      expect(color !== null).assertTrue();
    });

    it('PointerUtilsTest_PointerColor_002', TestType.FUNCTION, () => {
      LogUtil.showInfo(TAG, 'PointerUtilsTest_PointerColor_002 it begin');
      setPointerColor(PointerColor.YELLOW);
      const color = getPointerColor();
      expect(color !== null).assertTrue();
    });

    it('PointerUtilsTest_PointerColor_003', TestType.FUNCTION, () => {
      LogUtil.showInfo(TAG, 'PointerUtilsTest_PointerColor_003 it begin');
      setPointerColor(PointerColor.GREEN);
      const color = getPointerColor();
      expect(color !== null).assertTrue();
    });

    it('PointerUtilsTest_PointerColor_004', TestType.FUNCTION, () => {
      LogUtil.showInfo(TAG, 'PointerUtilsTest_PointerColor_004 it begin');
      setPointerColor(PointerColor.CYAN);
      const color = getPointerColor();
      expect(color !== null).assertTrue();
    });

    it('PointerUtilsTest_PointerColor_005', TestType.FUNCTION, () => {
      LogUtil.showInfo(TAG, 'PointerUtilsTest_PointerColor_005 it begin');
      setPointerColor(PointerColor.BLUE);
      const color = getPointerColor();
      expect(color !== null).assertTrue();
    });

    it('PointerUtilsTest_PointerColor_006', TestType.FUNCTION, () => {
      LogUtil.showInfo(TAG, 'PointerUtilsTest_PointerColor_006 it begin');
      setPointerColor(PointerColor.PURPLE);
      const color = getPointerColor();
      expect(color !== null).assertTrue();
    });

    it('PointerUtilsTest_PointerColor_007', TestType.FUNCTION, () => {
      LogUtil.showInfo(TAG, 'PointerUtilsTest_PointerColor_007 it begin');
      setPointerColor(PointerColor.WHITE);
      const color = getPointerColor();
      expect(color !== null).assertTrue();
    });

    it('PointerUtilsTest_PointerColor_008', TestType.FUNCTION, () => {
      LogUtil.showInfo(TAG, 'PointerUtilsTest_PointerColor_008 it begin');
      setPointerColor(PointerColor.BLACK);
      const color = getPointerColor();
      expect(color !== null).assertTrue();
    });

    it('PointerUtilsTest_PointerSize_001', TestType.FUNCTION, () => {
      LogUtil.showInfo(TAG, 'PointerUtilsTest_PointerSize_001 it begin');
      setPointerSize(1);
      const size = getPointerSize();
      expect(size !== null).assertTrue();
    });

    it('PointerUtilsTest_PointerSize_002', TestType.FUNCTION, () => {
      LogUtil.showInfo(TAG, 'PointerUtilsTest_PointerSize_002 it begin');
      setPointerSize(7);
      const size = getPointerSize();
      expect(size !== null).assertTrue();
    });

    it('PointerUtilsTest_PointerStyle_001', TestType.FUNCTION, () => {
      LogUtil.showInfo(TAG, 'PointerUtilsTest_PointerStyle_001 it begin');
      setPointerStyle(pointer.PointerStyle.DEFAULT);
      const style = getPointerStyle();
      expect(style !== null).assertTrue();
    });
  });
}
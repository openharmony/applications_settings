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
import { display } from '@kit.ArkUI';
import { BusinessError } from '@kit.BasicServicesKit';
import { Driver, ON } from '@ohos.UiTest';
import { beforeEach, describe, expect, it } from '@ohos/hypium';
import { LogUtil } from '@ohos/settings.common/src/main/ets/utils/LogUtil';

// 不被识别为左右Back手势的安全距离
const BACK_SAFE_DISTANCE: number = 100;

// 顺时针旋转180、270
const ROTATION_ONE: number = 1;
const ROTATION_THREE: number = 3;

// 滑动速度-快速
const SWIPE_SPEED_FAST: number = 10000;

const DELAY_BETWEEN_TESTS = 3500;

const COMMON_DELAY = 1000;
const TAG: string = 'SoundModeWindowPageTest: '

export default function SoundModeWindowPageTest() {
  describe('SoundModeWindowPageTest01', () => {
    const driver = Driver.create();
    beforeEach(async () => {
      await driver.delayMs(DELAY_BETWEEN_TESTS);
      await controlCenterLongPress(driver);
      await driver.delayMs(DELAY_BETWEEN_TESTS);
    });

    it('SoundModeWindowPageTest_001', 0, async () => {
      try {
        const btnText = await driver.findComponent(ON.id('MoreSettingButton'));
        await btnText?.click();
        await driver.delayMs(COMMON_DELAY);
        await driver.pressBack();
      } catch (e) {
        expect().assertFail();
      }
    });
  });
}

export const controlCenterLongPress = async (driver: Driver) => {
  try {
    let deviceWidth = display.getDefaultDisplaySync().width;
    let deviceHeight = display.getDefaultDisplaySync().height;
    let deviceRotation = display.getDefaultDisplaySync().rotation;
    const X = deviceWidth - BACK_SAFE_DISTANCE;
    if (deviceRotation === ROTATION_ONE || deviceRotation === ROTATION_THREE) {
      LogUtil.info(TAG + `device in landscape status`);
      await driver.swipe(X, 0, X, deviceHeight, SWIPE_SPEED_FAST);
      await driver.delayMs(COMMON_DELAY);
    }
    await driver.swipe(X, 0, X, deviceHeight, SWIPE_SPEED_FAST);
    const btnImage = await driver.findComponent(ON.id('Ctrl.NewToggleBaseComponent_Image_ring_mode'));
    await btnImage.longClick();
  } catch (err) {
    LogUtil.error(TAG + 'setDeviceRate getDefaultDisplaySync, err: ' + (err as BusinessError).message);
  }
}
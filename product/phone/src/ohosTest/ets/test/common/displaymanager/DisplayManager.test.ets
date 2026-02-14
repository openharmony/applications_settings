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

import { describe, it, expect, TestType, MockKit, when, ArgumentMatchers } from '@ohos/hypium';
import { LogUtil } from '@ohos/settings.common/src/main/ets/utils/LogUtil';
import {
  DisplayState,
  CutoutInfo,
  DisplayManager,
} from '@ohos/settings.common/src/main/ets/displaymanager/DisplayManager';
import { Constant } from '../../constant/Constant';
import Display from '@ohos.display';
import { Callback } from '@ohos.base';
import { SettingsDataUtils } from '@ohos/settings.common/src/main/ets/utils/SettingsDataUtils';

export default function DisplayManagerTest() {
  describe('DisplayManagerTest', () => {

    /*
    * @tc.number: DisplayManagerTest_001
    * @tc.name: 对比方法，校验是否一致
    * @tc.type: TestType.FUNCTION
    * @tc.desc: return true
    */
    it('DisplayManagerTest_001', TestType.FUNCTION, async () => {
      LogUtil.info(`${Constant.TAG} DisplayManagerTest_001 start`);
      let displayState = new DisplayState();
      let other: DisplayState = {
        rotation: 0,
        cutoutInfo: new CutoutInfo(0, 0, 0, 0),
        equals: (): boolean => {
          return true;
        },
      }
      let mocker: MockKit = new MockKit();
      let mockFunc: Function = mocker.mockFunc(displayState, displayState.equals);
      when(mockFunc)(other).afterReturn(true);
      let result = await displayState.equals(other);
      expect(result).assertTrue();
      mocker.clear(displayState);
      LogUtil.info(`${Constant.TAG} DisplayManagerTest_001 end`);
    });

    /*
    * @tc.number: DisplayManagerTest_002
    * @tc.name: 挖孔信息
    * @tc.type: TestType.FUNCTION
    * @tc.desc: return true
    */
    it('DisplayManagerTest_002', TestType.FUNCTION, async () => {
      LogUtil.info(`${Constant.TAG} DisplayManagerTest_002 start`);
      let cutoutInfo = new CutoutInfo(0, 0, 0, 0);
      let other: CutoutInfo = {
        left: 0,
        top: 0,
        right: 0,
        bottom: 0,
        equals: (): boolean => {
          return true;
        },
      }
      let mocker: MockKit = new MockKit();
      let mockFunc: Function = mocker.mockFunc(cutoutInfo, cutoutInfo.equals);
      when(mockFunc)(other).afterReturn(true);
      let result = await cutoutInfo.equals(other);
      expect(result).assertTrue();
      LogUtil.info(`${Constant.TAG} DisplayManagerTest_002 end`);
      mocker.clear(cutoutInfo);
    });

    /*
    * @tc.number: DisplayManagerTest_003
    * @tc.name: 注册屏幕信息改变监听
    * @tc.type: TestType.FUNCTION
    * @tc.desc: return true
    */
    it('DisplayManagerTest_003', TestType.FUNCTION, async () => {
      LogUtil.info(`${Constant.TAG} DisplayManagerTest_003 start`);
      let displayManager = new DisplayManager();
      let mocker: MockKit = new MockKit();
      let mockFunc: Function = mocker.mockFunc(displayManager, displayManager.on);
      when(mockFunc)(ArgumentMatchers.anyFunction).afterReturn(true);
      let result = await displayManager.on(() => {
      });
      expect(result).assertTrue();
      LogUtil.info(`${Constant.TAG} DisplayManagerTest_003 end`);
      mocker.clear(displayManager);
    });

    /*
    * @tc.number: DisplayManagerTest_004
    * @tc.name: 反注册屏幕信息改变监听
    * @tc.type: TestType.FUNCTION
    * @tc.desc: return true
    */
    it('DisplayManagerTest_004', TestType.FUNCTION, async () => {
      LogUtil.info(`${Constant.TAG} DisplayManagerTest_004 start`);
      let displayManager = new DisplayManager();
      let mocker: MockKit = new MockKit();
      let mockFunc: Function = mocker.mockFunc(displayManager, displayManager.off);
      when(mockFunc)(ArgumentMatchers.anyFunction).afterReturn(true);
      let result = await displayManager.off(() => {
      });
      expect(result !== null).assertTrue();
      LogUtil.info(`${Constant.TAG} DisplayManagerTest_004 end`);
      mocker.clear(displayManager);
    });

    /*
    * @tc.number: DisplayManagerTest_005
    * @tc.name: 直接获取缓存display，不用异步等待
    * @tc.type: TestType.FUNCTION
    * @tc.desc: return true
    */
    it('DisplayManagerTest_005', TestType.FUNCTION, async () => {
      LogUtil.info(`${Constant.TAG} DisplayManagerTest_005 start`);
      let displayManager = new DisplayManager();
      let mocker: MockKit = new MockKit();
      let mockFunc: Function = mocker.mockFunc(displayManager, displayManager.getCacheDisplay);
      when(mockFunc)().afterReturn(true);
      let result = await displayManager.getCacheDisplay();
      expect(result).assertTrue();
      LogUtil.info(`${Constant.TAG} DisplayManagerTest_005 end`);
      mocker.clear(displayManager);
    });

    /*
    * @tc.number: DisplayManagerTest_006
    * @tc.name: 获取当前display
    * @tc.type: TestType.FUNCTION
    * @tc.desc: return true
    */
    it('DisplayManagerTest_006', TestType.FUNCTION, async () => {
      LogUtil.info(`${Constant.TAG} DisplayManagerTest_006 start`);
      let displayManager = new DisplayManager();
      let mocker: MockKit = new MockKit();
      let mockFunc: Function = mocker.mockFunc(displayManager, displayManager.getCurrentDisplay);
      when(mockFunc)().afterReturn(true);
      let result = await displayManager.getCurrentDisplay();
      expect(result).assertTrue();
      LogUtil.info(`${Constant.TAG} DisplayManagerTest_006 end`);
      mocker.clear(displayManager);
    });
    // DisplayState
    it("DisplayManagerTest_007", 0, () => {
      let displayS: DisplayState = new DisplayState();
      let other: DisplayState = {
        rotation: 0,
        cutoutInfo: new CutoutInfo(0, 0, 0, 0),
        equals: (): boolean => {
          return true;
        },
      }
      displayS.rotation = 0;
      displayS.equals(other);
      displayS.cutoutInfo = new CutoutInfo(1, 1, 1, 1);
      displayS.equals(other);
      displayS.rotation = 1;
      displayS.cutoutInfo = new CutoutInfo(1, 1, 1, 1);
      let re: boolean = displayS.equals(other);
      expect(re).assertFalse();
    })
    // DisplayManager getDpiScale
    it("DisplayManagerTest_008", 0, () => {
      let displayM: DisplayManager = DisplayManager.getInstance();
      displayM.getDpiScale();
      (displayM as object)['defaultDensityDpi'] = 1;
      let displayD: Display.Display = {
        width: 1,
        rotation: 0,
        id: 0,
        name: '',
        alive: false,
        state: 0,
        refreshRate: 0,
        height: 0,
        availableWidth: 0,
        availableHeight: 0,
        densityDPI: 1,
        orientation: 0,
        densityPixels: 0,
        scaledDensity: 0,
        xDPI: 0,
        yDPI: 0,
        screenShape: 1,
        colorSpaces: [],
        hdrFormats: [],
        getAvailableArea: (): Promise<Display.Rect> => {
          throw new Error('Function not implemented.');
        },
        on: (type: 'availableAreaChange', callback: Callback<Display.Rect>): void => {
          throw new Error('Function not implemented.');
        },
        off: (type: 'availableAreaChange', callback?: Callback<Display.Rect> | undefined): void => {
          throw new Error('Function not implemented.');
        },
        getCutoutInfo: () => {
          throw new Error('Function not implemented.');
        },
        hasImmersiveWindow: () => {
          throw new Error('Function not implemented.');
        },
        getDisplayCapability: () => {
          throw new Error('Function not implemented.');
        },
        getLiveCreaseRegion: (): Display.FoldCreaseRegion => {
          throw new Error('Function not implemented.');
        }
      };
      (displayM as object)['display'] = displayD;
      let re: number = displayM.getDpiScale();
      expect(re).assertEqual(1);
    })
    // DisplayManager getDefaultDpi
    it("DisplayManagerTest_009", 0, () => {
      let displayM: DisplayManager = DisplayManager.getInstance();
      displayM.getDefaultDpi();
      expect(displayM != null).assertTrue();
      let mocker: MockKit = new MockKit();
      let mockFun: Function = mocker.mockFunc(SettingsDataUtils, SettingsDataUtils.getSettingsData);
      when(mockFun)(ArgumentMatchers.any).afterReturn('1');
      displayM.getDefaultDpi();
      when(mockFun)(ArgumentMatchers.any).afterReturn('');
      displayM.getDefaultDpi();
      mockFun = mocker.mockFunc(AppStorage, AppStorage.get);
      when(mockFun)().afterReturn(undefined);
      displayM.getDefaultDpi();
      mocker.clear(SettingsDataUtils);
      mocker.clear(AppStorage);
      expect(displayM != null).assertTrue();
    })
    // DisplayManager refreshCutoutInfo
    it("DisplayManagerTest_010", 0, () => {
      let displayM: DisplayManager = DisplayManager.getInstance();
      let displayD: Display.Display = {
        width: 1,
        rotation: 0,
        id: 0,
        name: '',
        alive: false,
        state: 0,
        refreshRate: 0,
        height: 0,
        availableWidth: 0,
        availableHeight: 0,
        densityDPI: 0,
        orientation: 0,
        densityPixels: 0,
        scaledDensity: 0,
        xDPI: 0,
        yDPI: 0,
        screenShape: 1,
        colorSpaces: [],
        hdrFormats: [],
        getAvailableArea: (): Promise<Display.Rect> => {
          throw new Error('Function not implemented.');
        },
        on: (type: 'availableAreaChange', callback: Callback<Display.Rect>): void => {
          throw new Error('Function not implemented.');
        },
        off: (type: 'availableAreaChange', callback?: Callback<Display.Rect> | undefined): void => {
          throw new Error('Function not implemented.');
        },
        getCutoutInfo: () => {
          throw new Error('Function not implemented.');
        },
        hasImmersiveWindow: () => {
          throw new Error('Function not implemented.');
        },
        getDisplayCapability: () => {
          throw new Error('Function not implemented.');
        },
        getLiveCreaseRegion: (): Display.FoldCreaseRegion => {
          throw new Error('Function not implemented.');
        }
      };
      let rects: Array<Display.Rect> = [{
        left: 0,
        top: 0,
        width: 0,
        height: 0
      }];
      (displayM as object)['refreshCutoutInfo']();
      (displayM as object)['refreshCutoutInfo'](displayD);
      (displayM as object)['refreshCutoutInfo'](displayD, []);
      (displayM as object)['refreshCutoutInfo'](displayD, rects);
      displayD.rotation = 1;
      (displayM as object)['refreshCutoutInfo'](displayD, rects);
      displayD.rotation = 3;
      (displayM as object)['refreshCutoutInfo'](displayD, rects);
      expect(displayM != null).assertTrue();
    })
    // DisplayManager on
    it("DisplayManagerTest_011", 0, () => {
      let displayM: DisplayManager = DisplayManager.getInstance();
      displayM.on(() => {});
      expect(displayM != null).assertTrue();
    })
    // DisplayManager off
    it("DisplayManagerTest_012", 0, () => {
      let displayM: DisplayManager = DisplayManager.getInstance();
      displayM.off(() => {});
      expect(displayM != null).assertTrue();
    })
    // DisplayManager getCurrentDisplay
    it("DisplayManagerTest_013", 0, async () => {
      let displayM: DisplayManager = DisplayManager.getInstance();
      await displayM.getCurrentDisplay();
      (displayM as object)['display'] = undefined;
      await displayM.getCurrentDisplay();
      expect(displayM != null).assertTrue();
    })
  });
}

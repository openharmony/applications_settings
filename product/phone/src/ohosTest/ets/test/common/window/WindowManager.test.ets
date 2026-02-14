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

import { describe, it, expect, TestType, MockKit, when } from '@ohos/hypium';
import { LogUtil } from '@ohos/settings.common/src/main/ets/utils/LogUtil';
import { AvoidAreaDirect, WindowInfo, WindowManager } from '@ohos/settings.common/src/main/ets/window/WindowManager';
import { Constant } from '../../constant/Constant';
import { common, ConfigurationConstant, Context } from '@kit.AbilityKit';
import { window } from '@kit.ArkUI';
import { AsyncCallback, Callback } from '@ohos.base';
import image from '@ohos.multimedia.image';
import rpc from '@ohos.rpc';

const NAME: string = 'test';

export default function WindowManagerTest() {
  describe('WindowManagerTest', () => {

    /*
    * @tc.number: WindowManagerTest_001
    * @tc.name: show window
    * @tc.type: TestType.FUNCTION
    * @tc.desc: show window error.
    */
    it('WindowManagerTest_001', TestType.FUNCTION, async () => {
      LogUtil.info(`${Constant.TAG} WindowManagerTest_001 start`);
      let windowManager = new WindowManager();
      let mocker: MockKit = new MockKit();
      let mockFuncShowWindow: Function = mocker.mockFunc(windowManager, windowManager.showWindow);
      when(mockFuncShowWindow)(NAME).afterThrow('show window error.');
      try {
        windowManager.showWindow(NAME);
        mocker.clear(windowManager);
      } catch (e) {
        expect(e).assertEqual('show window error.');
      }
      LogUtil.info(`${Constant.TAG} WindowManagerTest_001 end`);
    });

    /*
    * @tc.number: WindowManagerTest_002
    * @tc.name: hide window
    * @tc.type: TestType.FUNCTION
    * @tc.desc: hide window error.
    */
    it('WindowManagerTest_002', TestType.FUNCTION, async () => {
      LogUtil.info(`${Constant.TAG} WindowManagerTest_002 start`);
      let windowManager = new WindowManager();
      let mocker: MockKit = new MockKit();
      let mockFuncHideWindow: Function = mocker.mockFunc(windowManager, windowManager.hideWindow);
      when(mockFuncHideWindow)(NAME).afterThrow('hide window error.');
      try {
        windowManager.hideWindow(NAME);
        mocker.clear(windowManager);
      } catch (e) {
        expect(e).assertEqual('hide window error.');
      }
      LogUtil.info(`${Constant.TAG} WindowManagerTest_002 end`);
    });

    /*
    * @tc.number: WindowManagerTest_003
    * @tc.name: destroy window
    * @tc.type: TestType.FUNCTION
    * @tc.desc: destroy window error.
    */
    it('WindowManagerTest_003', TestType.FUNCTION, async () => {
      LogUtil.info(`${Constant.TAG} WindowManagerTest_003 start`);
      let windowManager = new WindowManager();
      let mocker: MockKit = new MockKit();
      let mockFuncDestroyWindow: Function = mocker.mockFunc(windowManager, windowManager.destroyWindow);
      when(mockFuncDestroyWindow)(NAME).afterThrow('destroy window error.');
      try {
        windowManager.destroyWindow(NAME);
        mocker.clear(windowManager);
      } catch (e) {
        expect(e).assertEqual('destroy window error.');
      }
      LogUtil.info(`${Constant.TAG} WindowManagerTest_003 end`);
    });

    /*
    * @tc.number: WindowManagerTest_004
    * @tc.name: find window
    * @tc.type: TestType.FUNCTION
    * @tc.desc: window is not found.
    */
    it('WindowManagerTest_004', TestType.FUNCTION, async () => {
      LogUtil.info(`${Constant.TAG} WindowManagerTest_004 start`);
      let windowManager = new WindowManager();
      let mocker: MockKit = new MockKit();
      let mockFuncFindWindow: Function = mocker.mockFunc(windowManager, windowManager.findWindow);
      when(mockFuncFindWindow)(NAME).afterThrow('window is not found.');
      try {
        windowManager.findWindow(NAME);
        mocker.clear(windowManager);
      } catch (e) {
        expect(e).assertEqual('window is not found.');
      }
      LogUtil.info(`${Constant.TAG} WindowManagerTest_004 end`);
    });

    /*
    * @tc.number: WindowManagerTest_005
    * @tc.name: 关闭固定态输入法窗口软键盘高度变化的监听
    * @tc.type: TestType.FUNCTION
    * @tc.desc: Failed to disable the listener for keyboard height changes.
    */
    it('WindowManagerTest_005', TestType.FUNCTION, async () => {
      LogUtil.info(`${Constant.TAG} WindowManagerTest_005 start`);
      let windowManager = new WindowManager();
      let mocker: MockKit = new MockKit();
      let mockFuncOffKeyboardHeightChange: Function =
        mocker.mockFunc(windowManager, windowManager.offKeyboardHeightChange);
      when(mockFuncOffKeyboardHeightChange)().afterThrow('Failed to disable the listener for keyboard height changes.');
      try {
        windowManager.offKeyboardHeightChange();
        mocker.clear(windowManager);
      } catch (e) {
        expect(e).assertEqual('Failed to disable the listener for keyboard height changes.');
      }
      LogUtil.info(`${Constant.TAG} WindowManagerTest_005 end`);
    });

    /*
    * @tc.number: WindowManagerTest_006
    * @tc.name: 为当前窗口添加或删除安全水印标志
    * @tc.type: TestType.FUNCTION
    * @tc.desc: Failed to set water mark flag of window.
    */
    it('WindowManagerTest_006', TestType.FUNCTION, async () => {
      LogUtil.info(`${Constant.TAG} WindowManagerTest_006 start`);
      let windowManager = new WindowManager();
      let mocker: MockKit = new MockKit();
      let mockFuncSetWaterMarkFlag: Function = mocker.mockFunc(windowManager, windowManager.setWaterMarkFlag);
      when(mockFuncSetWaterMarkFlag)(false).afterThrow('Failed to set water mark flag of window.');
      try {
        windowManager.setWaterMarkFlag(false);
        mocker.clear(windowManager);
      } catch (e) {
        expect(e).assertEqual('Failed to set water mark flag of window.');
      }
      LogUtil.info(`${Constant.TAG} WindowManagerTest_006 end`);
    });
    it('WindowManagerTest_getInstance', 0, () => {
      let windowManager = WindowManager;
      windowManager.getInstance()
    });

    it('WindowManagerTest_createWindow', 0, async () => {
      let windowManager = new WindowManager();
      try {
        let windowInfo: WindowInfo = {
          name: '',
          width: 100,
          height: 100,
          windowType: 10,
          loadContent: '',
        }
        let context: Context = AppStorage.get<Context>('pageContext') as common.UIAbilityContext;
        await windowManager.createWindow(context, windowInfo);
        let windowInfo2: WindowInfo = AppStorage.get<WindowInfo>('WindowInfo') as WindowInfo;
        await windowManager.createWindow(context, windowInfo2)
      } catch (e) {
      }
    });
    it('WindowManagerTest_createWindow2', 0, async () => {
      let windowManager = new WindowManager();
      try {
        let context2: Context = AppStorage.get<Context>('pageContext') as common.UIAbilityContext;
        await windowManager.createWindow(context2, {} as WindowInfo)
      } catch (e) {
      }
    });
    it('WindowManagerTest_createWindowIfAbsent', 0, () => {
      let windowManager = new WindowManager();
      try {
        let windowInfo: WindowInfo = {
          name: 'wifi_window',
          width: vp2px(604),
          height: vp2px(505),
          windowType: window.WindowType.TYPE_FLOAT,
          loadContent: 'pages/wifi/WifiDialogSettings',
        }
        let context: Context = AppStorage.get<Context>('pageContext') as common.UIAbilityContext;
        windowManager.createWindowIfAbsent(context, windowInfo, true);

        let windowInfo2: WindowInfo = AppStorage.get<WindowInfo>('WindowInfo') as WindowInfo;
        windowManager.createWindowIfAbsent(context, windowInfo2, true);
      } catch (e) {
      }
    });
    it('WindowManagerTest_createWindowIfAbsent2', 0, () => {
      let windowManager = new WindowManager();
      try {
        let context2: Context = AppStorage.get<Context>('pageContext') as common.UIAbilityContext;
        let windowInfo2: WindowInfo = {} as WindowInfo;
        windowManager.createWindowIfAbsent(context2, windowInfo2)
      } catch (e) {
      }
    });

    it('WindowManagerTest_showWindow', 0, async () => {
      let windowManager = new WindowManager();
      try {
        await windowManager.showWindow(NAME)
      } catch (e) {
      }
    });
    it('WindowManagerTest_hideWindow', 0, async () => {
      let windowManager = new WindowManager();
      try {
        await windowManager.hideWindow(NAME)
      } catch (e) {
      }
    });
    it('WindowManagerTest_destroyWindow', 0, async () => {
      let windowManager = new WindowManager();
      try {
        await windowManager.destroyWindow(NAME)
      } catch (e) {
      }
    });
    it('WindowManagerTest_updateBreakPointByWindWidth', 0, async () => {
      let windowManager = new WindowManager();
      windowManager.updateBreakPointByWindWidth(0)
      windowManager.updateBreakPointByWindWidth(500)
      windowManager.updateBreakPointByWindWidth(960)
      windowManager.updateBreakPointByWindWidth(1000)
    });
    it('WindowManagerTest_updateNavBarWidth', 0, async () => {
      let windowManager = new WindowManager();
      (windowManager as object)['currentBreakingPoint'] = 'lg';
      (windowManager as object)['updateNavBarWidth']();
      (windowManager as object)['currentBreakingPoint'] = 'md';
      (windowManager as object)['updateNavBarWidth']();
    });
    it('WindowManagerTest_setSystemBarProperties', 0, async () => {
      let windowManager = WindowManager;
      let windowStage: window.WindowStage = AppStorage.get<window.WindowStage>('windowStage') as window.WindowStage;
      let properties: window.SystemBarProperties = {
        statusBarContentColor: 'white',
        navigationBarContentColor: 'white',
      };
      let result = await windowManager.setSystemBarProperties(windowStage, properties, 'white');
      expect(result === null).assertFalse();
      let windowStage2: window.WindowStage = {} as window.WindowStage;
      let properties2: window.SystemBarProperties =
        AppStorage.get<window.SystemBarProperties>('SystemBarProperties') as window.SystemBarProperties;
      let result2 = await windowManager.setSystemBarProperties(windowStage2, properties2, 'white');
      expect(result2 === null).assertFalse();
    })
    it('WindowManagerTest_setKeepScreenOn', 0, async () => {
      let windowManager = WindowManager;
      let windowStage: window.WindowStage = AppStorage.get<window.WindowStage>('windowStage') as window.WindowStage;
      windowManager.setKeepScreenOn(windowStage, true)
    })
    it('WindowManagerTest_getAvoidAreaHeight', 0, (done: Function) => {
      let windowManager = WindowManager;
      let windowStage: window.WindowStage = AppStorage.get<window.WindowStage>('windowStage') as window.WindowStage;
      try {
        windowManager.getAvoidAreaHeight(windowStage,
          AvoidAreaDirect.TOP,
          window.AvoidAreaType.TYPE_SYSTEM_GESTURE);
        windowManager.getAvoidAreaHeight(windowStage,
          AvoidAreaDirect.BOTTOM,
          window.AvoidAreaType.TYPE_CUTOUT);
        windowManager.getAvoidAreaHeight(windowStage, 3,
          window.AvoidAreaType.TYPE_SYSTEM)
      } catch (e) {
      } finally {
        done()
      }
    })
    it('WindowManagerTest_setKeyboardAvoidMode', 0, async () => {
      let windowManager = new WindowManager();
      windowManager.setKeyboardAvoidMode(1)
    })
    it('WindowManagerTest_setSystemBar', 0, () => {
      let windowManager = WindowManager;
      let params: ConfigurationConstant.ColorMode = ConfigurationConstant.ColorMode.COLOR_MODE_DARK
      windowManager.setSystemBar(params)
      let params2: ConfigurationConstant.ColorMode = ConfigurationConstant.ColorMode.COLOR_MODE_LIGHT
      windowManager.setSystemBar(params2)
    })

    it('WindowManagerTest_setWindowBackgroundColor', 0, () => {
      let windowManager = WindowManager;
      let window: window.Window = {} as window.Window;
      windowManager.setWindowBackgroundColor('#ffffff', window)
    })
    it('WindowManagerTest_setWindowOrientation', 0, () => {
      let windowManager = WindowManager;
      let windowStage: window.WindowStage = AppStorage.get<window.WindowStage>('windowStage') as window.WindowStage;
      windowManager.setWindowOrientation(windowStage, 0);

      let windowStage2: window.WindowStage = {} as window.WindowStage;
      windowManager.setWindowOrientation(windowStage2, -1)

      let windowStage3: window.WindowStage = {} as window.WindowStage;
      windowManager.setWindowOrientation(windowStage3, 1)
    })
    it('WindowManagerTest_setWaterMarkFlag', 0, async (done: Function) => {
      let windowManager = new WindowManager();
      try {
        windowManager.setWaterMarkFlag(true)
      } catch (e) {
      } finally {
        done()
      }
    })

    it('WindowManagerTest_offKeyboardHeightChange', 0, () => {
      let windowManager = new WindowManager();
      windowManager.offKeyboardHeightChange()
    })
    it('WindowManagerTest_onKeyboardHeightChange', 0, () => {
      let windowManager = new WindowManager();
      windowManager.onKeyboardHeightChange(() => {
      });
    })

    it('WindowManagerTest_onKeyboardHeightChange_01', 0, () => {
      let windowManager = WindowManager;
      windowManager.closePluginWindow('test', true)
    })
    it('WindowManagerTest_updatePluginWindowHeight', 0, () => {
      let windowManager = WindowManager;
      windowManager.updatePluginWindowHeight('test', 100)
    })
    it('WindowManagerTest_setWindowProperties', 0, () => {
      let windowManager = WindowManager;
      let windowStage: window.WindowStage = AppStorage.get<window.WindowStage>('windowStage') as window.WindowStage;
      let context: Context = AppStorage.get<Context>('pageContext') as common.UIAbilityContext;
      windowManager.setWindowProperties(context, windowStage);
    })
    it('WindowManagerTest_resizeWindow', 0, async () => {
      let windowManager = new WindowManager();
      let window: window.Window = {} as window.Window;
      await windowManager.resizeWindow(window, 100, 100);

      let window2: window.Window = AppStorage.get<window.Window>('windowStage') as window.Window;
      await windowManager.resizeWindow(window2, 100, 100)
    })

    it('WindowManagerTest_setNavBarWidth', 0, async () => {
      let windowManager = WindowManager;
      await windowManager.setNavBarWidth(100)
    })

    it('WindowManagerTest_onAvoidAreaChange', 0, () => {
      try {
        let windowManager = WindowManager;
        let windowStage: window.WindowStage = AppStorage.get<window.WindowStage>('windowStage') as window.WindowStage;
        let res = windowManager.onAvoidAreaChange(windowStage, () => {
          () => {
          }
        });
        expect(res !== null).assertTrue()
      } catch (e) {
        LogUtil.error(e)
      }
    })

    it('WindowManagerTest_offAvoidAreaChange', 0, () => {
      try {
        let windowManager = WindowManager;
        let windowStage: window.WindowStage = AppStorage.get<window.WindowStage>('windowStage') as window.WindowStage;
        let res = windowManager.offAvoidAreaChange(windowStage, () => {
        });
        expect(res !== null).assertTrue()
      } catch (e) {
        LogUtil.error(e)
      }
    })

    it('WindowManagerTest_loadContent', 0, () => {
      try {
        let windowManager = WindowManager;
        let windowStage: window.WindowStage = AppStorage.get<window.WindowStage>('windowStage') as window.WindowStage;
        let res = windowManager.loadContent(windowStage, 'test', 'test1');
        expect(res !== null).assertTrue()
      } catch (e) {
        LogUtil.error(e)
      }
    })

    it('WindowManagerTest_setMainWindowBgColorByColorMode', 0, () => {
      try {
        let windowManager = WindowManager;
        let windowStage: window.WindowStage = AppStorage.get<window.WindowStage>('windowStage') as window.WindowStage;
        let res =
          windowManager.setMainWindowBgColorByColorMode(windowStage, ConfigurationConstant.ColorMode.COLOR_MODE_LIGHT);
        expect(res !== null).assertTrue();

      } catch (e) {
        LogUtil.error(e)
      }
    })

    it('WindowManagerTest_setMainWindowBgColorByColorMode2', 0, () => {
      try {
        let windowManager = WindowManager;
        let windowStage: window.WindowStage = AppStorage.get<window.WindowStage>('windowStage') as window.WindowStage;
        let res =
          windowManager.setMainWindowBgColorByColorMode(windowStage, ConfigurationConstant.ColorMode.COLOR_MODE_DARK);
        expect(res !== null).assertTrue()
      } catch (e) {
        LogUtil.error(e)
      }
    })

  });
}


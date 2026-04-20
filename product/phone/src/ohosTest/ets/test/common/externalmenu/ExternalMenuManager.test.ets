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
import {
  ExternalMenu,
  ExternalMenuChangeListener,
  ExternalMenuManager,
  LangChangeListener,
} from '@ohos/settings.common/src/main/ets/externalmenu/ExternalMenuManager';
import { Constant } from '../../constant/Constant';
import { bundle } from '@kit.AbilityKit';
import { resourceManager } from '@kit.LocalizationKit';

const MENU_KEY: string = 'test_menu';
const BUNDLE_NAME: string = 'com.ohos.ouc';
const USER_ID: number = 100;

export default function ExternalMenuManagerTest() {
  describe('ExternalMenuManagerTest', () => {
    let menu: ExternalMenu = {
      bundleName: '',
      abilityName: '',
      key: '',
      menuType: '',
      showCondition: '',
      titleResource: '',
      title: '',
      state: '',
      iconResource: '',
      icon: '',
      summaryResource: '',
      summary: '',
      stateDbKey: '',
      stateDefault: '',
      switchDbKey: '',
      switchDefault: '',
      accessTokenId: 1,
    } as ExternalMenu;
    let externalMenuInstance = new ExternalMenu(menu);
    let externalMenuManager = new ExternalMenuManager;
    /*
    * @tc.number: ExternalMenuManagerTest_001
    * @tc.name: 加载状态文本资源
    * @tc.type: TestType.FUNCTION
    * @tc.desc: return
    */
    it('ExternalMenuManagerTest_001', TestType.FUNCTION, async () => {
      LogUtil.info(`${Constant.TAG} ExternalMenuManagerTest_001 start`);
      let externalMenuManager = ExternalMenuManager.getInstance();
      let menu = await externalMenuManager.getExternalMenu(MENU_KEY);
      let externalMenu = new ExternalMenu(menu);
      let result = await externalMenu.loadStateResource();
      expect(result).assertEqual('');
      LogUtil.info(`${Constant.TAG} ExternalMenuManagerTest_001 end`);
    });

    /*
    * @tc.number: ExternalMenuManagerTest_003
    * @tc.name: 监听应用变更
    * @tc.type: TestType.FUNCTION
    * @tc.desc: registerListener listener invalid
    */
    it('ExternalMenuManagerTest_003', TestType.FUNCTION, async () => {
      LogUtil.info(`${Constant.TAG} ExternalMenuManagerTest_003 start`);
      let externalMenuManager = ExternalMenuManager.getInstance();
      let mocker: MockKit = new MockKit();
      let mockFunc: Function = mocker.mockFunc(externalMenuManager, externalMenuManager.registerListener);
      when(mockFunc)().afterThrow('registerListener listener invalid');
      try {
        externalMenuManager.registerListener(null);
        mocker.clear(externalMenuManager);
      } catch (e) {
        expect(e).assertEqual('registerListener listener invalid');
      }
      LogUtil.info(`${Constant.TAG} ExternalMenuManagerTest_003 end`);
    })

    /*
    * @tc.number: ExternalMenuManagerTest_004
    * @tc.name: 取消监听应用变更
    * @tc.type: TestType.FUNCTION
    * @tc.desc: unRegisterListener listener invalid
    */
    it('ExternalMenuManagerTest_004', TestType.FUNCTION, async () => {
      LogUtil.info(`${Constant.TAG} ExternalMenuManagerTest_004 start`);
      let externalMenuManager = ExternalMenuManager.getInstance();
      let mocker: MockKit = new MockKit();
      let mockFunc: Function = mocker.mockFunc(externalMenuManager, externalMenuManager.unRegisterListener);
      when(mockFunc)().afterThrow('unRegisterListener listener invalid');
      try {
        externalMenuManager.unRegisterListener(null);
        mocker.clear(externalMenuManager);
      } catch (e) {
        expect(e).assertEqual('unRegisterListener listener invalid');
      }
      LogUtil.info(`${Constant.TAG} ExternalMenuManagerTest_004 end`);
    });

    /*
    * @tc.number: ExternalMenuManagerTest_005
    * @tc.name: onBundleAdd
    * @tc.type: TestType.FUNCTION
    * @tc.desc: onBundleAdd bundleName invalid
    */
    it('ExternalMenuManagerTest_005', TestType.FUNCTION, async () => {
      LogUtil.info(`${Constant.TAG} ExternalMenuManagerTest_005 start`);
      let externalMenuManager = ExternalMenuManager.getInstance();
      let mocker: MockKit = new MockKit();
      let mockFunc: Function = mocker.mockFunc(externalMenuManager, externalMenuManager.onBundleAdd);
      when(mockFunc)().afterThrow('onBundleAdd bundleName invalid');
      try {
        externalMenuManager.onBundleAdd(null, null, 0);
        mocker.clear(externalMenuManager);
      } catch (e) {
        expect(e).assertEqual('onBundleAdd bundleName invalid');
      }
      when(mockFunc)(BUNDLE_NAME).afterReturn(true);
      let result = await externalMenuManager.onBundleAdd(BUNDLE_NAME, USER_ID, 0);
      expect(result !== null).assertTrue();
      LogUtil.info(`${Constant.TAG} ExternalMenuManagerTest_005 end`);
    });

    /*
    * @tc.number: ExternalMenuManagerTest_006
    * @tc.name: onBundleUpdate
    * @tc.type: TestType.FUNCTION
    * @tc.desc: onBundleUpdate bundleName invalid
    */
    it('ExternalMenuManagerTest_006', TestType.FUNCTION, async () => {
      LogUtil.info(`${Constant.TAG} ExternalMenuManagerTest_006 start`);
      let externalMenuManager = ExternalMenuManager.getInstance();
      let mocker: MockKit = new MockKit();
      let mockFunc: Function = mocker.mockFunc(externalMenuManager, externalMenuManager.onBundleUpdate);
      when(mockFunc)().afterThrow('onBundleUpdate bundleName invalid');
      try {
        externalMenuManager.onBundleUpdate(null, null, 0);
      } catch (e) {
        expect(e).assertEqual('onBundleUpdate bundleName invalid');
      }
      when(mockFunc)(BUNDLE_NAME).afterReturn(true);
      let result = await externalMenuManager.onBundleUpdate(BUNDLE_NAME, USER_ID, 0);
      expect(result !== null).assertTrue();
      mocker.clear(externalMenuManager);
      LogUtil.info(`${Constant.TAG} ExternalMenuManagerTest_006 end`);
    });

    /*
    * @tc.number: ExternalMenuManagerTest_007
    * @tc.name: onBundleRemove
    * @tc.type: TestType.FUNCTION
    * @tc.desc: onBundleRemove bundleName invalid
    */
    it('ExternalMenuManagerTest_007', TestType.FUNCTION, async () => {
      LogUtil.info(`${Constant.TAG} ExternalMenuManagerTest_007 start`);
      let externalMenuManager = ExternalMenuManager.getInstance();
      let mocker: MockKit = new MockKit();
      let mockFunc: Function = mocker.mockFunc(externalMenuManager, externalMenuManager.onBundleRemove);
      when(mockFunc)().afterThrow('onBundleRemove bundleName invalid');
      try {
        externalMenuManager.onBundleRemove(null, null, 0);
      } catch (e) {
        expect(e).assertEqual('onBundleRemove bundleName invalid');
      }
      when(mockFunc)(BUNDLE_NAME).afterReturn(true);
      let result = await externalMenuManager.onBundleRemove(BUNDLE_NAME, USER_ID, 0);
      expect(result !== null).assertTrue();
      mocker.clear(externalMenuManager);
      LogUtil.info(`${Constant.TAG} ExternalMenuManagerTest_007 end`);
    });

    it('ExternalMenuManagerTest_loadTitleResourceNew', 0, () => {
      let result = externalMenuInstance.loadTitleResourceNew(null);
      expect(result !== null).assertTrue();
    });

    it('ExternalMenuManagerTest_loadTitleResourceNew2', 0, () => {
      (externalMenuInstance as object)['titleResource'] = 'test';
      let result = externalMenuInstance.loadTitleResourceNew(null);
      expect(result !== null).assertTrue();
    });

    it('ExternalMenuManagerTest_loadTitleResourceNew3', 0, () => {
      (externalMenuInstance as object)['titleResource'] = 'test';
      let resourceManager: resourceManager.ResourceManager = {} as resourceManager.ResourceManager;
      let result = externalMenuInstance.loadTitleResourceNew(resourceManager);
      expect(result !== null).assertTrue();
    });

    it('ExternalMenuManagerTest_loadSummaryResourceNew', 0, () => {
      let result = externalMenuInstance.loadSummaryResourceNew(null);
      expect(result !== null).assertTrue();
    });

    it('ExternalMenuManagerTest_loadSummaryResourceNew2', 0, () => {
      (externalMenuInstance as object)['summaryResource'] = 'test';
      let result = externalMenuInstance.loadSummaryResourceNew(null);
      expect(result !== null).assertTrue();
    });

    it('ExternalMenuManagerTest_loadSummaryResourceNew3', 0, () => {
      (externalMenuInstance as object)['summaryResource'] = 'test';
      let resourceManager: resourceManager.ResourceManager = {} as resourceManager.ResourceManager;
      let result = externalMenuInstance.loadSummaryResourceNew(resourceManager);
      expect(result !== null).assertTrue();
    });

    it('ExternalMenuManagerTest_loadStringResource', 0, () => {
      let result = externalMenuInstance.loadStringResource('');
      expect(result !== null).assertTrue();
      let result2 = externalMenuInstance.loadStringResource('test');
      expect(result2 !== null).assertTrue();
      (externalMenuInstance as object)['bundleName'] = 'com.ohos.settings';
      let result3 = externalMenuInstance.loadStringResource('test');
      expect(result3 !== null).assertTrue();
    });

    it('ExternalMenuManagerTest_onBundleUpdate', 0, () => {
      let externalMenuManagerInstance = new ExternalMenuManager();
      let result = externalMenuManagerInstance.onBundleUpdate('', 0, 0);
      expect(result !== null).assertTrue();

      let result2 = externalMenuManagerInstance.onBundleUpdate('test', 0, 0);
      expect(result2 !== null).assertTrue();
    });

    it('ExternalMenuManagerTest_onBundleRemove', 0, () => {
      let externalMenuManagerInstance = new ExternalMenuManager();
      let result = externalMenuManagerInstance.onBundleRemove('', 0, 0);
      expect(result !== null).assertTrue();

      let result2 = externalMenuManagerInstance.onBundleRemove('test', 0, 0);
      expect(result2 !== null).assertTrue();
    });

    it('ExternalMenuManagerTest_getListenerName', 0, () => {
      let externalMenuManagerInstance = new ExternalMenuManager();
      let result = externalMenuManagerInstance.getListenerName();
      expect(result !== null).assertTrue();
    });

    it('ExternalMenuManagerTest_dispatchLangChangeEvent', 0, () => {
      let externalMenuManagerInstance = new ExternalMenuManager();
      let result = externalMenuManagerInstance.dispatchLangChangeEvent('test');
      expect(result !== null).assertTrue();
    });

    it('ExternalMenuManagerTest_startLoad', 0, async () => {
      let externalMenuManagerInstance = new ExternalMenuManager();
      let result = await externalMenuManagerInstance.startLoad(() => {
      });
      expect(result !== null).assertTrue();
    });

    it('ExternalMenuManagerTest_onBundleAdd', 0, async () => {
      let externalMenuManagerInstance = new ExternalMenuManager();
      let result = await externalMenuManagerInstance.onBundleAdd('', 1, 1);
      expect(result !== null).assertTrue();

      let result2 = await externalMenuManagerInstance.onBundleAdd('test', 1, 1);
      expect(result2 !== null).assertTrue();
    });

    it('ExternalMenuManagerTest_clearCache', 0, async () => {
      let externalMenuManagerInstance = new ExternalMenuManager();
      (externalMenuManagerInstance as object)['clearCache']();
    });

    it('ExternalMenuManagerTest_registerLangChangeListener', 0, async () => {
      let externalMenuManagerInstance = new ExternalMenuManager();
      let listener: LangChangeListener = {
        getListenerName: (): string => {
          return 'test';
        },
        onLangChange: (newLang: string): void => {
        }
      }
      externalMenuManagerInstance.langChangeListeners = [
        {
          getListenerName: (): string => {
            return 'test';
          },
          onLangChange: (newLang: string): void => {
          }
        }
      ]
      externalMenuManagerInstance.registerLangChangeListener(listener);
      let listener2: undefined = undefined;
      externalMenuManagerInstance.registerLangChangeListener(listener2);
    });

    it('ExternalMenuManagerTest_unregisterLangChangeListener', 0, () => {
      let externalMenuManagerInstance = new ExternalMenuManager();
      let listener: LangChangeListener = {
        getListenerName: (): string => {
          return 'test';
        },
        onLangChange: (newLang: string): void => {
        }
      };
      let arrList: LangChangeListener[] = [
        {
          getListenerName: (): string => {
            return 'test';
          },
          onLangChange: (newLang: string): void => {
          }
        }
      ];
      arrList.forEach((item: LangChangeListener) => {
        externalMenuManagerInstance.langChangeListeners.push(item)
        externalMenuManagerInstance.unregisterLangChangeListener(listener)
      }
      )
      let listener2: undefined = undefined;
      externalMenuManagerInstance.unregisterLangChangeListener(listener2);
    });
    it('ExternalMenuManagerTest_registerListener', 0, () => {
      let externalMenuManagerInstance = new ExternalMenuManager();
      let listener: ExternalMenuChangeListener = {
        getListenerName: (): string => {
          return 'test'
        },
        onExternalMenuChange: (bundleName: string): void => {
        },
        onExternalMenuLoadFinish: (): void => {
        }
      }
      externalMenuManagerInstance.listeners = [
        {
          getListenerName: (): string => {
            return 'test';
          },
          onExternalMenuChange: (newLang: string): void => {
          },
          onExternalMenuLoadFinish: (): void => {
          },
        }
      ];
      externalMenuManagerInstance.registerListener(listener);
      let listener2: undefined = undefined;
      externalMenuManagerInstance.registerListener(listener2);
    });

    it('ExternalMenuManagerTest_unRegisterListener', 0, async () => {
      let externalMenuManagerInstance = new ExternalMenuManager();
      let listener: ExternalMenuChangeListener = {
        getListenerName: (): string => {
          return 'test'
        },
        onExternalMenuChange: (bundleName: string): void => {
        },
        onExternalMenuLoadFinish: (): void => {
        }
      }
      externalMenuManagerInstance.listeners = [
        {
          getListenerName: (): string => {
            return 'test';
          },
          onExternalMenuChange: (newLang: string): void => {
          },
          onExternalMenuLoadFinish: (): void => {
          },
        }
      ];
      externalMenuManagerInstance.unRegisterListener(listener);
      let listener2: undefined = undefined;
      externalMenuManagerInstance.unRegisterListener(listener2);
    });

    it('ExternalMenuManagerTest_loadStateResource', 0, async () => {
      externalMenuInstance.stateDbKey = '123'
      let result = externalMenuInstance.loadStateResource()
      expect(result !== null).assertTrue()
    });

  });
}
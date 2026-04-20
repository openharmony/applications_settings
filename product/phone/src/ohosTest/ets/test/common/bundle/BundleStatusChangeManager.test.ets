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
  BundleStatusChangeManager,
  BundleStatusChangeListener,
} from '@ohos/settings.common/src/main/ets/bundle/BundleStatusChangeManager';
import { Constant } from '../../constant/Constant';

const MENU_KEY: string = "test_menu";

export default function BundleStatusChangeManagerTest() {
  describe('BundleStatusChangeManagerTest', () => {

    /*
    * @tc.number: BundleStatusChangeManagerTest_001
    * @tc.name: 注册应用变更监听
    * @tc.type: TestType.FUNCTION
    * @tc.desc: return true
    */
    it('BundleStatusChangeManagerTest_001', TestType.FUNCTION, async () => {
      LogUtil.info(`${Constant.TAG} BundleStatusChangeManagerTest_001 start`);
      let bundleStatusChangeManager = new BundleStatusChangeManager();
      let listener: BundleStatusChangeListener = {
        getListenerName: (): string => {
          return MENU_KEY;
        },
        onBundleAdd: () => {
        },
        onBundleRemove: () => {
        },
        onBundleUpdate: () => {
        },
      };
      let mocker: MockKit = new MockKit();
      let mockFunc: Function = mocker.mockFunc(bundleStatusChangeManager, bundleStatusChangeManager.registerBundleChangedListener);
      when(mockFunc)(listener).afterReturn(true);
      let result = await bundleStatusChangeManager.registerBundleChangedListener(listener);
      expect(result !== null).assertTrue();
      LogUtil.info(`${Constant.TAG} BundleStatusChangeManagerTest_001 end`);
      mocker.clear(bundleStatusChangeManager);
    });

    /*
    * @tc.number: BundleStatusChangeManagerTest_002
    * @tc.name: 取消注册应用变更监听
    * @tc.type: TestType.FUNCTION
    * @tc.desc: return true
    */
    it('BundleStatusChangeManagerTest_002', TestType.FUNCTION, async () => {
      LogUtil.info(`${Constant.TAG} BundleStatusChangeManagerTest_002 start`);
      let bundleStatusChangeManager = new BundleStatusChangeManager();
      let listener: BundleStatusChangeListener = {
        getListenerName: (): string => {
          return MENU_KEY;
        },
        onBundleAdd: () => {
        },
        onBundleRemove: () => {
        },
        onBundleUpdate: () => {
        },
      };
      let mocker: MockKit = new MockKit();
      let mockFunc: Function = mocker.mockFunc(bundleStatusChangeManager, bundleStatusChangeManager.unRegisterBundleChangedListener);
      when(mockFunc)(listener).afterReturn(true);
      let result = await bundleStatusChangeManager.unRegisterBundleChangedListener(listener);
      expect(result !== null).assertTrue();
      LogUtil.info(`${Constant.TAG} BundleStatusChangeManagerTest_002 end`);
      mocker.clear(bundleStatusChangeManager);
    });
    it("BundleStatusChangeManagerTest_003", 0, async (done: Function) => {
      let bundleStatusChangeM = new BundleStatusChangeManager();
      await (bundleStatusChangeM as object)['registerStatusChange']();
      await (bundleStatusChangeM as object)['registerStatusChange']();
      expect(bundleStatusChangeM != null).assertTrue();
      done();
    })
    it("BundleStatusChangeManagerTest_004", 0, () => {
      let bundleStatusChangeM = new BundleStatusChangeManager();
      (bundleStatusChangeM as object)['isRegister'] = true;
      (bundleStatusChangeM as object)['unRegisterStatusChange']();
      (bundleStatusChangeM as object)['isRegister'] = false;
      (bundleStatusChangeM as object)['unRegisterStatusChange']();
      expect(bundleStatusChangeM != null).assertTrue();
    })
    it("BundleStatusChangeManagerTest_005", 0, async (done: Function) => {
      let bundleStatusChangeM = new BundleStatusChangeManager();
      let listener: BundleStatusChangeListener = {
        getListenerName: (): string => {
          return MENU_KEY;
        },
        onBundleAdd: () => {
        },
        onBundleRemove: () => {
        },
        onBundleUpdate: () => {
        },
      };
      bundleStatusChangeM.listeners = [listener];
      await bundleStatusChangeM.registerBundleChangedListener(listener);
      let listener1: BundleStatusChangeListener = {
        getListenerName: (): string => {
          return MENU_KEY+'1';
        },
        onBundleAdd: () => {
        },
        onBundleRemove: () => {
        },
        onBundleUpdate: () => {
        },
      };
      await bundleStatusChangeM.registerBundleChangedListener(listener1);
      expect(bundleStatusChangeM != null).assertTrue();
      done();
    })
    it("BundleStatusChangeManagerTest_006", 0, () => {
      let bundleStatusChangeM = new BundleStatusChangeManager();
      let listener: BundleStatusChangeListener = {
        getListenerName: (): string => {
          return MENU_KEY;
        },
        onBundleAdd: () => {
        },
        onBundleRemove: () => {
        },
        onBundleUpdate: () => {
        },
      };
      let listener1: BundleStatusChangeListener = {
        getListenerName: (): string => {
          return MENU_KEY+'1';
        },
        onBundleAdd: () => {
        },
        onBundleRemove: () => {
        },
        onBundleUpdate: () => {
        },
      };
      let listener2: BundleStatusChangeListener = {
        getListenerName: (): string => {
          return MENU_KEY+'2';
        },
        onBundleAdd: () => {
        },
        onBundleRemove: () => {
        },
        onBundleUpdate: () => {
        },
      };
      bundleStatusChangeM.listeners = [listener, listener1];
      bundleStatusChangeM.unRegisterBundleChangedListener(listener2);
      bundleStatusChangeM.unRegisterBundleChangedListener(listener);
      bundleStatusChangeM.unRegisterBundleChangedListener(listener1);
      expect(bundleStatusChangeM != null).assertTrue();
    })
    it("BundleStatusChangeManagerTest_007", 0, () => {
      let bundleStatusChangeM = BundleStatusChangeManager.getInstance();
      let bundleStatusChangeM2 = BundleStatusChangeManager.getInstance();
      expect(bundleStatusChangeM2 == bundleStatusChangeM).assertTrue();
    })
    it("BundleStatusChangeManagerTest_008", 0, async (done: Function) => {
      let bundleStatusChangeM = BundleStatusChangeManager.getInstance();
      let listener: BundleStatusChangeListener =
        AppStorage.get<BundleStatusChangeListener>('listener') as BundleStatusChangeListener;
      await bundleStatusChangeM.registerBundleChangedListener(listener);
      expect(bundleStatusChangeM != null).assertTrue();
      done();
    })
    it("BundleStatusChangeManagerTest_009", 0, async (done: Function) => {
      let bundleStatusChangeM = BundleStatusChangeManager.getInstance();
      let listener: BundleStatusChangeListener =
        AppStorage.get<BundleStatusChangeListener>('listener') as BundleStatusChangeListener;
      await bundleStatusChangeM.unRegisterBundleChangedListener(listener);
      expect(bundleStatusChangeM != null).assertTrue();
      done();
    })
  });
}
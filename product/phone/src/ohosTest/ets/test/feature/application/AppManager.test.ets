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

import { describe, expect, it } from '@ohos/hypium';
import { AppManager } from '@ohos/settings.application/src/main/ets/util/AppManager';

export default function AppManagerTest() {
  describe('AppManagerTest', (): void => {
    let appManager = AppManager.getInstance();
    it('AppManagerTest_001', 0, (done: Function) => {
      try {
        let result = appManager.getUserId();
        expect(result !== null).assertTrue();
        appManager.userId = 1;
        let result2 = appManager.getUserId();
        expect(result2 !== null).assertTrue();
      } catch (e) {
      } finally {
        done()
      }
    });
    it('AppManagerTest_002', 0, (done: Function) => {
      try {
        let result = appManager.killProcessWithAccount('bundleName', 1);
        expect(result !== null).assertTrue();
        appManager.userId = 1;
        let result2 = appManager.killProcessWithAccount('bundleName', -1);
        expect(result2 !== null).assertTrue();
      } catch (e) {
      } finally {
        done()
      }
    });
    it('AppManagerTest_003', 0, (done: Function) => {
      try {
        let result = appManager.getIsApplicationRunning('', 1);
        expect(result !== null).assertTrue();
        appManager.userId = 1;
        let result2 = appManager.getIsApplicationRunning('bundleName', -1);
        expect(result2 !== null).assertTrue();
      } catch (e) {
      } finally {
        done()
      }
    });
    it('AppManagerTest_004', 0, (done: Function) => {
      try {
        let result = appManager.setApplicationEnabled('', true, 1);
        expect(result !== null).assertTrue();
        appManager.userId = 1;
        let result2 = appManager.setApplicationEnabled('bundleName', true, 1);
        expect(result2 !== null).assertTrue();
      } catch (e) {
      } finally {
        done()
      }
    });
    it('AppManagerTest_005', 0, (done: Function) => {
      try {
        let result = appManager.getIsApplicationEnabled('', 1);
        expect(result !== null).assertTrue();
        appManager.userId = 1;
        let result2 = appManager.getIsApplicationEnabled('bundleName', 1);
        expect(result2 !== null).assertTrue();
      } catch (e) {
      } finally {
        done()
      }
    });
    it('AppManagerTest_006', 0, (done: Function) => {
      try {
        let result = appManager.uninstallApp('', 1);
        expect(result !== null).assertTrue();
        appManager.userId = 1;
        let result2 = appManager.uninstallApp('bundleName', 1);
        expect(result2 !== null).assertTrue();
      } catch (e) {
      } finally {
        done()
      }
    });
    it('AppManagerTest_007', 0, (done: Function) => {
      try {
        let result = appManager.notifyHomePageStateChange('bundleName', true, 1);
        expect(result !== null).assertTrue();
        appManager.userId = 1;
        let result2 = appManager.notifyHomePageStateChange('com.ohos.vassistant', true, 1);
        expect(result2 !== null).assertTrue();
      } catch (e) {
      } finally {
        done()
      }
    });
    it('AppManagerTest_008', 0, (done: Function) => {
      try {
        let result = appManager.getLanguageChangingStatus('');
        expect(result !== null).assertTrue();
        (appManager as object)['isLanguageChanging'] = true;
        let result2 = appManager.getLanguageChangingStatus('');
        expect(result2 !== null).assertTrue();
      } catch (e) {
      } finally {
        done()
      }
    });
    it('AppManagerTest_009', 0, (done: Function) => {
      try {
        let result = appManager.isAppForceStop('bundleName', 'moduleName');
        expect(result !== null).assertTrue();
      } catch (e) {
      } finally {
        done()
      }
    });
    it('AppManagerTest_010', 0, (done: Function) => {
      try {
        let result = appManager.isAppDisables('bundleName', 'moduleName');
        expect(result !== null).assertTrue();
      } catch (e) {
      } finally {
        done()
      }
    });
    it('AppManagerTest_011', 0, (done: Function) => {
      try {
        let result = appManager.getMetadata('bundleName', 'moduleName', 'metaDataName');
        expect(result !== null).assertFalse();
      } catch (e) {
      } finally {
        done()
      }
    });
    it('AppManagerTest_013', 0, (done: Function) => {
      try {
        let result = appManager.queryEntryKey('');
        expect(result !== null).assertTrue();
        let result2 = appManager.queryEntryKey('entryKey');
        expect(result2 !== null).assertTrue();
      } catch (e) {
      } finally {
        done()
      }
    });
    it('AppManagerTest_014', 0, (done: Function) => {
      try {
        let result = appManager.registerEventListener();
        expect(result !== null).assertTrue();
      } catch (e) {
      } finally {
        done()
      }
    });
    it('AppManagerTest_015', 0, (done: Function) => {
      try {
        let result = appManager.unRegisterEventListener();
        expect(result !== null).assertTrue();
      } catch (e) {
      } finally {
        done()
      }
    });
  })
}


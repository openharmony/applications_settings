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

import { afterAll, afterEach, beforeAll, beforeEach, describe, expect, it } from '@ohos/hypium';
import { AppUtils } from '@ohos/settings.application/src/main/ets/AppUtils';


export default function appUtilsTest() {
  describe('appUtilsTest', (): void => {

    beforeAll((): void => {
    })

    beforeEach((): void => {

    })

    afterAll((): void => {
    })

    afterEach((): void => {
    })

    it('formatSize', 0, () => {
      const result = AppUtils.formatSize(1000);
      expect(result).assertEqual('0.98KB');
    })

    it('AppUtilsTest_clearUpApplicationData_success', 0, () => {
      let res = 'test';
      AppUtils.clearUpApplicationData('com.ohos.settings');
      expect(res).not().assertNull();
    })
    it('AppUtilsTest_clearUpApplicationData_failed', 0, () => {
      let res = 'test';
      AppUtils.clearUpApplicationData('');
      expect(res).not().assertNull();
    })

    it('AppUtilsTest_killProcessesByBundleName_01', 0, () => {
      let res = 'test';
      AppUtils.killProcessesByBundleName('');
      expect(res).not().assertNull();
    })
    it('AppUtilsTest_killProcessesByBundleName_02', 0, () => {
      let res = 'test';
      AppUtils.killProcessesByBundleName('bundleName');
      expect(res).not().assertNull();
    })

    it('ProcessServiceTest_isProcessesRunning_01', 0, async () => {
      const res = await AppUtils.isProcessesRunning('');
      expect(res).assertFalse();
    })

    it('appUtilsTest_formatSize', 0, (done: Function) => {
      try {
        let result = AppUtils.formatSize(921666);
        expect(result !== null).assertTrue();
        let result2 = AppUtils.formatSize(921666000);
        expect(result2 !== null).assertTrue();
      } catch (e) {
      } finally {
        done()
      }
    });
    it('appUtilsTest_cleanBundleCacheFiles', 0, (done: Function) => {
      try {
        let result = AppUtils.cleanBundleCacheFiles('');
        expect(result !== null).assertTrue();
        let result2 = AppUtils.cleanBundleCacheFiles('bundleName');
        expect(result2 !== null).assertTrue();
      } catch (e) {
      } finally {
        done()
      }
    });
    it('appUtilsTest_isProcessesRunning', 0, async  (done: Function) => {
      try {
        let result = await AppUtils.isProcessesRunning('bundleName');
        expect(result !== null).assertTrue();
      } catch (e) {
      } finally {
        done()
      }
    });

    it('appUtilsTest_getActivatedAccountLocalId', 0, async  (done: Function) => {
      try {
        let result = await AppUtils.getActivatedAccountLocalId();
        expect(result !== null).assertTrue();
      } catch (e) {
      } finally {
        done()
      }
    });

    it('appUtilsTest_parsePushParamFromAppKey', 0,  (done: Function) => {
      try {
        let result =  AppUtils.parsePushParamFromAppKey('');
        expect(result !== null).assertTrue();
        let result2 =  AppUtils.parsePushParamFromAppKey('test');
        expect(result2 !== null).assertTrue();
        let result3 =  AppUtils.parsePushParamFromAppKey('test,test,test');
        expect(result3 !== null).assertTrue();
      } catch (e) {
      } finally {
        done()
      }
    });
    it('appUtilsTest_isCloneBundle', 0,  (done: Function) => {
      try {
        let result =  AppUtils.isCloneBundle(1);
        expect(result !== null).assertTrue();
      } catch (e) {
      } finally {
        done()
      }
    });
    it('appUtilsTest_isBundleExist', 0,  (done: Function) => {
      try {
        let result =  AppUtils.isBundleExist('bundleName', 1);
        expect(result !== null).assertTrue();
      } catch (e) {
      } finally {
        done()
      }
    });

    it('appUtilsTest_getAppKey1', 0, () => {
      let result: string = AppUtils.getAppKey('one', 1);
      expect(result === 'one,1').assertTrue();
    });

    it('appUtilsTest_getAppKey2', 0, () => {
      let result: string = AppUtils.getAppKey('one');
      expect(result === 'one,0').assertTrue();
    });

    it('appUtilsTest_getAppKey3', 0, () => {
      let result: string = AppUtils.getAppKey('one', -1);
      expect(result === 'one,-1').assertTrue();
    });

    it('appUtilsTest_getAppKey4', 0, () => {
      let result: string = AppUtils.getAppKey('one', 0);
      expect(result === 'one,0').assertTrue();
    });
  })
}

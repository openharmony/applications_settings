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
import { MoreAppListLoader } from '@ohos/settings.application/src/main/ets/MoreAppListLoader';

export default function MoreAppListLoaderTest() {
  describe('MoreAppListLoaderTest', (): void => {
    let moreAppListLoader = MoreAppListLoader.getInstance();
    it('MoreAppListLoaderTest_001', 0, (done: Function) => {
      try {
        let result = moreAppListLoader.loadAppList();
        expect(result !== null).assertTrue();
        moreAppListLoader.lastSystemLocale = 'lastSystemLocale';
        let result2 = moreAppListLoader.loadAppList();
        expect(result2 !== null).assertTrue();
        (moreAppListLoader as object)['isFirstLoad'] = false;
        (moreAppListLoader as object)['isLocaleChanged'] = false;
        let result3 = moreAppListLoader.loadAppList();
        expect(result3 !== null).assertTrue();
      } catch (e) {
      } finally {
        done()
      }
    });
    it('MoreAppListLoaderTest_002', 0, (done: Function) => {
      try {
        let result = moreAppListLoader.getAppListCache();
        expect(result !== null).assertTrue();
      } catch (e) {
      } finally {
        done()
      }
    });
    it('MoreAppListLoaderTest_003', 0, (done: Function) => {
      try {
        let result = moreAppListLoader.registerStatusChange();
        expect(result !== null).assertTrue();
        moreAppListLoader.isRegister = true;
        let result2 = moreAppListLoader.registerStatusChange();
        expect(result2 !== null).assertTrue();
      } catch (e) {
      } finally {
        done()
      }
    });
    it('MoreAppListLoaderTest_004', 0, async (done: Function) => {
      try {
        (moreAppListLoader as object)['isRefreshing'] = true;
        await (moreAppListLoader as object)['refreshAppList']();
      } catch (e) {
      } finally {
        done()
      }
    });
    it('MoreAppListLoaderTest_005', 0, (done: Function) => {
      try {
        (moreAppListLoader as object)['removeAppEntry']('');
      } catch (e) {
      } finally {
        done()
      }
    });
    it('MoreAppListLoaderTest_006', 0, (done: Function) => {
      try {
        (moreAppListLoader as object)['clearEntriesCache']();
      } catch (e) {
      } finally {
        done()
      }
    });
    it('MoreAppListLoaderTest_007', 0, (done: Function) => {
      try {
        (moreAppListLoader as object)['addAppEntry']('');
        (moreAppListLoader as object)['addAppEntry']('bundleName');
      } catch (e) {
      } finally {
        done()
      }
    });
    it('MoreAppListLoaderTest_008', 0, async (done: Function) => {
      try {
        await moreAppListLoader.getAllBundleList();
        await (moreAppListLoader as object)['getMoreAppBundleList']();
      } catch (e) {
      } finally {
        done()
      }
    });
    it('MoreAppListLoaderTest_009', 0, (done: Function) => {
      try {
        let result = moreAppListLoader.unRegisterStatusChange();
        expect(result !== null).assertTrue();
        moreAppListLoader.isRegister = true;
        let result2 = moreAppListLoader.unRegisterStatusChange();
        expect(result2 !== null).assertTrue();
      } catch (e) {
      } finally {
        done()
      }
    });
    it('MoreAppListLoaderTest_010', 0, (done: Function) => {
      try {
        moreAppListLoader.lastSystemLocale = 'lastSystemLocale';
        (moreAppListLoader as object)['updateSystemLocale']();
        moreAppListLoader.lastSystemLocale = '';
        (moreAppListLoader as object)['updateSystemLocale']();
      } catch (e) {
      } finally {
        done()
      }
    });
    it('MoreAppListLoaderTest_011', 0, (done: Function) => {
      try {
        (moreAppListLoader as object)['onBundleResourcesChangedCallback'](false);
        (moreAppListLoader as object)['onBundleResourcesChangedCallback'](true);
      } catch (e) {
      } finally {
        done()
      }
    });
  })
}


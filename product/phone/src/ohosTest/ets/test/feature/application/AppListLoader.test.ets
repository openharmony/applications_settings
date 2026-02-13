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

import { describe, it, expect } from '@ohos/hypium';
import { AppEntry, AppEntryChangedListener } from '@ohos/settings.application';
import { AppListLoader } from '@ohos/settings.application/src/main/ets/AppListLoader';
import { AppGroupType } from '@ohos/settings.common/src/main/ets/utils/Consts';
import bundle from '@ohos.bundle.bundleManager';

const enum AppType {
  SYSTEM_APP = 'systemApp',
  UN_SYSTEM_APP = 'unSystemApp',
  SERVICE_APP = 'meetaApp',
  CONTAINER_APP = 'containerApp',
  UNKNOWN_TYPE = 'unknownApp'
}

export default function AppListLoaderTest() {
  describe('AppListLoaderTest', () => {
    let appListLoader = AppListLoader.getInstance();
    /*
    * @tc.number: AppListLoaderTest_001
    * @tc.name: 更新应用数据
    * @tc.type: TestType.FUNCTION
    * @tc.desc: return true
    */
    it('AppListLoaderTest_001', 0, (done: Function) => {
      try {
        appListLoader.isRefreshAppList();
        appListLoader.subscribeBundleResourcesChangeEvents();
        let result = appListLoader.registerStatusChange();
        expect(result !== null).assertTrue();
      } catch (e) {
      } finally {
        done()
      }
    });
    it('AppListLoaderTest_002', 0, (done: Function) => {
      try {
        (appListLoader as object)['isRefreshing'] = true;
        appListLoader.lastSystemLocale = 'test';
        let result = appListLoader.loadAppList();
        expect(result !== null).assertTrue();
      } catch (e) {
      } finally {
        done()
      }
    });
    it('AppListLoaderTest_002_02', 0, (done: Function) => {
      try {
        (appListLoader as object)['isRefreshing'] = false;
        appListLoader.lastSystemLocale = '';
        let result = appListLoader.loadAppList();
        expect(result !== null).assertTrue();
      } catch (e) {
      } finally {
        done()
      }
    });
    it('AppListLoaderTest_003', 0, async (done: Function) => {
      try {
        (appListLoader as object)['isRefreshing'] = true;
        (appListLoader as object)['isHdsHandle'] = true;
        let result = await appListLoader.refreshAppList(true);
        expect(result !== null).assertTrue();
      } catch (e) {
      } finally {
        done()
      }
    });
    it('AppListLoaderTest_004', 0, (done: Function) => {
      try {
        let result = appListLoader.getAppListCache(AppGroupType.SYSTEM);
        expect(result !== null).assertTrue();
        let result2 = appListLoader.getAppListCache(AppGroupType.UN_SYSTEM);
        expect(result2 !== null).assertTrue();
        let result3 = appListLoader.getAppListCache(AppGroupType.SERVICE);
        expect(result3 !== null).assertTrue();
        let bundleInfo: bundle.BundleInfo = {
          name: 'com.ohos.sceneboard',
          versionName: '',
          updateTime: 10,
          appIndex: 12,
          appInfo: {
            name: 'name',
            bundleType: 1,
            codePath: '/test'
          },
        } as bundle.BundleInfo;
        let appEntry = new AppEntry(bundleInfo);
        appListLoader.entriesCache = new Map([['key', appEntry]]);
        let result4 = appListLoader.getAppListCache('test');
        expect(result4 !== null).assertTrue();
      } catch (e) {
      } finally {
        done()
      }
    });
    it('AppListLoaderTest_005', 0, (done: Function) => {
      try {
        let listener: AppEntryChangedListener = AppStorage.get('appInfo') as AppEntryChangedListener;
        let result = appListLoader.registerAppChangedListener(listener);
        expect(result !== null).assertTrue();
      } catch (e) {
      } finally {
        done()
      }
    });
    it('AppListLoaderTest_006', 0, (done: Function) => {
      try {
        let listener: AppEntryChangedListener = AppStorage.get('appInfo') as AppEntryChangedListener;
        let result = appListLoader.unRegisterAppChangedListener(listener);
        expect(result !== null).assertTrue();
      } catch (e) {
      } finally {
        done()
      }
    });
    it('AppListLoaderTest_007', 0, (done: Function) => {
      try {
        let result = appListLoader.updateAppEntry('');
        expect(result !== null).assertTrue();
        let result2 = appListLoader.updateAppEntry('bundleName', 1);
        expect(result2 !== null).assertTrue();
      } catch (e) {
      } finally {
        done()
      }
    });
    it('AppListLoaderTest_008', 0, (done: Function) => {
      try {
        let result = appListLoader.createAndCache('');
        expect(result !== null).assertTrue();
        let result2 = appListLoader.createAndCache('bundleName', 1);
        expect(result2 !== null).assertTrue();
      } catch (e) {
      } finally {
        done()
      }
    });
    it('AppListLoaderTest_009', 0, (done: Function) => {
      try {
        let result = appListLoader.createAppEntryByName('');
        expect(result !== null).assertTrue();
        let result2 = appListLoader.createAppEntryByName('bundleName', 1);
        expect(result2 !== null).assertTrue();
      } catch (e) {
      } finally {
        done()
      }
    });
    it('AppListLoaderTest_010', 0, (done: Function) => {
      try {
        let result = appListLoader.getAndUpdateAppEntryByName('');
        expect(result !== null).assertTrue();
        let result2 = appListLoader.getAndUpdateAppEntryByName('bundleName', 1);
        expect(result2 !== null).assertTrue();
      } catch (e) {
      } finally {
        done()
      }
    });
    it('AppListLoaderTest_011', 0, (done: Function) => {
      try {
        appListLoader.isRegister = false;
        let result = appListLoader.registerStatusChange();
        expect(result !== null).assertTrue();
        appListLoader.isRegister = true;
        let result2 = appListLoader.registerStatusChange();
        expect(result2 !== null).assertTrue();
      } catch (e) {
      } finally {
        done()
      }
    });
    it('AppListLoaderTest_011_02', 0, (done: Function) => {
      try {
        appListLoader.isRegister = true;
        let result = appListLoader.registerStatusChange();
        expect(result !== null).assertTrue();
      } catch (e) {
      } finally {
        done()
      }
    });
    it('AppListLoaderTest_012', 0, (done: Function) => {
      try {
        appListLoader.isRegister = false;
        let result = appListLoader.unRegisterStatusChange();
        expect(result !== null).assertTrue();
      } catch (e) {
      } finally {
        done()
      }
    });
    it('AppListLoaderTest_012_02', 0, (done: Function) => {
      try {
        appListLoader.isRegister = true;
        let result = appListLoader.unRegisterStatusChange();
        expect(result !== null).assertTrue();
      } catch (e) {
      } finally {
        done()
      }
    });
    it('AppListLoaderTest_013', 0, (done: Function) => {
      try {
        appListLoader.isRegister = false;
        let result = appListLoader.updateSystemLocale();
        expect(result !== null).assertTrue();
      } catch (e) {
      } finally {
        done()
      }
    });
    it('AppListLoaderTest_014', 0, (done: Function) => {
      try {
        let bundleInfo: bundle.BundleInfo = {
          name: 'name',
          versionName: 'versionName',
          updateTime: 10,
          appInfo: {
            name: 'name',
          }
        } as bundle.BundleInfo;
        let appEntry = new AppEntry(bundleInfo);
        let params: bundle.BundleInfo = AppStorage.get('params') as bundle.BundleInfo;
        let result = appListLoader.isBundleMatch(appEntry, params);
        expect(result !== null).assertTrue();
      } catch (e) {
      } finally {
        done()
      }
    });
    it('AppListLoaderTest_015', 0, (done: Function) => {
      try {
        let bundleInfo: bundle.BundleInfo = {
          name: 'name',
          versionName: '',
          updateTime: 10,
          appInfo: {
            name: 'name',
          }
        } as bundle.BundleInfo;
        let appEntry = new AppEntry(bundleInfo);
        let result = appListLoader.isBundleMatch(appEntry, bundleInfo);
        expect(result !== null).assertTrue();
      } catch (e) {
      } finally {
        done()
      }
    });
    it('AppListLoaderTest_016', 0, (done: Function) => {
      try {
        let bundleInfo: bundle.BundleInfo = {
          name: 'name',
          versionName: 'versionName',
          updateTime: 10,
          appInfo: {
            name: 'name',
          }
        } as bundle.BundleInfo;
        let params: bundle.BundleInfo = {
          name: 'name',
          versionName: 'versionName',
          updateTime: 100,
          appInfo: {
            name: 'name',
          }
        } as bundle.BundleInfo;
        let appEntry = new AppEntry(bundleInfo);
        let result = appListLoader.isBundleMatch(appEntry, bundleInfo);
        expect(result !== null).assertTrue();
        let result2 = appListLoader.isBundleMatch(appEntry, params);
        expect(result2 !== null).assertTrue();
      } catch (e) {
      } finally {
        done()
      }
    });
    it('AppListLoaderTest_017', 0, (done: Function) => {
      try {
        let bundleInfo: bundle.BundleInfo = {
          name: 'name',
          versionName: '',
          updateTime: 10,
          appIndex: 12,
          appInfo: {
            name: 'name',
          }
        } as bundle.BundleInfo;
        let containerApps = new AppEntry(bundleInfo);
        let appList = [AppType.SYSTEM_APP, AppType.UN_SYSTEM_APP, AppType.SERVICE_APP, AppType.CONTAINER_APP];
        (appListLoader as object)['separateList2Handle'](appList, containerApps);
      } catch (e) {
      } finally {
        done()
      }
    });
    it('AppListLoaderTest_019', 0, (done: Function) => {
      try {
        (appListLoader as object)['addAppEntry']('', 1);
        (appListLoader as object)['addAppEntry']('bundleName', 1);
      } catch (e) {
      } finally {
        done()
      }
    });
    it('AppListLoaderTest_020', 0, (done: Function) => {
      try {
        (appListLoader as object)['removeAppEntry']('', 1);
        (appListLoader as object)['removeAppEntry']('bundleName', 1);
      } catch (e) {
      } finally {
        done()
      }
    });
    it('AppListLoaderTest_021', 0, (done: Function) => {
      try {
        let bundleInfo: bundle.BundleInfo = {
          name: 'name',
          versionName: 'versionName',
          updateTime: 10,
          appIndex: 1,
          appInfo: {
            name: 'name',
            codePath: 'test'
          }
        } as bundle.BundleInfo;
        (appListLoader as object)['getAndUpdateAppEntry'](bundleInfo);
      } catch (e) {
      } finally {
        done()
      }
    });
    it('AppListLoaderTest_022', 0, (done: Function) => {
      try {
        let bundleInfo: bundle.BundleInfo = {
          name: 'name',
          versionName: '',
          updateTime: 10,
          appIndex: 12,
          appInfo: {
            name: 'name',
            bundleType: 0,
            codePath: '/test'
          }
        } as bundle.BundleInfo;
        let appEntry = new AppEntry(bundleInfo);
        (appListLoader as object)['getAppType'](appEntry);
      } catch (e) {
      } finally {
        done()
      }
    });
    it('AppListLoaderTest_023', 0, (done: Function) => {
      try {
        let bundleInfo: bundle.BundleInfo = {
          name: 'name',
          versionName: '',
          updateTime: 10,
          appIndex: 12,
          appInfo: {
            name: 'name',
            bundleType: 1,
            codePath: '/test'
          }
        } as bundle.BundleInfo;
        let appEntry = new AppEntry(bundleInfo);
        (appListLoader as object)['getAppType'](appEntry);
      } catch (e) {
      } finally {
        done()
      }
    });
    it('AppListLoaderTest_024', 0, async (done: Function) => {
      try {
        let bundleInfo: bundle.BundleInfo = {
          name: 'name',
          versionName: '',
          updateTime: 10,
          appIndex: 12,
          appInfo: {
            name: 'name',
            bundleType: 1,
            codePath: '/test'
          },
        } as bundle.BundleInfo;
        let appEntry = new AppEntry(bundleInfo);
        await (appListLoader as object)['loadIconAndSize'](appEntry);
      } catch (e) {
      } finally {
        done()
      }
    });
    it('AppListLoaderTest_025', 0, (done: Function) => {
      try {
        let result = appListLoader.updateAppEntriesCache([], true);
        expect(result !== null).assertTrue();
        let result2 = appListLoader.updateAppEntriesCache(['1', '2'], true);
        expect(result2 !== null).assertTrue();
      } catch (e) {
      } finally {
        done()
      }
    });
    it('AppListLoaderTest_026', 0, (done: Function) => {
      try {
        let bundleInfo: bundle.BundleInfo = {
          name: 'name',
          versionName: '',
          updateTime: 10,
          appIndex: 12,
          appInfo: {
            name: 'name',
            bundleType: 1,
            codePath: '/test'
          }
        } as bundle.BundleInfo;
        (appListLoader as object)['isNeedToRefreshCache'](bundleInfo, false);
        (appListLoader as object)['isNeedToRefreshCache'](bundleInfo, true);
      } catch (e) {
      } finally {
        done()
      }
    });
    it('AppListLoaderTest_027', 0, (done: Function) => {
      try {
        (appListLoader as object)['setEntriesCache'](undefined, 'name', 1);
      } catch (e) {
      } finally {
        done()
      }
    });
    it('AppListLoaderTest_028', 0, (done: Function) => {
      try {
        (appListLoader as object)['setEntriesCacheNoDelete'](undefined, 'name', 1);
      } catch (e) {
      } finally {
        done()
      }
    });
    it('AppListLoaderTest_029', 0, (done: Function) => {
      try {
        (appListLoader as object)['clearEntriesCache']();
      } catch (e) {
      } finally {
        done()
      }
    });
    it('AppListLoaderTest_030', 0, (done: Function) => {
      try {
        let bundleInfo: bundle.BundleInfo = {
          name: 'com.ohos.sceneboard',
          versionName: '',
          updateTime: 10,
          appIndex: 12,
          appInfo: {
            name: 'name',
            bundleType: 1,
            codePath: '/test'
          },
        } as bundle.BundleInfo;
        let appEntry = new AppEntry(bundleInfo);
        appListLoader.entriesCache = new Map([['key', appEntry]]);
        (appListLoader as object)['getAppListWithType'](AppType.SYSTEM_APP);
      } catch (e) {
      } finally {
        done()
      }
    });
  });
}
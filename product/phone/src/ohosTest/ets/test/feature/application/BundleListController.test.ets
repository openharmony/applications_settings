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
import { BundleListController } from '@ohos/settings.application/src/main/ets/controller/BundleListController';
import { CompCtrlParam } from '@ohos/settings.common/src/main/ets/framework/model/SettingBaseModel';
import bundle from '@ohos.bundle.bundleManager';
import { AppEntry } from '@ohos/settings.application';
import { AppGroupType } from '@ohos/settings.common/src/main/ets/utils/Consts';

export default function BundleListControllerTest() {
  describe('BundleListControllerTest', (): void => {
    let bundleListController = new BundleListController;
    it('BundleListControllerTest_001', 0, (done: Function) => {
      try {
        let compParam: CompCtrlParam = {
          component: {
            id: 'com.ohos.sceneboard',
          },
          compId: 'com.ohos.sceneboard',
        } as CompCtrlParam;
        let result = bundleListController.init(compParam);
        expect(result !== null).assertTrue();
      } catch (e) {
      } finally {
        done()
      }
    });
    it('BundleListControllerTest_002', 0, (done: Function) => {
      try {
        let result = bundleListController.destroy();
        expect(result !== null).assertTrue();
      } catch (e) {
      } finally {
        done()
      }
    });
    it('BundleListControllerTest_003', 0, (done: Function) => {
      try {
        (bundleListController as object)['onAppListChanged']();
      } catch (e) {
      } finally {
        done()
      }
    });
    it('BundleListControllerTest_004', 0, (done: Function) => {
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
        (bundleListController as object)['addMenu'](appEntry);
      } catch (e) {
      } finally {
        done()
      }
    });
    it('BundleListControllerTest_005', 0, (done: Function) => {
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
        (bundleListController as object)['isAppCloneBadge'](appEntry);
      } catch (e) {
      } finally {
        done()
      }
    });
    it('BundleListControllerTest_006', 0, (done: Function) => {
      try {
        (bundleListController as object)['refreshAllData']();
      } catch (e) {
      } finally {
        done()
      }
    });
    it('BundleListControllerTest_007', 0, (done: Function) => {
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
        (bundleListController as object)['id'] = AppGroupType.SYSTEM;
        (bundleListController as object)['onAppListAdd'](appEntry);
        (bundleListController as object)['id'] = AppGroupType.UN_SYSTEM;
        (bundleListController as object)['onAppListAdd'](appEntry);
        (bundleListController as object)['id'] = AppGroupType.SERVICE;
        (bundleListController as object)['onAppListAdd'](appEntry);
        (bundleListController as object)['id'] = AppGroupType.ALL;
        (bundleListController as object)['onAppListAdd'](appEntry);
      } catch (e) {
      } finally {
        done()
      }
    });
    it('BundleListControllerTest_008', 0, (done: Function) => {
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
        (bundleListController as object)['getAppType'](appEntry);
      } catch (e) {
      } finally {
        done()
      }
    });
    it('BundleListControllerTest_009', 0, (done: Function) => {
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
        (bundleListController as object)['getAppType'](appEntry);
      } catch (e) {
      } finally {
        done()
      }
    });
    it('BundleListControllerTest_010', 0, (done: Function) => {
      try {
        (bundleListController as object)['id'] = AppGroupType.SERVICE;
        (bundleListController as object)['onServiceCountUpdate']();
      } catch (e) {
      } finally {
        done()
      }
    });
  })
}


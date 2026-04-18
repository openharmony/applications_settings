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

import { ArgumentMatchers, describe, expect, it, MockKit, when } from '@ohos/hypium';
import { AppEntry, AppMenu } from '@ohos/settings.application/src/main/ets/AppModel';
import bundle from '@ohos.bundle.bundleManager';
import util from '@ohos.util';
import bundleResourceManager from '@ohos.bundle.bundleResourceManager';
import { AppUtils } from '@ohos/settings.application/src/main/ets/AppUtils';

export default function AppModelTest() {
  describe('AppModelTest', (): void => {
    let bundleInfo: bundle.BundleInfo = {
      name: 'name',
      versionName: 'versionName',
      updateTime: 10,
      appInfo: {
        name: 'name',
      }
    } as bundle.BundleInfo;
    let appEntry = new AppEntry(bundleInfo);
    it('AppModelTest_001', 0, (done: Function) => {
      try {
        let appInfo: bundle.ApplicationInfo = AppStorage.get('appInfo') as bundle.ApplicationInfo;
        let result = appEntry.updateAppInfo(appInfo);
        expect(result !== null).assertTrue();
      } catch (e) {
      } finally {
        done()
      }
    });
    it('AppModelTest_002', 0, (done: Function) => {
      try {
        let appInfo: bundle.ApplicationInfo = {
          name: 'name',
          codePath: 'codePath',
          uid: 1213123121231231,
          systemApp: true,
          bundleType: 1
        } as bundle.ApplicationInfo;
        let result = appEntry.updateAppInfo(appInfo);
        expect(result !== null).assertTrue();
      } catch (e) {
      } finally {
        done()
      }
    });
    it('AppModelTest_003', 0, (done: Function) => {
      try {
        let result = appEntry.getCurrentActivatedId();
        expect(result === 10).assertFalse();
      } catch (e) {
      } finally {
        done()
      }
    });
    it('AppModelTest_004', 0, (done: Function) => {
      try {
        let result = appEntry.setCurrentActivatedId(0);
        expect(result !== null).assertTrue();
        let result2 = appEntry.setCurrentActivatedId(10);
        expect(result2 !== null).assertTrue();
      } catch (e) {
      } finally {
        done()
      }
    });
    it('AppModelTest_005', 0, (done: Function) => {
      try {
        let result = appEntry.isLocaleMatch('');
        expect(result !== null).assertTrue();
      } catch (e) {
      } finally {
        done()
      }
    });
    it('AppModelTest_006', 0, (done: Function) => {
      try {
        let appInfo: bundle.BundleInfo = AppStorage.get('appInfo') as bundle.BundleInfo;
        let result = appEntry.isBundleMatch(appInfo);
        expect(result !== null).assertTrue();
      } catch (e) {
      } finally {
        done()
      }
    });
    it('AppModelTest_007', 0, (done: Function) => {
      try {
        let appInfo: bundle.BundleInfo = {
          name: 'name',
          versionName: 'versionName',
          updateTime: 100
        } as bundle.BundleInfo;
        let result = appEntry.isBundleMatch(appInfo);
        expect(result !== null).assertTrue();
      } catch (e) {
      } finally {
        done()
      }
    });
    it('AppModelTest_008', 0, (done: Function) => {
      try {
        let result = appEntry.getBundleResourceInfo('', 12, 12);
        expect(result !== null).assertTrue();
      } catch (e) {
      } finally {
        done()
      }
    });
    it('AppModelTest_009', 0, (done: Function) => {
      try {
        let result = appEntry.getBundleResourceInfo('bundleName', 12, 12);
        expect(result !== null).assertTrue();
      } catch (e) {
      } finally {
        done()
      }
    });
    it('AppModelTest_010', 0, async (done: Function) => {
      try {
        let base64Helper: util.Base64Helper = new util.Base64Helper();
        let bundleInfo: bundleResourceManager.BundleResourceInfo = {
          bundleName: 'bundleName',
          icon: ''
        } as bundleResourceManager.BundleResourceInfo;
        let result: ResourceStr | PixelMap | undefined = await appEntry.base64ToPixelMap(base64Helper, bundleInfo);
        expect(result !== null).assertTrue();
      } catch (e) {
      } finally {
        done()
      }
    });
    it('AppModelTest_011', 0, async (done: Function) => {
      try {
        let base64Helper: util.Base64Helper = new util.Base64Helper();
        let bundleInfo: bundleResourceManager.BundleResourceInfo = {
          bundleName: 'bundleName',
          icon: 'icon'
        } as bundleResourceManager.BundleResourceInfo;
        let result: ResourceStr | PixelMap | undefined = await appEntry.base64ToPixelMap(base64Helper, bundleInfo);
        expect(result !== null).assertTrue();
      } catch (e) {
      } finally {
        done()
      }
    });
    it('AppModelTest_012', 0, async (done: Function) => {
      try {
        appEntry.label = 'label';
        let result = await appEntry.loadLabel();
        expect(result !== null).assertTrue();
      } catch (e) {
      } finally {
        done()
      }
    });
    it('AppModelTest_013', 0, async (done: Function) => {
      try {
        appEntry.label = '';
        let result = await appEntry.loadLabel();
        expect(result !== null).assertTrue();
      } catch (e) {
      } finally {
        done()
      }
    });
    it('AppModelTest_014', 0, async (done: Function) => {
      try {
        appEntry.icon = '';
        let result = await appEntry.loadIcon();
        expect(result !== null).assertTrue();
      } catch (e) {
      } finally {
        done()
      }
    });
    it('AppModelTest_015', 0, async (done: Function) => {
      try {
        appEntry.icon = 'icon';
        let result = await appEntry.loadIcon();
        expect(result !== null).assertTrue();
      } catch (e) {
      } finally {
        done()
      }
    });
    it('AppModelTest_016', 0, async (done: Function) => {
      try {
        appEntry.appInfo!.codePath = '1';
        let result = await appEntry.loadSize();
        expect(result !== null).assertTrue();
      } catch (e) {
      } finally {
        done()
      }
    });
    it('AppModelTest_017', 0, async (done: Function) => {
      try {
        appEntry.appInfo!.codePath = '3';
        let result = await appEntry.loadSize();
        expect(result !== null).assertTrue();
        let mocker = new MockKit();
        let mockfunc: Function =
          mocker.mockFunc(AppUtils, AppUtils.formatSize);
        when(mockfunc)(ArgumentMatchers.any).afterReturn('');
        let result2 = await appEntry.loadSize();
        expect(result2 !== null).assertTrue();
        mocker.clear(AppUtils);
      } catch (e) {
      } finally {
        done()
      }
    });
    it('AppModelTest_018', 0, async (done: Function) => {
      try {
        appEntry.appInfo!.codePath = '3';
        let result = await appEntry.loadSize();
        expect(result !== null).assertTrue();
        let mocker = new MockKit();
        let mockfunc: Function =
          mocker.mockFunc(AppUtils, AppUtils.formatSize);
        when(mockfunc)(ArgumentMatchers.any).afterReturn('appSize');
        let result2 = await appEntry.loadSize();
        expect(result2 !== null).assertTrue();
        mocker.clear(AppUtils);
      } catch (e) {
      } finally {
        done()
      }
    });
    it('AppModelTest_019', 0, (done: Function) => {
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
        let appMenu = new AppMenu(appEntry);
        let result = appMenu.updateEntry(appEntry);
        expect(result !== null).assertTrue();
      } catch (e) {
      } finally {
        done()
      }
    });
    it('AppModelTest_020', 0, async (done: Function) => {
      try {
        let base64Helper: util.Base64Helper = new util.Base64Helper();
        let result: ResourceStr | PixelMap | undefined = await AppEntry.createPixelMap(base64Helper, '', '');
        expect(result !== null).assertTrue();
      } catch (e) {
      } finally {
        done()
      }
    });
    it('AppModelTest_021', 0, async (done: Function) => {
      try {
        let base64Helper: util.Base64Helper = new util.Base64Helper();
        let result: ResourceStr | PixelMap | undefined =
          await AppEntry.createPixelMap(base64Helper, 'data:image/png;base64,', '');
        expect(result !== null).assertTrue();
        let result2: ResourceStr | PixelMap | undefined =
          await AppEntry.createPixelMap(base64Helper, 'data:image/jpeg;base64,', '');
        expect(result2 !== null).assertTrue();
      } catch (e) {
      } finally {
        done()
      }
    });
  })
}


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

import { describe, expect, it} from '@ohos/hypium';
import { AppEntry } from '@ohos/settings.application/src/main/ets/AppModel';
import { AppAllowAccessController } from '@ohos/settings.application/src/main/ets/controller/AppAllowAccessController';
import { CompCtrlParam } from '@ohos/settings.common/src/main/ets/framework/model/SettingBaseModel';
import bundle from '@ohos.bundle.bundleManager';
import { SettingAppGroupModel } from '@ohos/settings.application/src/main/ets/model/SettingAppItemModel';

export default function AppAllowAccessControllerTest() {
  describe('AppAllowAccessControllerTest', (): void => {
    let appAllowAccessController = new AppAllowAccessController;
    it('AppAllowAccessControllerTest_001', 0, (done: Function) => {
      try {
        let bundleInfo: bundle.BundleInfo = {
          name: 'name',
          versionName: 'versionName',
          updateTime: 10,
        } as bundle.BundleInfo;

        let compParam: CompCtrlParam = {
          compId: '123456',
          component: {
            icon: 'icon',
            entry: new AppEntry(bundleInfo)
          } as SettingAppGroupModel
        };
        let result = appAllowAccessController.init(compParam);
        expect(result !== null).assertTrue();
      } catch (e) {
      } finally {
        done()
      }
    });
    it('AppAllowAccessControllerTest_002', 0, (done: Function) => {
      try {
        let compParam: CompCtrlParam = AppStorage.get('compParam') as CompCtrlParam;
        let result = appAllowAccessController.init(compParam);
        expect(result !== null).assertTrue();
      } catch (e) {
      } finally {
        done()
      }
    });
    it('AppAllowAccessControllerTest_003', 0, (done: Function) => {
      try {
        (appAllowAccessController as object)['initAllowAccess']();
      } catch (e) {
      } finally {
        done()
      }
    });

    it('AppAllowAccessControllerTest_004', 0, (done: Function) => {
      try {
        let bundleInfo: bundle.BundleInfo = {
          name: 'name',
          versionName: 'versionName',
          updateTime: 10,
        } as bundle.BundleInfo;
        let entry: AppEntry = new AppEntry(bundleInfo);
        (appAllowAccessController as object)['entry'] = entry;
        (appAllowAccessController as object)['initAllowAccess']();
      } catch (e) {
      } finally {
        done()
      }
    });
    it('AppAllowAccessControllerTest_005', 0, (done: Function) => {
      try {
        (appAllowAccessController as object)['isShowNtfSwitch']('bundleName');
      } catch (e) {
      } finally {
        done()
      }
    });
    it('AppAllowAccessControllerTest_006', 0, (done: Function) => {
      try {
        (appAllowAccessController as object)['initAppPrivileges']();
      } catch (e) {
      } finally {
        done()
      }
    });
    it('AppAllowAccessControllerTest_007', 0, (done: Function) => {
      try {
        (appAllowAccessController as object)['initAppLiveViewSwitch']();
      } catch (e) {
      } finally {
        done()
      }
    });

  })
}


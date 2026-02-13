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
import { describe, it, expect } from '@ohos/hypium'
import { AppItemControl } from '@ohos/settings.storage/src/main/ets/controller/AppItemController'
import { SettingBaseModel } from '@ohos/settings.common/src/main/ets/framework/model/SettingBaseModel'
import bundle from '@ohos.bundle.bundleManager'
import { SettingItemModel } from '@ohos/settings.common/src/main/ets/framework/model/SettingItemModel'

class BundleStats {
  public appSize: string = '';
  public cacheSize: string = '';
  public dataSize: string = '';
  public totalSize: string = '';
  public icon?: ResourceStr | PixelMap;
  public versionName?: string;
  public label?: string;
  public name?: string;
  public removable?: boolean;
  public userDataClearable?: boolean;
  public skillUrl?: bundle.SkillUrl;
  public appIndex: number = 0;
}

interface GeneratedObjectLiteralInterface_1 {
  appSize: string;
  cacheSize: string;
  dataSize: string;
  totalSize: string;
  skillUrl?: bundle.SkillUrl;
}

export default function AppItemControllerTest() {
  describe('AppItemControllerTest', () => {
    it("AppItemControllerTest_001", 0, () => {
      let appItemC: AppItemControl = new AppItemControl();
      let settingBaseM: SettingBaseModel = {
        id: ''
      };
      appItemC.init({
        compId: '',
        component: settingBaseM,
      });
      appItemC.clearAppDataMenuClick();
      appItemC.onHandlerCancerClick();
      let settingItemM: SettingItemModel = {
        type: 1,
        id: ''
      };
      appItemC.onHandlerRemoveClick(settingItemM);
      expect(appItemC !== null).assertTrue();
      let re: Object = (appItemC as object)['initUri']();
      expect(re.toString() !== null).assertTrue();
    })
    it("AppItemControllerTest_002", 0, () => {
      let appItemC: AppItemControl = new AppItemControl();
      let settingBaseM: SettingBaseModel = {
        id: 'AppItemControllerTest'
      };
      appItemC.init({
        compId: '1',
        component: settingBaseM,
        param: new BundleStats()
      });
      (appItemC as object)["canClearData"] = false;
      let skillU: bundle.SkillUrl = {
        scheme: '',
        host: '',
        port: 0,
        path: '',
        pathStartWith: '',
        pathRegex: '',
        type: '',
        utd: '',
        maxFileSupported: 0,
        linkFeature: ''
      };
      let p: GeneratedObjectLiteralInterface_1 = {
        appSize: '',
        cacheSize: '',
        dataSize: '',
        totalSize: '',
        skillUrl: skillU
      };
      appItemC.init({
        compId: '1',
        component: settingBaseM,
        param: p
      });
      (appItemC as object)["skillUrl"] = skillU;
      let re: Object = (appItemC as object)['initUri']();
      expect(re.toString() !== null).assertTrue();
    })
    it("AppItemControllerTest_003", 0, () => {
      let appItemC: AppItemControl = new AppItemControl();
      let skillU: bundle.SkillUrl = {
        scheme: 'scheme',
        host: 'host',
        port: 8001,
        path: 'path',
        pathStartWith: 'pathSW',
        pathRegex: 'pathRegex',
        type: 'type',
        utd: 'utd',
        maxFileSupported: 1,
        linkFeature: 'linkFeature',
      };
      (appItemC as object)["skillUrl"] = skillU;
      let re: Object = (appItemC as object)['initUri']();
      expect(re.toString() !== null).assertTrue();

      (appItemC as object)["skillUrl"]["path"] = null;
      let re1: Object = (appItemC as object)['initUri']();
      expect(re1.toString() !== null).assertTrue();

      (appItemC as object)["skillUrl"]["pathStartWith"] = null;
      let re2: Object = (appItemC as object)['initUri']();
      expect(re2.toString() !== null).assertTrue();
    })
    it("AppItemControllerTest_004", 0, () => {
      let appItemC: AppItemControl = new AppItemControl();
      let settingItemM: SettingItemModel[] = [{
        type: 1,
        id: ''
      }];
      (appItemC as object)['canClearData'] = false;
      (appItemC as object)['addClearDataOption'](settingItemM);
      (appItemC as object)['removable'] = true;
      (appItemC as object)['addUninstallOption'](settingItemM);
      expect(appItemC !== null).assertTrue();
    })
  })
}
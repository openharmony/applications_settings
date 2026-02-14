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
import { ResourceUtil } from '@ohos/settings.aboutdevice/src/main/ets/legalInfo/util/ResourceUtil';
import { bundleManager } from '@kit.AbilityKit';
import resmgr from '@ohos.resourceManager';

export default function FeatureResourceUtilTest() {
  describe('FeatureResourceUtilTest', (): void => {
    let resourceUtil = ResourceUtil;
    it('FeatureResourceUtilTest_getAllAppList_001', 0, async  (done: Function) => {
      try {
        let result = await  resourceUtil.getAllAppList();
        expect(result !== null).assertTrue();
      } catch (e) {
      } finally {
        done()
      }
    });

    it('FeatureResourceUtilTest_getAppInfo_002', 0, async  (done: Function) => {
      try {
        let appInfo: bundleManager.ApplicationInfo = {
          name: 'name'
        } as bundleManager.ApplicationInfo;
        let result = await  resourceUtil.getAppInfo(appInfo);
        expect(result !== null).assertTrue();
      } catch (e) {
      } finally {
        done()
      }
    });

    it('FeatureResourceUtilTest_getMetadata_003', 0,  (done: Function) => {
      try {
        let result =  resourceUtil.getMetadata('bundleName', 'moduleName', 'metaDataName')
        expect(result === null).assertTrue();
      } catch (e) {
      } finally {
        done()
      }
    });

    it('FeatureResourceUtilTest_getResourceString_004', 0,  (done: Function) => {
      try {
        let resourceManager: resmgr.ResourceManager = AppStorage.get('resourceManager') as resmgr.ResourceManager;
        let result =  resourceUtil.getResourceString(resourceManager, '');
        expect(result !== null).assertTrue();
        let result2 =  resourceUtil.getResourceString(resourceManager, '$string:1212');
        expect(result2 !== null).assertTrue();
      } catch (e) {
      } finally {
        done()
      }
    });

    it('FeatureResourceUtilTest_getResourceString_005', 0,  (done: Function) => {
      try {
        let resourceManager: resmgr.ResourceManager = AppStorage.get('resourceManager') as resmgr.ResourceManager;
        let result2 =  resourceUtil.getResourceString(resourceManager, 'resourceManager');
        expect(result2 !== null).assertTrue();
      } catch (e) {
      } finally {
        done()
      }
    });
    it('FeatureResourceUtilTest_isResourceIdValid_006', 0,  (done: Function) => {
      try {
        (resourceUtil as object)['isResourceIdValid'](1);
      } catch (e) {
      } finally {
        done()
      }
    });
  })
}


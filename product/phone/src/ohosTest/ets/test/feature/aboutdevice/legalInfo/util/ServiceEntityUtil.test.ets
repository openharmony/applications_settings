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
import { ServiceEntity } from '@ohos/settings.aboutdevice';
import { ServiceEntityUtil } from '@ohos/settings.aboutdevice/src/main/ets/legalInfo/util/ServiceEntityUtil';
import { bundleManager } from '@kit.AbilityKit';
import { ResourceUtil } from '@ohos/settings.aboutdevice/src/main/ets/legalInfo/util/ResourceUtil';
import { ProtocolContent } from '@ohos/settings.aboutdevice/src/main/ets/legalInfo/model/ProtocolContent';
import resmgr from '@ohos.resourceManager';

export default function ServiceEntityUtilTest() {
  describe('ServiceEntityUtilTest', (): void => {
    let serviceEntityUtil = ServiceEntityUtil;
    it('ServiceEntityUtilTest_genServiceEntity_001', 0, async (done: Function) => {
      try {
        let serviceEntityParam: ServiceEntity = new ServiceEntity;
        let metadata: bundleManager.Metadata | null = null;
        let mocker = new MockKit();
        let mockfunc: Function =
          mocker.mockFunc(ResourceUtil, ResourceUtil.getMetadata);
        when(mockfunc)(ArgumentMatchers.any).afterReturn(metadata);
        let result = await serviceEntityUtil.genServiceEntity(serviceEntityParam);
        expect(result === null).assertTrue();
        mocker.clear(ResourceUtil);
      } catch (e) {
      } finally {
        done()
      }
    });
    it('ServiceEntityUtilTest_genServiceEntity_002', 0, async (done: Function) => {
      try {
        let serviceEntityParam: ServiceEntity = new ServiceEntity;
        let metadata: bundleManager.Metadata = {
          value: ''
        } as bundleManager.Metadata;
        let mocker = new MockKit();
        let mockfunc: Function =
          mocker.mockFunc(ResourceUtil, ResourceUtil.getMetadata);
        when(mockfunc)(ArgumentMatchers.any).afterReturn(metadata);
        let result = await serviceEntityUtil.genServiceEntity(serviceEntityParam);
        expect(result === null).assertTrue();
        mocker.clear(ResourceUtil);
      } catch (e) {
      } finally {
        done()
      }
    });
    it('ServiceEntityUtilTest_genServiceEntity_003', 0, async (done: Function) => {
      try {
        let serviceEntityParam: ServiceEntity = new ServiceEntity;
        let metadata: bundleManager.Metadata = {
          value: 'value'
        } as bundleManager.Metadata;
        let mocker = new MockKit();
        let mockfunc: Function =
          mocker.mockFunc(ResourceUtil, ResourceUtil.getMetadata);
        when(mockfunc)(ArgumentMatchers.any).afterReturn(metadata);
        let result = await serviceEntityUtil.genServiceEntity(serviceEntityParam);
        expect(result === null).assertTrue();
        mocker.clear(ResourceUtil);
      } catch (e) {
      } finally {
        done()
      }
    });
    it('ServiceEntityUtilTest_genServiceEntity_004', 0, async (done: Function) => {
      try {
        let serviceEntityParam: ServiceEntity = new ServiceEntity;
        let metadata: bundleManager.Metadata = {
          value: 'rawfile:1212.json'
        } as bundleManager.Metadata;
        let mocker = new MockKit();
        let mockfunc: Function =
          mocker.mockFunc(ResourceUtil, ResourceUtil.getMetadata);
        when(mockfunc)(ArgumentMatchers.any).afterReturn(metadata);
        let result = await serviceEntityUtil.genServiceEntity(serviceEntityParam);
        expect(result === null).assertTrue();
        mocker.clear(ResourceUtil);
      } catch (e) {
      } finally {
        done()
      }
    });
    it('ServiceEntityUtilTest_genProtocolContent_005', 0, (done: Function) => {
      try {
        let serviceEntity: ServiceEntity | null = AppStorage.get('serviceEntity') as ServiceEntity;
        let protocolObj: ProtocolContent = AppStorage.get('protocolObj') as ProtocolContent;
        let serviceEntityParam: resmgr.ResourceManager = {} as resmgr.ResourceManager;
        let result = serviceEntityUtil.genProtocolContent(serviceEntity, protocolObj, serviceEntityParam);
        expect(result !== null).assertTrue();
        let serviceEntity2: ServiceEntity = new ServiceEntity;
        let protocolObj2: ProtocolContent = new ProtocolContent;
        let result2 = serviceEntityUtil.genProtocolContent(serviceEntity2, protocolObj2, serviceEntityParam);
        expect(result2 !== null).assertTrue();
      } catch (e) {
      } finally {
        done()
      }
    });
  })
}


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

import bundleManager from '@ohos.bundle.bundleManager';
import resmgr from '@ohos.resourceManager';
import { LogUtil } from '@ohos/settings.common/src/main/ets/utils/LogUtil';
import { RawFileUtil } from '@ohos/settings.common/src/main/ets/utils/RawFileUtil';
import { MemoryMgrUtils } from '@ohos/settings.common/src/main/ets/utils/MemoryMgrUtils';
import { ResourceManagerUtil } from '@ohos/settings.common/src/main/ets/utils/ResourceManagerUtil';
import { ServiceEntity } from '../model/ServiceEntity';
import { ProtocolContent } from '../model/ProtocolContent';
import { StringUtil } from './StringUtil';
import { ArrayUtil } from './ArrayUtil';
import { ResourceUtil } from './ResourceUtil';

const TAG: string = 'ServiceEntityUtil';
const RAWFILE: string = 'rawfile:';
const JSON_SUFFIX: string = 'json';

/**
 * 服务声明工具类
 */
export class ServiceEntityUtil {
  /**
   * 获取服务声明信息
   * @param serviceEntityParam 服务实体
   * @returns 服务实体列表
   */
  public static async genServiceEntity(serviceEntityParam: ServiceEntity): Promise<ServiceEntity | null> {
    try {
      let serviceEntity: ServiceEntity = new ServiceEntity();
      serviceEntity.setPackageName(serviceEntityParam.packageName);
      serviceEntity.setModuleName(serviceEntityParam.moduleName);
      serviceEntity.setServiceType(serviceEntityParam.serviceType);
      serviceEntity.setServiceName(serviceEntityParam.serviceName);
      LogUtil.info(`${TAG} genServiceEntity begin. serviceName:${serviceEntity.getServiceName()}`);
      let metadata: bundleManager.Metadata | null = ResourceUtil.getMetadata(serviceEntity.getPackageName(),
        serviceEntity.getModuleName(), serviceEntity.getServiceName());
      if (metadata === null || StringUtil.isEmpty(metadata.value)) {
        LogUtil.error(`${TAG} metadata value is null`);
      }
      if (!metadata?.value.startsWith(RAWFILE) || !metadata?.value.endsWith(JSON_SUFFIX)) {
        LogUtil.error(`${TAG} metadata value is invalid, metadata.value:${metadata?.value}`);
      }
      let fileName = metadata?.value.substr(RAWFILE.length, metadata?.value.length - RAWFILE.length) as string;
      let resourceManager = ResourceManagerUtil.getBundleResourceManager(serviceEntity.getPackageName()) as
        resmgr.ResourceManager;
      let jsonContent = await RawFileUtil.getStringByFile(resourceManager, fileName);
      let protocolObj: ProtocolContent = JSON.parse(jsonContent);
      ServiceEntityUtil.genProtocolContent(serviceEntity, protocolObj, resourceManager);
      MemoryMgrUtils.removeNapiWrap(resourceManager, false);
      return serviceEntity;
    } catch (error) {
      LogUtil.error(`${TAG} genServiceEntity error: ${error?.message}`);
      return null;
    }
  }

  /**
   * 解析外部应用的协议配置文件
   * @param serviceEntity
   * @param protocolObj
   * @param resourceManager
   */
  public static genProtocolContent(
    serviceEntity: ServiceEntity, protocolObj: ProtocolContent, resourceManager: resmgr.ResourceManager): void {
    if (!serviceEntity || !protocolObj) {
      return;
    }
    try {
      serviceEntity.setVersion(Number.parseFloat(protocolObj.version));
      serviceEntity.setTitle(ResourceUtil.getResourceString(resourceManager, protocolObj.title));
      serviceEntity.setContent(ResourceUtil.getResourceString(resourceManager, protocolObj.content));
      if (ArrayUtil.isNotEmpty(protocolObj.params)) {
        for (let item of protocolObj.params) {
          if (item) {
            let paramValue: string = ResourceUtil.getResourceString(resourceManager, item.value);
            serviceEntity.addParamValue(item.name, paramValue);
          }
        }
      }

      if (ArrayUtil.isNotEmpty(protocolObj.abilities)) {
        for (let obj of protocolObj.abilities) {
          if (obj) {
            serviceEntity.addAbility(obj.key, obj.value);
          }
        }
      }
    } catch (error) {
      LogUtil.error(`${TAG} genProtocolContent error:${error?.errorMsg} ${serviceEntity?.getServiceName()}`);
    }
  }
}
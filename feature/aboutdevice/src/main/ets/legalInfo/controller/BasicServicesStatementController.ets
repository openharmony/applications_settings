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

import { RawFileUtil } from '@ohos/settings.common/src/main/ets/utils/RawFileUtil';
import { LogUtil } from '@ohos/settings.common/src/main/ets/utils/LogUtil';
import { ServiceEntity } from '../model/ServiceEntity';
import { ServiceEntityUtil } from '../util/ServiceEntityUtil';
/* instrument ignore file */
const BASIC_SERVICE_CONTROLLER_TAG: string = 'BasicServicesStatementController';
const TAG = 'BasicServicesStatementController：'

/**
 * 基础服务声明控制器
 *
 * @since 2023-09-12
 */
class BasicServicesStatementController {
  private mConfigFileName: string = 'basic_service_statements.json';

  /**
   * 初始化基础服务声明列表
   * @returns 服务实体列表
   */
  public async initBasicServiceList(): Promise<Array<ServiceEntity>> {
    let rawContent = await RawFileUtil.getStringByFile(AppStorage.get<Context>('pageContext')?.resourceManager, this.mConfigFileName);
    if (rawContent) {
      let serviceEntities: ServiceEntity[] = [];
      try {
        serviceEntities = JSON.parse(rawContent);
      } catch (err) {
        LogUtil.error(`${TAG} initBasicServiceList error code：${err?.code} msg: ${err?.message}`);
      }
      LogUtil.info(`${TAG} ${BASIC_SERVICE_CONTROLLER_TAG}, serviceEntities`);
      let basicServiceList: ServiceEntity[] = [];
      for (let item of serviceEntities) {
        let basicService: ServiceEntity | null = await ServiceEntityUtil.genServiceEntity(item);
        if (basicService) {
          basicServiceList.push(basicService);
        }
      }
      return basicServiceList;
    }
    return [];
  }
}

export default new BasicServicesStatementController();


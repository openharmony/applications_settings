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

import { Controller } from '@ohos/settings.common/src/main/ets/core/controller/Controller';
import { SettingsBaseMenu } from '@ohos/settings.common/src/main/ets/core/model/menu/SettingsMenu';
import { MenuController } from '@ohos/settings.common/src/main/ets/core/controller/MenuController';
import { PageRouter } from '@ohos/settings.common/src/main/ets/framework/common/PageRouter';
import { NavEntryKey } from '@ohos/settings.common/src/main/ets/utils/Consts';
import { HiSysEventUtil } from '@ohos/settings.common/src/main/ets/systemEvent/HiSysEventUtil';
import { HiSysSystemEventGroup } from '@ohos/settings.common/src/main/ets/systemEvent/BehaviorEventConsts';
import { RawFileUtil } from '@ohos/settings.common/src/main/ets/utils/RawFileUtil';
import { LogUtil } from '@ohos/settings.common/src/main/ets/utils/LogUtil';
/* instrument ignore file */
export class LinkEntity {
  public linkValue: string = '';
}

export async function getNetworkNavigatorLink(): Promise<string> {
  let rawContent = await RawFileUtil.getStringByFile(AppStorage.get<Context>('pageContext')?.resourceManager,
    'network_navigator_links.json');
  if (!rawContent) {
    LogUtil.warn(`getNetworkNavigator rawContent empty`);
    return '';
  }
  let linkEntities: LinkEntity[] = [];
  try {
    linkEntities = JSON.parse(rawContent);
  } catch (err) {
    LogUtil.error(`getNetworkNavigator linkEntities error code��${err?.code} msg: ${err?.message}`);
    return '';
  }
  if (linkEntities[0]) {
    LogUtil.info(`getNetworkNavigatorLink, serviceEntities ${linkEntities[0].linkValue}`);
    return linkEntities[0].linkValue;
  }
  LogUtil.warn(`getNetworkNavigatorLink empty`);
  return '';
}

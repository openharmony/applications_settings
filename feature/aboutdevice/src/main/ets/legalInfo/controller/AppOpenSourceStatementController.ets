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

import intl from '@ohos.intl';
import taskpool from '@ohos.taskpool';
import { LogUtil } from '@ohos/settings.common/src/main/ets/utils/LogUtil';
import { AppInfo } from '../model/AppInfo';
import { ResourceUtil } from '../util/ResourceUtil';

const TAG: string = 'AppOpenSourceStatementController';

@Concurrent
function sortByName(data: AppInfo[]): AppInfo[] {
  let compare: (firstEntry: AppInfo, secondEntry: AppInfo) =>
  number = (firstEntry: AppInfo, secondEntry: AppInfo): number => {
    let collator = new intl.Collator();
    return collator.compare(firstEntry.label.toString(), secondEntry.label.toString());
  }
  data.sort((firstItem, secondItem) => {
    return compare(firstItem, secondItem);
  });
  return data;
}

/**
 * 应用开源声明控制器
 *
 * @since 2023-09-12
 */
class AppOpenSourceStatementController {
  /**
   * 获取所有应用信息
   * @returns 应用信息列表
   */
  public async getAllAppList(): Promise<Array<AppInfo>> {
    LogUtil.info(`${TAG} start to getAllAppInfo`);
    let appInfoList: AppInfo[] = await ResourceUtil.getAllAppList();
    let task: taskpool.Task = new taskpool.Task(sortByName, appInfoList);
    try {
      appInfoList = await taskpool.execute(task, taskpool.Priority.MEDIUM) as AppInfo[];
    } catch (error) {
      LogUtil.error(`${TAG} catch exception when sorting, errmsg: ${error?.message}`);
    }
    return appInfoList;
  }
}

export default new AppOpenSourceStatementController();
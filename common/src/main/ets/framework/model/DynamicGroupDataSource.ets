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

import { LogUtil } from '../../utils/LogUtil';
import { BaseDataSource } from './BaseDataSource';
import { SettingGroupModel, GroupType } from './SettingGroupModel';
import { SettingItemModel } from './SettingItemModel';

const TAG: string = 'DynamicGroupDataSource';

export class DynamicGroupDataSource extends BaseDataSource<SettingGroupModel> {
  public pushData(...groups: SettingGroupModel[]): number {
    return this.push(...groups);
  }

  /**
   * 动态添加 group 时同步删除不需要显示的 item 项
   *
   * @param groups 待添加的groups
   * @returns 添加的数量
   */
  public pushAndFilterItems(...groups: SettingGroupModel[]): number {
    let itemModels: SettingItemModel[] | undefined;
    for (let groupIndex = 0; groupIndex < groups.length; groupIndex++) {
      if (groups[groupIndex].type === GroupType.GROUP_TYPE_DYNAMIC_LAZY) {
        continue;
      }
      itemModels = groups[groupIndex].items;
      if (!itemModels || itemModels?.length == 0) {
        groups.splice(groupIndex, 1);
        groupIndex--;
        continue;
      }
      for (let itemIndex = 0; itemIndex < itemModels.length; itemIndex++) {
        if (itemModels[itemIndex]?.needHide?.()) {
          LogUtil.showInfo(TAG, `remove item id: ${itemModels[itemIndex].id}`);
          itemModels.splice(itemIndex, 1);
          itemIndex--;
        }
      }
      // 如果所有的item项都不需要显示，对应的group也去除掉
      if (itemModels.length == 0) {
        groups.splice(groupIndex, 1);
        groupIndex--;
      }
    }
    return this.push(...groups);
  }

  public removeData(data: SettingGroupModel): void {
    this.removeDataById(data.id);
  }

  public removeDataById(id: string): void {
    let index = this.findIndex((value: SettingGroupModel) => {
      return id === value.id;
    })

    if (index < 0) {
      return;
    }
    this.splice(index, 1);
  }

  public insertData(index: number, data: SettingGroupModel): void {
    if (index > this.length) {
      return;
    }
    this.splice(index, 0, data);
  }
}
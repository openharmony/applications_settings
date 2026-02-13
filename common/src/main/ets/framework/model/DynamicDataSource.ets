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

import { SettingItemModel } from './SettingItemModel';
import { BaseDataSource } from './BaseDataSource';
import { SettingCompState, SettingStateType } from './SettingStateModel';

export class DynamicDataSource extends BaseDataSource<SettingItemModel> {
  public pushData(...items: SettingItemModel[]): number {
    if (this.length > 0) {
      this[this.length - 1].onItemEvent?.(new Map([[
        SettingStateType.STATE_TYPE_ITEM_POS, { state: false } as SettingCompState
      ]]));
    }
    return this.push(...items);
  }

  public removeData(data: SettingItemModel): void {
    this.removeDataById(data.id);
  }

  public removeDataById(id: string): void {
    let index = this.findIndex((value: SettingItemModel) => {
      return id === value.id;
    })

    if (index < 0) {
      return;
    }
    if (index === this.length - 1) {
      this[index - 1]?.onItemEvent?.(new Map([[
        SettingStateType.STATE_TYPE_ITEM_POS, { state: true } as SettingCompState
      ]]));
    }
    if (index === 0) {
      this[1]?.onItemEvent?.(new Map([[
        SettingStateType.STATE_TYPE_ITEM_IS_GROUP_START, { state: true } as SettingCompState
      ]]));
    }
    this.splice(index, 1);
  }

  public insertData(index: number, data: SettingItemModel): void {
    if (index > this.length) {
      return;
    }
    if (index === this.length && index > 0) {
      this[index - 1]?.onItemEvent?.(new Map([[
        SettingStateType.STATE_TYPE_ITEM_POS, { state: false } as SettingCompState
      ]]));
    }
    if (index === 0) {
      this[0]?.onItemEvent?.(new Map([[
        SettingStateType.STATE_TYPE_ITEM_IS_GROUP_START, { state: false } as SettingCompState
      ]]));
    }
    this.splice(index, 0, data);
  }
}
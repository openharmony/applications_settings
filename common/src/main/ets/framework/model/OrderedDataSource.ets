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

import { ComparableSettingItemModel } from './SettingItemModel';
import { LazyDataSource } from './LazyDataSource';
import { SettingCompState, SettingStateType } from './SettingStateModel';

export class OrderedDataSource extends LazyDataSource<ComparableSettingItemModel> {
  public getDataIndex(data: ComparableSettingItemModel): number {
    return this.findIndex((item: ComparableSettingItemModel) => {
      return item.id === data.id;
    });
  }

  private getInsertIndex(data: ComparableSettingItemModel): number {
    if (!data.compare) {
      return this.totalCount();
    }

    let index: number = 0;
    for (; index < this.totalCount(); index++) {
      const item = this.getData(index);
      if (data.compare(item) > 0) {
        return index
      }
    }
    return index;
  }

  public insertData(index: number, data: ComparableSettingItemModel): void {
    if (index > this.totalCount()) {
      return;
    }
    if (index === this.totalCount() && index > 0) {
      this.getData(index - 1)?.onItemEvent?.(new Map([[
        SettingStateType.STATE_TYPE_ITEM_POS, { state: false } as SettingCompState
      ]]));
    }
    if (index === 0) {
      this.getData(0)?.onItemEvent?.(new Map([[
        SettingStateType.STATE_TYPE_ITEM_IS_GROUP_START, { state: false } as SettingCompState
      ]]));
    }
    this.splice(index, 0, data);
    this.notifyDataAdd(index);
  }

  public pushData(data: ComparableSettingItemModel): void {
    let index = this.getInsertIndex(data);
    if (index === this.totalCount()) {
      this.getData(index - 1)?.onItemEvent?.(new Map([[
        SettingStateType.STATE_TYPE_ITEM_POS, { state: false } as SettingCompState
      ]]));
    }
    if (index === 0) {
      this.getData(0)?.onItemEvent?.(new Map([[
        SettingStateType.STATE_TYPE_ITEM_IS_GROUP_START, { state: false } as SettingCompState
      ]]));
    }
    this.splice(index, 0, data);
    this.notifyDataAdd(index);
  }

  public pushDataArrayToEnd(index: number, dataArray: ComparableSettingItemModel[]): void {
    if (dataArray.length <= 0) {
      return;
    }
    this.push(...dataArray);
    this.notifyDataAdd(index);
  }

  public pushDataArray(dataArray: ComparableSettingItemModel[]): void {
    dataArray.forEach((data: ComparableSettingItemModel) => {
      let index = this.getInsertIndex(data);
      if (index === this.totalCount()) {
        this.getData(index - 1)?.onItemEvent?.(new Map([[
          SettingStateType.STATE_TYPE_ITEM_POS, { state: false } as SettingCompState
        ]]));
      }
      if (index === 0) {
        this.getData(0)?.onItemEvent?.(new Map([[
          SettingStateType.STATE_TYPE_ITEM_IS_GROUP_START, { state: false } as SettingCompState
        ]]));
      }
      this.splice(index, 0, data);
    })
    this.notifyDataReload();
  }

  public removeDataByIndex(index: number): void {
    if (this.length <= index) {
      return;
    }
    if (index === this.length - 1) {
      this.getData(index - 1)?.onItemEvent?.(new Map([[
        SettingStateType.STATE_TYPE_ITEM_POS, { state: true } as SettingCompState
      ]]));
    }
    if (index === 0) {
      this.getData(1)?.onItemEvent?.(new Map([[
        SettingStateType.STATE_TYPE_ITEM_IS_GROUP_START, { state: true } as SettingCompState
      ]]));
    }
    this.splice(index, 1);
    this.notifyDataDelete(index);
  }

  public removeData(data: ComparableSettingItemModel): void {
    const index: number = this.getDataIndex(data);
    if (index < 0) {
      return;
    }
    if (index === this.length - 1) {
      this.getData(index - 1)?.onItemEvent?.(new Map([[
        SettingStateType.STATE_TYPE_ITEM_POS, { state: true } as SettingCompState
      ]]));
    }
    if (index === 0) {
      this.getData(1)?.onItemEvent?.(new Map([[
        SettingStateType.STATE_TYPE_ITEM_IS_GROUP_START, { state: true } as SettingCompState
      ]]));
    }
    this.splice(index, 1);
    this.notifyDataDelete(index);
  }

  public removeAll(): void {
    if (this.length <= 0) {
      return;
    }
    this.splice(0, this.length);
    this.notifyDataReload();
  }
}
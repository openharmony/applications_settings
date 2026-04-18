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
import { SearchItemOperation } from '@ohos/settings.common/src/main/ets/data/types';

export class UpdateSearchItemsModel {
  /**
   * 业务方id
   */
  public businessId: string = '';
  /**
   * 所要修改的搜索项的包名
   */
  public bundleName: string = '';

  public setBundleName(value: string) {
    this.bundleName = value;
  }

  public getBundleName(): string {
    return this.bundleName;
  }

  /**
   * 操作的搜索项
   */
  public itemList: Array<SearchItemOperation | string> = [];

  public setBusinessId(value: string) {
    this.businessId = value;
  }

  public getBusinessId(): string {
    return this.businessId;
  }

  public getItemList(): Array<SearchItemOperation | string> {
    return this.itemList;
  }

  public setItemList(itemList: Array<SearchItemOperation | string>): void {
    this.itemList = itemList;
  }
}
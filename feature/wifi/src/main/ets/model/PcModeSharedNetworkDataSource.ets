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

import { LogUtil } from '@ohos/settings.common/src/main/ets/utils/LogUtil';
import { LazyDataSource } from '@ohos/settings.common/src/main/ets/framework/model/LazyDataSource';
import { NetworkState } from '../controller/new/PcModeSharedNetworkController';
import { SharedNetworkMenu } from './SharedNetworkPanelModel';

const TAG: string = 'PcModeSharedNetworkDataSource : ';

export class PcModeSharedNetworkDataSource extends LazyDataSource<SharedNetworkMenu> implements IDataSource {
  private dataArray: SharedNetworkMenu[] = [];

  public totalCount(): number {
    return this.dataArray.length;
  }

  public getArray(): SharedNetworkMenu[] {
    return this.dataArray;
  }

  public getData(index: number): SharedNetworkMenu {
    return this.dataArray[index];
  }

  public removeDataByIndex(index: number): void {
    if (this.dataArray.length <= index) {
      return;
    }

    this.dataArray.splice(index, 1);
    this.notifyDataDelete(index);
  }

  public updateData(index: number, newData: SharedNetworkMenu): void {
    if (this.dataArray.length <= index) {
      return;
    }
    this.dataArray[index] = newData;
    this.notifyDataChange(index);
  }

  public addData(index: number, data: SharedNetworkMenu): void {
    this.dataArray.splice(index, 0, data);
    this.notifyDataAdd(index);
  }

  public pushData(data: SharedNetworkMenu): void {
    this.dataArray.push(data);
    this.notifyDataAdd(this.dataArray.length - 1);
  }

  public updateManus(updateMenus: Array<SharedNetworkMenu>): void {
    this.dataArray = [];
    if (!updateMenus || updateMenus.length === 0) {
      LogUtil.info(`${TAG} updateMenus empty`);
      return;
    }

    for (let updateMenu of updateMenus) {
      if(updateMenu) {
        updateMenu.networkState === NetworkState.ACTIVE ?
          this.addData(0, updateMenu) : this.pushData(updateMenu);
      }
    }
  }

  public clearAll(): void {
    this.dataArray.length = 0;
  }
}
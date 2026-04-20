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

import { GroupType, SettingGroupModel } from '../model/SettingGroupModel';
import { EventBus } from '../common/EventBus';
import { LogHelper } from '../common/LogHelper';
import {
  SettingBaseState,
  SettingCompState,
  SettingStandardGroupItemsChange,
  SettingStateType
} from '../model/SettingStateModel';
import { DynamicDataSource } from '../model/DynamicDataSource';
import { SettingItemModel } from '../model/SettingItemModel';

const TAG: string = 'SettingGroupEventHandler';

@Observed
export class SettingGroupVM {
  public visible: boolean = true;
}

export class SettingGroupEventHandler {
  public groupVm: SettingGroupVM;
  private groupInfo?: SettingGroupModel;
  private compId: string = '';
  private dataSource?: DynamicDataSource;
  private eventCb = (data: object) => {
    if (!(data instanceof Map)) {
      LogHelper.error(TAG, 'invaild eventbus data type.');
    }
    this.procEvent(data as Map<SettingStateType, SettingBaseState>);
  };

  constructor(groupVm: SettingGroupVM) {
    this.groupVm = groupVm;
  }

  private careCompState(group: SettingGroupModel): boolean {
    return group.type === GroupType.GROUP_TYPE_DYNAMIC || group.type === GroupType.GROUP_TYPE_DYNAMIC_LAZY ||
      group.type === GroupType.GROUP_TYPE_STANDARD;
  }

  private procGroupVisibleChange(value: SettingCompState): void {
    if (this.groupInfo && this.careCompState(this.groupInfo)) {
      LogHelper.info(TAG, `${this.compId} visible change from ${this.groupVm.visible} to ${value.state}`);
      this.groupVm.visible = value.state;
    }
  }

  /* instrument ignore next */
  private insertGroupsByConfigOrder(value: SettingStandardGroupItemsChange): void {
    let cfgOrder: Map<string, number> = new Map();
    this.groupInfo?.items?.forEach((item: SettingItemModel, index: number) => {
      cfgOrder.set(item.id, index);
    })

    value.itemIds.forEach((id: string) => {
      let itemIndex = cfgOrder.get(id);
      if (itemIndex === undefined || !this.dataSource) {
        return;
      }

      let index: number = 0;
      for (let i = 0; i < this.dataSource.length; i++) {
        let curIndex = cfgOrder.get(this.dataSource[i].id);
        if (curIndex !== undefined && curIndex > itemIndex) {
          break;
        }
        index++;
      }

      let sourceItem = this.groupInfo?.items?.[itemIndex];
      if (sourceItem) {
        this.dataSource?.insertData(index, sourceItem);
      }
    });
  }

  /* instrument ignore next */
  private procStandardGroupItemsChange(value: SettingStandardGroupItemsChange): void {
    LogHelper.info(TAG, `recv group item change event, ${JSON.stringify(value)}`);
    if (value.deleted) {
      value.itemIds.forEach((id: string) => {
        this.dataSource?.removeDataById(id);
      });
    } else {
      this.insertGroupsByConfigOrder(value);
    }
  }

  private procEvent(data: Map<SettingStateType, SettingBaseState>): void {
    data.forEach((value: SettingBaseState, key: SettingStateType) => {
      if (!value) {
        return;
      }

      switch (key) {
        case SettingStateType.STATE_TYPE_GROUP_VISIBLE:
          this.procGroupVisibleChange(value as SettingCompState);
          break;

        case SettingStateType.STATE_TYPE_STANDARD_GROUP_ITEMS_CHANGE:
          this.procStandardGroupItemsChange(value as SettingStandardGroupItemsChange);
          break;

        default:
          LogHelper.error(TAG, `invaild event data key: ${key}`);
          break;
      }
    })
  }

  public init(groupInfo: SettingGroupModel, compId: string, dataSource?: DynamicDataSource): void {
    this.groupInfo = groupInfo;
    this.compId = compId;
    this.dataSource = dataSource;
    let group = this.groupInfo;
    if (this.careCompState(group) || group.visible !== undefined) {
      this.groupVm.visible = (group.visible !== undefined) ? group.visible : true;
    }
    EventBus.getInstance().on(compId, this.eventCb);
  }

  public destroy(): void {
    EventBus.getInstance().detach(this.compId, this.eventCb);
  }
}

export class SettingGroupFooterEventHandler extends SettingGroupEventHandler {
  public init(group: SettingGroupModel, compId: string): void {
    super.init(group, compId);
    if (group.footer?.visible !== undefined) {
      this.groupVm.visible = group.footer.visible;
    }
  }
}
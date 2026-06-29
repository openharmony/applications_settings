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

import { PRECISION0 } from '@ohos/settings.common/src/main/ets/constant/ViewConstant';
import { EventBus } from '@ohos/settings.common/src/main/ets/framework/common/EventBus';
import { OrderedDataSource } from '@ohos/settings.common/src/main/ets/framework/model/OrderedDataSource';
import {
  CompCtrlParam,
  ComponentControl,
  SettingBaseModel
} from '@ohos/settings.common/src/main/ets/framework/model/SettingBaseModel';
import {
  ComparableSettingItemModel,
  ItemDetailType,
  ItemResultType,
  ItemType
} from '@ohos/settings.common/src/main/ets/framework/model/SettingItemModel';
import { NavEntryKey } from '@ohos/settings.common/src/main/ets/utils/Consts';
import { LogUtil } from '@ohos/settings.common/src/main/ets/utils/LogUtil';
import { StorageEventConstant } from '@ohos/settings.storage/src/main/ets/constant/StorageConstant';
import { StorageSizeUtil } from '@ohos/settings.storage/src/main/ets/utils/StorageSizeUtil';

/* instrument ignore file */
const TAG = 'BackupDataGroupController';

export interface BackupDataModel {
  localBackupData: number,
  upgradingData: number
}

export const BACKUP_DATA_UPDATE_EVENT: string = 'BACKUP_DATA_UPDATE_EVENT';

export class BackupDataGroupController implements ComponentControl {
  private dataSource?: OrderedDataSource;
  private compId?: string;
  private onBackupDataChange = (data: BackupDataModel) => {
    LogUtil.showInfo(TAG, `onBackupDataChange`)
    this.updateItems(data);
  }

  init(compParam: CompCtrlParam): void {
    if (!compParam || !compParam.compId) {
      LogUtil.error(`${TAG} init fail, compParam is invalid`);
      return;
    }
    this.compId = compParam.compId;
    LogUtil.info(`${TAG} init, compId: ${this.compId}`);
    this.dataSource = (compParam.dataSource) as OrderedDataSource;
    EventBus.getInstance().on(BACKUP_DATA_UPDATE_EVENT, this.onBackupDataChange);
    EventBus.getInstance().emit(StorageEventConstant.EVENT_STORAGE_SYS_DATA_GROUP_INIT);
  }

  private updateItems(data: BackupDataModel) {
    if (!this.dataSource || !data) {
      LogUtil.showWarn(TAG, `updateItems invalid, datasource: ${this.dataSource?.length}`);
      return;
    }
    let items: ComparableSettingItemModel[] = [];
    if (data.localBackupData > 0) {
      items.push(this.getLocalBackupDataItem(StorageSizeUtil.formatDataIntl(data.localBackupData, PRECISION0, true)));
    }
    if (data.upgradingData > 0) {
      items.push(this.getUpgradingDataItem(StorageSizeUtil.formatDataIntl(data.upgradingData, PRECISION0, true)));
    }
    const length = items.length;
    for (let i = 0; i < length; i++) {
      items[i].subId += `${i}_${length}`;
    }
    this.dataSource.splice(0, this.dataSource.length, ...items);
  }

  private getLocalBackupDataItem(size: string): ComparableSettingItemModel {
    return {
      id: 'LocalBackupData',
      type: ItemType.ITEM_TYPE_STANDARD,
      visible: true,
      title: { content: $r('app.string.storage_local_backup_data') },
      result: { type: ItemResultType.RESULT_TYPE_TEXT, result: { content: size } },
      subId: size,
      detail: {
        type: ItemDetailType.DETAIL_TYPE_NAVIGATE,
        icon: $r('sys.symbol.chevron_right'),
        isSymbolIcon: true,
        destination: NavEntryKey.LOCAL_BACKUP_DATA,
      }
    };
  }

  private getUpgradingDataItem(size: string): ComparableSettingItemModel {
    return {
      id: 'UpgradingData',
      type: ItemType.ITEM_TYPE_STANDARD,
      visible: true,
      title: { content: $r('app.string.storage_upgrading_data') },
      result: { type: ItemResultType.RESULT_TYPE_TEXT, result: { content: size } },
      subId: size,
      detail: {
        type: ItemDetailType.DETAIL_TYPE_NAVIGATE,
        icon: $r('sys.symbol.chevron_right'),
        isSymbolIcon: true,
        destination: NavEntryKey.UPGRADING_DATA,
      }
    };
  }

  onPageShow(component: SettingBaseModel): void {
    LogUtil.info(`${TAG} onPageShow success`);
  }

  destroy(): void {
    LogUtil.info(`${TAG} onDestroy`);
    EventBus.getInstance().detach(BACKUP_DATA_UPDATE_EVENT, this.onBackupDataChange);
  }
}
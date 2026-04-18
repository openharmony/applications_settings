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

import {
  CompCtrlParam,
  ComponentControl,
} from '@ohos/settings.common/src/main/ets/framework/model/SettingBaseModel';
import { GroupType, SettingContentModel } from '@ohos/settings.common/src/main/ets/framework/model/SettingGroupModel';
import {
  ItemResultType,
  ItemType,
} from '@ohos/settings.common/src/main/ets/framework/model/SettingItemModel';
import { SettingPageModel } from '@ohos/settings.common/src/main/ets/framework/model/SettingPageModel';
import { LogUtil } from '@ohos/settings.common/src/main/ets/utils/LogUtil';
import { StorageDataManager } from '@ohos/settings.storage/src/main/ets/model/StorageDataManager';
import { StorageSizeUtil } from '@ohos/settings.storage/src/main/ets/utils/StorageSizeUtil';
import { upgradingDataFooterBuilder } from '../components/UpgradingDataFooterComponent';
import { upgradingDataHeaderBuilder } from '../components/UpgradingDataHeaderComponent';
/* instrument ignore file */
const TAG = 'UpgradingDataController'

export class UpgradingDataController implements ComponentControl {
  private totalSize: string = '0';

  init(compParam: CompCtrlParam): void {
    if (!compParam || !compParam.compId) {
      LogUtil.error(`${TAG} init fail, compParam is invalid`);
      return;
    }
    let comp = compParam.component as SettingPageModel;
    this.totalSize = StorageSizeUtil.formatDataIntl(StorageDataManager.getInstance().getUpgradingData(), 0, true);
    this.setHeader(comp);
    this.setGroups(comp);
    LogUtil.info(`${TAG} init seccess`);
  }

  setHeader(comp: SettingPageModel): void {
    comp.header = {
      id: 'UpgradingDataHeader',
      builder: wrapBuilder(upgradingDataHeaderBuilder),
    } as SettingContentModel;
  }

  setGroups(comp: SettingPageModel): void {
    comp.groups = [
      {
        id: 'UpgradingDataGroup',
        type: GroupType.GROUP_TYPE_STANDARD,
        footer: {
          id: 'UpgradingDataFooter',
          builder: wrapBuilder(upgradingDataFooterBuilder)
        },
        items: [
          {
            id: 'upgradingData',
            type: ItemType.ITEM_TYPE_STANDARD,
            title: { content: $r('app.string.app_info_storage_total_size') },
            result: { type: ItemResultType.RESULT_TYPE_TEXT, result: { content: this.totalSize} }
          }
        ],
      },
    ];
  }

  destroy(): void {
    LogUtil.showInfo(TAG, 'onDestroy');
  }
}
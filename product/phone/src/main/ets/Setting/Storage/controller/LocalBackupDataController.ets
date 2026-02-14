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
  SettingBaseModel,
} from '@ohos/settings.common/src/main/ets/framework/model/SettingBaseModel';
import { GroupType, SettingContentModel } from '@ohos/settings.common/src/main/ets/framework/model/SettingGroupModel';
import {
  ItemResultType,
  ItemType,
} from '@ohos/settings.common/src/main/ets/framework/model/SettingItemModel';
import { SettingPageModel } from '@ohos/settings.common/src/main/ets/framework/model/SettingPageModel';
import { LogUtil } from '@ohos/settings.common/src/main/ets/utils/LogUtil';
import { SettingsDataUtils } from '@ohos/settings.common/src/main/ets/utils/SettingsDataUtils';
import { LanguageUtils } from '@ohos/settings.common/src/main/ets/utils/LanguageUtils';
import { StorageEventConstant } from '@ohos/settings.storage/src/main/ets/constant/StorageConstant';
import {
  notifyCompStateChange,
  SettingResultState,
  SettingStateType
} from '@ohos/settings.common/src/main/ets/framework/model/SettingStateModel';
import { StorageSizeUtil } from '@ohos/settings.storage/src/main/ets/utils/StorageSizeUtil';
import { StorageDataManager } from '@ohos/settings.storage/src/main/ets/model/StorageDataManager';
import { StorageUtil } from '@ohos/settings.storage/src/main/ets/utils/StorageUtil';
import { EventBus } from '@ohos/settings.common/src/main/ets/framework/common/EventBus';
import { localBackupDataHeaderBuilder } from '../components/LocalBackupDataHeaderComponent';
import { localBackupDataFooterBuilder } from '../components/LocalBackupDataFooterComponent';
/* instrument ignore file */
const TAG = 'LocalBackupDataController'

export class LocalBackupDataController implements ComponentControl {
  private totalSize: string = '0';

  init(compParam: CompCtrlParam): void {
    if (!compParam || !compParam.compId) {
      LogUtil.error(`${TAG} init fail, compParam is invalid`);
      return;
    }
    let comp = compParam.component as SettingPageModel;
    this.totalSize = StorageSizeUtil.formatDataIntl(StorageDataManager.getInstance().getLocalBackupModel().size, 0,
      true);
    this.setHeader(comp);
    this.setGroups(comp);
    LogUtil.info(`${TAG} init seccess`);
  }

  setHeader(comp: SettingPageModel): void {
    comp.header = {
      id: 'LocalBackUpDataHeader',
      builder: wrapBuilder(localBackupDataHeaderBuilder),
    } as SettingContentModel;
  }

  setGroups(comp: SettingPageModel): void {
    comp.groups = [
      {
        id: 'LocalBackupDataGroup',
        type: GroupType.GROUP_TYPE_STANDARD,
        footer: {
          id: 'LocalBackUpDataFooter',
          builder: wrapBuilder(localBackupDataFooterBuilder)
        },
        items: [
          {
            id: 'localBackupData',
            type: ItemType.ITEM_TYPE_STANDARD,
            title: { content: $r('app.string.app_info_storage_total_size') },
            result: { type: ItemResultType.RESULT_TYPE_TEXT, result: { content: this.totalSize } }
          }
        ],
      },
    ];
  }

  onPageShow(component: SettingBaseModel): void {
    LogUtil.info(`${TAG} onPageShow success`);
    let isHasBackupData: boolean = StorageDataManager.getIsHasBackupData();
    if (!isHasBackupData) {
      LogUtil.info(`${TAG} hwbackup record has clean`);
      notifyCompStateChange('Setting.LocalBackupData.LocalBackupDataGroup.localBackupData', new Map<SettingStateType, SettingResultState>(
        [[SettingStateType.STATE_TYPE_ITEM_RESULT, { type: ItemResultType.RESULT_TYPE_TEXT,
          result: { content: StorageSizeUtil.formatDataIntl(0, 0) } } as SettingResultState]]));
    } else {
      StorageUtil.refreshBackUpDataSize();
      EventBus.getInstance().emit('Setting.storage.updateCreatTime');
      notifyCompStateChange('Setting.LocalBackupData.LocalBackupDataGroup.localBackupData',
        new Map<SettingStateType, SettingResultState>(
          [[SettingStateType.STATE_TYPE_ITEM_RESULT,
            {
              type: ItemResultType.RESULT_TYPE_TEXT,
              result: {
                content: StorageSizeUtil.formatDataIntl(StorageDataManager.getInstance().getLocalBackupModel().size,
                  0, true)
              } } as SettingResultState]]));
    }
  }

  destroy(): void {
    LogUtil.showInfo(TAG, 'onDestroy');
  }
}
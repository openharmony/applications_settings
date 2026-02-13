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
import { SettingsDataUtils } from '@ohos/settings.common/src/main/ets/utils/SettingsDataUtils';
import { StorageEventConstant } from '../constant/StorageConstant';

const TAG: string = 'StorageDataManager';

/**
 * 存储数据
 *
 * @since 2024-11-16
 */
export class StorageDataManager {
  private static storageDataManager: StorageDataManager;
  private upgradingData: number = 0;
  private localBackupModel: LocalBackupModel = new LocalBackupModel();

  public setLocalBackupModel(value: LocalBackupModel) {
    this.localBackupModel = value;
  }

  public getLocalBackupModel(): LocalBackupModel {
    return this.localBackupModel;
  }

  public setUpgradingData(value: number) {
    this.upgradingData = value;
  }

  public getUpgradingData(): number {
    return this.upgradingData;
  }

  /**
   * 获取单例
   */
  public static getInstance(): StorageDataManager {
    if (StorageDataManager.storageDataManager) {
      return StorageDataManager.storageDataManager;
    }
    StorageDataManager.storageDataManager = new StorageDataManager();
    return StorageDataManager.storageDataManager;
  }

  /**
   * 获取是否存在备份数据，由克隆备份提供的字段在settingsdata中的值确定
   *
   * @returns true：存在备份数据，false：不存在备份数据
   */
  public static getIsHasBackupData(): boolean {
    let isHasRecord: string = SettingsDataUtils.getSecureValue(StorageEventConstant.HAS_HWBACKUP_RECORD, '0');
    let isHasNextRecord: string = SettingsDataUtils.getSecureValue(StorageEventConstant.HAS_NEXT_HWBACKUP_RECORD, '0');
    LogUtil.info(`${TAG} has hwbackup record ${isHasRecord}, has next hwback record ${isHasNextRecord}`);
    return isHasRecord !== '0' || isHasNextRecord !== '0';
  }
}

/**
 * 本地备份数据
 *
 * @since 2024-11-16
 */
export class LocalBackupModel {
  public size: number = 0;
  public createTime: number = 0;
}

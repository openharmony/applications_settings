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

import abilityAccessCtrl from '@ohos.abilityAccessCtrl';
import { SetBadgeNumberService } from '@ohos/settings.common/src/main/ets/badgeManagement/SetBadgeNumberService';
import { DisableItemService } from '@ohos/settings.common/src/main/ets/service/DisableItemService';
import { BaseServiceStub, IService } from '@ohos/settings.common/src/main/ets/stub/BaseServiceStub';
import { LogUtil } from '@ohos/settings.common/src/main/ets/utils/LogUtil';
import { RdbStoreInitService } from '@ohos/settings.search/src/main/ets/service/RdbStoreInitService';
import { SearchEnableService } from '@ohos/settings.search/src/main/ets/service/SearchEnableService';
import { RestoreConfigService } from '../pages/reset/Interface/RestoreConfigService';
import { NotDisturbConfigService } from '../Setting/Volume/service/NotDisturbConfigService';
/* instrument ignore file */
const TAG: string = 'SettingsExtServiceStub';
const ACCESS_SYSTEM_SETTINGS = 'ohos.permission.ACCESS_SYSTEM_SETTINGS';

export class SettingsExtServiceStub extends BaseServiceStub {
  protected getServiceTag(): string {
    return TAG;
  }

  protected initServiceMap(): Map<number, () => IService> {
    return new Map([
      [ServiceCode.ENABLE_SEARCH, (): IService => new SearchEnableService()],
      [ServiceCode.SET_BADGE_NUMBER, (): IService => new SetBadgeNumberService()],
      [ServiceCode.SET_DEFAULT_CONFIG, (): IService => new RestoreConfigService()],
      [ServiceCode.DISABLED_MEAU, (): IService => new DisableItemService()],
      [ServiceCode.RDB_STORE_INIT, (): IService => new RdbStoreInitService()],
      [ServiceCode.SET_NOT_DISTURB_MODE, (): IService => new NotDisturbConfigService()],
    ]);
  }

  protected async checkPermissions(callerUid: number, callerTokenId: number): Promise<boolean> {
    let atManager = abilityAccessCtrl.createAtManager();
    try {
      let grantStatus = atManager.verifyAccessTokenSync(callerTokenId, ACCESS_SYSTEM_SETTINGS);
      if (grantStatus === abilityAccessCtrl.GrantStatus.PERMISSION_DENIED) {
        LogUtil.showError(TAG, `verify ${ACCESS_SYSTEM_SETTINGS} fail`);
        return false;
      }
    } catch (error) {
      LogUtil.showError(TAG, `verify ${ACCESS_SYSTEM_SETTINGS}: ${error}`);
      return false;
    }
    LogUtil.showInfo(TAG, `verify ${ACCESS_SYSTEM_SETTINGS} success`);
    return true;
  }
}

class ServiceCode {
  public static readonly RDB_STORE_INIT = 1;
  public static readonly ENABLE_SEARCH = 2;
  public static readonly SET_BADGE_NUMBER = 3;
  public static readonly SET_DEFAULT_CONFIG = 4;
  public static readonly DISABLED_MEAU = 5;
  public static readonly SET_NOT_DISTURB_MODE = 6;
  public static readonly SOUND_RECOGNITION_MODE = 7;
}

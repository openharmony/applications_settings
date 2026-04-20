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

import appManager from '@ohos.app.ability.appManager';
import account_osAccount from '@ohos.account.osAccount';
import { BusinessError } from '@ohos.base';
import { HiSysEventUtil } from '@ohos/settings.common/src/main/ets/systemEvent/HiSysEventUtil';
import { ButtonMenuController } from '@ohos/settings.common/src/main/ets/core/controller/MenuController';
import { SettingsBaseMenu } from '@ohos/settings.common/src/main/ets/core/model/menu/SettingsMenu';
import { Controller } from '@ohos/settings.common/src/main/ets/core/controller/Controller';
import { LogUtil } from '@ohos/settings.common/src/main/ets/utils/LogUtil';
import { AppListLoader } from '@ohos/settings.application/src/main/ets/AppListLoader';
import { AppManager } from '@ohos/settings.application/src/main/ets/util/AppManager';
import { AppPowerEntry } from './PowerConsumptionListController';

const TAG: string = 'EndRunButtonController:';
const END_RUN_BUTTON: string = 'battery_end_run_button';

export class EndRunButtonController extends ButtonMenuController {
  static CreateEndRunButtonController(menu: SettingsBaseMenu): Controller {
    return new EndRunButtonController(menu);
  }

  public isEndRunValid: boolean = false;
  public appPowerEntry: AppPowerEntry | null = null;
  public accountId: number = 0;

  constructor(menu: SettingsBaseMenu) {
    super(menu);
    let params = this.menu.navRouterParam?.config;
    this.appPowerEntry = params as AppPowerEntry;
    this.getIsApplicationRunning();
  }

  async getIsApplicationRunning(): Promise<void> {
    if (!this.appPowerEntry) {
      return;
    }
    if (!this.appPowerEntry?.isVirtualApp) {
      let entry = await AppListLoader.getInstance().getAndUpdateAppEntryByName(this.appPowerEntry?.name);
      const disableForceStop = AppManager.getInstance().isAppForceStop(entry?.name || '', entry?.moduleName || '');
      LogUtil.info(`${TAG} getIsApplicationRunning. disableForceStop:${disableForceStop}`);
      if (!disableForceStop) {
        try {
          this.isEndRunValid = await appManager.isApplicationRunning(this.appPowerEntry?.name);
          LogUtil.info(`${TAG} isApplicationRunning. endRunEnabled:${this.isEndRunValid}`);
        } catch (error) {
          LogUtil.info(`${TAG} isApplicationRunning catch error. code:${error?.code} message:${error?.message}`);
        }
      }
    }
    this.refreshUi();
  }

  isButton3Enabled(): boolean {
    return this.isEndRunValid;
  }

  onButton3Click(): void {
    this.killProcessWithAccount();
    this.isEndRunValid = false;
  }

  async killProcessWithAccount(): Promise<void> {
    if (this.accountId && this.appPowerEntry) {
      try {
        LogUtil.info(`${TAG} killProcessWithAccount bundleName: ${this.appPowerEntry.name}`);
        HiSysEventUtil.reportButtonEvent(END_RUN_BUTTON, this.appPowerEntry.name);
        appManager.killProcessWithAccount(this.appPowerEntry.name, this.accountId).then(() => {
          LogUtil.info(`${TAG} killProcessWithAccount success`);
        }).catch((err: BusinessError) => {
          LogUtil.info(`${TAG} killProcessWithAccount fail, err: ${err.code}`);
        });
      } catch (paramError) {
        LogUtil.info(`${TAG} [appManager] error: ${(paramError as BusinessError).code}, message : ${(paramError as BusinessError).message} `);
      }
    }
  }

  aboutToAppear(): void {
    let accountManager: account_osAccount.AccountManager = account_osAccount.getAccountManager();
    try {
      accountManager.getOsAccountLocalId((exception: BusinessError, localId: number) => {
        if (exception) {
          LogUtil.info(`${TAG} getOsAccountLocalId failed, error:${(exception as BusinessError).code},
            msg: ${(exception as BusinessError).message}`);
        } else {
          this.accountId = localId;
          LogUtil.info(`${TAG} getOsAccountLocalId: ${localId}`);
        }
      });
    } catch (exception) {
      LogUtil.info(`${TAG} getOsAccountLocalId error:${(exception as BusinessError).code},
        msg: ${(exception as BusinessError).message}`);
    }
    super.aboutToAppear();
  }
}
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

/* instrument ignore file */
import osAccount from '@ohos.account.osAccount';
import appManager from '@ohos.app.ability.appManager';
import { BusinessError } from '@ohos.base';
import { LogUtil } from '@ohos/settings.common/src/main/ets/utils/LogUtil';
import { DeviceUtil } from '@ohos/settings.common/src/main/ets/utils/BaseUtils';
import { HiSysEventUtil } from '@ohos/settings.common/src/main/ets/systemEvent/HiSysEventUtil';
import { SettingGroupModel } from '@ohos/settings.common/src/main/ets/framework/model/SettingGroupModel';
import { AppListLoader } from '@ohos/settings.application/src/main/ets/AppListLoader';
import { AppManager } from '@ohos/settings.application/src/main/ets/util/AppManager';
import { AppPowerEntry } from '../controller/PowerConsumptionListController';
import { BatteryParamUtil } from '../utils/BatteryParamUtil';

@Builder
export function appEndRunButtonBuilder(param: object): void {
  AppEndRunButton({ item: param as SettingGroupModel });
}

const TAG: string = 'AppEndRunButton:';
const END_RUN_BUTTON: string = 'battery_end_run_button';

@Component
export struct AppEndRunButton {
  item?: SettingGroupModel;
  @State endRunEnabled: boolean = false;
  private userId: number = 100;
  private appPowerEntry?: AppPowerEntry;
  private isPc: boolean = DeviceUtil.isDevicePc();

  build() {
    Column() {
      Button() {
        Text($r('app.string.battery_end_run'))
          .fontFamily('HarmonyHeiTi')
          .fontWeight(FontWeight.Medium)
          .fontColor($r('sys.color.font_emphasize'))
          .fontSize($r('sys.float.Body_L'))
          .lineHeight(21)
          .wordBreak(WordBreak.HYPHENATION)
      }
      .role(ButtonRole.NORMAL)
      .type(ButtonType.Normal)
      .borderRadius($r('sys.float.corner_radius_level10'))
      .enabled(this.endRunEnabled)
      .backgroundColor($r('sys.color.comp_background_tertiary'))
      .constraintSize({
        maxWidth: 400,
        minHeight: 40,
      })
      .width('100%')
      .onClick(() => {
        this.onButtonClick();
      })
    }
    .width('100%')
    .padding({
      left: 16,
      right: 16,
      top: 8,
      bottom: 16,
    })
  }

  async aboutToAppear(): Promise<void> {
    this.appPowerEntry = BatteryParamUtil.getAppPowerEntryFromPathInfo();
    LogUtil.info(`${TAG} aboutToAppear name:${this.appPowerEntry?.name}`);
    if (!this.appPowerEntry?.isVirtualApp) {
      let entry = await AppListLoader.getInstance().getAndUpdateAppEntryByName(this.appPowerEntry?.name);
      const disableForceStop = AppManager.getInstance().isAppForceStop(entry?.name || '', entry?.moduleName || '');
      LogUtil.info(`${TAG} aboutToAppear disableForceStop:${disableForceStop}`);
      if (!disableForceStop) {
        try {
          this.endRunEnabled = await appManager.isApplicationRunning(this.appPowerEntry?.name);
          LogUtil.info(`${TAG} isApplicationRunning. endRunEnabled:${this.endRunEnabled}`);
        } catch (error) {
          LogUtil.info(`${TAG} isApplicationRunning catch error. code:${error?.code} message:${error?.message}`);
        }
      }
    }
    this.getUserId();
  }

  aboutToDisappear(): void {
    LogUtil.info(`${TAG} aboutToDisappear`);
  }

  /*
   * 获取当前用户
   */
  private async getUserId(): Promise<void> {
    let accountManager = osAccount.getAccountManager();
    try {
      this.userId = await accountManager.getOsAccountLocalId();
      LogUtil.info(`${TAG} getOsAccountLocalId success`);
    } catch (err) {
      LogUtil.error(`${TAG} getOsAccountLocalId. code:${err?.code} message:${err?.message}`);
    }
  }

  /*
   * 按钮点击事件
   */
  private onButtonClick(): void {
    if (this.appPowerEntry) {
      this.endRunEnabled = false;
      LogUtil.info(`${TAG} onButtonClick. bundleName:${this.appPowerEntry.name}`);
      HiSysEventUtil.reportButtonEvent(END_RUN_BUTTON, this.appPowerEntry.name);
      appManager.killProcessWithAccount(this.appPowerEntry.name, this.userId).then(() => {
        LogUtil.info(`${TAG} killProcessWithAccount success`);
      }).catch((error: BusinessError) => {
        LogUtil.info(`${TAG} killProcessWithAccount catch error. code:${error?.code} message:${error?.message}`);
      });
    }
  }
}
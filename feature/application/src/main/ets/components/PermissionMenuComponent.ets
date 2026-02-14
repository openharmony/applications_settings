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
import { osAccount } from '@kit.BasicServicesKit';
import { PushParam } from '@ohos/settings.common/src/main/ets/core/controller/Controller';
import { EventBus } from '@ohos/settings.common/src/main/ets/framework/common/EventBus';
import { PageRouter } from '@ohos/settings.common/src/main/ets/framework/common/PageRouter';
import { NavEntryKey } from '@ohos/settings.common/src/main/ets/utils/Consts';
import { LogUtil } from '@ohos/settings.common/src/main/ets/utils/LogUtil';
import { ExitAbnormallyComponent } from '@ohos/settings.common/src/main/ets/viewmodel/ExitAbnormallyComponent';
import { ObservedData, UiExtensionViewModel } from '@ohos/settings.common/src/main/ets/viewmodel/UiExtensionViewModel';
import { AppListLoader } from '../AppListLoader';
import { AppEntry, AppType } from '../AppModel';
import { SettingAppGroupModel } from '../model/SettingAppItemModel';
import { AppManager } from '../util/AppManager';

const BUNDLE_NAME: string = 'com.ohos.security.privacycenter';
const ABILITY_NAME: string = 'SettingsPermissionAbility';

@Component
export struct PermissionMenuComponent {
  tag: string = 'PermissionMenuComponent : ';
  uiExtensionProxy?: UIExtensionProxy;
  appItem?: SettingAppGroupModel;
  @State userId: Number = 100;
  @State exTensionHeight: number = 740.5;
  @State isUpdateUi: boolean = false;
  @State showHeight: number = 1000;
  @State observedData: ObservedData = new ObservedData();
  @State isAppEnable: boolean = false;
  @State appIndex: number = 0;
  private entry: AppEntry | null = null;
  private viewModel: UiExtensionViewModel = new UiExtensionViewModel(this.observedData);
  private bundleName: string = 'Permission';

  private appEnableSwitchEventCb = (data: object) => {
    let result = Boolean(data).valueOf() ?? false;
    LogUtil.info(`${this.tag} appEnableSwitch result is ${result}`);
    this.isAppEnable = result;
  };

  private refreshData = (entry: AppEntry) => {
    if (!entry) {
      LogUtil.error(`${this.tag} appEntry is invalid`);
      return;
    }
    this.entry = entry;
    this.bundleName = entry.name;
    this.appIndex = entry.appIndex;
    LogUtil.info(`${this.tag} receive app change: ${this.bundleName} | ${entry.name} | ${entry.appIndex}`);
  }

  recoverController: CustomDialogController = new CustomDialogController({
    builder: ExitAbnormallyComponent(),
  });

  // 校验子用户
  async getUserId(): Promise<void> {
    let accountManager = osAccount.getAccountManager();
    try {
      this.userId = await accountManager.getOsAccountLocalId();
      LogUtil.info(`${this.tag} verificationSubUser, userId: ${this.userId}`);
    } catch (err) {
      LogUtil.error(`${this.tag} verificationSubUser getOsAccountLocalId exception: ${err?.message}`);
    }
  }

  build() {
    Column() {
      UIExtensionComponent({
        bundleName: BUNDLE_NAME,
        abilityName: ABILITY_NAME,
        parameters: {
          'ability.want.params.uiExtensionType': 'sys/commonUI',
          'bundleName': this.bundleName,
          'userId': this.userId,
          'reconnect': this.observedData.reconnect,
          'appIndex': this.appIndex,
          'isAncoApp': AppListLoader.getInstance().getAppType(this.entry) === AppType.CONTAINER_APP
        }
      })
        .defaultFocus(true)
        .onRemoteReady((proxy) => {
          this.uiExtensionProxy = proxy;
        })
        .accessibilityUseSamePage(AccessibilitySamePageMode.FULL_SILENT)
        .onError((error) => {
          LogUtil.info(`${this.tag} UIExtensionComponent onError code: ${error?.code} message: ${error?.message}`);
          this.viewModel.refreshing(error, this.recoverController, BUNDLE_NAME, ABILITY_NAME);
        })
        .onTerminated(()=>{})
        .onReceive((data) => {
          LogUtil.info(`${this.tag} UIExtensionComponent onReceive`);
          if (data) {
            if (data['action'] === 'jump') {
              PageRouter.push(NavEntryKey.APPLICATION_PERMISSION_SETTINGS_ENTRY,
                new PushParam(data['uri'] as string, undefined, undefined, this.appIndex));
            }
            if ((data['newHeight'] !== undefined) && (data['newHeight'] !== null)) {
              this.showHeight = data['newHeight'] as number;
            }
          }
        })
        .width('100%')
        .height(this.showHeight)
        .visibility(this.isAppEnable ? Visibility.Visible : Visibility.None)
    }
  }

  aboutToAppear(): void {
    LogUtil.info(`${this.tag} aboutToAppear`);
    let data = this.appItem as SettingAppGroupModel;
    this.appIndex = data.appIndex as number;
    this.bundleName = data.bundleName as string;
    this.viewModel.listening(this.recoverController);
    this.getUserId();
    this.entry = data.entry ?? null;
    this.setIsAppEnable();
    EventBus.getInstance().on('EVENT_ID_APP_DETAIL_EVENTS', this.refreshData)
    EventBus.getInstance().on('EVENT_ID_APP_ENABLE_SWITCH_EVENTS', this.appEnableSwitchEventCb);
  }

  aboutToDisappear(): void {
    LogUtil.info(`${this.tag} aboutToDisappear`);
    EventBus.getInstance().detach('EVENT_ID_APP_DETAIL_EVENTS', this.refreshData);
    EventBus.getInstance().detach('EVENT_ID_APP_ENABLE_SWITCH_EVENTS', this.appEnableSwitchEventCb);
    this.viewModel.destroyListening();
  }

  private async setIsAppEnable(): Promise<void> {
    this.isAppEnable = await AppManager.getInstance()
      .getIsApplicationEnabled(this.bundleName, this.appIndex ?? 0, AppListLoader.getInstance().getAppType(this.entry));
    LogUtil.info(`${this.tag} setIsEnableValid ${this.isAppEnable}`);
  }
}
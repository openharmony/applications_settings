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

import { bundleManager, installer } from '@kit.AbilityKit';
import Want from '@ohos.app.ability.Want';
import { LogUtil } from '@ohos/settings.common/src/main/ets/utils/LogUtil';
import { AccountUtil } from '@ohos/settings.common/src/main/ets/utils/AccountUtil';
import {
  CompCtrlParam,
  ComponentControl,
  SettingBaseModel
} from '@ohos/settings.common/src/main/ets/framework/model/SettingBaseModel';
import { GroupType, } from '@ohos/settings.common/src/main/ets/framework/model/SettingGroupModel';
import { SettingPageModel } from '@ohos/settings.common/src/main/ets/framework/model/SettingPageModel';
import { PageRouter } from '@ohos/settings.common/src/main/ets/framework/common/PageRouter';
import { CheckEmptyUtils } from '@ohos/settings.common/src/main/ets/utils/CheckEmptyUtils';
import { PushParam } from '@ohos/settings.common/src/main/ets/core/controller/Controller';
import { EventBus } from '@ohos/settings.common/src/main/ets/framework/common/EventBus';
import { DynamicGroupDataSource } from '@ohos/settings.common/src/main/ets/framework/model/DynamicGroupDataSource';
import { ResourceUtil } from '@ohos/settings.common/src/main/ets/utils/ResourceUtil';
import { HiSysEventUtil } from '@ohos/settings.common/src/main/ets/systemEvent/HiSysEventUtil';
import {
  HiSysApplicationsAndServicesEventGroup
} from '@ohos/settings.common/src/main/ets/systemEvent/BehaviorEventConsts';
import {
  notifyCompStateChange,
  SettingBaseState,
  SettingContentState,
  SettingStateType
} from '@ohos/settings.common/src/main/ets/framework/model/SettingStateModel';
import { ExternalMenuPreloadManager } from '@ohos/settings.common/src/main/ets/externalmenu/ExternalMenuPreloadManager';
import { AppItemHeaderComponent } from '../components/AppItemHeaderComponent';
import { PermissionMenuComponent } from '../components/PermissionMenuComponent';
import { SettingAppGroupModel } from '../model/SettingAppItemModel';
import { AppNetworkController } from './AppNetworkController';
import { AppDetailActionComponent } from '../components/AppDetailActionComponent';
import { AppAllowAccessController } from './AppAllowAccessController';
import { DefaultBrowserItemController } from './DefaultBrowserItemController';
import { DefaultEmailItemController } from './DefaultEmailItemController';
import { AppListLoader } from '../AppListLoader';
import { AppEntry } from '../AppModel';
import { AppUtils } from '../AppUtils';
import { AppManager } from '../util/AppManager';

const TAG = 'AppDetailController: '

@Builder
function appDetailActionBuilder(param: object): void {
  AppDetailActionComponent({ appItem: param as SettingAppGroupModel });
}

@Builder
function permissionMenuBuilder(param: object): void {
  PermissionMenuComponent({ appItem: param as SettingAppGroupModel });
}

@Builder
function appItemHeaderBuilder(param: object): void {
  AppItemHeaderComponent({ appItem: param as SettingAppGroupModel });
}

export class AppDetailController implements ComponentControl {
  private params: PushParam = new PushParam();
  private comp: SettingPageModel | null = null;
  private appListLoader: AppListLoader = AppListLoader.getInstance();
  private entry: AppEntry | null = null;
  private bundleName: string = '';
  private appIndex: number = 0;
  private label: string = '';
  private isMoreApp: boolean = false;
  private dataSource: DynamicGroupDataSource = new DynamicGroupDataSource();

  init(compParam: CompCtrlParam): void {
    if (!compParam || !compParam.compId) {
      LogUtil.error(`${TAG} init fail, compParam is invalid`);
      return;
    }
    LogUtil.info(`${TAG} init begin: ${compParam.compId}`);
    this.params = compParam.param as PushParam;
    this.comp = compParam.component as SettingPageModel;
    this.dataSource = compParam.dataSource as DynamicGroupDataSource;
    if (!this.params) {
      LogUtil.info(`${TAG} init fail, init params is undefined`);
      return;
    }
    this.initBundleName();
    this.processExternal(this.params);
    LogUtil.info(`${TAG} init entry ${this.entry?.name}`);
    this.label = this.entry?.label as string;
    this.reportEvent();
    // ExternalMenuPreloadManager.getInstance().preloadUIExtensionAbility('SettingsPermissionAbility', getContext());
    HiSysEventUtil.reportDefaultBehaviorEventByUE(HiSysApplicationsAndServicesEventGroup.ENTER_APPLICATION_INFO_ENTRY,
      this.bundleName);
    LogUtil.info(`${TAG} init success`);
  }

  onPageShow(component: SettingBaseModel): void {
    LogUtil.info(`${TAG} onPageShow.`);
    EventBus.getInstance().emit('EVENT_ID_APP_DETAIL_PAGE_SHOW');
    this.updateTitle(this.entry?.label as string);
    // 如果该应用已经被卸载或者分身应用已被删除，则直接返回
    this.popPage();
  }

  onPageHide(component: SettingBaseModel): void {
    LogUtil.info(`${TAG} onPageHide.`);
  }

  private popPage(): void {
    if (!this.entry) {
      return;
    }
    if (!AppUtils.isBundleExist(this.entry?.name, this.entry?.appIndex)) {
      LogUtil.error(`${TAG} app not exist: ${this.entry?.name}, appIndex: ${this.entry?.appIndex}`);
      PageRouter.pop('Setting');
    }
  }

  private reportEvent() {
    let eventName: string = this.entry?.appInfo?.bundleType ?
      HiSysApplicationsAndServicesEventGroup.ENTER_META_MANAGE_PAGE :
      HiSysApplicationsAndServicesEventGroup.ENTER_NOTIFY_MANAGE_PAGE;
    HiSysEventUtil.reportDefaultBehaviorEventByUE(eventName, this.bundleName);
  }

  private initBundleName() {
    this.bundleName = this.params.config as string;
    if ((typeof this.bundleName !== 'string') || CheckEmptyUtils.checkStrIsEmpty(this.bundleName)) {
      this.bundleName = AppStorage.get<Want>('wantParams')?.parameters?.settingsParamBundleName as string ?? '';
    }
    this.appIndex = this.params.appIndex ?? 0;
    this.isMoreApp = this.params.itemName === 'MoreApp';
  }

  private async processExternal(inputPushParam: PushParam): Promise<void> {
    LogUtil.info(`${TAG} processExternal startReason： ${inputPushParam.startReason}`);
    if (inputPushParam.startReason === 'from_external') {
      let appIndexInWant: Object | undefined = AppStorage.get<Want>('wantParams')?.parameters?.appIndex;
      if (CheckEmptyUtils.isEmpty(appIndexInWant) || typeof appIndexInWant !== 'number') {
        // 未从wantParams 中取到，则去getAppCloneIdentity接口获取AppCloneIdentity，获取appIndex
        appIndexInWant = await this.getAppIndexInCaller();
        LogUtil.info(`${TAG} external appIndexInWant ${appIndexInWant}`);
      }
      this.appIndex = Number.isNaN(appIndexInWant as number) ? 0 : (appIndexInWant as number);
    }
    await this.initEntry();
    this.label = this.entry?.label as string;
    LogUtil.info(`${TAG} processExternal end, ${this.entry?.name}, ${this.appIndex}`);
    this.checkUninstallUpdate();
    this.addGroups();
  }

  private async checkUninstallUpdate(): Promise<void> {
    if (!this.entry) {
      LogUtil.showWarn(TAG, 'entry invalid');
      return;
    }
    let isCurrentMain: boolean = await AccountUtil.isCurrentAdmin();
    LogUtil.info(`${TAG} isCurrentMain: ${isCurrentMain}`);
    const bundleName = this.entry?.name || '';
    let isAppPreUpdated: boolean = AppManager.getInstance()
      .isAppPreUpdated(bundleName, AppListLoader.getInstance().getAppType(this.entry));
    LogUtil.info(`${TAG} isAppPreUpdated: ${isAppPreUpdated}`);
    let isRemovable = this.entry?.removable as boolean;
    LogUtil.info(`${TAG} isRemovable: ${isRemovable}`);
    if (!isRemovable && isCurrentMain && isAppPreUpdated) {
      LogUtil.info(`${TAG} show more_options`);
      this.comp?.menus?.push(
        {
          icon: $r('app.media.ic_public_more'),
          style: { accessibilityText: $r('app.string.more_options') },
          bindMenu: [
            {
              value: $r('app.string.app_info_uninstall_update'),
              action: () => {
                LogUtil.info(`${TAG} show uninstall update dialog`);
                EventBus.getInstance().emit('showUninstallUpdateDialog');
              },
            },
          ],
        }
      );
    }
  }

  private async initEntry(): Promise<void> {
    if (this.isMoreApp) {
      this.entry = await this.appListLoader.createAppEntryByName(this.bundleName, this.appIndex);
    } else {
      this.entry = this.appListLoader.getAppEntry(this.bundleName, this.appIndex) as AppEntry;
      if (!this.entry) {
        this.entry = await this.appListLoader.createAndCache(this.bundleName, this.appIndex);
      }
    }
    if (!this.entry) {
      LogUtil.error(`${TAG} initEntry fail`);
      PageRouter.pop('Setting');
    }
  }

  private async getAppIndexInCaller(): Promise<number> {
    let params = AppStorage.get<Want>('wantParams')?.parameters as Record<string, string>;
    let caller: string = '';
    Object.entries(params)?.forEach(
      (value: [key: string, value: string], index: number) => {
        if (value[0] === 'ohos.aafwk.param.callerUid') {
          caller = value[1];
        }
      }
    );
    LogUtil.info(`${TAG} getAppIndexInCaller, callerUid: ${Number(caller)}`);

    let appIndex: number = 0;
    try {
      const appCloneIdentity = await bundleManager.getAppCloneIdentity(Number(caller));
      LogUtil.info(`${TAG} getAppIndexInCaller, bundleName: ${appCloneIdentity?.bundleName} appIndex:${appCloneIdentity?.appIndex}`);
      appIndex = appCloneIdentity.appIndex;
    } catch (error) {
      LogUtil.error(`${TAG} getAppCloneIdentity failed, message: ${error?.message}, code: ${error?.code}`);
    }
    LogUtil.info(`${TAG} getAppIndexInCaller, appIndex: ${appIndex}`);
    return appIndex;
  }

  private getNotificationHeader(label: string): string {
    return ResourceUtil.getFormatStringSync($r('app.string.app_info_allow_access'), label as string);
  }

  private updateTitle(label: string) {
    LogUtil.info(`${TAG} updateTitle: ${label}`);
    notifyCompStateChange('Setting.AppDetail',
      new Map<SettingStateType, SettingBaseState>([[SettingStateType.STATE_TYPE_PAGE_TITLE,
        { content: label } as SettingContentState]]
      ));
  }

  private async addGroups(): Promise<void> {
    let isAppEnable: boolean = await AppManager.getInstance().getIsApplicationEnabled(this.bundleName, this.appIndex,
      AppListLoader.getInstance().getAppType(this.entry));
    let groups = [
      {
        id: 'AppInfoHeaderGroup',
        type: GroupType.GROUP_TYPE_CUSTOM,
        builder: wrapBuilder(appItemHeaderBuilder),
        icon: this.entry?.icon,
        versionName: this.entry?.versionName,
        label: this.entry?.label,
        name: this.entry?.name,
        entry: this.entry
      } as SettingAppGroupModel,
      {
        id: 'AppDetailActionGroup',
        type: GroupType.GROUP_TYPE_CUSTOM,
        builder: wrapBuilder(appDetailActionBuilder),
        bundleName: this.bundleName,
        appIndex: this.appIndex,
        entry: this.entry
      } as SettingAppGroupModel,
      {
        id: 'AppAllowAccessGroup',
        type: GroupType.GROUP_TYPE_DYNAMIC,
        header: {
          id: 'AppAllowAccessGroupHeader',
          content: isAppEnable ? this.getNotificationHeader(this.label) : '',
        },
        compControl: new AppAllowAccessController(),
        layout: {
          dividerStyle: {
            startMargin: 8,
            endMargin: 8
         },
        },
        entry: this.entry,
        visible: isAppEnable
      } as SettingAppGroupModel,
      {
        id: 'AppNetworkGroup',
        type: GroupType.GROUP_TYPE_DYNAMIC,
        visible: isAppEnable,
        compControl: new AppNetworkController(),
        entry: this.entry
      } as SettingAppGroupModel,
      {
        id: 'DefaultBrowserGroup',
        type: GroupType.GROUP_TYPE_DYNAMIC,
        visible: isAppEnable,
        compControl: new DefaultBrowserItemController(),
        entry: this.entry,
      } as SettingAppGroupModel,
      {
        id: 'DefaultEmailGroup',
        type: GroupType.GROUP_TYPE_DYNAMIC,
        visible: isAppEnable,
        compControl: new DefaultEmailItemController(),
        entry: this.entry,
      } as SettingAppGroupModel,
      // {
      //   id: 'PermissionGroup',
      //   type: GroupType.GROUP_TYPE_CUSTOM,
      //   builder: wrapBuilder(permissionMenuBuilder),
      //   bundleName: this.bundleName,
      //   appIndex: this.appIndex,
      //   entry: this.entry,
      //   visible: isAppEnable
      // } as SettingAppGroupModel,
    ];
    LogUtil.info(`${TAG} addGroups pushData, ${groups.length}, ${isAppEnable}`);
    this.dataSource.pushData(...groups);
    this.updateTitle(this.entry?.label as string);
  }

  destroy(): void {
    LogUtil.showInfo(TAG, 'onDestroy');
  }
}
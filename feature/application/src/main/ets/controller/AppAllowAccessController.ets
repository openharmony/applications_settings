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

import fs from '@ohos.file.fs';
import { notificationManager } from '@kit.NotificationKit';
import { commonEventManager, configPolicy } from '@kit.BasicServicesKit';
import bundleManager from '@ohos.bundle.bundleManager';
import { JSON } from '@kit.ArkTS';
import { EventBus } from '@ohos/settings.common/src/main/ets/framework/common/EventBus';
import { DynamicDataSource } from '@ohos/settings.common/src/main/ets/framework/model/DynamicDataSource';
import {
  CompCtrlParam,
  ComponentControl,
} from '@ohos/settings.common/src/main/ets/framework/model/SettingBaseModel';
import { LogUtil } from '@ohos/settings.common/src/main/ets/utils/LogUtil';
import { PageRouter } from '@ohos/settings.common/src/main/ets/framework/common/PageRouter';
import { NavEntryKey } from '@ohos/settings.common/src/main/ets/utils/Consts';
import { DeviceUtil } from '@ohos/settings.common/src/main/ets/utils/BaseUtils';
import { PushParam } from '@ohos/settings.common/src/main/ets/core/controller/Controller';
import { ResourceUtil } from '@ohos/settings.common/src/main/ets/utils/ResourceUtil';
import {
  ItemDetailType,
  ItemResultType,
  ItemType, SettingItemModel } from '@ohos/settings.common/src/main/ets/framework/model/SettingItemModel';
import {
  notifyCompStateChange,
  SettingBaseState,
  SettingCompState,
  SettingContentState,
  SettingStateType
} from '@ohos/settings.common/src/main/ets/framework/model/SettingStateModel';
import {
  INotificationConfig,
  NotifyDataModel,
  SettingAppGroupModel,
  SettingAppItemModel
} from '../model/SettingAppItemModel';
import { AppLiveViewController } from './AppLiveViewController';
import { AppEntry } from '../AppModel'
import { AppManager } from '../util/AppManager';
import { AppListLoader } from '../AppListLoader';

const TAG = 'AppAllowAccessController: ';

export class AppAllowAccessController implements ComponentControl {
  private compId: string = '';
  private dataSource: DynamicDataSource = new DynamicDataSource();
  private entry: AppEntry | null = null;
  private bundleName: string = '';
  private isLiveViewSwitchEnabled: boolean = false;
  private isNotificationEnabled: boolean = true;
  private commonEventSubscriber?: commonEventManager.CommonEventSubscriber;
  private isAppEnable: boolean = true;
  private appPrivileges?: Record<string, string>;

  private appEnableSwitchEventCb = (data: object) => {
    let result = Boolean(data).valueOf() ?? false;
    LogUtil.info(`${TAG} appEnableSwitch result is ${result}`);
    this.isAppEnable = result;
    this.refreshHeadState();
    this.refreshGroupState();
    this.updateHeaderTitle();
  };

  init(compParam: CompCtrlParam): void {
    LogUtil.showInfo(TAG, 'onInit');
    if (!compParam || !compParam.compId) {
      LogUtil.error(`${TAG} init fail, compParam is invalid`);
      return;
    }
    this.compId = compParam.compId;
    this.dataSource = compParam.dataSource as DynamicDataSource;
    let appItem: SettingAppGroupModel = compParam.component as SettingAppGroupModel;
    this.entry = appItem.entry as AppEntry;
    if (this.entry) {
      LogUtil.info(`${TAG} init app action entry: ${this.entry.name}, ${this.entry.appIndex}`);
      this.bundleName = this.entry.name;
      this.initAllowAccess();
    }
    this.subscribeSlotChangeEvent();
    EventBus.getInstance().on('EVENT_ID_APP_ENABLE_SWITCH_EVENTS', this.appEnableSwitchEventCb);
  }

  destroy(): void {
    LogUtil.showInfo(TAG, 'onDestroy');
    EventBus.getInstance().detach('EVENT_ID_APP_ENABLE_SWITCH_EVENTS', this.appEnableSwitchEventCb);
  }

  private async subscribeSlotChangeEvent(): Promise<void> {
    try {
      this.commonEventSubscriber = await commonEventManager.createSubscriber({
        events: ['usual.event.SLOT_CHANGE']
      });
      commonEventManager.subscribe(this.commonEventSubscriber, async (err, event) => {
        /* instrument ignore if*/
        if (err) {
          LogUtil.error(`${TAG} Receive usual.event.SLOT_CHANGE error: ${err?.code} ${err?.message}`);
          return;
        }
        /* instrument ignore if*/
        if (event.bundleName) {
          // 收到实况通知广播时，若实况开关未显示，则需要刷新界面显示开关，如果已显示，则刷新开关状态
          let status = await notificationManager.isNotificationSlotEnabled(
            { bundle: event.bundleName, uid: event?.parameters?.uid },
            notificationManager.SlotType.LIVE_VIEW
          );
          if (this.isLiveViewSwitchEnabled) {
            EventBus.getInstance().emit('EVENT_ID_APP_LIVE_SWITCH_CHANGE', status);
          } else {
            this.isLiveViewSwitchEnabled = status;
            this.initAllowAccess();
          }
        }
      });
      LogUtil.info(`${TAG} Subscribe usual.event.SLOT_CHANGE success`);
    } catch (e) {
      LogUtil.error(`${TAG} Subscribe usual.event.SLOT_CHANGE error: ${e?.message}`);
    }
  }

  private async initAllowAccess(): Promise<void> {
    if (!this.entry) {
      LogUtil.error(`${TAG} entry invalid`);
      return;
    }
    LogUtil.info(`${TAG} entry allow access: ${this.entry?.name}, ${this.entry?.appIndex}, ${this.entry?.appInfo?.uid}`);
    let bundleType: number = this.entry.appInfo?.bundleType as number;
    this.isNotificationEnabled = await this.isShowNtfSwitch(this.entry?.name as string);
    if (bundleType === bundleManager.BundleType.APP) {
      this.initAppAllowAccess();
    } else if (bundleType === bundleManager.BundleType.ATOMIC_SERVICE) {
      this.initServiceAllowAccess();
    }
    this.isAppEnable = await AppManager.getInstance()
      .getIsApplicationEnabled(this.entry?.name as string, this.entry?.appIndex ?? 0,
        AppListLoader.getInstance().getAppType(this.entry));
    this.refreshHeadState();
    this.refreshGroupState();
  }

  /**
   * 是否显示通知开关配置，一些应用可以通过CCM配置隐藏通知开关配置，即应用管理页面
   * @returns
   */
  private async isShowNtfSwitch(bundleName: string): Promise<boolean> {
    await this.initAppPrivileges();
    if (this.appPrivileges?.[bundleName] && this.appPrivileges[bundleName][3] === '1') {
      return false;
    }
    return true;
  }

  private async initAppPrivileges(): Promise<void> {
    if (!this.appPrivileges) {
      try {
        const notificationConfigPaths = await configPolicy.getCfgFiles('etc/notification/notification_config.json');
        if (notificationConfigPaths.length === 0) {
          LogUtil.showWarn(TAG, 'not get any valid config path');
          return;
        }
        let configs: INotificationConfig[] = [];
        for (let path of notificationConfigPaths) {
          const notificationConfig = JSON.parse(await fs.readText(path)) as INotificationConfig;
          configs.push(notificationConfig);
        }
        let mergeRes = this.mergeConfigs(configs);
        this.appPrivileges = mergeRes.appPrivileges;
        LogUtil.showInfo(TAG, 'appPrivileges init end');
      } catch (e) {
        LogUtil.error(`${TAG}Read notification_config.json failed: ${e?.message}`);
      }
    }
  }

  private mergeConfigs(configs: INotificationConfig[]): INotificationConfig {
    let mergeRes = configs[0]?.appPrivileges ?? {};
    for (let i = 1; i <= configs.length; i++) {
      const privilege = configs[i]?.appPrivileges ?? {};
      Object.keys(privilege).forEach((key) => {
        mergeRes[key] = privilege[key];
      });
    }
    return { appPrivileges: mergeRes };
  }

  private async initAppLiveViewSwitch(bundleName: string, uid: number): Promise<void> {
    if (DeviceUtil.isDevicePc()) {
      return;
    }
    let bundle: notificationManager.BundleOption = {
      bundle: bundleName,
      uid: uid
    };
    try {
      await this.initAppPrivileges();
      if (this.appPrivileges?.[bundleName] && this.appPrivileges?.[bundleName][0] === '1') {
        this.isLiveViewSwitchEnabled = false;
        return;
      }
      // 若历史发过实况通知，则需要显示实况菜单（有历史结论则接口能正常调用）
      await notificationManager.isNotificationSlotEnabled(bundle, notificationManager.SlotType.LIVE_VIEW);
      this.isLiveViewSwitchEnabled = true;
      LogUtil.info(`${TAG} initAppLiveViewSwitch: ${this.isLiveViewSwitchEnabled}`);
    } catch (err) {
      LogUtil.error(`${TAG} Get ${bundleName} live view switch fail: ${err?.message}`);
    }
  }

  private async initAppAllowAccess(): Promise<void> {
    this.dataSource?.splice(0, this.dataSource.length);
    if (this.isNotificationEnabled) {
      this.dataSource.push(this.createAppNotificationItem());
    }
    await this.initAppLiveViewSwitch(this.entry?.name as string, this.entry?.appInfo?.uid as number);
    LogUtil.info(`${TAG} initAppAllowAccess: ${this.isLiveViewSwitchEnabled}`);
    if (this.isLiveViewSwitchEnabled) {
      this.dataSource.push(this.createLiveViewItem());
    }
  }

  /* instrument ignore next */
  private initServiceAllowAccess(): void {
    this.dataSource?.splice(0, this.dataSource.length);
    if (this.isNotificationEnabled) {
      this.dataSource.push(this.createAppNotificationItem());
    }
  }

  private notificationMenuClick(): void {
    LogUtil.info(`${TAG} entry application_networking_entry: ${this.entry?.name}, ${this.entry?.appIndex}`);
    PageRouter.push(NavEntryKey.NOTIFICATION_SETTINGS_DETAIL_ENTRY, new PushParam({
      config: {
        bundleName: this.entry?.name,
        appIndex: this.entry?.appIndex,
      }
    } as NotifyDataModel, undefined, this.bundleName));
  }

  private getNotificationHeader(label: string): string {
    return ResourceUtil.getFormatStringSync($r('app.string.app_info_allow_access'), label as string);
  }

  private updateHeaderTitle() {
    notifyCompStateChange(`${this.compId}.header`,
      new Map<SettingStateType, SettingBaseState>([[SettingStateType.STATE_TYPE_GROUP_HEADER_TITLE,
        { content: this.getNotificationHeader(this.entry?.label as string) } as SettingContentState]]
      ));
  }

  // head根据通知显示隐藏
  private async refreshHeadState(): Promise<void> {
    notifyCompStateChange(`${this.compId}.header`,
      new Map<SettingStateType, SettingBaseState>([[SettingStateType.STATE_TYPE_GROUP_HEADER_VISIBLE,
        { state: this.isNotificationEnabled && this.isAppEnable } as SettingCompState]]));
  }

  // Group根据通知显示隐藏
  private async refreshGroupState(): Promise<void> {
    notifyCompStateChange(this.compId, new Map<SettingStateType, SettingBaseState>(
      [[SettingStateType.STATE_TYPE_GROUP_VISIBLE, { state: this.isAppEnable } as SettingCompState]]
    ));
  }

  private createAppNotificationItem(): SettingItemModel {
    return {
      id: 'Notification',
      type: ItemType.ITEM_TYPE_STANDARD,
      title: { content: $r('app.string.app_info_inform') },
      detail: {
        type: ItemDetailType.DETAIL_TYPE_CUSTOM,
        icon: $r('sys.symbol.chevron_right'),
        isSymbolIcon: true,
        onItemClick: () => {
          this.notificationMenuClick();
        }
      }
    }
  }

  private createLiveViewItem(): SettingAppItemModel {
    return {
      id: 'AppLiveView',
      type: ItemType.ITEM_TYPE_STANDARD,
      title: { content: $r('app.string.app_info_live_view') },
      result: {
        type: ItemResultType.RESULT_TYPE_TOGGLE,
        result: {
          state: true
        }
      },
      compControl: new AppLiveViewController(),
      layout: { noNeedDivider: true },
      entry: this.entry
    } as SettingAppItemModel
  }
}
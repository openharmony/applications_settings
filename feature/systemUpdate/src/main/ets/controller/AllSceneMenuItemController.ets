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

import taskpool from '@ohos.taskpool';
import { BusinessError } from '@ohos.base';
import emitter from '@ohos.events.emitter';
import { LogUtil } from '@ohos/settings.common/src/main/ets/utils/LogUtil';
import { AccountUtil } from '@ohos/settings.common/src/main/ets/utils/AccountUtil';
import { EVENT_ID_LANGUAGE_UPDATE } from '@ohos/settings.common/src/main/ets/event/types';
import { SettingsDataUtils } from '@ohos/settings.common/src/main/ets/utils/SettingsDataUtils';
import {
  CompCtrlParam,
  ComponentControl,
  SettingBaseModel
} from '@ohos/settings.common/src/main/ets/framework/model/SettingBaseModel';
import { EventBus } from '@ohos/settings.common/src/main/ets/framework/common/EventBus';
import {
  SettingCompState,
  SettingStateType
} from '@ohos/settings.common/src/main/ets/framework/model/SettingStateModel';
import { DynamicDataSource } from '@ohos/settings.common/src/main/ets/framework/model/DynamicDataSource';
import { SystemUpdateConstants } from '@ohos/settings.common/src/main/ets/constant/SystemUpdateConstants';
import { SettingItemModel, ItemType } from '@ohos/settings.common/src/main/ets/framework/model/SettingItemModel';
import { AllSceneMenuItemInfo } from '../model/AllSceneMenuItemModel';
import { AllSceneMenuItemView } from '../view/AllSceneMenuItemView';
import { FormatUtils } from '../utils/FormatUtils';
import { ExternalResourceUtils } from '../utils/ExternalResourceUtils';
import { AllSceneUpdateBadgeListenerManager } from '../listener/AllSceneUpdateBadgeListener';

const TAG: string = 'AllSceneMenuItemController';
const COMPONENT_ID: string = 'AboutDevice.all_scene_ota_group';

/**
 * 协同升级菜单项目定义
 */
const allSceneMenuItem: SettingItemModel = {
  id: 'all_scene_ota_name',
  type: ItemType.ITEM_TYPE_CUSTOM,
  builder: wrapBuilder(allSceneMenuItemBuilder),
};

/**
 * 协同升级菜单项目Builder
 */
@Builder function allSceneMenuItemBuilder(item: object) {
  AllSceneMenuItemView({ item: item as SettingBaseModel});
}

@Concurrent
async function doGetInfoTask(context: Context): Promise<Nullable<AllSceneMenuItemInfo>> {
  const importRes = await import('./AllSceneMenuItemController');
  LogUtil.showInfo('AllSceneMenuItemController', 'doGetInfoTask');
  return importRes.AllSceneMenuItemController.getAllSceneMenuInfoFromSettings(context);
}

/**
 * 协同升级菜单项目控制器
 *
 * @since 2024-09-26
 */
export class AllSceneMenuItemController implements ComponentControl {
  private allSceneMenuItemInfo: Nullable<AllSceneMenuItemInfo> = undefined;
  private orderedDataSource?: DynamicDataSource;
  public isPrivacyUser: boolean = false;
  private refreshLanguageCount: number = 0;
  private languageChangeCallBack = () => {
    LogUtil.showInfo(TAG, 'onLangChange');
    this.buildMenuContent();
  };

  private constructor() {
  }

  /**
   * 获取协同升级菜单项目控制器单例
   */
  static getInstance(): AllSceneMenuItemController {
    if (!Boolean(AppStorage.get<AllSceneMenuItemController>('allSceneMenuItemController')).valueOf()) {
      AppStorage.setOrCreate('allSceneMenuItemController', new AllSceneMenuItemController());
    }
    return AppStorage.get<AllSceneMenuItemController>('allSceneMenuItemController') as AllSceneMenuItemController;
  }

  init(compParam: CompCtrlParam): void {
    LogUtil.showInfo(TAG, 'init');
    try {
      let task: taskpool.Task = new taskpool.Task(doGetInfoTask, SettingsDataUtils.getContext());
      taskpool.execute(task, taskpool.Priority.MEDIUM).then((allSceneMenuItemInfo: Object) => {
        this.orderedDataSource = compParam.dataSource as DynamicDataSource;
        this.refreshAllSceneMenuItemInfo(allSceneMenuItemInfo as Nullable<AllSceneMenuItemInfo>);
        this.registerDataChange();
        this.registerLanguageChange();
      }).catch((err: BusinessError) => {
        LogUtil.showError(TAG, `init, doGetInfoTask execute error, ${err?.code} ${err?.message}`);
      });
    } catch (err) {
      LogUtil.showError(TAG, `init, doGetInfoTask taskpool execute error, ${err?.code} ${err?.message}`);
    }
  }

  destroy(): void {
    LogUtil.showInfo(TAG, 'destroy');
    this.unRegisterDataChange();
    this.unRegisterLanguageChange();
  }

  private setMenuItemShowOrHide(): void {
    if (this.allSceneMenuItemInfo && this.allSceneMenuItemInfo.isShowMenuItem && !this.isPrivacyUser) {
      if (!this.orderedDataSource?.includes(allSceneMenuItem)) {
        this.orderedDataSource?.pushData(allSceneMenuItem);
      }
      setTimeout(() => EventBus.getInstance().emit(COMPONENT_ID, new Map<SettingStateType, SettingCompState>(
        [[SettingStateType.STATE_TYPE_GROUP_VISIBLE, { state: true }]])), 50);
    } else {
      setTimeout(() => EventBus.getInstance().emit(COMPONENT_ID, new Map<SettingStateType, SettingCompState>(
        [[SettingStateType.STATE_TYPE_GROUP_VISIBLE, { state: false }]])), 200);
    }
  }

  aboutToAppear(): void {
    LogUtil.showInfo(TAG, 'aboutToAppear');
  }

  aboutToDisappear(): void {
    LogUtil.showInfo(TAG, 'aboutToDisappear');
  }

  private async registerDataChange(): Promise<void> {
    LogUtil.showInfo(TAG, 'registerDataChange');
    AllSceneUpdateBadgeListenerManager.getInstance().registerAllSceneUpdateBadgeChangeListener(this);
  }

  private unRegisterDataChange(): void {
    LogUtil.showInfo(TAG, 'unRegisterDataChange');
    AllSceneUpdateBadgeListenerManager.getInstance().unRegisterAllSceneUpdateBadgeChangeListener(this);
  }

  private registerLanguageChange(): void {
    LogUtil.showInfo(TAG, 'registerLanguageChange');
    emitter.on({ eventId: EVENT_ID_LANGUAGE_UPDATE }, this.languageChangeCallBack);
  }

  private unRegisterLanguageChange() {
    LogUtil.showInfo(TAG, 'unRegisterLanguageChange');
    emitter.off(EVENT_ID_LANGUAGE_UPDATE, this.languageChangeCallBack);
  }

  private buildMenuContent(): void {
    if (!this.allSceneMenuItemInfo) {
      return;
    }

    this.allSceneMenuItemInfo.menuItemTitle = ExternalResourceUtils.getExternalStringByName(
      SystemUpdateConstants.OUC_BUNDLE_NAME, this.allSceneMenuItemInfo.menuItemTitleResourceName);
    if (this.allSceneMenuItemInfo.deviceCount > 1) {
      this.allSceneMenuItemInfo.menuItemContent = FormatUtils.formatStrInOrder(
        ExternalResourceUtils.getExternalStringByName(SystemUpdateConstants.OUC_BUNDLE_NAME,
          this.allSceneMenuItemInfo.multipleContentResourceName),
        this.allSceneMenuItemInfo.firstDeviceName,
        ExternalResourceUtils.getExternalPluralStringByName(SystemUpdateConstants.OUC_BUNDLE_NAME,
          this.allSceneMenuItemInfo.deviceCountResourceName, this.allSceneMenuItemInfo.deviceCount));
      this.refreshLanguageCount++;
      return;
    }

    if (this.allSceneMenuItemInfo.multipleContentResourceName === '') {
      this.allSceneMenuItemInfo.menuItemContent = this.allSceneMenuItemInfo.firstDeviceName;
    } else {
      this.allSceneMenuItemInfo.menuItemContent = FormatUtils.formatStrInOrder(
        ExternalResourceUtils.getExternalStringByName(SystemUpdateConstants.OUC_BUNDLE_NAME,
          this.allSceneMenuItemInfo.multipleContentResourceName), this.allSceneMenuItemInfo.firstDeviceName);
    }
    this.refreshLanguageCount++;
  }

  static getAllSceneMenuInfoFromSettings(context: Context): Nullable<AllSceneMenuItemInfo> {
    try {
      let allSceneMenuItemInfoSettings: string =
        SettingsDataUtils.getSettingsDataWithContext(context, SystemUpdateConstants.ALL_SCENE_MENU_ITEM_INFO, '');
      let allSceneMenuItemInfo = FormatUtils.parseJson<AllSceneMenuItemInfo>(allSceneMenuItemInfoSettings);
      LogUtil.showInfo(TAG, `getAllSceneMenuInfoFromSettings, menuItemInfoSettings: ${allSceneMenuItemInfoSettings}`);
      return allSceneMenuItemInfo;
    } catch (err) {
      LogUtil.showError(TAG, `getAllSceneMenuInfoFromSettings failed, code: ${err?.code}, message: ${err?.message}`);
      return undefined;
    }
  }

  private async refreshAllSceneMenuItemInfo(allSceneMenuItemInfo: Nullable<AllSceneMenuItemInfo>): Promise<void> {
    try {
      this.allSceneMenuItemInfo = allSceneMenuItemInfo;
      this.buildMenuContent();
      this.isPrivacyUser = await AccountUtil.isCurrentPrivate();
      this.setMenuItemShowOrHide();
    } catch (error) {
      LogUtil.showError(TAG, `refreshAllSceneMenuItemInfo failed. code: ${error?.code}, message: ${error?.message}`);
    }
  }

  /**
   * 获取协同更新入口菜单信息
   */
  getAllSceneMenuItemInfo(): Nullable<AllSceneMenuItemInfo> {
    return this.allSceneMenuItemInfo;
  }

  /**
   * 协同更新入口变更监听器名称
   *
   * @return 监听器名称
   */
  getListenName(): string {
    return TAG;
  }

  /**
   * 协同更新入口变更监听器回调
   */
  onAllSceneUpdateBadgeChange(): void {
    LogUtil.showInfo(TAG, 'onAllSceneUpdateBadgeChange');
    let context: Context = SettingsDataUtils.getContext();
    this.refreshAllSceneMenuItemInfo(AllSceneMenuItemController.getAllSceneMenuInfoFromSettings(context));
  }
}

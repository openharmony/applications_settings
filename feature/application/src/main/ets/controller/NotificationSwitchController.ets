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
import configPolicy from '@ohos.configPolicy';
import { notificationManager } from '@kit.NotificationKit';
import { CompCtrlParam, ComponentControl } from '@ohos/settings.common/src/main/ets/framework/model/SettingBaseModel';
import { LogUtil } from '@ohos/settings.common/src/main/ets/utils/LogUtil';
import { EventBus } from '@ohos/settings.common/src/main/ets/framework/common/EventBus';
import { HiSysEventUtil } from '@ohos/settings.common/src/main/ets/systemEvent/HiSysEventUtil';
import {
  HiSysApplicationsAndServicesEventGroup
} from '@ohos/settings.common/src/main/ets/systemEvent/BehaviorEventConsts';
import { notifyCompStateChange,
  SettingBaseState,
  SettingResultState,
  SettingStateType,
  SettingToggleState} from '@ohos/settings.common/src/main/ets/framework/model/SettingStateModel';
import { ItemResultType } from '@ohos/settings.common/src/main/ets/framework/model/SettingItemModel';
import { INotificationConfig, SettingAppItemModel } from '../model/SettingAppItemModel';
import { AppEntry } from '../AppModel';

const TAG = 'NotificationSwitchController: ';

/**
 * 通知应用管理控制器
 *
 * @since 2024-10-30
 */
export class NotificationSwitchController implements ComponentControl {
  private compId: string = '';
  private entry: AppEntry | null = null;
  private isChecked: boolean = true;

  private refreshData = (entry: AppEntry) => {
    if (!entry) {
      LogUtil.error(`${TAG} appEntry is invalid`);
      return;
    }
    LogUtil.info(`${TAG} receive app change: ${entry.name}`);
    this.entry = entry;
    this.initData();
  }

  private toggleStateChangeEventCallback = (toggleState: SettingToggleState) => {
    if (!toggleState) {
      LogUtil.error(`${TAG} toggleModel is invalid`);
      return;
    }
    this.handleCheckedChange(toggleState.state);
  };

  init(compParam: CompCtrlParam): void {
    LogUtil.showInfo(TAG, 'onInit');
    if (!compParam || !compParam.compId) {
      LogUtil.error(`${TAG} init fail, compParam is invalid`);
      return;
    }
    this.compId = compParam.compId;
    let appItem: SettingAppItemModel = compParam.component as SettingAppItemModel;
    this.entry = appItem.entry as AppEntry;
    LogUtil.info(`${TAG} init ${this.entry?.name}`);
    if (this.entry) {
      this.refreshData(this.entry);
    }
    EventBus.getInstance().on(`${this.compId}.toggle`, this.toggleStateChangeEventCallback);
  }

  destroy(): void {
    LogUtil.showInfo(TAG, 'onDestroy');
    EventBus.getInstance().detach(`${this.compId}.toggle`, this.toggleStateChangeEventCallback);
  }

  /**
   * 开关变化的回调
   */
  private handleCheckedChange(isChecked: boolean): boolean {
    if (isChecked === this.isChecked) {
      LogUtil.info(`${TAG} handleCheckedChange isChecked not change : ${isChecked}`);
      return false;
    }
    const bundle: notificationManager.BundleOption = this.getBundleParams();
    LogUtil.info(`${TAG} set ${this.compId} handleCheckedChange ${isChecked}`);
    try {
      notificationManager.setNotificationEnable(bundle, isChecked).then(() => {
        this.isChecked = isChecked;
        HiSysEventUtil.reportDefaultBehaviorEventByUE(
          HiSysApplicationsAndServicesEventGroup.CLICK_RIGHTS_MANAGEMENT_SWITCH, isChecked ? 'on' : 'off');
        LogUtil.info(`${TAG} setNotificationEnable success`);
      });
    } catch (err) {
      LogUtil.error(`${TAG} setNotificationEnable fail: ${err?.message}`);
    }

    return true;
  }

  private getBundleParams(): notificationManager.BundleOption {
    const bundleName = this.entry?.name as string;
    const appUid = this.entry?.appInfo?.uid as number;
    const bundle: notificationManager.BundleOption = { bundle: bundleName, uid: appUid };
    return bundle;
  }

  private async initData(): Promise<void> {
    LogUtil.info(`${TAG} initData ${this.compId}`);
    await this.getMetaServiceInformStatus();
    this.updateSwitchState(this.isChecked);
  }

  private updateSwitchState(state: boolean) {
    notifyCompStateChange(`${this.compId}`, new Map<SettingStateType, SettingBaseState>(
      [[SettingStateType.STATE_TYPE_ITEM_RESULT, { type: ItemResultType.RESULT_TYPE_TOGGLE,
        result: { state: state } as SettingToggleState } as SettingResultState]]
    ));
  }

  private async getMetaServiceInformStatus(): Promise<void> {
    const bundle: notificationManager.BundleOption = this.getBundleParams();
    try {
      this.isChecked = await notificationManager.isNotificationEnabled(bundle);
    } catch (err) {
      LogUtil.error(`${TAG} isNotificationEnabled fail: ${err?.message}`);
    }
  }
}

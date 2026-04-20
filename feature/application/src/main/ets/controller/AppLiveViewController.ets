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

import { notificationManager } from '@kit.NotificationKit';
import { EventBus } from '@ohos/settings.common/src/main/ets/framework/common/EventBus';
import {
  CompCtrlParam,
  ComponentControl,
} from '@ohos/settings.common/src/main/ets/framework/model/SettingBaseModel';
import { LogUtil } from '@ohos/settings.common/src/main/ets/utils/LogUtil';
import { notifyCompStateChange,
  SettingBaseState,
  SettingResultState,
  SettingStateType,
  SettingToggleState} from '@ohos/settings.common/src/main/ets/framework/model/SettingStateModel';
import { ItemResultType } from '@ohos/settings.common/src/main/ets/framework/model/SettingItemModel';
import { HiSysEventUtil } from '@ohos/settings.common/src/main/ets/systemEvent/HiSysEventUtil';
import {
  HiSysApplicationsAndServicesEventGroup
} from '@ohos/settings.common/src/main/ets/systemEvent/BehaviorEventConsts';
import { SettingAppItemModel } from '../model/SettingAppItemModel';
import { AppEntry } from '../AppModel';
/* instrument ignore file */
const TAG = 'AppLiveViewController';

export class AppLiveViewController implements ComponentControl {
  private compId: string = '';
  private entry: AppEntry | null = null;
  private isLiveViewSwitchStatus: boolean = false;
  private isChecked: boolean = false;

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

  private refreshSwitchData = (status: boolean) => {
    LogUtil.info(`${TAG} receive switch change: ${status}`);
    this.initData();
  }

  init(compParam: CompCtrlParam): void {
    LogUtil.showInfo(TAG, 'onInit');
    if (!compParam || !compParam.compId) {
      LogUtil.error(`${TAG} init fail, compParam is invalid`);
      return;
    }
    this.compId = compParam.compId;
    let appItem: SettingAppItemModel = compParam.component as SettingAppItemModel;
    this.entry = appItem.entry as AppEntry;
    if (this.entry) {
      this.refreshData(this.entry);
    }
    EventBus.getInstance().on('EVENT_ID_APP_LIVE_SWITCH_CHANGE', this.refreshSwitchData);
    EventBus.getInstance().on(`${this.compId}.toggle`, this.toggleStateChangeEventCallback);
  }

  destroy(): void {
    LogUtil.showInfo(TAG, 'onDestroy');
    EventBus.getInstance().detach('EVENT_ID_APP_LIVE_SWITCH_CHANGE', this.refreshSwitchData);
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
    LogUtil.info(`${TAG} Set ${this.compId} handleCheckedChange ${isChecked}`);
    const bundleName = this.entry?.name as string;
    const appUid = this.entry?.appInfo?.uid as number;
    const bundle: notificationManager.BundleOption = { bundle: bundleName, uid: appUid };
    const slotType = notificationManager.SlotType.LIVE_VIEW;
    try {
      notificationManager.setNotificationEnableSlot(bundle, slotType, isChecked, true).then(() => {
        this.report(isChecked);
        LogUtil.info(`${TAG} Set ${bundleName} live view switch to ${isChecked} success`);
      });
    } catch (err) {
      LogUtil.error(`${TAG} Set ${bundleName} live view switch to ${isChecked} fail: ${err?.message}`);
    }
    return true;
  }

  /**
   * 打点
   * @param isChecked
   */
  protected report(isChecked: boolean): void {
    const param: Record<string, Object> = {};
    param.PACKAGE = this.entry?.name as string;
    param.STATUS = isChecked ? 'on' : 'off';
    HiSysEventUtil.reportBehaviorEventByUE(HiSysApplicationsAndServicesEventGroup.CLICK_LIVE_VIEW_SWITCH, param);
  }

  private async getAppLiveViewSwitchStatus(bundleName: string, uid: number): Promise<void> {
    let bundle: notificationManager.BundleOption = {
      bundle: bundleName,
      uid: uid
    };
    try {
      this.isLiveViewSwitchStatus = await notificationManager.isNotificationSlotEnabled(
        bundle, notificationManager.SlotType.LIVE_VIEW);
    } catch (err) {
      LogUtil.error(`${TAG} Get ${bundleName} live view switch fail: ${err?.message}`);
    }
  }

  private async initData(): Promise<void> {
    await this.getAppLiveViewSwitchStatus(this.entry?.name as string, this.entry?.appInfo?.uid as number);
    this.isChecked = this.isLiveViewSwitchStatus;
    this.updateSwitchState(this.isLiveViewSwitchStatus);
  }

  private updateSwitchState(state: boolean) {
    notifyCompStateChange(`${this.compId}`, new Map<SettingStateType, SettingBaseState>(
      [[SettingStateType.STATE_TYPE_ITEM_RESULT, { type: ItemResultType.RESULT_TYPE_TOGGLE,
        result: { state: state } as SettingToggleState } as SettingResultState]]
    ));
  }
}

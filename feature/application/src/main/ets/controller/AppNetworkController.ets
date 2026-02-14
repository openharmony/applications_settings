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

import { policy } from '@kit.NetworkKit';
import { BusinessError } from '@kit.BasicServicesKit';
import { call } from '@kit.TelephonyKit';
import { PushParam } from '@ohos/settings.common/src/main/ets/core/controller/Controller';
import { EventBus } from '@ohos/settings.common/src/main/ets/framework/common/EventBus';
import { DynamicDataSource } from '@ohos/settings.common/src/main/ets/framework/model/DynamicDataSource';
import {
  CompCtrlParam,
  ComponentControl
} from '@ohos/settings.common/src/main/ets/framework/model/SettingBaseModel';
import { ItemDetailType,
  ItemResultType,
  ItemType,
  SettingItemModel } from '@ohos/settings.common/src/main/ets/framework/model/SettingItemModel';
import { NavEntryKey } from '@ohos/settings.common/src/main/ets/utils/Consts';
import { LogUtil } from '@ohos/settings.common/src/main/ets/utils/LogUtil';
import { CheckEmptyUtils } from '@ohos/settings.common/src/main/ets/utils/CheckEmptyUtils';
import { PageRouter } from '@ohos/settings.common/src/main/ets/framework/common/PageRouter';
import { DeviceUtil } from '@ohos/settings.common/src/main/ets/utils/BaseUtils';
import { notifyCompStateChange,
  SettingBaseState,
  SettingCompState,
  SettingResultState,
  SettingStateType } from '@ohos/settings.common/src/main/ets/framework/model/SettingStateModel';
import { AppDataModel, SettingAppGroupModel } from '../model/SettingAppItemModel';
import { AppEntry } from '../AppModel';

const TAG = 'AppNetworkController';
const ATOMIC_SERVICE: number = 1;

export class AppNetworkController implements ComponentControl {
  private compId: string = '';
  private dataSource: DynamicDataSource = new DynamicDataSource();
  private entry: AppEntry | null = null;
  private networkingState: ResourceStr = '';

  private refreshData = (entry: AppEntry) => {
    /* instrument ignore if*/
    if (!entry) {
      LogUtil.error(`${TAG} appEntry is invalid`);
      return;
    }
    LogUtil.info(`${TAG} receive app change: ${entry.name}`);
    this.entry = entry;
    this.initNetwork();
  }

  private refreshState = () => {
    LogUtil.info(`${TAG} refreshState`);
    this.setAppNetworkingMenu();
  }

  init(compParam: CompCtrlParam): void {
    LogUtil.showInfo(TAG, `onInit`);
    /* instrument ignore if*/
    if (!compParam || !compParam.compId || DeviceUtil.isDevicePc()) {
      LogUtil.error(`${TAG} init fail, compParam is invalid or is pc`);
      return;
    }
    this.compId = compParam.compId;
    this.dataSource = compParam.dataSource as DynamicDataSource;
    let appItem: SettingAppGroupModel = compParam.component as SettingAppGroupModel;
    this.entry = appItem.entry as AppEntry;
    if (this.entry) {
      this.refreshData(this.entry);
    }
    EventBus.getInstance().on('EVENT_ID_APP_DETAIL_PAGE_SHOW', this.refreshState);
  }

  destroy(): void {
    LogUtil.showInfo(TAG, 'onDestroy');
    EventBus.getInstance().detach('EVENT_ID_APP_DETAIL_PAGE_SHOW', this.refreshState);
  }

  private async initNetwork(): Promise<void> {
    /* instrument ignore if*/
    if (!this.entry) {
      LogUtil.error(`${TAG} entry invalid`);
      return;
    }
    let isSystemApp: boolean | undefined = this.entry?.appInfo?.systemApp;
    let isAtomicService: boolean = this.entry?.appInfo?.bundleType === ATOMIC_SERVICE;
    LogUtil.info(`${TAG} entry application_networking_entry: ${isSystemApp} ${isAtomicService}`);
    // 非系统应用，非元服务才展示应用联网入口
    let isEntryVisible: boolean = !isSystemApp && !isAtomicService;
    this.setVisible(isEntryVisible);
    if (isEntryVisible) {
      this.setAppNetworkingMenu();
      this.dataSource.splice(0, this.dataSource.length);
      LogUtil.info(`${TAG} entry application_networking_entry: ${this.entry?.name}`);
      this.dataSource.pushData(this.createItem(() => {
        LogUtil.info(`${TAG} entry application_networking_entry: ${this.entry?.name}`);
        PageRouter.push(NavEntryKey.APPLICATION_NETWORKING_ENTRY, this.parsePushParam());
      }));
    }
  }

  private parsePushParam(): PushParam {
    let pushParam: PushParam = new PushParam();
    pushParam.config = {
      bundleName: this.entry?.name,
      uid: this.entry?.appInfo?.uid,
    } as AppDataModel;
    pushParam.bundleName = this.entry?.name;
    return pushParam;
  }

  private setAppNetworkingMenu(): void {
    let uid: number | undefined = this.entry?.appInfo?.uid;
    if (CheckEmptyUtils.isEmpty(uid)) {
      LogUtil.error(`${TAG} uid is empty or undefined.`);
      return;
    }
    try {
      policy.getNetworkAccessPolicy(uid).then((data: policy.NetworkAccessPolicy) => {
        LogUtil.info(`${TAG} getNetworkAccessPolicy for ${this.entry?.name} success`);
        let isMobileDataAvailable: boolean = call.hasVoiceCapability();
        let wifiAccess = data.allowWiFi as boolean;
        let cellularAccess = data.allowCellular as boolean;
        if (wifiAccess && !cellularAccess) {
          this.networkingState = $r('app.string.app_networking_wlan_only');
        } else if (!wifiAccess && cellularAccess) {
          this.networkingState = isMobileDataAvailable ? $r('app.string.app_networking_cellular_only') : ' ';
        } else if (wifiAccess && cellularAccess) {
          this.networkingState = isMobileDataAvailable ? $r('app.string.app_networking_wlan_and_cellular') : $r('app.string.app_networking_wlan_only');
        } else {
          this.networkingState = ' ';
        }
        notifyCompStateChange('Setting.AppDetail.AppNetworkGroup.AppNetwork',
          new Map<SettingStateType, SettingResultState>([[SettingStateType.STATE_TYPE_ITEM_RESULT,
            {
              type: ItemResultType.RESULT_TYPE_TEXT,
              result: { content: this.networkingState
            } } as SettingResultState]]));
      })
        .catch((err: BusinessError) => {
          LogUtil.error(`${TAG} getNetworkAccessPolicy failed. ${err?.code} ${err?.message}`);
        });
    } catch (error) {
      LogUtil.error(`${TAG} failed to get networking policy, because: ${error?.code} ${error?.message}`);
    }
  }

  private createItem(onItemClick: () => void): SettingItemModel {
    LogUtil.info(`${TAG} createItem for ${this.entry?.name} ${this.networkingState}`);
    return {
      id: 'AppNetwork',
      type: ItemType.ITEM_TYPE_STANDARD,
      title: { content: $r('app.string.app_info_networking') },
      result: {
        type: ItemResultType.RESULT_TYPE_TEXT,
        result: {
          content: this.networkingState,
        }
      },
      detail: {
        type: ItemDetailType.DETAIL_TYPE_CUSTOM,
        icon: $r('sys.symbol.chevron_right'),
        isSymbolIcon: true,
        onItemClick: () => {
          onItemClick();
        }
      }
    }
  }

  private setVisible(isShow: boolean) {
    notifyCompStateChange('Setting.AppDetail.AppNetworkGroup',
      new Map<SettingStateType, SettingBaseState>([[SettingStateType.STATE_TYPE_GROUP_VISIBLE, {
        state: isShow
      } as SettingCompState]]));
  }
}

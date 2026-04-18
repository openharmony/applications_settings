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

import Want from '@ohos.app.ability.Want';
import bundle from '@ohos.bundle.bundleManager';
import { LogUtil } from '@ohos/settings.common/src/main/ets/utils/LogUtil';
import { PreferencesUtil } from '@ohos/settings.common/src/main/ets/utils/PreferencesUtil';
import { NavEntryKey } from '@ohos/settings.common/src/main/ets/utils/Consts';
import { CommonUtils } from '@ohos/settings.common/src/main/ets/utils/CommonUtils';
import { CurrentMemScene, PerformanceReporter } from '@ohos/settings.common/src/main/ets/memery/PerformanceReporter';
import { EventBus } from '@ohos/settings.common/src/main/ets/framework/common/EventBus';
import { EVENT_ID_BUNDLE_RESOURCES_CHANGED } from '@ohos/settings.common/src/main/ets/event/types';
import { AppListLoader } from '../AppListLoader';
import { MoreAppListLoader } from '../MoreAppListLoader';

const TAG = 'ApplicationController';
const MAIL_LIST_DATA: string = 'mail_list_data';
const BROWSER_LIST_DATA: string = 'browser_list_data';

export class ApplicationController {
  private onBundleResourcesChangedCallback = (isChanged: boolean): void => {
    LogUtil.info(`${TAG} bundle resources changed: ${isChanged}`);
    if (isChanged) {
      this.setMailList();
      this.setBrowserList();
    }
  }

  init(): void {
    LogUtil.info(`${TAG} init`);
    this.setMailList();
    this.setBrowserList();
    AppListLoader.getInstance().loadAppList();
    AppListLoader.getInstance().subscribeBundleResourcesChangeEvents();
    EventBus.getInstance().on(EVENT_ID_BUNDLE_RESOURCES_CHANGED, this.onBundleResourcesChangedCallback);
    PerformanceReporter.getInstance().reportEnterMemScene(CurrentMemScene.START_APPLICATION);
  }

  destroy(): void {
    LogUtil.info(`${TAG} onDestroy`);
    if (CommonUtils.isPageExist(NavEntryKey.APPLICATION_SERVICE_ENTRY)) {
      LogUtil.info(`${TAG} the page exist, not destroy`);
      return;
    }
    EventBus.getInstance().detach(EVENT_ID_BUNDLE_RESOURCES_CHANGED, this.onBundleResourcesChangedCallback);
    AppListLoader.getInstance().unSubscribeBundleResourcesChangeEvents();
    MoreAppListLoader.getInstance().unSubscribeBundleResourcesChangeEvents();
    PerformanceReporter.getInstance().reportExitMemScene(CurrentMemScene.START_APPLICATION);
  }

  private async setBrowserList(): Promise<void> {
    try {
      let browserList = await bundle.queryAbilityInfo({
        'action': 'ohos.want.action.viewData',
        'entities': ['entity.system.browsable'],
        'uri': 'http'
      }, bundle.AbilityFlag.GET_ABILITY_INFO_WITH_APPLICATION)
      LogUtil.info(`${TAG} get browser list success ${browserList?.length}`);
      await this.storeData(BROWSER_LIST_DATA, browserList);
      EventBus.getInstance().emit('EVENT_ID_BROWSER_LIST_CHANGE_EVENTS');
    } catch (error) {
      LogUtil.error(`${TAG} query browser list catch, error: ${error?.message}`);
    }
  }

  private async setMailList(): Promise<void> {
    LogUtil.info(`${TAG} Get default mail list`);
    let want: Want = {
      'action': 'ohos.want.action.sendToData',
      'uri': 'mailto',
    }
    try {
      let mailLists = await bundle.queryAbilityInfo(want,
        bundle.AbilityFlag.GET_ABILITY_INFO_WITH_APPLICATION);
      LogUtil.info(`${TAG} get mail list success ${mailLists?.length}`);
      await this.storeData(MAIL_LIST_DATA, mailLists);
      EventBus.getInstance().emit('EVENT_ID_MAIL_LIST_CHANGE_EVENTS');
    } catch (error) {
      LogUtil.error(`${TAG} query mail list catch, error : ${error.message}`);
    }
  }

  private storeData(key: string, list: Array<bundle.AbilityInfo>) {
    let value: string = JSON.stringify(list);
    PreferencesUtil.put(key, value);
  }
}
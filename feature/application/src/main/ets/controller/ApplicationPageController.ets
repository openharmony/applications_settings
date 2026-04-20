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

import { LogUtil, LogMaskUtil } from '@ohos/settings.common/src/main/ets/utils/LogUtil';
import { EventBus } from '@ohos/settings.common/src/main/ets/framework/common/EventBus';
import {
  ComponentControl,
  SettingBaseModel
} from '@ohos/settings.common/src/main/ets/framework/model/SettingBaseModel';
import { EVENT_ID_SEARCH_BAR_VISIBLE, } from '@ohos/settings.common/src/main/ets/event/types';
import { isMatchKeyWord } from '@ohos/settings.common/src/main/ets/utils/ApplicationUtil';
import { EVENT_ID_BUNDLE_RESOURCES_CHANGED } from '@ohos/settings.common/src/main/ets/event/types';
import { DeviceUtil } from '@ohos/settings.common/src/main/ets/utils/BaseUtils';
import { AppManager, LanguageStatus } from '../util/AppManager';
import { AppListLoader } from '../AppListLoader';
import { AppEntry } from '../AppModel';
import { SearchBundleListController } from './SearchBundleListController';

/* instrument ignore file */
const TAG = 'ApplicationPageController';

export class ApplicationPageController implements ComponentControl {
  private isPC: boolean = DeviceUtil.isDevicePc();
  private isSearching: boolean = false;
  private keyWord: string = '';
  private searchControllers: Array<SearchBundleListController> = [];
  private onClickSearchBack?: () => void = () => {
  };
  private searchBarEventCb = (isSearching: boolean, coverVisible: boolean, searchWord: string) => {
    this.isSearching = isSearching;
  }
  private searchKeyWord = (value: string) => {
    LogUtil.info(`${TAG} searchKeyWord ${LogMaskUtil.getLogNickNameString(value)}`);
    this.keyWord = value;
    this.loadData();
  }
  private onBundleResourcesChangedCallback = (isChanged: boolean) => {
    LogUtil.info(`${TAG} bundle resources changed: ${isChanged}`);
    if (isChanged) {
      this.loadData();
    }
  }

  constructor(onClickSearchBack?: () => void) {
    this.onClickSearchBack = onClickSearchBack;
  }

  init(): void {
    EventBus.getInstance().on('EVENT_ID_APP_LIST_SEARCH_LOADER', this.searchKeyWord);
    EventBus.getInstance().on(EVENT_ID_BUNDLE_RESOURCES_CHANGED,
      this.onBundleResourcesChangedCallback);
    EventBus.getInstance().on(EVENT_ID_SEARCH_BAR_VISIBLE, this.searchBarEventCb);
  }

  destroy(): void {
    EventBus.getInstance().detach('EVENT_ID_APP_LIST_SEARCH_LOADER', this.searchKeyWord);
    EventBus.getInstance().detach(EVENT_ID_BUNDLE_RESOURCES_CHANGED, this.onBundleResourcesChangedCallback);
    EventBus.getInstance().detach(EVENT_ID_SEARCH_BAR_VISIBLE, this.searchBarEventCb);
  }

  onBackPressed(component: SettingBaseModel): boolean {
    // 不在应用和元服务搜索界面点击返回按钮或者侧滑返回时，不用单独处理
    if (!this.isSearching || this.isPC) {
      LogUtil.showInfo(TAG, 'not in search page');
      return false;
    }
    if (this.onClickSearchBack) {
      this.onClickSearchBack();
      LogUtil.showInfo(TAG, 'callback and in search page');
    }
    return true;
  }

  private loadData(): void {
    let isLanguageChanging: boolean =
      AppManager.getInstance().getLanguageChangingStatus('') === LanguageStatus.CHANGING;
    if (isLanguageChanging) {
      LogUtil.error(`${TAG} language is changing ${isLanguageChanging}`);
      return;
    }
    let searchAppList: AppEntry[] = this.searchAppByKeyWord();
    for (let searchController of this.searchControllers) {
      searchController.loadData(searchAppList, this.keyWord);
    }
  }

  private searchAppByKeyWord(): AppEntry[] {
    let searchAppList: AppEntry[] = [];
    if (this.keyWord.trim().length == 0) {
      LogUtil.error(`${TAG} keyWord is empty`);
      return searchAppList;
    }
    let appList: AppEntry[] = AppListLoader.getInstance().getAppListCache();
    appList.forEach((item) => {
      if (item.label) {
        if (isMatchKeyWord(item.label, this.keyWord)) {
          searchAppList.push(item);
        }
      }
    })
    return searchAppList;
  }

  public registerController(searchController: SearchBundleListController) {
    this.searchControllers.push(searchController);
  }
}
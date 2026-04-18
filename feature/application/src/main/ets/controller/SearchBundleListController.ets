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

import intl from '@ohos.intl';
import { PushParam } from '@ohos/settings.common/src/main/ets/core/controller/Controller';
import { PageStartReason } from '@ohos/settings.common/src/main/ets/data/types';
import { AppGroupType } from '@ohos/settings.common/src/main/ets/utils/Consts';
import { EventBus } from '@ohos/settings.common/src/main/ets/framework/common/EventBus';
import { PageRouter } from '@ohos/settings.common/src/main/ets/framework/common/PageRouter';
import { OrderedDataSource } from '@ohos/settings.common/src/main/ets/framework/model/OrderedDataSource';
import {
  CompCtrlParam,
  ComponentControl,
  SettingBaseModel
} from '@ohos/settings.common/src/main/ets/framework/model/SettingBaseModel';
import {
  ComparableSettingItemModel,
  ItemDetailType,
  ItemType,
  SettingIconType,
  SettingItemModel
} from '@ohos/settings.common/src/main/ets/framework/model/SettingItemModel';
import { CheckEmptyUtils } from '@ohos/settings.common/src/main/ets/utils/CheckEmptyUtils';
import { NavEntryKey } from '@ohos/settings.common/src/main/ets/utils/Consts';
import { LogUtil, LogMaskUtil } from '@ohos/settings.common/src/main/ets/utils/LogUtil';
import { PageStartModeManager } from '@ohos/settings.common/src/main/ets/window/PageStartModeManager';
import { HiSysEventUtil } from '@ohos/settings.common/src/main/ets/systemEvent/HiSysEventUtil';
import { isMatchKeyWord } from '@ohos/settings.common/src/main/ets/utils/ApplicationUtil';
import { AppListLoader } from '../AppListLoader';
import { AppEntry } from '../AppModel';
import { AppUtils } from '../AppUtils';
import { AppCloneBadgeComponent } from '../components/AppCloneBadgeComponent';
import { AppEntryUtil } from '../util/AppEntryUtil';
/* instrument ignore file */
const TAG: string = 'SearchBundleListController: ';

@Builder
function appCloneBadgeBuilder(param: object): void {
  AppCloneBadgeComponent({
    appCloneBadgeParam: param as SettingItemModel,
    iconSize: 48,
    bundleName: ((param as SettingItemModel)?.extra as AppEntry)?.name
  })
}

export class SearchBundleListController implements ComponentControl {
  private static searchCount: number = 0;
  private dataSource?: OrderedDataSource;
  private id?: string;
  private keyWord: string = '';
  private menuCache: ComparableSettingItemModel[] = [];
  private appListAddEventCb = (data: object) => {
    LogUtil.info(`${TAG} app list add`);
    let appEntry = data as AppEntry;
    if (appEntry) {
      this.onAppAdd(appEntry);
    }
  };
  private appListRemoveCb = (data: object, appIndex: number) => {
    LogUtil.info(`${TAG} app list remove`);
    let bundleName = (data as String).toString();
    if (bundleName) {
      this.onAppRemoved(bundleName, appIndex);
    }
  };

  init(compParam: CompCtrlParam): void {
    LogUtil.info(`${TAG} init`);
    this.id = compParam.component.id;
    this.dataSource = compParam.dataSource as OrderedDataSource;
    EventBus.getInstance().on('EVENT_ID_APP_LIST_ADD', this.appListAddEventCb);
    EventBus.getInstance().on('EVENT_ID_APP_LIST_REMOVE', this.appListRemoveCb);
  };

  destroy(): void {
    LogUtil.info(`${TAG} destory`);
    EventBus.getInstance().detach('EVENT_ID_APP_LIST_ADD', this.appListAddEventCb);
    EventBus.getInstance().detach('EVENT_ID_APP_LIST_REMOVE', this.appListRemoveCb);
  }

  private onAppAdd(appEntry: AppEntry): void {
    if (appEntry.label && isMatchKeyWord(appEntry.label, this.keyWord)) {
      let flag: boolean = this.filterByGroup(appEntry);
      if (!flag) {
        return;
      }
      this.pushDataToDataSource(appEntry);
      SearchBundleListController.searchCount++;
      this.onSearchCountUpdate();
    }
  }

  private filterByGroup(appEntry: AppEntry): boolean {
    let flag: boolean = false;
    switch (this.id) {
      case AppGroupType.SYSTEM:
        flag = AppListLoader.getInstance().getAppType(appEntry) === 'systemApp';
        break;
      case AppGroupType.UN_SYSTEM:
        flag = AppListLoader.getInstance().getAppType(appEntry) === 'unSystemApp';
        break;
      case AppGroupType.SERVICE:
        flag = AppListLoader.getInstance().getAppType(appEntry) === 'meetaApp';
        break;
      case AppGroupType.CONTAINER:
        flag = AppListLoader.getInstance().getAppType(appEntry) === 'containerApp';
        break;
      default:
        break;
    }
    return flag;
  }

  private pushDataToDataSource(appEntry: AppEntry): void {
    let item: ComparableSettingItemModel = this.creatItemData(appEntry);
    this.dataSource?.pushData(item);
  }

  private onAppRemoved(bundleName: string, appIndex: number): void {
    let index: number = this.dataSource?.findIndex(item => item.id === AppUtils.getAppKey(bundleName, appIndex)) ?? -1;
    if (index !== -1) {
      LogUtil.info(`${TAG} remove app, name: ${bundleName}, appIndex: ${appIndex}`);
      this.dataSource?.removeDataByIndex(index);
      SearchBundleListController.searchCount--;
      this.onSearchCountUpdate();
    }
  }

  private onSearchCountUpdate(): void {
    EventBus.getInstance().emit('EVENT_ID_SEARCH_EMPTY', SearchBundleListController.searchCount === 0);
  }

  public loadData(searchAppList: AppEntry[], keyWork: string): void {
    this.keyWord = keyWork;
    SearchBundleListController.searchCount = searchAppList.length;
    let filterAppList: AppEntry[] = searchAppList.filter(appEntry => this.filterByGroup(appEntry));
    const searchKey: string = LogMaskUtil.getLogNickNameString(this.keyWord);
    LogUtil.info(`${TAG} ,serach key:${searchKey},slength:${searchAppList.length}, flength:${filterAppList.length}`);
    this.onSearchCountUpdate();
    if (filterAppList.length > 0) {
      this.updateData(filterAppList);
    } else {
      this.clearDataArray();
    }
  }

  private updateData(appList: AppEntry[]): void {
    const searchKey: string = LogMaskUtil.getLogNickNameString(this.keyWord);
    LogUtil.info(`${TAG} ,serach key:${searchKey},slength:${appList.length}, dlength:${this.dataSource?.length}`);
    this.menuCache = [];
    this.clearDataArray();
    appList.forEach((item) => {
      this.menuCache.push(this.creatItemData(item));
    })
    this.pushDataArray();
  }

  private creatItemData(appEntry: AppEntry): ComparableSettingItemModel {
    return {
      id: AppUtils.getAppKey(appEntry.name, appEntry.appIndex),
      subId: new Date().getTime().toString(),
      type: ItemType.ITEM_TYPE_STANDARD,
      icon: {
        icon: appEntry.icon as ResourceStr,
        iconType: SettingIconType.ICON_TYPE_APPICON,
        style: {
          border: { width: '0px', color: '#00000000', radius: 0 },
          borderRadius: 0,
          width: 48,
          height: 48,
          mirrored: false,
          draggable: false
        },
        builder: AppEntryUtil.isAppCloneBadge(appEntry) || (this.id === AppGroupType.CONTAINER)
          ? wrapBuilder(appCloneBadgeBuilder) : undefined
      },
      title: { content: appEntry?.label ?? '' },
      compare: (dst: ComparableSettingItemModel) => {
        let collator = new intl.Collator();
        return collator.compare((dst.title?.content ?? '').toString(), (appEntry?.label ?? '').toString());
      },
      desc: { content: '' },
      detail: {
        type: ItemDetailType.DETAIL_TYPE_CUSTOM,
        icon: $r('sys.symbol.chevron_right'),
        isSymbolIcon: true,
        onItemClick: (component: SettingBaseModel) => {
          this.onHandlerItemClick(component);
        },
      },
      extra: appEntry
    }
  }

  protected onHandlerItemClick(e: SettingBaseModel): void {
    LogUtil.info(`${TAG} AppEntryController onMenuClick ${e.id}`);
    const APP_INFO_ENTRY: string = 'app_info_entry';
    HiSysEventUtil.reportEntryEvent(APP_INFO_ENTRY, e.id);
    let checkedApp: ComparableSettingItemModel =
      this.dataSource?.find(i => i.id === e.id) as ComparableSettingItemModel;
    AppStorage.setOrCreate('currentAppName', checkedApp?.title?.content);
    PageStartModeManager.getInstance().setStartReason(PageStartReason.DEFAULT);
    PageRouter.push(NavEntryKey.APPLICATION_INFO_ENTRY, this.parsePushParamFromAppKey(e.id));
  }

  private parsePushParamFromAppKey(key: string): PushParam {
    let pushParam: PushParam = new PushParam();
    if (CheckEmptyUtils.isEmpty(key)) {
      return pushParam;
    }
    let paramArray: string[] = key.split(',');
    if (!paramArray || paramArray.length < 1) {
      LogUtil.info(`${TAG} param ia invalid: ${key}`);
      return pushParam;
    } else {
      pushParam.config = paramArray[0];
      let index = Number(paramArray[1]);
      pushParam.appIndex = (Number.isNaN(index) || index < 0) ? 0 : index;
      return pushParam;
    }
  }

  private pushDataArray(): void {
    if (!this.dataSource) {
      return;
    }
    this.dataSource.pushDataArray(this.menuCache);
  }

  private clearDataArray(): void {
    if (!this.dataSource) {
      return;
    }
    this.dataSource.removeAll();
  }
}
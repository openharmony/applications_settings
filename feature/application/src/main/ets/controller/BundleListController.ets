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
import { AccountUtil } from '@ohos/settings.common/src/main/ets/utils/AccountUtil';
import { LogUtil } from '@ohos/settings.common/src/main/ets/utils/LogUtil';
import { NavEntryKey, AppGroupType } from '@ohos/settings.common/src/main/ets/utils/Consts';
import { TabIndexConstants } from '@ohos/settings.common/src/main/ets/constant/TabIndexConstants';
import { HiSysEventUtil } from '@ohos/settings.common/src/main/ets/systemEvent/HiSysEventUtil';
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
  SettingIconStyle,
  SettingIconType,
  SettingItemLayout,
  SettingItemModel
} from '@ohos/settings.common/src/main/ets/framework/model/SettingItemModel';
import { PageStartModeManager } from '@ohos/settings.common/src/main/ets/window/PageStartModeManager';
import { EventBus } from '@ohos/settings.common/src/main/ets/framework/common/EventBus';
import { PageStartReason } from '@ohos/settings.common/src/main/ets/data/types';
import { AppListLoader } from '../AppListLoader';
import { AppEntry, AppType } from '../AppModel';
import { AppUtils } from '../AppUtils';
import { AppCloneBadgeComponent } from '../components/AppCloneBadgeComponent';
import { AppEntryUtil } from '../util/AppEntryUtil';
import { ThemeManager } from '../util/ThemeManager';

const TAG: string = 'BundleListController';

@Builder
function appCloneBadgeBuilder(param: object): void {
  AppCloneBadgeComponent({
    appCloneBadgeParam: param as SettingItemModel,
    iconSize: 48,
    bundleName: ((param as SettingItemModel)?.extra as AppEntry)?.name
  })
}

export class BundleListController implements ComponentControl {
  private dataSource?: OrderedDataSource;
  private id?: string;
  private menuCache: ComparableSettingItemModel[] = [];
  private index: number = 0;
  private appListLoadEventCb = (data: Object) => {
    let eventData: string = (data === undefined || data === null) ? '' : data.toString();
    // 如果传回来一个空的字符串，则表示所有BundleListController示例都响应，否则只更新指定的列表
    if (eventData.length !== 0 && data !== this.id) {
      return;
    }
    this.onAppListChanged();
  };
  private appListAddEventCb = (data: object) => {
    LogUtil.info(`${TAG} app list add`);
    let appEntry = data as AppEntry;
    if (appEntry) {
      this.onAppListAdd(appEntry);
    }
  };
  private appListRemoveCb = (data: object, appIndex: number) => {
    LogUtil.info(`${TAG} app list remove`);
    let bundleName = (data as String).toString();
    if (bundleName) {
      this.onAppListRemove(bundleName, appIndex);
    }
  };

  private appListRemoveAllCb = () => {
    this.dataSource?.removeAll();
  }

  async init(compParam: CompCtrlParam): Promise<void> {
    LogUtil.info(`${TAG} init`);
    this.id = compParam.component.id;
    this.dataSource = compParam.dataSource as OrderedDataSource;
    EventBus.getInstance().on('EVENT_ID_APP_LIST_LOADER', this.appListLoadEventCb);
    EventBus.getInstance().on('EVENT_ID_APP_LIST_ADD', this.appListAddEventCb);
    EventBus.getInstance().on('EVENT_ID_APP_LIST_REMOVE', this.appListRemoveCb);
    EventBus.getInstance().on('EVENT_ID_APP_LIST_REMOVE_ALL', this.appListRemoveAllCb);
    AppStorage.setOrCreate('isCurrentPrivate', await AccountUtil.isCurrentPrivate());
  }

  destroy(): void {
    LogUtil.info(`${TAG} onDestroy`);
    EventBus.getInstance().detach('EVENT_ID_APP_LIST_LOADER', this.appListLoadEventCb);
    EventBus.getInstance().detach('EVENT_ID_APP_LIST_ADD', this.appListAddEventCb);
    EventBus.getInstance().detach('EVENT_ID_APP_LIST_REMOVE', this.appListRemoveCb);
    EventBus.getInstance().detach('EVENT_ID_APP_LIST_REMOVE_ALL', this.appListRemoveAllCb);
  }

  private onAppListChanged(): void {
    let filterAppList: AppEntry[] = AppListLoader.getInstance().getAppListCache(this.id);
    if (filterAppList.length > 0) {
      this.addMenu(filterAppList);
    } else {
      LogUtil.error(`${TAG} getAppList failed`);
    }
    this.onServiceCountUpdate();
    LogUtil.info(`${TAG} onAppListChanged , filterAppList: ${filterAppList.length}`);
  }

  private addMenu(appList: AppEntry[]): void {
    LogUtil.info(`${TAG} appList.length:${appList.length}, this.dataSource:${this.dataSource?.length}`)
    this.menuCache = [];
    appList.forEach((item, index) => {
      this.menuCache.push({
        id: AppUtils.getAppKey(item.name, item.appIndex),
        type: ItemType.ITEM_TYPE_STANDARD,
        subId: ThemeManager.getInstance().getCurrentThemeId(),
        icon: {
          icon: item.icon as ResourceStr,
          iconType: SettingIconType.ICON_TYPE_APPICON,
          // style: this.getIconStyle(),
          builder: AppEntryUtil.isAppCloneBadge(item) || (this.id === AppGroupType.CONTAINER)
            ? wrapBuilder(appCloneBadgeBuilder) : undefined
        },
        title: { content: item?.label ?? '' },
        compare: (dst: ComparableSettingItemModel) => {
          return 0;
        },
        desc: { content: '' },
        tabIndex: !index ? TabIndexConstants.TAB_INDEX_LEVEL2_PAGE : TabIndexConstants.TAB_INDEX_DEFAULT,
        detail: {
          type: ItemDetailType.DETAIL_TYPE_CUSTOM,
          icon: $r('sys.symbol.chevron_right'),
          isSymbolIcon: true,
          onItemClick: (component: SettingBaseModel) => {
            this.onHandlerItemClick(component);
          },
        },
        layout: this.getLayout(),
        extra: item
      })
    })
    this.dataSource?.splice(0, this.dataSource.length);
    this.refreshAllData();
  }

  private refreshAllData(): void {
    if (!this.dataSource) {
      return;
    }

    this.dataSource.push(...this.menuCache);
    this.dataSource.notifyDataReload();
  }

  protected getLayout(): SettingItemLayout | undefined {
    return undefined;
  }

  protected getIconStyle(): SettingIconStyle {
    // 接入了HDS之后，图标不需要主动做描边处理
    let style: SettingIconStyle = {
      border: { width: '0px', color: '#00000000', radius: 0 },
      borderRadius: 0,
      width: 48,
      height: 48,
      mirrored: false,
      draggable: false
    };
    return style;
  }

  private onHandlerItemClick(e: SettingBaseModel): void {
    LogUtil.info(`${TAG} AppEntryController onMenuClick ${e.id}`);
    const APP_INFO_ENTRY: string = 'app_info_entry';
    HiSysEventUtil.reportEntryEvent(APP_INFO_ENTRY, e.id);
    let checkedApp: ComparableSettingItemModel =
      this.dataSource?.find(i => i.id === e.id) as ComparableSettingItemModel;
    AppStorage.setOrCreate('currentAppName', checkedApp?.title?.content);
    PageStartModeManager.getInstance().setStartReason(PageStartReason.DEFAULT);
    PageRouter.push(NavEntryKey.APPLICATION_INFO_ENTRY, AppUtils.parsePushParamFromAppKey(e.id));
  }

  private onAppListAdd(appEntry: AppEntry): void {
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
    if (!flag) {
      return;
    }
    this.pushDataToDataSource(appEntry);
    this.onServiceCountUpdate();
  }

  private pushDataToDataSource(appEntry: AppEntry): void {
    let item: ComparableSettingItemModel = {
      id: AppUtils.getAppKey(appEntry?.name, appEntry?.appIndex),
      type: ItemType.ITEM_TYPE_STANDARD,
      icon: {
        icon: appEntry?.icon as ResourceStr,
        iconType: SettingIconType.ICON_TYPE_APPICON,
        style: this.getIconStyle(),
        builder: (this.id === AppGroupType.CONTAINER) ? wrapBuilder(appCloneBadgeBuilder) : undefined
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
    };
    this.dataSource?.pushData(item);
  }

  private onAppListRemove(bundleName: string, appIndex: number): void {
    let index = this.dataSource?.findIndex(item => item.id === AppUtils.getAppKey(bundleName, appIndex)) ?? -1;
    if (index !== -1) {
      LogUtil.info(`${TAG} remove app, name: ${bundleName}, appIndex: ${appIndex}`);
      this.dataSource?.removeDataByIndex(index);
      this.onServiceCountUpdate();
    }
  }

  private onServiceCountUpdate(): void {
    if (this.id === AppGroupType.SERVICE) {
      let curServiceCount = AppListLoader.getInstance().getAppListCache(AppType.SERVICE_APP).filter((menu) => {
        return menu.appInfo?.bundleType === 1;
      }).length;
      LogUtil.info(`${TAG} current service count: ${curServiceCount}`);
      EventBus.getInstance().emit('EVENT_ID_SERVICE_EMPTY', curServiceCount === 0);
    }
  }
}

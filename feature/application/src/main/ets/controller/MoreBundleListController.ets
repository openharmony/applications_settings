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

import emitter from '@ohos.events.emitter';
import intl from '@ohos.intl';
import { PushParam } from '@ohos/settings.common/src/main/ets/core/controller/Controller';
import { LogUtil } from '@ohos/settings.common/src/main/ets/utils/LogUtil';
import { EventBus } from '@ohos/settings.common/src/main/ets/framework/common/EventBus';
import { NavEntryKey } from '@ohos/settings.common/src/main/ets/utils/Consts';
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
  SettingIconType
} from '@ohos/settings.common/src/main/ets/framework/model/SettingItemModel';
import {
  EVENT_ID_BUNDLE_LIST_CHANGED,
  EVENT_ID_BUNDLE_REMOVE,
} from '@ohos/settings.common/src/main/ets/event/types';
import { PageStartModeManager } from '@ohos/settings.common/src/main/ets/window/PageStartModeManager';
import { PageStartReason } from '@ohos/settings.common/src/main/ets/data/types';
import { MoreAppListLoader } from '../MoreAppListLoader';
import { AppEntry } from '../AppModel';
/* instrument ignore file */
const TAG: string = 'MoreBundleListController';

export class MoreBundleListController implements ComponentControl {
  private dataSource?: OrderedDataSource;
  private appList?: AppEntry[];
  private id?: string;
  private appAddEventCallback = (data: AppEntry) => {
    let appEntry = data as AppEntry;
    if (appEntry) {
      LogUtil.info(`${TAG} appAddEventCallback ${appEntry.name}`);
      this.onAppListAdd(appEntry);
    }
  };

  async init(compParam: CompCtrlParam): Promise<void> {
    this.id = compParam.component.id;
    this.dataSource = compParam.dataSource as OrderedDataSource;

    this.registerAppListLoadEvent();
    this.registerAppListAddEvent();
    this.registerAppListRemoveEvent();
    EventBus.getInstance().on('EVENT_ID_MORE_APP_LIST_REMOVE_ALL', this.moreAppListRemoveAllCb);
    MoreAppListLoader.getInstance().loadAppList();
    MoreAppListLoader.getInstance().unRegisterStatusChange();
    MoreAppListLoader.getInstance().registerStatusChange();
  }

  destroy(): void {
    LogUtil.info(`${TAG} onDestroy`);
    emitter.off(EVENT_ID_BUNDLE_LIST_CHANGED);
    EventBus.getInstance().detach('EVENT_ID_BUNDLE_ADD', this.appAddEventCallback);
    emitter.off(EVENT_ID_BUNDLE_REMOVE);
    EventBus.getInstance().detach('EVENT_ID_MORE_APP_LIST_REMOVE_ALL', this.moreAppListRemoveAllCb);
  }

  private onAppListChanged(appList: Array<AppEntry>): void {
    if (!appList) {
      LogUtil.error(`${TAG} appList is empty, or language is changing`);
      return;
    }
    LogUtil.info(`${TAG} onAppListChanged length: ${appList.length}`);

    MoreAppListLoader.getInstance().notifyMoreAppListLoader(true);

    this.appList = appList;
    this.addMenu(this.appList);
  }

  onAppListAdd(appEntry: AppEntry): void {
    LogUtil.info(`${TAG} onAppListAdd`);
    let item: ComparableSettingItemModel = {
      id: appEntry.name,
      type: ItemType.ITEM_TYPE_STANDARD,
      icon: {
        icon: appEntry.icon as ResourceStr,
        iconType: SettingIconType.ICON_TYPE_APPICON,
        style: {
          border: { width: '0px', color: '#00000000', radius: 0 },
          borderRadius: 0,
          width: 48,
          height: 48,
          mirrored: false
        }
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
    };
    this.dataSource?.pushData(item);
  }

  onAppListRemove(bundleName: string): void {
    if (!bundleName) {
      LogUtil.error(`${TAG} onAppListRemove bundleName invalid`);
      return;
    }
    LogUtil.info(`${TAG} onAppListRemove, bundleName: ${bundleName}`);

    let item: ComparableSettingItemModel = {
      id: bundleName,
      type: ItemType.ITEM_TYPE_STANDARD,
    };
    this.dataSource?.removeData(item);
  }

  getListenerName(): string {
    return '';
  }

  public addMenu(appList: AppEntry[]): void {
    LogUtil.info(`${TAG} appList.length:${appList.length}, this.dataSource:${this.dataSource?.length}`)
    let items: ComparableSettingItemModel[] = [];
    appList.forEach((item) => {
      items.push({
        id: item.name,
        type: ItemType.ITEM_TYPE_STANDARD,
        icon: {
          icon: item.icon as ResourceStr,
          iconType: SettingIconType.ICON_TYPE_APPICON,
          style: {
            border: { width: '0px', color: '#00000000', radius: 0 },
            borderRadius: 0,
            width: 48,
            height: 48,
            mirrored: false
          }
        },
        title: { content: item?.label ?? '' },
        compare: (dst: ComparableSettingItemModel) => {
          return 0
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
      })
    })
    if (this.dataSource) {
      this.dataSource.length = 0;
      this.dataSource.pushDataArray(items);
    }
  }

  onHandlerItemClick(e: SettingBaseModel): void {
    LogUtil.info(`${TAG} AppEntryController onMenuClick ${e.id}`);
    const APP_INFO_ENTRY: string = 'app_info_entry';
    HiSysEventUtil.reportEntryEvent(APP_INFO_ENTRY, e.id);
    let checkedApp: ComparableSettingItemModel =
      this.dataSource?.find(i => i.id === e.id) as ComparableSettingItemModel;
    AppStorage.setOrCreate('currentAppName', checkedApp?.title?.content);
    PageStartModeManager.getInstance().setStartReason(PageStartReason.DEFAULT);
    PageRouter.push(NavEntryKey.APPLICATION_INFO_ENTRY,
      new PushParam(e.id as Object, undefined, undefined, undefined, 'MoreApp'));
  }

  private registerAppListLoadEvent(): void {
    emitter.on({
      eventId: EVENT_ID_BUNDLE_LIST_CHANGED,
    }, (eventData: emitter.EventData) => {
      LogUtil.info(`${TAG} app list load`);
      let appList = MoreAppListLoader.getInstance().getAppListCache();
      this.onAppListChanged(appList);
    });
  }

  private registerAppListAddEvent(): void {
    EventBus.getInstance().on('EVENT_ID_BUNDLE_ADD', this.appAddEventCallback);
  }

  private registerAppListRemoveEvent(): void {
    emitter.on({
      eventId: EVENT_ID_BUNDLE_REMOVE,
    }, (eventData: emitter.EventData) => {
      LogUtil.info(`${TAG} app list remove`);
      let bundleName = eventData.data?.bundleName as string;
      if (bundleName) {
        this.onAppListRemove(bundleName);
      }
    });
  }

  private moreAppListRemoveAllCb = () => {
    this.dataSource?.removeAll();
  }
}

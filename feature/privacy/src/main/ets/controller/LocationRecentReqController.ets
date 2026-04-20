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

import privacyManager, { Permissions } from '@ohos.privacyManager';
import bundleMonitor from '@ohos.bundle.bundleMonitor';
import { SettingsBaseMenu } from '@ohos/settings.common/src/main/ets/core/model/menu/SettingsMenu';
import { LogUtil } from '@ohos/settings.common/src/main/ets/utils/LogUtil';
import { AppListLoader } from '@ohos/settings.application/src/main/ets/AppListLoader';
import { StateMenu } from '@ohos/settings.uikit';
import { AppEntry, AppMenu } from '@ohos/settings.application/src/main/ets/AppModel';
import { LocationStateChangeListener, LocationUtil } from '../LocationUtil';
import { BusinessError } from '@ohos.base';
import { MenuGroupController } from '@ohos/settings.common/src/main/ets/core/controller/MenuController';
import { DateTimeUtil } from '@ohos/settings.common/src/main/ets/utils/DateTimeUtil';

type BundleUsedRecord = privacyManager.BundleUsedRecord;

const TAG: string = 'LocationRecentReqController : ';
const PERM_INACTIVE: number = 0;
const PERM_ACTIVE_IN_BACKGROUND: number = 2;

const TOKEN_ID: number = 0;
const COMPUTER_START_TIME: number = 0;
const FLAG_PERMISSION_USAGE_SUMMARY: number = 0;
const IS_REMOTE: boolean = false;
const DEVICE_ID: string = '';
const BUNDLE_NAME: string = '';
const PERMISSION_LIST: Permissions[] = ['ohos.permission.LOCATION', 'ohos.permission.LOCATION_IN_BACKGROUND',
  'ohos.permission.APPROXIMATELY_LOCATION'];

export abstract class LocationRecentReqController extends MenuGroupController implements LocationStateChangeListener {
  getListenerName(): string {
    return this.menu.key ?? ' ';
  }

  aboutToAppear(): void {
    super.aboutToAppear();
    LogUtil.info(`${TAG} aboutToAppear`);
    this.addMenus();
    LocationUtil.getInstance().start();
  }

  private async addMenus(): Promise<void> {
    LogUtil.info(`${TAG} addAppInfoMenu`);
    await this.refreshRecentApps();
    this.refreshUi();
  }

  async onLocationStateChange(state: boolean): Promise<void> {
    LogUtil.info(`${TAG} listener find location service isChanged: ${state}`);

    let geoLocationManager = await import('@ohos.geoLocationManager');
    this.getChildren().forEach(async item => {
      LogUtil.info(`${TAG} item: ${item.key}`);
      item.enable = geoLocationManager.default.isLocationEnabled();
      item.timestamp = new Date().getTime();
    })
    this.refreshUi();
  }

  protected registerDataChange(): void {
    LogUtil.info(`${TAG} registerDataChange`);
    LocationUtil.getInstance().registerStateChangeListener(this);

    // 监听最近位置信息访问列表状态变化
    LogUtil.info(`${TAG} listening to location service change`);
    try {
      privacyManager.on('activeStateChange', PERMISSION_LIST, (data) => {
        if (data.activeStatus === PERM_INACTIVE || data.activeStatus === PERM_ACTIVE_IN_BACKGROUND) {
          LogUtil.info(`${TAG} application apply for location service isChanged.`);
          this.refreshRecentApps();
        }
      })
    } catch (err) {
      LogUtil.error(`${TAG} listen to activeStateChange catch, err->${err?.message}`);
    }

    // 监听应用被删除后刷新页面
    try {
      bundleMonitor.on('remove', (bundleChangeInfo) => {
        LogUtil.info(`${TAG} listen find bundleName : ${bundleChangeInfo.bundleName} is removed`);
        let menu = this.findChild(bundleChangeInfo.bundleName);
        if (menu instanceof AppMenu) {
          this.removeChildren(bundleChangeInfo.bundleName);
        }
        this.checkReqEmpty();
        this.refreshUi();
      })
    } catch (err) {
      LogUtil.error(`${TAG} listen to bundleMonitor remove, err->${err?.message}`);
    }
  }

  protected unRegisterDataChange(): void {
    LogUtil.info(`${TAG} unRegisterDataChange`);
    LocationUtil.getInstance().unRegisterStateChangeListener(this);

    // 关闭位置信息变化监听
    LogUtil.info(`${TAG} close listening to privacyManager`);
    try {
      privacyManager.off('activeStateChange', PERMISSION_LIST);
    } catch (err) {
      LogUtil.error(`${TAG} unregister privacy manager failed: ${err?.message}`);
    }
    try {
      bundleMonitor.off('remove');
    } catch (err) {
      LogUtil.error(`${TAG} unregister bundle monitor failed: ${err?.message}`);
    }
  }

  private async refreshRecentApps(): Promise<void> {
    LogUtil.info(`${TAG} push request location apps into list`);

    let menus: SettingsBaseMenu[] = [];

    // 当前privacyManager底层存在bug，flag参数若调用底层枚举类会闪退, 且不支持数据默认，必须输入全量数据
    let beginTime: number = DateTimeUtil.getSystemDateInMills() - DateTimeUtil.getPerDayInMillis();
    beginTime = COMPUTER_START_TIME > beginTime ? COMPUTER_START_TIME : beginTime;
    let endTime: number = DateTimeUtil.getSystemDateInMills();

    let request: privacyManager.PermissionUsedRequest = {
      tokenId: TOKEN_ID,
      isRemote: IS_REMOTE,
      deviceId: DEVICE_ID,
      bundleName: BUNDLE_NAME,
      permissionNames: PERMISSION_LIST,
      // 如果当前时间是计算机初始化时间之前，则默认为计算机初始时间
      beginTime: beginTime,
      endTime: endTime,
      flag: FLAG_PERMISSION_USAGE_SUMMARY,
    };

    try {
      await privacyManager.getPermissionUsedRecord(request).then(async records => {
        let bundleRecords = this.getSortedBundleRecords(records.bundleRecords);

        for (let record of bundleRecords) {
          LogUtil.info(`${TAG} getPermissionUsedRecord success, app name ->${record.bundleName}`);
          // 查询应用信息
          let entry = await AppListLoader.getInstance().createAppEntryByName(record.bundleName);
          let menu = await this.createAppMenu(entry as AppEntry);
          menus.push(menu);
        }
      }).catch((err: BusinessError) => {
        LogUtil.info(`${TAG} getPermissionUsedRecord fail, err->${err?.message}`);
      });
    } catch (err) {
      LogUtil.info(`${TAG} getPermissionUsedRecord catch, err->${err?.message}`);
    }

    this.clearChildren();
    this.addChildren(menus);
    this.checkReqEmpty();
    this.refreshUi();
  }

  private checkReqEmpty(): void {
    if (this.getChildren().length === 0) {
      LogUtil.info(`${TAG} find have no request location apps recently`);

      let menus: SettingsBaseMenu[] = [];
      let menu = this.createEmptyState();
      menus.push(menu);
      this.clearChildren();
      this.addChildren(menus);
    }
    this.refreshUi();
  }

  getSortedBundleRecords(bundleRecords: Array<BundleUsedRecord>): Array<BundleUsedRecord> {
    bundleRecords.sort((record1: BundleUsedRecord, record2: BundleUsedRecord) => {
      LogUtil.info(`${TAG} enter recordSort`);

      let lastAccessTime1: number = Number.MIN_VALUE;
      let lastAccessTime2: number = Number.MIN_VALUE;

      record1.permissionRecords.forEach(permissionRecord => {
        if (permissionRecord.lastAccessTime > lastAccessTime1) {
          lastAccessTime1 = permissionRecord.lastAccessTime;
        }
      });

      record2.permissionRecords.forEach(permissionRecord => {
        if (permissionRecord.lastAccessTime > lastAccessTime2) {
          lastAccessTime2 = permissionRecord.lastAccessTime;
        }
      });
      return lastAccessTime2 - lastAccessTime1;
    });
    return bundleRecords;
  }

  abstract createAppMenu(entry: AppEntry): Promise<AppMenu>;

  abstract createEmptyState(): StateMenu;
}
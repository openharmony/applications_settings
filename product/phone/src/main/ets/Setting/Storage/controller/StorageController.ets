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

import { taskpool } from '@kit.ArkTS';
import osAccount from '@ohos.account.osAccount';
import storage from '@ohos.file.storageStatistics';
import storageStatistics from '@ohos.file.storageStatistics';
import { AppEntryChangedListener, AppListLoader } from '@ohos/settings.application/src/main/ets/AppListLoader';
import { AppEntry } from '@ohos/settings.application/src/main/ets/AppModel';
import { AccountConstants } from '@ohos/settings.common/src/main/ets/constant/AccountConstants';
import { PRECISION0, PRECISION2 } from '@ohos/settings.common/src/main/ets/constant/ViewConstant';
import { STORAGE_APP_CHANGE_EVENT, STORAGE_DATA_UPDATE_EVENT } from '@ohos/settings.common/src/main/ets/event/types';
import { EventBus } from '@ohos/settings.common/src/main/ets/framework/common/EventBus';
import {
  CompCtrlParam,
  ComponentControl,
  SettingBaseModel
} from '@ohos/settings.common/src/main/ets/framework/model/SettingBaseModel';
import { ItemResultType } from '@ohos/settings.common/src/main/ets/framework/model/SettingItemModel';
import {
  notifyCompStateChange,
  SettingResultState,
  SettingStateType
} from '@ohos/settings.common/src/main/ets/framework/model/SettingStateModel';
import { CurrentMemScene, PerformanceReporter } from '@ohos/settings.common/src/main/ets/memery/PerformanceReporter';
import { AccountUtil } from '@ohos/settings.common/src/main/ets/utils/AccountUtil';
import { CheckEmptyUtils } from '@ohos/settings.common/src/main/ets/utils/CheckEmptyUtils';
import { LanguageUtils } from '@ohos/settings.common/src/main/ets/utils/LanguageUtils';
import { LogUtil } from '@ohos/settings.common/src/main/ets/utils/LogUtil';
import { ResourceUtil } from '@ohos/settings.common/src/main/ets/utils/ResourceUtil';
import { DEFAULT_DATA_SIZE, StorageEventConstant } from '@ohos/settings.storage/src/main/ets/constant/StorageConstant';
import { CardInfo } from '@ohos/settings.storage/src/main/ets/model/CardInfo';
import DataPanelModel from '@ohos/settings.storage/src/main/ets/model/DataPanelModel';
import StorageCleanupCardManager from '@ohos/settings.storage/src/main/ets/model/StorageCleanupCardManager';
import { StorageDataManager } from '@ohos/settings.storage/src/main/ets/model/StorageDataManager';
import { StorageSizeUtil } from '@ohos/settings.storage/src/main/ets/utils/StorageSizeUtil';
import {
  getAudioStatisticsDataAsync,
  getFreeSizeAsync,
  getMigrationDataSizeAsync,
  getSystemSizeAsync,
  getUserStorageStatsAsync
} from '@ohos/settings.storage/src/main/ets/utils/StorageStatisticsUtil';
import { StorageUtil } from '@ohos/settings.storage/src/main/ets/utils/StorageUtil';
import { BACKUP_DATA_UPDATE_EVENT, BackupDataModel } from './BackupDataGroupController';

/* instrument ignore file */
const TAG = 'StorageControl';

export class StorageControl implements ComponentControl, AppEntryChangedListener {
  public userIDs: Array<number> = [];
  public message: string = '';
  public totalBytes: string = '';
  public usedBytes: string = '';
  public freeBytes: string = '';
  public proportion: string = '0';
  public categoryValues: number[] = [];
  public totalValue: number = 0;
  public otherUserData: number = 0;
  public localBackupData: number = 0;
  public upgradingData: number = 0;
  public valueColors: (ResourceColor | LinearGradient)[] = [];
  public legendNames: ResourceStr[] = [];
  private usedBytesNumber: number = 0;
  private freeBytesNumber: number = 0;
  private systemSizeNumber: number = 0;
  private audioSizeNumber: number = 0;
  private ancoSizeNumber: number = 0;
  private storageDetail: storage.StorageStats | null = null;
  private isFirstPageShow: boolean = true;
  private groupInitCallback = () => {
    LogUtil.info(`${TAG} groupInitCallback.`);
    this.changeSysData();
    this.notifyBackupDataGroup();
  };
  private refreshStorageDataCallback = () => {
    LogUtil.info(`${TAG} refreshStorageDataCallback.`);
    this.loadData();
  };

  init(compParam: CompCtrlParam): void {
    this.initLegendName();
    this.loadData();
    AppListLoader.getInstance().loadAppList();
    this.registerDataChange();
    PerformanceReporter.getInstance().reportExitMemScene(CurrentMemScene.START_STORAGE);
    EventBus.getInstance().on(StorageEventConstant.EVENT_STORAGE_SYS_DATA_GROUP_INIT, this.groupInitCallback);
    EventBus.getInstance().on(StorageEventConstant.EVENT_REFRESH_STORAGE_DATA, this.refreshStorageDataCallback);
  }

  onPageShow(component: SettingBaseModel): void {
    LogUtil.info(`${TAG} onPageShow success`);
    let isHasBackupData: boolean = StorageDataManager.getIsHasBackupData();
    if (!isHasBackupData && this.localBackupData > 0) {
      LogUtil.info(`${TAG} hwbackup record has clean`);
      this.localBackupData = 0;
    }

    this.updateStorageData();

    // 如果可用存储低于10%就加载推荐卡片
    this.loadCardList();
  }

  private updateStorageData() {
    // 存储页新增了多个数据清理入口，清理数据后 有必要刷新当前页面显示的存储数据情况
    if (this.isFirstPageShow) {
      // 首次onPageShow的时候没有必要做数据刷新，因为在init时刚刚获取
      this.isFirstPageShow = false;
    } else {
      this.refreshStorageData();
    }
  }

  private loadCardList(): void {
    StorageCleanupCardManager.init(getContext(), (cardList?: Array<CardInfo>) => {
      EventBus.getInstance().emit('handleCardInfo', cardList);
    });
  }

  onPageHide(): void {
    LogUtil.info(`${TAG} onPageHide success`);
    StorageCleanupCardManager.destroy(getContext());
  }

  async loadData(): Promise<void> {
    try {
      let osAccountManager = osAccount.getAccountManager();
      osAccountManager.getActivatedOsAccountLocalIds((err, dataArray) => {
        this.userIDs = dataArray;
        LogUtil.info(`${TAG} now userid is: ${dataArray[0]}`);
      });
      let isPrivateUser: boolean = await AccountUtil.isCurrentPrivate();
      LogUtil.info(`${TAG} now user isPrivateUser: ${isPrivateUser}`);
      this.userIDs = this.userIDs.filter(item => {
        if (isPrivateUser) {
          return item === AccountConstants.MAIN_USER;
        }
        return item !== AccountConstants.MAIN_USER;
      });
      if (this.userIDs.length > 0) {
        let promiseList: Promise<storage.StorageStats>[] = []
        this.userIDs.forEach(item => {
          LogUtil.info(`${TAG} user : ${item}`);
          promiseList.push(storageStatistics.getUserStorageStats(item))
        })
        let arr = await Promise.all(promiseList).then()
        arr.forEach(i => {
          this.otherUserData += i.audio + i.video + i.image + i.file + i.app;
        })
      } else {
        this.otherUserData = 0;
      }
    } catch (error) {
      LogUtil.error(`${TAG} getActivatedOsAccountLocalIds failed`);
    }
    this.refreshStorageData();
  }

  /**
   * 并发获取并刷新存储数据
   */
  private async refreshStorageData(): Promise<void> {
    const startTime: number = new Date().getTime();
    let taskGroup: taskpool.TaskGroup = new taskpool.TaskGroup();
    taskGroup.addTask(getUserStorageStatsAsync);
    taskGroup.addTask(getFreeSizeAsync);
    taskGroup.addTask(getSystemSizeAsync);
    taskGroup.addTask(getMigrationDataSizeAsync);
    taskGroup.addTask(getAudioStatisticsDataAsync);
    let res: Object[] = [];
    try {
      res = await taskpool.execute(taskGroup);
    } catch (err) {
      LogUtil.warn(`${TAG} taskGroup execute error, code ${err?.code} msg ${err?.msg}`);
      return;
    }
    if (CheckEmptyUtils.isEmptyArr(res) || res.length < 6) {
      LogUtil.warn(`${TAG} getStorageData res invalid!`);
      return;
    }
    const endTime = new Date().getTime();
    LogUtil.info(`${TAG} getStorageData end, cost time ${endTime - startTime}`);
    this.storageDetail = res[0] as storage.StorageStats;
    this.freeBytesNumber = res[1] as number;
    this.systemSizeNumber = res[2] as number;
    if (res[3] > 0) {
      this.upgradingData = res[3] as number;
      StorageDataManager.getInstance().setUpgradingData(this.upgradingData);
    }
    this.audioSizeNumber = res[4] as number;
    this.getLocalBackupData();
    this.showWhenAllDataReady();
  }

  private getLocalBackupData(): void {
    let isHasBackupData: boolean = StorageDataManager.getIsHasBackupData();
    if (!isHasBackupData) {
      LogUtil.info(`${TAG} no hwbackup record`);
      return;
    }
    StorageUtil.refreshBackUpDataSize();
    this.localBackupData = StorageDataManager.getInstance().getLocalBackupModel().size;
  }

  private showWhenAllDataReady(): void {
    let detail = this.storageDetail;
    if (detail && detail.total !== 0 && this.freeBytesNumber >= 0) {
      this.usedBytesNumber = detail.total - this.freeBytesNumber;
      if (this.usedBytesNumber / detail.total * 100 < 1) {
        this.proportion =
          LanguageUtils.getPercentFormat(Math.ceil(Number((this.usedBytesNumber / detail.total * 100))).valueOf());
      } else {
        this.proportion =
          LanguageUtils.getPercentFormat(Math.floor(Number((this.usedBytesNumber / detail.total * 100))).valueOf());
      }
      this.totalBytes = StorageSizeUtil.formatDataIntl(detail.total, PRECISION0);
      this.freeBytes = StorageSizeUtil.formatDataIntl(this.freeBytesNumber, PRECISION2);
      this.usedBytes = StorageSizeUtil.formatDataIntl(this.usedBytesNumber, PRECISION2);
      let otherStorage = this.usedBytesNumber - this.systemSizeNumber -
      detail.image - this.audioSizeNumber - detail.app - detail.video;
      this.printResourceLogInfo(detail, otherStorage);
      this.categoryValues = [
        detail.app,
        detail.image,
        this.audioSizeNumber,
        detail.video,
        this.systemSizeNumber,
        otherStorage,
      ];
      this.totalValue = detail.total;
      ResourceUtil.getAnyStrFormatString($r('app.string.used_data'), this.usedBytes, this.totalBytes)
        .then((message: string) => {
          this.message = message;
          LogUtil.info(`${TAG} message complete, refreshui msg: ${this.message}`);
          // 发出事件，将更新的数据通知到子组件
          EventBus.getInstance().emit(STORAGE_DATA_UPDATE_EVENT, {
            detail: detail,
            proportion: this.proportion,
            message: this.message,
            categoryValues: this.categoryValues,
            totalValue: this.totalValue,
            valueColors: this.valueColors,
            legendNames: this.legendNames,
            otherStorage: otherStorage,
          } as DataPanelModel);
        });
      this.notifyBackupDataGroup();
      this.changeSysData();
      LogUtil.info(`${TAG} data complete, refreshui`);
    } else {
      LogUtil.error(`${TAG} show data error, free byte ${this.freeBytesNumber}.`);
    }
  }

  // 日志：总空间 、 空闲 、 应用占用 、 操作系统镜像包 、 其他明确的体积占用
  private printResourceLogInfo(detail: storage.StorageStats, otherStorage: number): void {
    LogUtil.showInfo(TAG,
      'storage resource info, total: %{public}d, free: %{public}d, used: %{public}d, app: %{public}d, ' +
        'image: %{public}d, audio: %{public}d, video: %{public}d, system: %{public}d, other: %{public}d',
      detail.total, this.freeBytesNumber, this.usedBytesNumber, detail.app, detail.image,
      this.audioSizeNumber, detail.video, this.systemSizeNumber, otherStorage);
  }

  changeSysData(): void {
    let detail = this.storageDetail
    this.onNotifyCompStateChange(
      'Setting.Storage.SystemDataGroup.OtherUserData',
      this.otherUserData,
      PRECISION0
    );
    LogUtil.info(`${TAG} storage system data info, other user data: ${this.otherUserData}, system: ${this.systemSizeNumber}`);
    this.onNotifyCompStateChange(
      'Setting.Storage.SystemDataGroup.systemSizeNumber',
      this.systemSizeNumber,
      PRECISION0
    );
    if (detail) {
      let otherSystemResource =
        detail.total - this.freeBytesNumber - this.systemSizeNumber - detail.app - detail.video -
        detail.image - detail.file - this.localBackupData - this.upgradingData;
      LogUtil.info(`${TAG} storage system data info, other system: ${otherSystemResource}`);
      if (otherSystemResource < 0) {
        otherSystemResource = 0;
      }
      this.onNotifyCompStateChange(
        'Setting.Storage.OtherDataGroup.OtherSystemResource',
        otherSystemResource,
        PRECISION0
      );
    }
  }

  notifyBackupDataGroup(): void {
    LogUtil.showInfo(TAG,
      `notifyBackDataGroup localBackupData: ${this.localBackupData}, upgradingData: ${this.upgradingData}`)
    let data = { localBackupData: this.localBackupData, upgradingData: this.upgradingData } as BackupDataModel;
    EventBus.getInstance().emit(BACKUP_DATA_UPDATE_EVENT, data);
  }

  onNotifyCompStateChange(id: string, data: number, precision: number): void {
    notifyCompStateChange(id, new Map<SettingStateType, SettingResultState>([[SettingStateType.STATE_TYPE_ITEM_RESULT,
      {
        type: ItemResultType.RESULT_TYPE_TEXT,
        result: { content: StorageSizeUtil.formatDataIntl(data, precision, true) }
      } as SettingResultState]]));
  }

  initLegendName(): void {
    this.legendNames.push(
      $r('app.string.storage_apps'),
      $r('app.string.storage_images'),
      $r('app.string.storage_audio'),
      $r('app.string.storage_videos'),
      $r('app.string.storage_system'),
      $r('app.string.storage_other'),
    )
  }

  destroy(): void {
    LogUtil.showInfo(TAG, 'onDestroy');
    PerformanceReporter.getInstance().reportExitMemScene(CurrentMemScene.START_STORAGE);
    EventBus.getInstance().detach(StorageEventConstant.EVENT_STORAGE_SYS_DATA_GROUP_INIT, this.groupInitCallback);
    EventBus.getInstance().detach(StorageEventConstant.EVENT_REFRESH_STORAGE_DATA, this.refreshStorageDataCallback);
  }

  onAppUpdate(): void {
    LogUtil.info(`${TAG} onAppUpdate`);
  }

  onAppRemove(bundleName: string, appIndex?: number): void {
    LogUtil.info(`${TAG} onAppRemove`);
  }

  getListenerName(): string {
    return '';
  }

  onAppListChanged(appList: AppEntry[]): void {
    LogUtil.info(`${TAG} onAppListChanged `);
    this.notifyAppChange();
  }

  notifyAppChange(): void {
    EventBus.getInstance().emit(STORAGE_APP_CHANGE_EVENT)
  }

  protected registerDataChange(): void {
    AppListLoader.getInstance().unRegisterAppChangedListener(this);
    AppListLoader.getInstance().registerAppChangedListener(this);
  }
}
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

import { Context } from '@kit.AbilityKit';
import { collections, taskpool } from '@kit.ArkTS';
import { systemDateTime } from '@kit.BasicServicesKit';
import { storageStatistics } from '@kit.CoreFileKit';
import bundleManager from '@ohos.bundle.bundleManager';
import dataShare from '@ohos.data.dataShare';
import { EventBus } from '@ohos/settings.common/src/main/ets/framework/common/EventBus';
import { PageRouter } from '@ohos/settings.common/src/main/ets/framework/common/PageRouter';
import { LogUtil } from '@ohos/settings.common/src/main/ets/utils/LogUtil';
import { ResourceUtil } from '@ohos/settings.common/src/main/ets/utils/ResourceUtil';
import { DECIMAL_PLACE_NUMBER, MAX_PROPORTION, MIN_PROPORTION } from '../constant/StorageConstant';
import { ButtonInfo, CardInfo, ControllerInfo, queryAppStorageData } from '../model/CardInfo';
import StorageCleanupCardManager from '../model/StorageCleanupCardManager';
import { StorageSizeUtil } from '../utils/StorageSizeUtil';
import { StorageUtil } from '../utils/StorageUtil';
import { CardController } from './CardController';

@Sendable
class BundleInfo {
  public bundleName: string = '';
  public appIndex: number = 0;

  constructor(bundleName: string, appIndex: number) {
    this.bundleName = bundleName;
    this.appIndex = appIndex;
  }
}

// instrument ignore file
@Sendable
export class StorageAppUninstallController extends CardController {
  private uninstallAppCardName: string = 'uninstall_app';
  private appList: collections.Array<BundleInfo> = new collections.Array<BundleInfo>();
  private cardRefreshMsg: string = 'storage_app_uninstall';

  constructor(controllerInfo: ControllerInfo, proportion: number) {
    super(controllerInfo, proportion);
    this.tag = 'StorageAppUninstallController';
  }

  isNeedShow(context: Context): boolean {
    if (this.proportion <= MIN_PROPORTION) {
      LogUtil.info(`${this.tag} current proportion: ${this.proportion}, no need show.`);
      return false;
    }
    let cardBaseInfo = new CardInfo();
    cardBaseInfo.serviceName = this.controllerInfo.bundleName;
    cardBaseInfo.cardName = this.uninstallAppCardName;
    cardBaseInfo.cardController = this;
    let shouldKeepSilent: boolean = StorageCleanupCardManager.isSilentStatusHideByUser(cardBaseInfo, context);
    LogUtil.info(`${this.tag} should keep silent: ${shouldKeepSilent}`);
    return !shouldKeepSilent;
  }

  async registerDataChange(dataShareHelper: dataShare.DataShareHelper | undefined,
    callback: (cardInfos?: CardInfo[], cardController?: CardController) => void, context: Context): Promise<void> {
    EventBus.getInstance().on(this.cardRefreshMsg, (cardInfos:CardInfo[]) => {
      LogUtil.info(`${this.tag} notify card changed`);
      callback(cardInfos, this);
    })
  }

  async unRegisterDataChange(dataShareHelper: dataShare.DataShareHelper | undefined): Promise<void> {
    EventBus.getInstance().off(this.cardRefreshMsg);
  }

  private async countUnusedAppStorage(bundleInfos: bundleManager.BundleInfo[]): Promise<number> {
    LogUtil.info(`${this.tag} countUnusedAppStorage start`);
    let taskGroup: taskpool.TaskGroup = new taskpool.TaskGroup();
    let list = new collections.Array<BundleInfo>();
    for (let i = 0; i < bundleInfos.length; i++) {
      list.push(new BundleInfo(bundleInfos[i].name, bundleInfos[i].appInfo.appIndex));
      taskGroup.addTask(queryAppStorageData, this, bundleInfos[i].name, bundleInfos[i].appInfo.appIndex);
    }
    this.appList = list;
    let res: Object[] = await taskpool.execute(taskGroup);
    // 统计应用数据占用
    return this.countAppStorage(res);
  }

  private countAppStorage(res: Object[]): number {
    let validAppCount: number = 0;
    let storageCount: number = 0;
    res.forEach(object => {
      let storage: number = object as number;
      if (storage > 0) {
        validAppCount += 1;
        storageCount += storage;
      }
    });
    LogUtil.info(`${this.tag} countUnusedAppStorage finished, valid count:${validAppCount}, size:${storageCount}`);
    return storageCount;
  }

  async getBundleStorage(bundleName: string, index: number): Promise<number> {
    let start: number = systemDateTime.getTime();
    let bundleStats = await StorageUtil.getBundleStats(bundleName, index);
    let res: storageStatistics.BundleStats = bundleStats ?? {
      appSize: 0,
      dataSize: 0,
      cacheSize: 0
    };
    let time: number = systemDateTime.getTime() - start;
    if (time > 200) {
      LogUtil.info(`${this.tag} getBundleStats for app name:${bundleName},index:${index},time:${time}`);
    }
    return res.appSize + res.dataSize + res.cacheSize;
  }

  async queryCardInfo(context: Context): Promise<Array<CardInfo>> {
    let bundleInfos: bundleManager.BundleInfo[] = await StorageUtil.getUnusedBundleInfoList();
    if (!this.checkNeedShowCondition(bundleInfos.length)) {
      return [];
    }
    let storageCount = await this.countUnusedAppStorage(bundleInfos);
    let buttonInfo = new ButtonInfo();
    buttonInfo.buttonString = context.resourceManager.getStringSync($r('app.string.view_details'));
    let cardInfo = new CardInfo();
    cardInfo.cardName = this.uninstallAppCardName;
    cardInfo.serviceName = this.controllerInfo.bundleName;
    cardInfo.titleString = context.resourceManager.getStringSync($r('app.string.uninstall_unusual_apps'));
    cardInfo.summaryString =
      ResourceUtil.replaceAnyFormatString(context.resourceManager.getStringSync($r('app.string.uninstall_unusual_app_prompt')),
        [StorageSizeUtil.formatDataIntl(storageCount, DECIMAL_PLACE_NUMBER)]);
    cardInfo.iconImg = context.resourceManager.getMediaContentSync($r('app.media.app_uninstall_icon'));
    cardInfo.buttonList = [buttonInfo];
    cardInfo.cardController = this;
    cardInfo.priority = this.controllerInfo?.priority;
    return [cardInfo];
  }

  private checkNeedShowCondition(unusedAppCount: number): boolean {
    LogUtil.info(`${this.tag} checkNeedShowCondition unusedAppCount:${unusedAppCount}, proportion:${this.proportion}`);
    if (this.proportion > MAX_PROPORTION) {
      return unusedAppCount >= 3;
    } else if (this.proportion > MIN_PROPORTION) {
      return unusedAppCount >= 6;
    }
    return false;
  }

  async notifyBundleRemove(bundleName: string, appIndex: number, context?: Context): Promise<void> {
    if (!context) {
      return;
    }
    for (let i = this.appList.length - 1; i >= 0; i--) {
      let appInfo = this.appList[i];
      if (appInfo.bundleName === bundleName && appInfo.appIndex === appIndex) {
        let cardInfos: CardInfo[] = await this.queryCardWithTimeKeeping(context);
        EventBus.getInstance().emit(this.cardRefreshMsg, cardInfos);
        return;
      }
    }
  }

  async clickButton(context: Context, buttonInfo: ButtonInfo, cardInfo: CardInfo, pathInfos: NavPathStack,
    navigationMode: boolean, callback: ((isShow: boolean, cardInfo?: CardInfo) => void)): Promise<void> {
    LogUtil.info(`${this.tag} clickButton,jump to uninstall page`);
    PageRouter.push('storage_uninstall_settings');
  }
}
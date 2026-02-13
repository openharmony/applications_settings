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

/* instrument ignore file */
import { Context } from '@kit.AbilityKit';
import { dataShare } from '@kit.ArkData';
import { HashMap, JSON, taskpool } from '@kit.ArkTS';
import {
  BundleStatusChangeListener,
  BundleStatusChangeManager
} from '@ohos/settings.common/src/main/ets/bundle/BundleStatusChangeManager';
import { CheckEmptyUtils } from '@ohos/settings.common/src/main/ets/utils/CheckEmptyUtils';
import { DateTimeUtil } from '@ohos/settings.common/src/main/ets/utils/DateTimeUtil';
import { LogUtil } from '@ohos/settings.common/src/main/ets/utils/LogUtil';
import { PreferencesUtil } from '@ohos/settings.common/src/main/ets/utils/PreferencesUtil';
import { RawFileUtil } from '@ohos/settings.common/src/main/ets/utils/RawFileUtil';
import {
  CLEAR_CACHE_URL,
  CLOUD_GALLERY_URL,
  FILE_MANAGER_LOW_URL,
  FILE_MANAGER_URL,
  GALLERY_URL,
  INVALID_CARD_NAME,
  UNINSTALL_APP_URL
} from '../constant/StorageConstant';
import { CardController } from '../controller/CardController';
import { CloudGalleryCardController } from '../controller/CloudGalleryCardController';
import { CommonCardController } from '../controller/CommonCardController';
import { FileManagerCardController } from '../controller/FileManagerCardController';
import { FileManagerLowCardController } from '../controller/FileManagerLowCardController';
import { GalleryCardController } from '../controller/GalleryCardController';
import { StorageAppUninstallController } from '../controller/StorageAppUninstallController';
import { StorageCleanController } from '../controller/StorageCleanController';
import { StorageUtil } from '../utils/StorageUtil';
import { ButtonInfo, CardInfo, ControllerInfo } from './CardInfo';

const TAG: string = 'StorageCleanupCardManager';

export const SHOW_CARD_MAX_LENGTH: number = 1;

export const SILENT_CARD_PREFERENCE_NAME: string = 'silent_card';

@Concurrent
async function queryCardData(controller: CardController, context: Context): Promise<Array<CardInfo>> {
  try {
    if (!controller) {
      LogUtil.info(`StorageCleanupCardManager queryCardData controller invalid`);
      return [];
    }
    LogUtil.info(`StorageCleanupCardManager ${controller.tag} queryCardData start`);
    let res: CardInfo[] = await controller.queryCardWithTimeKeeping(context);
    if (res[0] && res[0].cardName === INVALID_CARD_NAME) {
      LogUtil.warn(`StorageCleanupCardManager ${controller.tag} queryCardData time out`);
      return [];
    }
    res.forEach(cardInfo => {
      cardInfo.cardController = controller;
      cardInfo.priority = controller.controllerInfo?.priority;
    });
    LogUtil.info(`StorageCleanupCardManager ${controller.tag} queryCardData finished: ${res.length}`);
    return res;
  } catch (err) {
    LogUtil.info(`StorageCleanupCardManager ${controller.tag} queryCardData eror: ${err?.message}`);
  }
  return [];
}

/**
 * 存储清理卡片管理
 *
 * @since 2024-11-16
 */
export class StorageCleanupCardManager {
  private controllerList: CardController[] = [];
  private allCardInfoList: CardInfo[] = [];
  private showCardInfoList: CardInfo[] = [];
  private dataCallback: ((cardList?: Array<CardInfo>, allCardList?: Array<CardInfo>) => void) | undefined = undefined;
  private context?: Context = undefined;
  private listenerKey: string = 'storage_card';
  private bundleList: string[] = [];
  private dataShareMap = new HashMap<CardController, dataShare.DataShareHelper>();
  private cardInfoMap = new HashMap<CardInfo, CardController>();
  private readonly bundleStatusCallback: BundleStatusChangeListener = {
    getListenerName: (): string => {
      return this.listenerKey ?? ' ';
    },
    onBundleAdd: (bundleName, userId, appIndex) => {
    },
    onBundleRemove: (bundleName, userId, appIndex) => {
      LogUtil.info(`${TAG} bundleStatusCallback remove, bundleName: ${bundleName} userId: ${userId} appIndex: ${appIndex}`);
      this.notifyControllerAppRemoved(bundleName, appIndex);
      if (this.context && this.bundleList.includes(bundleName)) {
        this.notifyDataChangedWhenDataChange(this.context);
      }
    },
    onBundleUpdate: (bundleName, userId, appIndex) => {
    }
  };

  /**
   * 卸载应用场景，针对不常用应用卡片定制刷新
   *
   * @param bundleName 应用bundleName
   * @param appIndex 应用appIndex，用于区分分身应用
   */
  private async notifyControllerAppRemoved(bundleName: string, appIndex: number): Promise<void> {
    for (let i = 0; i < this.controllerList.length; i++) {
      if (this.controllerList[i] instanceof StorageAppUninstallController) {
        let controller: StorageAppUninstallController = this.controllerList[i] as StorageAppUninstallController;
        controller.notifyBundleRemove(bundleName, appIndex, this.context);
        return;
      }
    }
  }

  /**
   * 刷新指定controller的卡片
   *
   * @param targetCardList 卡片列表
   * @param targetController 目标controller
   */
  private refreshLocalCardList(targetCardList: CardInfo[], targetController: CardController): void {
    LogUtil.info(`${TAG} refreshLocalCardList`);
    if (!this.dataCallback) {
      return;
    }
    let isNeedUpdate: boolean = false;
    // 若当前卡片已显示需要隐藏则刷新
    if (targetCardList.length === 0) {
      this.allCardInfoList = this.allCardInfoList.filter(localCardInfo => {
        return localCardInfo.cardController != targetController;
      });
      let length = this.showCardInfoList.length;
      this.showCardInfoList = this.showCardInfoList.filter(localCardInfo => {
        return localCardInfo.cardController != targetController;
      })
      if (length != this.showCardInfoList.length) {
        isNeedUpdate = true;
      }
    } else {
      // 界面已显示卡片有相同卡片则刷新
      targetCardList.forEach(cardInfo => {
        for (let i = this.allCardInfoList.length - 1; i >= 0; i--) {
          if (this.isSameCardInfo(cardInfo, this.allCardInfoList[i])) {
            this.allCardInfoList[i] = cardInfo;
          }
        }
        for (let i = this.showCardInfoList.length - 1; i >= 0; i--) {
          if (this.isSameCardInfo(cardInfo, this.showCardInfoList[i])) {
            this.showCardInfoList[i] = cardInfo;
            isNeedUpdate = true;
          }
        }
      })
    }
    LogUtil.info(`${TAG} refreshCardList ${isNeedUpdate}`);
    if (isNeedUpdate) {
      this.dataCallback(this.showCardInfoList, this.getAllNotSilentCardList());
    }
  }

  getTargetController(controllerInfo: ControllerInfo, proportion: number): CardController {
    switch (controllerInfo.controller) {
      case CLEAR_CACHE_URL:
        return new StorageCleanController(controllerInfo, proportion);
      case CLOUD_GALLERY_URL:
        return new CloudGalleryCardController(controllerInfo, proportion);
      case FILE_MANAGER_URL:
        return new FileManagerCardController(controllerInfo, proportion);
      case GALLERY_URL:
        return new GalleryCardController(controllerInfo, proportion);
      case FILE_MANAGER_LOW_URL:
        return new FileManagerLowCardController(controllerInfo, proportion);
      case UNINSTALL_APP_URL:
        return new StorageAppUninstallController(controllerInfo, proportion);
      default:
        return new CommonCardController(controllerInfo, proportion);
    }
  }

  private async initControllerList(): Promise<void> {
    // 读取配置项，获取需要加载的controller列表
    if (this.controllerList.length != 0) {
      return;
    }
    BundleStatusChangeManager.getInstance().registerBundleChangedListener(this.bundleStatusCallback);
    let res = await RawFileUtil.getJsonRawFile('storage_card_list.json');
    LogUtil.info(`${TAG} initControllerList from file finished`);
    let controllerInfoList = res as Array<ControllerInfo>;
    // 遍历所有controller，获取对应的卡片列表
    let usedProportion: number = await StorageUtil.getUsedProportion();
    LogUtil.info(`${TAG} manager used proportion is ${usedProportion}`);
    for (let i = 0; i < controllerInfoList.length; i++) {
      let controllerInfo = controllerInfoList[i];
      if (!controllerInfo) {
        return;
      }
      LogUtil.info(`${TAG} getConfig finish ${JSON.stringify(controllerInfo)}`);
      let controller: CardController = this.getTargetController(controllerInfo, usedProportion);
      if (!controller) {
        continue;
      }
      try {
        this.controllerList.push(controller);
      } catch (e) {
        LogUtil.info(`${TAG} getConfig error ${JSON.stringify(e?.msg)} ${console.traceHybridStack()}`);
      }
      if (controllerInfo.bundleName) {
        this.bundleList.push(controllerInfo.bundleName);
      }
    }

    LogUtil.info(`${TAG} initControllerList finish, size:${controllerInfoList.length}`);
  }

  async clickButton(context: Context, buttonInfo: ButtonInfo, cardInfo: CardInfo, pathInfos: NavPathStack,
    navigationMode: boolean): Promise<void> {
    cardInfo.cardController?.clickButton(context, buttonInfo, cardInfo, pathInfos, navigationMode,
      (isShow, updateCardInfo) => {
        if (!isShow) {
          this.allCardInfoList = this.allCardInfoList.filter(filterCardInfo => {
            return this.filterSameCardInfo(cardInfo, filterCardInfo);
          });
          this.showCardInfoList = this.showCardInfoList.filter(filerCardInfo => {
            return this.filterSameCardInfo(cardInfo, filerCardInfo);
          });
          this.notifyDataChange(this.showCardInfoList);
        }
      });
  }

  private filterSameCardInfo(cardInfo: CardInfo, filterCardInfo: CardInfo): boolean {
    return !this.isSameCardInfo(cardInfo, filterCardInfo);
  }

  private isSameCardInfo(cardInfo: CardInfo, filterCardInfo: CardInfo): boolean {
    if (cardInfo.cardName === filterCardInfo.cardName && cardInfo.serviceName === filterCardInfo.serviceName) {
      return true;
    }
    return false;
  }

  async refreshCardSilentTime(cardInfo: CardInfo): Promise<void> {
    let key = this.getCardSilentKey(cardInfo);
    if (!key) {
      return;
    }
    PreferencesUtil.putValueWithPreferenceName(key, new Date().getTime(), SILENT_CARD_PREFERENCE_NAME);
  }

  private getCardSilentKey(cardInfo: CardInfo): undefined | string {
    if (!cardInfo || !cardInfo.serviceName || !cardInfo.cardName) {
      return undefined;
    }
    let key: CardInfo = {
      'serviceName': cardInfo.serviceName,
      'cardName': cardInfo.cardName
    };
    return JSON.stringify(key);
  }

  private getSilentTime(cardInfo: CardInfo, context?: Context): number {
    let key = this.getCardSilentKey(cardInfo);
    if (!key) {
      return 0;
    }
    let value = PreferencesUtil.getSyncWithPreferenceName(key, 0 as number, SILENT_CARD_PREFERENCE_NAME, context);
    return parseInt(value.toString());
  }

  async init(context: Context, callback: (cardList?: Array<CardInfo>) => void): Promise<void> {
    this.context = context;
    await this.initControllerList();
    let cardInfoList = await this.getCardInfoList(context);
    this.dataCallback = callback;
    this.notifyDataChange(cardInfoList);
    LogUtil.info(`${TAG} init card info list finished and notify data change`);
    this.controllerList.forEach(controller => {
      this.registerControllerDataChange(controller, context);
    })
  }

  private async registerControllerDataChange(controller: CardController, context: Context): Promise<void> {
    let dataShareHelper = await controller.createDataShareHelper(context);
    if (dataShareHelper) {
      this.dataShareMap.set(controller, dataShareHelper);
    }
    await controller.registerDataChange(dataShareHelper, (cardInfos?: CardInfo[], cardController?: CardController) => {
      LogUtil.info(`${TAG} onDataChange, cardController: ${cardController?.tag}`);
      if (cardInfos && cardController) {
        this.refreshLocalCardList(cardInfos, cardController);
      } else {
        this.notifyDataChangedWhenDataChange(context);
      }
    }, context);
  }

  private notifyDataChangedWhenDataChange(context: Context): void {
    LogUtil.info(`${TAG} notifyDataChangedWhenDataChange`);
    this.getCardInfoList(context).then(cardInfoList => {
      // 界面上未显示卡片时，无需回调刷新
      if (CheckEmptyUtils.isEmptyArr(this.showCardInfoList)) {
        return;
      }
      this.notifyDataChange(cardInfoList);
    });
  }

  private notifyDataChange(cardInfoList: CardInfo[]): void {
    LogUtil.info(`${TAG} notifyDataChange ${cardInfoList.length}`);
    if (!this.dataCallback) {
      return;
    }
    // 首次获取数据界面未显示卡片时 或 清理卡片无可清理内存时，全量刷新
    if (CheckEmptyUtils.isEmptyArr(this.showCardInfoList) || this.showCardInfoList[0].cardName === 'clearCache') {
      this.showCardInfoList = cardInfoList.slice(0, SHOW_CARD_MAX_LENGTH);
      LogUtil.info(`${TAG} notifyDataChange show all card ${this.showCardInfoList.length}`);
      this.dataCallback(this.showCardInfoList, this.getAllNotSilentCardList());
      return;
    }

    let cardList: CardInfo[] = [];
    // 界面有卡片显示时增量刷新
    this.showCardInfoList.forEach(cardInfo => {
      cardInfoList.forEach(newCardInfo => {
        if (cardInfo.serviceName === newCardInfo.serviceName && cardInfo.cardName === newCardInfo.cardName) {
          cardList.push(newCardInfo);
        }
      })
    })
    this.showCardInfoList = cardList;
    this.dataCallback(cardList, this.getAllNotSilentCardList());
  }

  private async getCardInfoList(context: Context): Promise<CardInfo[]> {
    let cardInfoList = await this.queryAllCardInfo(context);
    // 卡片优先级排序，同时剔除用户主动关闭时间<时间戳的卡片
    cardInfoList.sort((cardInfo1: CardInfo, cardInfo2: CardInfo) => {
      if (!cardInfo1 || !cardInfo2) {
        return 0;
      }
      if (cardInfo1.priority === undefined || cardInfo2.priority === undefined) {
        return 0;
      }
      return cardInfo1.priority - cardInfo2.priority;
    });
    this.allCardInfoList = cardInfoList;
    // 后面再做过滤，解决时间刷新问题
    cardInfoList = cardInfoList.filter(cardInfo => {
      return !this.isSilentStatusHideByUser(cardInfo);
    })
    cardInfoList.forEach(cardInfo => {
      LogUtil.info(`${TAG} getCardInfoList ${cardInfo.cardName}`);
    })
    return cardInfoList;
  }

  public isSilentStatusHideByUser(cardInfo: CardInfo, context?: Context): boolean {
    let lastTime = this.getSilentTime(cardInfo, context);
    let interval = new Date().getTime() - lastTime;
    LogUtil.info(`${TAG} isSilentStatusHideByUser cardName: ${cardInfo?.cardName} last time: ${lastTime}, interval: ${interval}`);
    if (!cardInfo.cardController) {
      return true;
    }
    return interval <= cardInfo.cardController?.getSilentInterval();
  }

  public isSilentStatusHideByUser2(cardInfo: CardInfo, context: Context): boolean {
    let lastTime = this.getSilentTime(cardInfo, context);
    let interval = new Date().getTime() - lastTime;
    LogUtil.info(`${TAG} isSilentStatusHideByUser2 cardName: ${cardInfo?.cardName} last time: ${lastTime}, interval: ${interval}`);
    return interval <= DateTimeUtil.getPerHourInMillis() * 12;
  }

  private async queryAllCardInfo(context: Context): Promise<CardInfo[]> {
    LogUtil.info(`${TAG} queryAllCardInfo start`);
    let taskGroup: taskpool.TaskGroup = new taskpool.TaskGroup();
    for (let index = 0; index < this.controllerList.length; index++) {
      let controller = this.controllerList[index];
      if (!controller) {
        continue;
      }
      taskGroup.addTask(queryCardData, controller, context);
    }
    let res: Object[] = await taskpool.execute(taskGroup);
    let cardInfoList: CardInfo[] = [];
    res.forEach(object => {
      let cardList: CardInfo[] = object as Array<CardInfo>;
      cardList.forEach(cardInfo => {
        if (cardInfo) {
          cardInfoList.push(cardInfo);
        }
      })
    })
    LogUtil.info(`${TAG} queryAllCardInfo finished, card info list size: ${cardInfoList.length}`);
    return cardInfoList;
  }

  async onPageShow(): Promise<void> {
    if (!this.dataCallback) {
      return;
    }
    if (this.allCardInfoList) {
      this.showCardInfoList = this.allCardInfoList.filter(cardInfo => {
        return !this.isSilentStatusHideByUser(cardInfo);
      }).slice(0, SHOW_CARD_MAX_LENGTH);
      this.dataCallback(this.showCardInfoList, this.getAllNotSilentCardList());
    }
  }

  async destroy(context: Context): Promise<void> {
    this.controllerList.forEach((controller) => {
      let dataShareHelper = this.dataShareMap.get(controller);
      this.closeDataShareHelper(controller, dataShareHelper);
    })
    BundleStatusChangeManager.getInstance().unRegisterBundleChangedListener(this.bundleStatusCallback);
    this.controllerList.length = 0;
    this.dataShareMap.clear();
    this.allCardInfoList.length = 0;
    this.showCardInfoList.length = 0;
    this.bundleList.length = 0;
  }

  getAllNotSilentCardList(): CardInfo[] {
    return this.allCardInfoList.filter(cardInfo => {
      return !this.isSilentStatusHideByUser(cardInfo);
    });
  }

  private async closeDataShareHelper(controller: CardController, dataShareHelper: dataShare.DataShareHelper) {
    await controller.unRegisterDataChange(dataShareHelper);
    dataShareHelper?.close();
  }
}

export default new StorageCleanupCardManager();

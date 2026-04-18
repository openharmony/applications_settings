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
import bundleManager from '@ohos.bundle.bundleManager';
import { EventBus } from '@ohos/settings.common/src/main/ets/framework/common/EventBus';
import { DateTimeUtil } from '@ohos/settings.common/src/main/ets/utils/DateTimeUtil';
import { LogUtil } from '@ohos/settings.common/src/main/ets/utils/LogUtil';
import { ResourceUtil } from '@ohos/settings.common/src/main/ets/utils/ResourceUtil';
import { ToastUtil } from '@ohos/settings.common/src/main/ets/utils/ToastUtil';
import { CARD_DISAPPEAR_DELAY, CLEAR_CARD_STORAGE_PROPORTION } from '../constant/StorageConstant';
import { CardController } from '../controller/CardController';
import { CardInfo } from '../model/CardInfo';
import StorageCleanupCardManager from '../model/StorageCleanupCardManager';
import { StorageSizeUtil } from '../utils/StorageSizeUtil';

export const CACHE_CLEAN_CARD_STATUS: string = 'cardStatusChange';

export const CACHE_QUERY_MAX_TIME = DateTimeUtil.getPerSecondInMillis() * 30;

export const CACHE_CARD_BASE_INFO: CardInfo = {
  serviceName: 'com.storage.clearcache',
  abilityName: 'clearcache',
  cardName: 'clearCache'
}

export const enum QueryStatus {
  // 清理卡片初始状态
  CARD_STATUS_INIT = 'init',
  // 清理卡片状态正在计算
  CARD_STATUS_CALCULATING = 'calculating',
  // 清理卡片状态有缓存可清理
  CARD_STATUS_HAVE_CACHE = 'have_cache',
  // 清理卡片状态没有缓存可清理
  CARD_STATUS_NO_CACHE = 'no_cache',
  // 清理卡片状态空卡片
  CARD_STATUS_EMPTY = 'empty',
  // 清理卡片状态正在清理
  CARD_STATUS_CLEANING = 'cleaning'
}

/**
 * 一键清理缓存功能管理类
 */
@Sendable
export class AllBundleCacheManager {
  private static instance: AllBundleCacheManager;
  private readonly tag: string = 'AllCacheManager';
  private cacheSizeText: string = '';
  private summaryString: string = '';
  private queryStatus: QueryStatus = QueryStatus.CARD_STATUS_INIT;

  private constructor() {
    LogUtil.showWarn(this.tag, 'create instance......');
  }

  /**
   * 获取manager单实例
   *
   * @returns manager单实例
   */
  public static getInstance(): AllBundleCacheManager {
    if (!AllBundleCacheManager.instance) {
      AllBundleCacheManager.instance = new AllBundleCacheManager();
    }
    return AllBundleCacheManager.instance;
  }

  /**
   * 重置当前缓存查询状态
   */
  public resetQueryStatusIfNeed(): void {
    if (this.queryStatus === QueryStatus.CARD_STATUS_EMPTY) {
      LogUtil.showInfo(this.tag, `getInstance reset query status`)
      this.queryStatus = QueryStatus.CARD_STATUS_INIT;
    }
  }

  /**
   * 启动查询缓存，并根据返回接口更新查询状态通知UI刷新
   */
  public async triggerQueryCacheSize(): Promise<void> {
    if (this.queryStatus === QueryStatus.CARD_STATUS_CALCULATING) {
      LogUtil.showError(this.tag, `triggerQueryCacheSize last query processing!`);
      return;
    }
    LogUtil.showWarn(this.tag, 'trigger getAllBundleCacheSize...')
    this.updateQueryStatus(QueryStatus.CARD_STATUS_CALCULATING);

    let isQuerySuccess: boolean = false;
    let timeoutPromise: Promise<QueryStatus> = new Promise((resolve: Function, reject: Function) => {
      setTimeout(() => {
        if (!isQuerySuccess && this.queryStatus === QueryStatus.CARD_STATUS_CALCULATING) {
          LogUtil.showError(this.tag, 'getAllBundleCacheSize timeout!')
          resolve(QueryStatus.CARD_STATUS_NO_CACHE);
        }
      }, CACHE_QUERY_MAX_TIME);
    });

    let queryPromise: Promise<QueryStatus> = new Promise(async (resolve: Function, reject: Function) => {
      try {
        let start = new Date().getTime();
        let size: number = await bundleManager.getAllBundleCacheSize();
        let end = new Date().getTime();
        LogUtil.showInfo(this.tag, `getAllBundleCacheSize cost time: ${end - start}, res: ${size}`);
        isQuerySuccess = true;
        if (size >= CLEAR_CARD_STORAGE_PROPORTION) {
          // 有可清理缓存
          this.cacheSizeText = StorageSizeUtil.formatDataIntl(parseInt(size.toString()), 0, true);
          this.summaryString =
            ResourceUtil.getFormatStringSync($r('app.string.clear_cache_summary'), this.cacheSizeText);
          resolve(QueryStatus.CARD_STATUS_HAVE_CACHE);
        }
      } catch (error) {
        LogUtil.info(`${this.tag} getAllBundleCacheSize error, code: ${error?.code} message: ${error?.message}`);
      }
      // 如果缓存大小不足阈值或接口返回报错，就显示无可清理缓存
      resolve(QueryStatus.CARD_STATUS_NO_CACHE);
    });

    let resStatus:QueryStatus = await Promise.race([timeoutPromise, queryPromise]);
    this.updateQueryStatus(resStatus);
  }

  private updateQueryStatus(status: QueryStatus): void {
    LogUtil.showInfo(this.tag, `update cache query status: [${status}], last status: [${this.queryStatus}]`);
    this.queryStatus = status;
    EventBus.getInstance().emit(CACHE_CLEAN_CARD_STATUS, status);
    if (status === QueryStatus.CARD_STATUS_NO_CACHE) {
      setTimeout(() => {
        this.updateQueryStatus(QueryStatus.CARD_STATUS_EMPTY);
      }, CARD_DISAPPEAR_DELAY);
    }
  }

  /**
   * 执行一键清理缓存操作，并刷新卡片展示状态
   */
  public async executeCacheClean(): Promise<void> {
    // 正在清理状态
    this.updateQueryStatus(QueryStatus.CARD_STATUS_CLEANING);
    try {
      let start = Date.now();
      await bundleManager.cleanAllBundleCache();
      let end = Date.now();
      LogUtil.showInfo(this.tag, `cleanAllBundleCache cost time is ${end - start} `);
      let toastString =
        ResourceUtil.getFormatStringSync($r('app.string.clear_cache_cleaning_toast'), this.cacheSizeText);
      ToastUtil.showToast(toastString, ToastUtil.SHORT_DURATION);
      // 清理完成删除卡片
      this.updateQueryStatus(QueryStatus.CARD_STATUS_EMPTY);
      // 卡片静默12h
      StorageCleanupCardManager.refreshCardSilentTime(CACHE_CARD_BASE_INFO);
    } catch (error) {
      LogUtil.showError(this.tag, `cleanAllBundleCache error, code: ${error?.code} msg: ${error?.message}`);
      // 清理接口失败，直接删除卡片
      this.updateQueryStatus(QueryStatus.CARD_STATUS_EMPTY);
    }
  }

  public getCardInfo(cardController: CardController, queryStatus?: QueryStatus): CardInfo[] {
    let status: QueryStatus = queryStatus ?? this.queryStatus;
    LogUtil.showInfo(this.tag, `getCardInfo cache query status: [${status}]`);
    let cardInfo: CardInfo = {
      serviceName: 'com.storage.clearcache',
      abilityName: 'clearcache',
      cardName: 'clearCache',
      titleString: $r('app.string.clear_cache_title'),
      cardController: cardController
    }
    switch (status) {
      case QueryStatus.CARD_STATUS_INIT:
      case QueryStatus.CARD_STATUS_CALCULATING:
        cardInfo.summaryString = $r('app.string.clear_cache_caculating');
        break;
      case QueryStatus.CARD_STATUS_HAVE_CACHE:
        cardInfo.summaryString = this.summaryString;
        cardInfo.buttonList = [{ buttonString: $r('app.string.clear_cache_button_name') }];
        break;
      case QueryStatus.CARD_STATUS_NO_CACHE:
        cardInfo.summaryString = $r('app.string.clear_cache_not_clear_cache');
        break;
      case QueryStatus.CARD_STATUS_EMPTY:
        return [];
      case QueryStatus.CARD_STATUS_CLEANING:
        cardInfo.summaryString = $r('app.string.clear_cache_cleaning_up');
        break;
      default:
        LogUtil.showWarn(this.tag, `getCardInfo invalid cache query status: [${status}]`);
        break;
    }
    return [cardInfo];
  }
}
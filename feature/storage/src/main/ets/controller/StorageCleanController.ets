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
import dataShare from '@ohos.data.dataShare';
import { EventBus } from '@ohos/settings.common/src/main/ets/framework/common/EventBus';
import { DateTimeUtil } from '@ohos/settings.common/src/main/ets/utils/DateTimeUtil';
import { LogUtil } from '@ohos/settings.common/src/main/ets/utils/LogUtil';
import { CLEAR_CARD_MAX_PROPORTION } from '../constant/StorageConstant';
import {
  AllBundleCacheManager,
  CACHE_CARD_BASE_INFO,
  CACHE_CLEAN_CARD_STATUS,
  QueryStatus,
} from '../model/AllBundleCacheManager';
import { ButtonInfo, CardInfo, ControllerInfo } from '../model/CardInfo';
import StorageCleanupCardManager from '../model/StorageCleanupCardManager';
import { CardController } from './CardController';

// instrument ignore file
@Sendable
export class StorageCleanController extends CardController {
  private cacheCleanManager: AllBundleCacheManager;

  constructor(controllerInfo: ControllerInfo, proportion: number) {
    super(controllerInfo, proportion);
    this.tag = 'StorageCleanController';
    this.cacheCleanManager = AllBundleCacheManager.getInstance();
    this.cacheCleanManager.resetQueryStatusIfNeed();
  }

  isNeedShow(context: Context): boolean {
    if (this.proportion <= CLEAR_CARD_MAX_PROPORTION) {
      LogUtil.info(`${this.tag} current proportion: ${this.proportion}, no need show.`);
      return false;
    }
    let shouldKeepSilent: boolean = StorageCleanupCardManager.isSilentStatusHideByUser2(CACHE_CARD_BASE_INFO, context);
    LogUtil.info(`${this.tag} should keep silent: ${shouldKeepSilent}`);
    return !shouldKeepSilent;
  }

  async queryCardInfo(context: Context): Promise<CardInfo[]> {
    return this.cacheCleanManager.getCardInfo(this);
  }

  async registerDataChange(dataShareHelper: dataShare.DataShareHelper | undefined,
    callback: (cardInfos?: CardInfo[], cardController?: CardController) => void, context: Context): Promise<void> {
    LogUtil.info(`${this.tag} registerDataChange`);
    EventBus.getInstance().on(CACHE_CLEAN_CARD_STATUS, (data: QueryStatus) => {
      LogUtil.info(`${this.tag} cardStatusChange callback, status is ${data}`);
      let cardInfos: CardInfo[] = this.cacheCleanManager.getCardInfo(this, data);
      if (data === QueryStatus.CARD_STATUS_EMPTY) {
        callback();
      } else {
        callback(cardInfos, this);
      }
    })
    if (this.isNeedShow(context)) {
      this.cacheCleanManager.triggerQueryCacheSize();
    }
  }

  async clickButton(context: Context, buttonInfo: ButtonInfo, cardInfo: CardInfo, pathInfos: NavPathStack,
    navigationMode: boolean, callback: ((isShow: boolean, cardInfo?: CardInfo) => void)): Promise<void> {
    LogUtil.info(`${this.tag} clickButton`);
    this.cacheCleanManager.executeCacheClean();
  }

  async unRegisterDataChange(dataShareHelper: dataShare.DataShareHelper | undefined): Promise<void> {
    LogUtil.info(`${this.tag} unRegisterDataChange`);
    EventBus.getInstance().off(CACHE_CLEAN_CARD_STATUS);
  }

  getSilentInterval(): number {
    return DateTimeUtil.getPerHourInMillis() * 12;
  }
}
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
import { EventBus } from '@ohos/settings.common/src/main/ets/framework/common/EventBus';
import { CompCtrlParam, ComponentControl, } from '@ohos/settings.common/src/main/ets/framework/model/SettingBaseModel';
import { CardInfo } from '@ohos/settings.storage/src/main/ets/model/CardInfo';
import StorageCleanupCardManager from '@ohos/settings.storage/src/main/ets/model/StorageCleanupCardManager';
import { LogUtil } from '@ohos/settings.common/src/main/ets/utils/LogUtil';
/* instrument ignore file */
const TAG = 'MoreCardPageControl';

export class MoreCardPageControl implements ComponentControl {
  private cardList?: CardInfo[]
  private compId: string = ''
  private params: CardInfo[] = []

  init(compParam: CompCtrlParam): void {
    LogUtil.info(`${TAG} MoreCardPageController init`)
    if (!compParam || !compParam.compId) {
      LogUtil.error(`${TAG} init fail, compParam is invalid`);
      return;
    }
  }

  onPageShow(): void {
    LogUtil.info(`${TAG} MoreCardPageController page show`)
    StorageCleanupCardManager.init(getContext(this), (cardList?: Array<CardInfo>, allCardList?: Array<CardInfo>) => {
      LogUtil.info(`${TAG} allListlength : ${allCardList?.length}`);
      EventBus.getInstance().emit('handleFullCardInfo', allCardList);
    })
  }

  onPageHide(): void {
    LogUtil.info(`${TAG} MoreCardPageController page hide`);
    StorageCleanupCardManager.destroy(getContext(this));
  }

  destroy(): void {
    LogUtil.info(`${TAG} MoreCardPageControl destory`);
  }
}

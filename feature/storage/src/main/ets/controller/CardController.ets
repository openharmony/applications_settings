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
import { dataShare } from '@kit.ArkData';
import { DateTimeUtil } from '@ohos/settings.common/src/main/ets/utils/DateTimeUtil';
import { LogUtil } from '@ohos/settings.common/src/main/ets/utils/LogUtil';
import { INVALID_CARD_NAME } from '../constant/StorageConstant';
import { ButtonInfo, CardInfo, ControllerInfo } from '../model/CardInfo';

@Sendable
export class CardController {
  private QUERY_DATA_TIMEOUT: number = 1200;
  public tag: string = 'CardController';
  public controllerInfo: ControllerInfo = new ControllerInfo();
  public proportion: number;

  constructor(controllerInfo: ControllerInfo, proportion: number) {
    // @Sendable不能直接赋值
    this.proportion = proportion;
    this.controllerInfo.clone(controllerInfo);
  }

  isNeedShow(context: Context): boolean {
    LogUtil.info(`${this.tag} CardController isNeedShow`);
    return true;
  }

  async createDataShareHelper(context: Context): Promise<dataShare.DataShareHelper | undefined> {
    return undefined;
  }

  async queryCardWithTimeKeeping(context: Context): Promise<Array<CardInfo>> {
    LogUtil.info(`${this.tag} queryCardWithTimeout`);
    let promise: Promise<Array<CardInfo>> = new Promise((resolve: Function) => {
      setTimeout(() => {
        resolve([{ cardName: INVALID_CARD_NAME }]);
      }, this.QUERY_DATA_TIMEOUT);
    })
    return Promise.race([this.queryCardInfoWithNeedShow(context), promise]);
  }

  private async queryCardInfoWithNeedShow(context: Context): Promise<Array<CardInfo>> {
    LogUtil.info(`${this.tag} queryCardInfoWithNeedShow`);
    if (this.isNeedShow(context)) {
      return await this.queryCardInfo(context);
    }
    return [];
  }

  async queryCardInfo(context: Context): Promise<Array<CardInfo>> {
    return [];
  }

  async registerDataChange(dataShareHelper: dataShare.DataShareHelper | undefined,
    callback: (cardInfos?: CardInfo[], cardController?: CardController) => void, context: Context): Promise<void> {
  }

  async unRegisterDataChange(dataShareHelper: dataShare.DataShareHelper | undefined): Promise<void> {
  }

  getSilentInterval(): number {
    return DateTimeUtil.getPerDayInMillis();
  }

  async clickButton(context: Context, buttonInfo: ButtonInfo, cardInfo: CardInfo, pathInfos: NavPathStack,
    navigationMode: boolean, callback: ((isShow: boolean, cardInfo?: CardInfo) => void)): Promise<void> {
    LogUtil.info(`${this.tag} clickButton ${buttonInfo.action}`);
  }
}


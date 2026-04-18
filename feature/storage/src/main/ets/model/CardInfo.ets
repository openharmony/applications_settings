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

import { GET_APP_STATS_TIMEOUT } from '../constant/StorageConstant';
import { CardController } from '../controller/CardController';
import { StorageAppUninstallController } from '../controller/StorageAppUninstallController';

export class CardData {
  public id?: number
  public key?: string
  public value?: string
}

@Sendable
export class ControllerInfo {
  public bundleName?: string;
  public abilityName?: string;
  public queryUri?: string;
  public dataChangeUri?: string;
  public priority?: number;
  public controller: string = '';
  public cardType: number = 0;

  clone(cardInfo: ControllerInfo) {
    this.bundleName = cardInfo.bundleName;
    this.abilityName = cardInfo.abilityName;
    this.queryUri = cardInfo.queryUri;
    this.dataChangeUri = cardInfo.dataChangeUri;
    this.priority = cardInfo.priority;
    this.controller = cardInfo.controller;
    this.cardType = cardInfo.cardType;
  }
}

export class ButtonInfo {
  public button?: string;
  public buttonString?: ResourceStr;
  public action?: string;
  public routerUri?: string;
  public callUri?: string;
  public actionParams?: string;
}

export class SummaryParams {
  public type?: string;
  public value?: string;
}

export class CardInfo {
  public serviceName?: string;
  public abilityName?: string;
  public cardName?: string;
  public icon?: string;
  public iconImg?: Uint8Array;
  public title?: string;
  public titleString?: ResourceStr;
  public summaryString?: ResourceStr;
  public summary?: string;
  public summaryParam?: Array<SummaryParams>;
  public buttonList?: Array<ButtonInfo>;
  public priority?: number;
  public cardController?: CardController;
}

@Concurrent
export async function queryAppStorageData(controller: StorageAppUninstallController,
  bundleName: string, index: number): Promise<number> {
  let promise: Promise<number> = new Promise((resolve: Function, reject: Function) => {
    setTimeout(() => {
      resolve([]);
    }, GET_APP_STATS_TIMEOUT); // 500ms超时时间，设置的太短可能导致数据获取失败，导致最终页面显示的总大小不一致
  })
  return await Promise.race([controller.getBundleStorage(bundleName, index), promise]);
}
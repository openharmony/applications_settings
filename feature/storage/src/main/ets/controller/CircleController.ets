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

import storage from '@ohos.file.storageStatistics';
import { CommonCircleController } from '@ohos/settings.common/src/main/ets/core/controller/MenuController';
import { PageLifecycleObserverInterface } from '@ohos/settings.common/src/main/ets/core/lifecycle/Lifecycle';
import { SettingsBaseMenu } from '@ohos/settings.common/src/main/ets/core/model/menu/SettingsMenu';
import { LogUtil } from '@ohos/settings.common/src/main/ets/utils/LogUtil';
import { ResourceUtil } from '@ohos/settings.common/src/main/ets/utils/ResourceUtil';
import { Controller } from '@ohos/settings.common/src/main/ets/core/controller/Controller';
import { PRECISION0, PRECISION2 } from '@ohos/settings.common/src/main/ets/constant/ViewConstant';
import { StorageSizeUtil } from '../utils/StorageSizeUtil';

export interface StorageData {
  detail: storage.StorageStats,
  otherStorage: number
}

@Observed
export class CircleController extends CommonCircleController implements PageLifecycleObserverInterface {
  public tag: string = 'CircleController : ';
  private usedBytesNumber: number = 0;
  private freeBytesNumber: number = 0;
  private storageDetail: storage.StorageStats | null = null;
  public message: string = '';
  public totalBytes: string = '';
  public usedBytes: string = '';
  public freeBytes: string = '';
  public proportion: number = 0;
  public categoryValues: number[] = [];
  public totalValue: number = 0;
  public valueColors: (ResourceColor | LinearGradient)[] = [];

  static CreateCircleController(menu: SettingsBaseMenu): Controller {
    return new CircleController(menu);
  }

  updateStatus(): void {
    this.initValueColors();
  }

  /**
   * initial data
   */
  initial(): void {
    try {
      LogUtil.info(`${this.tag} get storage info start`);
      Promise.all([
        storage.getUserStorageStats(),
        storage.getFreeSize()
      ]).then((res) => {
        LogUtil.info(`${this.tag} get getUserStorageStats and getFreeSize end`);
        this.storageDetail = res[0];
        this.freeBytesNumber = res[1];
        this.showWhenAllDataReady();
      }).catch((error: Error) => {
        LogUtil.error(`${this.tag} get getUserStorageStats and getFreeSize failed, error reason: ${error}`);
      });
    } catch (error) {
      LogUtil.error(`${this.tag} get storage info failed: ${error?.message} code: ${error?.code}`);
    }
  }

  private showWhenAllDataReady() {
    let detail = this.storageDetail;
    if (detail && this.freeBytesNumber >= 0) {
      this.usedBytesNumber = detail.total - this.freeBytesNumber;
      if (this.usedBytesNumber / detail.total * 100 < 1) {
        this.proportion = Math.ceil(Number((this.usedBytesNumber / detail.total * 100))).valueOf();
      } else {
        this.proportion = Math.floor(Number((this.usedBytesNumber / detail.total * 100))).valueOf();
      }
      this.totalBytes = StorageSizeUtil.formatData(detail.total, PRECISION0);
      this.freeBytes = StorageSizeUtil.formatData(this.freeBytesNumber, PRECISION2);
      this.usedBytes = StorageSizeUtil.formatData(this.usedBytesNumber, PRECISION2);
      ResourceUtil.getAnyStrFormatString(this.menu.extra as Resource, this.usedBytes, this.totalBytes)
        .then((message: string) => {
          this.message = message;
          LogUtil.info(`${this.tag} message complete, refreshui msg: ${this.message}, res: ${this.menu.extra}`);
          this.refreshUi()
        });
      let otherStorage = this.usedBytesNumber - detail.image - detail.video - detail.audio - detail.file - detail.app;
      this.categoryValues = [detail.image, detail.video, detail.audio, detail.file, detail.app, otherStorage];
      this.totalValue = detail.total;
      this.publishDataChange({ detail: detail, otherStorage: otherStorage } as StorageData);
      this.refreshUi()
      LogUtil.info(`${this.tag} data complete, refreshui`);
    } else {
      LogUtil.error(`${this.tag} show data error, free byte ${this.freeBytesNumber}.`);
    }
  }

  initValueColors() {
    this.valueColors.push(new LinearGradient([{ color: $r('app.color.data_panel_start_1'), offset: 0 },
      { color: $r('app.color.data_panel_end_1'), offset: 1 }]),
      new LinearGradient([{ color: $r('app.color.data_panel_start_2'), offset: 0 },
        { color: $r('app.color.data_panel_end_2'), offset: 1 }]),
      new LinearGradient([{ color: $r('app.color.data_panel_start_3'), offset: 0 },
        { color: $r('app.color.data_panel_end_3'), offset: 1 }]),
      new LinearGradient([{ color: $r('app.color.data_panel_start_4'), offset: 0 },
        { color: $r('app.color.data_panel_end_4'), offset: 1 }]),
      new LinearGradient([{ color: $r('app.color.data_panel_start_5'), offset: 0 },
        { color: $r('app.color.data_panel_end_5'), offset: 1 }]),
      new LinearGradient([{ color: $r('app.color.data_panel_start_100'), offset: 0 },
        { color: $r('app.color.data_panel_end_100'), offset: 1 }]));
  }

  onPageShow(): void {
    LogUtil.info(`${this.tag} onPageShow`);
    this.initial();
  }

  onPageHide(): void {
    LogUtil.info(`${this.tag} onPageHide`);
  }

  public getObserverKey = (): string => {
    return this.menu?.key ?? '';
  }
}

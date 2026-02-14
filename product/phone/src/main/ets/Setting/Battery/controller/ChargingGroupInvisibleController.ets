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
import batteryInfo from '@ohos.batteryInfo';
import { DynamicDataSource } from '@ohos/settings.common/src/main/ets/framework/model/DynamicDataSource';
import { CompCtrlParam, ComponentControl } from '@ohos/settings.common/src/main/ets/framework/model/SettingBaseModel';
import {
  ItemResultType,
  ItemType,
  SettingItemModel,
} from '@ohos/settings.common/src/main/ets/framework/model/SettingItemModel';
import { LogUtil } from '@ohos/settings.common/src/main/ets/utils/LogUtil';
import { DisplayBatteryPercentageSwitchController } from './DisplayBatteryPercentageSwitchController';

/**
 * 内容空的时候自动隐藏菜单组控制器
 *
 * @since 2024-06-25
 */
export class ChargingGroupInvisibleController implements ComponentControl {
  public tag: string = 'ChargingGroupInvisibleController: ';
  public dataSource?: DynamicDataSource;

  init(compParam: CompCtrlParam): void {
    if (!compParam || !compParam.dataSource) {
      LogUtil.error(`${this.tag} init fail, compParam is invalid`);
      return;
    }

    LogUtil.info(`${this.tag} init`);
    this.dataSource = compParam.dataSource as DynamicDataSource
    this.setDisplayBatteryPercentageMenu();
  }

  private setDisplayBatteryPercentageMenu(): void {
    let itemModel = {
      id: 'display_battery_percentage_switch',
      type: ItemType.ITEM_TYPE_STANDARD,
      title: { content: $r('app.string.display_battery_percentage') },
      result: { type: ItemResultType.RESULT_TYPE_TOGGLE, result: { state: true } },
      compControl: new DisplayBatteryPercentageSwitchController(),
    } as SettingItemModel;
    this.dataSource?.push(itemModel);
  }

  destroy(): void {
  }
}
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

import settings from '@ohos.settings';
import { EventBus } from '@ohos/settings.common/src/main/ets/framework/common/EventBus';
import { OrderedDataSource } from '@ohos/settings.common/src/main/ets/framework/model/OrderedDataSource';
import { CompCtrlParam } from '@ohos/settings.common/src/main/ets/framework/model/SettingBaseModel';
import {
  ItemDetailType,
  ItemResultType,
  ItemType,
  SettingItemModel
} from '@ohos/settings.common/src/main/ets/framework/model/SettingItemModel';
import {
  notifyCompStateChange,
  SettingResultState,
  SettingStateType
} from '@ohos/settings.common/src/main/ets/framework/model/SettingStateModel';
import { LogUtil } from '@ohos/settings.common/src/main/ets/utils/LogUtil';
import { SettingsDataUtils } from '@ohos/settings.common/src/main/ets/utils/SettingsDataUtils';
import { WEEK_LIST_COMPONENT_EVENT, WeekListComponent } from '../components/WeekListComponent';
import {
  SCHEDULED_POWER_ON_OFF_WEEK_REPEAT,
  SCHEDULED_POWER_ON_OFF_WORKDAY_REPEAT,
  SCHEDULED_POWER_TIME_NOT_SET,
  SCHEDULED_POWER_ON_OFF_CALENDAR_DATA
} from '../constants/ScheduledPowerOnOffConstant';
import { ScheduledPowerOnOffDataUtil } from '../utils/ScheduledPowerOnOffDataUtil';
import { ScheduledPowerOnOffController } from './ScheduledPowerOnOffController';
/* instrument ignore file */
const TAG: string = 'ScheduledPowerOnOffRepeatController: ';
const POWER_REPEAT_ID: string = 'power_repeat';
const POWER_WEEK_REPEAT_ID: string = 'week_repeat';

@Builder
function weekBuilder(args: object): void {
  WeekListComponent({ item: (args as SettingItemModel) });
}

/**
 * 定时开关机重复信息Controller
 *
 * @since 2024-12-16
 */
export class ScheduledPowerOnOffRepeatController extends ScheduledPowerOnOffController {
  private dataSource?: OrderedDataSource;
  private switchMode: string = '';
  private weekRepeatEventCallback = () => {
    LogUtil.showInfo(TAG, `weekRepeatEventCallback`);
    this.updateTimer();
  };
  protected ScheduledPowerOnOffChangeCallback = () => {
    let switchMode: string = ScheduledPowerOnOffDataUtil.getSwitchModeType(TAG);
    LogUtil.showInfo(TAG, `ScheduledPowerOnOff mode change callback ${switchMode}`);
    if (this.isSwitchOpen(switchMode)) {
      this.addRepeatItem();
    } else {
      this.removeTimeRepeatItem();
      this.removeWeekRepeatItem();
    }
  };

  init(compParam: CompCtrlParam): void {
    if (!compParam || !compParam.compId) {
      LogUtil.showError(TAG, `init fail, compParam is invalid`);
      return;
    }
    this.compId = compParam.compId;
    this.dataSource = (compParam.dataSource) as OrderedDataSource;
    this.switchMode = ScheduledPowerOnOffDataUtil.getSwitchModeType(TAG);

    if (this.isSwitchOpen(this.switchMode)) {
      this.addRepeatItem();
    }
    this.registerDataHelper();
    EventBus.getInstance().on(WEEK_LIST_COMPONENT_EVENT, this.weekRepeatEventCallback);
    SettingsDataUtils.registerKeyObserverWithDomain(SCHEDULED_POWER_ON_OFF_CALENDAR_DATA,
      settings.domainName.USER_PROPERTY, () => {
        if (this.isSwitchOpen(ScheduledPowerOnOffDataUtil.getSwitchModeType(TAG))) {
          this.removeTimeRepeatItem();
          this.removeWeekRepeatItem();
          this.addRepeatItem();
        }
      });
  }

  private addRepeatItem(): void {
    this.addTimeRepeatItem();
    if (String(ScheduledPowerOnOffDataUtil.getRepeatMenuChose(TAG)) == SCHEDULED_POWER_ON_OFF_WEEK_REPEAT) {
      this.addWeekRepeatItem();
    }
  }

  private addTimeRepeatItem(): void {
    this.dataSource?.pushData({
      id: POWER_REPEAT_ID,
      type: ItemType.ITEM_TYPE_STANDARD,
      title: { content: $r('app.string.time_repeat') },
      result: {
        type: ItemResultType.RESULT_TYPE_TEXT,
        result: { content: this.getRepeatMenu()[ScheduledPowerOnOffDataUtil.getRepeatMenuChose(TAG)] },
      },
      detail: {
        type: ItemDetailType.DETAIL_TYPE_MENU,
        icon: $r('sys.symbol.chevron_right'),
        isSymbolIcon: true,
        menu: {
          items: this.getRepeatMenu(),
          defaultFocus: ScheduledPowerOnOffDataUtil.getRepeatMenuChose(TAG),
          selectIcon: $r('app.media.ic_selected'),
          style: { width: $r('app.float.length_224') },
          onSelected: (index: number) => {
            this.onHandlerSelected(String(index));
          }
        }
      },
    });
  }

  private addWeekRepeatItem(): void {
    this.dataSource?.pushData({
      id: POWER_WEEK_REPEAT_ID,
      type: ItemType.ITEM_TYPE_CUSTOM,
      builder: wrapBuilder(weekBuilder),
    });
  }

  private onHandlerSelected(currentSelect: string) {
    LogUtil.showInfo(TAG, `currentSelect is ${currentSelect}`);
    if (Number(currentSelect) == ScheduledPowerOnOffDataUtil.getRepeatMenuChose(TAG)) {
      return;
    }
    this.setRepeatMenuChose(currentSelect);
    notifyCompStateChange(`${this.compId}.${POWER_REPEAT_ID}`,
      new Map<SettingStateType, SettingResultState>([[SettingStateType.STATE_TYPE_ITEM_RESULT,
        {
          type: ItemResultType.RESULT_TYPE_TEXT, result: { content: this.getRepeatMenu()[Number(currentSelect)] }
        } as SettingResultState]]));
    this.updateTimer();

    if (currentSelect == SCHEDULED_POWER_ON_OFF_WEEK_REPEAT) {
      this.addWeekRepeatItem();
    } else {
      this.removeWeekRepeatItem();
    }
  }

  private removeTimeRepeatItem(): void {
    LogUtil.showInfo(TAG, `remove time select item ${this.compId}`);
    this.dataSource?.removeData({
      id: POWER_REPEAT_ID,
      type: ItemType.ITEM_TYPE_STANDARD,
      title: { content: $r('app.string.time_repeat') },
    });
  }

  private removeWeekRepeatItem(): void {
    LogUtil.showInfo(TAG, `remove week select item ${this.compId}`);
    this.dataSource?.removeData({
      id: POWER_WEEK_REPEAT_ID,
      type: ItemType.ITEM_TYPE_CUSTOM,
    });
  }

  private getRepeatMenu(): ResourceStr[] {
    if (ScheduledPowerOnOffDataUtil.getCalendarData(TAG) != SCHEDULED_POWER_TIME_NOT_SET ||
      ScheduledPowerOnOffDataUtil.getRepeatMenuChose(TAG) == Number(SCHEDULED_POWER_ON_OFF_WORKDAY_REPEAT)) {
      return [
        $r('app.string.single_time_item'),
        $r('app.string.every_day_item'),
        $r('app.string.every_week_item'),
        $r('app.string.statutory_workday_item')
      ]
    }
    return [
      $r('app.string.single_time_item'),
      $r('app.string.every_day_item'),
      $r('app.string.every_week_item')
    ]
  }

  destroy(): void {
    LogUtil.showInfo(TAG, 'onDestroy eventbus');
    this.unRegisterDataHelper();
    EventBus.getInstance().detach(WEEK_LIST_COMPONENT_EVENT, this.weekRepeatEventCallback);
    SettingsDataUtils.unregisterKeyObserverWithDomain(SCHEDULED_POWER_ON_OFF_CALENDAR_DATA,
      settings.domainName.USER_PROPERTY);
  }
}

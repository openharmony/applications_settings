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
import emitter from '@ohos.events.emitter';
import { PushParam } from '@ohos/settings.common/src/main/ets/core/controller/Controller';
import { PageRouter } from '@ohos/settings.common/src/main/ets/framework/common/PageRouter';
import { DynamicDataSource } from '@ohos/settings.common/src/main/ets/framework/model/DynamicDataSource';
import {
  CompCtrlParam,
  ComponentControl,
} from '@ohos/settings.common/src/main/ets/framework/model/SettingBaseModel';
import {
  ItemDetailType,
  ItemResultType,
  ItemType,
  SettingIconType,
  SettingItemModel
} from '@ohos/settings.common/src/main/ets/framework/model/SettingItemModel';
import { NavEntryKey } from '@ohos/settings.common/src/main/ets/utils/Consts';
import { LogUtil } from '@ohos/settings.common/src/main/ets/utils/LogUtil';
import { EVENT_ID_NOT_DISTURB_UPDATE } from '@ohos/settings.common/src/main/ets/event/types';
import {
  notifyCompStateChange,
  SettingBaseState,
  SettingCompState,
  SettingStateType
} from '@ohos/settings.common/src/main/ets/framework/model/SettingStateModel';
import {
  NotDisturbUtils,
  NOT_DISTURB_NUMBER_MINUS
} from '@ohos/settings.notDisturb/src/main/ets/utils/NotDisturbUtils';
import {
  NotDisturbTimerId,
  NotDisturbTimerPararm
} from '@ohos/settings.notDisturb/src/main/ets/model/NotDisturbTimerPararm';
import { NotDisturbTimerManager } from '@ohos/settings.notDisturb/src/main/ets/NotDisturbTimerManager';
import { CommonUtils } from '@ohos/settings.common/src/main/ets/utils/CommonUtils';
import { EventBus } from '@ohos/settings.common/src/main/ets/framework/common/EventBus';
import { StorageEventConstant } from '@ohos/settings.storage/src/main/ets/constant/StorageConstant';

const SCHEDULE_UPDATE_TIMEOUT: number = 30;
const MAX_TIMER_ID: number = 10;
const ITEM_UPDATE_TIMEOUT: number = 10;

/**
 * 免打扰界面动态加载定时规则菜单
 */
export class NotDisturbAddTimeController implements ComponentControl {
  private tag: string = 'NotDisturbAddTimeController: ';
  private updateTimerId: number | null = null;
  private dataSource?: DynamicDataSource;
  private static currentZenItems: SettingItemModel[] = [];
  private readonly timeFormat: Intl.DateTimeFormat = NotDisturbUtils.getFormat();

  public static getCurrentZenItems(): SettingItemModel[] {
    return NotDisturbAddTimeController.currentZenItems;
  }

  init(compParam: CompCtrlParam): void {
    if (!compParam || !compParam.dataSource) {
      LogUtil.error(`${this.tag} init fail, compParam is invalid`);
      return;
    }

    LogUtil.info(`${this.tag} init`);
    this.dataSource = compParam.dataSource as DynamicDataSource;
    EventBus.getInstance().on(StorageEventConstant.EVENT_NOTDISTURB_GROUP_INIT, this.groupInitCallback);
    // 获取用户所有设置的数据
    this.refreshUI();
    emitter.on({
      eventId: EVENT_ID_NOT_DISTURB_UPDATE,
      priority: emitter.EventPriority.IMMEDIATE,
    }, (eventData: emitter.EventData) => {
      this.refreshUI();
    });
  }

  private groupInitCallback = () => {
    LogUtil.info(`${this.tag} groupInitCallback.`);
    this.refreshUI();
  };

  private refreshUI() {
    NotDisturbAddTimeController.currentZenItems.forEach((model) => {
      this.dataSource?.removeData(model);
    });
    setTimeout(() => {
      NotDisturbAddTimeController.currentZenItems = [];
      let zenTimers: NotDisturbTimerPararm[] = NotDisturbTimerManager.getInstance().getTimers(getContext());
      let isDisturbOn: boolean = NotDisturbTimerManager.getInstance().isNotDisturbOpen(getContext());
      let isMaunalTurnOn: boolean =
        isDisturbOn && NotDisturbTimerManager.getInstance().getTimerId(getContext()) === NOT_DISTURB_NUMBER_MINUS;
      LogUtil.info(`${this.tag} on refreshUI, isMaunalTurnOn: ${isMaunalTurnOn}`);

      zenTimers.forEach((zenItem) => {
        if (zenItem?.id < NotDisturbTimerId.USER_SET_START) {
          return;
        }
        let itemModel = {
          id: `not_disturb_schedule_${zenItem?.id}`,
          type: ItemType.ITEM_TYPE_STANDARD,
          title: { content: NotDisturbUtils.getZenModeScheduleRepeatText(zenItem.repeat) },
          desc: { content: NotDisturbUtils.getTimerSummary(this.timeFormat, zenItem.startTime, zenItem.endTime) },
          result: {
            type: ItemResultType.RESULT_TYPE_TEXT,
            result: {
              content: zenItem.isOpen ? $r('app.string.not_disturb_turnedon') : $r('app.string.not_disturb_closed')
            },
          },
          cached: false,
          detail: {
            type: ItemDetailType.DETAIL_TYPE_CUSTOM,
            icon: $r('sys.symbol.chevron_right'),
            isSymbolIcon: true,
            iconType: SettingIconType.ICON_TYPE_ARROW,
            onItemClick: () => {
              LogUtil.info(`${this.tag} onItemClick`);
              PageRouter.push(NavEntryKey.TIME_PERIOD_ENTRY, new PushParam(zenItem));
            }
          },
          enabled: isMaunalTurnOn ? false : true,
          layout: { noNeedDivider: true },
        } as SettingItemModel;

        this.updateTimerId = setTimeout(() => {
          this.dataSource?.pushData(itemModel);
          NotDisturbAddTimeController.currentZenItems.push(itemModel);
        }, ITEM_UPDATE_TIMEOUT);
      });

      LogUtil.info(`${this.tag} on refreshUi ${zenTimers[zenTimers.length - 1]?.id}`);
      let isDisable: boolean = zenTimers[0]?.id === 0 ?
        zenTimers.length - 1 === MAX_TIMER_ID : zenTimers.length === MAX_TIMER_ID;
      notifyCompStateChange('Setting.not_disturb_mode.add_scheduled.add_scheduled_menu',
        new Map<SettingStateType, SettingBaseState>([[SettingStateType.STATE_TYPE_ITEM_ENABLED,
          { state: isDisable || isMaunalTurnOn ? false : true } as SettingCompState]]));
    }, SCHEDULE_UPDATE_TIMEOUT);
  }

  destroy(): void {
    LogUtil.info(`${this.tag} destroy`);
    if (CommonUtils.isPageExist(NavEntryKey.NOT_DISTURB_ENTRY)) {
      LogUtil.info(`${this.tag} the page exist, do not emitter.off`);
      return;
    }
    if (this.updateTimerId != null) {
      clearTimeout(this.updateTimerId);
      this.updateTimerId = null;
    }
    EventBus.getInstance().detach(StorageEventConstant.EVENT_NOTDISTURB_GROUP_INIT, this.groupInitCallback);
    emitter.off(EVENT_ID_NOT_DISTURB_UPDATE);
  }
}
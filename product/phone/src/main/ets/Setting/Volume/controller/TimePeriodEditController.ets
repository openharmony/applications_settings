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
import settings from '@ohos.settings';
import emitter from '@ohos.events.emitter';
import dataShare from '@ohos.data.dataShare';
import { CheckEmptyUtils, LogUtil, PushParam, SettingsDataUtils } from '@ohos/settings.common/index';
import { PADDING_0 } from '@ohos/settings.common/src/main/ets/constant/StyleConstant';
import {
  CompCtrlParam,
  ComponentControl,
  SettingBaseModel,
} from '@ohos/settings.common/src/main/ets/framework/model/SettingBaseModel';
import { SettingPageMenu, SettingPageModel } from '@ohos/settings.common/src/main/ets/framework/model/SettingPageModel';
import { GroupType, SettingGroupModel } from '@ohos/settings.common/src/main/ets/framework/model/SettingGroupModel';
import { EVENT_ID_NOT_DISTURB_UPDATE } from '@ohos/settings.common/src/main/ets/event/types';
import { PageRouter } from '@ohos/settings.common/src/main/ets/framework/common/PageRouter';
import { FontScaleUtils } from '@ohos/settings.common/src/main/ets/utils/FontScaleUtils';
import {
  ItemDetailType,
  ItemResultType,
  ItemType,
  SettingItemModel
} from '@ohos/settings.common/src/main/ets/framework/model/SettingItemModel';
import {
  FOCUS_MODE_TIMER,
  NotDisturbTimerManager
} from '@ohos/settings.notDisturb/src/main/ets/NotDisturbTimerManager';
import {
  FOCUS_MODE_MANUAL_ENABLE,
  NotDisturbUtils,
  NOT_DISTURB_VALUE_DISABLE} from '@ohos/settings.notDisturb/src/main/ets/utils/NotDisturbUtils';
import {
  NotDisturbTimerPararm,
  NotDisturbTimerRepeatType
} from '@ohos/settings.notDisturb/src/main/ets/model/NotDisturbTimerPararm';
import { TimerStatusController } from './TimerStatusController';
import { TimePickerController } from './TimePickerController';
import { NotDisturbDeleteComponent } from '../view/NotDisturbDeleteComponent';
import { NotDisturbDeleteController } from './NotDisturbDeleteController';
import { WeekListController } from './WeekListController';
import { WeekListComponent } from '../view/WeekListComponent';
import { TimerPickerComponent } from '../view/TimerPickerComponent';
import { GlobalContext } from '@ohos/settings.common/src/main/ets/utils/GlobalContext';

@Builder
export function deleteComponentBuilder(param: object): void {
  NotDisturbDeleteComponent({ item: param as SettingGroupModel });
}

const DEFAULT_START: string = '22:00';
const DEFAULT_END: string = '7:00';
const DEFAULT_REPEAT: string = '1,7';
const SETTINGSDATA_UPDATE_TIMEOUT: number = 20;

/**
 * 免打扰定时规则编辑菜单控制器
 */
export class TimePeriodEditController implements ComponentControl {
  public tag: string = 'TimePeriodEditController: ';
  private timer?: NotDisturbTimerPararm;
  private settingPageModel?: SettingPageModel;
  private isAdd: boolean = true;
  private isHasDataChange: boolean = false;
  private dataHelper: dataShare.DataShareHelper | null = null;
  public dataShareHelper?: Promise<dataShare.DataShareHelper> | dataShare.DataShareHelper;
  private oldTimer?: NotDisturbTimerPararm;

  init(compParam: CompCtrlParam): void {
    LogUtil.info(`${this.tag} init`);
    if (!compParam || !compParam.compId || !compParam.component) {
      LogUtil.error(`${this.tag} init fail, compParam is invalid`);
      return;
    }

    //不用 compParam.param.config 引用变量，在修改后可能不保存
    if (compParam.param && compParam.param instanceof PushParam) {
      this.isAdd = false;
      let originalTimer = compParam.param.config as NotDisturbTimerPararm;
      let context = NotDisturbTimerManager.getContext();
      let queryTimer = NotDisturbTimerManager.getInstance().getTimerById(context, originalTimer.id);
      this.oldTimer = queryTimer as NotDisturbTimerPararm;

      this.timer = {
        id: originalTimer.id,
        isOpen: queryTimer ? (queryTimer as NotDisturbTimerPararm).isOpen : originalTimer.isOpen,
        repeat: originalTimer.repeat,
        startTime: originalTimer.startTime,
        endTime: originalTimer.endTime,
        repeatType: originalTimer.repeatType,
        skipEndTime: queryTimer ? (queryTimer as NotDisturbTimerPararm).skipEndTime : originalTimer.skipEndTime,
        repeatText: NotDisturbUtils.getZenModeScheduleRepeatText(originalTimer.repeat)
      }
    } else {
      this.timer = {
        id: 1,
        isOpen: true,
        repeat: DEFAULT_REPEAT,
        startTime: DEFAULT_START,
        endTime: DEFAULT_END,
        repeatType: 1,
        skipEndTime: 0,
        repeatText: NotDisturbUtils.getZenModeScheduleRepeatText(DEFAULT_REPEAT)
      };
      this.isAdd = true;
    }
    LogUtil.info(`${this.tag} this.timer`);
    this.settingPageModel = compParam.component as SettingPageModel;
    if (!this.settingPageModel) {
      LogUtil.error(`${this.tag} init fail, settingPageModel is invalid`);
      return;
    }
    this.settingPageModel.title = this.isAdd ? $r('app.string.timer_add') : $r('app.string.timer_edit');
    if (!this.isAdd) {
      this.setStatusGroup();
    }
    this.setRepeatGroup();
    this.setTimeGroup();
    this.addDeleteButton();
    this.addRightMenu();
  }

  registerDataChange(): void {
    if (this.dataHelper) {
      SettingsDataUtils.registerUserDataChange(this.dataHelper, FOCUS_MODE_TIMER, this.onDataChange);
    } else {
      (SettingsDataUtils.createDataHelper(FOCUS_MODE_TIMER) as Promise<dataShare.DataShareHelper>)
        .then((dataShareHelper?: dataShare.DataShareHelper) => {
          if (dataShareHelper) {
            this.dataHelper = dataShareHelper;
            SettingsDataUtils.registerUserDataChange(this.dataHelper, FOCUS_MODE_TIMER, this.onDataChange);
          }
        })
    }
    LogUtil.info(`${this.tag} registerDataChange`);
  }

  private onDataChange = () => {
    LogUtil.info(`${this.tag} on onDataChange, }`);
    this.isHasDataChange = true;
  }

  unRegisterDataChange(): void {
    SettingsDataUtils.unRegisterUserDataChange(this.dataHelper as dataShare.DataShareHelper, FOCUS_MODE_TIMER);
    LogUtil.info(`${this.tag} unRegisterDataChange`);
  }

  onPageShow(component: SettingBaseModel): void {
    LogUtil.info(`${this.tag} onPageShow`);
    this.registerDataChange()
  }

  onPageHide(component: SettingBaseModel): void {
    LogUtil.info(`${this.tag} onPageHide: ${this.isHasDataChange}`);
    if (this.isHasDataChange) {
      emitter.emit({
        eventId: EVENT_ID_NOT_DISTURB_UPDATE
      });
    }
    this.unRegisterDataChange();
  }

  private setStatusGroup(): void {
    let statusGroupModel: SettingGroupModel = {
      id: 'status_group',
      type: GroupType.GROUP_TYPE_STANDARD,
      items: [
        {
          id: 'time_status',
          type: ItemType.ITEM_TYPE_STANDARD,
          title: { content: $r('app.string.timer_open') },
          result: {
            type: ItemResultType.RESULT_TYPE_TOGGLE,
            result: { state: this.timer?.isOpen as boolean },
          },
          compControl: new TimerStatusController(this.timer as NotDisturbTimerPararm),
        }
      ]
    };
    this.settingPageModel?.groups?.push(statusGroupModel);
  }

  private setRepeatGroup(): void {
    let repeatGroupModel: SettingGroupModel = {
      id: 'repeat_group',
      type: GroupType.GROUP_TYPE_STANDARD,
      items: [
        {
          id: 'time_repeat',
          type: ItemType.ITEM_TYPE_STANDARD,
          title: { content: $r('app.string.timer_repeat') },
          result: {
            type: ItemResultType.RESULT_TYPE_TEXT,
            result: { content: this.timer?.repeatText as string },
          },
        },
        {
          id: 'week_repeat',
          type: ItemType.ITEM_TYPE_CUSTOM,
          compControl: new WeekListController(this.timer as NotDisturbTimerPararm),
          builder: wrapBuilder(weekBuilder),
        }
      ]
    };
    this.settingPageModel?.groups?.push(repeatGroupModel);
  }

  private getStartTimeItem(): SettingItemModel {
    return {
      id: 'time_start',
      type: ItemType.ITEM_TYPE_STANDARD,
      title: { content: $r('app.string.timer_start_time') },
      result: {
        type: ItemResultType.RESULT_TYPE_TEXT,
        result: { content: NotDisturbUtils.getSysFormatTime(this.timer?.startTime as string) }
      },
      compControl: new TimePickerController(this.timer as NotDisturbTimerPararm, true),
      detail: {
        type: ItemDetailType.DETAIL_TYPE_DIALOG,
        icon: $r('sys.symbol.chevron_right'),
        isSymbolIcon: true,
        dialog: {
          style: { padding: { top: PADDING_0 } },
          contentBuilder: wrapBuilder(timerPickerBuilder),
          buttonVertical: FontScaleUtils.isExtraLargeFontMode() ? false : true,
          buttons: [
            {
              value: $r('app.string.timer_cancel'),
              style: { buttonStyle: ButtonStyleMode.TEXTUAL, },
              action: (component: SettingItemModel) => {
              },
            },
            {
              value: $r('app.string.timer_confirm'),
              style: { buttonStyle: ButtonStyleMode.TEXTUAL, },
              action: (component: SettingItemModel) => {
              },
            },
          ],
        },
      }
    }
  }

  private getEndTimeItem(): SettingItemModel {
    return {
      id: 'time_end',
      type: ItemType.ITEM_TYPE_STANDARD,
      title: { content: $r('app.string.timer_end_time') },
      result: {
        type: ItemResultType.RESULT_TYPE_TEXT,
        result: {
          content: NotDisturbUtils.getEndTimeSummary(this.timer?.startTime as string, this.timer?.endTime as string)
        },
      },
      compControl: new TimePickerController(this.timer as NotDisturbTimerPararm, false),
      detail: {
        type: ItemDetailType.DETAIL_TYPE_DIALOG,
        icon: $r('sys.symbol.chevron_right'),
        isSymbolIcon: true,
        dialog: {
          style: { padding: { top: PADDING_0 } },
          contentBuilder: wrapBuilder(timerPickerBuilder),
          buttonVertical: FontScaleUtils.isExtraLargeFontMode() ? false : true,
          buttons: [
            {
              value: $r('app.string.timer_cancel'),
              style: { buttonStyle: ButtonStyleMode.TEXTUAL, },
              action: (component: SettingItemModel) => {
              },
            },
            {
              value: $r('app.string.timer_confirm'),
              style: { buttonStyle: ButtonStyleMode.TEXTUAL, },
              action: (component: SettingItemModel) => {
              },
            },
          ],
        }
      }
    }
  }

  private setTimeGroup(): void {
    let startTimeGroupModel: SettingGroupModel = {
      id: 'time_group',
      type: GroupType.GROUP_TYPE_STANDARD,
      items: [
        this.getStartTimeItem(),
        this.getEndTimeItem()
      ]
    };
    this.settingPageModel?.groups?.push(startTimeGroupModel);
  }

  private addRightMenu(): void {
    let rightMenuModel: SettingPageMenu = {
      icon: $r('app.media.ic_public_ok'),
      style: { accessibilityText: $r('app.string.done') },
      onClick: () => {
        if (!this.timer) {
          return;
        }
        //判断是否有修改，有修改则保存，无修改则直接退出
        let isTimeChange: boolean = this.oldTimer?.startTime != this.timer.startTime ||
          this.oldTimer.endTime != this.timer.endTime;
        let isChange: boolean = this.oldTimer?.isOpen != this.timer.isOpen ||
          this.oldTimer.repeat != this.timer.repeat || isTimeChange;
        if (isChange) {
          // 判断是否选择重复，选择repeatType为1，不选择则为0
          if (CheckEmptyUtils.checkStrIsEmpty(this.timer.repeat)) {
            this.timer.repeatType = NotDisturbTimerRepeatType.ONES;
          } else {
            this.timer.repeatType = NotDisturbTimerRepeatType.EVERY_WEEK;
          }
          if (this.timer.skipEndTime != 0) {
            this.timer.skipEndTime = 0;
          }
          let context = NotDisturbTimerManager.getContext();
          let zenTimers: NotDisturbTimerPararm[] = NotDisturbTimerManager.getInstance().getTimers(context);
          if (this.isAdd) {
            this.timer.id = zenTimers[zenTimers.length - 1].id + 1;
            zenTimers.push(this.timer);
          } else {
            zenTimers = this.updateTimerDb(zenTimers, this.timer);
          }

          SettingsDataUtils.setSettingsDataWithContext(context, FOCUS_MODE_TIMER, JSON.stringify(zenTimers),
            settings.domainName.USER_PROPERTY);
          let isNotMaunalTurnOn: boolean = SettingsDataUtils.getSettingsData(FOCUS_MODE_MANUAL_ENABLE,
            NOT_DISTURB_VALUE_DISABLE, settings.domainName.USER_PROPERTY) === NOT_DISTURB_VALUE_DISABLE;
          if (isNotMaunalTurnOn) {
            NotDisturbTimerManager.getInstance().refreshTimer(false, zenTimers);
          }
        }

        setTimeout(() => {
          PageRouter.pop('Setting');
        }, SETTINGSDATA_UPDATE_TIMEOUT);
      }
    };
    this.settingPageModel?.menus?.push(rightMenuModel);
  }

  private updateTimerDb(zenTimers: NotDisturbTimerPararm[], timer: NotDisturbTimerPararm):
    Array<NotDisturbTimerPararm> {
    const index: number = zenTimers.findIndex((value: NotDisturbTimerPararm) => {
      return timer.id === value.id;
    });
    zenTimers[index] = timer;
    return zenTimers;
  }

  private addDeleteButton(): void {
    let context = NotDisturbTimerManager.getContext();
    let zenTimers: NotDisturbTimerPararm[] = NotDisturbTimerManager.getInstance().getTimers(context);
    let isLastOne: boolean = zenTimers[0].id === 0 ? zenTimers.length <= 2 : zenTimers.length <= 1
    if (this.isAdd || !this.timer || isLastOne) {
      return;
    }

    if (this.settingPageModel) {
      this.settingPageModel.stickBottomContent = {
        id: 'delete_time_group',
        builder: wrapBuilder(deleteComponentBuilder),
        compControl: new NotDisturbDeleteController(this.timer),
      }
    }
  }

  destroy(): void {
    LogUtil.info(`${this.tag} destroy`);
  }
}

@Builder
function weekBuilder(args: object): void {
  WeekListComponent({ item: (args as SettingItemModel) });
}

@Builder
function timerPickerBuilder(args: SettingItemModel): void {
  TimerPickerComponent({ item: args });
}


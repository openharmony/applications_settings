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

import config from '@ohos.accessibility.config';
import emitter from '@ohos.events.emitter';
import { promptAction } from '@kit.ArkUI';
import { BusinessError } from '@kit.BasicServicesKit';
import { LengthMetrics } from '@kit.ArkUI';
import { EventBus } from '@ohos/settings.common/src/main/ets/framework/common/EventBus';
import Settings from '@ohos.settings';
import {
  CompCtrlParam,
} from '@ohos/settings.common/src/main/ets/framework/model/SettingBaseModel';
import {
  ItemDetailType,
  ItemResultType,
  ItemType,
  SettingDialogModel,
  SettingIconType,
  SettingItemModel
} from '@ohos/settings.common/src/main/ets/framework/model/SettingItemModel';
import {
  notifyCompStateChange,
  SettingResultState,
  SettingStateType,
  SettingToggleState
} from '@ohos/settings.common/src/main/ets/framework/model/SettingStateModel';
import { LogUtil } from '@ohos/settings.common/src/main/ets/utils/LogUtil';
import { SettingsDataUtils } from '@ohos/settings.common/src/main/ets/utils/SettingsDataUtils';
import { OrderedDataSource } from '@ohos/settings.common/src/main/ets/framework/model/OrderedDataSource';
import { FontScaleUtils } from '@ohos/settings.common/src/main/ets/utils/FontScaleUtils';
import { CheckEmptyUtils } from '@ohos/settings.common/src/main/ets/utils/CheckEmptyUtils';
import { HiSysEventUtil } from '@ohos/settings.common/src/main/ets/systemEvent/HiSysEventUtil';
import { HiSysDisplayBrightnessEventGroup } from '@ohos/settings.common/src/main/ets/systemEvent/BehaviorEventConsts';
import { PADDING_0 } from '@ohos/settings.common/src/main/ets/constant/StyleConstant';
import { DisplayUtils } from '@ohos/settings.common/src/main/ets/utils/DisplayUtils';
import {
  DARK_MODE_TIMED_ON,
  DEFAULT_DARK_MODE_END_TIME,
  DEFAULT_DARK_MODE_START_TIME,
  DEFAULT_DARK_MODE_STATE,
  SETTINGS_UI_APPEARANCE_DARK_MODE,
  SETTINGS_UI_APPEARANCE_DARK_MODE_ENDTIME,
  SETTINGS_UI_APPEARANCE_DARK_MODE_STARTTIME,
  SWITCH_DELAY,
} from '../../constant/DarkModeConstant';
import {
  SHOW_TOAST_TIME
} from '../../constant/DisplayConstant';
import {
  SUBMIT_ACTION,
  CANCEL_ACTION,
  END,
  START,
  TimePickerDialog,
  TIME_PICKER_DIALOG_EVENT,
  TIME_PICKER_SELECT_CHANGE
} from '../../component/TimePickerDialog';
import { MIN_60, STR_END_TIME, STR_OFF, STR_ON, STR_START_TIME } from '../../constant/DisplayConstant';
import { TimeUtil } from '../../utils/TimeUtil';
import { TimePickerModel } from '../../model/TimePickerModel';
import { BaseDarkModeController } from './BaseDarkModeController';

const TIMED_ON_ID: string = 'timeOn';
const TIMED_ON_TOGGLE_ID: string = 'Setting.DarkMode.timed_on.timeOn';

@Builder
function startDialogBuilder(param: object): void {
  TimePickerDialog({ param: param as SettingItemModel });
}

export class DarkModeTimedOnController extends BaseDarkModeController {
  protected tag: string = 'DarkModeTimedOnController: ';
  private dataSource?: OrderedDataSource;
  private darkModeType: string = DEFAULT_DARK_MODE_STATE;
  private isNeedDealToggleChange: boolean = true;
  private switchTimerId: number | null = null;
  private data: Date = new Date();
  private changeDate: Date = new Date();

  private toggleStateChangeEventCallback = (toggleState: SettingToggleState) => {
    if (!toggleState) {
      LogUtil.error(`${this.tag} toggleModel is invalid`);
      return;
    }
    if (!this.isNeedDealToggleChange) {
      LogUtil.warn(`${this.tag} no need deal`);
      return;
    }
    LogUtil.info(`${this.tag} toggleState ${toggleState.state}`);
    this.dealTimedOnSwitchCallback(toggleState.state);
    this.updateDarkTimeSearchItemStatus(toggleState.state);
  };

  private onTimePickerSelectChange = (selectDate: Date) => {
    LogUtil.info(`${this.tag} TimePicker slect time：${selectDate.getHours()}:${selectDate.getMinutes()}`);
    this.changeDate = selectDate;
  };

  private timePickerDialogEventCallback = (compId: string, action: string, selectDate: Date) => {
    LogUtil.info(`${this.tag} timePickerDialogEventCallback ${compId}, ${action}, ${selectDate}`);
    this.hideDialog(this.compId);
    if (action === CANCEL_ACTION) {
      return;
    }
    this.dealSubmitAction(compId, selectDate);
  };

  protected darkModeChangeCallback = () => {
    let darkModeType: string = this.getDarkModeType();
    LogUtil.info(`${this.tag} dark mode change callback ${darkModeType}`);
    if (darkModeType === DARK_MODE_TIMED_ON) {
      this.addTimeSelectItem();
    } else {
      this.removeTimeSelectItem();
    }
    this.isNeedDealToggleChange = false;
    this.updateToggleState(`${this.compId}.${TIMED_ON_ID}`, darkModeType === DARK_MODE_TIMED_ON, false);
    setTimeout(() => {
      this.isNeedDealToggleChange = true;
      this.updateToggleState(`${this.compId}.${TIMED_ON_ID}`, darkModeType === DARK_MODE_TIMED_ON, true);
    }, SWITCH_DELAY);
  }

  init(compParam: CompCtrlParam): void {
    if (!compParam || !compParam.compId) {
      LogUtil.error(`${this.tag} init fail, compParam is invalid`);
      return;
    }
    this.compId = compParam.compId;
    this.dataSource = (compParam.dataSource) as OrderedDataSource;
    this.initState();
    this.initMenus();
    this.registerEvent();
  }

  /* instrument ignore next*/
  private verifySelectDate(isEnd: boolean): boolean {
    if (CheckEmptyUtils.isEmpty(TimePickerDialog.startTimeKey) ||
      CheckEmptyUtils.isEmpty(TimePickerDialog.endTimeKey)) {
      LogUtil.warn(`${this.tag} no need verify select date`);
      return true;
    }
    let calcTime: string = (this.data.getHours() * MIN_60 + this.data.getMinutes()).toString();
    if (TimePickerDialog.dateTime === calcTime) {
      LogUtil.info(`${this.tag} select date no change, no need change`);
      return true;
    }
    let dataTime: string = SettingsDataUtils
      .getSettingsDataDomain(isEnd ? TimePickerDialog.startTimeKey : TimePickerDialog.endTimeKey, '', Settings.domainName.USER_PROPERTY);
    if (!isEnd) {
      let endTimeNumber: number = Number.parseInt(dataTime);
      LogUtil.info(`${this.tag} start select end time ${endTimeNumber}`);
      let endTimeInPicker: number = endTimeNumber >= TimeUtil.getNextDayTime() ?
        endTimeNumber - TimeUtil.getNextDayTime() : endTimeNumber;
      return calcTime !== endTimeInPicker.toString();
    }
    LogUtil.info(`${this.tag} verifySelectDate ${dataTime}, ${calcTime}`);
    return calcTime !== dataTime;
  }

  private initState(): void {
    this.darkModeType = SettingsDataUtils
      .getSettingsData(SETTINGS_UI_APPEARANCE_DARK_MODE, DEFAULT_DARK_MODE_STATE, Settings.domainName.USER_PROPERTY);
    LogUtil.info(`${this.tag} dark mode type ${this.darkModeType}`);
  }

  private initMenus(): void {
    this.addTimedOnItem();
    if (this.darkModeType === DARK_MODE_TIMED_ON) {
      this.addTimeSelectItem();
    }
  }

  private dealTimedOnSwitchCallback(isOpened: boolean): void {
    /* instrument ignore if*/
    if (isOpened && DisplayUtils.isHighContrastOn()) {
      this.isNeedDealToggleChange = false;
      this.updateToggleState(TIMED_ON_TOGGLE_ID, false, true);
      this.showDialog(TIMED_ON_TOGGLE_ID);
      return;
    }
    if (isOpened) {
      HiSysEventUtil.serviceStatusDefaultBehaviorEventByUE(HiSysDisplayBrightnessEventGroup.DARK_MODE_SCHEDULED_SWITCH,
        STR_START_TIME, this.getStartTime(), STR_ON);
      HiSysEventUtil.serviceStatusDefaultBehaviorEventByUE(HiSysDisplayBrightnessEventGroup.DARK_MODE_SCHEDULED_SWITCH,
        STR_END_TIME, this.getEndTime(), STR_ON);
      this.addTimeSelectItem();
    } else {
      HiSysEventUtil.serviceStatusDefaultBehaviorEventByUE(HiSysDisplayBrightnessEventGroup.DARK_MODE_SCHEDULED_SWITCH,
        '', '', STR_OFF);
      this.removeTimeSelectItem();
    }
    this.handleCheckedChange(isOpened);
  }

  private showDialog(compId: string): void {
    let state = new Map<SettingStateType, SettingDialogModel>([[SettingStateType.STATE_TYPE_ITEM_DIALOG,
      {
        title: $r('app.string.dark_mode_dialog_title'),
        message: $r('app.string.confirm_close_high_contrast_content'),
        buttonVertical: true,
        onWillDismiss: () => {
          LogUtil.info(`${this.tag} onWillDismiss`);
          this.isNeedDealToggleChange = true;
        },
        buttons: [
          {
            value: $r('app.string.dialog_cancel'),
            action: () => {
              this.hideDialog(this.compId);
              this.isNeedDealToggleChange = true;
            },
            style: {
              buttonStyle: ButtonStyleMode.TEXTUAL
            }
          },
          {
            value: $r('app.string.dialog_enable'),
            action: () => {
              this.hideDialog(this.compId);
              this.closeHighContrastTextMode();
              this.addTimeSelectItem();
              this.handleCheckedChange(true);
            },
            style: {
              buttonStyle: ButtonStyleMode.TEXTUAL
            }
          }
        ]
      } as SettingDialogModel]]);
    notifyCompStateChange(compId, state);
  }

  private closeHighContrastTextMode(): void {
    config.highContrastText.set(false).then(() => {
      LogUtil.info(`${this.tag} highContrastText set success`);
    }).catch((error: BusinessError) => {
      LogUtil.error(`${this.tag} highContrastText set err: ${error?.message}`);
    });
  }

  private addTimedOnItem(): void {
    this.dataSource?.pushData({
      id: TIMED_ON_ID,
      type: ItemType.ITEM_TYPE_STANDARD,
      title: { content: $r('app.string.eye_timed_on') },
      result: {
        type: ItemResultType.RESULT_TYPE_TOGGLE,
        result: { state: this.darkModeType === DARK_MODE_TIMED_ON },
      },
    });
  }

  private addStartItem(): void {
    if (!this.dataSource) {
      LogUtil.warn(`${this.tag} addStartItem error`);
      return;
    }
    let startIndex: number = this.dataSource.getDataIndex({
      id: START,
      type: ItemType.ITEM_TYPE_STANDARD
    });

    if (startIndex > -1) {
      return;
    }
    let startTimeExtra: TimePickerModel = {
      dateTime: this.getStartTime(),
      startTimeKey: SETTINGS_UI_APPEARANCE_DARK_MODE_STARTTIME,
      endTimeKey: SETTINGS_UI_APPEARANCE_DARK_MODE_ENDTIME
    };
    this.dataSource?.pushData({
      id: START,
      type: ItemType.ITEM_TYPE_STANDARD,
      title: { content: $r('app.string.start_time') },
      result: {
        type: ItemResultType.RESULT_TYPE_TEXT,
        result: { content: this.initStartTime() },
      },
      detail: {
        type: ItemDetailType.DETAIL_TYPE_DIALOG,
        icon: $r('sys.symbol.chevron_right'),
        isSymbolIcon: true,
        iconType: SettingIconType.ICON_TYPE_ARROW,
        dialog: {
          contentBuilder: wrapBuilder(startDialogBuilder),
          buttonVertical: FontScaleUtils.isExtraLargeFontMode() ? false : true,
          style: { padding: { top: PADDING_0 } },
          buttons: [
            {
              value: $r('app.string.dialog_cancel'),
              style: { buttonStyle: ButtonStyleMode.TEXTUAL, },
              action: (component: SettingItemModel) => {
                EventBus.getInstance().emit(TIME_PICKER_DIALOG_EVENT, START, CANCEL_ACTION);
              },
            },
            {
              value: $r('app.string.dialog_sure'),
              style: { buttonStyle: ButtonStyleMode.TEXTUAL, },
              /* instrument ignore next*/
              action: (component: SettingItemModel) => {
                this.data = this.changeDate;
                if (this.verifySelectDate(false)) {
                  EventBus.getInstance().emit(TIME_PICKER_DIALOG_EVENT, START, SUBMIT_ACTION, this.data);
                } else {
                  promptAction.showToast({ message: $r('app.string.eye_timed_warn'), duration: SHOW_TOAST_TIME });
                }
              },
            },
          ],
        }
      },
      extra: startTimeExtra
    });
  }

  private addEndItem(): void {
    if (!this.dataSource) {
      LogUtil.warn(`${this.tag} addEndItem error`);
      return;
    }
    let endIndex: number = this.dataSource.getDataIndex({
      id: END,
      type: ItemType.ITEM_TYPE_STANDARD
    });

    if (endIndex > -1) {
      return;
    }
    let endTimeExtra: TimePickerModel = {
      dateTime: this.getEndTime(),
      startTimeKey: SETTINGS_UI_APPEARANCE_DARK_MODE_STARTTIME,
      endTimeKey: SETTINGS_UI_APPEARANCE_DARK_MODE_ENDTIME
    };
    this.dataSource?.pushData({
      id: END,
      type: ItemType.ITEM_TYPE_STANDARD,
      title: { content: $r('app.string.end_time') },
      result: {
        type: ItemResultType.RESULT_TYPE_TEXT,
        result: { content: this.initEndTime() },
      },
      detail: {
        type: ItemDetailType.DETAIL_TYPE_DIALOG,
        icon: $r('sys.symbol.chevron_right'),
        isSymbolIcon: true,
        iconType: SettingIconType.ICON_TYPE_ARROW,
        dialog: {
          contentBuilder: wrapBuilder(startDialogBuilder),
          buttonVertical: FontScaleUtils.isExtraLargeFontMode() ? false : true,
          style: { padding: { top: PADDING_0 } },
          buttons: [
            {
              value: $r('app.string.dialog_cancel'),
              style: { buttonStyle: ButtonStyleMode.TEXTUAL, },
              action: (component: SettingItemModel) => {
                EventBus.getInstance().emit(TIME_PICKER_DIALOG_EVENT, END, CANCEL_ACTION);
              },
            },
            {
              value: $r('app.string.dialog_sure'),
              style: { buttonStyle: ButtonStyleMode.TEXTUAL, },
              /* instrument ignore next*/
              action: (component: SettingItemModel) => {
                this.data = this.changeDate;
                if (this.verifySelectDate(true)) {
                  EventBus.getInstance().emit(TIME_PICKER_DIALOG_EVENT, END, SUBMIT_ACTION, this.data);
                } else {
                  promptAction.showToast({ message: $r('app.string.eye_timed_warn'), duration: SHOW_TOAST_TIME });
                }
              },
            },
          ],
        }
      },
      extra: endTimeExtra
    });
  }

  private initStartTime(): string {
    let startTime: string = this.getStartTime();
    let startTimeNumber: number = Number.parseInt(startTime);
    let hour: number = Math.floor(startTimeNumber / MIN_60);
    let minute: number = startTimeNumber % MIN_60;
    return TimeUtil.getTimeFormatString(TimeUtil.getDateTimeFormat(), hour, minute);
  }

  private initEndTime(): string {
    let endTime: string = this.getEndTime();
    let endTimeNumber: number = Number.parseInt(endTime);
    return TimeUtil.formatTime(endTimeNumber.toString(), endTimeNumber >= TimeUtil.getNextDayTime());
  }

  private addTimeSelectItem(): void {
    this.addStartItem();
    this.addEndItem();
  }

  private removeTimeSelectItem(): void {
    LogUtil.info(`${this.tag} remove time select item ${this.compId}`);
    this.dataSource?.removeData({
      id: START,
      type: ItemType.ITEM_TYPE_STANDARD,
      title: { content: $r('app.string.start_time') },
    });
    this.dataSource?.removeData({
      id: END,
      type: ItemType.ITEM_TYPE_STANDARD,
      title: { content: $r('app.string.end_time') },
    });
  }

  private handleCheckedChange(isOpened: boolean): void {
    this.stopTask();
    this.updateToggleState(`${this.compId}.${TIMED_ON_ID}`, isOpened, false);
    this.switchTimerId = setTimeout(() => {
      this.updateToggleState(`${this.compId}.${TIMED_ON_ID}`, isOpened, true);
    }, SWITCH_DELAY);
    if (!isOpened) {
      this.closeTimedOnDarkMode();
      return;
    }
    this.openTimedOnDarkMode();
    let startTime: string = SettingsDataUtils
      .getSettingsData(SETTINGS_UI_APPEARANCE_DARK_MODE_STARTTIME, '', Settings.domainName.USER_PROPERTY);
    let endTime: string = SettingsDataUtils
      .getSettingsData(SETTINGS_UI_APPEARANCE_DARK_MODE_ENDTIME, '', Settings.domainName.USER_PROPERTY);
    LogUtil.info(`${this.tag}  startTime ${startTime} endTime ${endTime}`);
    if (CheckEmptyUtils.checkStrIsEmpty(startTime) && CheckEmptyUtils.checkStrIsEmpty(endTime)) {
      LogUtil.info(`${this.tag} init default time`);
      this.setStartTime(DEFAULT_DARK_MODE_START_TIME);
      this.setEndTime(DEFAULT_DARK_MODE_END_TIME);
      return;
    }
  }

  private closeTimedOnDarkMode(): void {
    SettingsDataUtils
      .setSettingsData(SETTINGS_UI_APPEARANCE_DARK_MODE, DEFAULT_DARK_MODE_STATE,
        Settings.domainName.USER_PROPERTY);
  }

  private openTimedOnDarkMode(): void {
    SettingsDataUtils
      .setSettingsData(SETTINGS_UI_APPEARANCE_DARK_MODE, DARK_MODE_TIMED_ON,
         Settings.domainName.USER_PROPERTY);
  }

  private dealSubmitAction(compId: string, selectDate: Date): void {
    if (!selectDate) {
      LogUtil.error(`${this.tag} dealSubmitAction error selectDate is invalid`);
      return;
    }
    let hour: number = selectDate.getHours();
    let min: number = selectDate.getMinutes();
    let currentSelectTime: number = hour * MIN_60 + min;
    if (compId === START) {
      let endTime: string = this.getEndTime();
      let endTimeNumber: number = Number.parseInt(endTime);
      this.setStartTime(currentSelectTime.toString());
      this.refreshContentText(`${this.compId}.${START}`, TimeUtil.formatTime(currentSelectTime.toString(), false));
      this.updateExtraInfo(START, currentSelectTime.toString());
      LogUtil.info(`${this.tag} dealSubmitAction start ${currentSelectTime}, ${endTimeNumber}`);
      if (currentSelectTime >= endTimeNumber) {
        endTimeNumber += TimeUtil.getNextDayTime();
        this.refreshEndTime(endTimeNumber, true);
      }
      /* instrument ignore if*/
      if (endTimeNumber - currentSelectTime > TimeUtil.getNextDayTime()) {
        endTimeNumber -= TimeUtil.getNextDayTime();
        LogUtil.info(`${this.tag} end time too large ${endTimeNumber}`);
        this.refreshEndTime(endTimeNumber, false);
      }
      return;
    }

    let startTime: string = this.getStartTime();
    let startTimeNumber: number = Number.parseInt(startTime);
    if (currentSelectTime <= startTimeNumber) {
      currentSelectTime += TimeUtil.getNextDayTime();
      this.refreshContentText(`${this.compId}.${END}`, TimeUtil.formatTime(currentSelectTime.toString(), true));
    } else {
      this.refreshContentText(`${this.compId}.${END}`, TimeUtil.formatTime(currentSelectTime.toString(), false));
    }
    this.setEndTime(currentSelectTime.toString());
    this.updateExtraInfo(END, currentSelectTime.toString());
    LogUtil.info(`${this.tag} set end time ${currentSelectTime}`);
  }

  private refreshEndTime(endTimeNumber: number, isShowNextDay: boolean): void {
    this.setEndTime(endTimeNumber.toString());
    this.updateExtraInfo(END, endTimeNumber.toString());
    this.refreshContentText(`${this.compId}.${END}`, TimeUtil.formatTime(endTimeNumber.toString(), isShowNextDay));
  }

  private updateExtraInfo(compId: string, dateTime: string): void {
    let index: number | undefined = this.dataSource?.getDataIndex({
      id: compId,
      type: ItemType.ITEM_TYPE_STANDARD,
    });
    LogUtil.info(`${this.tag} updateExtraInfo ${index}, ${compId}`);
    if (index !== undefined && index > -1) {
      (this.dataSource?.getData(index).extra as TimePickerModel).dateTime = dateTime;
    }
  }

  /* instrument ignore next*/
  private selectDateCallback = (eventData: emitter.EventData) => {
    if (!(eventData && eventData.data)) {
      return;
    }
    LogUtil.info(`${this.tag} selectDate ${eventData.data?.selectDate}`);
    this.data = eventData.data?.selectDate;
  }

  private registerEvent(): void {
    EventBus.getInstance().on(`${this.compId}.${TIMED_ON_ID}.toggle`, this.toggleStateChangeEventCallback);
    EventBus.getInstance().on(TIME_PICKER_DIALOG_EVENT, this.timePickerDialogEventCallback);
    EventBus.getInstance().on(TIME_PICKER_SELECT_CHANGE, this.onTimePickerSelectChange);
    this.registerDataHelper();
  }

  private unRegisterEvent(): void {
    EventBus.getInstance().detach(`${this.compId}.${TIMED_ON_ID}.toggle`, this.toggleStateChangeEventCallback);
    EventBus.getInstance().detach(TIME_PICKER_DIALOG_EVENT, this.timePickerDialogEventCallback);
    EventBus.getInstance().detach('TIME_PICKER_SELECT_CHANGE', this.onTimePickerSelectChange);
    this.unRegisterDataHelper();
  }

  private refreshContentText(compId: string, content: string): void {
    LogUtil.info(`${this.tag} refreshContentText: ${compId}`);
    notifyCompStateChange(compId, new Map<SettingStateType, SettingResultState>(
      [[SettingStateType.STATE_TYPE_ITEM_RESULT, { type: ItemResultType.RESULT_TYPE_TEXT,
        result: { content:content } } as SettingResultState]]));
  }

  private hideDialog(compId: string): void {
    let state = new Map<SettingStateType, SettingDialogModel>([[SettingStateType.STATE_TYPE_ITEM_DIALOG,
      {
        buttons: [
          {
            value: $r('app.string.dialog_sure'),
            action: (component: SettingItemModel) => {
            }
          }
        ]
      } as SettingDialogModel]]);
    notifyCompStateChange(`${compId}.${START}}`, state);
    notifyCompStateChange(`${compId}.${END}`, state);
  }

  private updateToggleState(compId: string, isOpened: boolean, isEnabled: boolean): void {
    notifyCompStateChange(compId,
      new Map<SettingStateType, SettingResultState>(
        [[SettingStateType.STATE_TYPE_ITEM_RESULT, {
          type: ItemResultType.RESULT_TYPE_TOGGLE,
          result: { state: isOpened, enabled: isEnabled } 
        } as SettingResultState]]));
  }

  destroy(): void {
    LogUtil.showInfo(this.tag, 'onDestroy eventbus');
    this.stopTask();
    this.unRegisterEvent();
  }

  private stopTask(): void {
    if (this.switchTimerId !== null) {
      LogUtil.showInfo(this.tag, 'stop existing switchTimerId task');
      clearTimeout(this.switchTimerId);
      this.switchTimerId = null;
    }
  }
}
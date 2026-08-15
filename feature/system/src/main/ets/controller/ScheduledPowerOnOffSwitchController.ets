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
import observer from '@ohos.telephony.observer';
import { LengthMetrics } from '@kit.ArkUI';
import emitter from '@ohos.events.emitter';
import { CompCtrlParam } from '@ohos/settings.common/src/main/ets/framework/model/SettingBaseModel';
import { LogUtil } from '@ohos/settings.common/src/main/ets/utils/LogUtil';
import { SettingsDataUtils } from '@ohos/settings.common/src/main/ets/utils/SettingsDataUtils';
import { SearchDataController } from '@ohos/settings.search/src/main/ets/controller/SearchController';
import { OrderedDataSource } from '@ohos/settings.common/src/main/ets/framework/model/OrderedDataSource';
import {
  ItemDetailType,
  ItemResultType,
  ItemType,
  SettingDialogModel,
  SettingIconType,
  SettingItemModel
} from '@ohos/settings.common/src/main/ets/framework/model/SettingItemModel';
import { FontScaleUtils } from '@ohos/settings.common/src/main/ets/utils/FontScaleUtils';
import { TimeUtil } from '@ohos/settings.display/src/main/ets/utils/TimeUtil';
import { EventBus } from '@ohos/settings.common/src/main/ets/framework/common/EventBus';
import {
  notifyCompStateChange,
  SettingResultState,
  SettingStateType,
  SettingToggleState
} from '@ohos/settings.common/src/main/ets/framework/model/SettingStateModel';
import { CheckEmptyUtils } from '@ohos/settings.common/src/main/ets/utils/CheckEmptyUtils';
import { ResourceUtil } from '@ohos/settings.common/src/main/ets/utils/ResourceUtil';
import { PreferencesUtil } from '@ohos/settings.common/src/main/ets/utils/PreferencesUtil';
import { TIME_24_HOUR_SWITCH_OPEN_EVENTS } from '@ohos/settings.common/src/main/ets/event/types';
import {
  DEFAULT_SCHEDULED_POWER_OFF_TIME,
  DEFAULT_SCHEDULED_POWER_ON_OFF_REPEAT,
  DEFAULT_SCHEDULED_POWER_ON_OFF_WEEK_REPEAT,
  DEFAULT_SCHEDULED_POWER_ON_TIME,
  MIN_60,
  SCHEDULED_POWER_OFF_TIME,
  SCHEDULED_POWER_ON_OFF_CLOSE,
  SCHEDULED_POWER_ON_OFF_OPEN,
  SCHEDULED_POWER_ON_OFF_REPEAT,
  SCHEDULED_POWER_ON_OFF_REPEAT_WEEK,
  SCHEDULED_POWER_ON_TIME,
  SCHEDULED_POWER_TIME_NOT_SET
} from '../constants/ScheduledPowerOnOffConstant';
import { ScheduledPowerOnOffController } from './ScheduledPowerOnOffController';
import {
  CANCEL_ACTION,
  POWER_OFF,
  POWER_ON,
  TIME_PICKER_DIALOG_EVENT,
  TimePickerDialog
} from '../components/TimePickerDialog';
import { ScheduledPowerOnOffTimerManager } from '../ScheduledPowerOnOffTimerManager';
import { TimePickerModel } from '../model/TimePickerModel';
import { ScheduledPowerOnOffDataUtil } from '../utils/ScheduledPowerOnOffDataUtil';
/* instrument ignore file */
const TAG: string = 'ScheduledPowerOnOffSwitchController: ';
const POWER_SWITCH_ID: string = 'power_switch';

@Builder
function powerOnDialogBuilder(param: object): void {
  TimePickerDialog({ param: param as SettingItemModel });
}

/**
 * 定时开关机开启/关闭Controller
 *
 * @since 2024-12-12
 */
export class ScheduledPowerOnOffSwitchController extends ScheduledPowerOnOffController {
  private dataSource?: OrderedDataSource;
  private switchMode: string = '';
  private isNeedDealToggleChange: boolean = true;
  private callStateChangeCallback = (data: observer.CallStateInfo) => {
    if (data) {
      LogUtil.info('callStateChangeData:' + data.state);
      PreferencesUtil.putSync('CallState', data.state);
    }
  };
  private timePickerDialogEventCallback = (compId: string, action: string, selectDate: Date) => {
    LogUtil.showInfo(TAG, `timePickerDialogEventCallback ${compId}, ${action}, ${selectDate}`);
    this.hideDialog(this.compId);
    if (action === CANCEL_ACTION) {
      return;
    }
    this.dealSubmitAction(compId, selectDate);
  };
  private toggleStateChangeEventCallback = (toggleState: SettingToggleState) => {
    if (!toggleState) {
      LogUtil.showError(TAG, `toggleModel is invalid`);
      return;
    }
    if (!this.isNeedDealToggleChange) {
      LogUtil.showWarn(TAG, `no need deal`);
      return;
    }
    LogUtil.showInfo(TAG, `toggleState ${toggleState.state}`);
    this.dealTimedOnSwitchCallback(toggleState.state);
  };
  protected ScheduledPowerOnOffChangeCallback = () => {
    let switchMode: string = ScheduledPowerOnOffDataUtil.getSwitchModeType(TAG);
    LogUtil.showInfo(TAG, `ScheduledPowerOnOff mode change callback ${switchMode}`);
    if (this.isSwitchOpen(switchMode)) {
      this.addTimeSelectItem();
    } else {
      this.removeTimeSelectItem();
    }
    this.isNeedDealToggleChange = true;
    this.updateToggleState(`${this.compId}.${POWER_SWITCH_ID}`, this.isSwitchOpen(switchMode), true);
  }

  init(compParam: CompCtrlParam): void {
    if (!compParam || !compParam.compId) {
      LogUtil.showError(TAG, `init fail, compParam is invalid`);
      return;
    }
    this.compId = compParam.compId;
    this.dataSource = (compParam.dataSource) as OrderedDataSource;

    this.switchMode = ScheduledPowerOnOffDataUtil.getSwitchModeType(TAG);
    LogUtil.showInfo(TAG, `init isScheduledPowerOnOffOpen ${this.switchMode}`);
    this.initMenus();
    this.registerEvent();
  }

  private initMenus(): void {
    this.addSwitchItem();
    if (this.isSwitchOpen(this.switchMode)) {
      observer.on('callStateChange', this.callStateChangeCallback);
      this.addTimeSelectItem();
    }
  }

  private addSwitchItem(): void {
    this.dataSource?.pushData({
      id: POWER_SWITCH_ID,
      type: ItemType.ITEM_TYPE_STANDARD,
      title: { content: $r('app.string.scheduled_power_on_off_title') },
      result: {
        type: ItemResultType.RESULT_TYPE_TOGGLE,
        result: { state: this.isSwitchOpen(this.switchMode) },
      },
    });
  }

  private removeTimeSelectItem(): void {
    LogUtil.showInfo(TAG, `remove time select item ${this.compId}`);
    observer.off('callStateChange');
    PreferencesUtil.putSync('CallState', 0);
    this.dataSource?.removeData({
      id: POWER_ON,
      type: ItemType.ITEM_TYPE_STANDARD,
      title: { content: $r('app.string.power_on_time_title') },
    });
    this.dataSource?.removeData({
      id: POWER_OFF,
      type: ItemType.ITEM_TYPE_STANDARD,
      title: { content: $r('app.string.power_off_time_title') },
    });
    SettingsDataUtils.unregisterKeyObserverWithDomain(SCHEDULED_POWER_ON_TIME, settings.domainName.DEVICE_SHARED);
    SettingsDataUtils.unregisterKeyObserverWithDomain(SCHEDULED_POWER_OFF_TIME, settings.domainName.DEVICE_SHARED);
  }

  private addTimeSelectItem(): void {
    observer.on('callStateChange', this.callStateChangeCallback);
    // 开机定时器暂不支持
    // this.addPowerOnItem();
    this.addPowerOffItem();
    SettingsDataUtils.registerKeyObserverWithDomain(SCHEDULED_POWER_ON_TIME, settings.domainName.DEVICE_SHARED, () => {
      if (ScheduledPowerOnOffDataUtil.getPowerOnTime(TAG) == SCHEDULED_POWER_TIME_NOT_SET) {
        this.refreshContentText(`${this.compId}.${POWER_ON}`,
          ResourceUtil.getStringSync($r('app.string.time_not_set')));
      }
    });
    SettingsDataUtils.registerKeyObserverWithDomain(SCHEDULED_POWER_OFF_TIME, settings.domainName.DEVICE_SHARED, () => {
      if (ScheduledPowerOnOffDataUtil.getPowerOffTime(TAG) == SCHEDULED_POWER_TIME_NOT_SET) {
        this.refreshContentText(`${this.compId}.${POWER_OFF}`,
          ResourceUtil.getStringSync($r('app.string.time_not_set')));
      }
    });
  }

  private addPowerOnItem(): void {
    if (!this.dataSource) {
      LogUtil.showWarn(TAG, `addPowerOnItem error`);
      return;
    }
    let powerOnIndex: number = this.dataSource.getDataIndex({
      id: POWER_ON,
      type: ItemType.ITEM_TYPE_STANDARD
    });

    if (powerOnIndex > -1) {
      return;
    }
    let powerOnTimeExtra: TimePickerModel = {
      dateTime: ScheduledPowerOnOffDataUtil.getPowerOnTime(TAG),
      powerOnTimeKey: SCHEDULED_POWER_ON_TIME,
      powerOffTimeKey: SCHEDULED_POWER_OFF_TIME
    };
    this.dataSource?.pushData({
      id: POWER_ON,
      type: ItemType.ITEM_TYPE_STANDARD,
      title: { content: $r('app.string.power_on_time_title') },
      result: {
        type: ItemResultType.RESULT_TYPE_TEXT,
        result: { content: this.initPowerOnTime() },
      },
      detail: {
        type: ItemDetailType.DETAIL_TYPE_DIALOG,
        icon: $r('sys.symbol.chevron_right'),
        isSymbolIcon: true,
        iconType: SettingIconType.ICON_TYPE_ARROW,
        dialog: {
          contentBuilder: wrapBuilder(powerOnDialogBuilder),
          buttonVertical: FontScaleUtils.isExtraLargeFontMode() ? false : true,
          style: {
            padding: {
              top: LengthMetrics.vp(0),
              bottom: LengthMetrics.vp(0),
              start: LengthMetrics.vp(0),
              end: LengthMetrics.vp(0),
            },
            contentButtonSpace: LengthMetrics.vp(0), alignment: DialogAlignment.Center
          },
          buttons: [],
        }
      },
      extra: powerOnTimeExtra
    });
  }

  private addPowerOffItem(): void {
    if (!this.dataSource) {
      LogUtil.showWarn(TAG, `addPowerOffItem error`);
      return;
    }
    let powerOffIndex: number = this.dataSource.getDataIndex({
      id: POWER_OFF,
      type: ItemType.ITEM_TYPE_STANDARD
    });

    if (powerOffIndex > -1) {
      return;
    }
    let powerOffTimeExtra: TimePickerModel = {
      dateTime: ScheduledPowerOnOffDataUtil.getPowerOffTime(TAG),
      powerOnTimeKey: SCHEDULED_POWER_ON_TIME,
      powerOffTimeKey: SCHEDULED_POWER_OFF_TIME
    };
    this.dataSource?.pushData({
      id: POWER_OFF,
      type: ItemType.ITEM_TYPE_STANDARD,
      title: { content: $r('app.string.power_off_time_title') },
      result: {
        type: ItemResultType.RESULT_TYPE_TEXT,
        result: { content: this.initPowerOffTime() },
      },
      detail: {
        type: ItemDetailType.DETAIL_TYPE_DIALOG,
        icon: $r('sys.symbol.chevron_right'),
        isSymbolIcon: true,
        iconType: SettingIconType.ICON_TYPE_ARROW,
        dialog: {
          contentBuilder: wrapBuilder(powerOnDialogBuilder),
          buttonVertical: FontScaleUtils.isExtraLargeFontMode() ? false : true,
          style: {
            padding: {
              top: LengthMetrics.vp(0),
              bottom: LengthMetrics.vp(0),
              start: LengthMetrics.vp(0),
              end: LengthMetrics.vp(0),
            },
            contentButtonSpace: LengthMetrics.vp(0), alignment: DialogAlignment.Center
          },
          buttons: [],
        }
      },
      extra: powerOffTimeExtra
    });
  }

  private initPowerOnTime(): string {
    let powerOnTime: string = ScheduledPowerOnOffDataUtil.getPowerOnTime(TAG);
    if (powerOnTime == SCHEDULED_POWER_TIME_NOT_SET) {
      return ResourceUtil.getStringSync($r('app.string.time_not_set'))
    }
    let powerOnTimeNumber: number = Number.parseInt(powerOnTime);
    let hour: number = Math.floor(powerOnTimeNumber / MIN_60);
    let minute: number = powerOnTimeNumber % MIN_60;
    return TimeUtil.getTimeFormatString(TimeUtil.getDateTimeFormat(), hour, minute);
  }

  private initPowerOffTime(): string {
    let powerOffTime: string = ScheduledPowerOnOffDataUtil.getPowerOffTime(TAG);
    if (powerOffTime == SCHEDULED_POWER_TIME_NOT_SET) {
      return ResourceUtil.getStringSync($r('app.string.time_not_set'))
    }
    let powerOffTimeNumber: number = Number.parseInt(powerOffTime);
    return TimeUtil.formatTime(powerOffTimeNumber.toString(), false);
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
    notifyCompStateChange(`${compId}.${POWER_ON}`, state);
    notifyCompStateChange(`${compId}.${POWER_OFF}`, state);
  }

  private dealSubmitAction(compId: string, selectDate: Date): void {
    if (!selectDate) {
      LogUtil.showError(TAG, `dealSubmitAction error selectDate is invalid`);
      return;
    }
    let hour: number = selectDate.getHours();
    let min: number = selectDate.getMinutes();
    let currentSelectTime: number = hour * MIN_60 + min;
    if (compId === POWER_ON) {
      let powerOffTime: string = ScheduledPowerOnOffDataUtil.getPowerOffTime(TAG);
      let powerOffTimeNumber: number = Number.parseInt(powerOffTime);
      this.refreshContentText(`${this.compId}.${POWER_ON}`, TimeUtil.formatTime(currentSelectTime.toString(), false));
      this.setPowerOnTime(currentSelectTime.toString());
      this.updateExtraInfo(POWER_ON, currentSelectTime.toString());
      LogUtil.showInfo(TAG, `dealSubmitAction powerOn ${currentSelectTime}, ${powerOffTimeNumber}`);
      return;
    }
    this.refreshContentText(`${this.compId}.${POWER_OFF}`, TimeUtil.formatTime(currentSelectTime.toString(), false));
    this.setPowerOffTime(currentSelectTime.toString());
    this.updateExtraInfo(POWER_OFF, currentSelectTime.toString());
    LogUtil.showInfo(TAG, `set powerOff time ${currentSelectTime}`);
  }

  private refreshContentText(compId: string, content: string): void {
    LogUtil.showInfo(TAG, `refreshContentText: ${compId}`);
    notifyCompStateChange(compId, new Map<SettingStateType, SettingResultState>(
      [[SettingStateType.STATE_TYPE_ITEM_RESULT, {
        type: ItemResultType.RESULT_TYPE_TEXT,
        result: { content: content }
      } as SettingResultState]]));
  }

  private updateExtraInfo(compId: string, dateTime: string): void {
    let index: number | undefined = this.dataSource?.getDataIndex({
      id: compId,
      type: ItemType.ITEM_TYPE_STANDARD,
    });
    LogUtil.showInfo(TAG, `updateExtraInfo ${index}, ${compId}`);
    if (index !== undefined && index > -1) {
      (this.dataSource?.getData(index).extra as TimePickerModel).dateTime = dateTime;
    }
    this.updateTimer();
  }

  private refreshUi(): void {
    let on: string = SettingsDataUtils
      .getSettingsData(SCHEDULED_POWER_ON_TIME, '', settings.domainName.DEVICE_SHARED);
    let off: string = SettingsDataUtils
      .getSettingsData(SCHEDULED_POWER_OFF_TIME, '', settings.domainName.DEVICE_SHARED);
    // 定时开关机的开关是开启的并且开机关机时间不为空，刷新字符串
    LogUtil.info(`${TAG} receive TIME_24_HOUR_SWITCH_OPEN_EVENTS refresh ui`);
    if (!CheckEmptyUtils.checkStrIsEmpty(on)) {
      this.refreshContentText(`${this.compId}.${POWER_ON}`, TimeUtil.formatTime(on, false));
    }
    if (!CheckEmptyUtils.checkStrIsEmpty(off)) {
      this.refreshContentText(`${this.compId}.${POWER_OFF}`, TimeUtil.formatTime(off.toString(), false));
    }
  }

  private registerEvent(): void {
    EventBus.getInstance().on(`${this.compId}.${POWER_SWITCH_ID}.toggle`, this.toggleStateChangeEventCallback);
    EventBus.getInstance().on(TIME_PICKER_DIALOG_EVENT, this.timePickerDialogEventCallback);
    this.registerDataHelper();
    // 监听24小时制开关事件，并刷新ui
    emitter.on({ eventId: TIME_24_HOUR_SWITCH_OPEN_EVENTS }, () => this.refreshUi());
  }

  private unRegisterEvent(): void {
    EventBus.getInstance().detach(`${this.compId}.${POWER_SWITCH_ID}.toggle`, this.toggleStateChangeEventCallback);
    EventBus.getInstance().detach(TIME_PICKER_DIALOG_EVENT, this.timePickerDialogEventCallback);
    this.unRegisterDataHelper();
    emitter.off(TIME_24_HOUR_SWITCH_OPEN_EVENTS);
  }

  private updateToggleState(compId: string, isOpened: boolean, isEnabled: boolean): void {
    notifyCompStateChange(compId,
      new Map<SettingStateType, SettingResultState>(
        [[SettingStateType.STATE_TYPE_ITEM_RESULT, {
          type: ItemResultType.RESULT_TYPE_TOGGLE,
          result: { state: isOpened, enabled: isEnabled }
        } as SettingResultState]]));
  }

  private dealTimedOnSwitchCallback(isOpened: boolean): void {
    SearchDataController.getInstance().updateChildItemSearchStatus('scheduled_power_settings_item', isOpened);
    if (isOpened) {
      this.addTimeSelectItem();
    } else {
      this.removeTimeSelectItem();
    }
    this.handleCheckedChange(isOpened);
  }

  private handleCheckedChange(isOpened: boolean): void {
    this.updateToggleState(`${this.compId}.${POWER_SWITCH_ID}`, isOpened, true);
    if (!isOpened) {
      this.setSwitchModeType(SCHEDULED_POWER_ON_OFF_CLOSE);
      ScheduledPowerOnOffTimerManager.getInstance().destroyAlarm();
      return;
    }

    this.setSwitchModeType(SCHEDULED_POWER_ON_OFF_OPEN);
    this.initDateHelper();
    this.updateTimer(true);
  }

  private initDateHelper() {
    if (CheckEmptyUtils.checkStrIsEmpty(SettingsDataUtils
      .getSettingsData(SCHEDULED_POWER_ON_TIME, '', settings.domainName.DEVICE_SHARED))) {
      LogUtil.showInfo(TAG, `init default powerOnTime`);
      this.setPowerOnTime(DEFAULT_SCHEDULED_POWER_ON_TIME);
    }
    if (CheckEmptyUtils.checkStrIsEmpty(SettingsDataUtils
      .getSettingsData(SCHEDULED_POWER_OFF_TIME, '', settings.domainName.DEVICE_SHARED))) {
      LogUtil.showInfo(TAG, `init default powerOffTime`);
      this.setPowerOffTime(DEFAULT_SCHEDULED_POWER_OFF_TIME);
    }
    if (CheckEmptyUtils.checkStrIsEmpty(SettingsDataUtils
      .getSettingsData(SCHEDULED_POWER_ON_OFF_REPEAT, '', settings.domainName.DEVICE_SHARED))) {
      LogUtil.showInfo(TAG, `init default repeat`);
      this.setRepeatMenuChose(DEFAULT_SCHEDULED_POWER_ON_OFF_REPEAT);
    }
    if (CheckEmptyUtils.checkStrIsEmpty(SettingsDataUtils
      .getSettingsData(SCHEDULED_POWER_ON_OFF_REPEAT_WEEK, '', settings.domainName.DEVICE_SHARED))) {
      LogUtil.showInfo(TAG, `init default repeatWeek`);
      SettingsDataUtils.setSettingsData(SCHEDULED_POWER_ON_OFF_REPEAT_WEEK, DEFAULT_SCHEDULED_POWER_ON_OFF_WEEK_REPEAT,
        settings.domainName.DEVICE_SHARED);
    }
  }

  destroy(): void {
    LogUtil.showInfo(TAG, 'onDestroy eventbus');
    this.unRegisterEvent()
  }
}
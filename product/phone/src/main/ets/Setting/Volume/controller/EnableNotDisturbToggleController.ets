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
import dataShare from '@ohos.data.dataShare';
import settings from '@ohos.settings';
import { EventBus } from '@ohos/settings.common/src/main/ets/framework/common/EventBus';
import {
  CompCtrlParam,
  ComponentControl,
} from '@ohos/settings.common/src/main/ets/framework/model/SettingBaseModel';
import {
  ItemResultType,
  SettingToggleModel
} from '@ohos/settings.common/src/main/ets/framework/model/SettingItemModel';
import {
  notifyCompStateChange,
  SettingBaseState,
  SettingCompState,
  SettingResultState,
  SettingStateType
} from '@ohos/settings.common/src/main/ets/framework/model/SettingStateModel';
import { LogUtil } from '@ohos/settings.common/src/main/ets/utils/LogUtil';
import { SettingsDataUtils } from '@ohos/settings.common/src/main/ets/utils/SettingsDataUtils';
import {
  NotDisturbUtils,
  FOCUS_MODE_MANUAL_ENABLE,
  FOCUS_MODE_ENABLED,
  NOT_DISTURB_VALUE_DISABLE,
  NOT_DISTURB_VALUE_ENABLE,
  NOT_DISTURB_VALUE_ERROR
} from '@ohos/settings.notDisturb/src/main/ets/utils/NotDisturbUtils';
import {
  NotDisturbReportSources,
  NotDisturbTimerPararm
} from '@ohos/settings.notDisturb/src/main/ets/model/NotDisturbTimerPararm';
import {
  DISTURB_MODE_TRIGGER_END_TIME,
  DISTURB_MODE_TRIGGER_START_TIME,
  NotDisturbTimerManager
} from '@ohos/settings.notDisturb/src/main/ets/NotDisturbTimerManager';
import { ToggleMenuController } from './VolumeController';
import { NotDisturbAddTimeController } from './NotDisturbAddTimeGroupController';

const TAG: string = 'EnableNotDisturbToggleController';
const MAX_TIMER_ID: number = 10;

/**
 * 立即开启免打扰开关的控制
 */
export class EnableNotDisturbToggleController extends ToggleMenuController implements ComponentControl {
  private autoChangeMode: boolean = false;
  private dataHelper: dataShare.DataShareHelper | null = null;
  private compId: string = '';
  private onToggleChangeCallback = (param: object) => {
    let toggleState: SettingToggleModel = param as SettingToggleModel;
    let isChecked: boolean = !!(toggleState?.state);
    LogUtil.info(`${TAG} EnableNotDisturbToggleController autoChangeMode: ${this.autoChangeMode}`);
    if (this.autoChangeMode) {
      this.autoChangeMode = false;
      LogUtil.info(`${TAG} EnableNotDisturbToggleController set autoChangeMode: ${this.autoChangeMode}`);
    } else {
      SettingsDataUtils.setSettingsData(FOCUS_MODE_MANUAL_ENABLE, isChecked ? NOT_DISTURB_VALUE_ENABLE :
        NOT_DISTURB_VALUE_DISABLE, settings.domainName.USER_PROPERTY);
      SettingsDataUtils.setSettingsData(FOCUS_MODE_ENABLED, isChecked ? NOT_DISTURB_VALUE_ENABLE :
        NOT_DISTURB_VALUE_DISABLE, settings.domainName.USER_SECURITY);
      const status = isChecked ? 'on' : 'off';
      this.setModeStatus(isChecked)
      NotDisturbUtils.reportNotDisturb(status, NotDisturbReportSources.SETTINGS);
    }
    this.setChecked(isChecked);
    this.setScheduledEnabled();
  }

  init(compParam: CompCtrlParam): void {
    this.compId = compParam?.compId;
    let isChecked: boolean = SettingsDataUtils.getSettingsData(FOCUS_MODE_ENABLED, NOT_DISTURB_VALUE_DISABLE,
      settings.domainName.USER_SECURITY) === NOT_DISTURB_VALUE_ENABLE;
    LogUtil.info(`${TAG} EnableNotDisturbToggleController get isChecked : ${isChecked}`);
    this.setChecked(isChecked);
    this.registerDataChange();
    EventBus.getInstance().on(`${this.compId}.toggle`, this.onToggleChangeCallback);
  }

  registerDataChange(): void {
    if (this.dataHelper) {
      SettingsDataUtils.registerSecurityDataChange(this.dataHelper, FOCUS_MODE_ENABLED, this.onDataChange);
    } else {
      (SettingsDataUtils.createDataHelper(FOCUS_MODE_ENABLED) as Promise<dataShare.DataShareHelper>)
        .then((dataShareHelper?: dataShare.DataShareHelper) => {
          if (dataShareHelper) {
            this.dataHelper = dataShareHelper;
            SettingsDataUtils.registerSecurityDataChange(this.dataHelper, FOCUS_MODE_ENABLED, this.onDataChange);
          }
        })
    }
    LogUtil.info(`${TAG} registerDataChange`);
  }

  private onDataChange = () => {
    let isChecked: boolean = NotDisturbTimerManager.getInstance().isNotDisturbOpen(getContext());
    LogUtil.info(`${TAG} onDataChange this.isChecked: ${this.isChecked} - isopen: ${isChecked}`);
    if (this.isChecked == isChecked) {
      return;
    }
    this.isChecked = isChecked;
    this.autoChangeMode = true;
    LogUtil.info(`${TAG} onDataChange refreshUi: ${this.autoChangeMode}`);
    this.refreshToggleUi(isChecked);
  }

  unRegisterDataChange(): void {
    SettingsDataUtils.unRegisterSecurityDataChange(this.dataHelper as dataShare.DataShareHelper, FOCUS_MODE_ENABLED,
      this.onDataChange);
    LogUtil.info(`${TAG} unRegisterDataChange`);
  }

  setModeStatus(isChecked: boolean): void {
    if (isChecked) {
      NotDisturbTimerManager.getInstance().stopAlarm();
      SettingsDataUtils.setSettingsData(DISTURB_MODE_TRIGGER_START_TIME, NOT_DISTURB_VALUE_ERROR,
        settings.domainName.USER_PROPERTY);
      SettingsDataUtils.setSettingsData(DISTURB_MODE_TRIGGER_END_TIME, NOT_DISTURB_VALUE_ERROR,
        settings.domainName.USER_PROPERTY);
      NotDisturbTimerManager.getInstance().initOtherConfig(getContext());
    } else {
      NotDisturbTimerManager.getInstance().closeNowChange(new Date().getTime());
    }
  }

  setScheduledEnabled(): void {
    let isMaunalTurnOn: boolean = SettingsDataUtils.getSettingsData(FOCUS_MODE_MANUAL_ENABLE, NOT_DISTURB_VALUE_DISABLE,
      settings.domainName.USER_PROPERTY) === NOT_DISTURB_VALUE_ENABLE;
    LogUtil.info(`${TAG} EnableNotDisturbToggleController isMaunalTurnOn: ${isMaunalTurnOn}`);
    NotDisturbAddTimeController.getCurrentZenItems().forEach((model) => {
      notifyCompStateChange(`Setting.not_disturb_mode.timing_turnon.${model.id}`,
        new Map<SettingStateType, SettingBaseState>([[SettingStateType.STATE_TYPE_ITEM_ENABLED,
          { state: isMaunalTurnOn ? false : true } as SettingCompState]]));
    });
    let zenTimers: NotDisturbTimerPararm[] = NotDisturbTimerManager.getInstance().getTimers(getContext());
    let isDisable: boolean = zenTimers[0].id === 0 ?
      zenTimers.length - 1 === MAX_TIMER_ID : zenTimers.length === MAX_TIMER_ID;
    notifyCompStateChange('Setting.not_disturb_mode.add_scheduled.add_scheduled_menu',
      new Map<SettingStateType, SettingBaseState>([[SettingStateType.STATE_TYPE_ITEM_ENABLED,
        { state: isDisable || isMaunalTurnOn ? false : true } as SettingCompState]]));
  }

  protected refreshToggleUi(checked: boolean): void {
    notifyCompStateChange(this.compId,
      new Map<SettingStateType, SettingResultState>([[SettingStateType.STATE_TYPE_ITEM_RESULT,
        { type: ItemResultType.RESULT_TYPE_TOGGLE, result: { state: checked } } as SettingResultState]]));
  }

  destroy(): void {
    LogUtil.info(`${TAG} destroy`);
    EventBus.getInstance().detach(`${this.compId}.toggle`, this.onToggleChangeCallback);
    this.unRegisterDataChange();
  }

  protected refreshUi(): void {
    notifyCompStateChange(this.compId,
      new Map<SettingStateType, SettingResultState>([[SettingStateType.STATE_TYPE_ITEM_RESULT,
        { type: ItemResultType.RESULT_TYPE_TOGGLE, result: { state: this.isChecked } } as SettingResultState]]));
  }
}
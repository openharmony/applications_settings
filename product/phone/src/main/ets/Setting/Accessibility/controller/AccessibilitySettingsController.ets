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
import taskpool from '@ohos.taskpool';
import collections from '@arkts.collections';
import { RestoreAccessibilityConfig } from '@ohos/settings.reset/src/main/ets/controller/RestoreAccessibilityConfig';
import {
  CompCtrlParam,
  ComponentControl,
  SettingBaseModel
} from '@ohos/settings.common/src/main/ets/framework/model/SettingBaseModel';
import { SettingItemModel } from '@ohos/settings.common/src/main/ets/framework/model/SettingItemModel';
import { EventBus } from '@ohos/settings.common/src/main/ets/framework/common/EventBus';
import {
  notifyCompStateChange,
  SettingBaseState,
  SettingDialogState,
  SettingStateType
} from '@ohos/settings.common/src/main/ets/framework/model/SettingStateModel';
import { FontScaleUtils } from '@ohos/settings.common/src/main/ets/utils/FontScaleUtils';
import { SettingsDataUtils } from '@ohos/settings.common/src/main/ets/utils/SettingsDataUtils';
import { HiSysEventUtil } from '@ohos/settings.common/src/main/ets/systemEvent/HiSysEventUtil';
import { LogUtil } from '@ohos/settings.common/src/main/ets/utils/LogUtil';
import { ElderCareUtils } from '@ohos/settings.accessibility/src/main/ets/ElderCareUtils';
import { SearchDataController } from '@ohos/settings.search/src/main/ets/controller/SearchController';
import {
  HiSysAccessibilityEventGroup,
  HiSysAuxiliaryEventGroup } from '@ohos/settings.common/src/main/ets/systemEvent/BehaviorEventConsts';
import { a11yInitData, A11yInitData } from '../sendable/A11yInitData';
import { PageUrl } from '../../../pages/PageUrl';
import {
  ACCESSIBILITY_ELDER_CARE_SWITCH_ENABLED,
  CLICK_SWITCH_OFF,
  CLICK_SWITCH_ON,
  RESTORE_DEFAULT_GROUP_EVENT
} from '../constant/Constants';

/* instrument ignore file */
const TAG: string = 'AccessibilitySettingsController : ';
const ENTER_INTERNAL_ENTRY: string = 'enter_internal_entry';

const RESTORE_GROUP_SUMMARY_LIST: ResourceStr[] = [$r('app.string.restore_defaults_visual_dialog_content'),
  $r('app.string.restore_defaults_hearing_dialog_content'), $r('app.string.restore_defaults_control_dialog_content')];

@Concurrent
async function initInvertColorState(a11yInitData: A11yInitData): Promise<void> {
  try {
    a11yInitData.invertColorState = await config.invertColor.get();
  } catch (err) {
    LogUtil.showError('initInvertColorState', `get invertColorState error: ${err?.message}`);
  }
  LogUtil.showInfo('A11yInit', `initInvertColorState ${a11yInitData.invertColorState}`);
}

@Concurrent
async function initHighContrastTextState(a11yInitData: A11yInitData): Promise<void> {
  try {
    a11yInitData.highContrastTextState = await config.highContrastText.get();
  } catch (err) {
    LogUtil.showError('initHighContrastTextState', `get highContrastTextState error: ${err?.message}`);
  }
  LogUtil.showInfo('A11yInit', `initHighContrastTextState ${a11yInitData.highContrastTextState}`);
}

@Concurrent
async function initAudioMonoState(a11yInitData: A11yInitData): Promise<void> {
  try {
    a11yInitData.audioMonoState = await config.audioMono.get();
  } catch (err) {
    LogUtil.showError('initAudioMonoState', `get audioMonoState error: ${err?.message}`);
  }
  LogUtil.showInfo('A11yInit', `initAudioMonoState ${a11yInitData.audioMonoState}`);
}

@Concurrent
async function initAudioBalanceState(a11yInitData: A11yInitData): Promise<void> {
  try {
    a11yInitData.audioBalanceState = await config.audioBalance.get();
  } catch (err) {
    LogUtil.showError('initAudioBalanceState', `get audioBalance error: ${err?.message}`);
  }
  LogUtil.showInfo('A11yInit', `initAudioBalanceState ${a11yInitData.audioBalanceState}`);
}

@Concurrent
async function initShortkeyState(a11yInitData: A11yInitData): Promise<void> {
  try {
    a11yInitData.shortkeyState = await config.shortkey.get();
  } catch (err) {
    LogUtil.showError('initShortkey', `get shortkey error: ${err?.message}`);
  }
  LogUtil.showInfo('A11yInit', `initShortkeyState ${a11yInitData.shortkeyState}`);
}

@Concurrent
async function initShortkeyMultiTargets(a11yInitData: A11yInitData): Promise<void> {
  try {
    a11yInitData.shortkeyMultiTargets = collections.Array.from(await config.shortkeyMultiTargets.get());
  } catch (err) {
    LogUtil.showError('initShortkeyMultiTargets', `get shortkeyMultiTargets error: ${err?.message}`);
  }
  LogUtil.showInfo('A11yInit', `initShortkeyMultiTargets ${a11yInitData.shortkeyMultiTargets}`);
}

@Concurrent
async function initDaltonizationState(a11yInitData: A11yInitData): Promise<void> {
  try {
    a11yInitData.daltonizationState = await config.daltonizationState.get();
  } catch (err) {
    LogUtil.showError('initDaltonizationState', `get daltonizationState error: ${err?.message}`);
  }
  LogUtil.showInfo('A11yInit', `initDaltonizationState ${a11yInitData.daltonizationState}`);
}

@Concurrent
async function initIgnoreRepeatClick(a11yInitData: A11yInitData): Promise<void> {
  try {
    a11yInitData.ignoreRepeatClick = await config.ignoreRepeatClick.get();
  } catch (err) {
    LogUtil.showError('initIgnoreRepeatClick', `get ignoreRepeatClick error: ${err?.message}`);
  }
  LogUtil.showInfo('A11yInit', `initIgnoreRepeatClick ${a11yInitData.ignoreRepeatClick}`);
}

@Concurrent
async function initElderCare(a11yInitData: A11yInitData): Promise<void> {
  try {
    a11yInitData.simpleUiModeSwitch =
      SettingsDataUtils.getSettingsData('simple_ui_mode_switch', CLICK_SWITCH_OFF) === CLICK_SWITCH_ON;
    LogUtil.showInfo('A11yInit', `initElderCare get simpleUiModeSwitch success: ${a11yInitData.simpleUiModeSwitch}`);
    if (a11yInitData.simpleUiModeSwitch) {
      SettingsDataUtils.setSecureValue(ACCESSIBILITY_ELDER_CARE_SWITCH_ENABLED, CLICK_SWITCH_ON);
      a11yInitData.elderCareSwitch = true;
    } else {
      a11yInitData.elderCareSwitch = SettingsDataUtils.getSecureValue(ACCESSIBILITY_ELDER_CARE_SWITCH_ENABLED,
        CLICK_SWITCH_OFF) === CLICK_SWITCH_ON;
    }

    if (a11yInitData.elderCareSwitch) {
      SettingsDataUtils.setSecureValue(ElderCareUtils.ELDER_CARE_HAS_ENABLED, 'true');
    }
  } catch (err) {
    LogUtil.showError('initElderCare', `get initElderCare error: ${err?.message}`);
  }
  LogUtil.showInfo('A11yInit', `initElderCare elderCareSwitch: ${a11yInitData.elderCareSwitch}`);
}

@Concurrent
async function initAnimationOff(a11yInitData: A11yInitData): Promise<void> {
  try {
    a11yInitData.animationOffState = await config.animationOff.get();
  } catch (err) {
    LogUtil.showError('initAnimationOff', `get animationOffState error: ${err?.message}`);
  }
  LogUtil.showInfo('A11yInit', `initAnimationOff ${a11yInitData.animationOffState}`);
}

export class AccessibilitySettingsController implements ComponentControl {
  private compId: string = '';
  private restoreAccessibilityConfig: RestoreAccessibilityConfig = new RestoreAccessibilityConfig();
  private searchItems: string[] = ['sound_alarm_item', 'sound_baby_crying_item', 'sound_knock_door_item',
    'sound_doorbell_item', 'sound_meow_item', 'sound_bark_item', 'reminder_alarmClock_switch',
    'incoming_call_switch', 'notify_switch'];
  private restoreVisual: Function = ()=> {
    this.restoreAccessibilityConfig.restoreAccessibilityVisualConfig();
    SearchDataController.getInstance().updateSearchItemStatus('zoom_zone_text', false);
  }
  private restoreHearing: Function = ()=> {
    this.restoreAccessibilityConfig.restoreAccessibilityHearingConfig();
    this.searchItems.forEach((itemName) => {
      SearchDataController.getInstance().updateSearchItemStatus(itemName, false);
    });
  }
  private restoreControl: Function = ()=> {
    this.restoreAccessibilityConfig.restoreAccessibilityControlConfig();
  }

  private commandMap: Map<number, Function> = new Map([
    [0, this.restoreVisual],
    [1, this.restoreHearing],
    [2, this.restoreControl],
  ]);

  async getAccessibilityConfig(): Promise<void> {
    try {
      let group: taskpool.TaskGroup = new taskpool.TaskGroup();
      group.addTask(initInvertColorState, a11yInitData);
      group.addTask(initHighContrastTextState, a11yInitData);
      group.addTask(initAudioMonoState, a11yInitData);
      group.addTask(initAudioBalanceState, a11yInitData);
      group.addTask(initShortkeyState, a11yInitData);
      group.addTask(initShortkeyMultiTargets, a11yInitData);
      group.addTask(initDaltonizationState, a11yInitData);
      group.addTask(initIgnoreRepeatClick, a11yInitData);
      group.addTask(initElderCare, a11yInitData);
      group.addTask(initAnimationOff, a11yInitData);
      taskpool.execute(group, taskpool.Priority.HIGH);
      LogUtil.showInfo('A11yInit', 'end');
    } catch (err) {
      LogUtil.error(`${TAG} Accessibility config fail, err: ${err?.message}`);
    }
  }

  private restoreObserver = (dialogSummaryNum: number) => {
    LogUtil.info(`${TAG} on restoreObserver: ${dialogSummaryNum}`);
    if (dialogSummaryNum === undefined) {
      return;
    }
    LogUtil.info(`${TAG} on restoreObserver: ${RESTORE_GROUP_SUMMARY_LIST[dialogSummaryNum]}`);
    this.openRestoreDialog(dialogSummaryNum);
  };

  private closeDialog(): void {
    notifyCompStateChange(`${this.compId}.AccessibilityFixedGroups.restoreDialog`, new Map(
      [[SettingStateType.STATE_TYPE_ITEM_DIALOG, {} as SettingBaseState]]
    ));
  }

  private openRestoreDialog(dialogSummaryNum: number): void {
    if (dialogSummaryNum < 0 || dialogSummaryNum >= RESTORE_GROUP_SUMMARY_LIST.length) {
      LogUtil.error(`${TAG} Invalid dialogSummaryNum: ${dialogSummaryNum}`);
      return;
    }
    notifyCompStateChange(`${this.compId}.AccessibilityFixedGroups.restoreDialog`,
      new Map<SettingStateType, SettingDialogState>([[SettingStateType.STATE_TYPE_ITEM_DIALOG,
        {
          title: $r('app.string.restore_defaults_dialog_title'),
          message: RESTORE_GROUP_SUMMARY_LIST[dialogSummaryNum],
          buttons: [
            {
              value: $r('app.string.button_tittle_cancel'),
              action: (component: SettingItemModel) => {
                this.closeDialog();
              },
              style: {
                buttonStyle: ButtonStyleMode.TEXTUAL,
              }
            },
            {
              value: $r('app.string.restore_defaults_dialog_confirm'),
              action: (component: SettingItemModel) => {
                let restoreAction = this.commandMap.get(dialogSummaryNum);
                if (restoreAction) {
                  restoreAction();
                  HiSysEventUtil.reportDefaultBehaviorEventByUE(
                    HiSysAccessibilityEventGroup.ACCESSIBILITY_RESTORE_DEFAULTS, dialogSummaryNum);
                } else {
                  LogUtil.info(`${TAG} Unknown command`);
                }
              },
              style: {
                buttonStyle: ButtonStyleMode.TEXTUAL,
              }
            }
          ],
          buttonVertical: FontScaleUtils.isExtraLargeFontMode() ? false : true
        } as SettingDialogState]]));
  }

  async init(compParam: CompCtrlParam): Promise<void> {
    LogUtil.info(`${TAG} init`);
    if (!compParam || !compParam.component) {
      LogUtil.showInfo(TAG, 'Init failed, component is empty');
      return;
    }
    this.compId = compParam.compId;
    HiSysEventUtil.reportDefaultBehaviorEventByUE(HiSysAuxiliaryEventGroup.ENTER_AUXILIARY_FUNCTIONS,
      'pageUrl: ' + PageUrl.ACCESSIBILITY_PAGE_URL);
    HiSysEventUtil.reportEntryEvent(ENTER_INTERNAL_ENTRY, 'pageUrl: ' + PageUrl.ACCESSIBILITY_PAGE_URL);
    await this.getAccessibilityConfig();
    EventBus.getInstance().on(RESTORE_DEFAULT_GROUP_EVENT, this.restoreObserver);
  }

  destroy(): void {
    LogUtil.info(`${TAG} on destroy`);
    EventBus.getInstance().detach(RESTORE_DEFAULT_GROUP_EVENT, this.restoreObserver);
  }

  onPageShow(component: SettingBaseModel): void {
    LogUtil.info(`${TAG} onPageShow`);
  }

  onPageHide(component: SettingBaseModel): void {
    LogUtil.info(`${TAG} onPageHide`);
  }
}
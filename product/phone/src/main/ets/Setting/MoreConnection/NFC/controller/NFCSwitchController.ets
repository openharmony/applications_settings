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
import nfcController from '@ohos.nfc.controller';
import { emitter } from '@kit.BasicServicesKit';
import { LogUtil } from '@ohos/settings.common/src/main/ets/utils/LogUtil';
import { CommonUtils } from '@ohos/settings.common/src/main/ets/utils/CommonUtils';
import { NavEntryKey } from '@ohos/settings.common/src/main/ets/utils/Consts';
import { HiSysEventUtil } from '@ohos/settings.common/src/main/ets/systemEvent/HiSysEventUtil';
import { HiSysNfcEventGroup } from '@ohos/settings.common/src/main/ets/systemEvent/BehaviorEventConsts';
import {
  CompCtrlParam,
  ComponentControl,
  SettingBaseModel
} from '@ohos/settings.common/src/main/ets/framework/model/SettingBaseModel';
import {
  notifyCompStateChange,
  SettingBaseState,
  SettingCompState,
  SettingResultState,
  SettingStateType,
  SettingTextState,
  SettingToggleState,
} from '@ohos/settings.common/src/main/ets/framework/model/SettingStateModel';
import { ItemResultType } from '@ohos/settings.common/src/main/ets/framework/model/SettingItemModel';
import { EventBus } from '@ohos/settings.common/src/main/ets/framework/common/EventBus';
import { EVENT_ID_NFC_SWITCH_CHANGE } from '@ohos/settings.common/src/main/ets/event/types';
import { SettingsDataUtils } from '@ohos/settings.common/src/main/ets/utils/SettingsDataUtils';
import { MASK_OPACITY, FULL_OPACITY } from '@ohos/settings.common/src/main/ets/constant/ViewConstant';
import { NFCStateChangeListener, NFCUtil } from '@ohos/settings.moreconnection/src/main/ets/NFCUtil';
import { NFCTool } from '../util/NFCTool';

const TAG: string = 'NFCSwitchController : ';
const DEFAULT_PAY_APP = 'nfc_payment_default_app';
const CHANGE_NFC_SWITCH: string = 'change_nfc_switch';
const INACTIVE: number = nfcController?.NfcState?.STATE_OFF;
const ACTIVE: number = nfcController?.NfcState?.STATE_ON;
const ACTIVATING: number = nfcController?.NfcState?.STATE_TURNING_ON;
const DEACTIVATING: number = nfcController?.NfcState?.STATE_TURNING_OFF;
const SWITCH_DELAY: number = 500;
const SWITCH_MAX_TIME: number = 5000;
const DEFAULT_PAYMENT_APPLICATION_ITEM: string =
  'Setting.nfc_settings.default_payment_application_group.default_payment_application_item';
const NFC_NOT_DISTURB_ITEM: string = 'Setting.nfc_settings.nfc_not_disturb_group.nfc_not_disturb_item';

export class NFCSwitchController implements ComponentControl, NFCStateChangeListener {
  private compId: string = '';
  // 用于表示目标状态 1: STATE_OFF, 2: STATE_TURNING_ON, 3: STATE_ON, 4: STATE_TURNING_OFF
  private targetState: number | null = null;
  private currentState: number | null = null; // 用于获取当前开关状态
  private taskTimerId: number | null = null; // taskTimerId 用于设置任务的完成时间
  private switchTimerId: number | null = null; // switchTimerId 开关能容忍的切换完成时间
  private isChecked: boolean = false;
  private isNFCDisable: boolean = false;
  private toggleStateChangeCallback = (toggleState: SettingToggleState) => {
    LogUtil.info(`${TAG} toggleStateChangeCallback = ${JSON.stringify(toggleState)}`);
    if (!toggleState) {
      LogUtil.error(`${TAG} toggleModel is invalid`);
      return;
    }
    if (toggleState.state === this.isChecked) {
      LogUtil.warn(`${TAG} target state equal to current state`);
      return;
    }
    this.handleCheckedChange(toggleState.state);
    emitter.emit({
      eventId: EVENT_ID_NFC_SWITCH_CHANGE,
      priority: emitter.EventPriority.IMMEDIATE,
    }, { data: { 'defaultAppState': toggleState } });
  };

  init(compParam: CompCtrlParam) {
    LogUtil.info(`${TAG} init`);
    if (!compParam) {
      LogUtil.error(`${TAG} init fail, compParam is invalid`);
      return;
    }
    this.compId = compParam?.compId;
    this.updateStatus();
    EventBus.getInstance().on(`${this.compId}.toggle`, this.toggleStateChangeCallback);
    this.registerDataChange();
    let settingsDataKeyChange = SettingsDataUtils.registerKeyObserver(DEFAULT_PAY_APP, () => {
      LogUtil.info(`${TAG} settingsDataKeyChange`);
      let curDefaultPayAPPValue: string = SettingsDataUtils.getSettingsData(DEFAULT_PAY_APP, '');
      NFCTool.notifyRefreshDefaultApp(curDefaultPayAPPValue, DEFAULT_PAYMENT_APPLICATION_ITEM, true);
    });
    LogUtil.info(`${TAG} registerKeyObserverUser:settingsDataKeyChange: ${settingsDataKeyChange}`);

  }

  onPageShow(component: SettingBaseModel): void {
    LogUtil.info(`${TAG} onPageShow`);
    this.setEDMNFCState();
  }

  onPageHide(component: SettingBaseModel): void {
    LogUtil.info(`${TAG} onPageHide`);
  }

  destroy(): void {
    LogUtil.info(`${TAG} destroy`);
    EventBus.getInstance().detach(`${this.compId}.toggle`, this.toggleStateChangeCallback);
    let settingsDataKeyChange = SettingsDataUtils.unregisterKeyObserver(DEFAULT_PAY_APP);
    LogUtil.info(`${TAG} unregisterKeyObserver:settingsDataKeyChange: ${settingsDataKeyChange}`);
    if (!CommonUtils.isPageExist(NavEntryKey.NFC_ENTRY)) {
      this.unRegisterDataChange();
    } else {
      LogUtil.info(`${TAG} nfc_entry exist, do not unregister`);
    }
  }

  private setEDMNFCState(): void {
    this.updateItemEnableStatus(this.compId, !this.isNFCDisable)
  }

  /**
   * 更新NFC开关按钮状态
   */
  private updateCheckedState(): boolean {
    let isChecked: boolean = nfcController.isNfcOpen();
    this.currentState = isChecked ? ACTIVE : INACTIVE;
    LogUtil.info(`${TAG} updateCheckedState ${isChecked}`);
    this.updateTargetStateValue(this.currentState);
    return isChecked;
  }

  private updateTargetStateValue(state: number): void {
    LogUtil.info(`${TAG} updateTargetStateValue ${state}`);
    this.targetState = state;
  }

  private handleCheckedChange(isChecked: boolean): boolean {
    HiSysEventUtil.reportDefaultBehaviorEventByUE(HiSysNfcEventGroup.CLICK_NFC_BUTTON, isChecked ? 'true' : 'false');
    LogUtil.info(`${TAG} enter handleCheckedChange...`);
    this.updateTargetStateValue(isChecked ? ACTIVE : INACTIVE);
    this.setChecked(isChecked);
    return this.startTask();
  }

  public getChecked(): boolean {
    LogUtil.info(`${TAG} getChecked ${this.isChecked}`);
    return this.isChecked;
  }

  private startTask(): boolean {
    this.stopTask();
    LogUtil.info(`${TAG} task start, currentState ${this.currentState}`);
    this.taskTimerId = setTimeout(() => {
      this.taskTimerId = null; // 开始新任务时，先清空现有的 taskTimerId
      LogUtil.info(`${TAG} switch task timeout`);
      this.updateStatus();
    }, SWITCH_MAX_TIME);

    return this.updateToTargetState();
  }

  private stopTask(): void {
    if (this.taskTimerId !== null) { // 将现有的taskTimerId清空
      clearTimeout(this.taskTimerId);
      this.taskTimerId = null;
    }

    if (this.switchTimerId !== null) { // 将现有的switchTimerId清空
      clearTimeout(this.switchTimerId);
      this.switchTimerId = null;
    }
  }

  updateStatus(): void {
    LogUtil.info(`${TAG} updateStatus`);
    let isChecked = this.updateCheckedState();
    this.setChecked(isChecked);
  }

  updateToTargetState(delay: number = 0): boolean {
    if (this.taskTimerId === null) { // 重复点击时间，使得之前的任务被取消执行
      LogUtil.error(`${TAG} taskTimerId null`);
      return true;
    }
    if (this.currentState !== ACTIVE && this.currentState !== INACTIVE) {
      // 中间态，切换中, 等待切换完成
      LogUtil.info(`${TAG} in task, currentState ${this.currentState}`);
      return true;
    }
    if (this.currentState === this.targetState) {
      // 非中间态，且已经目标态，任务结束
      LogUtil.info(`${TAG} task finish, currentState ${this.currentState}`);
      if (this.currentState === ACTIVE) {
        HiSysEventUtil.reportSwitchEvent(CHANGE_NFC_SWITCH, 'on');
      } else if (this.currentState === INACTIVE) {
        HiSysEventUtil.reportSwitchEvent(CHANGE_NFC_SWITCH, 'off');
      }
      this.stopTask();
      return true;
    }

    // 非中间态，且不是目标态，开始切换到目标态
    if (this.switchTimerId !== null) {
      clearTimeout(this.switchTimerId);
      this.switchTimerId = null;
    }

    this.switchTimerId = setTimeout(() => {
      this.switchNFC();
      this.switchTimerId = null;
    }, delay);

    return true;
  }

  private switchNFC(): void {
    if (this.currentState !== ACTIVE && this.currentState !== INACTIVE) {
      // 中间态，不切换
      LogUtil.info(`${TAG} switchBluetooth, in task, currentState ${this.currentState}`);
      return;
    }

    LogUtil.info(`${TAG} switchNFC, targetState : ${this.targetState}`);
    let result = (this.targetState === ACTIVE) ? this.enableNfc() : this.disableNfc();
    if (result) {
      this.currentState = this.targetState === ACTIVE ? ACTIVATING : DEACTIVATING;
      LogUtil.info(`${TAG} enable or disable success, currentState ${this.currentState}`);
    } else {
      // 切换失败
      LogUtil.error(`${TAG} enable or disable failed`);
      this.stopTask();
      this.updateStatus();
    }
  }

  private enableNfc(): boolean {
    if (nfcController?.isNfcOpen() === true) {
      LogUtil.info(`${TAG} nfc is already active`);
      return true;
    }
    let isSuccess: boolean = nfcController?.openNfc();
    LogUtil.info(`${TAG} enable nfc result is : ${isSuccess}`);
    return isSuccess;
  }

  private disableNfc(): boolean | undefined {
    if (nfcController?.isNfcOpen() !== true) {
      LogUtil.info(`${TAG} nfc is already inactive`);
      return;
    }
    let isSuccess: boolean = nfcController?.closeNfc();
    LogUtil.info(`${TAG} disable nfc result is : ${isSuccess}`);
    return isSuccess;
  }

  setChecked(isChecked: boolean): void {
    LogUtil.info(`${TAG} setChecked ${isChecked}`);
    if (this.isChecked !== isChecked) {
      this.isChecked = isChecked;
      LogUtil.info(`${TAG} setChecked, refresh : ${this.isChecked}`);
      this.refreshUi();
    }
  }

  /**
   * 刷新NFC开关、默认付款应用状态、NFC读卡通知勿扰状态
   */
  private refreshUi(): void {
    LogUtil.info(`${TAG} refreshUi, this.isChecked=${this.isChecked}`);
    notifyCompStateChange(`${this.compId}`, new Map<SettingStateType, SettingBaseState>(
      [[SettingStateType.STATE_TYPE_ITEM_RESULT, {
        type: ItemResultType.RESULT_TYPE_TOGGLE,
        result: { state: this.getChecked() } as SettingToggleState
      } as SettingResultState]]
    ));
    notifyCompStateChange(DEFAULT_PAYMENT_APPLICATION_ITEM,
      new Map<SettingStateType, SettingBaseState>([[SettingStateType.STATE_TYPE_ITEM_ENABLED,
        { state: this.getChecked() } as SettingCompState]]));
    this.updateItemEnableStatus(NFC_NOT_DISTURB_ITEM, this.getChecked());
  }

  private updateItemEnableStatus(compId: string, enable: boolean): void {
    LogUtil.info(`${TAG} updateItemEnableStatus ${enable}`);
    notifyCompStateChange(compId,
      new Map<SettingStateType, SettingBaseState>([
        [SettingStateType.STATE_TYPE_ITEM_TITLE,
          {
            opacity: enable ? FULL_OPACITY : MASK_OPACITY
          } as SettingTextState],
        [SettingStateType.STATE_TYPE_ITEM_RESULT, {
          type: ItemResultType.RESULT_TYPE_TOGGLE,
          result: {
            enabled: enable
          } as SettingToggleState
        } as SettingResultState]
      ]));
  }

  /**
   * 发送NFC状态变更事件
   */
  private emitNfcStatus(): void {
    let state: boolean = false;
    try {
      state = nfcController?.isNfcOpen();
      LogUtil.info(`${TAG} update nfc service state, state: ${state}`);
    } catch (err) {
      LogUtil.error(`${TAG} check nfcStatus api failed`);
    }

    emitter.emit({
      eventId: EVENT_ID_NFC_SWITCH_CHANGE,
      priority: emitter.EventPriority.IMMEDIATE,
    }, { data: { 'defaultAppState': state } });
    LogUtil.info(`${TAG} emitter.emit`);
  }

  getListenerName(): string {
    return this.compId ?? ' ';
  }

  onNFCStateChange(stateChanged: nfcController.NfcState): void {
    LogUtil.info(`${TAG} listener find nfc service isChanged: ${stateChanged}`);
    this.currentState = stateChanged;

    if (stateChanged === nfcController?.NfcState?.STATE_OFF || stateChanged === nfcController?.NfcState?.STATE_ON) {
      this.emitNfcStatus();
    }

    if (this.taskTimerId !== null) { // taskTimerId存在，则说明此时生成任务
      // 用户点击，切换任务中
      this.updateToTargetState(SWITCH_DELAY);
    } else {
      // 外部切换事件接收
      if (this.currentState !== ACTIVE && this.currentState !== INACTIVE) {
        // 中间态，切换中
        return;
      }
      this.updateTargetStateValue(this.currentState);
      this.setChecked(this.currentState === ACTIVE);
    }
  }

  protected registerDataChange(): void {
    LogUtil.info(`${TAG} registerDataChange`);
    NFCUtil.getInstance().unRegisterStateChangeListener(this);
    NFCUtil.getInstance().registerStateChangeListener(this);
  }

  protected unRegisterDataChange(): void {
    LogUtil.info(`${TAG} unRegisterDataChange`);
    NFCUtil.getInstance().unRegisterStateChangeListener(this);
  }
}
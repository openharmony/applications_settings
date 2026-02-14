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

import nfcController from '@ohos.nfc.controller';
import { SettingsBaseMenu } from '@ohos/settings.common/src/main/ets/core/model/menu/SettingsMenu';
import { LogUtil } from '@ohos/settings.common/src/main/ets/utils/LogUtil';
import { Controller } from '@ohos/settings.common/src/main/ets/core/controller/Controller';
import { HiSysEventUtil } from '@ohos/settings.common/src/main/ets/systemEvent/HiSysEventUtil';
import { HiSysNfcEventGroup } from '@ohos/settings.common/src/main/ets/systemEvent/BehaviorEventConsts';
import emitter from '@ohos.events.emitter';
import { EVENT_ID_NFC_SWITCH_CHANGE } from '@ohos/settings.common/src/main/ets/event/types';
import { SwitchMenuController } from '@ohos/settings.common/src/main/ets/core/controller/MenuController';
import { NFCStateChangeListener, NFCUtil } from '../NFCUtil';

const CHANGE_NFC_SWITCH: string = 'change_nfc_switch';
const TAG: string = 'NFCServiceController : ';
const INACTIVE: number = nfcController?.NfcState?.STATE_OFF;
const ACTIVE: number = nfcController?.NfcState?.STATE_ON;
const ACTIVATING: number = nfcController?.NfcState?.STATE_TURNING_ON;
const DEACTIVATING: number = nfcController?.NfcState?.STATE_TURNING_OFF;
const SWITCH_DELAY: number = 500;
const SWITCH_MAX_TIME: number = 5000; // 5s

export function getNfcStatusForReport():boolean {
  return nfcController.isNfcOpen();
}

export class NFCServiceController extends SwitchMenuController implements NFCStateChangeListener {
  static CreateNFCServiceController(menu: SettingsBaseMenu): Controller {
    return new NFCServiceController(menu);
  }

  // 用于表示目标状态 1: STATE_OFF, 2: STATE_TURNING_ON, 3: STATE_ON, 4: STATE_TURNING_OFF
  public targetState: number | null = null;
  public currentState: number | null = null; // 用于获取当前开关状态
  public taskTimerId: number | null = null; // taskTimerId 用于设置任务的完成时间
  public switchTimerId: number | null = null; // switchTimerId 开关能容忍的切换完成时间

  getListenerName(): string {
    return this.menu.key ?? ' ';
  }

  aboutToAppear(): void {
    LogUtil.info(`${TAG} aboutToAppear`);
    super.aboutToAppear();
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
      this.setChecked(this.currentState === ACTIVE ? true : false);
      this.refreshUi();
    }
  }

  // aboutToAppear会调用，用于更新按钮状态
  protected updateCheckedState(): boolean {
    let isChecked: boolean = nfcController.isNfcOpen();
    this.currentState = isChecked ? ACTIVE : INACTIVE;
    LogUtil.info(`${TAG} updateCheckedState ${isChecked}`);
    this.updateTargetStateValue(this.currentState);
    return isChecked;
  }

  protected handleCheckedChange(isChecked: boolean): boolean {
    if (isChecked === this.getChecked()) {
      LogUtil.info(`${this.tag} handleCheckedChange isChecked not change : ${isChecked}`);
      return false;
    }

    HiSysEventUtil.reportDefaultBehaviorEventByUE(HiSysNfcEventGroup.CLICK_NFC_BUTTON, isChecked ? 'true' : 'false');
    LogUtil.info(`${TAG} enter handleCheckedChange...`);
    this.updateTargetStateValue(isChecked ? ACTIVE : INACTIVE);
    return this.startTask();
  }

  private updateTargetStateValue(state: number): void {
    LogUtil.info(`${TAG} updateTargetStateValue ${state}`);
    this.targetState = state;
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

  // 用于规避重复点击事件
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

  protected registerDataChange(): void {
    LogUtil.info(`${TAG} registerDataChange`);
    NFCUtil.getInstance().registerStateChangeListener(this);
  }

  protected unRegisterDataChange(): void {
    LogUtil.info(`${TAG} unRegisterDataChange`);
    NFCUtil.getInstance().unRegisterStateChangeListener(this);
  }
}
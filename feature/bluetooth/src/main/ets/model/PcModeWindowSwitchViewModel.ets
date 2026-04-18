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
import access from '@ohos.bluetooth.access';
import {
  HiSysEventUtil,
} from '@ohos/settings.common/src/main/ets/systemEvent/HiSysEventUtil';
import { BluetoothUtils } from '@ohos/settings.common/src/main/ets/utils/BluetoothUtils';
import { LogUtil } from '@ohos/settings.common/src/main/ets/utils/LogUtil';
import { NavEntryKey } from '@ohos/settings.common/src/main/ets/utils/Consts';
import { CommonUtils } from '@ohos/settings.common/src/main/ets/utils/CommonUtils';
import { HiSysBluetoothEventGroup } from '@ohos/settings.common/src/main/ets/systemEvent/BehaviorEventConsts';
import { HiSysBluetoothStateException } from '@ohos/settings.common/src/main/ets/systemEvent/ExceptionEventConsts';
import { BluetoothAdapter, BluetoothStateChangeListener } from '../BluetoothAdapter';

const TAG: string = 'PcModeWindowSwitchViewModel : ';
const SWITCH_MAX_TIME: number = 5000; // 5s
const SWITCH_DELAY: number = 500;
const BT_TOGGLE_SWITCH_DELAY: number = 200;
const INACTIVE: number = access.BluetoothState.STATE_OFF;
const ACTIVE: number = access.BluetoothState.STATE_ON;
const ACTIVATING: number = access.BluetoothState.STATE_TURNING_ON;
const DEACTIVATING: number = access.BluetoothState.STATE_TURNING_OFF;
const CHANGE_BLUETOOTH_SWITCH: string = 'change_bluetooth_switch';

/**
 * 蓝牙开关控制器
 *
 * @since 2022-04-25
 */
@Observed
export class PcModeWindowSwitchViewModel implements BluetoothStateChangeListener {
  public targetState: number | undefined = undefined;
  public currentState: number | undefined = undefined;
  public taskTimerId: number | null = null;
  public switchTimerId: number | null = null;
  public isChecked: boolean = BluetoothUtils.isBluetoothStateOn(BluetoothAdapter.getInstance().currentState);

  init(): void {
    LogUtil.info(`${TAG} init`);
    this.updateCheckedState();
    this.registerDataChange();
  }

  onPageShow(): void {
    LogUtil.info(`${TAG} onPageShow`);
    this.updateCheckedState();
  }

  destroy(): void {
    LogUtil.info(`${TAG} destroy`);
    if (CommonUtils.isPageExist(NavEntryKey.BLUETOOTH_ENTRY)) {
      LogUtil.info(`${TAG} the page exist, not unregister`);
      return;
    }

    this.unRegisterDataChange();
  }

  getListenKey(): string {
    return 'Window_Switch_View_Model';
  }

  public setChecked(value: boolean) {
    LogUtil.info(`${TAG} setChecked: ${value}`);
    this.isChecked = value;
  }

  public getChecked(): boolean {
    return this.isChecked;
  }

  onBluetoothStateChange(state: number): void {
    LogUtil.info(TAG + 'bluetooth stateChange : ' + state);
    this.currentState = state;

    if (this.taskTimerId != null) {
      // 用户点击，切换任务中
      this.updateToTargetState(SWITCH_DELAY);
    } else {
      // 外部切换事件接收
      if (BluetoothUtils.isBluetoothMiddleState(state)) {
        // 中间态，切换中
        return;
      }
      this.updateTargetStateValue(this.currentState);
      this.setChecked(BluetoothUtils.isBluetoothStateOn(this.currentState));
    }
  }

  private updateCheckedState(): void {
    this.setChecked(BluetoothUtils.isBluetoothStateOn(BluetoothAdapter.getInstance().currentState));
    this.currentState = this.isChecked ? ACTIVE : INACTIVE;
    LogUtil.info(`${TAG} updateCheckedState : ${this.isChecked}`);
    this.updateTargetStateValue(this.currentState);
  }

  public handleCheckedChange(isChecked: boolean): boolean {
    LogUtil.info(`${TAG} handleCheckedChange, isChecked: ${isChecked}, this.getChecked(): ${this.getChecked()}`);
    if (isChecked === this.getChecked()) {
      LogUtil.info(`${TAG} handleCheckedChange isChecked not change : ${isChecked}`);
      return false;
    }
    if (isChecked) {
      HiSysEventUtil.reportDefaultBehaviorEventByUE(HiSysBluetoothEventGroup.CLICK_BLUETOOTH_BUTTON, 'true');
    }
    this.updateTargetStateValue(isChecked ? ACTIVE : INACTIVE);
    return this.startTask();
  }

  private updateTargetStateValue(state: number): void {
    LogUtil.info(`${TAG} updateTargetStateValue : ${state}`);
    this.targetState = state;
  }

  updateToTargetState(delay: number = 0): boolean {
    if (this.taskTimerId == null) {
      LogUtil.error(`${TAG} taskTimerId null`);
      return true;
    }
    this.currentState = this.currentState as number;
    this.targetState = this.targetState as number;
    if (BluetoothUtils.isBluetoothMiddleState(this.currentState)) {
      // 中间态，切换中, 等待切换完成
      LogUtil.info(`${TAG} in task, currentState ${this.currentState}`);
      return true;
    }
    if (this.currentState == this.targetState ||
      (BluetoothUtils.isBluetoothStateOn(this.currentState) &&
      BluetoothUtils.isBluetoothStateOn(this.targetState))) {
      // 非中间态，且已经目标态，任务结束
      LogUtil.info(`${TAG} task finish, currentState ${this.currentState}`);
      if (BluetoothUtils.isBluetoothStateOn(this.currentState) && BluetoothUtils.isBluetoothStateOn(this.targetState)) {
        HiSysEventUtil.reportSwitchEvent(CHANGE_BLUETOOTH_SWITCH, 'on');
      } else if (BluetoothUtils.isBluetoothStateOff(this.currentState)) {
        HiSysEventUtil.reportSwitchEvent(CHANGE_BLUETOOTH_SWITCH, 'off');
      }
      this.setChecked(BluetoothUtils.isBluetoothStateOn(this.currentState));
      this.stopTask();
      return true;
    }

    // 非中间态，且不是目标态，开始切换到目标态
    if (this.switchTimerId != null) {
      clearTimeout(this.switchTimerId);
      this.switchTimerId = null;
    }
    this.switchTimerId = setTimeout(() => {
      this.switchBluetooth();
      this.switchTimerId = null;
    }, delay);

    return true;
  }

  private switchBluetooth(): void {
    this.currentState = this.currentState as number;
    this.targetState = this.targetState as number;
    if (BluetoothUtils.isBluetoothMiddleState(this.currentState)) {
      // 中间态，不切换
      LogUtil.info(`${TAG} switchBluetooth, in task, currentState ${this.currentState}`);
      return;
    }
    LogUtil.info(`${TAG} switchBluetooth, targetState : ${this.targetState}`);
    let result = BluetoothUtils.isBluetoothStateOn(this.targetState) ? this.enableBluetooth() : this.disableBluetooth();
    if (result) {
      this.currentState = BluetoothUtils.isBluetoothStateOn(this.targetState) ? ACTIVATING : DEACTIVATING;
      this.setChecked(this.targetState === ACTIVE);
      LogUtil.info(`${TAG} enable or disable success, currentState ${this.currentState}`);
    } else {
      // 切换失败
      LogUtil.error(`${TAG} enable or disable failed`);
      this.stopTask();
      this.setChecked(BluetoothUtils.isBluetoothStateOn(BluetoothAdapter.getInstance().currentState));
    }
  }

  private startTask(): boolean {
    this.stopTask();
    LogUtil.info(`${TAG} task start, currentState ${this.currentState}`);
    this.taskTimerId = setTimeout(() => {
      this.taskTimerId = null;
      LogUtil.error(`${TAG} switch task timeout`);
      HiSysEventUtil.reportDefaultFaultEvent(HiSysBluetoothStateException.EVENT_NAME,
        HiSysBluetoothStateException.BLUETOOTH_STATE_CHANGE_TIMEOUT);
      this.setChecked(BluetoothUtils.isBluetoothStateOn(BluetoothAdapter.getInstance().currentState));
    }, SWITCH_MAX_TIME);

    //animation first, delay 200ms to switch BT;
    return this.updateToTargetState(BT_TOGGLE_SWITCH_DELAY);
  }

  private stopTask(): void {
    if (this.taskTimerId != null) {
      clearTimeout(this.taskTimerId);
      this.taskTimerId = null;
    }
    if (this.switchTimerId != null) {
      clearTimeout(this.switchTimerId);
      this.switchTimerId = null;
    }
  }

  private enableBluetooth(): boolean {
    if (BluetoothUtils.isBluetoothStateOn(BluetoothAdapter.getInstance().currentState)) {
      LogUtil.info(TAG + 'bluetooth is already enable');
      return true;
    }
    let isSuccess: boolean = BluetoothUtils.enableBlueTooth();
    LogUtil.info(TAG + 'enable bluetooth result is : ' + isSuccess);
    return isSuccess;
  }

  private disableBluetooth(): boolean {
    if (!BluetoothUtils.isBluetoothStateOn(BluetoothAdapter.getInstance().currentState)) {
      LogUtil.info(TAG + 'bluetooth is already disable');
      return true;
    }
    let isSuccess: boolean = BluetoothUtils.disableBlueTooth();
    LogUtil.info(TAG + 'disable bluetooth result is : ' + isSuccess);
    return isSuccess;
  }

  private registerDataChange(): void {
    LogUtil.info(TAG + 'registerDataChange');
    BluetoothAdapter.getInstance().unRegisterStateChangeListener(this);
    BluetoothAdapter.getInstance().registerStateChangeListener(this);
  }

  private unRegisterDataChange(): void {
    LogUtil.info(TAG + 'unRegisterDataChange');
    BluetoothAdapter.getInstance().unRegisterStateChangeListener(this);
  }
}

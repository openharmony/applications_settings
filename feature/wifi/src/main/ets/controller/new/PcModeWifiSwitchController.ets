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

import { AirPlaneUtils } from '@ohos/settings.common/src/main/ets/utils/AirPlaneUtils';
import { EventBus } from '@ohos/settings.common/src/main/ets/framework/common/EventBus';
import { EVENT_ID_PC_MODE_WLAN_SWITCH } from '@ohos/settings.common/src/main/ets/event/types';
import { HiSysEventUtil } from '@ohos/settings.common/src/main/ets/systemEvent/HiSysEventUtil';
import { HiSysWIFIStateException } from '@ohos/settings.common/src/main/ets/systemEvent/ExceptionEventConsts';
import { LogUtil } from '@ohos/settings.common/src/main/ets/utils/LogUtil';
import {
  SWITCH_ON_VAL
} from '@ohos/settings.common/src/main/ets/utils/Consts';
import { SettingsDataUtils } from '@ohos/settings.common/src/main/ets/utils/SettingsDataUtils';
import { WifiState } from '../../model/WifiModel';
import { WifiUtils } from '../../../ets/WifiUtils';

/* instrument ignore file */
const TAG: string = 'PcModeWifiSwitchController : ';
const INACTIVE: number = WifiState.INACTIVE;
const ACTIVE: number = WifiState.ACTIVE;
const ACTIVATING: number = WifiState.ACTIVATING;
const DEACTIVATING: number = WifiState.DEACTIVATING;
const WIFI_TOGGLE_SWITCH_DELAY: number = 200;
const WIFI_TOGGLE_SWITCH_TIMEOUT: number = 5000;
const SWITCH_DELAY: number = 500;
const CHANGE_WIFI_SWITCH: string = 'change_wifi_switch';

/**
 * PcMode Wifi二级面板开关控制器
 *
 * @since 2025-06-30
 */
export class PcModeWifiSwitchController {
  public isChecked: boolean = true;
  public targetState: number | null = null; // 0: inactive, 1: active, 2: activating, 3: deactivating
  public currentState: number | null = null;
  public taskTimerId: number | null = null;
  public switchTimerId: number | null = null;
  // 应用是否被管控
  public isDisabled: boolean = false;

  init(): void {
    LogUtil.info(`${TAG} init`);
    // 初始化时更新按钮状态，防止存在默认值true导致有切换动效
    this.isChecked = WifiUtils.isWifiActive();
    this.updateCheckedState(this.isChecked);
    this.registerDataChange();
  }

  onPageShow(): void {
    this.updateCheckedState();
  }

  destroy(): void {
    LogUtil.info(`${TAG} destroy`);
    this.unRegisterDataChange();
  }

  public onWifiStateChange = (state: number): void => {
    LogUtil.info(`${TAG} wifi state change : ${state}, getDetailState:${WifiUtils.getDetailState()}`);
    this.currentState = state;

    if (this.taskTimerId !== null) {
      // 用户点击，切换任务中
      AppStorage.setOrCreate('WifiStateIsOn', this.currentState === ACTIVE ? true : false);
      this.updateToTargetState(SWITCH_DELAY);
    } else {
      // 外部切换事件接收
      if (this.isWifiSwitching()) {
        // 中间态，切换中
        return;
      }
      this.updateTargetStateValue(this.currentState);
      this.setChecked(this.currentState === ACTIVE ? true : false);
      AppStorage.setOrCreate('WifiStateIsOn', this.currentState === ACTIVE ? true : false);
    }
  }

  public onToggleChange(isChecked: boolean): boolean {
    LogUtil.info(`${TAG} onToggleChange ${isChecked}`);
    if (!this.handleCheckedChange(isChecked)) {
      LogUtil.info(`${TAG} handleCheckedChange fail`);
      return false;
    }
    this.isChecked = isChecked;
    return true;
  }

  public getChecked(): boolean {
    return this.isChecked;
  }

  private updateCheckedState(isSwitchChecked?: boolean): boolean {
    let isChecked: boolean = isSwitchChecked ?? false;
    if (isSwitchChecked === undefined) {
      isChecked = WifiUtils.isWifiActive();
    }
    this.currentState = isChecked ? ACTIVE : INACTIVE;
    LogUtil.info(`${TAG} updateCheckedState : ${isChecked}`);
    this.updateTargetStateValue(this.currentState);
    return isChecked;
  }

  private handleCheckedChange(isChecked: boolean): boolean {
    LogUtil.info(`${TAG} handleCheckedChange isChecked: ${isChecked}, this.isChecked: ${this.isChecked}`);
    if (isChecked === this.getChecked()) {
      LogUtil.info(`${TAG} handleCheckedChange isChecked not change : ${isChecked}`);
      return false;
    }
    this.targetState = isChecked ? ACTIVE : INACTIVE;
    return this.startTask();
  }

  private updateTargetStateValue(state: number): void {
    this.targetState = state;
    LogUtil.info(`${TAG} updateTargetStateValue targetState:${this.targetState}`);
    EventBus.getInstance().emit(EVENT_ID_PC_MODE_WLAN_SWITCH, this.targetState);
  }

  private updateToTargetState(delay: number = 0): boolean {
    if (this.taskTimerId === null) {
      LogUtil.error(`${TAG} taskTimerId null`);
      return true;
    }

    if (this.isWifiSwitching()) {
      // 中间态，切换中, 等待切换完成
      LogUtil.info(`${TAG} in task, currentState ${this.currentState}`);
      return true;
    }

    if (this.currentState === this.targetState) {
      // 非中间态，且已经目标态，任务结束
      LogUtil.info(`${TAG} task finish, currentState ${this.currentState}`);
      if (this.currentState === ACTIVE) {
        HiSysEventUtil.reportSwitchEvent(CHANGE_WIFI_SWITCH, 'on');
      } else if (this.currentState === INACTIVE) {
        HiSysEventUtil.reportSwitchEvent(CHANGE_WIFI_SWITCH, 'off');
      }
      // 已经是目标态 也要发送总线通知
      EventBus.getInstance().emit(EVENT_ID_PC_MODE_WLAN_SWITCH, this.currentState);
      this.stopTask();
      return true;
    }

    // 非中间态，且不是目标态，开始切换到目标态
    if (this.switchTimerId !== null) {
      clearTimeout(this.switchTimerId);
      this.switchTimerId = null;
    }
    this.switchTimerId = setTimeout(() => {
      // if the state change to INACTIVE, publish immediately to close wlan panel.
      LogUtil.info(`${TAG} switchTimerId updateTargetStateValue targetState:${this.targetState}`);
      EventBus.getInstance().emit(EVENT_ID_PC_MODE_WLAN_SWITCH, this.targetState);
      this.switchWifi();
      this.switchTimerId = null;
    }, delay);

    return true;
  }

  private switchWifi(): void {
    LogUtil.info(`${TAG} switchWifi, targetState : ${this.targetState}`);
    let result = (this.targetState === ACTIVE) ? this.enableWiFi() : this.processWifiDisable();
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

  private startTask(): boolean {
    this.stopTask();
    LogUtil.info(`${TAG} task start, currentState ${this.currentState}`);
    this.taskTimerId = setTimeout(() => {
      this.taskTimerId = null;
      this.switchTimerId = null;
      LogUtil.error(`${TAG} switch task timeout`);
      HiSysEventUtil.reportDefaultFaultEvent(HiSysWIFIStateException.EVENT_NAME,
        HiSysWIFIStateException.WIFI_STATE_CHANGE_TIMEOUT);
      this.updateStatus();
    }, WIFI_TOGGLE_SWITCH_TIMEOUT);

    // delay 200ms to switch wifi;
    return this.updateToTargetState(WIFI_TOGGLE_SWITCH_DELAY);
  }

  private stopTask(): void {
    if (this.taskTimerId !== null) {
      clearTimeout(this.taskTimerId);
      this.taskTimerId = null;
    }
    if (this.switchTimerId !== null) {
      clearTimeout(this.switchTimerId);
      this.switchTimerId = null;
    }
  }

  private enableWiFi(): boolean {
    if (WifiUtils.isWifiActive() === true) {
      LogUtil.info(`${TAG} wifi is already active`);
      return true;
    }
    let isSuccess: boolean = WifiUtils.enableWifi();
    LogUtil.info(`${TAG} enable wifi result is : ${isSuccess}`);
    return isSuccess;
  }

  private disableWifi(): boolean {
    if (WifiUtils.isWifiActive() !== true) {
      LogUtil.info(`${TAG} wifi is already inactive`);
      return true;
    }
    let isSuccess: boolean = WifiUtils.disableWifi();
    LogUtil.info(`${TAG} disable wifi result is : ${isSuccess}`);
    return isSuccess;
  }

  private enableSemiWifi(): boolean {
    if (!WifiUtils.isWifiActive()) {
      LogUtil.info(`${TAG} wifi is already inactive`);
      return true;
    }

    let isSuccess: boolean = WifiUtils.enableSemiWifi();
    LogUtil.info(`${TAG} changed wifi state to semiactive result is : ${isSuccess}`);
    return isSuccess;
  }

  private processWifiDisable(): boolean {
    let isAirPlaneOn: boolean = AirPlaneUtils.isAirplaneActive();
    if (isAirPlaneOn) {
      LogUtil.info(`${TAG} airPlane on, disabling wifi.`);
      return this.disableWifi();
    }
    return this.disableWifi();
  }

  private isWifiSwitching(): boolean {
    return this.currentState !== ACTIVE && this.currentState !== INACTIVE && this.currentState !== WifiState.SEMIACTIVE;
  }

  private setChecked(isChecked: boolean): void {
    if (this.isChecked === isChecked) {
      LogUtil.warn(`${TAG} setChecked failed.`);
      return;
    }
    this.isChecked = isChecked;
    LogUtil.info(`${TAG} setChecked, refresh : ${this.isChecked}`);
    EventBus.getInstance().emit(EVENT_ID_PC_MODE_WLAN_SWITCH, this.currentState);
  }

  private updateStatus(isSwitchChecked?: boolean): void {
    LogUtil.info(`${TAG} updateStatus`);
    let isChecked = this.updateCheckedState(isSwitchChecked);
    this.setChecked(isChecked);
  }

  private registerDataChange(): void {
    WifiUtils.wifiStateChangeOn(TAG, this.onWifiStateChange);
  }

  private unRegisterDataChange(): void {
    WifiUtils.wifiStateChangeOff(TAG, this.onWifiStateChange);
  }
}
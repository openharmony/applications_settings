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

import enterpriseWifiManager from '@ohos.enterprise.wifiManager';
import { SwitchMenuController } from '@ohos/settings.common/src/main/ets/core/controller/MenuController';
import { Controller } from '@ohos/settings.common/src/main/ets/core/controller/Controller';
import { SettingsBaseMenu } from '@ohos/settings.common/src/main/ets/core/model/menu/SettingsMenu';
import { SettingsDataUtils } from '@ohos/settings.common/src/main/ets/utils/SettingsDataUtils';
import { LogUtil } from '@ohos/settings.common/src/main/ets/utils/LogUtil';
import { PageLifecycleObserverInterface } from '@ohos/settings.common/src/main/ets/core/lifecycle/Lifecycle';
import { HiSysEventUtil } from '@ohos/settings.common/src/main/ets/systemEvent/HiSysEventUtil';
import { HiSysWIFIStateException } from '@ohos/settings.common/src/main/ets/systemEvent/ExceptionEventConsts';
import {
  SWITCH_ON_VAL
} from '@ohos/settings.common/src/main/ets/utils/Consts';
import { AirPlaneUtils } from '@ohos/settings.common/src/main/ets/utils/AirPlaneUtils';
import { WifiState } from '../model/WifiModel';
import { WifiUtils } from '../WifiUtils';

/* instrument ignore file */
const TAG: string = 'WifiSwitchController : ';
const INACTIVE: number = WifiState.INACTIVE;
const ACTIVE: number = WifiState.ACTIVE;
const ACTIVATING: number = WifiState.ACTIVATING;
const DEACTIVATING: number = WifiState.DEACTIVATING;
const WIFI_TOGGLE_SWITCH_DELAY: number = 200;
const SWITCH_DELAY: number = 500;
const CHANGE_WIFI_SWITCH: string = 'change_wifi_switch';

/**
 * Wifi开关控制器
 *
 * @since 2022-03-21
 */
export class WifiSwitchController extends SwitchMenuController implements PageLifecycleObserverInterface {
  public static CreateWifiSwitchController(menu: SettingsBaseMenu): Controller {
    return new WifiSwitchController(menu);
  }

  public readonly tag: string = 'WifiSwitchController : ';
  public targetState: number | null = null; // 0: inactive, 1: active, 2: activating, 3: deactivating
  public currentState: number | null = null;
  public taskTimerId: number | null = null;
  public switchTimerId: number | null = null;
  public getObserverKey = (): string => {
    return this.menu?.key as string;
  }
  // 应用是否被管控
  public isDisabled: boolean = false;

  onPageShow(): void {
    this.updateWifiManageStatus();
    this.updateCheckedState();
    this.refreshUi();
  }

  onPageHide(): void {
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
      this.refreshUi();
    }
  }

  protected updateCheckedState(): boolean {
    let isChecked = WifiUtils.isWifiActive();
    this.currentState = isChecked ? ACTIVE : INACTIVE;
    LogUtil.info(`${TAG} updateCheckedState : ${isChecked}`);
    this.updateTargetStateValue(this.currentState);
    return isChecked;
  }

  private updateWifiManageStatus(): void {
    try {
      // 调用wifi管理模块查询wifi管控情况
      this.isDisabled = enterpriseWifiManager.isWifiDisabled(null);
      LogUtil.info(`${TAG}: Succeeded in query is wifi disabled or not, result : ${this.isDisabled}`);
    } catch (err) {
      LogUtil.error(`${TAG}: Failed to get device encryption status. Code: ${err.code}, message: ${err.message}`);
    }
    // 设置按钮启用情况，与被管控情况相反
    this.setToggleState(!this.isDisabled);
  }

  protected handleCheckedChange(isChecked: boolean): boolean {
    LogUtil.info(`${TAG} handleCheckedChange isChecked:${isChecked}`);
    if (isChecked === this.getChecked()) {
      LogUtil.info(`${this.tag} handleCheckedChange isChecked not change : ${isChecked}`);
      return false;
    }
    // avoid to publish status; don't call updateTargetStateValue(isChecked ? ACTIVE : INACTIVE);
    this.targetState = isChecked ? ACTIVE : INACTIVE;
    return this.startTask();
  }

  private updateTargetStateValue(state: number): void {
    this.targetState = state;
    LogUtil.info(`${TAG} updateTargetStateValue publishDataChange targetState:${this.targetState}`);
    this.publishDataChange(this.targetState);
  }

  public onRegisteredByObserver(observerKey: string): void {
    LogUtil.info(`${TAG} onRegisteredByObserver publishDataChange targetState:${this.targetState}`);
    this.publishDataChange(this.targetState as Object);
  }

  public updateToTargetState(delay: number = 0): boolean {
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
      this.publishDataChange(this.currentState as number);
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
      LogUtil.info(`${TAG} switchTimerId publishDataChange targetState:${this.targetState}`);
      this.publishDataChange(this.targetState as number);
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
      LogUtil.error(`${TAG} switch task timeout`);
      HiSysEventUtil.reportDefaultFaultEvent(HiSysWIFIStateException.EVENT_NAME,
        HiSysWIFIStateException.WIFI_STATE_CHANGE_TIMEOUT);
      this.updateStatus();
    }, 5000);

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
    let isOobeWifi: boolean = AppStorage.get<boolean>('OOBEWifi') ?? false;
    if (isOobeWifi) {
      LogUtil.info(`${TAG} isOobeWifi, disabling wifi.`);
      return this.disableWifi();
    }
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

  protected registerDataChange(): void {
    WifiUtils.wifiStateChangeOn(TAG, this.onWifiStateChange);
  }

  protected unRegisterDataChange(): void {
    WifiUtils.wifiStateChangeOff(TAG, this.onWifiStateChange);
  }
}

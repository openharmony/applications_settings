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

import systemparameter from '@ohos.systemparameter';
import promptAction from '@ohos.promptAction';
import { LogUtil } from '@ohos/settings.common/src/main/ets/utils/LogUtil';
import { EventBus } from '@ohos/settings.common/src/main/ets/framework/common/EventBus';
import {
  ComponentControl,
  CompCtrlParam,
  SettingBaseModel,
} from '@ohos/settings.common/src/main/ets/framework/model/SettingBaseModel';
import {
  ItemResultType,
} from '@ohos/settings.common/src/main/ets/framework/model/SettingItemModel';
import {
  notifyCompStateChange,
  SettingResultState,
  SettingStateType,
  SettingToggleState,
  SettingBaseState,
  SettingLayoutState,
  SettingTextState
} from '@ohos/settings.common/src/main/ets/framework/model/SettingStateModel';
import { HiSysEventUtil } from '@ohos/settings.common/src/main/ets/systemEvent/HiSysEventUtil';
import { AirPlaneUtils } from '@ohos/settings.common/src/main/ets/utils/AirPlaneUtils';
import { SettingsDataUtils } from '@ohos/settings.common/src/main/ets/utils/SettingsDataUtils';
import {
  NUMBER_OPEN,
  NUMBER_CLOSE,
  WIRELESS_ANTI_THEFT_KEY,
  SWITCH_ON_VAL,
} from '@ohos/settings.common/src/main/ets/utils/Consts';
import { HiSysWIFIStateException } from '@ohos/settings.common/src/main/ets/systemEvent/ExceptionEventConsts';
import { HiSysWlanEventGroup } from '@ohos/settings.common/src/main/ets/systemEvent/BehaviorEventConsts';
import { EventResultConsts } from '@ohos/settings.common/src/main/ets/systemEvent/EventResultConsts';
import { MASK_OPACITY, FULL_OPACITY } from '@ohos/settings.common/src/main/ets/constant/ViewConstant';
import { SystemParamUtil } from '@ohos/settings.common/src/main/ets/utils/SystemParamUtil';
import { EDM_FORCE_OPEN_WIFI } from '@ohos/settings.common/src/main/ets/constant/EDMConstant';
import { ResourceUtil } from '@ohos/settings.common/src/main/ets/utils/ResourceUtil';
import { ToastUtil } from '@ohos/settings.common/src/main/ets/utils/ToastUtil';
import { WifiState } from '../../model/WifiModel';
import { WifiUtils } from '../../WifiUtils';
import { WifiMenuManager } from '../../WifiMenuManager';

/* instrument ignore file */
const TAG = 'WifiSwitchController: ';
const INACTIVE: number = WifiState.INACTIVE;
const ACTIVE: number = WifiState.ACTIVE;
const ACTIVATING: number = WifiState.ACTIVATING;
const DEACTIVATING: number = WifiState.DEACTIVATING;
const WIFI_TOGGLE_SWITCH_DELAY: number = 200;
const SWITCH_DELAY: number = 500;
const CHANGE_WIFI_SWITCH: string = 'change_wifi_switch';

/**
 * Wlan首页 WLAN列表开关
 *
 */
export class WifiSwitchController implements ComponentControl {
  public currentState: number | null = null;
  public taskTimerId: number | null = null;
  // 0: inactive, 1: active, 2: activating, 3: deactivating
  public targetState: number | null = null;
  public switchTimerId: number | null = null;
  // 应用是否被管控
  public isChecked: boolean = true;
  public onClick?: (component: SettingBaseModel) => void = undefined;
  // 无线防盗标志位
  private isWirelessAntiTheft: boolean = false;
  private isForceOpenWifi: boolean = false;
  private onPageShowCallBack = () => {
    this.onPageShow({id: '' });
  }

  private onPageShowHideBack = () => {
    this.onPageHide({id: '' });
  }

  private compId: string = '';
  public onWifiStateChange = (state: number): void => {
    LogUtil.info(`${TAG} wifi state change : ${state}`);
    this.currentState = state;
    if (this.taskTimerId !== null) {
      // 用户点击，切换任务中
      AppStorage.setOrCreate('WifiStateIsOn', this.currentState === ACTIVE ? true : false);
      this.updateToTargetState(SWITCH_DELAY);
    } else {
      // 外部切换事件接收
      if (this.currentState !== ACTIVE && this.currentState !== INACTIVE) {
        // 中间态，切换中
        return;
      }
      this.updateTargetStateValue(this.currentState);
      this.setChecked(this.currentState === ACTIVE ? true : false);
      AppStorage.setOrCreate('WifiStateIsOn', this.currentState === ACTIVE ? true : false);
    }
  }
  private onToggleChange = (state: SettingToggleState) => {
    LogUtil.info(`${TAG} onToggleChange ${state.state}`);
    if (!this.handleCheckedChange(state.state)) {
      LogUtil.info(`${TAG} handleCheckedChange fail`);
      return false;
    }
    this.isChecked = state.state;
    return true;
  }

  init(param?: object | undefined): void {
    if (!param) {
      LogUtil.info(`${TAG} init failed, param is empty.`);
      return;
    }
    // 初始化时更新按钮状态，防止存在默认值true导致有切换动效
    this.isChecked = WifiUtils.isWifiActive();
    this.updateCheckedState(this.isChecked);
    LogUtil.info(`${TAG} init`);
    WifiUtils.wifiStateChangeOn(TAG, this.onWifiStateChange);
    this.compId = (param as CompCtrlParam).compId;
    EventBus.getInstance().on(`${this.compId}.toggle`, this.onToggleChange);
    // 无线防盗相关
    this.setOnAllowChanged();
    this.getWirelessAntiTheftState().then(res => {
      this.isWirelessAntiTheft = res;
    });
    SettingsDataUtils.registerKeyObserver(WIRELESS_ANTI_THEFT_KEY, async () => {
      const newIsWirelessAntiTheft = await this.getWirelessAntiTheftState();
      LogUtil.info(`${TAG} oldState:${this.isWirelessAntiTheft} newState:${newIsWirelessAntiTheft}`);
      if (this.isWirelessAntiTheft !== newIsWirelessAntiTheft) {
        this.isWirelessAntiTheft = newIsWirelessAntiTheft;
      }
    });
    if (WifiMenuManager.isExternalNetworkStage()) {
      this.updateWifiManageStatus();
      this.updateStatus(this.isChecked);
      WifiUtils.publishEnterWlanPageEvent(true);
    }
    EventBus.getInstance().on('ExternalNetworkPagePageShow', this.onPageShowCallBack);
    EventBus.getInstance().on('ExternalNetworkPagePageHide', this.onPageShowHideBack);
  }

  private setEDMWifiSwitchState(): void {
    let isForceOpenWifiByEdm = SystemParamUtil.getParam(EDM_FORCE_OPEN_WIFI, 'false') === 'true';
    if (this.isForceOpenWifi === isForceOpenWifiByEdm) {
      return;
    }
    this.isForceOpenWifi = isForceOpenWifiByEdm;
    this.onClick = this.isForceOpenWifi ? (() => {
      ToastUtil.handleMultiToast(ResourceUtil.getStringSync($r('app.string.reset_factory_disabled_toast')),
        ToastUtil.SHORT_DURATION);
    }) : undefined;
    notifyCompStateChange(this.compId,
      new Map<SettingStateType, SettingBaseState>([
        [SettingStateType.STATE_TYPE_ITEM_TITLE,
          {
            opacity: this.isForceOpenWifi ? MASK_OPACITY : FULL_OPACITY
          } as SettingTextState]
      ]));
  }

  destroy(): void {
    LogUtil.info(`${TAG} destroy`);
    SettingsDataUtils.unregisterKeyObserver(WIRELESS_ANTI_THEFT_KEY);
    WifiUtils.wifiStateChangeOff(TAG, this.onWifiStateChange);
    EventBus.getInstance().detach(`${this.compId}.toggle`, this.onToggleChange);
    EventBus.getInstance().detach('ExternalNetworkPagePageShow', this.onPageShowCallBack);
    EventBus.getInstance().detach('ExternalNetworkPagePageHide', this.onPageShowHideBack);
  }

  onPageShow(component: SettingBaseModel): void {
    LogUtil.info(`${TAG} onPageShow`);
    this.setEDMWifiSwitchState();
    this.updateWifiManageStatus();
    this.updateStatus();
    WifiUtils.publishEnterWlanPageEvent(true);
  }

  onPageHide(component: SettingBaseModel): void {
    LogUtil.info(`${TAG} onPageHide`);
    WifiUtils.publishEnterWlanPageEvent(false);
  }

  /**
   * 获取当前系统设置中的无线防盗,默认false
   */
  private async getWirelessAntiTheftState(): Promise<boolean> {
    // 获取当前系统设置中的允许休眠时通知开关的状态,默认false
    const wirelessAntiTheftState: string =
      await SettingsDataUtils.getSettingsDataAsync(WIRELESS_ANTI_THEFT_KEY, NUMBER_CLOSE);
    LogUtil.info(`${TAG} getWirelessAntiTheftState. wirelessAntiTheftState:${wirelessAntiTheftState}`);
    return wirelessAntiTheftState === NUMBER_OPEN;
  }

  /**
   * 初始化的时候通过箭头函数把onAllowChanged给组件 锁定this的作用域
   */
  private setOnAllowChanged(): void {
    notifyCompStateChange(this.compId, new Map<SettingStateType, SettingResultState>(
      [[SettingStateType.STATE_TYPE_ITEM_RESULT, {
        type: ItemResultType.RESULT_TYPE_TOGGLE,
        result: {
          state: this.isChecked,
          onAllowChanged: (isOn: boolean) => {
            LogUtil.info(`${TAG} onAllowChanged. isWirelessAntiTheft:${this.isWirelessAntiTheft} isOn:${isOn}`);
            // 无线防盗状态下 不可关闭
            if (this.isWirelessAntiTheft && !isOn) {
              try {
                promptAction.showToast({
                  message: $r('app.string.wireless_anti_theft_tip'),
                  duration: 2000
                });
              } catch (error) {
                LogUtil.error(`${TAG} showToast catch error. code:${error?.code} message:${error?.message}`);
              };
              return false;
            }
            return true;
          },
        },
      } as SettingResultState]]
    ));
  }

  protected updateCheckedState(isSwitchChecked?: boolean): boolean {
    let isChecked: boolean = isSwitchChecked ?? false;
    if (isSwitchChecked === undefined) {
      isChecked = WifiUtils.isWifiActive();
    }
    this.currentState = isChecked ? ACTIVE : INACTIVE;
    LogUtil.info(`${TAG} updateCheckedState : ${isChecked}`);
    this.updateTargetStateValue(this.currentState);
    return isChecked;
  }

  protected handleCheckedChange(isChecked: boolean): boolean {
    LogUtil.info(`${TAG} handleCheckedChange isChecked:${isChecked}`);
    if (isChecked === this.isChecked) {
      LogUtil.info(`${TAG} handleCheckedChange isChecked not change : ${isChecked}`);
      return false;
    }

    HiSysEventUtil.reportDefaultBehaviorEventByUE(HiSysWlanEventGroup.WIFI_SWITCH,
      isChecked ? EventResultConsts.SWITCH_ON : EventResultConsts.SWITCH_OFF);
    this.targetState = isChecked ? ACTIVE : INACTIVE;
    return this.startTask();
  }

  private updateWifiManageStatus(): void {
    // 设置按钮启用情况，与被管控情况相反
    this.setToggleState(this.isForceOpenWifi ? false : WifiUtils.isWifiEnabled());
  }

  private setToggleState(isToggleEnable: boolean): void {
    notifyCompStateChange(this.compId,
      new Map<SettingStateType, SettingResultState>([[SettingStateType.STATE_TYPE_ITEM_RESULT,
        {
          type: ItemResultType.RESULT_TYPE_TOGGLE,
          result: {
            state: this.isChecked,
            enabled: isToggleEnable,
          },
        } as SettingResultState]]));
  }

  private updateTargetStateValue(state: number): void {
    this.targetState = state;
    LogUtil.info(`${TAG} updateTargetStateValue publishDataChange targetState:${this.targetState}`);
  }

  public updateToTargetState(delay: number = 0): boolean {
    if (this.taskTimerId === null) {
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
        HiSysEventUtil.reportSwitchEvent(CHANGE_WIFI_SWITCH, 'on');
      } else if (this.currentState === INACTIVE) {
        HiSysEventUtil.reportSwitchEvent(CHANGE_WIFI_SWITCH, 'off');
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
      LogUtil.info(`${TAG} switchTimerId publishDataChange targetState:${this.targetState}`);
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
    if (WifiUtils.isWifiActive()) {
      LogUtil.info(`${TAG} wifi is already active`);
      return true;
    }
    let isSuccess: boolean = WifiUtils.enableWifi();
    LogUtil.info(`${TAG} enable wifi result is : ${isSuccess}`);
    return isSuccess;
  }

  private disableWifi(): boolean {
    if (!WifiUtils.isWifiActive()) {
      LogUtil.info(`${TAG} wifi is already inactive`);
      return true;
    }
    let isSuccess: boolean = WifiUtils.disableWifi();
    LogUtil.info(`${TAG} disable wifi result is : ${isSuccess}`);
    return isSuccess;
  }

  private updateStatus(isSwitchChecked?: boolean): void {
    LogUtil.info(`${TAG} updateStatus`);
    let isChecked = this.updateCheckedState(isSwitchChecked);
    this.setChecked(isChecked);
  }

  private setChecked(isChecked: boolean): void {
    if (this.isChecked === isChecked) {
      LogUtil.warn(`${TAG} setChecked failed.`);
      return;
    }
    this.isChecked = isChecked;
    LogUtil.info(`${TAG} setChecked, refresh : ${this.isChecked}`);
    notifyCompStateChange(this.compId, new Map<SettingStateType, SettingResultState>(
      [[SettingStateType.STATE_TYPE_ITEM_RESULT, {
        type: ItemResultType.RESULT_TYPE_TOGGLE,
        result: {
          state: isChecked
        }
      } as SettingResultState]]
    ));
  }
}
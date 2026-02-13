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

import access from '@ohos.bluetooth.access';
import promptAction from '@ohos.promptAction';
import { HiSysEventUtil } from '@ohos/settings.common/src/main/ets/systemEvent/HiSysEventUtil';
import { HiSysBluetoothEventGroup } from '@ohos/settings.common/src/main/ets/systemEvent/BehaviorEventConsts';
import { HiSysBluetoothStateException } from '@ohos/settings.common/src/main/ets/systemEvent/ExceptionEventConsts';
import {
  CompCtrlParam,
  ComponentControl,
  SettingBaseModel
} from '@ohos/settings.common/src/main/ets/framework/model/SettingBaseModel';
import { EventBus } from '@ohos/settings.common/src/main/ets/framework/common/EventBus';
import {
  notifyCompStateChange,
  SettingBaseState,
  SettingResultState,
  SettingStateType,
  SettingTextState,
  SettingToggleState,
  SettingLayoutState
} from '@ohos/settings.common/src/main/ets/framework/model/SettingStateModel';
import { ItemResultType } from '@ohos/settings.common/src/main/ets/framework/model/SettingItemModel';
import { BluetoothUtils } from '@ohos/settings.common/src/main/ets/utils/BluetoothUtils';
import { LogUtil } from '@ohos/settings.common/src/main/ets/utils/LogUtil';
import {
  NUMBER_OPEN,
  NUMBER_CLOSE,
  WIRELESS_ANTI_THEFT_KEY,
  NavEntryKey,
} from '@ohos/settings.common/src/main/ets/utils/Consts';
import { CommonUtils } from '@ohos/settings.common/src/main/ets/utils/CommonUtils';
import { SettingsDataUtils } from '@ohos/settings.common/src/main/ets/utils/SettingsDataUtils';
import { MASK_OPACITY, FULL_OPACITY } from '@ohos/settings.common/src/main/ets/constant/ViewConstant';
import { SystemParamUtil } from '@ohos/settings.common/src/main/ets/utils/SystemParamUtil';
import { EDM_PROHIBIT_BLUETOOTH } from '@ohos/settings.common/src/main/ets/constant/EDMConstant';
import { ResourceUtil } from '@ohos/settings.common/src/main/ets/utils/ResourceUtil';
import { ToastUtil } from '@ohos/settings.common/src/main/ets/utils/ToastUtil';
import { BluetoothAdapter, BluetoothStateChangeListener } from '../BluetoothAdapter';

/* instrument ignore file */
const TAG: string = 'BluetoothSwitchController : ';
const SWITCH_MAX_TIME: number = 5000; // 5s
const SWITCH_DELAY: number = 500;
const BT_TOGGLE_SWITCH_DELAY: number = 50;
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
export class BluetoothSwitchController implements ComponentControl, BluetoothStateChangeListener {
  public tag: string = 'BluetoothSwitchController: ';
  public targetState: number | undefined = undefined;
  public currentState: number | undefined = undefined;
  public taskTimerId: number | null = null;
  public onClick?: (component: SettingBaseModel) => void = undefined;
  public switchTimerId: number | null = null;
  public compId: string = '';
  private isChecked: boolean = false;
  private isProhibitBluetooth: boolean = false;
  // 无线防盗标志位
  private isWirelessAntiTheft: boolean = false;
  private toggleStateChangeEventCallback = (toggleState: SettingToggleState) => {
    if (!toggleState) {
      LogUtil.error(`${TAG} toggleModel is invalid`);
      return;
    }
    this.handleCheckedChange(toggleState.state);
  };

  init(compParam: CompCtrlParam): void {
    LogUtil.info(`${this.tag} init`);
    this.compId = compParam?.compId;
    this.updateCheckedState();
    this.refreshUi();
    this.registerDataChange();
    // 监听界面开关状态变化
    EventBus.getInstance().on(`${this.compId}.toggle`, this.toggleStateChangeEventCallback);
    // 无线防盗相关
    this.setOnAllowChanged();
    this.isWirelessAntiTheft = this.getWirelessAntiTheftState();
    SettingsDataUtils.registerKeyObserver(WIRELESS_ANTI_THEFT_KEY, () => {
      const newIsWirelessAntiTheft = this.getWirelessAntiTheftState();
      LogUtil.info(`${TAG} oldState:${this.isWirelessAntiTheft} newState:${newIsWirelessAntiTheft}`);
      if (this.isWirelessAntiTheft !== newIsWirelessAntiTheft) {
        this.isWirelessAntiTheft = newIsWirelessAntiTheft;
      }
    });
  }

  onPageShow(): void {
    LogUtil.info(`${this.tag} onPageShow`);
    this.updateCheckedState();
    this.refreshUi();
    this.setEDMBluetoothSwitchState();
  }

  private setEDMBluetoothSwitchState(): void {
    let isDisableBluetoothByEdm = SystemParamUtil.getParam(EDM_PROHIBIT_BLUETOOTH, 'false') === 'true';
    if (this.isProhibitBluetooth === isDisableBluetoothByEdm) {
      return;
    }
    this.isProhibitBluetooth = isDisableBluetoothByEdm;
    this.onClick = this.isProhibitBluetooth ? (() => {
      ToastUtil.handleMultiToast(ResourceUtil.getStringSync($r('app.string.reset_factory_disabled_toast')),
        ToastUtil.SHORT_DURATION);
    }) : undefined;
    notifyCompStateChange(this.compId,
      new Map<SettingStateType, SettingBaseState>([
        [SettingStateType.STATE_TYPE_ITEM_TITLE,
          {
            opacity: this.isProhibitBluetooth ? MASK_OPACITY : FULL_OPACITY
          } as SettingTextState],
        [SettingStateType.STATE_TYPE_ITEM_RESULT, {
          type: ItemResultType.RESULT_TYPE_TOGGLE,
          result: {
            enabled: !this.isProhibitBluetooth
          } as SettingToggleState
        } as SettingResultState]
     ]));
  }

  private refreshUi(): void {
    notifyCompStateChange(`${this.compId}`, new Map<SettingStateType, SettingBaseState>(
      [[SettingStateType.STATE_TYPE_ITEM_RESULT, {
        type: ItemResultType.RESULT_TYPE_TOGGLE,
        result: { state: this.getChecked() } as SettingToggleState
      } as SettingResultState]]
    ));
  }

  destroy(): void {
    LogUtil.info(`${this.tag} destroy`);
    EventBus.getInstance().detach(`${this.compId}.toggle`, this.toggleStateChangeEventCallback);
    if (CommonUtils.isPageExist(NavEntryKey.BLUETOOTH_ENTRY)) {
      LogUtil.info(`${this.tag} the page exist, not unregister`);
      return;
    }

    this.unRegisterDataChange();
    SettingsDataUtils.unregisterKeyObserver(WIRELESS_ANTI_THEFT_KEY);
  }

  /**
   * 获取当前系统设置中的无线防盗,默认false
   */
  private getWirelessAntiTheftState(): boolean {
    // 获取当前系统设置中的允许休眠时通知开关的状态,默认false
    const wirelessAntiTheftState: string = SettingsDataUtils.getSettingsData(WIRELESS_ANTI_THEFT_KEY, NUMBER_CLOSE);
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
              }
              return false;
            }
            return true;
          },
        },
      } as SettingResultState]]
    ));
  }

  getListenKey(): string {
    return 'Bluetooth_Switch_Controller';
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
      this.refreshUi();
    }
  }

  private updateCheckedState(): void {
    this.isChecked = BluetoothUtils.isBluetoothStateOn(BluetoothAdapter.getInstance().currentState);
    this.setChecked(this.isChecked);
    this.currentState = this.isChecked ? ACTIVE : INACTIVE;
    LogUtil.info(`${TAG} updateCheckedState : ${this.isChecked}`);
    this.updateTargetStateValue(this.currentState);
  }

  private handleCheckedChange(isChecked: boolean): boolean {
    LogUtil.info(`${TAG} handleCheckedChange, isChecked: ${isChecked}, this.getChecked(): ${this.getChecked()}`);
    if (isChecked === this.getChecked()) {
      LogUtil.info(`${this.tag} handleCheckedChange isChecked not change : ${isChecked}`);
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
      this.refreshUi();
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
    this.changeBluetoothState().then((data: boolean) => {
      if (data) {
        LogUtil.info(`${TAG} enable or disable success, currentState ${this.currentState}`);
        // 刷新设备名称
        EventBus.getInstance().emit(`Setting.Bluetooth.SwitchGroup.footer.update`);
      } else {
        // 切换失败
        LogUtil.error(`${TAG} enable or disable failed`);
        this.stopTask();
        this.setChecked(BluetoothUtils.isBluetoothStateOn(BluetoothAdapter.getInstance().currentState));
        this.refreshUi();
      }
    })
  }

  private async changeBluetoothState(): Promise<boolean> {
    this.targetState = this.targetState as number;
    this.currentState = BluetoothUtils.isBluetoothStateOn(this.targetState as number) ? ACTIVATING : DEACTIVATING;
    if (BluetoothUtils.isBluetoothStateOn(this.targetState)) {
      return await this.enableBluetooth()
    } else {
      return this.disableBluetooth();
    }
  }

  private startTask(): boolean {
    this.stopTask();
    LogUtil.info(`${TAG} task start, currentState ${this.currentState}`);
    this.taskTimerId = setTimeout(() => {
      this.taskTimerId = null;
      this.switchTimerId = null;
      LogUtil.error(`${TAG} switch task timeout`);
      HiSysEventUtil.reportDefaultFaultEvent(HiSysBluetoothStateException.EVENT_NAME,
        HiSysBluetoothStateException.BLUETOOTH_STATE_CHANGE_TIMEOUT);
      this.setChecked(BluetoothUtils.isBluetoothStateOn(BluetoothAdapter.getInstance().currentState));
      this.refreshUi();
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

  private async enableBluetooth(): Promise<boolean> {
    if (BluetoothUtils.isBluetoothStateOn(BluetoothAdapter.getInstance().currentState)) {
      LogUtil.info(TAG + 'bluetooth is already enable');
      return true;
    }
    let isSuccess: boolean = await BluetoothUtils.enableBlueToothAsync();
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

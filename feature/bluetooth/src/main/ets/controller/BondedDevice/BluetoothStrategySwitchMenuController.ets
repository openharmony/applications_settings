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

import constant from '@ohos.bluetooth.constant';
import bluetooth from '@ohos.bluetooth';
import {
  CompCtrlParam,
  ComponentControl,
} from '@ohos/settings.common/src/main/ets/framework/model/SettingBaseModel';
import { EventBus } from '@ohos/settings.common/src/main/ets/framework/common/EventBus';
import { HiSysEventUtil } from '@ohos/settings.common/src/main/ets/systemEvent/HiSysEventUtil';
import { HiSysBluetoothEventGroup } from '@ohos/settings.common/src/main/ets/systemEvent/BehaviorEventConsts';
import { LogUtil } from '@ohos/settings.common/src/main/ets/utils/LogUtil';
import { BluetoothUtils } from '@ohos/settings.common/src/main/ets/utils/BluetoothUtils';
import { CheckEmptyUtils } from '@ohos/settings.common/src/main/ets/utils/CheckEmptyUtils';
import {
  BluetoothAdapter,
  BluetoothProfile,
  BluetoothProfileStateChangeListener,
  BluetoothStateChangeListener,
  ConnectionProfile,
  ConnectionStrategy,
} from '../../BluetoothAdapter';
import { BluetoothDevice, ProfileConnectionState, ProfileId, StateChangeParam } from '../../model/BluetoothModel';
import { notifyCompStateChange, SettingResultState, SettingStateType } from '@ohos/settings.common/src/main/ets/framework/model/SettingStateModel';
import { ItemResultType } from '@ohos/settings.common/src/main/ets/framework/model/SettingItemModel';

/* instrument ignore file */
enum SummaryStatus {
  OPERATING = 'operating',
  DONE = 'done',
}

const FRESH_TITLE_TIME_OUT: number = 200;
const FRESH_PROFILE_TIME_OUT: number = 1000;

/**
 * 开关菜单控制器
 *
 * @since 2022-03-21
 */
export class BluetoothStrategySwitchMenuController implements ComponentControl, BluetoothStateChangeListener,
  BluetoothProfileStateChangeListener {
  public tag: string = 'BluetoothStrategySwitchMenuController: ';
  public isChecked: boolean = false;
  public summary?: ResourceStr = '';
  public summaryFontColor: Resource = $r('sys.color.font_secondary');
  public titleFontColor: Resource = $r('sys.color.font_primary');
  public selectedColor: Resource = $r('app.color.default_switch_color');
  public isToggleEnable: boolean = true;
  public device?: BluetoothDevice;
  public connectProfile: BluetoothProfile | null = null;
  public connectionProfile: ConnectionProfile | null = null;
  public lastSummaryStatus: SummaryStatus | null = null;
  public isRequestFocus: boolean = true;
  public refreshFromOther: boolean = false;
  public profileMap: Map<string, Map<ProfileId, ProfileConnectionState>> = new Map();
  public compId?: string;
  public isShowDivider: boolean = true;
  private toggleStateChangeCallback = (isOn: boolean) => {
    LogUtil.info(`${this.tag} receive toggle change ${isOn}, ${this.isChecked}`);
    if (isOn === this.isChecked) {
      return;
    }
    if (isOn) {
      BluetoothAdapter.getInstance().connectProfile(this.device?.deviceId!, this.getProfileId())
    } else {
      BluetoothAdapter.getInstance().disconnectProfile(this.device?.deviceId, this.getProfileId())
    }
    this.onToggleChange(isOn);
  };
  private toggleStateChangeFromOtherProfileCallback = (profileId: ProfileId, status: boolean) => {
    if (!this.device) {
      return;
    }

    LogUtil.info(`${this.tag} onDataChange , profileId: ${profileId}, status: ${status}`);
    this.isRequestFocus = false;
    this.refreshFromOther = profileId !== this.getProfileId();
    if (status !== undefined) {
      if (profileId === this.getProfileId()) {
        this.isRequestFocus = true;
      }
      this.setToggleMenuStatus(status);
    } else {
      if (this.isChecked) {
        return;
      }
      if (this.device && profileId !== this.getProfileId()) {
        this.setSummary($r('app.string.bt_connection_strategy_summary'));
        this.updateToggleStatus(bluetooth.getState(),
          this.getConnectionProfile()?.getConnectionState(this.device!.deviceId as string));
      }
    }
  };

  constructor(device: BluetoothDevice) {
    this.device = device;
  }

  getListenKey(): string {
    return 'Bluetooth_Strategy_Switch_Menu_Controller';
  }

  init(compParam: CompCtrlParam): void {
    this.registerDataChange();
    this.updateStatus();
    EventBus.getInstance().on(`${this.compId}.toggle`, this.toggleStateChangeCallback);
    EventBus.getInstance().on(`Setting.BondedDevice.profile_group.${this.device?.deviceId}.toggle`, this.toggleStateChangeFromOtherProfileCallback);

    if (!this.isShowDivider) {
      EventBus.getInstance().emit(`${this.compId}.divider`, this.isShowDivider);
    }
  }

  destroy(): void {
    this.unRegisterDataChange();
    EventBus.getInstance().detach(`${this.compId}.toggle`, this.toggleStateChangeCallback);
    EventBus.getInstance().detach(`Setting.BondedDevice.profile_group.${this.device?.deviceId}.toggle`, this.toggleStateChangeFromOtherProfileCallback);
  }

  getConnectionProfile(): BluetoothProfile | null | undefined {
    return BluetoothAdapter.getInstance().profileManager?.profiles?.get(this.getProfileId()) as BluetoothProfile;
  }

  onBluetoothStateChange(state: number): void {
    LogUtil.info(`${this.tag} onBluetoothStateChange, state :${state}`);
    this.updateToggleStatus(state, BluetoothUtils.isBluetoothDiscoveryOn(state) ?
    this.getConnectionProfile()?.getConnectionState(this.device!.deviceId as string) :
    ProfileConnectionState.STATE_DISCONNECTED);
  }

  onBluetoothProfileStateChange(profileId: ProfileId, stateChangeParam: StateChangeParam): void {
    if (!stateChangeParam) {
      return;
    }
    if (this.profileMap.has(stateChangeParam.deviceId)) {
      let deviceProfileMap: Map<ProfileId, ProfileConnectionState> | undefined =
        this.profileMap.get(stateChangeParam.deviceId);
      if (deviceProfileMap?.get(profileId)?.valueOf() === stateChangeParam.state.valueOf()) {
        LogUtil.info(`${this.tag} onBluetoothProfileStateChange , profileStateChange has changed`);
        return;
      }
    }
    if (this.profileMap.has(stateChangeParam.deviceId)) {
      let deviceProfileMap: Map<ProfileId, ProfileConnectionState> | undefined =
        this.profileMap.get(stateChangeParam.deviceId);
      if (deviceProfileMap) {
        deviceProfileMap.set(profileId, stateChangeParam.state);
      } else {
        deviceProfileMap = new Map();
        deviceProfileMap.set(profileId, stateChangeParam.state);
        this.profileMap.set(stateChangeParam.deviceId, deviceProfileMap);
      }
    } else {
      let deviceProfileMap: Map<ProfileId, ProfileConnectionState> = new Map();
      deviceProfileMap.set(profileId, stateChangeParam.state);
      this.profileMap.set(stateChangeParam.deviceId, deviceProfileMap);
    }
    LogUtil.info(`${this.tag} onBluetoothProfileStateChange, profileId: ${profileId},state :${stateChangeParam.state}, this.getProfileId():${this.getProfileId()}`);
    if (profileId === this.getProfileId()) {
      this.refreshFromOther = false;
      this.updateToggleStatus(bluetooth.getState(), stateChangeParam.state);
    }
  }

  onConnectResult(deviceId: string, result: number, isSuccess: boolean): void {
  }

  protected getProfileId(): ProfileId {
    return ProfileId.PROFILE_A2DP_SOURCE;
  }

  protected getConnectProfileId(): constant.ProfileId {
    return constant.ProfileId.PROFILE_HID_HOST;
  }

  getProfileData(): void {
    LogUtil.info(`${this.tag} getProfileData`);
    if (!this.device) {
      LogUtil.error(`${this.tag} get device is null`);
    }
    this.connectProfile = this.device?.getConnectableProfiles()?.get(this.getProfileId()) as BluetoothProfile;
  }

  updateStatus(): void {
    LogUtil.info(`${this.tag} updateStatus`);
    this.getProfileData();
    let state: number = bluetooth.getState();
    if (!this.device) {
      return;
    }
    let connectionState: ProfileConnectionState | undefined;
    try {
      connectionState = this.getConnectionProfile()?.getConnectionState(this.device!.deviceId as string);
    } catch (err) {
      LogUtil.error(`${this.tag} getConnectionState fail, err.code: ${err?.code}, err.message: ${err?.message}`);
    }

    if (BluetoothUtils.isBluetoothStateOff(state) || connectionState === ProfileConnectionState.STATE_DISCONNECTED) {
      LogUtil.info(`${this.tag} bt is off or disconnected`);
      this.setChecked(false);
      this.setSummary();
    } else if (BluetoothUtils.isBluetoothDiscoveryOn(state) &&
      connectionState === ProfileConnectionState.STATE_CONNECTED) {
      let isChecked = this.device?.connectionStatusMap.get(this.getProfileId()) !==
        ConnectionStrategy.CONNECTION_STRATEGY_FORBIDDEN;
      LogUtil.info(`${this.tag} bt is on and connected, isChecked: ${isChecked}`);
      this.setChecked(isChecked);
      if (this.isChecked) {
        this.setSelectorColor($r('app.color.profile_switch_color'));
      }
      this.setSummary();
    } else {
      LogUtil.info(`${this.tag} else branch: ${connectionState}`);
      if (connectionState !== ProfileConnectionState.STATE_DISCONNECTING) {
        this.setSummary($r('app.string.bt_connection_strategy_summary'));
      }
    }
  }

  protected registerDataChange(): void {
    BluetoothAdapter.getInstance().registerStateChangeListener(this);
    BluetoothAdapter.getInstance().registerProfileStateChangeListener(this);
  }

  protected unRegisterDataChange(): void {
    BluetoothAdapter.getInstance().unRegisterStateChangeListener(this);
    BluetoothAdapter.getInstance().unRegisterProfileStateChangeListener(this);
  }

  /**
   * 返回开关的实时状态
   */
  protected updateToggleStatus(state: number, profileState?: ProfileConnectionState, isInit: boolean = false): void {
    if (CheckEmptyUtils.isEmpty(this.device)) {
      return;
    }
    let connectionState: ProfileConnectionState | undefined = profileState ??
    this.getConnectionProfile()?.getConnectionState(this.device?.deviceId as string);
    LogUtil.info(`${this.tag} updateCheckedState start, blueState: ${state} , connectionState : ${connectionState}`);
    try {
      if (BluetoothUtils.isBluetoothStateOff(state) || connectionState === ProfileConnectionState.STATE_DISCONNECTED) {
        LogUtil.info(`${this.tag} updateToggleStatus false, ProfileId ${this.getConnectProfileId()}, isOn: ${BluetoothUtils.isBluetoothStateOn(state)}`);
        this.setChecked(false);
        this.setSummary();
        if (!this.refreshFromOther) {
          this.refreshOtherSwitchStatus(true);
        }
        this.refreshFromOther = false;
        this.setToggleMenuStatus(true);
      } else if (BluetoothUtils.isBluetoothDiscoveryOn(state) &&
        connectionState === ProfileConnectionState.STATE_CONNECTED) {
        this.updateToggleStatusWhenConnected(isInit);
      } else {
        if (connectionState !== ProfileConnectionState.STATE_DISCONNECTING) {
          this.setSummary($r('app.string.bt_connection_strategy_summary'));
        }
      }
      LogUtil.info(`${this.tag} refreshUi isChecked: ${this.isChecked} `);
    } catch (err) {
      LogUtil.info(`${this.tag} updateCheckedState error ${err?.code}, ${err?.message}`)
    }
  }

  private updateToggleStatusWhenConnected(isInit: boolean): void {
    let timeOut: number = 0;
    if (!isInit) {
      timeOut = FRESH_PROFILE_TIME_OUT;
    }
    setTimeout(() => {
      (this.connectProfile as BluetoothProfile).getConnectionStrategy((this.device as BluetoothDevice).deviceId)
        .then((isCheck) => {
          this.updateToggleStatusTimeout(isCheck);
        })
    }, timeOut);
  }

  private updateToggleStatusTimeout(isCheck: ConnectionStrategy): void {
    LogUtil.info(`${this.tag} updateToggleStatusTimeout connectionStatusMap status: ${isCheck}`);
    if (!this.isChecked && isCheck === ConnectionStrategy.CONNECTION_STRATEGY_ALLOWED) {
      if (!this.refreshFromOther) {
        this.refreshALLSwitchStatus();
      }
    }
    let state: ProfileConnectionState | undefined =
      this.getConnectionProfile()?.getConnectionState(this.device?.deviceId as string);
    LogUtil.info(`${this.tag} updateToggleStatusTimeout recheck connection status: ${state}`);
    this.setChecked(isCheck === ConnectionStrategy.CONNECTION_STRATEGY_ALLOWED &&
      state === ProfileConnectionState.STATE_CONNECTED);
    if (this.isChecked) {
      this.setSelectorColor($r('app.color.profile_switch_color'));
    }
    this.setSummary();
    if (!this.refreshFromOther) {
      this.refreshOtherSwitchStatus(true);
    }
    this.refreshFromOther = false;
    this.setToggleMenuStatus(true);
  }

  setSelectorColor(resource: Resource): void {
    this.selectedColor = resource;
    EventBus.getInstance().emit(`${this.compId}.toggle.selectedColor`, resource);
  }

  setToggleMenuStatus(status: boolean): void {
    LogUtil.info(`${this.tag} setToggleMenuStatus ${status}`);
    if (!status) {
      this.setFontColor($r('app.color.color_E3E3E3_grey'));
      if (this.isChecked) {
        this.setSelectorColor($r('app.color.default_switch_color'));
      }
      this.setToggleState(false, this.isRequestFocus);
      this.resetRequestFocus();
      return;
    } else {
      this.setFontColor();
      this.setSelectorColor($r('app.color.profile_switch_color'));
      this.setToggleState(true, this.isRequestFocus);
      this.resetRequestFocus();
      return;
    }
  }

  setSummary(summaryMsg ?: Resource): void {
    LogUtil.info(`${this.tag} setSummary enter.`);
    if (summaryMsg) {
      if (this.lastSummaryStatus === SummaryStatus.OPERATING) {
        return;
      }

      this.summary = summaryMsg;
      EventBus.getInstance().emit(`${this.compId}.desp`, summaryMsg);
      this.setFontColor($r('app.color.color_E3E3E3_grey'));
      LogUtil.info(`${this.tag} setSummary is openning`);
      this.lastSummaryStatus = SummaryStatus.OPERATING;
      this.setToggleState(false, this.isRequestFocus);
      this.resetRequestFocus();
    } else {
      let timeOut: number = 0;
      if (this.lastSummaryStatus === SummaryStatus.OPERATING) {
        timeOut = FRESH_TITLE_TIME_OUT;
      }
      if (timeOut === 0) {
        this.freshCompletedStatus();
      } else {
        setTimeout(() => {
          this.freshCompletedStatus();
        }, timeOut);
      }
      LogUtil.info(`${this.tag} setSummary is done`);
    }
  }

  setToggleState(isToggleEnable: boolean, isRequestFocus: boolean = false): void {
    LogUtil.info(`${this.tag} setToggleState ${isToggleEnable}， ${this.isToggleEnable}`);
    if (this.isToggleEnable !== isToggleEnable) {
      this.isToggleEnable = isToggleEnable;
      LogUtil.info(`${this.tag} setToggleState, refresh : ${this.isToggleEnable}`);
      EventBus.getInstance().emit(`${this.compId}.toggle.enable`, this.isToggleEnable);

      // if (isToggleEnable) {
      //   LogUtil.info(`【调用栈】---走到了这里1------close---${this.getProfileId()}`)
      //   BluetoothAdapter.getInstance().connectProfile(this.device?.deviceId!, this.getProfileId())
      // } else {
      //   LogUtil.info(`【调用栈】---走到了这里2------close---${this.getProfileId()}`)
      //   BluetoothAdapter.getInstance().disconnectProfile(this.device?.deviceId, this.getProfileId())
      // }
      //关闭对应的协议
      // switch (this.compId) {
      //   case 'Setting.BondedDevice.profile_group.a2dp_device_key':
      //     if (isToggleEnable) {
      //       LogUtil.info(`走到了这里1------close---${this.getProfileId()}`)
      //       BluetoothAdapter.getInstance().connectProfile(this.device?.deviceId!, this.getProfileId())
      //     } else {
      //       LogUtil.info(`走到了这里1------close---${this.getProfileId()}`)
      //       BluetoothAdapter.getInstance().disconnectProfile(this.device?.deviceId, this.getProfileId())
      //     }
      //     break;
      //   case 'Setting.BondedDevice.profile_group.hfp_device_key':
      //     if (isToggleEnable) {
      //       LogUtil.info(`走到了这里2------close---${this.getProfileId()}`)
      //       BluetoothAdapter.getInstance().connectProfile(this.device?.deviceId!, this.getProfileId())
      //     } else {
      //       LogUtil.info(`走到了这里2------close---${this.getProfileId()}`)
      //       BluetoothAdapter.getInstance().disconnectProfile(this.device?.deviceId, this.getProfileId())
      //     }
      //     break;
      //   default :
      //     break;
      // }
    }
  }

  private freshCompletedStatus(): void {
    this.summary = this.isChecked ? $r('app.string.bt_connected_summary') : undefined;
    EventBus.getInstance().emit(`${this.compId}.desp`, this.summary);
    this.setFontColor();
    this.lastSummaryStatus = SummaryStatus.DONE;
    this.setToggleState(true, this.isRequestFocus);
    this.resetRequestFocus();
  }

  resetRequestFocus(): void {
    this.isRequestFocus = true;
  }

  setFontColor(fontColor?: Resource): void {
    LogUtil.info(`${this.tag} setFontColor enter`);
    if (fontColor) {
      this.summaryFontColor = fontColor;
      this.titleFontColor = fontColor;
      EventBus.getInstance().emit(`${this.compId}.title.fontColor`, fontColor);
      EventBus.getInstance().emit(`${this.compId}.desp.fontColor`, fontColor);
    } else {
      this.summaryFontColor = $r('sys.color.font_secondary');
      this.titleFontColor = $r('sys.color.font_primary');
      EventBus.getInstance().emit(`${this.compId}.title.fontColor`, $r('sys.color.font_primary'));
      EventBus.getInstance().emit(`${this.compId}.desp.fontColor`, $r('sys.color.font_secondary'));
    }
  }

  reportStrategySwitchChangeEvent(isOn: boolean): void {
    switch (this.getProfileId()) {
      case ProfileId.PROFILE_A2DP_SOURCE:
        HiSysEventUtil.reportDefaultBehaviorEvent(HiSysBluetoothEventGroup.A2DP_SWITCH_CHANGE, isOn ? 'on' : 'off');
        break;
      case ProfileId.PROFILE_HANDS_FREE_AUDIO_GATEWAY:
        HiSysEventUtil.reportDefaultBehaviorEvent(HiSysBluetoothEventGroup.HFP_SWITCH_CHANGE, isOn ? 'on' : 'off');
        break;
      default:
        break;
    }
  }

  protected onToggleChange(isOn: boolean): boolean {
    LogUtil.info(`${this.tag} onToggleChange ${isOn}, ${this.isChecked}`);
    if (isOn === this.isChecked) {
      return false;
    }
    if (!this.device) {
      return false;
    }
    this.reportStrategySwitchChangeEvent(isOn);
    if (!isOn) {
      if (BluetoothUtils.isBluetoothStateOff(bluetooth.getState()) ||
        this.getConnectionProfile()?.getConnectionState(this.device!.deviceId as string) ===
          ProfileConnectionState.STATE_DISCONNECTED) {
        LogUtil.info(`${this.tag} handleCheckedChange setCheck false , bluetooth is off or profile is not connected`);
        return false;
      }
    }
    if (isOn) {
      this.setSummary($r('app.string.bt_connection_strategy_summary'));
    } else {
      this.setToggleMenuStatus(false);
    }
    this.refreshOtherSwitchStatus(false);
    this.handleCheckedChange(isOn);
    return true;
  }

  /**
   * 刷新其他toggle的可使用状态
   */
  refreshOtherSwitchStatus(status: boolean): void {
    LogUtil.info(`${this.tag} refreshOtherSwitchStatus`);
    EventBus.getInstance().emit(`Setting.BondedDevice.profile_group.${this.device?.deviceId}.toggle`, this.getProfileId(), status);
  }

  /**
   * 返回开关的保存状态
   */
  getChecked(): boolean {
    LogUtil.info(`${this.tag} getChecked ${this.isChecked}`);
    return this.isChecked;
  }

  /**
   * 设置开关的状态
   */
  setChecked(isChecked: boolean): void {
    LogUtil.info(`${this.tag} setChecked ${isChecked}`);
    if (this.isChecked !== isChecked) {
      this.isChecked = isChecked;
      LogUtil.info(`${this.tag} setChecked, refresh : ${this.isChecked} compId: ${this.compId}`);
      notifyCompStateChange(this.compId ?? '',
        new Map<SettingStateType, SettingResultState>([[SettingStateType.STATE_TYPE_ITEM_RESULT,
          { type: ItemResultType.RESULT_TYPE_TOGGLE, result: { state: this.isChecked } } as SettingResultState]]))
    }
  }

  /**
   * 再设置完某一协议值后需要刷新其他开关的状态值，看是否需要联动打开
   */
  refreshALLSwitchStatus(): void {
    LogUtil.info(`${this.tag} refreshALLSwitchStatus`);
    EventBus.getInstance().emit(`Setting.BondedDevice.profile_group.${this.device?.deviceId}.toggle`, this.getProfileId(), undefined);
  }

  /**
   * 开关变化的回调
   */
  protected handleCheckedChange(isChecked: boolean): boolean {
    LogUtil.info(`${this.tag} handleCheckedChange ${isChecked}`);
    if (!this.device || !this.connectProfile) {
      return false;
    }
    this.setChecked(isChecked);
    try {
      this.connectProfile?.setConnectionStrategy(this.device.deviceId,
        isChecked ? ConnectionStrategy.CONNECTION_STRATEGY_ALLOWED : ConnectionStrategy.CONNECTION_STRATEGY_FORBIDDEN)
        .then(() => {
          (this.connectProfile as BluetoothProfile).getConnectionStrategy((this.device as BluetoothDevice).deviceId)
            .then((isCheck) => {
              LogUtil.info(`${this.tag} handleCheckedChange isCheck: ${isCheck}`);
              this.updateConnectAndToggleStatus(isCheck);
            })
        })
      return true;
    } catch (err) {
      LogUtil.error(`${this.tag} handleCheckedChange error:  ${err?.code}, ${err?.message}`);
      this.setChecked(!isChecked);
      return false;
    }
  }

  private updateConnectAndToggleStatus(isCheck: ConnectionStrategy): void {
    if (this.device) {
      this.device.addConnectionStatus(this.getProfileId(),
        isCheck ? ConnectionStrategy.CONNECTION_STRATEGY_ALLOWED : ConnectionStrategy.CONNECTION_STRATEGY_FORBIDDEN);
      this.updateToggleStatus(bluetooth.getState(),
        this.getConnectionProfile()?.getConnectionState(this.device!.deviceId as string));
    }
  }
}
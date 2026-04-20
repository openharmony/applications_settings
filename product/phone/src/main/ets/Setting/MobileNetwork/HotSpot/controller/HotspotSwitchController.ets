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
import sharing from '@ohos.net.sharing';
import wifiManager from '@ohos.wifiManager';
import { BusinessError } from '@ohos.base';
import emitter from '@ohos.events.emitter';
import CommonEventManager from '@ohos.commonEventManager';
import { AirPlaneUtils } from '@ohos/settings.common/src/main/ets/utils/AirPlaneUtils';
import {
  CompCtrlParam,
  ComponentControl,
  SettingBaseModel,
} from '@ohos/settings.common/src/main/ets/framework/model/SettingBaseModel';
import { LogUtil } from '@ohos/settings.common/src/main/ets/utils/LogUtil';
import { CommonEventHelper } from '@ohos/settings.common/src/main/ets/utils/CommonEventHelper';
import { SettingsDataUtils } from '@ohos/settings.common/src/main/ets/utils/SettingsDataUtils';
import { HiSysEventUtil } from '@ohos/settings.common/src/main/ets/systemEvent/HiSysEventUtil';
import { EventBus } from '@ohos/settings.common/src/main/ets/framework/common/EventBus';
import {
  notifyCompStateChange,
  SettingBaseState,
  SettingCompState,
  SettingResultState,
  SettingStateType,
  SettingTextState,
  SettingToggleState
} from '@ohos/settings.common/src/main/ets/framework/model/SettingStateModel';
import { EVENT_ID_HOT_SPOT_SWITCH_CHANGE } from '@ohos/settings.common/src/main/ets/event/types';
import { ItemResultType } from '@ohos/settings.common/src/main/ets/framework/model/SettingItemModel';
import { SatelliteUtils } from '@ohos/settings.common/src/main/ets/utils/BaseUtils';
import { DeviceNameUtil } from '@ohos/settings.common/src/main/ets/utils/DeviceNameUtils';
import { HiSysHotspotStateException } from '@ohos/settings.common/src/main/ets/systemEvent/ExceptionEventConsts';
import { harmonyShareAdapter, SharableTargetListener } from '@ohos/settings.wifi/src/main/ets/HarmonyShareAdapter';
import { ShareDataType, ShareTipsCode } from '@ohos/settings.wifi/src/main/ets/model/ShareModel';
import { HiSysHotspotEventGroup } from '@ohos/settings.common/src/main/ets/systemEvent/BehaviorEventConsts';
import { EventResultConsts } from '@ohos/settings.common/src/main/ets/systemEvent/EventResultConsts';
import { StringUtil } from '@ohos/settings.common/src/main/ets/utils/StringUtil';
import { HOTSPOT_NAME_MAX_LENGTH, HOTSPOT_NAME_ELLIPSIS } from '@ohos/settings.common/src/main/ets/utils/DeviceNameUtils';
import { LogMaskUtil } from '@ohos/settings.common/src/main/ets/utils/LogUtil';
import { MASK_OPACITY, FULL_OPACITY } from '@ohos/settings.common/src/main/ets/constant/ViewConstant';
import { WifiUtils } from '@ohos/settings.wifi';

const TAG: string = 'HotspotSwitchController';
const MAX_AP_DEVICES_NUMBER: number = 8;
const AIR_PLANE_MODE: string = 'settings.telephony.airplanemode';
const AIR_PLANE_MODE_DEFAULT_VAL: string = '0';
const HOTSPOT_TOGGLE_KEY: string = 'Setting.hotspot_data_entry.hotspot_switch.hotspot_switch_setting';
const SATELLITE_SWITCH: string = 'satellite_mode_switch';

const WIFI_CONN_SUCCESS: number = 4;
const WIFI_DISCONNECT: number = 6;
const AIRPLANE_MODE_ON: number = 1;
const AIRPLANE_MODE_OFF: number = 0;

export class HotspotSwitchController implements ComponentControl, SharableTargetListener {
  public stateChangeTimeoutId: number | null = null;
  private compId: string = '';
  // 以开启开关为例，一次完整的打开热点过程：手动打开 -> 收到开启完成广播
  private isWaitingLastActionDone: boolean = false;
  private isHotspotOn: boolean = false;
  private isChecked: boolean = true;
  private isToggleEnable: boolean = true;
  private isInAirplaneMode: boolean = true;
  private isRegisterShare: boolean = false;

  getShareTag(): ShareDataType {
    return ShareDataType.HOTSPOT;
  }

  getSharePreviewImage(): Resource {
    LogUtil.info(`${TAG} getSharePreviewImage`);
    return $r('app.media.share_hotspot');
  }

  async getShareConfig(): Promise<wifiManager.WifiDeviceConfig | wifiManager.HotspotConfig | undefined> {
    LogUtil.info(`${TAG} getShareConfig`);
    if (!this.isHotspotOn) {
      harmonyShareAdapter.finishShare(ShareTipsCode.SEND_API_NOTIFY_INFO_OPEN_HOTPOINT_TO_SHARE);
      return undefined;
    }
    return wifiManager.getHotspotConfig();
  }

  private registerHMShareListener(): void {
    LogUtil.info(`${TAG} registerHMShareListener isRegister:${this.isRegisterShare}`);
    if (!this.isRegisterShare) {
      harmonyShareAdapter.setListener(this);
      this.isRegisterShare = true;
    }
  }

  private unRegisterHMShareListener(): void {
    LogUtil.info(`${TAG} unRegisterHMShareListener isRegister:${this.isRegisterShare}`);
    if (this.isRegisterShare) {
      harmonyShareAdapter.releaseListener(this);
      this.isRegisterShare = false;
    }
  }

  private subscribeInfo: CommonEventManager.CommonEventSubscribeInfo = {
    events: [
      CommonEventManager.Support.COMMON_EVENT_WIFI_HOTSPOT_STATE,
      CommonEventManager.Support.COMMON_EVENT_AIRPLANE_MODE_CHANGED,
      CommonEventManager.Support.COMMON_EVENT_WIFI_CONN_STATE
    ]
  };

  private apConnected: CommonEventHelper = new CommonEventHelper(this.subscribeInfo, (err, data) => {
    if (data.event === CommonEventManager.Support.COMMON_EVENT_AIRPLANE_MODE_CHANGED) {
      LogUtil.info(`${TAG} Airplan mode ：${data.code}`);
      let isOpenSoftApAllowed: boolean = this.getSoftApAllowedState();
      LogUtil.info(`${TAG} isOpenSoftApAllowed ：${isOpenSoftApAllowed}`);
      let enable: boolean = this.getEnableState(AIRPLANE_MODE_ON === data.code, isOpenSoftApAllowed);
      this.setToggleState(enable);
      this.refreshUi();
    } else if (data.event === CommonEventManager.Support.COMMON_EVENT_WIFI_CONN_STATE) {
      LogUtil.info(`${TAG} wifi state ：${data.code}`);
      if (data.code == WIFI_CONN_SUCCESS || data.code == WIFI_DISCONNECT) {
        let isAirplaneModeOn: boolean = AirPlaneUtils.isAirplaneActive();
        if (!isAirplaneModeOn) {
          LogUtil.warn(`${TAG} airplane mode is off, ignore wifi event`);
          return;
        }
        let isOpenSoftApAllowed: boolean = this.getSoftApAllowedState();
        LogUtil.info(`${TAG} isOpenSoftApAllowed ：${isOpenSoftApAllowed}`);
        let enable: boolean = !SatelliteUtils.isCommunicationOpen() && isOpenSoftApAllowed;
        this.setToggleState(enable);
        this.refreshUi();
        if (!enable) {
          this.setChecked(false);
        }
      }
    }
  });

  private onToggleChange = (state: SettingToggleState) => {
    LogUtil.info(`${TAG} onToggleChange ${state.state}`);
    if (!this.handleCheckedChange(state.state)) {
      LogUtil.info(`${TAG} handleCheckedChange fail`);
      return false;
    }
    this.isChecked = state.state;
    return true;
  }

  init(compParam: CompCtrlParam): void {
    if (!compParam || !compParam.compId) {
      LogUtil.error(`${TAG} init fail, compParam is invalid`);
      return;
    }
    LogUtil.info(`${TAG} init, compId: ${compParam.compId}`);
    this.compId = compParam.compId;
    EventBus.getInstance().on(`${this.compId}.toggle`, this.onToggleChange);
    this.updateHotspotState();
    this.updateHotspotSwitchState();
    this.registerSatelliteListener();
  }

  destroy(): void {
    LogUtil.info(`${TAG} destroy`);
    EventBus.getInstance().detach(`${this.compId}.toggle`, this.onToggleChange);
    this.apConnected.unRegisterCommonEvent();
    this.unRegisterSatelliteListener();
  }

  onPageShow(component: SettingBaseModel): void {
    LogUtil.info(`${TAG} onPageShow`);
    this.updateHotspotState();
    this.updateHotspotSwitchState();
    this.registerHMShareListener();
  }

  onPageHide(component: SettingBaseModel): void {
    LogUtil.info(`${TAG} onPageHide`);
    this.apConnected.unRegisterCommonEvent();
    try {
      sharing.off('sharingStateChange');
    } catch (error) {
      LogUtil.error(`sharingStateChange on failed: ${error?.message}`);
    }
    if (this.isWaitingLastActionDone) {
      this.isWaitingLastActionDone = false;
      if (this.getChecked()) {
        this.startHotspot();
      } else {
        this.stopHotspot();
      }
    }
    this.unRegisterHMShareListener()
  }

  private getEnableState(isAirplaneModeOn: boolean, isOpenSoftApAllowed: boolean): boolean {
    if (SatelliteUtils.isCommunicationOpen()) {
      return false;
    }
    if (!isAirplaneModeOn) {
      LogUtil.info(`${TAG} airplane mode off, enable toggle`);
      return true;
    }
    return isOpenSoftApAllowed;
  }

  private updateHotspotState(): void {
    try {
      let ret: boolean = wifiManager.isHotspotActive();
      LogUtil.info(`${TAG} aboutToAppear isHotspotActive: ${ret}`);
      this.isHotspotOn = ret;
      this.updateStatus();
    } catch (error) {
      LogUtil.error(`${TAG} aboutToAppear get isHotspotActive fail`);
    }
    this.apConnected.registerCommonEvent();
    try {
      sharing.on('sharingStateChange', (isOn: boolean) => {
        this.onHotSpotStateChange(isOn);
      });
    } catch (error) {
      LogUtil.info(`sharingStateChange on failed: ${(error as BusinessError).message}`);
    }
  }

  private onHotSpotStateChange(isOn: boolean): void {
    LogUtil.info(`${TAG} onHotSpotStateChange ：${isOn}`);
    if (isOn === this.getChecked()) {
      this.isWaitingLastActionDone = false;
      LogUtil.info(`${TAG} receive state equals toggle, new state is：${isOn}`);
      return;
    }
    if (this.isWaitingLastActionDone) {
      this.isWaitingLastActionDone = false;
      this.isHotspotOn = this.getChecked();
      this.updateStatus();
      LogUtil.info(`${TAG} action finished isHotspotOn ：${this.isHotspotOn}`);
      if (this.getChecked()) {
        this.startHotspot();
      } else {
        this.stopHotspot();
      }
    } else {
      this.isHotspotOn = isOn;
      LogUtil.info(`${TAG} onHotSpotStateChange isHotspotOn ：${this.isHotspotOn}`);
      this.updateStatus();
    }
  }

  private startHotspot(): void {
    this.stopStateChangeTimeoutTimer();
    this.setStateChangeTimeoutTimer();
    LogUtil.info(`${TAG} begin startSharing.`);
    sharing.startSharing(sharing.SharingIfaceType.SHARING_WIFI).then(() => {
      LogUtil.info(`${TAG} handleCheckedChange startSharing success`);
      this.isHotspotOn = true;
    }).catch((error: BusinessError) => {
      LogUtil.error(`${TAG} handleCheckedChange startSharing fail: ${error?.message}`);
      this.isWaitingLastActionDone = false;
      this.updateStatus();
      this.stopStateChangeTimeoutTimer();
    });
  }

  private updateHotspotSwitchState(): void {
    let isOpenSoftApAllowed: boolean = this.getSoftApAllowedState();
    LogUtil.info(`${TAG} isOpenSoftApAllowed ：${isOpenSoftApAllowed}`);
    let enable: boolean =
      this.getEnableState(AirPlaneUtils.isAirplaneActive(), isOpenSoftApAllowed);
    this.setToggleState(enable);
    this.refreshUi();
  }

  private stopHotspot(): void {
    this.stopStateChangeTimeoutTimer();
    this.setStateChangeTimeoutTimer();
    LogUtil.info('begin stopSharing.');
    sharing.stopSharing(sharing.SharingIfaceType.SHARING_WIFI).then(() => {
      LogUtil.info(`${TAG} handleCheckedChange stopSharing success`);
      this.isHotspotOn = false;
    }).catch((error: BusinessError) => {
      LogUtil.error(`${TAG} handleCheckedChange stopSharing fail: ${error?.message}`);
      this.isWaitingLastActionDone = false;
      this.updateStatus();
      this.stopStateChangeTimeoutTimer();
    });
  }

  protected updateCheckedState(): boolean {
    LogUtil.info(`${TAG} updateCheckedState: ${this.isHotspotOn}`);
    return this.isHotspotOn;
  }

  protected handleCheckedChange(isChecked: boolean): boolean {
    LogUtil.info(`${TAG} handleCheckedChange isChecked=${isChecked}`);
    emitter.emit({
      eventId: EVENT_ID_HOT_SPOT_SWITCH_CHANGE,
    }, {
      data: {
        isChecked: isChecked,
      }
    });
    if (isChecked) {
      // 重复打开会关闭前一次的共享，然后开启新的热点
      if (this.isHotspotOn) {
        LogUtil.info(`${TAG} handleCheckedChange already on`);
        return true;
      }
      HiSysEventUtil.reportDefaultBehaviorEventByUE(HiSysHotspotEventGroup.HOTSPOT_SWITCH,
        EventResultConsts.SWITCH_ON);
      this.enableHotspot();
      if (!this.isWaitingLastActionDone) {
        this.startHotspot();
      }
      LogUtil.info(`${TAG} isWaitingLastActionDone = ${this.isWaitingLastActionDone}`);
      this.isWaitingLastActionDone = true;
    } else {
      if (!this.isHotspotOn) {
        LogUtil.info(`${TAG} handleCheckedChange already off`);
        return true;
      }
      HiSysEventUtil.reportDefaultBehaviorEventByUE(HiSysHotspotEventGroup.HOTSPOT_SWITCH,
        EventResultConsts.SWITCH_OFF);
      if (!this.isWaitingLastActionDone) {
        this.stopHotspot();
      }
      LogUtil.info(`${TAG} isWaitingLastActionDone = ${this.isWaitingLastActionDone}`);
      this.isWaitingLastActionDone = true;
    }
    return true;
  }

  setStateChangeTimeoutTimer(): void {
    this.stateChangeTimeoutId = setTimeout(() => {
      try {
        if (this.isHotspotOn === wifiManager?.isHotspotActive()) {
          return;
        }
      } catch (error) {
        LogUtil.error(`${TAG} get isHotspotActive fail`);
      }
      HiSysEventUtil.reportDefaultFaultEvent(HiSysHotspotStateException.EVENT_NAME,
        HiSysHotspotStateException.HOTSPOT_STATE_CHANGE_TIMEOUT);
    }, 5000);
  }

  stopStateChangeTimeoutTimer(): void {
    if (this.stateChangeTimeoutId != null) {
      clearTimeout(this.stateChangeTimeoutId);
      this.stateChangeTimeoutId = null;
    }
  }

  updateStatus(): void {
    LogUtil.info(`${TAG} updateStatus`);
    let isChecked: boolean = this.updateCheckedState();
    this.setChecked(isChecked);
    let isToggleEnable: boolean = this.updateToggleState();
    this.setToggleState(isToggleEnable);
  }

  protected updateToggleState(): boolean {
    return this.isToggleEnable;
  }

  /**
   * 返回开关的保存状态
   */
  getChecked(): boolean {
    LogUtil.info(`${TAG} getChecked ${this.isChecked}`);
    return this.isChecked;
  }

  getToggleState(): boolean {
    LogUtil.info(`${TAG} getToggleState ${this.isToggleEnable}`);
    return this.isToggleEnable;
  }

  /**
   * 设置开关的状态
   */
  setChecked(isChecked: boolean): void {
    LogUtil.info(`${TAG} setChecked ${isChecked}`);
    if (this.isChecked !== isChecked) {
      this.isChecked = isChecked;
      LogUtil.info(`${TAG} setChecked, refresh : ${this.isChecked}`);
      this.refreshUi();
    }
  }

  setToggleState(isToggleEnable: boolean): void {
    LogUtil.info(`${TAG} setToggleState ${isToggleEnable}`);
    if (this.isToggleEnable !== isToggleEnable) {
      this.isToggleEnable = isToggleEnable;
      LogUtil.info(`${TAG} setToggleState, refresh : ${this.isToggleEnable}`);
      notifyCompStateChange(HOTSPOT_TOGGLE_KEY,
        new Map<SettingStateType, SettingBaseState>([[SettingStateType.STATE_TYPE_ITEM_TITLE, {
          opacity: isToggleEnable ? FULL_OPACITY : MASK_OPACITY
        } as SettingTextState]]));
    }
  }

  refreshUi(): void {
    notifyCompStateChange(HOTSPOT_TOGGLE_KEY,
      new Map<SettingStateType, SettingResultState>([[SettingStateType.STATE_TYPE_ITEM_RESULT,
        {
          type: ItemResultType.RESULT_TYPE_TOGGLE,
          result: {
            state: this.isChecked,
            enabled: this.isToggleEnable,
          },
        } as SettingResultState]]));
  }

  private async registerSatelliteListener() {
    SettingsDataUtils.registerKeyObserverUser(SATELLITE_SWITCH, () => {
      let isOpenSoftApAllowed: boolean = this.getSoftApAllowedState();
      let enable: boolean = !SatelliteUtils.isCommunicationOpen() && isOpenSoftApAllowed;
      this.setToggleState(enable);
    });
  }

  private async unRegisterSatelliteListener() {
    SettingsDataUtils.unregisterKeyObserver(SATELLITE_SWITCH);
  }

  private enableHotspot(): void {
    try {
      let config: wifiManager.HotspotConfig = wifiManager.getHotspotConfig();
      let hotspotTitle: string = DeviceNameUtil.getDisplayDeviceName();
      if (config.ssid !== hotspotTitle) {
        let deviceNameLength: number = StringUtil.getStringLength(hotspotTitle);
        if (deviceNameLength > HOTSPOT_NAME_MAX_LENGTH) {
          let ellipsisLength: number = StringUtil.getStringLength(HOTSPOT_NAME_ELLIPSIS);
          config.ssid = StringUtil.getSubstringByBytes(hotspotTitle, HOTSPOT_NAME_MAX_LENGTH - ellipsisLength) +
            HOTSPOT_NAME_ELLIPSIS;
        } else {
          config.ssid = hotspotTitle;
        }
      }
      LogUtil.info(`${TAG} enableHotspot config ssid: ${LogMaskUtil.getLogNickNameString(config.ssid)}`);
      config.maxConn = MAX_AP_DEVICES_NUMBER;
      if (wifiManager.isHotspotActive()) {
        wifiManager.disableHotspot();
        wifiManager.setHotspotConfig(config);
        wifiManager.enableHotspot();
      } else {
        wifiManager.setHotspotConfig(config);
      }
    } catch (err) {
      LogUtil.error(`${TAG} getHotspotConfig error: ${err?.message}`);
    }
  }

  private getSoftApAllowedState(): boolean {
    let isOpenSoftApAllowed: boolean = false;
    try {
      isOpenSoftApAllowed = wifiManager.isOpenSoftApAllowed();
    } catch (err) {
      LogUtil.error(`${TAG} getSoftApAllowedState error: ${err?.message}`);
    }
    return isOpenSoftApAllowed;
  }
}
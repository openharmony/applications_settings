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
import connection from '@ohos.net.connection';
import CommonEvent from '@ohos.commonEvent';
import commonEventManager from '@ohos.commonEventManager';
import {
  CompCtrlParam,
  ComponentControl,
  SettingBaseModel
} from '@ohos/settings.common/src/main/ets/framework/model/SettingBaseModel';
import { CommonEventHelper } from '@ohos/settings.common/src/main/ets/utils/CommonEventHelper';
import { LogUtil } from '@ohos/settings.common/src/main/ets/utils/LogUtil';
import { SettingsDataUtils } from '@ohos/settings.common/src/main/ets/utils/SettingsDataUtils';
import {
    HiSysEventUtil
} from '@ohos/settings.common/src/main/ets/systemEvent/HiSysEventUtil';
import { EventBus } from '@ohos/settings.common/src/main/ets/framework/common/EventBus';
import {
  notifyCompStateChange,
  SettingBaseState,
  SettingResultState,
  SettingStateType,
  SettingToggleState,
  SettingTextState
} from '@ohos/settings.common/src/main/ets/framework/model/SettingStateModel';
import { ItemResultType } from '@ohos/settings.common/src/main/ets/framework/model/SettingItemModel';
import { HiSysAboutSystemSettingsEventGroup } from '@ohos/settings.common/src/main/ets/systemEvent/BehaviorEventConsts';
import { AirPlaneUtils, EMERGENCY_KEY } from '@ohos/settings.common/src/main/ets/utils/AirPlaneUtils';
import { MASK_OPACITY, FULL_OPACITY } from '@ohos/settings.common/src/main/ets/constant/ViewConstant';

const AIR_PLANE_MODE: string = 'settings.telephony.airplanemode';
const AIR_PLANE_MODE_DEFAULT_VAL: string = '0';
const TOGGLE_KEY: string = 'Setting.MobileNetwork.air_plane_group.air_plane_mode_setting';

export class AirPlaneModeSwitchController implements ComponentControl {
  private readonly tag: string = 'AirPlaneModeSwitchController : ';
  private compId: string = '';
  /**
   * 当前开关状态
   */
  private isAirPlaneOn: boolean = false;
  private isAirplaneDisable: boolean = false;
  private onToggleChange = (state: SettingToggleState) => {
    LogUtil.info(`${this.tag} onToggleChange ${state.state}`);
    if (!this.handleCheckedChange(state.state)) {
      LogUtil.info(`${this.tag} handleCheckedChange fail`);
      return false;
    }
    return true;
  }
  /**
   * 订阅者信息，飞行模式已更改的公共事件的动作
   */
  private subscribeInfo: commonEventManager.CommonEventSubscribeInfo = {
    events: [CommonEvent.Support.COMMON_EVENT_AIRPLANE_MODE_CHANGED]
  };
  /**
   * 订阅/取消订阅飞行模式的回调时间
   */
  private airPlaneModeCommonEvent: CommonEventHelper = new CommonEventHelper(this.subscribeInfo, (err, data) => {
    LogUtil.info(`${this.tag} airPlaneModeCommonEvent, code: ${err.code}, data: ${data.code},
      currentStatus: ${this.isAirPlaneOn}`);
    if (!(err.code as number) && this.isAirPlaneOn !== (data.code ? true : false)) {
      this.updateStatus();
    }
  });

  init(param: CompCtrlParam): void {
    LogUtil.info(`${this.tag} init`);
    if (!param) {
      LogUtil.info(`${this.tag} init failed, param is empty.`);
      return;
    }
    this.compId = (param as CompCtrlParam).compId;
    EventBus.getInstance().on(`${this.compId}.toggle`, this.onToggleChange);
    SettingsDataUtils.registerKeyObserverUser(EMERGENCY_KEY, () => {
      let isAirPlaneOperateEnable: boolean = AirPlaneUtils.isAirPlaneOperateEnable();
      LogUtil.info(`${this.tag} emergency status changed:${isAirPlaneOperateEnable}`);
      this.updateItemEnableStatus(isAirPlaneOperateEnable);
    })
  }

  destroy(): void {
    LogUtil.info(`${this.tag} destroy`);
    EventBus.getInstance().detach(`${this.compId}.toggle`, this.onToggleChange);
    SettingsDataUtils.unregisterKeyObserverUser(EMERGENCY_KEY);
  }

  onPageShow(component: SettingBaseModel): void {
    LogUtil.info(`${this.tag} onPageShow`);
    this.airPlaneModeCommonEvent.registerCommonEvent();
    this.updateStatus();
    this.setAirplaneState();
  }

  onPageHide(component: SettingBaseModel): void {
    LogUtil.info(`${this.tag} onPageHide`);
    this.airPlaneModeCommonEvent.unRegisterCommonEvent();
  }

  protected updateCheckedState(): boolean {
    let value: string = SettingsDataUtils.getSettingsData(AIR_PLANE_MODE, AIR_PLANE_MODE_DEFAULT_VAL);
    this.isAirPlaneOn = value === AIR_PLANE_MODE_DEFAULT_VAL ? false : true;
    return this.isAirPlaneOn;
  }

  protected handleCheckedChange(isChecked: boolean): boolean {
    LogUtil.info(`${this.tag} handleCheckedChange isChecked:${isChecked}`);
    if (isChecked && !this.isAirPlaneOn) {
      this.enableAirplaneMode();
    }
    if (!isChecked && this.isAirPlaneOn) {
      this.disableAirplaneMode();
    }
    this.isAirPlaneOn = isChecked;
    return true;
  }

  /**
   * 开启飞行模式开关
   */
  private enableAirplaneMode(): Promise<void> {
    LogUtil.info(`${this.tag} enableAirplaneMode`);
    HiSysEventUtil.reportDefaultBehaviorEventByUE(HiSysAboutSystemSettingsEventGroup.CLICK_OFFLINE_MODE_SWITCH, 'on');
    return connection.enableAirplaneMode().catch((error: Error) => {
      LogUtil.error(`${this.tag} enableAirplaneMode, error: ${error?.message}`);
      this.updateStatus();
    });
  }

  /**
   * 关闭飞行模式开关
   */
  private disableAirplaneMode(): Promise<void> {
    LogUtil.info(`${this.tag} disableAirplaneMode`);
    HiSysEventUtil.reportDefaultBehaviorEventByUE(HiSysAboutSystemSettingsEventGroup.CLICK_OFFLINE_MODE_SWITCH, 'off');
    return connection.disableAirplaneMode().catch((error: Error) => {
      LogUtil.error(`${this.tag} disableAirplaneMode, error: ${error?.message}`);
      this.updateStatus();
    });
  }

  private updateStatus(): void {
    LogUtil.info(`${this.tag} updateStatus`);
    let isChecked = this.updateCheckedState();
    notifyCompStateChange(TOGGLE_KEY,
      new Map<SettingStateType, SettingResultState>([[SettingStateType.STATE_TYPE_ITEM_RESULT,
        {
          type: ItemResultType.RESULT_TYPE_TOGGLE,
          result: {
            state: isChecked,
          },
        } as SettingResultState]]));
  }

  private updateItemEnableStatus(enable: boolean): void {
    LogUtil.info(`${this.tag} updateItemEnableStatus ${enable}`);
    notifyCompStateChange(TOGGLE_KEY,
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

  private setAirplaneState(): void {
    let isAirPlaneOperateDisable = !AirPlaneUtils.isAirPlaneOperateEnable();
    if (this.isAirplaneDisable === isAirPlaneOperateDisable) {
      return;
    }
    this.isAirplaneDisable = isAirPlaneOperateDisable;
    this.updateItemEnableStatus(!this.isAirplaneDisable);
  }
}
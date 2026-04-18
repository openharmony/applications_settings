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
import { observer } from '@kit.TelephonyKit';
import data from '@ohos.telephony.data';
import commonEventManager from '@ohos.commonEventManager';
import { LogUtil } from '@ohos/settings.common/src/main/ets/utils/LogUtil';
import {
  CompCtrlParam,
  ComponentControl
} from '@ohos/settings.common/src/main/ets/framework/model/SettingBaseModel';
import {
  notifyCompStateChange,
  SettingBaseState,
  SettingCompState,
  SettingResultState,
  SettingStateType,
  SettingToggleState,
} from '@ohos/settings.common/src/main/ets/framework/model/SettingStateModel';
import { SatelliteUtils } from '@ohos/settings.common/src/main/ets/utils/BaseUtils';
import { SimUtils } from '@ohos/settings.common/src/main/ets/utils/SimUtils';
import { AirPlaneUtils } from '@ohos/settings.common/src/main/ets/utils/AirPlaneUtils';
import { CommonEventHelper } from '@ohos/settings.common/src/main/ets/utils/CommonEventHelper';
import { EventBus } from '@ohos/settings.common/src/main/ets/framework/common/EventBus';
import { SettingsDataUtils } from '@ohos/settings.common/src/main/ets/utils/SettingsDataUtils';
import { ItemResultType } from '@ohos/settings.common/src/main/ets/framework/model/SettingItemModel';

const TAG: string = 'MobileNetworkSwitchController: ';

const MOBILE_SWITCH_KEY = 'cellular_data_enable';

export class MobileNetworkSwitchController implements ComponentControl {
  private isMobileDateAvailable: boolean = false;
  private isAirPlaneOn: boolean = false;
  private isMobileNetWorkOn: boolean = false;
  private compId: string = '';
  // 开关开启或者关闭中
  private isEditing: boolean = false;

  /**
   * 订阅者信息，飞行模式已更改的公共事件的动作
   */
  private subscribeInfo: commonEventManager.CommonEventSubscribeInfo = {
    events: [commonEventManager.Support.COMMON_EVENT_AIRPLANE_MODE_CHANGED]
  };
  /**
   * 订阅/取消订阅飞行模式的回调时间
   */
  private airPlaneModeCommonEvent: CommonEventHelper = new CommonEventHelper(this.subscribeInfo, (err, data) => {
    LogUtil.info(`${TAG} airPlaneModeCommonEvent, code: ${err?.code}, data: ${data?.code},
      currentStatus: ${this.isAirPlaneOn}`);
    if (!(err.code as number) && this.isAirPlaneOn !== (data.code ? true : false)) {
      this.updateEnabledState();
    }
  });

  private onPageShowCallBack = () => {
    this.onPageShow();
  }

  private onPageShowHideBack = () => {
    this.onPageHide();
  }

  private onToggleChange = (state: SettingToggleState) => {
    LogUtil.info(`${TAG} onToggleChange ${state.state}`);
    if (this.isEditing) {
      LogUtil.error(`${TAG} onToggleChange faile, current is editing.`);
      return false;
    }
    if (!this.handleCheckedChange(state.state)) {
      LogUtil.error(`${TAG} handleCheckedChange fail.`);
      return false;
    }
    return true;
  }

  constructor(isMobileDateAvailable: boolean, isAirplaneActive: boolean, isCellularDataEnabled: boolean) {
    this.isMobileDateAvailable = isMobileDateAvailable;
    this.isAirPlaneOn = isAirplaneActive;
    this.isMobileNetWorkOn = isCellularDataEnabled;
  }

  init(param?: object | undefined): void {
    if (!param) {
      LogUtil.info(`${TAG} init failed, param is empty.`);
      return;
    }
    this.compId = (param as CompCtrlParam).compId;
    LogUtil.info(`${TAG} init: ${this.compId}`);
    if (!this.isMobileDateAvailable) {
      notifyCompStateChange(this.compId, new Map<SettingStateType, SettingBaseState>(
        [[SettingStateType.STATE_TYPE_ITEM_VISIBLE, { state: false } as SettingCompState]]));
      return;
    }
    this.airPlaneModeCommonEvent.registerCommonEvent();
    try {
      observer.on('simStateChange', (simStateData: observer.SimStateData) => {
        LogUtil.info(`${TAG} simStateChange.`);
        this.updateEnabledState();
      });
      observer.on('iccAccountInfoChange', value => {
        LogUtil.info(`${TAG} iccAccountInfoChange.`);
        this.updateEnabledState();
      });
    } catch (error) {
      LogUtil.error(`${TAG} sim register error, ${error?.message}`);
    }
    EventBus.getInstance().on(`${this.compId}.toggle`, this.onToggleChange);
    EventBus.getInstance().on('ExternalNetworkPagePageShow', this.onPageShowCallBack);
    EventBus.getInstance().on('ExternalNetworkPagePageHide', this.onPageShowHideBack);
    this.registerCellularDataSettingChange();
  }

  destroy(): void {
    LogUtil.info(`${TAG} destroy`);
    if (!this.isMobileDateAvailable) {
      return;
    }
    this.airPlaneModeCommonEvent.unRegisterCommonEvent();
    try {
      observer.off('simStateChange');
      observer.off('iccAccountInfoChange');
    } catch (error) {
      LogUtil.error(`${TAG} sim unregister error, ${error?.message}`);
    }
    EventBus.getInstance().detach(`${this.compId}.toggle`, this.onToggleChange);
    EventBus.getInstance().detach('ExternalNetworkPagePageShow', this.onPageShowCallBack);
    EventBus.getInstance().detach('ExternalNetworkPagePageHide', this.onPageShowHideBack);
    this.unRegisterCellularDataSettingChange();
  }

  onPageShow(): void {
    LogUtil.info(`${TAG} onPageShow`);
    this.updateEnabledState();
  }

  onPageHide(): void {
    LogUtil.info(`${TAG} onPageHide`);
  }

  updateEnabledState() {
    this.isAirPlaneOn = AirPlaneUtils.isAirplaneActive();
    let isMobileDateEnabled = SimUtils.hasSimCard() && !this.isAirPlaneOn &&
      !SatelliteUtils.isCommunicationOpen();
    notifyCompStateChange(this.compId, new Map<SettingStateType, SettingBaseState>(
      [[SettingStateType.STATE_TYPE_ITEM_ENABLED, { state: isMobileDateEnabled } as SettingCompState]]));
  }

  protected handleCheckedChange(isChecked: boolean): boolean {
    LogUtil.info(`${TAG} handleCheckedChange isChecked:${isChecked}`);
    if (isChecked && !this.isMobileNetWorkOn) {
      this.openMobileData();
    }
    if (!isChecked && this.isMobileNetWorkOn) {
      this.closeMobileData();
    }
    this.isMobileNetWorkOn = isChecked;
    return true;
  }
  private openMobileData(): void {
    this.isEditing = true;
    data.enableCellularData().then(() => {
      this.isMobileNetWorkOn = true;
      this.isEditing = false;
      LogUtil.info(`${TAG} openMobileData success`);
    }).catch((err: Error) => {
      LogUtil.error(`${TAG} openMobileData fail, err msg: ${err?.message}`);
    });
  }

  private closeMobileData(): void {
    this.isEditing = true;
    data.disableCellularData().then(() => {
      this.isMobileNetWorkOn = false;
      this.isEditing = false;
      LogUtil.info(`${TAG} closeMobileData success`);
    }).catch((err: Error) => {
      LogUtil.error(`${TAG} closeMobileData fail, err msg: ${err?.message}`);
    });
  }

  private registerCellularDataSettingChange(): void {
    LogUtil.info(`${TAG} registerCellularDataSettingChange`);
    SettingsDataUtils.registerKeyObserver(MOBILE_SWITCH_KEY, () => {
      let value: string = SettingsDataUtils.getSettingsData(MOBILE_SWITCH_KEY, '0');
      // 1 表示开启 0 表示关闭
      this.isMobileNetWorkOn = value === '1';
      notifyCompStateChange(this.compId, new Map<SettingStateType, SettingResultState>(
        [[SettingStateType.STATE_TYPE_ITEM_RESULT, {
          type: ItemResultType.RESULT_TYPE_TOGGLE,
          result: {
            state: this.isMobileNetWorkOn,
          }
        } as SettingResultState]]
      ));
    })
  }

  private unRegisterCellularDataSettingChange(): void {
    LogUtil.info(`${TAG} unRegisterCellularDataSettingChange`);
    SettingsDataUtils.unregisterKeyObserver('cellular_data_enable');
  }
}
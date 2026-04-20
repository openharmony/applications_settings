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

import { BusinessError } from '@ohos.base';
import abilityAccessCtrl, { Permissions } from '@ohos.abilityAccessCtrl';
import radio from '@ohos.telephony.radio';
import observer from '@ohos.telephony.observer';
import CommonEventManager from '@ohos.commonEventManager';
import { LogUtil } from '@ohos/settings.common/src/main/ets/utils/LogUtil';
import { CompCtrlParam, ComponentControl } from '@ohos/settings.common/src/main/ets/framework/model/SettingBaseModel';
import {
  notifyCompStateChange,
  SettingBaseState,
  SettingCompState,
  SettingResultState,
  SettingStateType
} from '@ohos/settings.common/src/main/ets/framework/model/SettingStateModel';
import { CommonEventHelper } from '@ohos/settings.common/src/main/ets/utils/CommonEventHelper';
import { SLOTID_ONE, SLOTID_TWO, CARD_NUM_ONE } from '@ohos/settings.common/src/main/ets/constant/SimConstant';
import { AirPlaneUtils } from '@ohos/settings.common/src/main/ets/utils/AirPlaneUtils';
import { SimUtils } from '@ohos/settings.common/src/main/ets/utils/SimUtils';
import { SettingPageModel } from '@ohos/settings.common/src/main/ets/framework/model/SettingPageModel';
import { ItemResultType, SettingItemModel } from '@ohos/settings.common/src/main/ets/framework/model/SettingItemModel';
import { ContextUtils } from '@ohos/settings.common/src/main/ets/utils/baseutils/ContextUtils';
import { ResourceUtil } from '@ohos/settings.common/src/main/ets/utils/ResourceUtil';
import { PageRouter } from '@ohos/settings.common/src/main/ets/framework/common/PageRouter';
import { EventBus, EventCb } from '@ohos/settings.common/src/main/ets/framework/common/EventBus';
import { SystemParamUtil } from '@ohos/settings.common/src/main/ets/utils/SystemParamUtil';
import { AboutDeviceUtils } from '@ohos/settings.aboutdevice/src/main/ets/utils/AboutDeviceUtils';
import { NetworkInfoModel } from '../model/NetworkInfoModel';
import { ESimUtils } from '../../../../utils/ESimUtils';
/* instrument ignore file */
const NETWORK_START_CHANGE: string = 'networkStateChange';

/**
 * 网络入口
 */
export class NetworkEntryController implements ComponentControl {
  private tag: string = 'NetworkEntryController';
  private compId: string = '';
  private enable?: boolean;
  private isAirPlaneMode?: boolean;

  init(compParam: CompCtrlParam): void {
    LogUtil.showInfo(this.tag, 'on init');
    this.compId = compParam?.compId;
    this.simState.registerCommonEvent();
    this.updateStatus();
  }

  destroy(): void {
    LogUtil.showInfo(this.tag, 'on destroy');
    this.simState.unRegisterCommonEvent();
  }

  private refreshUi(result: boolean): void {
    notifyCompStateChange(this.compId, new Map<SettingStateType, SettingCompState>([
      [SettingStateType.STATE_TYPE_ITEM_ENABLED, { state: result } as SettingCompState],
    ]));
  }

  private subscribeInfo: CommonEventManager.CommonEventSubscribeInfo = {
    events: [
      CommonEventManager.Support.COMMON_EVENT_SIM_STATE_CHANGED,
      CommonEventManager.Support.COMMON_EVENT_AIRPLANE_MODE_CHANGED,
    ]
  }
  private simState: CommonEventHelper = new CommonEventHelper(this.subscribeInfo, (err, data) => {
    LogUtil.info(`${this.tag} subscribeInfo state changed: ${data?.event}`);
    this.isAirPlaneMode = AirPlaneUtils.isAirplaneActive();
    this.updateStatus();
  })

  updateStatus(): void {
    if ((!SimUtils.isSimActivating(SLOTID_ONE) && !SimUtils.isSimActivating(SLOTID_TWO)) || this.isAirPlaneMode) {
      this.enable = false;
    } else {
      this.enable = true;
    }
    this.refreshUi(this.enable);
  }
}

/**
 * 网络信息
 */
export class NetworkInfoController implements ComponentControl {
  private tag: string = 'NetworkInfoController';
  private comp: SettingPageModel | null = null;
  private pageModel: NetworkInfoModel = new NetworkInfoModel();

  init(compParam: CompCtrlParam): void {
    LogUtil.showInfo(this.tag, 'on init');
    this.comp = compParam?.component as SettingPageModel;
    this.networkState.registerCommonEvent();
    observer.on('networkStateChange', (networkState: observer.NetworkState) => {
      if (!networkState) {
        return;
      }
      let isRegStateInService: boolean = false;
      if (networkState.regState === radio.RegState.REG_STATE_IN_SERVICE) {
        isRegStateInService = true;
      }
      EventBus.getInstance().emit(NETWORK_START_CHANGE, isRegStateInService);
    })

    this.initPage(this.comp as SettingPageModel);
    if (!SystemParamUtil.isEflForbidden()) {
      this.requestPermissions();
    }
  }

  destroy(): void {
    LogUtil.showInfo(this.tag, 'on destroy');
    this.networkState.unRegisterCommonEvent();
    observer.off('networkStateChange');
  }

  private subscribeInfo: CommonEventManager.CommonEventSubscribeInfo = {
    events: [
      CommonEventManager.Support.COMMON_EVENT_AIRPLANE_MODE_CHANGED,
    ]
  }
  private networkState: CommonEventHelper = new CommonEventHelper(this.subscribeInfo, (err, data) => {
    LogUtil.showInfo(this.tag, `networkState subscribeInfo state changed: ${data?.event}`);
    PageRouter.pop('Setting');
  })

  requestPermissions() {
    let requestPermissions: Permissions[] = [
      'ohos.permission.APPROXIMATELY_LOCATION',
      'ohos.permission.LOCATION',
    ];
    let atManager = abilityAccessCtrl.createAtManager();
    atManager.requestPermissionsFromUser(ContextUtils.getContext(), requestPermissions)
      .then((data) => {
        for (let i = 0; i < data?.authResults.length; i++) {
          if (data?.authResults[i] === 0) {
            EventBus.getInstance().emit('cellid_permission_value', true);
            return;
          }
        }
      }).catch((err: BusinessError) => {
      LogUtil.showError(this.tag, `requestPermissionsFromUser err. code: ${err?.code}, message: ${err?.message}`);
    });
    LogUtil.showInfo(this.tag, 'Cellid requestPermissionsFromUser end');
  }

  initPage(comp: SettingPageModel): void {
    if (SimUtils.getCardSlotNum() === CARD_NUM_ONE) {
      LogUtil.showInfo(this.tag, 'initGroups');
      comp.groups = this.pageModel.simCardOneGroup;
    } else {
      LogUtil.showInfo(this.tag, 'initTabs');
      comp.tabs = [
        {
          id: 'SimOneTab',
          content: ESimUtils.getSimCardName(SLOTID_ONE),
          groups: this.pageModel.simCardOneGroup,
        },
        {
          id: 'SimTwoTab',
          content: ESimUtils.getSimCardName(SLOTID_TWO),
          groups: this.pageModel.simCardTwoGroup,
        },
      ]
    }
  }
}

/**
 * 运营商名称
 */
export class OperatorNameController implements ComponentControl {
  private tag: string = 'OperatorNameController';
  private itemModel?: SettingItemModel;
  private compId: string = '';
  private state: string | Resource = '';
  private enable?: boolean;
  private onNetworkStateChangeCallback: EventCb = () => {
    this.setNetworkInfo();
  };

  init(compParam: CompCtrlParam): void {
    LogUtil.showInfo(this.tag, 'on init');
    this.compId = compParam?.compId;
    this.itemModel = compParam?.component as SettingItemModel;
    this.simState.registerCommonEvent();
    EventBus.getInstance().on(NETWORK_START_CHANGE, this.onNetworkStateChangeCallback);
    this.setNetworkInfo();
  }

  destroy(): void {
    LogUtil.showInfo(this.tag, 'on destroy');
    this.simState.unRegisterCommonEvent();
    EventBus.getInstance().detach(NETWORK_START_CHANGE, this.onNetworkStateChangeCallback);
  }

  private refreshUi(result: boolean): void {
    notifyCompStateChange(this.compId, new Map<SettingStateType, SettingBaseState>(
      [
        [SettingStateType.STATE_TYPE_ITEM_RESULT,
          { type: ItemResultType.RESULT_TYPE_TEXT, result: { content: this.state } } as SettingResultState],
        [SettingStateType.STATE_TYPE_ITEM_ENABLED, { state: result } as SettingCompState],
      ]
    ));
  }

  private async setNetworkInfo(): Promise<void> {
    if (this.itemModel?.id === 'network_information_name_simOne') {
      this.state = await AboutDeviceUtils.getOperatorNameData(SLOTID_ONE);
      this.enable = SimUtils.isSimActivating(SLOTID_ONE);
    } else {
      this.state = await AboutDeviceUtils.getOperatorNameData(SLOTID_TWO);
      this.enable = SimUtils.isSimActivating(SLOTID_TWO);
    }
    this.refreshUi(this.enable);
  }

  private subscribeInfo: CommonEventManager.CommonEventSubscribeInfo = {
    events: [
      CommonEventManager.Support.COMMON_EVENT_SIM_STATE_CHANGED
    ]
  }
  private simState: CommonEventHelper = new CommonEventHelper(this.subscribeInfo, (err, data) => {
    LogUtil.showInfo(this.tag, `subscribeInfo state changed: ${data?.event}`);
    this.setNetworkInfo();
  })
}

/**
 * 信号强度（dBm）
 */
export class SignalStrengthController implements ComponentControl {
  private tag: string = 'SignalStrengthController';
  private itemModel?: SettingItemModel;
  private compId: string = '';
  private state: string | Resource = '';
  private enable?: boolean;
  private onNetworkStateChangeCallback: EventCb = () => {
    this.setSignalStrengthInfo();
  };

  init(compParam: CompCtrlParam): void {
    LogUtil.showInfo(this.tag, 'on init');
    this.compId = compParam?.compId;
    this.itemModel = compParam?.component as SettingItemModel;
    observer.on('signalInfoChange', { slotId: SLOTID_ONE }, (data: Array<radio.SignalInformation>) => {
      this.setSignalStrengthInfo();
    });
    observer.on('signalInfoChange', { slotId: SLOTID_TWO }, (data: Array<radio.SignalInformation>) => {
      this.setSignalStrengthInfo();
    });
    this.simState.registerCommonEvent();
    EventBus.getInstance().on(NETWORK_START_CHANGE, this.onNetworkStateChangeCallback);
    this.setSignalStrengthInfo();
  }

  destroy(): void {
    LogUtil.showInfo(this.tag, 'on destroy');
    observer.off('signalInfoChange');
    this.simState.unRegisterCommonEvent();
    EventBus.getInstance().detach(NETWORK_START_CHANGE, this.onNetworkStateChangeCallback);
  }

  private refreshUi(result: boolean): void {
    notifyCompStateChange(this.compId, new Map<SettingStateType, SettingBaseState>(
      [
        [SettingStateType.STATE_TYPE_ITEM_RESULT,
          { type: ItemResultType.RESULT_TYPE_TEXT, result: { content: this.state } } as SettingResultState],
        [SettingStateType.STATE_TYPE_ITEM_ENABLED, { state: result } as SettingCompState],
      ]
    ));
  }

  private async setSignalStrengthInfo(): Promise<void> {
    if (this.itemModel?.id === 'signal_strength_simOne') {
      this.state = await AboutDeviceUtils.getSignalStrengthDate(SLOTID_ONE);
      this.enable = SimUtils.isSimActivating(SLOTID_ONE);
    } else {
      this.state = await AboutDeviceUtils.getSignalStrengthDate(SLOTID_TWO);
      this.enable = SimUtils.isSimActivating(SLOTID_TWO);
    }
    this.refreshUi(this.enable);
  }

  private subscribeInfo: CommonEventManager.CommonEventSubscribeInfo = {
    events: [
      CommonEventManager.Support.COMMON_EVENT_SIM_STATE_CHANGED
    ]
  }
  private simState: CommonEventHelper = new CommonEventHelper(this.subscribeInfo, (err, data) => {
    LogUtil.showInfo(this.tag, `subscribeInfo state changed: ${data?.event}`);
    this.setSignalStrengthInfo();
  })
}

/**
 * 移动网络类型
 * 不支持5G的设备不显示
 */
export class MobileNetworkTypeController implements ComponentControl {
  private tag: string = 'MobileNetworkTypeController';
  private itemModel?: SettingItemModel;
  private compId: string = '';
  private state: string | Resource = '';
  private enable?: boolean;

  init(compParam: CompCtrlParam): void {
    LogUtil.showInfo(this.tag, 'on init');
    this.compId = compParam?.compId;
    this.itemModel = compParam?.component as SettingItemModel;
    this.simState.registerCommonEvent();
    this.setNetworkType();
  }

  destroy(): void {
    LogUtil.showInfo(this.tag, 'on destroy');
    this.simState.unRegisterCommonEvent();
  }

  private refreshUi(result: boolean): void {
    notifyCompStateChange(this.compId, new Map<SettingStateType, SettingBaseState>(
      [
        [SettingStateType.STATE_TYPE_ITEM_RESULT,
          { type: ItemResultType.RESULT_TYPE_TEXT, result: { content: this.state } } as SettingResultState],
        [SettingStateType.STATE_TYPE_ITEM_ENABLED, { state: result } as SettingCompState],
      ]
    ));
  }

  private async setNetworkType(): Promise<void> {
    if (this.itemModel?.id === 'mobile_network_type_simOne') {
      let networkTypeSimOne: string | Resource = await AboutDeviceUtils.getMobileNetworkTypeDate(SLOTID_ONE);
      this.state = networkTypeSimOne;
      this.enable = SimUtils.isSimActivating(SLOTID_ONE);
    } else {
      let networkTypeSimTwo: string | Resource = await AboutDeviceUtils.getMobileNetworkTypeDate(SLOTID_TWO);
      this.state = networkTypeSimTwo;
      this.enable = SimUtils.isSimActivating(SLOTID_TWO);
    }
    this.refreshUi(this.enable);
  }

  private subscribeInfo: CommonEventManager.CommonEventSubscribeInfo = {
    events: [
      CommonEventManager.Support.COMMON_EVENT_SIM_STATE_CHANGED
    ]
  }
  private simState: CommonEventHelper = new CommonEventHelper(this.subscribeInfo, (err, data) => {
    LogUtil.showInfo(this.tag, `subscribeInfo state changed: ${data?.event}`);
    this.setNetworkType();
  })
}

/**
 * Cell ID
 */
export class CellIdController implements ComponentControl {
  private tag: string = 'CellIdController';
  private itemModel?: SettingItemModel;
  private compId: string = '';
  private state: string | Resource = '';
  private enable?: boolean;

  init(compParam: CompCtrlParam): void {
    LogUtil.showInfo(this.tag, 'on init');
    this.compId = compParam?.compId;
    this.itemModel = compParam?.component as SettingItemModel;
    this.simState.registerCommonEvent();
    this.setCellIdInfo();
    EventBus.getInstance().on('cellid_permission_value', (state: boolean) => {
      LogUtil.showInfo(this.tag, `cellid_permission_value value ${state}`);
      this.setCellIdInfo();
    });
  }

  destroy(): void {
    LogUtil.showInfo(this.tag, 'on destroy');
    EventBus.getInstance().detach('cellid_permission_value', (state: boolean) => {
      LogUtil.showInfo(this.tag, 'cellid_permission_value value false');
    });
    this.simState.unRegisterCommonEvent();
  }

  private refreshUi(result: boolean): void {
    notifyCompStateChange(this.compId, new Map<SettingStateType, SettingBaseState>(
      [
        [SettingStateType.STATE_TYPE_ITEM_RESULT,
          { type: ItemResultType.RESULT_TYPE_TEXT, result: { content: this.state } } as SettingResultState],
        [SettingStateType.STATE_TYPE_ITEM_ENABLED, { state: result } as SettingCompState],
      ]
    ));
  }

  private async setCellIdInfo(): Promise<void> {
    let cellIdSimOne = await AboutDeviceUtils.getCellId(SLOTID_ONE);
    let cellIdSimTwo = await AboutDeviceUtils.getCellId(SLOTID_TWO);
    if (this.itemModel?.id === 'cell_id_simOne') {
      this.state = cellIdSimOne;
      this.enable = SimUtils.isSimActivating(SLOTID_ONE);
    } else {
      this.state = cellIdSimTwo;
      this.enable = SimUtils.isSimActivating(SLOTID_TWO);
    }
    this.refreshUi(this.enable);
  }

  private subscribeInfo: CommonEventManager.CommonEventSubscribeInfo = {
    events: [
      CommonEventManager.Support.COMMON_EVENT_SIM_STATE_CHANGED
    ]
  };
  private simState: CommonEventHelper = new CommonEventHelper(this.subscribeInfo, (err, data) => {
    LogUtil.showInfo(this.tag, `subscribeInfo state changed: ${data?.event}`);
    this.setCellIdInfo();
  });
}

/**
 * mcc,mnc
 */
export class MccMncController implements ComponentControl {
  private tag: string = 'MccMncController';
  private itemModel?: SettingItemModel;
  private compId: string = '';
  private state: string | Resource = '';
  private enable?: boolean;
  private onNetworkStateChangeCallback: EventCb = () => {
    this.setMccMncInfo();
  };

  init(compParam: CompCtrlParam): void {
    LogUtil.showInfo(this.tag, 'on init');
    this.compId = compParam?.compId;
    this.itemModel = compParam?.component as SettingItemModel;
    this.simState.registerCommonEvent();
    EventBus.getInstance().on(NETWORK_START_CHANGE, this.onNetworkStateChangeCallback);
    this.setMccMncInfo();
  }

  destroy(): void {
    LogUtil.showInfo(this.tag, 'on destroy');
    this.simState.unRegisterCommonEvent();
    EventBus.getInstance().detach(NETWORK_START_CHANGE, this.onNetworkStateChangeCallback);
  }

  private refreshUi(result: boolean): void {
    notifyCompStateChange(this.compId, new Map<SettingStateType, SettingBaseState>(
      [
        [SettingStateType.STATE_TYPE_ITEM_RESULT,
          { type: ItemResultType.RESULT_TYPE_TEXT, result: { content: this.state } } as SettingResultState],
        [SettingStateType.STATE_TYPE_ITEM_ENABLED, { state: result } as SettingCompState],
      ]
    ));
  }

  private async setMccMncInfo(): Promise<void> {
    if (this.itemModel?.id === 'mcc_mnc_simOne') {
      let mccMncInfoSimOne = await AboutDeviceUtils.getMccMncInfo(SLOTID_ONE);
      this.state = mccMncInfoSimOne;
      this.enable = SimUtils.isSimActivating(SLOTID_ONE);
    } else {
      let mccMncInfoSimTwo = await AboutDeviceUtils.getMccMncInfo(SLOTID_TWO);
      this.state = mccMncInfoSimTwo;
      this.enable = SimUtils.isSimActivating(SLOTID_TWO);
    }
    this.refreshUi(this.enable);
  }

  private subscribeInfo: CommonEventManager.CommonEventSubscribeInfo = {
    events: [
      CommonEventManager.Support.COMMON_EVENT_SIM_STATE_CHANGED
    ]
  };
  private simState: CommonEventHelper = new CommonEventHelper(this.subscribeInfo, (err, data) => {
    LogUtil.showInfo(this.tag, `subscribeInfo state changed: ${data?.event}`);
    this.setMccMncInfo();
  })
}

/**
 * 短信中心号码
 */
export class SmsCenterNumberController implements ComponentControl {
  private tag: string = 'CellIdController';
  private itemModel?: SettingItemModel;
  private compId: string = '';
  private state: string | Resource = '';
  private enable?: boolean;

  init(compParam: CompCtrlParam): void {
    LogUtil.showInfo(this.tag, 'on init');
    this.compId = compParam?.compId;
    this.itemModel = compParam?.component as SettingItemModel;
    this.simState.registerCommonEvent();
    this.setSmsCenterNumberInfo();
  }

  destroy(): void {
    LogUtil.showInfo(this.tag, 'on destroy');
    this.simState.unRegisterCommonEvent();
  }

  private refreshUi(result: boolean): void {
    notifyCompStateChange(this.compId, new Map<SettingStateType, SettingBaseState>(
      [
        [SettingStateType.STATE_TYPE_ITEM_RESULT,
          { type: ItemResultType.RESULT_TYPE_TEXT, result: { content: this.state } } as SettingResultState],
        [SettingStateType.STATE_TYPE_ITEM_ENABLED, { state: result } as SettingCompState],
      ]
    ));
  }

  private async setSmsCenterNumberInfo(): Promise<void> {
    if (this.itemModel?.id === 'sms_center_number_simOne') {
      let smsCenterNumberData: (string | Resource) = await AboutDeviceUtils.getSmsCenterNumber(SLOTID_ONE);
      this.state = smsCenterNumberData;
      this.enable = SimUtils.isSimActivating(SLOTID_ONE);
    } else {
      let smsCenterNumberData: (string | Resource) = await AboutDeviceUtils.getSmsCenterNumber(SLOTID_TWO);
      this.state = smsCenterNumberData;
      this.enable = SimUtils.isSimActivating(SLOTID_TWO);
    }
    this.refreshUi(this.enable);
  }

  private subscribeInfo: CommonEventManager.CommonEventSubscribeInfo = {
    events: [
      CommonEventManager.Support.COMMON_EVENT_SIM_STATE_CHANGED
    ]
  };
  private simState: CommonEventHelper = new CommonEventHelper(this.subscribeInfo, (err, data) => {
    LogUtil.showInfo(this.tag, `subscribeInfo state changed: ${data?.event}`);
    this.setSmsCenterNumberInfo();
  })
}
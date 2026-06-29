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
import rpc from '@ohos.rpc';
import Want from '@ohos.app.ability.Want';
import common from '@ohos.app.ability.common';
import commonEvent from '@ohos.commonEventManager';
import commonEventManager from '@ohos.commonEventManager';
import { BusinessError } from '@ohos.base';
import { LogUtil } from '@ohos/settings.common/src/main/ets/utils/LogUtil';
import {
  CompCtrlParam,
  ComponentControl,
} from '@ohos/settings.common/src/main/ets/framework/model/SettingBaseModel';
import {
  notifyCompStateChange,
  SettingResultState,
  SettingStateType
} from '@ohos/settings.common/src/main/ets/framework/model/SettingStateModel';
import { ItemResultType } from '@ohos/settings.common/src/main/ets/framework/model/SettingItemModel';
import { CommonEventHelper } from '@ohos/settings.common/src/main/ets/utils/CommonEventHelper';
import IdlDataServiceProxy from '../../idl/idl_data_service_proxy';
import { CarInfo } from '../../idl/i_idl_data_service';

const TAG: string = 'HiCarStateController : ';
const CONNECTED_STATE_CHANGE: string = 'com.ohos.hicar.connectionStateChange';
const UPDATE_CAR_INFO: string = 'com.ohos.hicar.updateCarInfo';
const HICAR_SWITCH_CHANGE = 'com.ohos.hicar.hiCarSwitchChange';
const HICAR_BUNDLE_NAME: string = 'com.ohos.hicar';
const COMMON_EVENT_PERMISSION = 'ohos.permission.sec.ACCESS_UDID';

export class HiCarStateController implements ComponentControl {
  private static isHiCarEnable: boolean = true;
  private static isHiCarConnected: boolean | undefined = false;
  private static deviceName: string | undefined = '';
  private static bleMac: string | undefined = '';
  private compId: string = '';
  private context = getContext(this) as common.UIAbilityContext;
  private connectionId = -1;
  private dataProxy?: IdlDataServiceProxy;
  public subscribeInfo: commonEventManager.CommonEventSubscribeInfo = {
    events: [CONNECTED_STATE_CHANGE, UPDATE_CAR_INFO, HICAR_SWITCH_CHANGE],
    publisherPermission: COMMON_EVENT_PERMISSION
  };
  public hiCarCommonEvent = new CommonEventHelper(this.subscribeInfo, (err: BusinessError, data) => {
    if (err.code) {
      LogUtil.error(`${TAG} subscribe failed ${err?.message}`);
    } else {
      if (data.event === CONNECTED_STATE_CHANGE) {
        LogUtil.info(`${TAG} HiCar connected state change subscribe success`);
        this.checkHiCarConnectionChange(data);
      } else if (data.event === UPDATE_CAR_INFO) {
        LogUtil.info(`${TAG} HiCar info change subscribe success`);
        this.checkHiCarInfoChange(data);
      } else {
        this.checkHiCarSwitch(data.parameters?.isHiCarEnable);
      }
    }
  });

  init(compParam: CompCtrlParam): void {
    if (!compParam || !compParam.compId) {
      LogUtil.error(`${TAG} init fail, compParam is invalid`);
      return;
    }
    LogUtil.info(`${TAG} init, compId: ${compParam.compId}`);
    this.compId = compParam.compId;
    LogUtil.info(`${TAG + HiCarStateController.isHiCarConnected} init`);
    this.refreshUi(this.checkConnectState());
    this.connectAbility(this.context);
    this.hiCarCommonEvent.registerCommonEvent();
  }

  destroy(): void {
    LogUtil.info(`${TAG} destroy`);
    this.disconnectAbility(this.context);
    this.hiCarCommonEvent.unRegisterCommonEvent();
  }

  checkConnectState(): Resource | string {
    if (HiCarStateController.isHiCarEnable) {
      return HiCarStateController.isHiCarConnected && HiCarStateController.deviceName
        ? HiCarStateController.deviceName
        : $r('app.string.connect_off_text');
    } else {
      return $r('app.string.nfc_switch_off_text')
    }
  }

  checkHiCarConnectionChange(data: commonEvent.CommonEventData) {
    LogUtil.info(`${TAG} HiCar Connection State Change`);
    HiCarStateController.isHiCarConnected = data?.parameters?.isConnected;
    HiCarStateController.deviceName = data?.parameters?.deviceName;
    HiCarStateController.bleMac = data?.parameters?.bleMac;
    this.refreshUi(this.checkConnectState());
  }

  checkHiCarSwitch(isHiCarEnable: boolean) {
    LogUtil.info(`${TAG} checkHiCarSwitch isHiCarEnable: ${isHiCarEnable}`);
    HiCarStateController.isHiCarEnable = isHiCarEnable;
    this.refreshUi(this.checkConnectState());
  }

  checkHiCarInfoChange(data: commonEvent.CommonEventData) {
    LogUtil.info(`${TAG} HiCar Info Change`);
    if (!HiCarStateController.isHiCarEnable) {
      return;
    }
    if (HiCarStateController.bleMac === data?.parameters?.carInfo?.bleMac) {
      HiCarStateController.deviceName = data?.parameters?.carInfo?.deviceName;
      this.refreshUi(this.checkConnectState());
    }
  }

  connectAbility(context: common.UIAbilityContext): void {
    let want: Want = {
      bundleName: HICAR_BUNDLE_NAME,
      abilityName: 'HiCarExtService',
    };
    LogUtil.info(`${TAG} connectAbility`);
    this.connectionId = context.connectServiceExtensionAbility(want, this.onAbilityConnectDone);
    LogUtil.info(`${TAG} connectAbility connectionId ${this.connectionId}`);
  }

  disconnectAbility(context: common.UIAbilityContext) {
    context.disconnectServiceExtensionAbility(this.connectionId, (err, data) => {
      if (err.code === 0) {
        LogUtil.info(`${TAG} disconnectServiceExtensionAbility.`);
      } else {
        LogUtil.error(`${TAG} disconnectServiceExtensionAbility error${err?.message}`);
      }
    })
  }

  public onAbilityConnectDone: common.ConnectOptions = {
    onConnect: (elementName, proxy: rpc.RemoteObject) => {
      LogUtil.info(`${TAG} onConnect ${elementName}`);
      this.dataProxy = new IdlDataServiceProxy(proxy);
      this.dataProxy.getHiCarEnable((isHiCarEnable: boolean) => {
        HiCarStateController.isHiCarEnable = isHiCarEnable;
        LogUtil.info(`${TAG} getHiCarEnable isHiCarEnable: ${isHiCarEnable}`);
        if (!isHiCarEnable) {
          this.refreshUi(this.checkConnectState());
          return;
        }
        this.dataProxy?.getConnectedCarInfo((errCode: number, carInfo: CarInfo) => {
          if (errCode === 0) {
            HiCarStateController.isHiCarConnected = carInfo?.isConnected;
            HiCarStateController.deviceName = carInfo?.deviceName;
            HiCarStateController.bleMac = carInfo?.bleMac;
            this.refreshUi(this.checkConnectState());
            LogUtil.info(`${TAG} getConnectedCarInfo success isHiCarConnected: ${carInfo?.isConnected}`);
          } else {
            HiCarStateController.isHiCarConnected = false;
            HiCarStateController.deviceName = '';
            HiCarStateController.bleMac = '';
            this.refreshUi(this.checkConnectState());
            LogUtil.info(`${TAG} getConnectedCarInfo failed`);
          }
        });
      });
    },
    onDisconnect: (elementName) => {
      LogUtil.info(`${TAG} onDisconnect ${elementName}`);
    },
    onFailed: (code) => {
      LogUtil.info(`${TAG}IDL Connect onFailed ${code}`);
    }
  }

  private refreshUi(content: ResourceStr): void {
    notifyCompStateChange(this.compId,
      new Map<SettingStateType, SettingResultState>([[SettingStateType.STATE_TYPE_ITEM_RESULT,
        { type: ItemResultType.RESULT_TYPE_TEXT, result: { content: content } } as SettingResultState]]));
  }
}
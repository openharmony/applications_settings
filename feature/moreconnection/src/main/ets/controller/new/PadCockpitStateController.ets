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

import common from '@ohos.app.ability.common';
import Want from '@ohos.app.ability.Want';
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

/* instrument ignore file */
const TAG: string = 'PadCockpitStateController: ';
const PAD_COCKPIT_CONNECT_STATE_CHANGE: string = 'com.ohos.padCockpit.connectionStateChange';
const PAD_COCKPIT_SWITCH_CHANGE = 'com.ohos.padCockpit.settingsSwitchChange';
const PAD_COCKPIT_BUNDLE_NAME: string = 'com.ohos.cardistributedassist';
const CONNECT_STATE_PERMISSION: string = 'ohos.permission.GET_BUNDLE_INFO';
const CONNECTED_STATE: number = 3;

export class PadCockpitStateController implements ComponentControl {
  private static isPadCockpitEnable: boolean = true;
  private static isPadCockpitConnected: boolean | undefined = false;
  private static deviceName: string | undefined = '';
  private compId: string = '';
  private context = getContext(this) as common.UIAbilityContext;
  private connectionId = -1;
  private dataProxy?: IdlDataServiceProxy;
  private subscribeInfo: commonEventManager.CommonEventSubscribeInfo = {
    publisherPermission: CONNECT_STATE_PERMISSION,
    events: [PAD_COCKPIT_CONNECT_STATE_CHANGE, PAD_COCKPIT_SWITCH_CHANGE]
  };
  private padCockpitCommonEvent = new CommonEventHelper(this.subscribeInfo, (err: BusinessError, data) => {
    if (err.code) {
      LogUtil.error(`${TAG} receive padCockpitCommonEvent failed ${err?.message}`);
    } else {
      LogUtil.info(`${TAG} receive padCockpitCommonEvent: event = ${data.event}`);
      if (data.event === PAD_COCKPIT_CONNECT_STATE_CHANGE) {
        this.checkPadCockpitConnectStateChange(data);
      } else if (data.event === PAD_COCKPIT_SWITCH_CHANGE) {
        this.checkPadCockpitSwitch(data.parameters?.isPadCockpitEnable);
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
    LogUtil.info(`${TAG + PadCockpitStateController.isPadCockpitConnected} init`);
    let state = PadCockpitStateController.isPadCockpitConnected ? PadCockpitStateController.deviceName
      : $r('app.string.connect_off_text');
    this.refreshUi(state ?? '');
    this.connectAbility(this.context);
    this.padCockpitCommonEvent.registerCommonEvent();
  }

  destroy(): void {
    LogUtil.info(`${TAG} destroy`);
    this.disconnectAbility(this.context);
    this.padCockpitCommonEvent.unRegisterCommonEvent();
  }

  private checkConnectState(): Resource | string {
    if (PadCockpitStateController.isPadCockpitEnable) {
      return PadCockpitStateController.isPadCockpitConnected
        ? $r('app.string.connect_on_text')
        : $r('app.string.connect_off_text');
    } else {
      return $r('app.string.nfc_switch_off_text')
    }
  }

  private checkPadCockpitConnectStateChange(data: commonEventManager.CommonEventData) {
    const connectState: boolean = data?.parameters?.isConnected;
    LogUtil.info(`${TAG} checkPadCockpitConnectionChange: connectState = ${connectState}`);
    PadCockpitStateController.isPadCockpitConnected = connectState;
    this.refreshUi(this.checkConnectState());
  }

  private checkPadCockpitSwitch(isPadCockpitEnable: boolean) {
    LogUtil.info(`${TAG} checkPadCockpitSwitch: isPadCockpitEnable = ${isPadCockpitEnable}`);
    PadCockpitStateController.isPadCockpitEnable = isPadCockpitEnable;
    this.refreshUi(this.checkConnectState());
  }

  private connectAbility(context: common.UIAbilityContext): void {
    LogUtil.info(`${TAG} connectAbility`);
    let want: Want = {
      bundleName: PAD_COCKPIT_BUNDLE_NAME,
      abilityName: 'SettingsServiceExtAbility',
    };
    this.connectionId = context.connectServiceExtensionAbility(want, this.onAbilityConnectDone);
    LogUtil.info(`${TAG} connectAbility connectionId ${this.connectionId}`);
  }

  private disconnectAbility(context: common.UIAbilityContext) {
    context.disconnectServiceExtensionAbility(this.connectionId, (err, data) => {
      if (err.code === 0) {
        LogUtil.info(`${TAG} disconnectServiceExtensionAbility`);
      } else {
        LogUtil.error(`${TAG} disconnectServiceExtensionAbility: errorCode = ${err?.code}`);
      }
    })
  }

  private onAbilityConnectDone: common.ConnectOptions = {
    onConnect: (elementName, proxy) => {
      LogUtil.info(`${TAG} onConnect ${elementName}`);
      this.dataProxy = new IdlDataServiceProxy(proxy);
      this.dataProxy?.getPadCockpitConnectedState((isEnable: boolean, connectState: number) => {
        LogUtil.info(`${TAG} getPadCockpitState: isEnable = ${isEnable}, connectState = ${connectState}`);
        PadCockpitStateController.isPadCockpitEnable = isEnable;
        if (connectState === CONNECTED_STATE) {
          PadCockpitStateController.isPadCockpitConnected = true;
        } else {
          PadCockpitStateController.isPadCockpitConnected = false;
        }
        this.refreshUi(this.checkConnectState());
      });
    },
    onDisconnect: (elementName) => {
      LogUtil.info(`${TAG} onDisconnect ${elementName}`);
    },
    onFailed: (code) => {
      LogUtil.error(`${TAG} Connect onFailed ${code}`);
    }
  };

  private refreshUi(content: ResourceStr): void {
    notifyCompStateChange(this.compId,
      new Map<SettingStateType, SettingResultState>([[SettingStateType.STATE_TYPE_ITEM_RESULT,
        { type: ItemResultType.RESULT_TYPE_TEXT, result: { content: content } } as SettingResultState]]));
  }
}
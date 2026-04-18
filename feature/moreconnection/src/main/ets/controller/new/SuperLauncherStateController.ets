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
import { HiSysEventUtil } from '@ohos/settings.common/src/main/ets/systemEvent/HiSysEventUtil';
import { HiSysMoreConnectionGroup } from '@ohos/settings.common/src/main/ets/systemEvent/BehaviorEventConsts';
import { EventResultConsts } from '@ohos/settings.common/src/main/ets/systemEvent/EventResultConsts';
import IdlDataServiceProxy from '../../idl/idl_data_service_proxy';

const TAG: string = 'SuperLauncherStateController : ';
const EVENT: string = 'com.ohos.slassistant.connectionStateChange';
const SUPER_LAUNCHER_SWITCH_CHANGE = 'com.ohos.superLauncher.superLauncherSwitchChange';
const SUPER_LAUNCHER_BUNDLE_NAME: string = 'com.ohos.slassistant';
const CONNECT_STATE_PERMISSION: string = 'ohos.permission.START_ABILITIES_FROM_BACKGROUND';

export class SuperLauncherStateController implements ComponentControl {
  private static isSuperLauncherEnable: boolean = true;
  private static isSuperLauncherConnected: boolean | undefined = false;
  private static deviceName: string | undefined = '';
  private compId: string = '';
  private context = getContext(this) as common.UIAbilityContext;
  private connectionId = -1;
  private dataProxy?: IdlDataServiceProxy;
  private static instance: SuperLauncherStateController | undefined = undefined;
  public subscribeInfo: commonEventManager.CommonEventSubscribeInfo = {
    publisherPermission: CONNECT_STATE_PERMISSION,
    events: [EVENT, SUPER_LAUNCHER_SWITCH_CHANGE]
  };
  public superLauncherCommonEvent = new CommonEventHelper(this.subscribeInfo, (err: BusinessError, data) => {
    /* instrument ignore if*/
    if (err.code) {
      LogUtil.error(`${TAG} subscribe failed ${err?.message}`);
    } else {
      LogUtil.info(`${TAG} subscribe success`);
      if (data.event == EVENT) {
        this.checkSuperLauncherConnectionChange(data);
      } else {
        this.checkSuperLauncherSwitch(data.parameters?.isSuperLauncherEnable);
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
    LogUtil.info(`${TAG + SuperLauncherStateController.isSuperLauncherConnected} init`);
    let state = SuperLauncherStateController.isSuperLauncherConnected ? $r('app.string.connect_on_text')
      : $r('app.string.connect_off_text');
    this.refreshUi(state ?? '');
    this.connectAbility(this.context);
    this.superLauncherCommonEvent.registerCommonEvent();
  }

  destroy(): void {
    LogUtil.info(`${TAG} destroy`);
    this.disconnectAbility(this.context);
    this.superLauncherCommonEvent.unRegisterCommonEvent();
  }

  checkConnectState(): Resource | string {
    /* instrument ignore else*/
    if (SuperLauncherStateController.isSuperLauncherEnable) {
      return SuperLauncherStateController.isSuperLauncherConnected ? $r('app.string.connect_on_text')
        : $r('app.string.connect_off_text');
    } else {
      return $r('app.string.nfc_switch_off_text')
    }
  }

  checkSuperLauncherConnectionChange(data: commonEventManager.CommonEventData) {
    LogUtil.info(`${TAG} SuperLauncher Connection State Change`);
    SuperLauncherStateController.isSuperLauncherConnected = data?.parameters?.isConnected;
    SuperLauncherStateController.deviceName = data?.parameters?.deviceName;
    this.refreshUi(this.checkConnectState());
  }

  checkSuperLauncherSwitch(isSuperLauncherEnable: boolean) {
    LogUtil.info(`${TAG} checkHiCarSwitch isHiCarEnable: ${isSuperLauncherEnable}`);
    HiSysEventUtil.reportDefaultBehaviorEventByUE(HiSysMoreConnectionGroup.SUPER_DESKTOP_SWITCH,
      isSuperLauncherEnable ? EventResultConsts.SWITCH_ON : EventResultConsts.SWITCH_OFF);
    SuperLauncherStateController.isSuperLauncherEnable = isSuperLauncherEnable;
    this.refreshUi(this.checkConnectState());
  }

  connectAbility(context: common.UIAbilityContext): void {
    let want: Want = {
      bundleName: SUPER_LAUNCHER_BUNDLE_NAME,
      abilityName: 'SuperLauncherServiceExtAbility',
    };
    LogUtil.info(`${TAG} connectAbility`);
    this.connectionId = context.connectServiceExtensionAbility(want, this.onAbilityConnectDone);
    LogUtil.info(`${TAG} connectAbility connectionId ${this.connectionId}`);
  }

  /* instrument ignore next */
  disconnectAbility(context: common.UIAbilityContext) {
    context.disconnectServiceExtensionAbility(this.connectionId, (err, data) => {
      if (err.code === 0) {
        LogUtil.info(`${TAG} disconnectServiceExtensionAbility`);
      } else {
        LogUtil.error(`${TAG} disconnectServiceExtensionAbility error${err?.message}`);
      }
    })
  }

  public static getInstance(): SuperLauncherStateController {
    if (SuperLauncherStateController.instance === undefined) {
      SuperLauncherStateController.instance = new SuperLauncherStateController();
    }
    return SuperLauncherStateController.instance;
  }

  public getSuperLauncherEnable(): boolean {
    return SuperLauncherStateController.isSuperLauncherEnable;
  }

  public onAbilityConnectDone: common.ConnectOptions = {
    onConnect: (elementName, proxy) => {
      LogUtil.info(`${TAG} onConnect ${elementName}`);
      this.dataProxy = new IdlDataServiceProxy(proxy);
      this.dataProxy?.getSuperLauncherInfo((isConnected: boolean, deviceName: string, isEnable: boolean) => {
        SuperLauncherStateController.isSuperLauncherEnable = isEnable;
        SuperLauncherStateController.isSuperLauncherConnected = isConnected;
        SuperLauncherStateController.deviceName = deviceName;
        this.refreshUi(this.checkConnectState());
        LogUtil.info(`${TAG} getSuperLauncherInfo success ${SuperLauncherStateController.deviceName}`);
      });
    },
    onDisconnect: (elementName) => {
      LogUtil.info(`${TAG} onDisconnect ${elementName}`);
    },
    onFailed: (code) => {
      LogUtil.info(`${TAG}IDL Connect onFailed ${code}`);
    }
  };

  private refreshUi(content: ResourceStr): void {
    notifyCompStateChange(this.compId,
      new Map<SettingStateType, SettingResultState>([[SettingStateType.STATE_TYPE_ITEM_RESULT,
        { type: ItemResultType.RESULT_TYPE_TEXT, result: { content: content } } as SettingResultState]]));
  }
}
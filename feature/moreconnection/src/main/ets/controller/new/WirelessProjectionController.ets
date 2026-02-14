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

import settings from '@ohos.settings';
import { common } from '@kit.AbilityKit';
import { rpc } from '@kit.IPCKit';
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
import { SettingsDataUtils } from '@ohos/settings.common/src/main/ets/utils/SettingsDataUtils';
import { DeviceUtil } from '@ohos/settings.common/src/main/ets/utils/BaseUtils';

const TAG: string = 'WirelessProjectionController';
const PRIVACY_STATEMENT_AGREE_KEY: string = 'wireless_projection_privacy_agree';
const CONTROL_CENTER_RESHOW: string = 'need_reshow_projection_privacy';
const KEY_ACTIVE_NFC_TAGS: string = 'activeNfcTags';
const SETTINGS_VALUE_0: string = '0';
const SETTINGS_VALUE_1: string = '1';
const FUN_NUM: string = 'SF-10045857_f301';
const TIPS_TYPE_PHONE: string = '62';
const TIPS_TYPE_PC: string = 'banner';
const WIRELESS_TRUSTED_DEVICE: number = 1009;

export class WirelessProjectionController implements ComponentControl {
  private static INSTANCE: WirelessProjectionController | undefined = undefined;
  private remoteProxy?: rpc.IRemoteObject;
  private connectionNumber: number = -1;
  private compId: string = '';
  public switchState: boolean = false;
  private callBack?: (switchState: boolean) => void;
  private isRegisterData: boolean = false;
  private isDestroy: boolean = false;

  public static getInstance() {
    if (!WirelessProjectionController.INSTANCE) {
      WirelessProjectionController.INSTANCE = new WirelessProjectionController();
    }
    return WirelessProjectionController.INSTANCE;
  }

  init(compParam: CompCtrlParam): void {
    if (!compParam || !compParam.compId) {
      LogUtil.error(`${TAG} init fail, compParam is invalid`);
      return;
    }
    LogUtil.info(`${TAG} init, compId: ${compParam.compId}`);
    this.compId = compParam.compId;
    this.isDestroy = false;
    this.updateStateAsync();
    if (!this.isRegisterData) {
      this.isRegisterData = true;
      this.registerDataChange();
    }
  }

  destroy(): void {
    this.isDestroy = true;
    this.unRegisterDataChange();
  }

  // instrument ignore next
  public registerSwitch(callBack: (switchState: boolean) => void): void {
    this.updateStateAsync();
    if (!this.isRegisterData) {
      this.isRegisterData = true;
      this.registerDataChange();
    }
    this.callBack = callBack;
    LogUtil.info(`${TAG} registerSwitch ${this.switchState}`);
    this.callBack?.(this.switchState);
  }

  /* instrument ignore next */
  public unregisterSwitch(): void {
    if (this.callBack) {
      this.callBack = undefined;
    }
    if (this.isDestroy) {
      this.unRegisterDataChange();
    }
  }

  private registerDataChange(): void {
    SettingsDataUtils.registerKeyObserverWithDomain(PRIVACY_STATEMENT_AGREE_KEY, settings.domainName.USER_SECURITY,
      () => {
        this.updateStateAsync();
      });
    /* instrument ignore if*/
    if (!DeviceUtil.isDevicePc()) {
      SettingsDataUtils.registerKeyObserverWithDomain(CONTROL_CENTER_RESHOW, settings.domainName.USER_SECURITY, () => {
        this.updateStateAsync();
      });
    }
  }

  // instrument ignore next
  public setSwitchState(isOpen: boolean): void {
    if (isOpen) {
      SettingsDataUtils.setSettingsDataDomain(PRIVACY_STATEMENT_AGREE_KEY, SETTINGS_VALUE_1,
        settings.domainName.USER_SECURITY);
      if (!DeviceUtil.isDevicePc()) {
        SettingsDataUtils.setSettingsDataDomain(CONTROL_CENTER_RESHOW, SETTINGS_VALUE_1,
          settings.domainName.USER_SECURITY);
      }
    } else {
      SettingsDataUtils.setSettingsDataDomain(PRIVACY_STATEMENT_AGREE_KEY, SETTINGS_VALUE_0,
        settings.domainName.USER_SECURITY);
      if (!DeviceUtil.isDevicePc()) {
        SettingsDataUtils.setSettingsDataDomain(KEY_ACTIVE_NFC_TAGS, '', settings.domainName.USER_SECURITY);
      }
    }
  }

  private updateStateAsync(): void {
    SettingsDataUtils.getSettingsDataAsync(PRIVACY_STATEMENT_AGREE_KEY, SETTINGS_VALUE_0,
      settings.domainName.USER_SECURITY).then(privacyAgreeState => {
      /* instrument ignore else*/
      if (!DeviceUtil.isDevicePc()) {
        this.updateForPhone(privacyAgreeState);
      } else {
        let newState: ResourceStr = '';
        if (privacyAgreeState === SETTINGS_VALUE_0) {
          this.switchState = false;
          newState = $r('app.string.projection_state_off');
        } else {
          this.switchState = true;
          newState = $r('app.string.projection_state_on');
        }
        this.callBack?.(this.switchState);
        notifyCompStateChange(this.compId,
          new Map<SettingStateType, SettingResultState>([[SettingStateType.STATE_TYPE_ITEM_RESULT,
            { type: ItemResultType.RESULT_TYPE_TEXT, result: { content: newState } } as SettingResultState]]));
      }
    })
  }

  private updateForPhone(privacyAgreeState: string): void {
    SettingsDataUtils.getSettingsDataAsync(CONTROL_CENTER_RESHOW, SETTINGS_VALUE_1,
      settings.domainName.USER_SECURITY).then(controlCenterReshow => {
      let newState: ResourceStr = '';
      if (privacyAgreeState === SETTINGS_VALUE_0 || controlCenterReshow === SETTINGS_VALUE_0) {
        this.switchState = false;
        newState = $r('app.string.projection_state_off');
      } else {
        this.switchState = true;
        newState = $r('app.string.projection_state_on');
      }
      this.callBack?.(this.switchState);
      LogUtil.info(`${TAG} updateState privacyAgreeState: ${privacyAgreeState} needReshow: ${controlCenterReshow}`);
      notifyCompStateChange(this.compId,
        new Map<SettingStateType, SettingResultState>([[SettingStateType.STATE_TYPE_ITEM_RESULT,
          { type: ItemResultType.RESULT_TYPE_TEXT, result: { content: newState } } as SettingResultState]]));
    })
  }

  private unRegisterDataChange(): void {
    SettingsDataUtils.unregisterKeyObserverWithDomain(PRIVACY_STATEMENT_AGREE_KEY, settings.domainName.USER_SECURITY);
    SettingsDataUtils.unregisterKeyObserverWithDomain(CONTROL_CENTER_RESHOW, settings.domainName.USER_SECURITY);
    this.isRegisterData = false;
  }

  /* instrument ignore next */
  public disconnectCastService(context: Context) {
    if (this.connectionNumber !== -1) {
      try {
        let ctx = context as common.UIAbilityContext;
        ctx.disconnectServiceExtensionAbility(this.connectionNumber);
      } catch (error) {
        LogUtil.error(`${TAG} disConnectServiceAbility error ${error.code}`);
      }
    }
  }

  // instrument ignore next
  public connectCastService(context: Context): void {
    if (this.remoteProxy) {
      this.sendRemoteMessage();
      return;
    }
    let options: common.ConnectOptions = {
      onConnect(_, remote) {
        LogUtil.info(`${TAG} onConnect callback`);
        if (WirelessProjectionController.INSTANCE) {
          WirelessProjectionController.INSTANCE.remoteProxy = remote;
          WirelessProjectionController.INSTANCE.sendRemoteMessage();
        }
      },
      onDisconnect(_) {
        LogUtil.info(`${TAG} onDisconnect castsourceservice`);
        if (WirelessProjectionController.INSTANCE) {
          WirelessProjectionController.INSTANCE.remoteProxy = undefined;
        }
      },
      onFailed(code) {
        LogUtil.info(`${TAG}onFailed castsourceservice callback ${code}`);
        if (WirelessProjectionController.INSTANCE) {
          WirelessProjectionController.INSTANCE.remoteProxy = undefined;
        }
      }
    };
    let want: Want = {
      bundleName: 'com.ohos.cast',
      abilityName: 'CastSourceServiceAbility',
    }
    try {
      let ctx = context as common.UIAbilityContext;
      this.connectionNumber = ctx.connectServiceExtensionAbility(want, options);
    } catch (error) {
      LogUtil.error(`${TAG} connectServiceAbility error ${error.code}`);
    }
  }

  /* instrument ignore next */
  public sendRemoteMessage(): void {
    if (!this.remoteProxy) {
      LogUtil.info(`${TAG} sendRemoteMessage remoteProxy undefined`);
      return;
    }
    let option = new rpc.MessageOption();
    let data = rpc.MessageSequence.create();
    let reply = rpc.MessageSequence.create();
    let code = WIRELESS_TRUSTED_DEVICE;
    this.remoteProxy.sendMessageRequest(code, data, reply, option)
      .then((result: rpc.RequestResult) => {
        LogUtil.warn(`${TAG} sendMessageRequest result: ${result.code}`);
      })
      .catch((error: Error) => {
        LogUtil.error(`${TAG} sendMessageRequest error ${error.message}`);
      })
      .finally(() => {
        data.reclaim();
        reply.reclaim();
      });
  }

  public jumpTips(context: common.UIAbilityContext): void {

  }
}
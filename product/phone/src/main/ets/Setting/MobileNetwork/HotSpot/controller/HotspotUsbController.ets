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
import { BusinessError, commonEventManager } from '@kit.BasicServicesKit';
import {
  CompCtrlParam,
  ComponentControl,
} from '@ohos/settings.common/src/main/ets/framework/model/SettingBaseModel';
import { EventBus } from '@ohos/settings.common/src/main/ets/framework/common/EventBus';
import { LogUtil } from '@ohos/settings.common/src/main/ets/utils/LogUtil';
import {
  SettingToggleState,
  notifyCompStateChange,
  SettingStateType,
  SettingContentState,
  SettingCompState,
  SettingBaseState,
  SettingResultState,
  SettingTextState,
} from '@ohos/settings.common/src/main/ets/framework/model/SettingStateModel';
import { MASK_OPACITY, FULL_OPACITY } from '@ohos/settings.common/src/main/ets/constant/ViewConstant';
import { ItemResultType } from '@ohos/settings.common/src/main/ets/framework/model/SettingItemModel';
import { CommonEventHelper } from '@ohos/settings.common/src/main/ets/utils/CommonEventHelper';
import { HiSysEventUtil } from '@ohos/settings.common/src/main/ets/systemEvent/HiSysEventUtil';
import { HotspotDeviceGroup } from '@ohos/settings.common/src/main/ets/systemEvent/BehaviorEventConsts';

const TAG: string = 'HotspotUsbController: ';

export class HotspotUsbController implements ComponentControl {
  private toggleState: boolean = false;
  private isUsbConnected: boolean = false;
  private compId: string = '';

  private subscribeInfo: commonEventManager.CommonEventSubscribeInfo = {
    events: [
      commonEventManager.Support.COMMON_EVENT_USB_STATE,
    ]
  };

  private usbConnected: CommonEventHelper = new CommonEventHelper(this.subscribeInfo, (e, data) => {
    const connected = data.parameters?.connected as boolean;
    LogUtil.info(`${TAG} connected: ${connected} toggleState: ${this.toggleState}`);
    this.isUsbConnected = connected;
    if (!connected) {
      sharing.stopSharing(sharing.SharingIfaceType.SHARING_USB).catch((err: BusinessError) => {
        LogUtil.error(`${TAG} usbConnected stopSharing ${err}`);
      });
      if (this.toggleState) {
        this.reportBehaviorEventByUE(false);
      }
      this.setToggleState(false);
    }
    this.stateChangeNotify(this.toggleState, connected);
  });

  private setToggleState(state: boolean): void {
    this.toggleState = state;
    notifyCompStateChange(this.compId,
      new Map<SettingStateType, SettingResultState>([[SettingStateType.STATE_TYPE_ITEM_RESULT, {
        type: ItemResultType.RESULT_TYPE_TOGGLE,
        result: {
          state: state
        }
      }]]));
  }

  init(compParam: CompCtrlParam): void {
    if (!compParam || !compParam.compId) {
      LogUtil.error(`${TAG} init fail, compParam is invalid`);
      return;
    }
    LogUtil.info(`${TAG} init, compId: ${compParam.compId}`);
    this.compId = compParam.compId;
    sharing.getSharingState(sharing.SharingIfaceType.SHARING_USB).then((data: sharing.SharingIfaceState) => {
      this.toggleState = data === sharing.SharingIfaceState.SHARING_NIC_SERVING;
      LogUtil.info(`${TAG} getSharingState: ${data}`);
      this.setToggleState(this.toggleState);
      EventBus.getInstance().on(`${this.compId}.toggle`, this.onToggleChange);
      this.usbConnected.registerCommonEvent();
    }).catch((err: BusinessError) => {
      LogUtil.error(`${TAG} getSharingState error: ${err}`);
    });
  }

  private setItemEnabled(enabled: boolean): void {
    notifyCompStateChange(this.compId,
      new Map<SettingStateType, SettingBaseState>([
      [SettingStateType.STATE_TYPE_ITEM_TITLE,
      {
        opacity: enabled ? FULL_OPACITY : MASK_OPACITY
      } as SettingTextState],
        [SettingStateType.STATE_TYPE_ITEM_RESULT, {
          type: ItemResultType.RESULT_TYPE_TOGGLE,
          result: {
            enabled: enabled
          } as SettingToggleState
        } as SettingResultState]
      ]));
  }

  public getDespContent(usbState: boolean, toggleState: boolean): Resource {
    if (!usbState) {
      return $r('app.string.hotspot_usb_not_connection');
    }
    return toggleState ? $r('app.string.hotspot_already') : $r('app.string.hotspot_usb_connection');
  }

  private stateChangeNotify(toggleState: boolean, enabled: boolean): void {
    notifyCompStateChange(this.compId,
      new Map<SettingStateType, SettingBaseState>([[SettingStateType.STATE_TYPE_ITEM_DESP,
        { content: this.getDespContent(this.isUsbConnected, toggleState) } as SettingContentState]
      ]));
    this.setItemEnabled(enabled);
  }

  private reportBehaviorEventByUE(state: boolean): void {
    let reportParams: Record<string, Object> = {};
    reportParams.HOTSPOT_USB_STATE = state;
    HiSysEventUtil.reportBehaviorEventByUE(HotspotDeviceGroup.HOTSPOT_DEVICE_USB, reportParams);
  }

  private onToggleChange = (state: SettingToggleState): void => {
    LogUtil.info(`${TAG} onToggleChange ${state.state}, toggleState: ${this.toggleState}`);
    if (this.toggleState === state.state) {
      return;
    }
    this.toggleState = state.state;
    this.stateChangeNotify(state.state, false);
    this.reportBehaviorEventByUE(this.toggleState);
    if (state.state) {
      sharing.startSharing(sharing.SharingIfaceType.SHARING_USB).catch((err: BusinessError) => {
        this.setToggleState(false);
        LogUtil.error(`${TAG} startSharing ${err}`);
      }).finally(() => {
        this.setItemEnabled(this.isUsbConnected)
      });
    } else {
      sharing.stopSharing(sharing.SharingIfaceType.SHARING_USB).catch((err: BusinessError) => {
        LogUtil.error(`${TAG} stopSharing ${err}`);
      }).finally(() => {
        this.setItemEnabled(this.isUsbConnected);
      });
    }
  }

  destroy(): void {
    LogUtil.info(`${TAG} destroy`);
    this.usbConnected.unRegisterCommonEvent();
    EventBus.getInstance().detach(`${this.compId}.toggle`, this.onToggleChange);
  }
}
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

import emitter from '@ohos.events.emitter';
import wifiManager from '@ohos.wifiManager';
import {
  CompCtrlParam,
  ComponentControl,
} from '@ohos/settings.common/src/main/ets/framework/model/SettingBaseModel';
import {
  ItemResultType,
  SettingDialogModel,
  SettingItemModel,
} from '@ohos/settings.common/src/main/ets/framework/model/SettingItemModel';
import {
  notifyCompStateChange,
  SettingBaseState,
  SettingCompState,
  SettingResultState,
  SettingStateType,
} from '@ohos/settings.common/src/main/ets/framework/model/SettingStateModel';
import { LogUtil } from '@ohos/settings.common/src/main/ets/utils/LogUtil';
import { EVENT_ID_CHANGE_HOT_SPOT_QRCODE } from '@ohos/settings.common/src/main/ets/event/types';
import { EventBus } from '@ohos/settings.common/src/main/ets/framework/common/EventBus';
import { PasswordUtil } from '@ohos/settings.common/src/main/ets/utils/PasswordUtil';
import { HiSysEventUtil } from '@ohos/settings.common/src/main/ets/systemEvent/HiSysEventUtil';
import { HiSysHotspotEventGroup } from '@ohos/settings.common/src/main/ets/systemEvent/BehaviorEventConsts';
import { PADDING_0, PADDING_12, PADDING_16 } from '@ohos/settings.common/src/main/ets/constant/StyleConstant';
import { FontScaleUtils } from '@ohos/settings.common/src/main/ets/utils/FontScaleUtils';
import { CLICK_HOT_SPOT_EVENT, WeakPasswordChooseType, WeakPasswordDialogView } from '../view/WeakPasswordDialogView';
/* instrument ignore file */
@Builder
function weakPasswordDialogBuilder(param: object): void {
  WeakPasswordDialogView();
}

const TAG: string = 'HotspotPwdConfirmController';
const HOT_SPOT_PASSWORD_ENTRY: string = 'Setting.hotspot_data_entry.hotspot_devices_info.password_entry';
// 解决输入法拉起后立刻消失的问题
const SHEET_DISMISS_DELAY: number = 600;

export class HotspotPwdConfirmController implements ComponentControl {
  private hotspotPassword: string = '';
  private callBack = (state: string) => {
    if (state === WeakPasswordChooseType.CONTINUE_USE) {
      this.changeHotspotPwd(this.hotspotPassword);
      emitter.emit({
        eventId: EVENT_ID_CHANGE_HOT_SPOT_QRCODE,
        priority: emitter.EventPriority.IMMEDIATE,
      });
      setTimeout(() => {
        this.closeSheet();
      }, SHEET_DISMISS_DELAY);
      notifyCompStateChange(HOT_SPOT_PASSWORD_ENTRY, new Map(
        [[SettingStateType.STATE_TYPE_ITEM_DIALOG, {} as SettingBaseState]]
      ));
    }
  };

  init(compParam: CompCtrlParam): void {
    LogUtil.info(`${TAG} init`);
    EventBus.getInstance().on(CLICK_HOT_SPOT_EVENT, this.callBack);
  }

  destroy(): void {
    LogUtil.info(`${TAG} destroy`);
    EventBus.getInstance().detach(CLICK_HOT_SPOT_EVENT, this.callBack);
  }

  public dealClick(hotspotPassword: string): void {
    this.hotspotPassword = hotspotPassword;
    if (PasswordUtil.isWeakPasswords(hotspotPassword) || PasswordUtil.isOnlyNumber(hotspotPassword)) {
      this.openSafeTipsDialog();
    } else {
      this.changeHotspotPwd(hotspotPassword);
      emitter.emit({
        eventId: EVENT_ID_CHANGE_HOT_SPOT_QRCODE,
        priority: emitter.EventPriority.IMMEDIATE,
      });
      // 关闭半模态
      this.closeSheet();
    }
  }

  changeHotspotPwd(hotspotPwd: string): void {
    if (!hotspotPwd) {
      LogUtil.error(`${TAG} changeHotspotPwd error`);
      return;
    }
    HiSysEventUtil.reportDefaultBehaviorEventByUE(HiSysHotspotEventGroup.UPDATE_HOTSPOT_PASSWORD);
    try {
      let config: wifiManager.HotspotConfig = wifiManager.getHotspotConfig();
      config.preSharedKey = hotspotPwd;
      if (wifiManager.isHotspotActive()) {
        wifiManager.disableHotspot();
        wifiManager.setHotspotConfig(config);
        wifiManager.enableHotspot();
      } else {
        wifiManager.setHotspotConfig(config);
      }
    } catch (err) {
      LogUtil.error(`${TAG} setHotspotConfig error: ${err}`);
      return;
    }
    notifyCompStateChange(HOT_SPOT_PASSWORD_ENTRY,
      new Map<SettingStateType, SettingResultState>(
        [[SettingStateType.STATE_TYPE_ITEM_RESULT, {
          type: ItemResultType.RESULT_TYPE_TEXT,
          result: {
            content: hotspotPwd,
          },
        } as SettingResultState]]
      ));
  }

  private openSafeTipsDialog(): void {
    let state = new Map<SettingStateType, SettingDialogModel>([[SettingStateType.STATE_TYPE_ITEM_DIALOG,
      {
        contentBuilder: wrapBuilder(weakPasswordDialogBuilder),
        title: $r('app.string.weak_password_dialog_title'),
        buttons: [
          {
            value: $r('app.string.weak_password_dialog_negative_button'),
            style: { buttonStyle: ButtonStyleMode.TEXTUAL, padding: { start: PADDING_0, end: PADDING_0 } },
            action: (component: SettingItemModel) => {
              EventBus.getInstance().emit(CLICK_HOT_SPOT_EVENT, WeakPasswordChooseType.CONTINUE_USE);
            },
          },
          {
            value: $r('app.string.weak_password_dialog_positive_button'),
            style: { buttonStyle: ButtonStyleMode.TEXTUAL, padding: { start: PADDING_0, end: PADDING_0 } },
            action: (component: SettingItemModel) => {
              EventBus.getInstance().emit(CLICK_HOT_SPOT_EVENT, WeakPasswordChooseType.RESET);
            },
          },
        ],
        buttonVertical: !FontScaleUtils.isExtraLargeFontMode(),
      } as SettingDialogModel]]);
    notifyCompStateChange(HOT_SPOT_PASSWORD_ENTRY, state);
  }

  private closeSheet(): void {
    // 关闭半模态
    notifyCompStateChange(HOT_SPOT_PASSWORD_ENTRY,
      new Map<SettingStateType, SettingBaseState>([[SettingStateType.STATE_TYPE_ITEM_SHEET,
        {
          state: false,
        } as SettingCompState]]
      ));
  }
}
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


import { LogUtil } from '@ohos/settings.common/src/main/ets/utils/LogUtil';
import { NavEntryKey } from '@ohos/settings.common/src/main/ets/utils/Consts';
import { CompCtrlParam, ComponentControl } from '@ohos/settings.common/src/main/ets/framework/model/SettingBaseModel';
import {
  notifyCompStateChange,
  SettingBaseState,
  SettingStateType,
  SettingTextState,
  SettingLayoutState,
} from '@ohos/settings.common/src/main/ets/framework/model/SettingStateModel';
import { SystemParamUtils } from '@ohos/settings.common/src/main/ets/screenReader/utils/SystemParamUtils';
import { ResourceUtil } from '@ohos/settings.common/src/main/ets/utils/ResourceUtil';
import { ToastUtil } from '@ohos/settings.common/src/main/ets/utils/ToastUtil';
import { PageRouter } from '@ohos/settings.common/src/main/ets/framework/common/PageRouter';
import { MASK_OPACITY, FULL_OPACITY } from '@ohos/settings.common/src/main/ets/constant/ViewConstant';
/* instrument ignore file */
export class VpnGroupController implements ComponentControl {
  public compId: string = '';
  public isForbidVpn: boolean = false;
  init(compParam: CompCtrlParam): void {
    LogUtil.info(`VpnGroupController init`);
    this.compId = compParam?.compId;
  }

  destroy(): void {
  }

  onClick(): void {
    if (this.isForbidVpn == true) {
      ToastUtil.handleMultiToast(ResourceUtil.getStringSync($r('app.string.reset_factory_disabled_toast')),
        ToastUtil.SHORT_DURATION);
    } else {
      PageRouter.push(NavEntryKey.VPN_SETTINGS_ENTRY);
    }
  };

  setVpnState(): void {
    let isDisableVpn: boolean =
      SystemParamUtils.getSystemParam('persist.edm.vpn_disable', 'false') === 'true';
    if (this.isForbidVpn === isDisableVpn) {
      return;
    }
    this.isForbidVpn = isDisableVpn;
    notifyCompStateChange(this.compId,
      new Map<SettingStateType, SettingBaseState>([
        [SettingStateType.STATE_TYPE_ITEM_TITLE,
          {
            opacity: this.isForbidVpn ? MASK_OPACITY : FULL_OPACITY
          } as SettingTextState],
        [SettingStateType.STATE_TYPE_ITEM_LAYOUT,
        {
          background: {
            pressedBackgroundColor: this.isForbidVpn ? Color.Transparent : $r('sys.color.ohos_id_color_click_effect')
          }
        } as SettingLayoutState]]));
  }
}
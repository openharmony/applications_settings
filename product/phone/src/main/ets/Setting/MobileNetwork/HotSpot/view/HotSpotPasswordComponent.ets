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

import wifiManager from '@ohos.wifiManager';
import { TextInputMenuStyle } from '@ohos/settings.common/src/main/ets/core/model/menu/BaseMenu';
import { SettingGroupModel } from '@ohos/settings.common/src/main/ets/framework/model/SettingGroupModel';
import {
  notifyCompStateChange,
  SettingBaseState,
  SettingStateType,
} from '@ohos/settings.common/src/main/ets/framework/model/SettingStateModel';
import { InputComponent } from '@ohos/settings.commonUikit/src/main/ets/component/InputComponent';
import { LogUtil } from '@ohos/settings.common/src/main/ets/utils/LogUtil';
import { EventBus } from '@ohos/settings.common/src/main/ets/framework/common/EventBus';
import {
  EapPasswordTextInputStyle,
  EapPasswordInputStyle,
  EapPasswordTextDividerStyle,
} from '@ohos/settings.commonUikit/src/main/ets/InputStyle';
import { CLICK_HOT_SPOT_EVENT, WeakPasswordChooseType } from './WeakPasswordDialogView';
/* instrument ignore file */
let eapPasswordTextInputStyle: EapPasswordTextInputStyle = new EapPasswordTextInputStyle();

let eapPasswordInputStyle: EapPasswordInputStyle = new EapPasswordInputStyle();

let dividerStyle: EapPasswordTextDividerStyle = new EapPasswordTextDividerStyle();

const TAG: string = 'HotSpotPasswordComponent:';

const HOT_SPOT_PSW_INPUT_CHANGE: string = 'HOT_SPOT_PSW_INPUT_CHANGE';

const REAL_MAX_PWD_LENGTH: number = 63;

const HOT_SPOT_PASSWORD_ENTRY: string = 'Setting.hotspot_data_entry.hotspot_devices_info.password_entry';

@Component
export struct HotSpotPasswordComponent {
  item ?: object;
  private hint: ResourceStr = $r('app.string.hotspot_password');
  @State showPasswordComponent: boolean = true;
  @State content: ResourceStr = '';
  @State dividerBackgroundColor: Resource = $r('sys.color.comp_background_tertiary');
  private callBack = (state: string) => {
    if (state === WeakPasswordChooseType.RESET) {
      notifyCompStateChange(HOT_SPOT_PASSWORD_ENTRY, new Map(
        [[SettingStateType.STATE_TYPE_ITEM_DIALOG, {} as SettingBaseState]]
      ));
      LogUtil.info(`${TAG} clear password.`);
      this.content = '';
    }
  }

  build() {
    InputComponent({
      hint: this.hint,
      content: this.content,
      showCancelButton: true,
      enablePreviewText: false,
      showPassword: true,
      showPasswordIcon: false,
      onChange: (input: string) => {
        this.content = input;
        this.inputChange(input);
      },
      showComponent: this.showPasswordComponent,
      style: this.getStyle(),
    })
  }

  aboutToAppear(): void {
    this.initStyle();
    try {
      let config: wifiManager.HotspotConfig = wifiManager.getHotspotConfig();
      this.content = config.preSharedKey;
    } catch (error) {
      LogUtil.error(`${TAG} getHotspotConfig fail, ${error?.message}`);
    }
    EventBus.getInstance().on(CLICK_HOT_SPOT_EVENT, this.callBack);
  }

  initStyle(): void {
    eapPasswordInputStyle.padding = {
      left: $r('sys.float.padding_level5'),
    }
    dividerStyle.size = {
      width: 'calc(100% - 24vp)',
      height: $r('app.float.length_1'),
    }
    eapPasswordTextInputStyle.textInputStyle = eapPasswordInputStyle;
    eapPasswordTextInputStyle.dividerStyle = dividerStyle;
    eapPasswordInputStyle.maxLength = REAL_MAX_PWD_LENGTH;
    eapPasswordInputStyle.inputType = InputType.Password;
  }

  aboutToDisappear(): void {
    EventBus.getInstance().detach(CLICK_HOT_SPOT_EVENT, this.callBack);
  }

  private getStyle(): TextInputMenuStyle {
    return eapPasswordTextInputStyle;
  }

  private inputChange(input: string): void {
    EventBus.getInstance().emit(HOT_SPOT_PSW_INPUT_CHANGE, input);
  }
}
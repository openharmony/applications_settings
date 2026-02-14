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
import wifiManager from '@ohos.wifiManager';
import { LogUtil } from '@ohos/settings.common/src/main/ets/utils/LogUtil';
import { SettingGroupModel } from '@ohos/settings.common/src/main/ets/framework/model/SettingGroupModel';
import { EventBus } from '@ohos/settings.common/src/main/ets/framework/common/EventBus';
import {
  NewDefaultTextInputMenuStyle,
  NewTextInputStyle,
  TextInputMenuStyle,
  TextInputStyle
} from '@ohos/settings.commonUikit/src/main/ets/InputStyle';
import { WLAN_CONFIG_INPUT_CHANGE_EVENT, WLAN_PSW_ENTER_EVENT } from '../model/WifiModel';
import { WifiPasswordConfigManager } from '../WifiPasswordConfigManager';
import { AddOtherWlanConfigManager } from '../AddOtherWlanConfigManager';
import { WIFI_EAP_DOMAIN, WIFI_EAP_IDENTITY } from '../WifiMenuManager';

export const WLAN_PROXY_INPUT_CHANGE: string = 'wifi_proxy_input_change';

let newDefaultTextInputMenuStyle: NewDefaultTextInputMenuStyle = new NewDefaultTextInputMenuStyle();

let newDefaultTextInputStyle: NewTextInputStyle = new NewTextInputStyle();

@Extend(TextInput)
function textInputStyle(textInputStyle?: TextInputStyle) {
  .type(textInputStyle?.inputType)
  .copyOption(textInputStyle?.inputType === InputType.Password ? CopyOptions.None : CopyOptions.LocalDevice)
  .placeholderColor(textInputStyle?.placeholderColor)
  .placeholderFont(textInputStyle?.placeholderFont)
  .caretColor(textInputStyle?.caretColor)
  .constraintSize(textInputStyle?.constraintSize)
  .borderRadius(textInputStyle?.borderRadius as Length)
  .padding(textInputStyle?.padding as Padding)
  .margin(textInputStyle?.margin as Padding)
  .maxLength(textInputStyle?.maxLength ?? 1000)
  .backgroundColor(textInputStyle?.backgroundColor)
  .textAlign(textInputStyle?.textAlign)
  .fontColor(textInputStyle?.fontColor)
  .fontSize(textInputStyle?.fontSize?.size)
  .fontFamily(textInputStyle?.fontSize?.family)
  .fontWeight(textInputStyle?.fontSize?.weight)
  .showUnderline(textInputStyle?.showUnderline ?? false)
}

const TAG: string = 'EapInputComponent : ';

@Component
export struct EapInputComponent {
  private item?: object;
  public eapConfig?: wifiManager.WifiEapConfig;
  private groupModel?: SettingGroupModel;
  private hint: ResourceStr = $r('app.string.please_enter');
  private content: ResourceStr = '';

  build() {
    Column() {
      TextInput({
        placeholder: this.hint,
        text: this.content,
      })
        .enablePreviewText(false)
        .defaultFocus(true)
        .textInputStyle(this.getStyle()?.textInputStyle)
        .constraintSize({
          minHeight: 32,
        })
        .onSubmit((enterKeyType: EnterKeyType) => {
          if (enterKeyType === EnterKeyType.Done) {
            EventBus.getInstance().emit(WLAN_PSW_ENTER_EVENT);
          }
        })
        .copyOption(CopyOptions.LocalDevice)
        .inputFilter(this.getStyle()?.textInputStyle?.inputFilter ?? '')
        .onChange((input: string) => {
          this.onChange(input, this.groupModel?.id);
        })
        .borderRadius($r('sys.float.corner_radius_none'))
    }
    .constraintSize({
      maxWidth: '56%',
    })
    .width('100%')
  }

  aboutToAppear(): void {
    LogUtil.info(`${TAG} aboutToAppear.`);
    this.groupModel = this.item as SettingGroupModel;
    if (WifiPasswordConfigManager.getInstance().getConfig()) {
      this.eapConfig = WifiPasswordConfigManager.getInstance().getConfig()?.eapConfig;
    } else {
      this.eapConfig = AddOtherWlanConfigManager.getInstance().getConfig()?.eapConfig;
    }
  }

  aboutToDisappear(): void {
    LogUtil.info(`${TAG} aboutToDisappear.`);
  }

  onChange(input: string, id?: string): void {
    if (this.eapConfig === undefined) {
      LogUtil.error(`${TAG} onChange, eapConfig is invalid`);
      return;
    }
    if (id === WIFI_EAP_DOMAIN) {
      this.eapConfig.domainSuffixMatch = input;
      EventBus.getInstance().emit(WLAN_CONFIG_INPUT_CHANGE_EVENT);
    } else if (id === WIFI_EAP_IDENTITY) {
      this.eapConfig.identity = input;
    } else {
      this.eapConfig.anonymousIdentity = input;
    }
  }

  private getStyle(): TextInputMenuStyle {
    newDefaultTextInputStyle.textAlign = TextAlign.End;
    newDefaultTextInputStyle.constraintSize = {
      minHeight: 32,
    };
    newDefaultTextInputStyle.fontSize = {
      size: $r('sys.float.Body_M'),
      weight: FontWeight.Regular,
      family: 'HarmonyHeiTi',
    };
    newDefaultTextInputStyle.placeholderFont = {
      size: $r('sys.float.Body_M'),
      weight: FontWeight.Regular,
      family: 'HarmonyHeiTi',
    };
    newDefaultTextInputStyle.padding = {
      left: $r('sys.float.padding_level0'),
      right: $r('sys.float.padding_level0'),
      bottom: $r('sys.float.padding_level0'),
      top: $r('sys.float.padding_level0'),
    }
    newDefaultTextInputMenuStyle.textInputStyle = newDefaultTextInputStyle;
    return newDefaultTextInputMenuStyle;
  }
}
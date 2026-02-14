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
import { DeviceUtil } from '@ohos/settings.common/src/main/ets/utils/BaseUtils';
import { FontScaleUtils } from '@ohos/settings.common/src/main/ets/utils/FontScaleUtils';
import { PADDING_0, PADDING_12, PADDING_16 } from '@ohos/settings.common/src/main/ets/constant/StyleConstant';
import { IProxySettingParameters } from '../model/IProxySettingParameters';

@Component
export struct CustomTextInputArea {
  @Link useProxy: boolean;
  @Link proxyParametersInfo: IProxySettingParameters;
  @Link errorInputKeys: string[];
  @State borderFlag: boolean = true;
  @State isFocused: boolean = false;
  private name: Resource = $r('app.string.proxy_server_port');
  private inputHint: Resource = $r('app.string.proxy_server_host_name_hint');
  private customKey: string = '';
  private type: string = '';
  private textAreaController: TextAreaController = new TextAreaController();

  build() {
    if (this.type === 'textInput') {
      Flex({
        justifyContent: FlexAlign.SpaceBetween,
        alignItems: ItemAlign.Center,
        wrap: FontScaleUtils.isExtraLargeFontMode() ? FlexWrap.Wrap : FlexWrap.NoWrap
      }) {
        Text(this.name)
          .fontWeight(FontWeight.Medium)
          .fontSize($r('sys.float.Body_L'))
          .fontColor(this.useProxy ? $r('sys.color.font_primary') :
          $r('sys.color.font_tertiary'))
          .draggable(false)
          .margin({ end: PADDING_16 })
          .flexShrink(0)

        TextInput({
          text: (this.proxyParametersInfo as Record<string, string>)[this.customKey],
          placeholder: this.inputHint
        })
          .placeholderColor(this.useProxy ? $r('sys.color.font_secondary') : $r('sys.color.font_tertiary'))
          .fontWeight(FontWeight.Regular)
          .fontSize($r('sys.float.Body_M'))
          .fontColor(this.useProxy ? (this.isFocused ? $r('sys.color.font_primary') :
          $r('sys.color.font_secondary')) : $r('sys.color.font_tertiary'))
          .flexGrow(1)
          .constraintSize({
            minHeight: $r('app.float.height_40')
          })
          .focusable(this.useProxy)
          .enableKeyboardOnFocus(true)
          .key(this.customKey)
          .hitTestBehavior(this.useProxy ? HitTestMode.Default : HitTestMode.Block)
          .draggable(false)
          .onChange((val) => {
            (this.proxyParametersInfo as Record<string, string>)[this.customKey] = val;
          })
          .onFocus(() => {
            this.borderFlag = false;
            this.isFocused = true;
          })
          .defaultFocus(true)
          .textAlign(FontScaleUtils.isExtraLargeFontMode() ? TextAlign.Start : TextAlign.End)
          .padding({
            start: FontScaleUtils.isExtraLargeFontMode() ? PADDING_0 : PADDING_12
          })
          .borderRadius(FontScaleUtils.isExtraLargeFontMode() ? $r('sys.float.corner_radius_none') : undefined)
          .backgroundColor(Color.Transparent)
          .onBlur(() => {
            this.borderFlag = true;
            this.isFocused = false;
          })
      }
      .constraintSize({ minHeight: DeviceUtil.isDevicePc() ? $r('app.float.height_40') : $r('app.float.height_48') })
      .padding({
        top: FontScaleUtils.isExtraLargeFontMode() ? FontScaleUtils.getCurrentTopPadding() :
        $r('sys.float.padding_level0'),
        bottom: FontScaleUtils.isExtraLargeFontMode() ? FontScaleUtils.getCurrentTopPadding() :
        $r('sys.float.padding_level0')
      })

      this.dividerBuilder();
    } else if (this.type === 'textArea') {
      this.ignoreHostListItem();
    }
  }

  @Builder
  dividerBuilder() {
    Row() {
      Divider()
        .color(this.needShowRedDivider(this.customKey) && this.borderFlag ? $r('sys.color.warning') :
        $r('sys.color.comp_divider'))
    }
    .margin({ end: PADDING_12 })
  }

  @Builder
  ignoreHostListItem() {
    Flex({ justifyContent: FlexAlign.SpaceBetween, alignItems: ItemAlign.Center }) {
      Text($r('app.string.proxy_setting_ignore_host'))
        .fontWeight(FontWeight.Medium)
        .fontSize($r('sys.float.Body_L'))
        .draggable(false)
        .fontColor(this.useProxy ? $r('sys.color.font_primary') :
        $r('sys.color.font_tertiary'))
        .textAlign(TextAlign.Start)
        .constraintSize({ minHeight: DeviceUtil.isDevicePc() ? $r('app.float.height_40') : $r('app.float.height_48') })
        .margin({ end: PADDING_12 })
        .padding({
          top: FontScaleUtils.getCurrentTopPadding(),
          bottom: FontScaleUtils.getCurrentTopPadding()
        })
    }

    Flex({ justifyContent: FlexAlign.SpaceBetween, alignItems: ItemAlign.Center }) {
      TextArea({
        text: (this.proxyParametersInfo as IProxySettingParameters).ignoreHostList,
        placeholder: '',
        controller: this.textAreaController
      })
        .height($r('app.float.height_64'))
        .fontSize($r('sys.float.Body_L'))
        .fontColor(this.useProxy ? (this.isFocused ? $r('sys.color.font_primary') :
        $r('sys.color.font_secondary')) : $r('sys.color.font_tertiary'))
        .borderRadius($r('sys.float.corner_radius_level4'))
        .focusable(this.useProxy)
        .hitTestBehavior(this.useProxy ? HitTestMode.Default : HitTestMode.Block)
        .draggable(false)
        .border((this.errorInputKeys.includes(this.customKey) && this.useProxy && this.borderFlag) ?
          { width: $r('app.float.length_1'), color: $r('sys.color.warning') } :
          { width: $r('app.float.length_0'), color: Color.Transparent })
        .onChange((value: string) => {
          this.proxyParametersInfo.ignoreHostList = value;
        })
        .onFocus(() => {
          this.borderFlag = false;
          this.isFocused = true;
        })
        .onBlur(() => {
          this.borderFlag = true;
          this.isFocused = false;
        })
        .key(this.customKey)
        .margin({ end: PADDING_12 })
    }
  }

  private needShowRedDivider(key: string): boolean {
    let v: boolean = this.errorInputKeys.includes(key);
    return v;
  }
}
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
import ethernet from '@ohos.net.ethernet';
import { DeviceUtil } from '@ohos/settings.common/src/main/ets/utils/BaseUtils';
import { FontScaleUtils } from '@ohos/settings.common/src/main/ets/utils/FontScaleUtils';
import { LanguageUtils } from '@ohos/settings.common/src/main/ets/utils/LanguageUtils';
import { PADDING_0, PADDING_12, PADDING_16 } from '@ohos/settings.common/src/main/ets/constant/StyleConstant';
import { EthernetUtil } from '../util/EthernetUtil';
import { IEthernetInterfaceInfo } from '../model/IEthernetInterfaceInfo';

@Component
struct BuildNetIfcListItem {
  @State name: Resource = $r('app.string.ip_address');
  @State inputHint: Resource = $r('app.string.ip_address_hint');
  @State customKey: string = '';
  @Link currentEthIfcInfo: IEthernetInterfaceInfo;
  @Link paramEthIfcInfo: IEthernetInterfaceInfo;
  @Link errorInputKeys: string[];
  @State currentFocusKey: string = '';
  @State borderFlag: boolean = true;
  @Prop showDivider: boolean = true;

  build() {
    Column() {
      Flex({
        justifyContent: FlexAlign.SpaceBetween, alignItems: ItemAlign.Center,
        wrap: FontScaleUtils.isExtraLargeFontMode() ? FlexWrap.Wrap : FlexWrap.NoWrap
      }) {
        Text(this.name)
          .fontWeight(FontWeight.Medium)
          .fontSize($r('sys.float.Body_L'))
          .fontColor($r('sys.color.font_primary'))
          .flexShrink(0)
          .margin({ end: PADDING_16 })
          .maxLines(FontScaleUtils.isExtraLargeFontMode() ? undefined : 1)

        if (this.currentEthIfcInfo.mode === ethernet.IPSetMode.DHCP) {
          // DHCP模式 只读
          Text(this.paramEthIfcInfo[this.customKey])
            .fontWeight(FontWeight.Regular)
            .fontSize($r('sys.float.Body_M'))
            .copyOption(1)
            .fontColor($r('sys.color.font_secondary'))
            .key(this.customKey)
            .textAlign(FontScaleUtils.isExtraLargeFontMode() ? TextAlign.Start : TextAlign.End)
        } else {
          // 手动输入
          this.manualInput();
        }
      }
      .constraintSize({
        minHeight: DeviceUtil.isDevicePc() ? $r('app.float.height_40') : $r('app.float.height_48')
      })
      .margin({
        start: PADDING_12,
        end: (this.currentEthIfcInfo.mode === ethernet.IPSetMode.DHCP) ?
          PADDING_12 : PADDING_0
      })
      .padding({
        top: FontScaleUtils.isExtraLargeFontMode() ? FontScaleUtils.getCurrentTopPadding() :
        $r('sys.float.padding_level0'),
        bottom: FontScaleUtils.isExtraLargeFontMode() ? FontScaleUtils.getCurrentTopPadding() :
        $r('sys.float.padding_level0')
      })

      this.dividerBuilder();
    }
  }

  @Builder
  dividerBuilder() {
    if (this.showDivider === true || this.isNeedBorder(this.customKey)) {
      Row() {
        Divider()
          .color(this.isNeedBorder(this.customKey) && this.borderFlag ? $r('sys.color.warning')
            : $r('sys.color.comp_divider'))
      }
      .margin({ left: $r('sys.float.padding_level6'), right: $r('sys.float.padding_level6') })
    }
  }

  @Builder
  manualInput() {
    // 手动输入
    TextInput({
      text: this.currentEthIfcInfo[this.customKey],
      placeholder: this.inputHint
    })
      .fontWeight(FontWeight.Regular)
      .key(this.customKey)
      .fontSize($r('sys.float.Body_M'))
      .fontColor(this.currentFocusKey === this.customKey ? $r('sys.color.font_primary') :
      $r('sys.color.font_secondary'))
      .enableKeyboardOnFocus(true)
      .flexGrow(1)
      .constraintSize({
        minHeight: DeviceUtil.isDevicePc() ? $r('app.float.height_40') : $r('app.float.height_48')
      })
      .inputFilter('^[0-9.]*')
      .copyOption(1)
      .draggable(false)
      .onFocus(() => {
        this.currentFocusKey = this.customKey;
        this.borderFlag = false;
      })
      .onBlur(() => {
        if (EthernetUtil.isVarStringType(this.currentEthIfcInfo[this.customKey])) {
          this.currentEthIfcInfo[this.customKey] = this.currentEthIfcInfo[this.customKey].split('.')
            .map((item: string) => {
              const str: string = item.replace(new RegExp('/[^0-9.]/g'), '');
              return str === '' ? '' : BigInt(str);
            })
            .join('.');
        }
        this.currentFocusKey = '';
        this.borderFlag = true;
      })
      .onChange((val) => {
        this.currentEthIfcInfo[this.customKey] = val;
      })
      .textAlign(FontScaleUtils.isExtraLargeFontMode() ? TextAlign.Start : TextAlign.End)
      .padding({
        start: FontScaleUtils.isExtraLargeFontMode() && LanguageUtils.isLtrDirection() ? PADDING_0 : PADDING_12
      })
      .borderRadius(FontScaleUtils.isExtraLargeFontMode() ? $r('sys.float.corner_radius_none') : undefined)
      .backgroundColor(Color.Transparent)
  }

  private isNeedBorder(key: string): boolean {
    if (this.currentEthIfcInfo.mode === ethernet.IPSetMode.DHCP) {
      return false;
    }
    let result: boolean = this.errorInputKeys.includes(key);
    return result;
  }
}

export { BuildNetIfcListItem }
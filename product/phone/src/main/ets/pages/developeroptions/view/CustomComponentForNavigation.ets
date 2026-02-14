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

import { PADDING_12 } from '@ohos/settings.common/src/main/ets/constant/StyleConstant';
import { DeviceUtil } from '@ohos/settings.common/src/main/ets/utils/BaseUtils';
import { LanguageUtils } from '@ohos/settings.common/src/main/ets/utils/LanguageUtils';
/* instrument ignore file */
const IS_PC: boolean = DeviceUtil.isDevicePc();
const IS_LTR: boolean = LanguageUtils.isLtrDirection();
const INPUT_MAX_LENGTH: number = 100;

@Extend(Text)
function textPrimaryStyle() {
  .fontColor($r('sys.color.font_primary'))
  .fontSize($r('sys.float.Body_L'))
  .fontFamily('HarmonyHeiTi')
  .fontWeight(FontWeight.Medium)
  .textAlign(TextAlign.Start)
  .textOverflow({ overflow: TextOverflow.Ellipsis })
  .maxLines(2)
}

@Extend(Row)
function heightAndRadiusStyle() {
  .borderRadius(IS_PC ? $r('sys.float.corner_radius_level8') :
  $r('sys.float.corner_radius_level10'))
}

@Component
export struct TextWithInput {
  title: Resource | string = '';
  textInputId: string = '';
  inputType: number | undefined = undefined;
  inputPlaceholder: Resource | string = '';
  maxLength: number = INPUT_MAX_LENGTH;
  @Prop inputText: string = '';
  @Prop unit: string = '';
  @Prop maxWidth: string = '';
  @Prop isShowUnderline: boolean = true;
  @State fontColor: ResourceColor = $r('sys.color.font_primary');
  onChange: (value: string) => void = () => {};

  build() {
    Flex({
      direction: FlexDirection.Row,
      wrap: FlexWrap.Wrap,
      alignItems: ItemAlign.Center,
      alignContent: FlexAlign.Center
    }) {
      Row() {
        Text(this.title)
          .textPrimaryStyle()
          .constraintSize({ maxWidth: '100%' })
          .direction(!IS_LTR ? Direction.Rtl : Direction.Ltr)
      }
      .flexShrink(0)
      .justifyContent(FlexAlign.Center)
      .constraintSize({
        minHeight: '46vp',
      })
      .padding({
        top: PADDING_12,
        bottom: PADDING_12,
        start: PADDING_12,
      })

      Column() {
        Row({ space: 0 }) {
          TextInput({ placeholder: this.inputPlaceholder, text: this.inputText })
            .type(InputType.NUMBER_DECIMAL)
            .maxLength(this.maxLength)
            .fontColor(this.fontColor)
            .placeholderFont({ size: $r('sys.float.Body_L'), weight: FontWeight.Regular, family: 'HarmonyHeiTi' })
            .fontSize($r('sys.float.Body_L'))
            .fontFamily('HarmonyHeiTi')
            .fontWeight(FontWeight.Regular)
            .textAlign(TextAlign.Start)
            .backgroundColor(Color.Transparent)
            .maxLines(1)
            .inputFilter('^[0-9]*\.?[0-9]*$', (e) => {
              console.log(JSON.stringify(e))
            })
            .layoutWeight(1)
            .padding({ left: 12, right: 4 })
            .direction(!IS_LTR ? Direction.Rtl : Direction.Ltr)
            .id(this.textInputId)
            .onChange((value: string) => {
              this.onChange(value);
            })
            .onWillChange((value: EditableTextChangeValue) => {
              return this.willChange(value?.content);
            })
            .width('auto')

          Text(this.unit)
            .fontSize($r('sys.float.Body_L'))
            .fontFamily('HarmonyHeiTi')
            .fontWeight(FontWeight.Regular)
            .fontColor(this.fontColor)
            .backgroundColor(Color.Transparent)
            .visibility(this.inputText !== '' ? Visibility.Visible : Visibility.None)
        }
        Divider()
          .strokeWidth('1px')
          .width(0)
          .alignSelf(ItemAlign.Stretch)
          .padding({ left: IS_LTR ? 12 : 0 })
          .visibility(this.isShowUnderline ? Visibility.Visible : Visibility.None)
      }
      .alignItems(HorizontalAlign.Start)
      .flexGrow(1)
      .flexShrink(1)
      .padding({ right: 12 , left: !IS_LTR ? 12 : 0})
    }
  }

  private willChange(value: string): boolean {
    const numericValue = Number(value);
    return !isNaN(numericValue);
  }
}

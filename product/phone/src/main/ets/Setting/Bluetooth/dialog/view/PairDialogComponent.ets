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
import { LogUtil } from '@ohos/settings.common/src/main/ets/utils/LogUtil';
import { PADDING_12 } from '@ohos/settings.common/src/main/ets/constant/StyleConstant';
import { SimUtils } from '@ohos/settings.common/src/main/ets/utils/SimUtils';
import { BluetoothAdapter } from '@ohos/settings.bluetooth/src/main/ets/BluetoothAdapter';
import { PinType } from '@ohos/settings.bluetooth/src/main/ets/model/BluetoothModel';
import { PairDialogController } from '../controller/PairDialogController';

const TAG: string = 'PairDialogComponent: ';

@CustomDialog
export struct PairDialogComponent {
  deviceId: string = '';
  pinCode: string = '';
  pinType: number = -1;
  content: ResourceStr = '';
  deviceName: string = '';
  checkBoxState: boolean = false;
  input: string = '';
  pairDialogController?: PairDialogController;
  controller?: CustomDialogController;
  private isOnClick: boolean = false;

  build() {
    Column() {
      this.dialogContentBuilder();
    }
    .width('100%')
    .height('100%')
    .justifyContent(FlexAlign.Center)
    .padding({
      left: $r('sys.float.padding_level8'),
      right: $r('sys.float.padding_level8'),
    })
  }

  @Builder
  dialogContentBuilder() {
    Column() {
      this.titleBuilder()
      Scroll() {
        if (this.pinType === PinType.PAIRING_VARIANT_PASSKEY_CONFIRMATION) {
          this.contentForPinType2Builder()
        } else if (this.pinType === PinType.PAIRING_VARIANT_CONSENT ||
          this.pinType === PinType.PAIRING_VARIANT_OOB_CONSENT) {
          this.contentForPinType36Builder();
        } else if (this.pinType === PinType.PAIRING_VARIANT_DISPLAY_PASSKEY ||
          this.pinType === PinType.PAIRING_VARIANT_DISPLAY_PIN) {
          this.contentForPinType45Builder();
        } else if (this.pinType === PinType.PAIRING_VARIANT_PIN ||
          this.pinType === PinType.PAIRING_VARIANT_PIN_16_DIGITS) {
          this.contentForPinType07Builder();
        } else if (this.pinType === PinType.PAIRING_VARIANT_PASSKEY) {
          this.contentForPinType1Builder();
        }
      }
      .scrollable(ScrollDirection.Vertical)
      .scrollBar(BarState.Auto)
      .edgeEffect(EdgeEffect.Spring)
      .constraintSize({
        maxHeight: '50%'
      })

      this.buttonBuilder()
    }
    .backgroundColor($r('sys.color.ohos_id_color_dialog_bg'))
    .backgroundBlurStyle(BlurStyle.COMPONENT_ULTRA_THICK)
    .saturate(0.9)
    .alignItems(HorizontalAlign.Start)
    .borderRadius($r('sys.float.corner_radius_level16'))
    .constraintSize({
      maxWidth: 400,
    })
    .width('100%')
  }

  @Builder
  titleBuilder() {
    Row() {
      Text($r('app.string.bt_pair_required_title'))
        .fontFamily('HarmonyHeiTi')
        .fontWeight(FontWeight.Bold)
        .fontSize('20fp')
        .maxFontScale(2)
        .fontColor($r('sys.color.font_primary'))
        .lineHeight(27)
        .textAlign(TextAlign.Center)
        .maxLines(2)
        .textOverflow({ overflow: TextOverflow.Ellipsis })
    }
    .alignItems(VerticalAlign.Center)
    .justifyContent(FlexAlign.Center)
    .width('100%')
    .padding({
      top: 15,
      bottom: 15,
      left: 24,
      right: 24,
    })
  }

  @Builder
  contentForPinType2Builder() {
    Column() {
      Text(this.content)
        .fontFamily('HarmonyHeiTi')
        .fontWeight(FontWeight.Regular)
        .fontSize($r('sys.float.Body_L'))
        .fontColor($r('sys.color.font_primary'))
        .lineHeight(21)
        .width('100%')

      // PIN码
      Text(this.pinCode)
        .fontFamily('HarmonyHeiTi')
        .fontWeight(FontWeight.Medium)
        .fontSize('32fp')
        .fontColor($r('sys.color.font_primary'))
        .lineHeight(43)
        .margin({
          top: $r('sys.float.padding_level6'),
          bottom: $r('sys.float.padding_level6'),
        })

      this.accessAuthorizationBuilder()
    }
    .margin({
      left: $r('sys.float.padding_level12'),
      right: $r('sys.float.padding_level12'),
    })
  }

  @Builder
  contentForPinType36Builder() {
    Column() {
      Text() {
        Span(this.content)
          .fontFamily('HarmonyHeiTi')
          .fontWeight(FontWeight.Regular)
          .fontSize($r('sys.float.Body_L'))
          .fontColor($r('sys.color.font_primary'))
          .lineHeight(21)
        Span('\n')
          .fontFamily('HarmonyHeiTi')
          .fontWeight(FontWeight.Regular)
          .fontSize($r('sys.float.Body_L'))
          .fontColor($r('sys.color.font_primary'))
        Span(this.deviceName)
          .fontFamily('HarmonyHeiTi')
          .fontWeight(FontWeight.Regular)
          .fontSize($r('sys.float.Body_L'))
          .fontColor($r('sys.color.font_primary'))
          .lineHeight(21)
      }

      this.accessAuthorizationBuilder()
    }
    .alignItems(HorizontalAlign.Start)
    .margin({
      left: $r('sys.float.padding_level12'),
      right: $r('sys.float.padding_level12'),
    })
  }

  @Builder
  contentForPinType45Builder() {
    Column() {
      Text() {
        Span(this.content)
          .fontFamily('HarmonyHeiTi')
          .fontWeight(FontWeight.Regular)
          .fontSize($r('sys.float.Body_L'))
          .fontColor($r('sys.color.font_primary'))
          .lineHeight(21)
        Span('\n')
          .fontFamily('HarmonyHeiTi')
          .fontWeight(FontWeight.Regular)
          .fontSize($r('sys.float.Body_L'))
          .fontColor($r('sys.color.font_primary'))
        Span(this.deviceName)
          .fontFamily('HarmonyHeiTi')
          .fontWeight(FontWeight.Regular)
          .fontSize($r('sys.float.Body_L'))
          .fontColor($r('sys.color.font_primary'))
          .lineHeight(21)
      }

      Text() {
        Span($r('app.string.bluetooth_pin_required_code_title'))
          .fontFamily('HarmonyHeiTi')
          .fontWeight(FontWeight.Regular)
          .fontSize($r('sys.float.Body_L'))
          .fontColor($r('sys.color.font_primary'))
          .lineHeight(21)
        Span('\n')
          .fontFamily('HarmonyHeiTi')
          .fontWeight(FontWeight.Regular)
          .fontSize($r('sys.float.Body_L'))
          .fontColor($r('sys.color.font_primary'))
        Span(this.pinCode)
          .fontFamily('HarmonyHeiTi')
          .fontWeight(FontWeight.Regular)
          .fontSize($r('sys.float.Body_L'))
          .fontColor($r('sys.color.font_primary'))
          .lineHeight(21)
      }
      .margin({
        top: $r('sys.float.padding_level8'),
      })

      Text($r('app.string.bluetooth_pin_required_please_enter_message'))
        .fontFamily('HarmonyHeiTi')
        .fontWeight(FontWeight.Regular)
        .fontSize($r('sys.float.Body_L'))
        .fontColor($r('sys.color.font_primary'))
        .lineHeight(21)
        .margin({
          top: $r('sys.float.padding_level8'),
        })

      this.accessAuthorizationBuilder()
    }
    .alignItems(HorizontalAlign.Start)
    .margin({
      left: $r('sys.float.padding_level12'),
      right: $r('sys.float.padding_level12'),
    })
  }

  @Builder
  contentForPinType07Builder() {
    Column() {
      TextInput({ text: this.input, placeholder: $r('app.string.bluetooth_usually_message') })
        .placeholderColor($r('sys.color.font_secondary'))
        .placeholderFont({ size: $r('sys.float.Body_L'), weight: FontWeight.Regular, family: 'HarmonyHeiTi', })
        .caretColor(Color.Blue)
        .defaultFocus(false)
        .width('100%')
        .constraintSize({ minHeight: '40vp' })
        .fontSize($r('sys.float.Body_L'))
        .fontColor($r('sys.color.font_secondary'))
        .margin({
          top: $r('sys.float.padding_level4'),
        })
        .onChange((value: string) => {
          this.input = value;
        })

      Flex({ justifyContent: FlexAlign.Start, alignItems: ItemAlign.Start }) {
        Text($r('app.string.bluetooth_PinConsist_message'))
          .width('100%')
          .fontSize($r('sys.float.Body_M'))
          .lineHeight(19)
          .fontColor($r('sys.color.font_primary'))
          .fontWeight(FontWeight.Regular)
          .fontFamily('HarmonyHeiTi')
          .margin({
            top: $r('sys.float.padding_level6'),
            bottom: $r('sys.float.padding_level6'),
            left: $r('sys.float.padding_level6'),
          })
      }
      .width('100%')
      .margin({
        top: $r('sys.float.padding_level4'),
      })
      .constraintSize({
        minHeight: 48,
      })

      Text($r('app.string.bluetooth_pinCode_required_message'))
        .fontFamily('HarmonyHeiTi')
        .fontWeight(FontWeight.Regular)
        .fontSize($r('sys.float.Body_L'))
        .fontColor($r('sys.color.font_primary'))
        .lineHeight(21)

      this.accessAuthorizationBuilder()
    }
    .alignItems(HorizontalAlign.Start)
    .margin({
      left: $r('sys.float.padding_level12'),
      right: $r('sys.float.padding_level12'),
    })
  }

  @Builder
  contentForPinType1Builder() {
    Column() {
      Column() {
        TextInput({ text: this.input, placeholder: $r('app.string.bluetooth_usually_message') })
          .placeholderColor($r('sys.color.font_secondary'))
          .placeholderFont({ size: $r('sys.float.Body_L'), weight: FontWeight.Regular, family: 'HarmonyHeiTi', })
          .caretColor(Color.Blue)
          .defaultFocus(false)
          .width('100%')
          .fontSize($r('sys.float.Body_L'))
          .fontColor($r('sys.color.font_secondary'))
          .constraintSize({
            minHeight: 40,
          })
          .onChange((value: string) => {
            this.input = value;
          })
      }
      .constraintSize({
        minHeight: 56,
      })
      .justifyContent(FlexAlign.Center)

      Text($r('app.string.bluetooth_pinCode_required_message'))
        .fontFamily('HarmonyHeiTi')
        .fontWeight(FontWeight.Regular)
        .fontSize($r('sys.float.Body_L'))
        .fontColor($r('sys.color.font_primary'))
        .lineHeight(21)

      this.accessAuthorizationBuilder()
    }
    .alignItems(HorizontalAlign.Start)
    .margin({
      left: $r('sys.float.padding_level12'),
      right: $r('sys.float.padding_level12'),
    })
  }

  @Builder
  buttonBuilder() {
    Row() {
      Button() {
        Text($r('app.string.cancel'))
          .fontFamily('HarmonyHeiTi')
          .fontWeight(FontWeight.Medium)
          .fontSize($r('sys.float.Body_L'))
          .fontColor($r('sys.color.font_emphasize'))
          .lineHeight(21)
          .maxFontScale(2)
          .margin({
            top: 10,
            bottom: 9,
          })
      }
      .layoutWeight(1)
      .backgroundColor(Color.Transparent)
      .onClick(() => {
        LogUtil.info(`${TAG} onClick cancel`);
        this.isOnClick = true;
        this.pairDialogController?.onCancelClick(this.deviceId, this.input);
      })

      if (this.pinType !== PinType.PAIRING_VARIANT_DISPLAY_PASSKEY &&
        this.pinType !== PinType.PAIRING_VARIANT_DISPLAY_PIN) {
        Divider()
          .vertical(true)
          .height(24)
          .strokeWidth(px2vp(2))
          .color($r('sys.color.comp_divider'))
          .margin({ left: 8, right: 8 })

        Button() {
          Text($r('app.string.bluetooth_pairing_accept'))
            .fontFamily('HarmonyHeiTi')
            .fontWeight(FontWeight.Medium)
            .fontSize($r('sys.float.Body_L'))
            .fontColor($r('sys.color.font_emphasize'))
            .lineHeight(21)
            .maxFontScale(2)
            .margin({
              top: 10,
              bottom: 9,
            })
        }
        .layoutWeight(1)
        .backgroundColor(Color.Transparent)
        .onClick(() => {
          LogUtil.info(`${TAG} onClick pair`);
          this.isOnClick = true;
          this.pairDialogController?.onPairClick(this.deviceId, this.checkBoxState, this.input);
        })
      }
    }
    .alignItems(VerticalAlign.Center)
    .justifyContent(FlexAlign.Center)
    .width('100%')
    .margin({
      top: $r('sys.float.padding_level4'),
    })
    .padding({
      left: $r('sys.float.padding_level8'),
      right: $r('sys.float.padding_level8'),
      bottom: $r('sys.float.padding_level8'),
    })
  }

  @Builder
  accessAuthorizationBuilder() {
    Flex({ justifyContent: FlexAlign.Start, alignItems: ItemAlign.Start }) {
      Row() {
        Checkbox()
          .width(24)
          .height(24)
          .margin(0)
          .padding(2)
          .select(this.checkBoxState)
          .selectedColor($r('sys.color.comp_background_emphasize'))
          .shape(CheckBoxShape.CIRCLE)
          .onChange((value: boolean) => {
            LogUtil.info(`${TAG} Checkbox onChange`);
            this.checkBoxState = value;
          })
      }
      .alignItems(VerticalAlign.Center)
      .margin({
        top: $r('sys.float.padding_level6'),
      })

      Text(this.getSummary())
        .width('100%')
        .fontSize($r('sys.float.Body_M'))
        .lineHeight(19)
        .fontColor($r('sys.color.font_primary'))
        .fontWeight(FontWeight.Regular)
        .fontFamily('HarmonyHeiTi')
        .margin({
          top: PADDING_12,
          bottom: PADDING_12,
          start: PADDING_12,
        })
        .layoutWeight(1)
    }
    .width('100%')
  }

  aboutToAppear(): void {
    LogUtil.info(`${TAG} aboutToAppear pinType: ${this.pinType}`);
    this.pairDialogController = new PairDialogController(this.pinType, this.controller);
    this.pairDialogController?.init(this.deviceId);
    this.content = this.pairDialogController?.content;
    this.deviceName = this.pairDialogController?.deviceName;
    if (this.pinType === PinType.PAIRING_VARIANT_DISPLAY_PIN) {
      BluetoothAdapter.getInstance().setPinCodeDevicePairingConfirmation(this.deviceId, true, this.pinCode);
    }
  }

  aboutToDisappear(): void {
    LogUtil.info(`${TAG} aboutToDisappear ${this.isOnClick}`);
    this.pairDialogController?.destroy();
    if (!this.isOnClick) {
      this.pairDialogController?.onCancelClick(this.deviceId, this.input);
    }
  }

  private getSummary(): ResourceStr {
    if (SimUtils.getCardSlotNum() > 0) {
      return $r('app.string.access_permission_full_stop');
    }
    return $r('app.string.access_permission_stop');
  }
}
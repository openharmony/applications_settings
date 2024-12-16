/**
 * Copyright (c) 2024 Huawei Device Co., Ltd.
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

import BluetoothDeviceController from '../../controller/bluetooth/BluetoothDeviceController';
import BluetoothModel, { BondState } from '../../model/bluetoothImpl/BluetoothModel';
import deviceInfo from '@ohos.deviceInfo';
import Display from '@ohos.display';
import pbap from '@ohos.bluetooth.pbap';
import LogUtil from '../../../../../../../common/utils/src/main/ets/default/baseUtil/LogUtil';
import sim from '@ohos.telephony.sim';
import UIExtensionContentSession from '@ohos.app.ability.UIExtensionContentSession';
import { connection } from '@kit.ConnectivityKit';
import { display } from '@kit.ArkUI';
import { PinType } from '../../MainAbility/BluetoothPairDialogAbility';

const TAG = 'BluetoothPairDialog :';
const deviceTypeInfo = deviceInfo.deviceType;
const PIN_REQUIRED_TIME_OUT: number = 30000;

@Entry
@Component
export struct BluetoothPairDialog {
  deviceId: string = '';
  pinCode: string = '';
  pinType: number = -1;
  public pinRequireTimerId: number | null = null;
  bluetoothPairDialogController: CustomDialogController | null = new CustomDialogController({
    builder: PairDialogComponent({
      deviceId: this.deviceId,
      pinType: this.pinType,
      pinCode: this.pinCode,
    }),
    cancel: () => {
    },
    autoCancel: false,
    customStyle: true,
    alignment: DialogAlignment.Bottom,
    maskColor: $r('sys.color.mask_fourth'),
  });

  build() {
  }

  aboutToAppear(): void {
    LogUtil.info(`${TAG} aboutToAppear`);
    this.deviceId = AppStorage.get<string>('PairDeviceId') as string;
    this.pinCode = AppStorage.get<string>('PairPinCode') as string;
    this.pinType = AppStorage.get<number>('PairPinType') as number;
    this.bluetoothPairDialogController?.open();
    this.pinRequireTimerId = setTimeout(() => {
      LogUtil.info(`${TAG} pinRequired timeout`);
      this.closeDialog();
    }, PIN_REQUIRED_TIME_OUT)

    connection.on('bondStateChange', (data: connection.BondStateParam) => {
      LogUtil.info(`${TAG}bondStateChange, deviceId:${data.deviceId}`);
      if (data.deviceId === this.deviceId) {
        if (data.state === BondState.BOND_STATE_INVALID || data.state === BondState.BOND_STATE_BONDED) {
          LogUtil.info(`${TAG}bondStateChange closeDialog, state:${data.state}`);
          this.closeDialog();
        }
      }
    });
  }

  aboutToDisappear(): void {
    LogUtil.info(`${TAG} aboutToDisappear`);
    clearTimeout(this.pinRequireTimerId);
  }

  private closeDialog(): void {
    this.bluetoothPairDialogController?.close;
    (AppStorage.get<UIExtensionContentSession>(`dialogSession`) as UIExtensionContentSession)?.terminateSelf();
  }
}

@CustomDialog
export struct PairDialogComponent {
  deviceId: string = '';
  pinCode: string = '';
  pinType: number = -1;
  deviceName: string = '';
  checkBoxState: boolean = false;
  input: string = '';
  pairDialogController?: PairDialogController;
  controller?: CustomDialogController;
  private isOnClick: boolean = false;
  @State dialogWidth: number | string = deviceTypeInfo === 'phone' || deviceTypeInfo === 'default' ? 400 : 400
  @State paddingValue: ResourceStr | number = deviceTypeInfo === 'phone' || deviceTypeInfo === 'default' ? $r('sys.float.padding_level8') : 0

  build() {
    Column() {
      this.dialogContentBuilder()
    }
    .width('100%')
    .height('100%')
    .justifyContent(FlexAlign.Center)
    .padding({
      left: this.paddingValue,
      right: this.paddingValue,
    })
  }

  @Builder
  dialogContentBuilder() {
    Column() {
      this.titleBuilder()
      Scroll() {
        if (this.pinType === PinType.PAIRING_VARIANT_PASSKEY_CONFIRMATION) {
          this.contentForPinType4Builder();
        } else if (this.pinType === PinType.PAIRING_VARIANT_CONSENT ||
          this.pinType === PinType.PAIRING_VARIANT_OOB_CONSENT) {
          this.contentForPinType56Builder();
        } else if (this.pinType === PinType.PAIRING_VARIANT_DISPLAY_PASSKEY ||
          this.pinType === PinType.PAIRING_VARIANT_DISPLAY_PIN) {
          this.contentForPinType02Builder();
        } else if (this.pinType === PinType.PAIRING_VARIANT_PIN ||
          this.pinType === PinType.PAIRING_VARIANT_PIN_16_DIGITS) {
          this.contentForPinType17Builder();
        } else if (this.pinType === PinType.PAIRING_VARIANT_PASSKEY) {
          this.contentForPinType3Builder();
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
    .margin({bottom: 24})
    .backgroundColor($r('sys.color.ohos_id_color_dialog_bg'))
    .backgroundBlurStyle(BlurStyle.COMPONENT_ULTRA_THICK)
    .saturate(0.9)
    .alignItems(HorizontalAlign.Start)
    .borderRadius($r('sys.float.corner_radius_level16'))
    .width(this.dialogWidth)
  }

  @Builder
  titleBuilder() {
    Row() {
      Text($r('app.string.bluetooth_pairing_request'))
        .fontFamily('HarmonyHeiTi')
        .fontWeight(FontWeight.Bold)
        .fontSize('20fp')
        .fontColor($r('sys.color.font_primary'))
        .constraintSize({ minHeight: 27, })
    }
    .alignItems(VerticalAlign.Center)
    .justifyContent(FlexAlign.Center)
    .width('100%')
    .padding({
      top: 15,
      bottom: 15,
      left: 24,
      right: 24
    })
  }

  @Builder
  contentForPinType4Builder() {
    Column() {
      Text($r('app.string.bt_pair_required_message', this.deviceName, this.deviceName))
        .fontFamily('HarmonyHeiTi')
        .fontWeight(FontWeight.Regular)
        .fontSize($r('sys.float.Body_L'))
        .fontColor($r('sys.color.font_primary'))
        .margin({ bottom: $r('sys.float.padding_level6') })
        .constraintSize({
          minHeight: 21,
        })

      Text(this.pinCode)
        .fontFamily('HarmonyHeiTi')
        .fontWeight(FontWeight.Medium)
        .fontSize('32fp')
        .fontColor($r('sys.color.font_primary'))
        .constraintSize({ minHeight: 43 })
        .align(Alignment.Center)
      this.accessAuthorizationBuilder()
    }
    .margin({
      left: 24,
      right: 24,
    })
  }

  @Builder
  contentForPinType56Builder() {
    Column() {
      Text() {
        Span($r('app.string.bluetooth_pairing_media_device_hit'))
          .fontFamily('HarmonyHeiTi')
          .fontWeight(FontWeight.Regular)
          .fontSize($r('sys.float.Body_L'))
          .fontColor($r('sys.color.font_primary'))
          .constraintSize({
            minHeight: 21,
          })
        Span('\n')
          .fontFamily('HarmonyHeiTi')
          .fontWeight(FontWeight.Regular)
          .fontSize($r('sys.float.Body_L'))
          .fontColor($r('sys.color.font_primary'))
        Span(this.deviceName)
          .fontFamily('HarmonyHeiTi')
          .fontWeight(FontWeight.Medium)
          .fontSize($r('sys.float.Body_L'))
          .fontColor($r('sys.color.font_primary'))
          .constraintSize({
            minHeight: 21,
          })
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
  contentForPinType02Builder() {
    Column() {
      Text() {
        Span($r('app.string.bluetooth_pairing_media_device_hit'))
          .fontFamily('HarmonyHeiT')
          .fontWeight(FontWeight.Regular)
          .fontSize($r('sys.float.Body_L'))
          .fontColor($r('sys.color.font_primary'))
          .constraintSize({
            minHeight: 21,
          })
        Span('\n')
          .fontFamily('HarmonyHeiT')
          .fontWeight(FontWeight.Regular)
          .fontSize($r('sys.float.Body_L'))
          .fontColor($r('sys.color.font_primary'))
        Span(this.deviceName)
          .fontFamily('HarmonyHeiT')
          .fontWeight(FontWeight.Medium)
          .fontSize($r('sys.float.Body_L'))
          .fontColor($r('sys.color.font_primary'))
          .constraintSize({
            minHeight: 21,
          })
      }

      Text() {
        Span($r('app.string.bluetooth_pin_required_code_title'))
          .fontFamily('HarmonyHeiT')
          .fontWeight(FontWeight.Regular)
          .fontSize($r('sys.float.Body_L'))
          .fontColor($r('sys.color.font_primary'))
          .constraintSize({
            minHeight: 21,
          })
        Span('\n')
          .fontFamily('HarmonyHeiT')
          .fontWeight(FontWeight.Regular)
          .fontSize($r('sys.float.Body_L'))
          .fontColor($r('sys.color.font_primary'))
        Span(this.pinCode)
          .fontFamily('HarmonyHeiT')
          .fontWeight(FontWeight.Medium)
          .fontSize($r('sys.float.Body_L'))
          .fontColor($r('sys.color.font_primary'))
          .constraintSize({
            minHeight: 21,
          })
      }
      .margin({
        top: $r('sys.float.padding_level8'),
      })

      Text($r('app.string.bluetooth_pin_required_please_enter_message'))
        .fontFamily('HarmonyHeiT')
        .fontWeight(FontWeight.Regular)
        .fontSize($r('sys.float.Body_L'))
        .fontColor($r('sys.color.font_primary'))
        .constraintSize({
          minHeight: 21,
        })
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
  contentForPinType17Builder() {
    Column() {
      TextInput({ text: this.input, placeholder: $r('app.string.bluetooth_usually_message') })
        .placeholderColor($r('sys.color.font_secondary'))
        .placeholderFont({ size: $r('sys.float.Body_L'), weight: FontWeight.Regular, family: 'HarmonyHeiTi', })
        .caretColor(Color.Blue)
        .defaultFocus(false)
        .width('100%')
        .constraintSize({ minHeight: '40vp', })
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
          .fontSize($r('sys.float.Body_S'))
          .constraintSize({
            minHeight: 19,
          })
          .fontColor($r('sys.color.font_secondary'))
          .fontWeight(FontWeight.Regular)
          .fontFamily('HarmonyHeiTi')
          .margin({
            left: $r('sys.float.padding_level6'),
          })
      }
      .width('100%')
      .margin({
        top: $r('sys.float.padding_level4'),
      })
      .constraintSize({ minHeight: 32, })

      Text($r('app.string.bluetooth_pinCode_required_message'))
        .fontFamily('HarmonyHeiTi')
        .fontWeight(FontWeight.Regular)
        .fontSize($r('sys.float.Body_L'))
        .fontColor($r('sys.color.font_primary'))
        .constraintSize({
          minHeight: 21,
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
  contentForPinType3Builder() {
    Column() {
      Column() {
        TextInput({ text: this.input, placeholder: $r('app.string.bluetooth_usually_message') })
          .placeholderColor($r('sys.color.font_secondary'))
          .placeholderFont({ size: $r('sys.float.Body_L'), weight: FontWeight.Regular, family: 'HarmonyHeiT' })
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
        .constraintSize({
          minHeight: 21,
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
  buttonBuilder() {
    Row() {
      Button() {
        Text($r('app.string.pair_cancel'))
          .fontFamily('HarmonyHeiTi')
          .fontWeight(FontWeight.Medium)
          .fontSize($r('sys.float.Body_L'))
          .fontColor($r('sys.color.font_emphasize'))
          .constraintSize({ minHeight: '21vp' })
          .margin({
            top: 10,
            bottom: 9,
          })
      }
      .layoutWeight(1)
      .width('20%')
      .backgroundColor(Color.Transparent)
      .onClick(() => {
        LogUtil.info(`${TAG} onClick cancel`);
        this.isOnClick = true;
        this.pairDialogController?.onCancelClick(this.deviceId, this.input);
      })

      if (this.pinType !== PinType.PAIRING_VARIANT_DISPLAY_PASSKEY &&
        this.pinType !== PinType.PAIRING_VARIANT_DISPLAY_PIN) {
        Button() {
          Text($r('app.string.bluetooth_pair_button'))
            .fontFamily('HarmonyHeiTi')
            .fontWeight(FontWeight.Medium)
            .fontSize($r('sys.float.Body_L'))
            .fontColor($r('sys.color.font_emphasize'))
            .constraintSize({ minHeight: '21vp' })
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
          .width('24vp')
          .height('20vp')
          .margin(0)
          .select(this.checkBoxState)
          .shape(CheckBoxShape.CIRCLE)
          .onChange((value: boolean) => {
            LogUtil.info(`${TAG} Checkbox onChange`)
            this.checkBoxState = value;
          })
      }
      .alignItems(VerticalAlign.Center)
      .margin({ top: 15, })
      .constraintSize({ minHeight: $r('sys.float.Body_M') })

      Text(this.getSummary())
        .width('100%')
        .fontSize($r('sys.float.Body_M'))
        .constraintSize({ minHeight: 19 })
        .fontColor($r('sys.color.font_primary'))
        .fontWeight(FontWeight.Regular)
        .fontFamily('HarmonyHeiTi')
        .margin({
          top: 15,
          bottom: 13,
          left: $r('sys.float.padding_level6'),
        })
    }
    .width('100%')
    .constraintSize({ minHeight: 62 })
  }

  aboutToAppear(): void {
    LogUtil.info(`${TAG} aboutToAppear pinType: ${this.pinType}`);
    this.pairDialogController = new PairDialogController(this.pinType, this.controller);
    this.pairDialogController?.init();
    this.deviceName = BluetoothModel.getDeviceName(this.deviceId);
    if (this.pinType === PinType.PAIRING_VARIANT_DISPLAY_PIN) {
      connection.setDevicePinCode(this.deviceId, this.pinCode ?? '');
    }
    if (display.isFoldable()) {
      try {
        Display.on('foldStatusChange', (status: number) => {
          this.handleFoldStateChange(status);
        });
      } catch (err) {
        LogUtil.error(`${TAG} aboutToAppear pinType: ${this.pinType}`);
      }
    }
  }

  private handleFoldStateChange(status: number): void {
    LogUtil.info(`${TAG} on fold status changed: ${status}`);
    if (status === Display.FoldStatus.FOLD_STATUS_FOLDED) {
      this.dialogWidth = '100%';
      this.paddingValue = $r('sys.float.padding_level8');
    } else {
      this.dialogWidth = 400;
      this.paddingValue = 0;
    }
  }

  aboutToDisappear(): void {
    LogUtil.info(`${TAG} aboutToDisappear ${this.isOnClick}`);
    if (!this.isOnClick) {
      this.pairDialogController?.onCancelClick(this.deviceId, this.input);
    }
    if (display.isFoldable()) {
      try {
        Display.off('foldStatusChange');
      } catch (e) {
        LogUtil.error(`${TAG} unregister foldStatusChange ${e?.message}`);
      }
    }
  }

  private getSummary(): ResourceStr {
    if (sim.getMaxSimCount() > 0) {
      return $r('app.string.access_permission_full_stop')
    }
    return $r('app.string.access_permission_stop')
  }
}

export enum AccessAuthorization {
  UNKNOWN = 0,
  ALLOWED = 1,
  REJECTED = 2,
}

export enum ShareType {
  SHARE_NAME_AND_PHONE_NUMBER = 0,
  SHARE_ALL = 1,
  SHARE_NOTHING = 2
}

class PairDialogController {
  public deviceName: string = '';
  private controller?: CustomDialogController;
  private bluetoothDeviceController: BluetoothDeviceController = new BluetoothDeviceController();
  private pinType: number = -1;
  private pbapServerProfile = pbap.createPbapServerProfile();

  constructor(pinType: number, controller?: CustomDialogController) {
    this.pinType = pinType;
    this.controller = controller;
  }

  init(): void {
    this.bluetoothDeviceController
      .initData()
      .subscribe();
  }

  onPairClick(deviceId: string, checkBoxState: boolean, input?: string): void {
    LogUtil.info(`${TAG} onPairClick, deviceId: ${deviceId}, checkBoxState: ${checkBoxState}, pinType: ${this.pinType}`);
    let pinType: number = this.pinType;
    if (pinType === PinType.PAIRING_VARIANT_PASSKEY_CONFIRMATION || pinType === PinType.PAIRING_VARIANT_CONSENT) {
      this.onPairClickForPinType45(deviceId, checkBoxState);
    } else if (pinType === PinType.PAIRING_VARIANT_OOB_CONSENT) {
      this.onPairClickForPinType02ForOther(deviceId, checkBoxState);
    } else if (pinType === PinType.PAIRING_VARIANT_DISPLAY_PASSKEY || pinType === PinType.PAIRING_VARIANT_DISPLAY_PIN) {
      this.onPairClickForPinType02ForOther(deviceId, checkBoxState);
    } else if (pinType === PinType.PAIRING_VARIANT_PIN || pinType === PinType.PAIRING_VARIANT_PIN_16_DIGITS ||
      pinType === PinType.PAIRING_VARIANT_PASSKEY) {
      this.onPairClickForPinType137(deviceId, checkBoxState, input);
    }
    this.closeDialog();
  }

  onCancelClick(deviceId: string, input?: string): void {
    LogUtil.info(`${TAG} onCancelClick, deviceId: ${deviceId}, pinType: ${this.pinType}`);
    let pinType: number = this.pinType;
    if (pinType === PinType.PAIRING_VARIANT_PASSKEY_CONFIRMATION || pinType === PinType.PAIRING_VARIANT_CONSENT) {
      this.onCancelClickForPinType45(deviceId);
    } else if (pinType === PinType.PAIRING_VARIANT_OOB_CONSENT) {
      this.onCancelClickForPinType02ForOther(deviceId);
    } else if (pinType === PinType.PAIRING_VARIANT_DISPLAY_PASSKEY || pinType === PinType.PAIRING_VARIANT_DISPLAY_PIN) {
      this.onCancelClickForPinType02ForOther(deviceId);
    } else if (pinType === PinType.PAIRING_VARIANT_PIN || pinType === PinType.PAIRING_VARIANT_PIN_16_DIGITS ||
      pinType === PinType.PAIRING_VARIANT_PASSKEY) {
      this.onCancelClickForPinType137(deviceId, input);
    }
    this.closeDialog();
  }

  private onPairClickForPinType137(deviceId: string, checkBoxState: boolean, input?: string): void {
    let accessAuthorizationParams: AccessAuthorization;
    let shareTypeParams: ShareType;
    if (checkBoxState) {
      accessAuthorizationParams = AccessAuthorization.ALLOWED;
      shareTypeParams = ShareType.SHARE_NAME_AND_PHONE_NUMBER;
    } else {
      accessAuthorizationParams = AccessAuthorization.UNKNOWN;
      shareTypeParams = ShareType.SHARE_NOTHING;
    }
    this.pbapServerProfile.setPhoneBookAccessAuthorization(deviceId, accessAuthorizationParams)
    this.pbapServerProfile.setShareType(deviceId, shareTypeParams)
    LogUtil.info(`${TAG} onPairClickForPinType137 onButton3Click`);
    connection.setDevicePinCode(deviceId, input ?? '');
  }

  private onPairClickForPinType02ForOther(deviceId: string, checkBoxState: boolean): void {
    let accessAuthorizationParams: AccessAuthorization;
    let shareTypeParams: ShareType;
    if (checkBoxState) {
      accessAuthorizationParams = AccessAuthorization.ALLOWED;
      shareTypeParams = ShareType.SHARE_NAME_AND_PHONE_NUMBER;
    } else {
      accessAuthorizationParams = AccessAuthorization.UNKNOWN;
      shareTypeParams = ShareType.SHARE_NOTHING;
    }
    this.pbapServerProfile.setPhoneBookAccessAuthorization(deviceId, accessAuthorizationParams)
    this.pbapServerProfile.setShareType(deviceId, shareTypeParams)
    LogUtil.info('${TAG} onPairClickForPinType02ForOther onButton3Click');
  }

  private onPairClickForPinType45(deviceId: string, checkBoxState: boolean): void {
    let accessAuthorizationParams: AccessAuthorization;
    let shareTypeParams: ShareType;
    if (checkBoxState) {
      accessAuthorizationParams = AccessAuthorization.ALLOWED;
      shareTypeParams = ShareType.SHARE_NAME_AND_PHONE_NUMBER;
    } else {
      accessAuthorizationParams = AccessAuthorization.UNKNOWN;
      shareTypeParams = ShareType.SHARE_NOTHING;
    }
    this.pbapServerProfile.setPhoneBookAccessAuthorization(deviceId, accessAuthorizationParams)
    this.pbapServerProfile.setShareType(deviceId, shareTypeParams)
    LogUtil.info(`${TAG} setShareType onPairClickForPinType256`);
    connection.setDevicePairingConfirmation(deviceId, true);
  }

  private onCancelClickForPinType137(deviceId: string, input?: string): void {
    this.pbapServerProfile.setPhoneBookAccessAuthorization(deviceId, AccessAuthorization.REJECTED)
    this.pbapServerProfile.setShareType(deviceId, ShareType.SHARE_NOTHING)
    LogUtil.info(`[${TAG}] onCancelClickForPinType17 onCancelPair`);
    connection.cancelPairingDevice(deviceId)
  }

  private onCancelClickForPinType45(deviceId: string): void {
    this.pbapServerProfile.setPhoneBookAccessAuthorization(deviceId, AccessAuthorization.REJECTED)
    this.pbapServerProfile.setShareType(deviceId, ShareType.SHARE_NOTHING)
    LogUtil.info(`[${TAG}] onCancelClickForPinType2 onCancelPair`);
    connection.setDevicePairingConfirmation(deviceId, false);
  }

  private onCancelClickForPinType02ForOther(deviceId: string): void {
    this.pbapServerProfile.setPhoneBookAccessAuthorization(deviceId, AccessAuthorization.REJECTED)
    this.pbapServerProfile.setShareType(deviceId, ShareType.SHARE_NOTHING)
    LogUtil.info(`[${TAG}] onCancelClickForPinType56ForOther onCancelPair`);
    connection.cancelPairingDevice(deviceId);
  }

  private closeDialog(): void {
    this.controller?.close;
    this.bluetoothDeviceController.unsubscribe();
    (AppStorage.get<UIExtensionContentSession>(`dialogSession`) as UIExtensionContentSession)?.terminateSelf();
  }
}
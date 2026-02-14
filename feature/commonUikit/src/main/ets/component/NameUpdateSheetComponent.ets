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

import { SymbolGlyphModifier } from '@kit.ArkUI';
import prompt from '@ohos.prompt';
import wifiManager from '@ohos.wifiManager';
import { LogUtil } from '@ohos/settings.common/src/main/ets/utils/LogUtil';
import { ResourceUtil } from '@ohos/settings.common/src/main/ets/utils/ResourceUtil';
import { StringUtil } from '@ohos/settings.common/src/main/ets/utils/StringUtil';
import { ToastUtil } from '@ohos/settings.common/src/main/ets/utils/ToastUtil';
import { EventBus } from '@ohos/settings.common/src/main/ets/framework/common/EventBus';
import { FontScaleUtils } from '@ohos/settings.common/src/main/ets/utils/FontScaleUtils';

/* instrument ignore file */
const TAG: string = 'NameUpdateSheetComponent: ';
const OPACITY_PERCENT_FULL: number = 1;
const TOAST_DURATION: number = 2000;
const MAX_LENGTH: number = 100;
const WIFI_ACTIVE: number = 1;
// 接口超时没返回结果会弹窗，目前调用DM的接口，平均耗时500ms，最长耗时10s
const UPDATE_DEVICE_NAME_TIMEOUT: number = 10000;

@Component
export struct NameUpdateSheetComponent {
  hint?: ResourceStr;
  primaryButton?: ResourceStr;
  maxLength: number = MAX_LENGTH;
  confirm?: Function;
  closeDialog?: Function;
  private ssid: string = '';
  @State isWarning: boolean = false;
  @State textValue: ResourceStr = '';
  @Link inputValue: ResourceStr;
  @State isUpdating: boolean = false;
  @State isFocusing: boolean = false;
  timerId: number | null = null;
  needReConfirm: boolean = false;
  reConfirm?: Function;
  private onWifiConnectionChange = (state: number): void => {
    LogUtil.info(`${TAG} wifi state change : ${state}`);
    if (state === WIFI_ACTIVE) {
      this.refreshSsid();
    } else {
      this.ssid = '';
      this.isWarning = false;
    }
  };
  private scroller: Scroller = new Scroller();

  build() {
    Scroll(this.scroller) {
      Column() {
        this.contentBuilder()
        Row()
          .layoutWeight(1)
        this.buttonBuilder()
      }
      .width('100%')
      .padding({ bottom: 80 })
    }
    .width('100%')
    .height('100%')
  }

  @Builder
  contentBuilder() {
    Column() {
      TextInput({ placeholder: '', text: this.textValue })
        .showUnderline(false)
        .defaultFocus(true)
        .fontColor($r('sys.color.font_primary'))
        .fontSize($r('sys.float.Body_L'))
        .fontWeight(FontWeight.Regular)
        .fontFamily('HarmonyHeiTi')
        .backgroundColor(Color.Transparent)
        .borderRadius(0)
        .constraintSize({
          minHeight: 48,
        })
        .cancelButton({
          style: CancelButtonStyle.CONSTANT,
          icon: new SymbolGlyphModifier($r('sys.symbol.xmark'))
            .fontSize('24vp')
            .fontColor([$r('sys.color.ohos_id_color_primary')])
        })
        .onChange((value: string) => {
          this.inputChange(value);
        })
        .onWillInsert((info: InsertValue) => {
          return this.willInputChange(info?.insertValue);
        })
        .onWillChange((value: EditableTextChangeValue) => {
          return this.willChange(value?.content);
        })
        .onEditChange((isEditing: boolean) => {
          this.isFocusing = isEditing;
        })

      Divider()
        .vertical(false)
        .color(this.isFocusing ? $r('sys.color.font_primary') : $r('sys.color.comp_divider'))
        .height(this.isFocusing ? '2px' : '1px')
        .opacity(this.isFocusing ? 0.6 : 1)
        .margin({
          left: $r('sys.float.padding_level8'),
          right: $r('sys.float.padding_level8'),
        })
      if (this.hint) {
        Text(this.isWarning ? $r('app.string.repeat_name_warning') : this.hint)
          .fontFamily('HarmonyHeiTi')
          .fontWeight(FontWeight.Regular)
          .fontSize($r('sys.float.Body_S'))
          .fontColor(this.isWarning ? $r('sys.color.warning') : $r('sys.color.font_secondary'))
          .constraintSize({
            minHeight: 16,
          })
          .margin({
            top: $r('sys.float.padding_level4'),
            left: $r('sys.float.padding_level8'),
            right: $r('sys.float.padding_level8'),
          })
      }
    }
    .margin({
      top: $r('sys.float.padding_level4'),
    })
    .alignItems(HorizontalAlign.Start)
  }

  @Builder
  buttonBuilder() {
    Row() {
      Button() {
        Row() {
          LoadingProgress()
            .width('24vp')
            .height('24vp')
            .visibility(this.isUpdating ? Visibility.Visible : Visibility.None)

          Text(this.isUpdating ? $r('app.string.device_name_wait_tip') : this.primaryButton)
            .fontFamily('HarmonyHeiTi')
            .fontWeight(FontWeight.Medium)
            .fontSize($r('sys.float.Body_L'))
            .fontColor(this.isUpdating ? $r('sys.color.font_tertiary') : $r('sys.color.font_emphasize'))
            .maxFontScale(FontScaleUtils.EXTRA_LARGE_FONT_1)
            .margin({
              top: '9.5vp',
              bottom: $r('sys.float.padding_level5'),
            })
        }
        .width('100%')
        .justifyContent(FlexAlign.Center)
        .alignItems(VerticalAlign.Center)
      }
      .width('100%')
      .opacity(this.inputValue?.toString()?.trim()?.length > 0 ? OPACITY_PERCENT_FULL : OPACITY_PERCENT_FULL)
      .enabled(!this.isWarning && this.inputValue?.toString()?.trim()?.length > 0 && !this.isUpdating ? true : false)
      .backgroundColor($r('sys.color.comp_background_tertiary'))
      .onClick(() => {
        LogUtil.info(`${TAG} onclick confirm, update remote device name`);
        if (this.needReConfirm) {
          this.reConfirm?.();
          return;
        }
        this.timerId = setTimeout(() => {
          LogUtil.info(`${TAG} update device name time out`);
          this.isUpdating = false;
          ToastUtil.showToast(ResourceUtil.getStringSync($r('app.string.device_name_update_fail')),
            ToastUtil.SHORT_DURATION)
        }, UPDATE_DEVICE_NAME_TIMEOUT);
        this.confirm?.();
        this.isUpdating = true;
        LogUtil.info(`${TAG} onclick confirm, update remote device name ${this.isUpdating}`);
      })
    }
    .padding({
      left: $r('sys.float.padding_level8'),
      right: $r('sys.float.padding_level8'),
    })
    .width('100%')
    .margin({
      bottom: $r('sys.float.padding_level12'),
    })
  }

  private willChange(value: string): boolean {
    let valueLength: number = StringUtil.getStringLength(value);
    LogUtil.info(`${TAG} willChange valueLength is: ${valueLength}`);
    if (valueLength > this.maxLength) {
      ResourceUtil.getString($r('app.string.input_max_length_message')).then(value => {
        this.showToast(value);
      });
      return false;
    }
    return true;
  }

  private willInputChange(value: string): boolean {
    LogUtil.info(`${TAG} willInputChange value is: ${value?.length}, textvalue length: ${this.textValue?.toString()?.length}`);
    let inputValueLength: number = StringUtil.getStringLength(this.inputValue.toString());
    let valueLength: number = StringUtil.getStringLength(value);
    let length: number = inputValueLength + valueLength;
    if (length > this.maxLength) {
      ResourceUtil.getString($r('app.string.input_max_length_message')).then(value => {
        this.showToast(value);
      });
      return false;
    }
    return true;
  }

  private inputChange(value: string): void {
    LogUtil.info(`${TAG} TextInput onchange ${value?.length}`);
    if (this.ssid && value === this.ssid) {
      this.isWarning = true;
    } else {
      this.isWarning = false;
    }

    this.textValue = value;
    this.inputValue = value;
  }

  aboutToAppear(): void {
    LogUtil.info(`${TAG} aboutToAppear`);
    this.refreshSsid();
    this.registerListener();
    EventBus.getInstance().on('deviceNameCheck', this.deviceNameCheckEventCallback);
    EventBus.getInstance().on('updateDeviceNameConfirm', this.updateConfirmEventCallback);
  }

  aboutToDisappear(): void {
    LogUtil.info(`${TAG} aboutToDisappear`);
    if (this.timerId != null) {
      clearTimeout(this.timerId);
      this.timerId = null;
    }
    this.unRegisterListener();
    EventBus.getInstance().detach('deviceNameCheck', this.deviceNameCheckEventCallback);
    EventBus.getInstance().detach('updateDeviceNameConfirm', this.updateConfirmEventCallback);
  }

  private showToast(content: string): void {
    try {
      prompt.showToast({
        message: content,
        duration: TOAST_DURATION,
      });
    } catch (error) {
      LogUtil.info(`${TAG} showToast failed: ${error?.message}`);
    }
    ;
  }

  private refreshSsid(): void {
    try {
      wifiManager.getLinkedInfo().then(data => {
        this.ssid = data?.ssid ?? '';
        this.isWarning = this.ssid === this.inputValue && wifiManager.isWifiActive();
      });
    } catch (error) {
      LogUtil.error(`${TAG} getLinkedInfo fail: ${error?.message}`);
    }
  }

  private registerListener(): void {
    try {
      wifiManager.on('wifiConnectionChange', this.onWifiConnectionChange);
    } catch (error) {
      LogUtil.error(`${TAG}, registerListener failed. ${error?.message}`);
    }
  }

  private unRegisterListener(): void {
    try {
      wifiManager.off('wifiConnectionChange', this.onWifiConnectionChange);
    } catch (error) {
      LogUtil.error(`${TAG} unRegisterListener failed. ${error?.message}`);
    }
  }

  private deviceNameCheckEventCallback = () => {
    LogUtil.info(`${TAG} device name check over`);
    this.isUpdating = false;
    if (this.timerId != null) {
      clearTimeout(this.timerId);
      this.timerId = null;
    }
  }
  private updateConfirmEventCallback = () => {
    LogUtil.info(`${TAG} update confirm call back`);
    this.timerId = setTimeout(() => {
      LogUtil.info(`${TAG} update device name time out`);
      this.isUpdating = false;
      ToastUtil.showToast(ResourceUtil.getStringSync($r('app.string.device_name_update_fail')),
        ToastUtil.SHORT_DURATION)
    }, UPDATE_DEVICE_NAME_TIMEOUT);
    this.confirm?.();
    this.isUpdating = true;
  }
}

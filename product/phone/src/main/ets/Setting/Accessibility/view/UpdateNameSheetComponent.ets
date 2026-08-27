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

import prompt from '@ohos.prompt';
import { LogUtil } from '@ohos/settings.common/src/main/ets/utils/LogUtil';
import { EventBus } from '@ohos/settings.common/src/main/ets/framework/common/EventBus';
import { HiSysAccessibilityEventGroup } from '@ohos/settings.common/src/main/ets/systemEvent/BehaviorEventConsts';
import { HiSysEventUtil } from '@ohos/settings.common/src/main/ets/systemEvent/HiSysEventUtil';
import { StringUtil } from '@ohos/settings.common/src/main/ets/utils/StringUtil';
import { ResourceUtil } from '@ohos/settings.common/src/main/ets/utils/ResourceUtil';
import { FontScaleUtils } from '@ohos/settings.common/src/main/ets/utils/FontScaleUtils';

/* instrument ignore file */
const TAG: string = 'UpdateNameSheetComponent: ';
const MAX_LENGTH: number = 64;
const TOAST_DURATION: number = 2000;
const OPACITY_PERCENT_FULL: number = 1;
const ALPHA_DISABLED: Resource = $r('sys.float.alpha_tertiary');

@Component
export struct UpdateNameSheetComponent {
  hint?: ResourceStr;
  primaryButton?: ResourceStr;
  primaryCancelButton?: ResourceStr;
  maxLength: number = MAX_LENGTH;
  confirm?: Function;
  closeDialog?: Function;
  private ssid: string = '';
  @State isWarning: boolean = false;
  @State textValue: ResourceStr = '';
  @Link inputValue: ResourceStr;
  @State isUpdating: boolean = false;
  timerId: number | null = null;
  needReConfirm: boolean = false;
  reConfirm?: Function;

  build() {
    Column() {
      this.contentBuilder()
      if (FontScaleUtils.isExtraLargeFontMode()) {
        this.buttonLargeBuilder()
      } else {
        this.buttonBuilder()
      }
    }
    .width('100%')
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
          icon: {
            size: '24vp',
            color: $r('sys.color.icon_primary'),
            src: $r('app.media.ic_public_cancel_bt'),
          },
        })
        .onChange((value: string) => {
          this.inputChange(value);
        })
        .onWillInsert((info: InsertValue) => {
          return this.willInputChange(info?.insertValue);
        })
        .onWillChange((value: EditableTextChangeValue)=>{
          return this.willChange(value?.content);
        })

      Divider()
        .vertical(false)
        .color($r('sys.color.comp_divider'))
        .height('1vp')
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
  buttonLargeBuilder() {
    Column() {
      Button() {
        Text(this.primaryCancelButton)
          .fontColor($r('sys.color.font_emphasize'))
          .fontSize($r('sys.float.Body_L'))
          .fontWeight(FontWeight.Regular)
          .maxFontScale(2)
      }
      .width('100%')
      .backgroundColor($r('sys.color.comp_background_tertiary'))
      .onClick(() => {
        this.closeDialog?.();
        this.isUpdating = true;
        LogUtil.debug(`${TAG} onclick cancel`);
        HiSysEventUtil.reportDefaultBehaviorEventByUE(HiSysAccessibilityEventGroup.ENTER_CANCEL_DEVICES_NAME, 'cancel');
      })
      .hoverEffect(HoverEffect.None)
      .padding({ left: $r('app.float.padding_8'), right: $r('app.float.padding_8') })
      .margin({ bottom: $r('app.float.padding_8') })

      Button() {
        Text(this.primaryButton)
          .fontColor($r('sys.color.font_emphasize'))
          .fontSize($r('sys.float.Body_L'))
          .fontWeight(FontWeight.Regular)
          .maxFontScale(2)
      }
      .backgroundColor($r('sys.color.comp_background_tertiary'))
      .opacity(this.textValue ? OPACITY_PERCENT_FULL : ALPHA_DISABLED)
      .width('100%')
      .onClick(() => {
        if (this.needReConfirm) {
          this.reConfirm?.();
          return;
        }
        this.confirm?.();
        this.isUpdating = true;
        LogUtil.debug(`${TAG} onclick confirm`);
        HiSysEventUtil.reportDefaultBehaviorEventByUE(HiSysAccessibilityEventGroup.ENTER_CONFIRM_DEVICES_NAME, 'OK');
      })
      .padding({ left: $r('app.float.padding_8'), right: $r('app.float.padding_8') })
    }
    .width('100%')
    .justifyContent(FlexAlign.SpaceBetween)
    .margin({
      top: $r('sys.float.padding_level8'),
      bottom: $r('sys.float.padding_level12'),
    })
    .padding({
      left: $r('sys.float.padding_level8'),
      right: $r('sys.float.padding_level8'),
    })
  }

  @Builder
  buttonBuilder() {
    Row({space: 12}) {
      Button() {
        Row() {
          Text(this.primaryCancelButton)
            .fontFamily('HarmonyHeiTi')
            .fontWeight(FontWeight.Medium)
            .fontSize($r('sys.float.Body_L'))
            .fontColor($r('sys.color.font_emphasize'))
            .margin({
              top: '9.5vp',
              bottom: $r('sys.float.padding_level5'),
            })
        }
        .justifyContent(FlexAlign.Center)
        .alignItems(VerticalAlign.Center)
      }
      .layoutWeight(1)
      .backgroundColor($r('sys.color.comp_background_tertiary'))
      .onClick(() => {
        this.closeDialog?.();
        this.isUpdating = true;
        LogUtil.debug(`${TAG} onclick cancel`);
        HiSysEventUtil.reportDefaultBehaviorEventByUE(HiSysAccessibilityEventGroup.ENTER_CANCEL_DEVICES_NAME, 'cancel');
      })

      Button() {
        Row() {
          Text(this.primaryButton)
            .fontFamily('HarmonyHeiTi')
            .fontWeight(FontWeight.Medium)
            .fontSize($r('sys.float.Body_L'))
            .fontColor($r('sys.color.font_emphasize'))
            .margin({
              top: '9.5vp',
              bottom: $r('sys.float.padding_level5'),
            })
        }
        .justifyContent(FlexAlign.Center)
        .alignItems(VerticalAlign.Center)
      }
      .enabled(this.textValue ? true : false)
      .opacity(this.textValue ? OPACITY_PERCENT_FULL : ALPHA_DISABLED)
      .layoutWeight(1)
      .backgroundColor($r('sys.color.comp_background_tertiary'))
      .onClick(() => {
        if (this.needReConfirm) {
          this.reConfirm?.();
          return;
        }
        this.confirm?.();
        this.isUpdating = true;
        LogUtil.debug(`${TAG} onclick confirm`);
        HiSysEventUtil.reportDefaultBehaviorEventByUE(HiSysAccessibilityEventGroup.ENTER_CONFIRM_DEVICES_NAME, 'OK');
      })
    }
    .padding({
      left: $r('sys.float.padding_level8'),
      right: $r('sys.float.padding_level8'),
    })
    .width('100%')
    .margin({
      top: $r('sys.float.padding_level8'),
      bottom: $r('sys.float.padding_level12'),
    })
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

  private showToast(content: string): void {
    try {
      prompt.showToast({
        message: content,
        duration: TOAST_DURATION,
      });
    } catch (error) {
      LogUtil.info(`${TAG} showToast failed: ${error?.message}`);
    };
  }

  aboutToAppear(): void {
    LogUtil.info(`${TAG} aboutToAppear`);
    EventBus.getInstance().on('deviceNameCheck', this.deviceNameCheckEventCallback);
  }

  aboutToDisappear(): void {
    LogUtil.info(`${TAG} aboutToDisappear`);
    if (this.timerId != null) {
      clearTimeout(this.timerId);
      this.timerId = null;
    }
    EventBus.getInstance().detach('deviceNameCheck', this.deviceNameCheckEventCallback);
  }

  private deviceNameCheckEventCallback = () => {
    LogUtil.info(`${TAG} device name check over`);
    this.isUpdating = false;
    if (this.timerId != null) {
      clearTimeout(this.timerId);
      this.timerId = null;
    }
  }
}
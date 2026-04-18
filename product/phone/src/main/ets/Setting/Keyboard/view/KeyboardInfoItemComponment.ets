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
import { SettingsDataUtils } from '@ohos/settings.common/src/main/ets/utils/SettingsDataUtils';
import { NavEntryKey } from '@ohos/settings.common/src/main/ets/utils/Consts';
import { PushParam } from '@ohos/settings.common/src/main/ets/core/controller/Controller';
import { DefaultPageConfig } from '@ohos/settings.common/src/main/ets/framework/common/DefaultPageConfig';
import { PageRouter } from '@ohos/settings.common/src/main/ets/framework/common/PageRouter';
import { SystemParamUtil } from '@ohos/settings.common/src/main/ets/utils/SystemParamUtil';
import {
  SettingIconStyle,
  SettingIconType,
  SettingTextStyle,
  SettingTextType
} from '@ohos/settings.common/src/main/ets/framework/model/SettingItemModel';
import uiAppearance from '@ohos.uiAppearance';
import { common } from '@kit.AbilityKit';
import { KeyboardSettingsManager } from '../KeyboardSettingsManager';
/* instrument ignore file */
import componentConfig from '../utils/ComponentConfig';

@Extend(Text)
function textStyle(style: SettingTextStyle, fontColor?: ResourceColor) {
  .fontSize(style.fontSize)
  .fontColor(fontColor ?? style.fontColor)
  .fontWeight(style.fontWeight)
  .fontFamily(style.fontFamily)
  .textAlign(style.textAlign)
  .maxLines(style.maxLines)
  .textOverflow({ overflow: style.textOverflow })
  .opacity(style.opacity)
}

@Extend(Image)
function iconStyle(style: SettingIconStyle) {
  .width(style.width)
  .height(style.height)
  .objectFit(style.objectFit)
  .borderRadius(style.borderRadius)
  .draggable(style.draggable)
  .interpolation(style.interpolation)
  .edgeAntialiasing(style.edgeAntialiasing)
  .border(style.border)
  .clip(style.clip)
  .syncLoad(true)
  .matchTextDirection(true)
}

export enum ChargingState {
  OFF = '0',
  ON = '1',
}

@Component
export struct KeyboardInfoItemComponent {
  @State keyboardName: string = KeyboardSettingsManager.getInstance().getKeyboardName();
  @State showBattery: string = '';
  @State batteryValue: string = '0%';
  @State currentBatteryImage: ResourceStr = '';
  @State batteryLevelIndex: number = 0;
  @State isHover: boolean = false;
  private compId: string = '';
  private tag: string = 'KeyboardInfoItemComponent: ';
  private isNeedShowBattery: boolean = false;
  private charging: boolean = false;
  private chargingSupport: boolean = false;
  private battery: string = '0';
  private batteryTimer: number = 0;
  private batteryIndexOne: number = 1;
  private defaultPageConfig: DefaultPageConfig = DefaultPageConfig.getInstance();
  private batteryChargingDrawables = componentConfig.KEYBOARD_BATTERY_CAHRGE;
  private batteryNormalDrawables = componentConfig.KEYBOARD_BATTERY;
  private batteryChargingDarkDrawables = componentConfig.KEYBOARD_BATTERY_CAHRGE_DARK;
  private batteryNormalDarkDrawables = componentConfig.KEYBOARD_BATTERY_DARK;

  aboutToAppear() {
    LogUtil.info(`${this.tag} getFirstKeyboardInfo begin`);
    this.keyboardName = KeyboardSettingsManager.getInstance().getKeyboardName();
    this.showBattery = SettingsDataUtils.getSettingsDataWithContext(getContext(this) as common.UIAbilityContext,
      componentConfig.spShowBatteryKey, ChargingState.OFF)
    LogUtil.info(`${this.tag} showBattery : ${this.showBattery}`);
    this.isNeedShowBattery = this.showBattery === ChargingState.ON;
    if (this.isNeedShowBattery) {
      this.chargingSupport = SystemParamUtil.getParam(componentConfig.spChargingSupportKey, ChargingState.OFF) ===
      ChargingState.ON;
      this.battery = SystemParamUtil.getParam(componentConfig.spBatteryKey, ChargingState.OFF);
      this.getBatteryInfo();
      this.updateBatteryInfo();
    }
  }

  aboutToDisappear(): void {
    clearInterval(this.batteryTimer);
  }

  private getBatteryInfoTask(): void {
    let isCharging: boolean = false;
    if (this.chargingSupport) {
      isCharging = SystemParamUtil.getParam(componentConfig.spKeyboardChargingStateKey, ChargingState.OFF) ===
      ChargingState.ON;
    }
    let newBattery: string = SystemParamUtil.getParam(componentConfig.spBatteryKey, ChargingState.OFF);
    if (newBattery !== this.battery || this.charging !== isCharging) {
      LogUtil.info(`${this.tag} battery info oldbattery ${this.battery}, newbattery ${newBattery}`);
      LogUtil.info(`${this.tag} charging status oldstatus ${this.charging}, newstatus ${isCharging}`);
      this.charging = isCharging;
      this.battery = newBattery;
      this.getBatteryInfo();
    }
  }

  private updateBatteryInfo(): void {
    this.getBatteryInfoTask();
    this.batteryTimer = setInterval(() => {
      this.getBatteryInfoTask();
    }, componentConfig.loopingChargeTimes);
  }

  formatBattery(): void {
    try {
      if (Number.isNaN(Number(this.battery)) || Number(this.battery) < componentConfig.batteryLeverZero ||
        Number(this.battery) > componentConfig.batteryLeverOneHundred) {
        this.battery = componentConfig.defaultBatteryPower;
      } else {
        this.battery = String(Math.floor(Number(this.battery)));
      }
    } catch {
      this.battery = componentConfig.defaultBatteryPower;
      LogUtil.error(`${this.tag} format battery failed`);
    }
  }

  getBatteryInfo(): void {
    this.formatBattery();
    this.batteryValue = this.battery + '%';
    this.updateBatteryDrawableIndex();
    if (uiAppearance.getDarkMode() === uiAppearance.DarkMode.ALWAYS_DARK) {
      this.currentBatteryImage = this.charging ? this.batteryChargingDarkDrawables[this.batteryLevelIndex]
        : this.batteryNormalDarkDrawables[this.batteryLevelIndex];
    } else {
      this.currentBatteryImage = this.charging ? this.batteryChargingDrawables[this.batteryLevelIndex]
        : this.batteryNormalDrawables[this.batteryLevelIndex];
    }
  }

  private updateBatteryDrawableIndex(): void {
    if (this.battery === null || this.battery === undefined) {
      return;
    }
    let level = Number(this.battery);
    if (componentConfig.batteryLeverFive < level && level <= componentConfig.batteryLeverNinetyFive) {
      this.batteryLevelIndex = Math.floor((level - this.batteryIndexOne) / componentConfig.dividend +
      this.batteryIndexOne);
    } else if (componentConfig.batteryLeverNinetyFive < level && level <= componentConfig.batteryLeverOneHundred) {
      this.batteryLevelIndex = componentConfig.batteryLevelList.length - this.batteryIndexOne;
    }
  }

  @Builder
  batteryInfoBuilder(): void {
    if (this.isNeedShowBattery) {
      Row({ space: componentConfig.rowSpaceTwo }) {
        Image(this.currentBatteryImage)
          .objectFit(ImageFit.Contain)
          .width($r('app.float.length_24'))
          .height($r('app.float.length_22'))

        Text(this.batteryValue)
          .id(`${this.compId}.desp`)
          .textStyle(this.defaultPageConfig.getDefaultTextStyle(SettingTextType.TEXT_TYPE_SECONDARY))
      }
      .margin({ top: $r('app.float.margin_2') })
    }
  }

  @Builder
  itemResultBuilder(): void {
    Text($r('app.string.product_info'))
      .id(`${this.compId}.result`)
      .textStyle(this.defaultPageConfig.getDefaultTextStyle(SettingTextType.TEXT_TYPE_SECONDARY))
      .textAlign(TextAlign.End)
      .constraintSize({ minWidth: '33%' })
      .flexShrink(1)
  }

  @Builder
  itemTitleBuilder(): void {
    Text(this.keyboardName)
      .id(`${this.compId}.title`)
      .textStyle(this.defaultPageConfig.getDefaultTextStyle(SettingTextType.TEXT_TYPE_PRIMARY))
  }

  @Builder
  itemContentBuilder(): void {
    Row() {
      Column() {
        this.itemTitleBuilder()
        this.batteryInfoBuilder()
      }
      .alignItems(HorizontalAlign.Start)
      .constraintSize({ maxWidth: '67%' })

      this.itemResultBuilder()
    }
    .justifyContent(FlexAlign.SpaceBetween)
    .layoutWeight(1)
    .padding({ top: $r('sys.float.padding_level4'), bottom: $r('sys.float.padding_level4') })
    .constraintSize({ minHeight: $r('app.float.height_64') })
  }

  @Builder
  itemDetailBuilder(): void {
    Image($r('app.media.ic_settings_arrow'))
      .id(`${this.compId}.detail`)
      .iconStyle(this.defaultPageConfig.getDefaultIconStyle(SettingIconType.ICON_TYPE_ARROW))
      .margin({ left: $r('sys.float.padding_level2') })
  }

  build() {
    Row() {
      this.itemContentBuilder()

      this.itemDetailBuilder()
    }
    .id(this.compId)
    .width('100%')
    .borderRadius($r('sys.float.corner_radius_level8'))
    .padding({ left: $r('sys.float.padding_level4'), right: $r('sys.float.padding_level4') })
    .backgroundColor(this.isHover ? $r('sys.color.interactive_hover') : undefined)
    .onClick(() => {
      PageRouter.push(NavEntryKey.PAD_KEYBOARD_INFORMATION, new PushParam(this.compId as Object));
    })
    .onHover((isHover: boolean) => {
      this.isHover = isHover
    })
  }
}

@Builder
export function keyboardInfoItemBuilder(param: object): void {
  KeyboardInfoItemComponent({
    compId: 'Setting.Keyboard.KeyboardInfoGroup.KeyboardInfomationItem'
  });
}
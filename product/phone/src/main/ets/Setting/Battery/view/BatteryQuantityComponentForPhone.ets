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
import { CommonEventConstant } from '@ohos/settings.common/src/main/ets/constant/CommonEventConstant';
import {
  PADDING_0,
  PADDING_2,
  PADDING_18,
  PADDING_24,
  PADDING_27,
  PADDING_30,
  PADDING_42,
} from '@ohos/settings.common/src/main/ets/constant/StyleConstant';
import { FULL_CHARGE } from '@ohos/settings.common/src/main/ets/constant/BatteryConstant';
import { EventBus } from '@ohos/settings.common/src/main/ets/framework/common/EventBus';
import { SettingGroupModel } from '@ohos/settings.common/src/main/ets/framework/model/SettingGroupModel';
import { LogUtil } from '@ohos/settings.common/src/main/ets/utils/LogUtil';
import { LanguageUtils } from '@ohos/settings.common/src/main/ets/utils/LanguageUtils';
import { DeviceUtil } from '@ohos/settings.common/src/main/ets/utils/BaseUtils';
import { BatteryQuantityController } from '../controller/BatteryQuantityController';
import { BatteryQuantityModel } from '../model/BatteryQuantityModel';

@Component
export struct BatteryQuantityComponentForPhone {
  public tag: string = 'BatteryQuantityComponentForPhone: ';
  item?: SettingGroupModel;
  compId: string = '';
  compControl?: BatteryQuantityController;
  @State title: ResourceStr = '';
  @State summary: ResourceStr = '';
  @State progressColor: ResourceStr = '#34C759';
  @State isCharging: boolean = false;
  @StorageProp('navigationMode') navigationMode: NavigationMode | undefined = NavigationMode.Stack;
  @StorageProp('calNavBarWidth') calNavBarWidth: number = 0;

  private chargingEventCallback = (model: BatteryQuantityModel) => {
    if (!model) {
      LogUtil.error(`${this.tag} ths param is invalid`);
      return;
    }

    LogUtil.info(`${this.tag} receive BatteryQuantityModel change`);
    this.title = model.batteryQuantity;
    this.isCharging = model.isCharging;
    this.progressColor = model.progressColor;
    this.summary = model.summary;
  };

  private isNarrowScreen(): boolean {
    if (DeviceUtil.isNfcAntLocationLow()) {
      return false;
    }
    return this.navigationMode === NavigationMode.Stack;
  }

  build() {
    Row() {
      Stack() {
        Column() {
          Progress({ value: Number(this.title), total: FULL_CHARGE, type: ProgressType.Linear })
            .height(118)
            .color(this.progressColor)
            .style({
              strokeWidth: 118,
              strokeRadius: 0,
              enableSmoothEffect: false,
            })
            .borderRadius($r('app.float.wh_value_16'))
            .clip(true)
        }
        .border({ width: 1, color: 'rgba(0,0,0,0.15)', radius: 17 })

        Row() {
          // 电池百分比
          Text(LanguageUtils.getPercentFormat(Number(this.title)))
          .fontFamily('HarmonyHeiTi')
          .fontSize($r('sys.float.Display_M'))
          .fontWeight(FontWeight.Bold)
          .fontColor(Number(this.title) > 25 ? $r('sys.color.font_on_primary') : $r('sys.color.font_primary'))
          .maxFontScale(1.2)
          .lineHeight(64)
          .margin({ start: PADDING_24, end: PADDING_24 })

          // 充电图标
          Image($r('app.media.ic_battery'))
            .draggable(false)
            .visibility(this.summary ? Visibility.Visible : Visibility.None)
            .width($r('app.float.wh_value_14'))
            .height($r('app.float.wh_value_40'))
            .fillColor(Number(this.title) > 25 ? $r('sys.color.icon_on_primary') : $r('sys.color.icon_primary'))
        }
        .width('100%')
      }
      .width(this.isNarrowScreen() ? '100%' : 280)
      // 电池正极
      Column() {
      }
      .width($r('app.float.wh_value_10'))
      .height($r('app.float.wh_value_32'))
      .backgroundColor(Number(this.title) === FULL_CHARGE ? '#34C759' : Color.Gray)
      .borderRadius('3vp')
      .margin({ start: PADDING_2 })
      .opacity(Number(this.title) === FULL_CHARGE ? 1 : 0.2)
    }
    .width('100%')
    .padding({
      start: this.isNarrowScreen() ? PADDING_18 : PADDING_0,
      end: this.isNarrowScreen() ? PADDING_30 : PADDING_0,
      top: PADDING_27,
      bottom: PADDING_42,
    })
    .borderRadius($r('app.float.wh_value_20'))
    .backgroundColor($r('sys.color.comp_background_list_card'))
    .accessibilityGroup(true)
    .accessibilityText($r('app.string.battery_level'))
    .accessibilityDescription(`${this.title}%`)
    .justifyContent(FlexAlign.Center)
  }

  aboutToAppear(): void {
    LogUtil.info(`${this.tag} aboutToAppear. calNavBarWidth:${this.calNavBarWidth}`);
    this.compId = this.item?.id as string;
    this.compControl = this.item?.compControl as BatteryQuantityController;
    EventBus.getInstance().on(CommonEventConstant.EVENT_BATTERY_QUANTITY_REFRESH, this.chargingEventCallback);
    this.compControl?.init({ compId: this.compId, component: this.item as SettingGroupModel });
  }

  aboutToDisappear(): void {
    LogUtil.info(`${this.tag} aboutToDisappear`);
    EventBus.getInstance().detach(CommonEventConstant.EVENT_BATTERY_QUANTITY_REFRESH, this.chargingEventCallback);
    this.compControl?.destroy();
  }
}
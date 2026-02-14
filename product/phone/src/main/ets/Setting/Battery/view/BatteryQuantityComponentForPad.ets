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
import { LengthMetrics } from '@kit.ArkUI';
import { CommonEventConstant } from '@ohos/settings.common/src/main/ets/constant/CommonEventConstant';
import {
  PADDING_2,
  PADDING_24,
  PADDING_30,
  PADDING_48
} from '@ohos/settings.common/src/main/ets/constant/StyleConstant';
import { FULL_CHARGE } from '@ohos/settings.common/src/main/ets/constant/BatteryConstant';
import { EventBus } from '@ohos/settings.common/src/main/ets/framework/common/EventBus';
import { SettingGroupModel } from '@ohos/settings.common/src/main/ets/framework/model/SettingGroupModel';
import { LogUtil } from '@ohos/settings.common/src/main/ets/utils/LogUtil';
import { LanguageUtils } from '@ohos/settings.common/src/main/ets/utils/LanguageUtils';
import { BatteryQuantityController } from '../controller/BatteryQuantityController';
import { BatteryQuantityModel } from '../model/BatteryQuantityModel';

@Component
export struct BatteryQuantityComponentForPad {
  public tag: string = 'BatteryQuantityComponentForPad: ';
  item?: SettingGroupModel;
  compId: string = '';
  compControl?: BatteryQuantityController;
  @State title: ResourceStr = '';
  @State summary: ResourceStr = '';
  @State progressColor: ResourceStr = '#34C759';
  @State isCharging: boolean = false;
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

  build() {
    Flex({
      wrap: FlexWrap.Wrap,
      alignItems: ItemAlign.Center,
      justifyContent: FlexAlign.SpaceBetween,
      space: { cross: LengthMetrics.vp(16) }
    }) {
      Column() {
        Text(LanguageUtils.getPercentFormat(Number(this.title)))
        .fontSize($r('sys.float.Display_M'))
        .fontWeight(FontWeight.Bold)
        .fontColor($r('sys.color.icon_primary'))
        .lineHeight(64)
        .maxFontScale(2)

        Text(this.summary)
        .fontSize($r('sys.float.Body_M'))
        .fontColor($r('sys.color.font_secondary'))
        .lineHeight(19)
        .visibility((this.summary && Number(this.title) !== FULL_CHARGE) ? Visibility.Visible : Visibility.None)
      }
      .alignItems(HorizontalAlign.Start)

      Row() {
        Stack() {
          Column() {
            Progress({ value: Number(this.title), total: FULL_CHARGE, type: ProgressType.Linear })
              .width(209)
              .height(88)
              .color(this.progressColor)
              .style({
                strokeWidth: 88,
                strokeRadius: 0,
                enableSmoothEffect: false, // 动画
              })
              .borderRadius(13)
              .clip(true)
          }
          .border({ width: 1, color: 'rgba(0,0,0,0.15)', radius: 14 })
          // 充电图标
          Image($r('app.media.ic_battery'))
            .draggable(false)
            .visibility(this.summary ? Visibility.Visible : Visibility.None)
            .width($r('app.float.wh_value_14'))
            .height($r('app.float.wh_value_40'))
            .fillColor(Number(this.title) > 50 ? $r('sys.color.icon_on_primary') : $r('sys.color.icon_primary'))
        }
        // 电池正极
        Column() {
        }
        .width(7)
        .height(24)
        .backgroundColor(Number(this.title) === FULL_CHARGE ? '#34C759' : $r('sys.color.comp_background_secondary'))
        .borderRadius(3)
        .margin({ start: PADDING_2 })
      }
    }
    .width('100%')
    // 屏幕宽度小于 840 用小边距
    .padding({
      start: this.calNavBarWidth < 840 ? PADDING_24 : PADDING_48,
      end: this.calNavBarWidth < 840 ? PADDING_24 : PADDING_48,
      top: PADDING_30,
      bottom: PADDING_30,
    })
    .borderRadius($r('sys.float.corner_radius_level10'))
    .backgroundColor($r('sys.color.comp_background_list_card'))
    .accessibilityGroup(true)
    .accessibilityText($r('app.string.battery_level'))
    .accessibilityDescription(`${this.title}%`)
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
  }
}
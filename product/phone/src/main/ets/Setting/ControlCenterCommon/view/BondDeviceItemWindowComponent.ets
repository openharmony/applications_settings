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
import { HiSysEventUtil } from '@ohos/settings.common/src/main/ets/systemEvent/HiSysEventUtil';
import { HiSysAboutBluetoothEventGroup } from '@ohos/settings.common/src/main/ets/systemEvent/BehaviorEventConsts';

const TAG: string = 'BondDeviceItemWindowComponent: ';

@Component
export struct BondDeviceItemWindowComponent {
  @Prop controlCenterColor: ResourceColor = $r('app.color.control_center_sub_panel_color');
  @Prop title: ResourceStr;
  @Prop subTitle: ResourceStr;
  @Prop isConnect: boolean;
  @Prop symbolIcon?: ResourceStr = undefined;
  @State itemBackgroundColor: ResourceColor = Color.Transparent;
  handleClickEvent?: () => void;

  build() {
    ListItem() {
      Row() {
        Column() {
          SymbolGlyph(this.symbolIcon as Resource)
            .fontSize($r('app.float.wh_value_24'))
            .fontColor([$r('sys.color.ohos_id_color_secondary')])
            .renderingStrategy(SymbolRenderingStrategy.MULTIPLE_OPACITY)
            .draggable(false)
        }

        Column() {
          Text(this.title)
            .fontColor(this.isConnect ? this.controlCenterColor : $r('app.color.window_settings_font_secondary'))
            .fontSize(this.isConnect ? $r('app.float.font_16') : $r('sys.float.ohos_id_text_size_body1'))
            .fontWeight(FontWeight.Medium)
            .fontFamily('HarmonyHeiTi')
            .lineHeight(this.isConnect ? $r('app.float.font_22') : $r('app.float.font_21'))
          if (this.subTitle) {
            Text(this.subTitle)
              .fontFamily('HarmonyHeiTi')
              .fontSize($r('app.float.font_14'))
              .fontColor($r('app.color.window_settings_font_tertiary'))
              .fontWeight(FontWeight.Regular)
              .lineHeight($r('app.float.font_19'))
              .textAlign(TextAlign.Start)
              .margin({
                top: $r('app.float.length_2'),
              })
          }
        }
        .layoutWeight(1)
        .margin({
          left: $r('app.float.wh_value_12'),
          right: $r('app.float.wh_value_9'),
        })
        .padding({
          top: this.subTitle ? $r('app.float.wh_value_9_5') : $r('app.float.wh_value_17'),
          bottom: this.subTitle ? $r('app.float.wh_value_12') : $r('app.float.wh_value_16'),
        })
        .alignItems(HorizontalAlign.Start)
        .justifyContent(FlexAlign.Center)

        if (this.isConnect) {
          Column() {
            Image($r('app.media.ic_connect_ok'))
              .fillColor(this.controlCenterColor)
              .size({
                width: $r('app.float.wh_value_18'),
                height: $r('app.float.wh_value_18'),
              })
              .draggable(false)
          }
        }
      }
      .width('100%')
      .padding({
        left: 8,
        right: 8,
      })
      .justifyContent(FlexAlign.SpaceBetween)
      .borderRadius($r('app.float.wh_value_16'))
      .stateStyles({
        normal: this.normalStyles,
        pressed: this.pressedStyles,
      })
      .onClick(() => {
        LogUtil.info(`${TAG} onclick`);
        let reportParams: Record<string, Object> = {};
        reportParams.VALUE = this.title;
        reportParams.IS_SETTINGS_OPEN = '0';
        HiSysEventUtil.reportBehaviorEventByUE(HiSysAboutBluetoothEventGroup.SELECT_BLUETOOTH_PAIRING, reportParams);
        this.handleClickEvent?.();
      })
      .backgroundColor(this.itemBackgroundColor)
      .onHover((isHover?: boolean) => {
        this.itemBackgroundColor = isHover ? $r('sys.color.interactive_hover') : Color.Transparent;
      })
    }
    .padding({
      left: 8,
      right: 8,
    })
  }

  @Styles
  normalStyles() {
    .backgroundColor(Color.Transparent)
  }

  @Styles
  pressedStyles() {
    .backgroundColor($r('sys.color.ohos_id_color_click_effect'))
  }
}

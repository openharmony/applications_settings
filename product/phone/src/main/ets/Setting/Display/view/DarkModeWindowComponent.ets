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

import settings from '@ohos.settings';
import { EventBus } from '@ohos/settings.common/src/main/ets/framework/common/EventBus';
import {
  HiSysDisplayBrightnessEventGroup,
  HiSysDisplayEventGroup } from '@ohos/settings.common/src/main/ets/systemEvent/BehaviorEventConsts';
import { HiSysEventUtil } from '@ohos/settings.common/src/main/ets/systemEvent/HiSysEventUtil';
import { AccessibilityUtils } from '@ohos/settings.common/src/main/ets/utils/AccessibilityUtils';
import { ResourceUtil } from '@ohos/settings.common/src/main/ets/utils/ResourceUtil';
import { LogUtil } from '@ohos/settings.common/src/main/ets/utils/LogUtil';
import { SettingsDataUtils } from '@ohos/settings.common/src/main/ets/utils/SettingsDataUtils';
import BlendModeUtil from '@ohos/settings.commonUikit/src/main/ets/utils/BlendModeUtil';
import {
  CLICK_ENABLE_EVENT,
  DARK_MODE_STATE,
  DARK_MODE_TIMED_ON,
  DEFAULT_DARK_MODE_END_TIME,
  DEFAULT_DARK_MODE_START_TIME,
  INVALID_VALUE,
  SETTINGS_UI_APPEARANCE_DARK_MODE,
  SETTINGS_UI_APPEARANCE_DARK_MODE_ENDTIME,
  SETTINGS_UI_APPEARANCE_DARK_MODE_STARTTIME,
  SWITCH_DELAY
} from '@ohos/settings.display/src/main/ets/constant/DarkModeConstant';
import { DisplayUtils } from '../utils/DisplayUtils';
/* instrument ignore file */
const TAG: string = 'DarkModeWindowComponent: ';
const STR_START_TIME: string = 'startTime';
const STR_END_TIME: string = 'endTime';
const STR_ON: string = 'on';

/**
 * 控制中心二级页面-标题组件
 */
@Component
export struct DarkModeWindowTitleComponent {
  private symbol: Resource = $r('sys.symbol.circle_filled_and_circle');
  private title: ResourceStr = $r('app.string.dark_mode');
  private domId: string = 'dark_mode_window_title';
  @Prop isDarkMode: boolean;

  build() {
    Column() {
      Column() {
        SymbolGlyph(this.symbol)
          .fontSize($r('app.float.wh_value_24'))
          .fontWeight(FontWeight.Medium)
          .fontColor([$r('sys.color.ohos_id_color_primary')])
          .advancedBlendMode(this.isDarkMode ? BlendModeUtil.blenderCenterDark : BlendModeUtil.blenderCenter)
      }
      .margin({
        bottom: $r('app.float.wh_value_8'),
      })

      Text(this.title)
        .fontFamily('HarmonyHeiTi')
        .fontWeight(FontWeight.Medium)
        .advancedBlendMode(this.isDarkMode ? BlendModeUtil.blenderCenterDark : BlendModeUtil.blenderCenter)
        .fontSize($r('sys.float.ohos_id_text_size_headline8'))
        .fontColor($r('app.color.window_settings_font_primary'))
        .lineHeight($r('app.float.wh_value_26'))
        .height($r('app.float.wh_value_26'))
        .id(this.domId)
    }
    .width('100%')
    .padding({
      top: $r('app.float.wh_value_16'),
      bottom: $r('app.float.wh_value_16'),
    })
    .alignItems(HorizontalAlign.Center)

  }
}

/**
 * item样式内容
 */
@Component
export struct DarkModeItemComponent {
  @State clickEnable: boolean = true;
  @Prop comId: string;
  @Prop controlCenterColor: ResourceColor = $r('app.color.control_center_sub_panel_color');
  @Prop title: ResourceStr;
  @Prop subTitle: ResourceStr;
  @Prop isSelected: boolean;
  @Prop value: string;
  private modeChangeCb = (newMode: string) => {
    LogUtil.info(`${TAG} modeChangeCb : newMode:${newMode}`);
    this.isSelected = this.value === newMode;
  }

  aboutToAppear(): void {
    EventBus.getInstance().on(DARK_MODE_STATE, this.modeChangeCb);
  }

  aboutToDisappear(): void {
    EventBus.getInstance().detach(DARK_MODE_STATE, this.modeChangeCb);
  }

  private handleClickEvent(): void {
    if (this.isSelected) {
      return;
    }
    EventBus.getInstance().emit(CLICK_ENABLE_EVENT, false);
    setTimeout(() => {
      EventBus.getInstance().emit(CLICK_ENABLE_EVENT, true);
    }, SWITCH_DELAY);
    LogUtil.info(`${TAG} handleClickEvent:value:${this.value}`);
    SettingsDataUtils.setSettingsDataDomain(SETTINGS_UI_APPEARANCE_DARK_MODE, this.value,
      settings.domainName.USER_PROPERTY);
    if (this.value === DARK_MODE_TIMED_ON) {
      let startTime: string = SettingsDataUtils.getSettingsDataDomain(SETTINGS_UI_APPEARANCE_DARK_MODE_STARTTIME,
        INVALID_VALUE, settings.domainName.USER_PROPERTY);
      let endTime: string = SettingsDataUtils.getSettingsDataDomain(SETTINGS_UI_APPEARANCE_DARK_MODE_ENDTIME,
        INVALID_VALUE, settings.domainName.USER_PROPERTY);
      if (startTime === INVALID_VALUE || endTime === INVALID_VALUE) {
        SettingsDataUtils.setSettingsData(SETTINGS_UI_APPEARANCE_DARK_MODE_STARTTIME, DEFAULT_DARK_MODE_START_TIME,
          settings.domainName.USER_PROPERTY);
        SettingsDataUtils.setSettingsData(SETTINGS_UI_APPEARANCE_DARK_MODE_ENDTIME, DEFAULT_DARK_MODE_END_TIME,
          settings.domainName.USER_PROPERTY);
        startTime = DEFAULT_DARK_MODE_START_TIME;
        endTime = DEFAULT_DARK_MODE_END_TIME;
      }
      HiSysEventUtil.serviceStatusDefaultBehaviorEventByUE(HiSysDisplayBrightnessEventGroup.DARK_MODE_SCHEDULED_SWITCH,
        STR_START_TIME, startTime, STR_ON);
      HiSysEventUtil.serviceStatusDefaultBehaviorEventByUE(HiSysDisplayBrightnessEventGroup.DARK_MODE_SCHEDULED_SWITCH,
        STR_END_TIME, endTime, STR_ON);
    } else {
      HiSysEventUtil.reportDefaultBehaviorEventByUE(HiSysDisplayEventGroup.DARK_MODE_ALL_DAY_SWITCH, STR_ON);
    }
    DisplayUtils.closeHighContrastTextMode();
    EventBus.getInstance().emit(DARK_MODE_STATE, this.value);
  }

  build() {
    ListItem() {
      Row() {
        Column() {
          Text(this.title)
            .fontColor(this.isSelected ? $r('app.color.control_center_sub_panel_color') : $r('app.color.window_settings_font_secondary'))
            .fontSize(this.isSelected ? $r('app.float.font_16') : $r('sys.float.ohos_id_text_size_body1'))
            .fontWeight(FontWeight.Medium)
            .fontFamily('HarmonyHeiTi')
            .lineHeight($r('app.float.font_21'))

          if (this.subTitle) {
            Text(this.subTitle)
              .fontFamily('HarmonyHeiTi')
              .fontSize($r('app.float.font_14'))
              .fontColor(this.isSelected ? $r('app.color.control_center_sub_panel_color') : $r('app.color.window_settings_font_secondary'))
              .fontWeight(FontWeight.Regular)
              .lineHeight($r('app.float.font_19'))
              .textAlign(TextAlign.Start)
              .margin({
                top: $r('app.float.length_2'),
              })
          }
        }
        .opacity(this.clickEnable ? 1 : 0.5)
        .layoutWeight(1)
        .padding({
          top: this.subTitle ? $r('app.float.wh_value_9_5') : $r('app.float.wh_value_17'),
          bottom: this.subTitle ? $r('app.float.wh_value_12') : $r('app.float.wh_value_16'),
        })
        .alignItems(HorizontalAlign.Start)
        .justifyContent(FlexAlign.Center)

        if (this.isSelected) {
          Column() {
            Image($r('app.media.ic_connect_ok'))
              .fillColor($r('app.color.control_center_sub_panel_color'))
              .size({
                width: $r('app.float.wh_value_18'),
                height: $r('app.float.wh_value_18'),
              })
              .draggable(false)
          }
        }
      }
      .accessibilitySelected(this.isSelected)
      .accessibilityDescription(this.isSelected ? ' ' : '')
      .width('100%')
      .padding({
        left: $r('app.float.wh_value_8'),
        right: $r('app.float.wh_value_8'),
      })
      .stateStyles({
        normal: {
          .backgroundColor($r('app.color.color_default_white'))
          .borderRadius($r('sys.float.corner_radius_level8'))
        },
        pressed: {
          .backgroundColor($r('sys.color.interactive_click'))
          .borderRadius($r('sys.float.corner_radius_level8'))
        },
      })
      .justifyContent(FlexAlign.SpaceBetween)
      .borderRadius($r('app.float.wh_value_16'))
      .onClick(() => {
        this.handleClickEvent?.();
      })
    }
  }
}

/**
 * 控制中心二级页面-更多设置按钮组件
 */
@Component
export struct MoreSettingButtonComponent {
  @State bgColor: ResourceColor = Color.Transparent;
  @Prop controlCenterColor: ResourceColor = $r('app.color.control_center_sub_panel_color');
  onMoreSettingClick?: () => void;

  build() {
    Column() {
      Text($r('app.string.more_settings'))
        .fontFamily('HarmonyHeiTi')
        .fontWeight(FontWeight.Medium)
        .fontSize($r('app.float.font_15'))
        .fontColor($r('app.color.control_center_sub_panel_color'))
        .lineHeight($r('app.float.font_21'))
        .width('100%')
        .textAlign(TextAlign.Center)
        .maxFontScale(2)
    }
    .borderRadius($r('app.float.wh_value_20'))
    .backgroundColor(this.bgColor)
    .alignItems(HorizontalAlign.Center)
    .margin({
      top: $r('app.float.wh_value_6'),
      bottom: $r('app.float.wh_value_16'),
      left: $r('app.float.wh_value_16'),
      right: $r('app.float.wh_value_16'),
    })
    .padding({
      top: $r('app.float.wh_value_10'),
      bottom: $r('app.float.wh_value_9'),
    })
    .onHover((isHover?: boolean) => {
      this.onHoverEvent(isHover);
    })
    .onTouch((event?: TouchEvent) => {
      this.onTouchEvent(event);
    })
    .onMouse((event?: MouseEvent): void => {
      this.onMouseEvent(event)
    })
    .onClick((event) => {
      this.onMoreSettingClick?.();
    })
  }

  private onHoverEvent(isHover?: boolean): void {
    this.bgColor = isHover ? $r('sys.color.ohos_id_color_hover') : Color.Transparent;
  }

  private onTouchEvent(event?: TouchEvent): void {
    if (event && event.type === TouchType.Down) {
      this.bgColor = $r('sys.color.interactive_pressed');
    }
    if (event && event.type === TouchType.Up) {
      this.bgColor = Color.Transparent;
    }
  }

  private onMouseEvent(event?: MouseEvent): void {
    if (!event || event.button != MouseButton.Left) {
      return;
    }
    this.bgColor = event.action === MouseAction.Press ? $r('sys.color.ohos_id_color_click_effect') : Color.Transparent;
  }
}
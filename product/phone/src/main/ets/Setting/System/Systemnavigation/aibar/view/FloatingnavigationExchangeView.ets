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
import { LogUtil } from '@ohos/settings.common/src/main/ets/utils/LogUtil';
import { PADDING_24 } from '@ohos/settings.common/src/main/ets/constant/StyleConstant';
import { AccessibilityLevelType } from '@ohos/settings.common/src/main/ets/utils/AccessibilityUtils';
/* instrument ignore file */
const TAG: string = 'FloatingNavigationExchangeView';

@Component
export struct FloatingNavigationExchangeView {
  readonly RIGHT: string = '0';
  readonly LEFT: string = '1';
  readonly SETINGS_DATA_KEY: string = 'floatingnavigation_exchange_button';
  readonly ICON_SIZE: string = '16vp';
  readonly SETINGS_DATA_DOMAIN = settings.domainName.USER_PROPERTY;
  readonly STROKE_WIDTH: number = 0.5;
  @State selectedDirection: string = this.RIGHT;
  @Consume('exchangeButton') @Watch('exchangeButton') isExchangeButton: boolean;

  aboutToAppear(): void {
    LogUtil.showInfo(TAG, 'aboutToAppear');
    try {
      let direction =
        settings.getValueSync(getContext(), this.SETINGS_DATA_KEY, this.RIGHT, this.SETINGS_DATA_DOMAIN);
      this.selectedDirection = direction;
      LogUtil.showInfo(TAG, `aboutToAppear selectedDirection is: ${direction}`);
    } catch (err) {
      LogUtil.showError(TAG, `err is: ${err?.code}  ${err?.message}`);
      this.selectedDirection = this.RIGHT;
    }
  }

  aboutToDisappear(): void {
    LogUtil.showInfo(TAG, 'aboutToDisappear');
  }

  build() {
    this.DirectionGroup();
  }

  @Builder
  DirectionGroup() {
    List() {
      ListItem() {
        this.exchangeItemView(this.RIGHT);
      }

      ListItem() {
        this.exchangeItemView(this.LEFT);
      }
    }
    .divider({
      strokeWidth: this.STROKE_WIDTH,
      color: $r('sys.color.ohos_id_color_list_separator'),
      startMargin: $r('app.float.distance_8'),
      endMargin: $r('app.float.distance_8'),
    })
    .switchCardStyle()
  }

  @Builder
  exchangeItemView(direction: string) {
    Row() {
      Row() {
        Image(direction == this.RIGHT ? $r('app.media.square_inapp') : $r('app.media.chevron_backward_inapp'))
          .width(this.ICON_SIZE)
          .height(this.ICON_SIZE)
          .imageStyles()
        Image($r('app.media.circle_inapp'))
          .width(this.ICON_SIZE)
          .height(this.ICON_SIZE)
          .margin({ start: PADDING_24 })
          .imageStyles()
        Image(direction == this.RIGHT ? $r('app.media.chevron_backward_inapp') : $r('app.media.square_inapp'))
          .width(this.ICON_SIZE)
          .height(this.ICON_SIZE)
          .margin({ start: PADDING_24 })
          .imageStyles()
      }
      .layoutWeight(1)

      Toggle({
        type: ToggleType.Checkbox,
        isOn: this.selectedDirection === direction
      })
        .accessibilityLevel(AccessibilityLevelType.NO)
        .hitTestBehavior(HitTestMode.None)
        .visibility(this.selectedDirection === direction ? Visibility.Visible : Visibility.Hidden)
    }
    .accessibilityGroup(true)
    .accessibilitySelected(this.selectedDirection === direction)
    .accessibilityDescription(this.selectedDirection === direction ? ' ' : '')
    .accessibilityText(direction === this.RIGHT ? $r('app.string.accessibility_text_right') :
    $r('app.string.accessibility_text_left'))
    .settingItemStyle()
    .onClick(() => {
      if (this.selectedDirection === direction) {
        LogUtil.showInfo(TAG, 'currently selected');
        return;
      }
      LogUtil.showInfo(TAG, `onClick selectedDirection is ${direction}`);
      this.selectedDirection = direction;
      this.setValueToSettingsData(this.selectedDirection);
    })
  }

  @Styles
  switchCardStyle() {
    .padding({
      left: 4,
      right: 4,
      top: 4,
      bottom: 4,
    })
    .backgroundColor($r('sys.color.ohos_id_color_card_bg'))
    .borderRadius(16)
    .width('100%')
  }

  @Styles
  settingItemStyle() {
    .padding({
      top: 10,
      bottom: 10,
      left: 8,
      right: 8
    })
    .backgroundColor($r('sys.color.ohos_id_color_card_bg'))
    .borderRadius(16)
    .width('100%')
  }

  @Styles
  imageStyles(){
    .transition(TransitionEffect.OPACITY.animation({ duration: 100, curve: Curve.Sharp }))
    .draggable(false)
  }

  private setValueToSettingsData(selectedDirection: string) {
    try {
      LogUtil.showInfo(TAG, `setValue is ${selectedDirection} `);
      settings.setValue(getContext(), this.SETINGS_DATA_KEY, selectedDirection, this.SETINGS_DATA_DOMAIN);
    } catch (e) {
      LogUtil.showError(TAG, `setValue is error ${e?.code} ${e?.message}`);
    }
  }

  /**
   * 收到位置信息改变的监听
   */
  private exchangeButton(): void {
    let direction =
      settings.getValueSync(getContext(), this.SETINGS_DATA_KEY, this.RIGHT, this.SETINGS_DATA_DOMAIN);
    if (direction === this.selectedDirection) {
      LogUtil.showInfo(TAG, `direction and selectedDirection is same `);
      return;
    }
    this.selectedDirection = direction;
    LogUtil.showInfo(TAG, `exchangeButton is: ${direction}`);
  }
}
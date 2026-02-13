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
import { SettingItemModel } from '@ohos/settings.common/src/main/ets/framework/model/SettingItemModel';
import {
  SettingBaseState,
  SettingStateType
} from '@ohos/settings.common/src/main/ets/framework/model/SettingStateModel';
import { DeviceUtil } from '@ohos/settings.common/src/main/ets/utils/BaseUtils';
import { SettingsDataUtils } from '@ohos/settings.common/src/main/ets/utils/SettingsDataUtils';
import { SleepKey, SleepTime } from '../Constant/Constant';
import { DormancyRadioController } from '../controller/DormancyRadioController';
/* instrument ignore file */
const DELAY_CLOSE_DIALOG: number = 250;

@Styles
function pressedStateStyles() {
  .backgroundColor($r('sys.color.interactive_click'))
}

@Styles
function normalStateStyles() {
  .backgroundColor(Color.Transparent)
}

@Component
struct RadioComponent {
  compId: string = '';
  itemModel?: SettingItemModel | undefined;
  @State controller?: DormancyRadioController = undefined;

  private closeDialog(): void {
    setTimeout(() => {
      this.itemModel?.onItemEvent?.(new Map([[SettingStateType.STATE_TYPE_ITEM_DIALOG, {} as SettingBaseState]]));
    }, DELAY_CLOSE_DIALOG);
  }

  aboutToAppear(): void {
    this.controller?.init();
  }

  build() {
    Column() {
      Flex({ direction: FlexDirection.Row, justifyContent: FlexAlign.SpaceBetween, alignItems: ItemAlign.Center }) {
        Text(this.controller?.menuTitle)
          .fontColor($r('sys.color.font_primary'))
          .fontSize($r('sys.float.Subtitle_M'))
          .fontWeight(FontWeight.Medium)
          .textAlign(TextAlign.Start)
          .flexShrink(0)
          .flexGrow(1)
          .width(DeviceUtil.isDevicePhone() ? 'calc(100% - 20vp - 24vp)' : 'calc(100% - 24vp - 24vp)')

        if (this.controller?.isChecked){
          Radio({
            value: this.compId,
            group: 'dormancy_dialog_group'
          })
            .checked(this.controller?.isChecked)
            .onChange((isChecked: boolean) => {
              if (this.controller) {
                this.controller.isChecked = isChecked;
              }
            })
            .radioStyle({
              checkedBackgroundColor: $r('sys.color.comp_background_emphasize')
            })
            .height(DeviceUtil.isDevicePhone() ? $r('app.float.length_20') : $r('app.float.length_24'))
            .width(DeviceUtil.isDevicePhone() ? $r('app.float.length_20') : $r('app.float.length_24'))
            .hitTestBehavior(HitTestMode.None)
            .id(`dormancy_radiomenu_radio_${this.compId}`)
            .onClick((event) => {
              this.controller?.onRadioChange(true);
              this.closeDialog();
            });
        }
      }
      .padding({ left: $r('sys.float.padding_level6'), right: $r('sys.float.padding_level6'), top: $r('sys.float.padding_level3'), bottom:  $r('sys.float.padding_level3')})
      .constraintSize({ minHeight: $r('app.float.wh_value_48') })
      .borderRadius($r('sys.float.corner_radius_level8'))
      .stateStyles({
        normal: normalStateStyles,
        pressed: pressedStateStyles,
      })
    }
    .onClick((event) => {
      this.controller?.onRadioChange(true);
      this.closeDialog();
    })
    .accessibilityGroup(true)
    .accessibilityText(this.controller?.menuTitle)
    .accessibilityDescription(this.controller?.isChecked ? $r('app.string.be_chosen') :
      $r('app.string.not_selected_click_tips'))
  }
}

@Component
export struct DormancyDialogComponent {
  private itemModel?: SettingItemModel | undefined;
  private dormancyTime: string =
    SettingsDataUtils.getSettingsData(settings.display.SCREEN_OFF_TIMEOUT, SleepTime.THIRTY_SECONDS);

  @Builder
  itemDividerBuilder(): void {
    Divider()
      .height(px2vp(2))
      .strokeWidth(0.5)
      .color($r('sys.color.comp_divider'))
      .lineCap(LineCapStyle.Square)
      .padding({ left: $r('sys.float.padding_level6'), right: $r('sys.float.padding_level6') })
  }

  @Builder
  dialogContentBuilder() {
    Column() {
      RadioComponent({
        compId: SleepKey.FIFTEEN_SECONDS_KEY,
        itemModel: this.itemModel,
        controller: new DormancyRadioController(SleepKey.FIFTEEN_SECONDS_KEY, SleepTime.FIFTEEN_SECONDS,
          this.dormancyTime === SleepTime.FIFTEEN_SECONDS)
      })

      this.itemDividerBuilder()

      RadioComponent({
        compId: SleepKey.THIRTY_SECONDS_KEY,
        itemModel: this.itemModel,
        controller: new DormancyRadioController(SleepKey.THIRTY_SECONDS_KEY, SleepTime.THIRTY_SECONDS,
          this.dormancyTime === SleepTime.THIRTY_SECONDS)
      })

      this.itemDividerBuilder()

      RadioComponent({
        compId: SleepKey.ONE_MINUTE_KEY,
        itemModel: this.itemModel,
        controller: new DormancyRadioController(SleepKey.ONE_MINUTE_KEY, SleepTime.ONE_MINUTE,
          this.dormancyTime === SleepTime.ONE_MINUTE)
      })

      this.itemDividerBuilder()

      RadioComponent({
        compId: SleepKey.TWO_MINUTES_KEY,
        itemModel: this.itemModel,
        controller: new DormancyRadioController(SleepKey.TWO_MINUTES_KEY, SleepTime.TWO_MINUTES,
          this.dormancyTime === SleepTime.TWO_MINUTES)
      })

      this.itemDividerBuilder()

      RadioComponent({
        compId: SleepKey.FIVE_MINUTES_KEY,
        itemModel: this.itemModel,
        controller: new DormancyRadioController(SleepKey.FIVE_MINUTES_KEY, SleepTime.FIVE_MINUTES,
          this.dormancyTime === SleepTime.FIVE_MINUTES)
      })

      this.itemDividerBuilder()

      RadioComponent({
        compId: SleepKey.TEN_MINUTES_KEY,
        itemModel: this.itemModel,
        controller: new DormancyRadioController(SleepKey.TEN_MINUTES_KEY, SleepTime.TEN_MINUTES,
          this.dormancyTime === SleepTime.TEN_MINUTES)
      })
    }
    .id('DormancyDialogComponent')
    .width('100%')
    .alignItems(HorizontalAlign.Center)
  }

  build() {
    Scroll() {
      this.dialogContentBuilder();
    }
    .align(Alignment.TopStart)
    .edgeEffect(EdgeEffect.Spring)
    .constraintSize({ maxHeight: '60%' })
  }
}
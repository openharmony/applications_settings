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

import i18n from '@ohos.i18n';
import { promptAction } from '@kit.ArkUI';
import { SettingItemModel } from '@ohos/settings.common/src/main/ets/framework/model/SettingItemModel';
import { LogUtil } from '@ohos/settings.common/src/main/ets/utils/LogUtil';
import { ResourceUtil } from '@ohos/settings.common/src/main/ets/utils/ResourceUtil';
import { EventBus } from '@ohos/settings.common/src/main/ets/framework/common/EventBus';
import { CheckEmptyUtils } from '@ohos/settings.common/src/main/ets/utils/CheckEmptyUtils';
import { FontScaleUtils } from '@ohos/settings.common/src/main/ets/utils/FontScaleUtils';
import { TimeUtil } from '@ohos/settings.display/src/main/ets/utils/TimeUtil';
import { TimePickerModel } from '../model/TimePickerModel';
import { MIN_60, SHOW_TOAST_TIME } from '../constants/ScheduledPowerOnOffConstant';
import { ScheduledPowerOnOffDataUtil } from '../utils/ScheduledPowerOnOffDataUtil';
/* instrument ignore file */
const TAG: string = 'TimePickerDialog: ';

export const POWER_ON: string = 'powerOn';

export const POWER_OFF: string = 'powerOff';

export const TIME_PICKER_DIALOG_EVENT: string = 'timePickerDialogEvent';

export const SUBMIT_ACTION: string = 'submit';

export const CANCEL_ACTION: string = 'cancel';

const POWER_TIMED_WARN_INTERVAL = '5';

const MIN_MINUTES = 5;

@Component
export struct TimePickerDialog {
  controller?: CustomDialogController;
  private data: Date = new Date();
  private titleText?: string;
  private param: SettingItemModel | undefined = undefined;
  private compId: string = '';
  private dateTime: string = '';
  private powerOnTimeKey?: string = '';
  private powerOffTimeKey?: string = '';
  private isExtraLargeFontMode = false;

  private initParam(): void {
    if (!this.param) {
      LogUtil.showInfo(TAG, `initParam param is null`);
      return;
    }
    LogUtil.showInfo(TAG, `initParam param ${this.param.id}`);
    this.compId = this.param.id;
    this.titleText = this.compId === POWER_ON ? ResourceUtil.getStringSync($r('app.string.power_on_time_title')) :
    ResourceUtil.getStringSync($r('app.string.power_off_time_title'));
    if (!CheckEmptyUtils.isEmpty(this.param.extra)) {
      this.dateTime = (this.param.extra as TimePickerModel).dateTime;
      this.powerOnTimeKey = (this.param.extra as TimePickerModel).powerOnTimeKey;
      this.powerOffTimeKey = (this.param.extra as TimePickerModel).powerOffTimeKey;
      LogUtil.showInfo(TAG, `extra info ${this.dateTime}, ${this.powerOnTimeKey}, ${this.powerOffTimeKey}`);
    }
    this.isExtraLargeFontMode = FontScaleUtils.isExtraLargeFontMode();
  }

  private initSelectDate(): void {
    let selectDate = new Date();
    if (CheckEmptyUtils.checkStrIsEmpty(this.dateTime)) {
      LogUtil.showInfo(TAG, `initSelectDate dateTime is empty`);
      this.data = selectDate;
      return;
    }
    if (POWER_OFF === this.compId) {
      LogUtil.showInfo(TAG, `init powerOff date ${this.dateTime}`);
      if (Number.parseInt(this.dateTime) > TimeUtil.getNextDayTime()) {
        selectDate.setHours(Math.floor((Number.parseInt(this.dateTime) - TimeUtil.getNextDayTime()) / MIN_60));
      } else {
        selectDate.setHours(Math.floor(Number.parseInt(this.dateTime) / MIN_60));
      }
      selectDate.setMinutes(Number.parseInt(this.dateTime) % MIN_60);
      this.data = selectDate;
      return;
    }
    LogUtil.showInfo(TAG, `init powerOn date ${this.dateTime}`);
    selectDate.setHours(Math.floor(Number.parseInt(this.dateTime) / MIN_60));
    selectDate.setMinutes(Number.parseInt(this.dateTime) % MIN_60);
    this.data = selectDate;
  }

  private verifySelectDate(): boolean {
    if (CheckEmptyUtils.isEmpty(this.powerOnTimeKey) || CheckEmptyUtils.isEmpty(this.powerOffTimeKey)) {
      LogUtil.showWarn(TAG, `no need verify select date`);
      return true;
    }
    let isEnd: boolean = POWER_OFF === this.compId;
    let otherDataTime: number = Number(isEnd ? ScheduledPowerOnOffDataUtil.getPowerOnTime(TAG)
      : ScheduledPowerOnOffDataUtil.getPowerOffTime(TAG));
    if (otherDataTime === -1) {
      return true;
    }
    LogUtil.showInfo(TAG, `verifySelectDate ${otherDataTime}`);
    return (Math.abs(this.data.getHours() * MIN_60 + this.data.getMinutes() - otherDataTime) >= MIN_MINUTES);
  }

  aboutToAppear(): void {
    this.initParam();
    this.initSelectDate();
  }

  build() {
    Column() {
      Row() {
        Text(this.titleText)
          .fontWeight(FontWeight.Bold)
          .fontSize($r('sys.float.Title_S'))
          .fontColor($r('sys.color.ohos_id_color_text_primary'))
          .maxFontScale(2)
          .maxLines(2)
      }
      .width('100%')
      .padding({
        top: this.isExtraLargeFontMode ? $r('app.float.padding_12') : 0,
        left: $r('app.float.padding_24'),
        right: $r('app.float.padding_24'),
      })
      .constraintSize({ minHeight: $r('app.float.height_56') })
      .justifyContent(FlexAlign.Center);

      TimePicker({ selected: this.data })
        .useMilitaryTime(i18n.System.is24HourClock())
        .backgroundColor(Color.Transparent)
        .width('100%')
        .margin({
          bottom: $r('app.float.margin_8'),
        })
        .padding({
          left: $r('app.float.padding_24'),
          right: $r('app.float.padding_24')
        })
        .onChange((value: TimePickerResult) => {
          this.data?.setHours(value.hour, value.minute);
        });

      Row() {
        Flex({
          direction: this.isExtraLargeFontMode ? FlexDirection.Column : FlexDirection.Row,
          justifyContent: FlexAlign.SpaceBetween,
          alignItems: ItemAlign.Center
        }) {
          Button() {
            Text($r('app.string.dialog_cancel'))
              .fontWeight(FontWeight.Medium)
              .maxFontScale(2)
              .fontSize($r('sys.float.ohos_id_text_size_button1'))
              .fontColor($r('sys.color.ohos_id_color_text_primary_activated'))
          }
          .constraintSize({ minHeight: $r('app.float.height_40') })
          .backgroundColor(Color.Transparent)
          .layoutWeight(this.isExtraLargeFontMode ? 0 : 1)
          .width('100%')
          .accessibilityText($r('app.string.dialog_cancel'))
          .onClick(() => {
            EventBus.getInstance().emit(TIME_PICKER_DIALOG_EVENT, this.compId, CANCEL_ACTION);
          });

          if (!this.isExtraLargeFontMode) {
            Divider()
              .vertical(true)
              .strokeWidth(px2vp(2))
              .align(Alignment.Center)
              .margin({
                left: $r('sys.float.ohos_id_elements_margin_horizontal_m'),
                right: $r('sys.float.ohos_id_elements_margin_horizontal_m')
              })
              .height($r('app.float.height_24'));
          }

          Button() {
            Text($r('app.string.dialog_sure'))
              .fontWeight(FontWeight.Medium)
              .maxFontScale(2)
              .fontSize($r('sys.float.ohos_id_text_size_button1'))
              .fontColor($r('sys.color.ohos_id_color_text_primary_activated'))
          }
          .margin({
            top: this.isExtraLargeFontMode ? $r('app.float.margin_4') : 0
          })
          .constraintSize({ minHeight: $r('app.float.height_40') })
          .backgroundColor(Color.Transparent)
          .layoutWeight(this.isExtraLargeFontMode ? 0 : 1)
          .width('100%')
          .accessibilityText($r('app.string.dialog_sure'))
          .onClick(() => {
            let calcTime: string = (this.data.getHours() * MIN_60 + this.data.getMinutes()).toString();
            if (this.dateTime === calcTime) {
              LogUtil.showInfo(TAG, `select date no change, no need change`);
              EventBus.getInstance().emit(TIME_PICKER_DIALOG_EVENT, this.compId, CANCEL_ACTION);
              return;
            }
            if (this.verifySelectDate()) {
              EventBus.getInstance().emit(TIME_PICKER_DIALOG_EVENT, this.compId, SUBMIT_ACTION, this.data);
            } else {
              promptAction.showToast({
                message: ResourceUtil.getNumberFormatStringSync($r('app.string.power_timed_warn'),
                  POWER_TIMED_WARN_INTERVAL),
                duration: SHOW_TOAST_TIME
              });
              EventBus.getInstance().emit(TIME_PICKER_DIALOG_EVENT, this.compId, CANCEL_ACTION);
            }
          });
        }
        .width('100%')
      }
      .padding({
        left: $r('app.float.padding_16'),
        right: $r('app.float.padding_16'),
        bottom: (this.isExtraLargeFontMode ? $r('app.float.padding_8') : $r('app.float.padding_16'))
      })
      .width('100%');
    }
    .width('100%');
  }
}
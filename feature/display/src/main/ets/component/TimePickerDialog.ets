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
import i18n from '@ohos.i18n';
import Settings from '@ohos.settings';
import emitter from '@ohos.events.emitter';
import { promptAction } from '@kit.ArkUI';
import { SettingItemModel } from '@ohos/settings.common/src/main/ets/framework/model/SettingItemModel';
import { LogUtil } from '@ohos/settings.common/src/main/ets/utils/LogUtil';
import { ResourceUtil } from '@ohos/settings.common/src/main/ets/utils/ResourceUtil';
import { CheckEmptyUtils } from '@ohos/settings.common/src/main/ets/utils/CheckEmptyUtils';
import {
  MIN_60,
  SHOW_TOAST_TIME
} from '../constant/DisplayConstant';
import { TimeUtil } from '../utils/TimeUtil';
import { TimePickerModel } from '../model/TimePickerModel';
import { EventBus } from '@ohos/settings.common/src/main/ets/framework/common/EventBus';

const TAG: string = 'TimePickerDialog: ';
export const START: string = 'start';
export const END: string = 'end';
export const TIME_PICKER_DIALOG_EVENT: string = 'timePickerDialogEvent';
export const SUBMIT_ACTION: string = 'submit';
export const CANCEL_ACTION: string = 'cancel';
export const TIME_PICKER_SELECT_CHANGE: string = 'timePickerSelectChange';
@Component
export struct TimePickerDialog {
  controller?: CustomDialogController;
  private data: Date = new Date();
  private titleText?: string;
  private param: SettingItemModel | undefined = undefined;
  private compId: string = '';
  public static dateTime: string = '';
  public static startTimeKey?: string = '';
  public static endTimeKey?: string = '';

  private initParam(): void {
    if (!this.param) {
      LogUtil.info(`${TAG} initParam param is null`);
      return;
    }
    LogUtil.info(`${TAG} initParam param ${this.param.id}`);
    this.compId = this.param.id;
    this.titleText = this.compId === START ? ResourceUtil.getStringSync($r('app.string.start_time')) :
      ResourceUtil.getStringSync($r('app.string.end_time'));
    if (!CheckEmptyUtils.isEmpty(this.param.extra)) {
      TimePickerDialog.dateTime = (this.param.extra as TimePickerModel).dateTime;
      TimePickerDialog.startTimeKey = (this.param.extra as TimePickerModel).startTimeKey;
      TimePickerDialog.endTimeKey = (this.param.extra as TimePickerModel).endTimeKey;
      LogUtil.info(`${TAG} extra info ${TimePickerDialog.dateTime}, ${TimePickerDialog.startTimeKey},
        ${TimePickerDialog.endTimeKey}`);
    }
  }

  private initSelectDate(): void {
    let selectDate = new Date();
    if (CheckEmptyUtils.checkStrIsEmpty(TimePickerDialog.dateTime)) {
      LogUtil.info(`${TAG} initSelectDate dateTime is empty`);
      this.data = selectDate;
      EventBus.getInstance().emit(TIME_PICKER_SELECT_CHANGE, this.data);
      return;
    }
    let hours: number = 0;
    let minutes: number = 0;
    let dialogTime: number = Number.parseInt(TimePickerDialog.dateTime);
    if (this.compId === END) {
      LogUtil.info(`${TAG} init end date ${dialogTime}`);
      let nextDayTime: number = TimeUtil.getNextDayTime();
      hours = Math.floor(dialogTime > nextDayTime ? ((dialogTime - nextDayTime) / MIN_60) : dialogTime / MIN_60);
    } else {
      LogUtil.info(`${TAG} init start date ${dialogTime}`);
      hours = Math.floor(dialogTime / MIN_60);
    }
    minutes = dialogTime % MIN_60;
    selectDate.setHours(hours);
    selectDate.setMinutes(minutes);
    this.data = selectDate;
    EventBus.getInstance().emit(TIME_PICKER_SELECT_CHANGE, this.data);
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
          .maxFontScale(2)
          .fontColor($r('sys.color.font_primary'));
      }
      .alignItems(VerticalAlign.Center)
      .constraintSize({ maxWidth: '100%' })
      .height('56vp')
      .align(Alignment.Start)

      TimePicker({ selected: this.data })
        .useMilitaryTime(i18n.System.is24HourClock())
        .onChange((value: TimePickerResult) => {
          this.data?.setHours(value.hour, value.minute);
          EventBus.getInstance().emit(TIME_PICKER_SELECT_CHANGE, this.data);
        });
    }
    .margin({ top: 0 })
    .width('100%');
  }
}
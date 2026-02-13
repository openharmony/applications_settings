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
import I18n from '@ohos.i18n';
import { ItemResultType, SettingItemModel } from '@ohos/settings.common/src/main/ets/framework/model/SettingItemModel';
import {
  notifyCompStateChange,
  SettingResultState,
  SettingStateType
} from '@ohos/settings.common/src/main/ets/framework/model/SettingStateModel';
import { LogUtil } from '@ohos/settings.common/src/main/ets/utils/LogUtil';
import { TimeUtil } from '@ohos/settings.common/src/main/ets/utils/TimeUtil';
import { TimePickerController } from '../controller/TimePickerController';

@CustomDialog
export struct TimerPickerComponent {
  private selectTime: Date = new Date();
  tag: string = 'TimerPickerComponent: ';
  item?: SettingItemModel;
  compControl?: TimePickerController;
  controllerTimer?: CustomDialogController

  build() {
    Column() {
      Row() {
        Text(this.compControl?.getTitle())
          .textAlign(TextAlign.Center)
          .fontWeight(FontWeight.Bold)
          .fontSize($r('sys.float.Title_S'))
          .maxFontScale(2)
          .fontColor($r('sys.color.font_primary'));
      }
      .alignItems(VerticalAlign.Center)
      .constraintSize({ maxWidth: '100%' })
      .height($r('app.float.height_56'))
      .align(Alignment.Start)

      TimePicker({
        selected: this.compControl?.getCurrentTime()
      })
        .useMilitaryTime(I18n.System.is24HourClock())
        .onChange((value: TimePickerResult) => {
          this.onChange(value);
        })
    }
    .margin({ top: $r('app.float.margin_0'), })
    .width('100%')
  }

  aboutToAppear(): void {
    LogUtil.info(`${this.tag} aboutToAppear`);
    if (this.item?.compControl instanceof TimePickerController) {
      LogUtil.info(`${this.tag} instanceof ZenTimerPickerController`);
      this.compControl = this.item?.compControl as TimePickerController;
    }
  }

  private onChange(value: TimePickerResult): void {
    if (value.hour < 0) {
      return;
    }
    this.selectTime.setHours(value.hour, value.minute)

    // 用来更新界面数据
    let time = TimeUtil.getTimeStr(TimeUtil.getTimeStrByDate(this.selectTime));

    // 24小时HH:mm这种形式的，用来更新timer的保存值
    this.compControl?.updateTime(TimeUtil.getTimeStrByDate(this.selectTime));

    if (this.compControl?.getMorning()) {
      notifyCompStateChange('Setting.zenTimerEdit.time_group.time_start',
        new Map<SettingStateType, SettingResultState>([[SettingStateType.STATE_TYPE_ITEM_RESULT,
          {
            type: ItemResultType.RESULT_TYPE_TEXT,
            result: {
              content: time
            }
          } as SettingResultState]]));

      // 结束时间要随着开始时间变化，判断是否要加次日
      notifyCompStateChange('Setting.zenTimerEdit.time_group.time_end',
        new Map<SettingStateType, SettingResultState>([[SettingStateType.STATE_TYPE_ITEM_RESULT,
          {
            type: ItemResultType.RESULT_TYPE_TEXT,
            result: {
              content: this.compControl?.getEndTime()
            }
          } as SettingResultState]]));
    } else {
      notifyCompStateChange('Setting.zenTimerEdit.time_group.time_end',
        new Map<SettingStateType, SettingResultState>([[SettingStateType.STATE_TYPE_ITEM_RESULT,
          {
            type: ItemResultType.RESULT_TYPE_TEXT,
            result: {
              content: this.compControl?.getEndTime()
            }
          } as SettingResultState]]));
    }
  }
}



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
import Settings from '@ohos.settings';
import { AccessibilityUtils } from '@ohos/settings.common/src/main/ets/utils/AccessibilityUtils';
import { CheckEmptyUtils } from '@ohos/settings.common/src/main/ets/utils/CheckEmptyUtils';
import { SettingItemModel } from '@ohos/settings.common/src/main/ets/framework/model/SettingItemModel';
import {
  NotDisturbTimeUtil,
  WeekListField,
  WeekDayFormat
} from '@ohos/settings.notDisturb/src/main/ets/utils/NotDisturbTimeUtil';
import { SettingsDataUtils } from '@ohos/settings.common/src/main/ets/utils/SettingsDataUtils';
import { LogUtil } from '@ohos/settings.common/src/main/ets/utils/LogUtil';
import { EventBus } from '@ohos/settings.common/src/main/ets/framework/common/EventBus';
import { HiSysSystemEventGroup } from '@ohos/settings.common/src/main/ets/systemEvent/BehaviorEventConsts';
import { HiSysEventUtil } from '@ohos/settings.common/src/main/ets/systemEvent/HiSysEventUtil';
import {
  DEFAULT_SCHEDULED_POWER_ON_OFF_REPEAT,
  SCHEDULED_POWER_ON_OFF_REPEAT,
  SCHEDULED_POWER_ON_OFF_REPEAT_WEEK,
  SCHEDULED_POWER_ON_OFF_WEEK_REPEAT,
  SCHEDULED_POWER_TIME_NOT_SET
} from '../constants/ScheduledPowerOnOffConstant';
import { ScheduledPowerOnOffDataUtil } from '../utils/ScheduledPowerOnOffDataUtil';
/* instrument ignore file */
export const WEEK_LIST_COMPONENT_EVENT: string = 'weekListComponentEvent';

const TAG: string = 'WeekListComponent: ';
const WEEK_REPEAT: string = '2';

@Component
export struct WeekListComponent {
  item?: SettingItemModel;
  selectIndex: number = 0;
  @State weekListMap: string = '{}';
  private daysOfWeekLabels: string[] = [];
  private firstAppear: boolean = true;

  @Builder
  buildAlarmButton(item: WeekListField, index: number) {
    Button({ type: ButtonType.Circle, stateEffect: true }) {
      Text(i18n.getSystemLanguage().startsWith('zh') ? item.label.split('')[1] : item.label)
        .textAlign(TextAlign.Center)
        .fontSize('13vp')
        .fontWeight(item.selected ? FontWeight.Medium : FontWeight.Regular)
        .fontColor(item.selected ? $r('sys.color.font_on_primary') : $r('sys.color.font_secondary'))
        .focusable(true)
        .padding({
          top: 4,
          bottom: 4
        })
    }
    .onAppear(()=>{
      if (!this.firstAppear) {
        AccessibilityUtils.requestFocusAccessibility(item.label);
      }
    })
    .id(item.label)
    .backgroundColor(item.selected ? $r('sys.color.font_emphasize') : $r('sys.color.comp_background_tertiary'))
    .constraintSize({
      minWidth: '40vp',
      minHeight: '40vp',
    })
    .margin({
      top: $r('app.float.distance_2'),
      bottom: $r('app.float.distance_2')
    })
    .controlSize(ControlSize.SMALL)
    .onClick(() => {
      this.firstAppear = false;
      let _weekList: WeekListField[] = JSON.parse(this.weekListMap);
      _weekList[index].selected = !item.selected
      this.weekListMap = JSON.stringify(_weekList);
      let daysNumArr: number[] = [];
      _weekList.map((item: WeekListField, index: number) => {
        if (item.selected) {
          // 周天是1，周一是2，数组是从0开始的，所以这里要+1
          daysNumArr.push(item.value + 1)
        }
      })
      SettingsDataUtils
        .setSettingsData(SCHEDULED_POWER_ON_OFF_REPEAT_WEEK,
          (daysNumArr.toString() === '') ? SCHEDULED_POWER_TIME_NOT_SET : daysNumArr.toString(),
          Settings.domainName.DEVICE_SHARED);
      LogUtil.showInfo(TAG, `week repeat:${daysNumArr.toString()}`);
      EventBus.getInstance().emit(WEEK_LIST_COMPONENT_EVENT);
      let params: Record<string, Object> = {};
      params.REPEAT = WEEK_REPEAT;
      params.WEEK = daysNumArr.toString();
      HiSysEventUtil.reportBehaviorEventByUE(HiSysSystemEventGroup.SCHEDULED_REPEAT_SELECT, params);
    })
    .accessibilityText(`${i18n.getSystemLanguage().startsWith('zh') ? item.label.split('')[1] :
    item.label} ${getContext(this).resourceManager.getStringSync(item.selected ?
    $r('app.string.has_selected') : $r('app.string.not_selected'))}`)
  }

  aboutToAppear(): void {
    this.daysOfWeekLabels = NotDisturbTimeUtil.getDaysOfWeekLabels(WeekDayFormat.Short);
    let weekListArr: WeekListField[] = [];
    this.selectIndex = Number(SettingsDataUtils
      .getSettingsData(SCHEDULED_POWER_ON_OFF_REPEAT, DEFAULT_SCHEDULED_POWER_ON_OFF_REPEAT,
        Settings.domainName.DEVICE_SHARED));

    if (this.selectIndex == Number(SCHEDULED_POWER_ON_OFF_WEEK_REPEAT)) {
      let text = ScheduledPowerOnOffDataUtil.getRepeatWeekChose(TAG);
      // 重复天数可以不选 dataArray可以是一个空数组
      let dataArray: string[] = [];
      if (!CheckEmptyUtils.checkStrIsEmpty(text)) {
        dataArray = text.split(',');
      }
      // 周天是1，周一是2，映射是从0 开始的所以要-1
      this.daysOfWeekLabels.map((label: string, index: number) => {
        weekListArr.push({
          label: label,
          value: index,
          selected: dataArray.some(day => Number(day) - 1 === index),
        })
      })
    } else {
      this.daysOfWeekLabels.map((label: string, index: number) => {
        weekListArr.push({
          label: label,
          value: index,
          selected: false
        })
      })
    }
    this.weekListMap = JSON.stringify(weekListArr);
  }

  build() {
    Column() {
      Row({}) {
        Flex({ justifyContent: FlexAlign.SpaceBetween, alignItems: ItemAlign.Center, wrap: FlexWrap.Wrap }) {
          ForEach(JSON.parse(this.weekListMap), (item: WeekListField, index: number) => {
            this.buildAlarmButton(item, index);
          })
        }
      }
      .width('100%')
      .constraintSize({
        minHeight: 60
      })
      .justifyContent(FlexAlign.Center)
    }
    .padding($r('sys.float.padding_level4'))
  }
}

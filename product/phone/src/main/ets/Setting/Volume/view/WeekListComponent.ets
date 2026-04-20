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
import { AccessibilityUtils } from '@ohos/settings.common/src/main/ets/utils/AccessibilityUtils';
import { CheckEmptyUtils } from '@ohos/settings.common/src/main/ets/utils/CheckEmptyUtils';
import { ItemResultType, SettingItemModel } from '@ohos/settings.common/src/main/ets/framework/model/SettingItemModel';
import {
  notifyCompStateChange,
  SettingResultState,
  SettingStateType
} from '@ohos/settings.common/src/main/ets/framework/model/SettingStateModel';
import { NotDisturbTimeUtil, WeekListField } from '@ohos/settings.notDisturb/src/main/ets/utils/NotDisturbTimeUtil';
import { NotDisturbUtils } from '@ohos/settings.notDisturb/src/main/ets/utils/NotDisturbUtils';
import { WeekListController } from '../controller/WeekListController';

@Component
export struct WeekListComponent {
  item?: SettingItemModel;
  compControl?: WeekListController;
  selectIndex: number = 0;
  @State @Watch('updateWeekMapList') weekListMap: string = '{}';

  private updateWeekMapList() {
  }

  private daysOfWeekLabels: string[] = [];

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
      this.compControl?.updateRepeatText(daysNumArr.toString());
      this.compControl?.getRepeatType()

      let showSummary = NotDisturbUtils.getZenModeScheduleRepeatText(daysNumArr.toString());
      notifyCompStateChange('Setting.zenTimerEdit.repeat_group.time_repeat',
        new Map<SettingStateType, SettingResultState>([[SettingStateType.STATE_TYPE_ITEM_RESULT,
          {
            type: ItemResultType.RESULT_TYPE_TEXT,
            result: {
              content: showSummary
            }
          } as SettingResultState]]));
      AccessibilityUtils.requestFocusAccessibility(item.label);
    })
    .accessibilityText(`${i18n.getSystemLanguage().startsWith('zh') ? item.label.split('')[1] :
    item.label} ${getContext(this).resourceManager.getStringSync(item.selected ?
    $r('app.string.has_selected') : $r('app.string.not_selected'))}`)
  }

  aboutToAppear(): void {
    if (this.item?.compControl instanceof WeekListController) {
      this.compControl = this.item?.compControl as WeekListController;
    }
    this.daysOfWeekLabels = NotDisturbTimeUtil.getDaysOfWeekLabels();
    let weekListArr: WeekListField[] = [];
    this.selectIndex = this.compControl === undefined ? 0 : this.compControl.getRepeatType();

    if (this.selectIndex == 1) {
      let text = String(this.compControl?.getRepeatText());
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

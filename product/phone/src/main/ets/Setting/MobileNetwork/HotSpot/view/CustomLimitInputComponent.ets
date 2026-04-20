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

import { LogUtil } from '@ohos/settings.common/src/main/ets/utils/LogUtil';
import { ResourceUtil } from '@ohos/settings.common/src/main/ets/utils/ResourceUtil';
import { PADDING_1_PX } from '@ohos/settings.common/src/main/ets/constant/StyleConstant';
import { EventBus } from '@ohos/settings.common/src/main/ets/framework/common/EventBus';
import { SettingItemModel } from '@ohos/settings.common/src/main/ets/framework/model/SettingItemModel';
import {SettingStateType, SettingBaseState, SettingCompState } from '@ohos/settings.common/src/main/ets/framework/model/SettingStateModel';
import { InputComponent } from '@ohos/settings.commonUikit/src/main/ets/component/InputComponent';
import { HotspotLimitStyle } from '@ohos/settings.commonUikit/src/main/ets/InputStyle';
import { GB_STR, HOTSPOT_CONFIG_CHANGE_EVENT, MB_STR } from '../utils/HotspotUtils';
import { HotspotLimitDataManager, USER_DATA_NO_LIMIT } from '../HotspotLimitDataManager';

const TAG: string = 'CustomLimitInputComponent';
const SELECT_ITEMS: string[] = [MB_STR, GB_STR];
export const LIMIT_INPUT_COMP_ID: string = 'Setting.hotspot_limit.limit_selection.input';
export const INPUT_CHANGE_EVENT: string = 'input_change';
export const UNIT_CHANGE_EVENT: string = 'unit_change';
export const INPUT_IS_CUSTOM: string = 'input_custom';

@Builder
export function inputBuilder(param: object): void {
  CustomLimitInputComponent({
    itemInfo: param as SettingItemModel
  })
}

@Component
export struct CustomLimitInputComponent{
  itemInfo?: SettingItemModel;
  onInputChange?: (input: string) => void;
  @State unit: string = MB_STR;
  @State isVisible: boolean = false;
  private content: ResourceStr = '';
  private eventCb = (data: object) => {
    if (!(data instanceof  Map)) {
      LogUtil.error(`${TAG} invalid event data`);
      return;
    }
    (data as Map<SettingStateType, SettingBaseState>).forEach((value: SettingBaseState, key: SettingStateType) => {
      if (key === SettingStateType.STATE_TYPE_ITEM_VISIBLE) {
        this.procItemVisible(value as SettingCompState);
      }
    });
  };

  aboutToAppear(): void {
    LogUtil.info(`${TAG} aboutToAppear compId: ${this.itemInfo?.id}`);
    EventBus.getInstance().on(LIMIT_INPUT_COMP_ID, this.eventCb);
    this.isVisible = this.itemInfo?.visible ?? false;
    let curLimit: number = HotspotLimitDataManager.getInstance().curLimit;
    this.content = curLimit === USER_DATA_NO_LIMIT ? '' : curLimit.toString();
    this.unit = curLimit === USER_DATA_NO_LIMIT ? MB_STR : HotspotLimitDataManager.getInstance().curUnit;
    EventBus.getInstance().emit(INPUT_CHANGE_EVENT, this.content);
    EventBus.getInstance().emit(HOTSPOT_CONFIG_CHANGE_EVENT);
  }

  private inputChange(input: string) {
    LogUtil.info(`${TAG} inputChange: ${input}`);
    EventBus.getInstance().emit(INPUT_CHANGE_EVENT, input);
    EventBus.getInstance().emit(HOTSPOT_CONFIG_CHANGE_EVENT);
    HotspotLimitDataManager.getInstance().updateLimitNumber(parseInt(input));
  }

  private procItemVisible(state: SettingCompState): void {
    LogUtil.info(`${TAG} InputChange: ${state.state}`);
    if (state.state === undefined || state.state === this.isVisible) {
      LogUtil.info(`${TAG} the state is not empty or no up date required`);
      return;
    }
    this.isVisible = state.state;
  }

  @Builder
  menuBuilder(): void {
    Menu() {
      ForEach(SELECT_ITEMS, (item: string, index:number) => {
        MenuItem({ content: item })
          .id(`menuItem${index}`)
          .selected(item === this.unit)
          .contentFont({
            size: $r('sys.float.Body_L'),
            weight: FontWeight.Medium,
          })
          .contentFontColor($r('sys.color.font_primary'))
          .onClick(() => {
            EventBus.getInstance().emit(UNIT_CHANGE_EVENT, item);
            HotspotLimitDataManager.getInstance().updateLimitUnit(item);
            this.unit = item;
          })
      })
    }
    .menuItemDivider({
      strokeWidth: PADDING_1_PX,
      color: $r('sys.color.ohos_id_color_list_separator')
    })
    .radius($r('sys.float.corner_radius_level4'))
    .width($r('app.float.length_24'))
  }
  build() {
    Column() {
      Divider()
        .height(px2vp(2))
        .strokeWidth(ResourceUtil.getStringSync($r('app.float.divider_stroke_width')))
        .color($r('sys.color.ohos_id_color_list_separator'))
        .lineCap(LineCapStyle.Square)
        .padding({ left: $r('sys.float.padding_level4'), right: $r('sys.float.padding_level4') })
      Row() {
        InputComponent({
          hint: '',
          content: this.content,
          onChange: (input: string) => {
            this.inputChange(input);
          },
          style: new HotspotLimitStyle(),
        })
          .layoutWeight(1)

        Row() {
          Text(this.unit)
            .fontFamily('HarmonyHeiTi')
            .fontWeight(FontWeight.Regular)
            .fontSize($r('sys.float.Body_M'))
            .fontColor($r('sys.color.icon_primary'))
        }
        .bindMenu(this.menuBuilder())
        .constraintSize({
          minWidth: $r('app.float.value_48'),
          maxWidth: $r('app.float.wh_value_96')
        })
      }
    }
    .visibility(this.isVisible ? Visibility.Visible : Visibility.None)
  }

}









































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
import { SettingsDataUtils } from '@ohos/settings.common/src/main/ets/utils/SettingsDataUtils';
import { EventBus } from '@ohos/settings.common/src/main/ets/framework/common/EventBus';
import { CompCtrlParam, ComponentControl } from '@ohos/settings.common/src/main/ets/framework/model/SettingBaseModel';
import { GroupType, SettingGroupModel } from '@ohos/settings.common/src/main/ets/framework/model/SettingGroupModel';
import { ItemResultType, ItemType, SettingItemModel } from '@ohos/settings.common/src/main/ets/framework/model/SettingItemModel';
import {
  notifyCompStateChange,
  SettingBaseState,
  SettingCompState,
  SettingResultState,
  SettingStateType
} from '@ohos/settings.common/src/main/ets/framework/model/SettingStateModel';
import { LogUtil } from '@ohos/settings.common/src/main/ets/utils/LogUtil';
import {
  HotSpotUtils,
  MAX_MB_NUM,
  MB_STR,
  USER_DATA_LIMIT_CONFIRM_EVENT,
  GB_STR,
  HOTSPOT_CONFIG_CHANGE_EVENT
} from '../utils/HotspotUtils';
import { inputBuilder,
  INPUT_CHANGE_EVENT,
  INPUT_IS_CUSTOM, LIMIT_INPUT_COMP_ID,
  UNIT_CHANGE_EVENT } from '../view/CustomLimitInputComponent';
import {
  HotspotLimitDataManager,
  LAST_INPUT_UNIT_KEY,
  limitList,
  USER_DATA_NO_LIMIT } from '../HotspotLimitDataManager';
import { buildConfirmButton } from '../view/HotspotLimitConfimComponent';

const LIMIT_STR: string = 'limit_';
const NO_LIMIT_STR: string = 'no_limit';
const GROUP_ID_STR: string = 'limit_selection';
const TAG: string = 'HotspotLimitSheetPageController';

export class HotspotLimitSheetPageController implements ComponentControl {
  private compId: string = ''
  private hotspotDataManager: HotspotLimitDataManager = HotspotLimitDataManager.getInstance();
  private isCustom: boolean = this.hotspotDataManager.isCustomized();
  private customLimit: number = 0;
  private customUnit: string = MB_STR;
  private readonly parentId: string = 'Setting.more_share_entry.ApBand.limit_once';

  private onConfirm = () => {
    this.hotspotDataManager.updateSettingData();
    SettingsDataUtils.setSecureValue(LAST_INPUT_UNIT_KEY, this.hotspotDataManager.curUnit);
    this.refreshUi(this.hotspotDataManager.getCurLimitString());
  }

  private onInputChange = (input: string) => {
    this.customLimit = parseInt(input);
  }

  private onUnitChange = (unit: string) => {
    this.customUnit = unit;
  }

  init(compParam: CompCtrlParam): void {
    if (!compParam) {
      LogUtil.warn(`${TAG} init error: no comParam`);
      return;
    }
    LogUtil.info(`${TAG} init compId: ${compParam.compId}`);
    this.compId = compParam.compId;
    EventBus.getInstance().on(USER_DATA_LIMIT_CONFIRM_EVENT, this.onConfirm);
    EventBus.getInstance().on(INPUT_CHANGE_EVENT, this.onInputChange);
    EventBus.getInstance().on(UNIT_CHANGE_EVENT, this.onUnitChange);
  }

  public getPreseatGroup(): SettingGroupModel[] {
    this.hotspotDataManager.initData();
    this.isCustom = this.hotspotDataManager.isCustomized();
    this.customLimit = this.hotspotDataManager.curLimit;
    this.customUnit = this.hotspotDataManager.curUnit;
    return [
      {
        id: GROUP_ID_STR,
        type: GroupType.GROUP_TYPE_STANDARD,
        items: [
          {
            id: NO_LIMIT_STR,
            type: ItemType.ITEM_TYPE_STANDARD,
            title: { content: $r('app.string.no_limit') },
            result: {
              type: ItemResultType.RESULT_TYPE_RADIO,
              result: {
                checked: this.hotspotDataManager.curLimit === USER_DATA_NO_LIMIT && !this.isCustom,
                style: { width: $r('app.float.length_22'), height: $r('app.float.length_22'), showUnchecked: false },
                onCheck: (isCheck: boolean, item: SettingItemModel) => {
                  LogUtil.info(`${TAG}, preseat onCheck: ${isCheck}`);
                  if (isCheck) {
                    this.onItemSelect(item);
                  }
                }
              }
            }
          },
          ...this.initLimitItems()
        ],
      },
      {
        id: GROUP_ID_STR,
        type: GroupType.GROUP_TYPE_STANDARD,
        items: [
          {
            id: 'title',
            type: ItemType.ITEM_TYPE_STANDARD,
            title: { content: $r('app.string.custom_limit') },
            result: {
              type: ItemResultType.RESULT_TYPE_RADIO,
              result: {
                checked: this.isCustom,
                style: { width: $r('app.float.length_22'), height: $r('app.float.length_22'), showUnchecked: false },
                onCheck: (isCheck: boolean, item: SettingItemModel) => {
                  LogUtil.info(`${TAG}, custom oncheck: ${isCheck}`);
                  EventBus.getInstance().emit(INPUT_IS_CUSTOM, isCheck);
                  EventBus.getInstance().emit(HOTSPOT_CONFIG_CHANGE_EVENT);
                  this.isCustom = isCheck;
                  this.showOrHideInput(isCheck);
                  if (isCheck) {
                    this.hotspotDataManager.updateCurrentLimit(this.customLimit, this.customUnit);
                  }
                }
              }
            },
            layout: { noNeedDivider: true }
          },
          {
            id: 'input',
            type: ItemType.ITEM_TYPE_CUSTOM,
            builder: wrapBuilder(inputBuilder),
            visible: this.isCustom,
          }
        ]
      }
    ]
  }

  private initLimitItems(): SettingItemModel[] {
    let result: SettingItemModel[] = [];
    limitList.forEach((value: number) => {
      result.push(this.createLimitItems(value));
    });
    return result;
  }

  private createLimitItems(limit: number): SettingItemModel {
    return {
      id: LIMIT_STR + limit.toString(),
      type: ItemType.ITEM_TYPE_STANDARD,
      title: {content: HotSpotUtils.getConvertedMb2Gb(limit.toString())},
      result: {
        type: ItemResultType.RESULT_TYPE_RADIO,
        result: {
          checked: this.isItemChecked(limit) && !this.isCustom,
          style: {width: $r('app.float.length_22'), height: $r('app.float.length_22'), showUnchecked: false},
          onCheck: (isCheck: boolean, item: SettingItemModel) => {
            LogUtil.info(`${TAG}, proseat oncheck: ${isCheck}`);
            if (isCheck) {
              this.onItemSelect(item);
            }
          }
        }
      }
    }
  }

  private isItemChecked(limit: number): boolean {
    let unit: string = MB_STR;
    if(limit >= MAX_MB_NUM) {
      limit = Math.floor(limit / MAX_MB_NUM);
      unit = GB_STR;
    }
    return this.hotspotDataManager.curLimit === limit && this.hotspotDataManager.curUnit === unit;
  }

  private  onItemSelect(item: SettingItemModel): void {
    if (!item) {
      return;
    }
    let limitNum: number = this.getLimitNumberFromItem(item);
    let unit: string = MB_STR;
    if (limitNum >= MAX_MB_NUM) {
      limitNum = Math.floor(limitNum / MAX_MB_NUM);
      unit = GB_STR;
    }
    this.hotspotDataManager.updateCurrentLimit(limitNum, unit);
    EventBus.getInstance().emit(INPUT_IS_CUSTOM, false);
    EventBus.getInstance().emit(HOTSPOT_CONFIG_CHANGE_EVENT);
    LogUtil.info(`${TAG}, select limit: ${limitNum} MB`);
  }

  private getLimitNumberFromItem(item: SettingItemModel): number {
    if (item.id === NO_LIMIT_STR) {
      return USER_DATA_NO_LIMIT;
    }
    let itemId: string = item.id;
    return parseInt(itemId.split('_')[1]);
  }

  private showOrHideInput(isShow: boolean): void {
    notifyCompStateChange(LIMIT_INPUT_COMP_ID, new Map<SettingStateType, SettingBaseState>(
      [[SettingStateType.STATE_TYPE_ITEM_VISIBLE, {
        state: isShow
      } as SettingCompState]]
    ));
  }

  private refreshUi(value: ResourceStr): void {
    notifyCompStateChange(this.parentId, new Map<SettingStateType, SettingBaseState>(
      [[SettingStateType.STATE_TYPE_ITEM_RESULT, {
        type: ItemResultType.RESULT_TYPE_TEXT,
        result: {content: value }
      } as SettingResultState]]
    ));
    notifyCompStateChange(this.parentId, new Map<SettingStateType, SettingBaseState>(
      [[SettingStateType.STATE_TYPE_ITEM_SHEET, {
        state: false
      } as SettingCompState]]
    ));
  }

  destroy(): void {
    LogUtil.info(`${TAG} destroy`);
    EventBus.getInstance().detach(USER_DATA_LIMIT_CONFIRM_EVENT, this.onConfirm);
    EventBus.getInstance().detach(INPUT_CHANGE_EVENT, this.onInputChange);
    EventBus.getInstance().detach(UNIT_CHANGE_EVENT, this.onUnitChange);
  }
}





















































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
import { LogUtil } from '@ohos/settings.common/src/main/ets/utils/LogUtil';
import { DynamicDataSource } from '@ohos/settings.common/src/main/ets/framework/model/DynamicDataSource';
import { CompCtrlParam, ComponentControl } from '@ohos/settings.common/src/main/ets/framework/model/SettingBaseModel';
import {
  ItemResultType,
  ItemType,
  SettingItemModel
} from '@ohos/settings.common/src/main/ets/framework/model/SettingItemModel';
import {
  SettingCompState,
  SettingStateType,
  SettingToggleState
} from '@ohos/settings.common/src/main/ets/framework/model/SettingStateModel';
import { EventBus } from '@ohos/settings.common/src/main/ets/framework/common/EventBus';
import { MouseSmartChangeController } from './MouseSmartChangeController';
import { Utils } from '../utils/Utils';
import { mouseColorBuilder, mouseSizeBuilder, mouseSpeedBuilder } from '../view/MouseSettingsComponentBuilder';
import { MouseSettingsManager } from '../MouseSettingsManager';

export class MouseOtherSettingsGroupController implements ComponentControl {
  private tag: string = 'MouseOtherSettingsGroupController: ';
  private compId?: string;
  private dataSource: DynamicDataSource = new DynamicDataSource();
  private smartChangeItem: SettingItemModel = this.createSmartChangeItem();
  private mouseColorItem: SettingItemModel = this.createMouseColorItem();
  private mouseSizeItem: SettingItemModel = this.createMouseSizeItem();
  private mouseSpeedItem: SettingItemModel = this.createMouseSpeedItem();
  private mouseSmartChangeEventCallback = (toggleState: SettingToggleState) => {
    if (!toggleState) {
      LogUtil.error(`${this.tag} toggleModel is invalid`);
      return;
    }
    if (!Utils.isEnableMagicCursor()) {
      return;
    }
    LogUtil.info(`${this.tag} mouseSmartChangeEventCallback ${toggleState.state}`);
    if (toggleState.state) {
      this.dataSource.removeData(this.mouseColorItem);
    } else {
      this.insertData(1, this.mouseColorItem);
    }
  };
  private mouseStyleChangeEventCallback = (isCircle: boolean) => {
    if (!Utils.isEnableMagicCursor()) {
      return;
    }
    LogUtil.info(`${this.tag} mouseStyleChangeEventCallback ${isCircle}`);
    if (isCircle) {
      this.insertData(0, this.smartChangeItem);
      if (Utils.getSmartChangeState()) {
        this.dataSource.removeData(this.mouseColorItem);
      }
    } else {
      this.dataSource.removeData(this.smartChangeItem);
      this.insertDataIfNotExit(0, this.mouseColorItem);
    }
  };

  private insertData(index: number, data: SettingItemModel): void {
    if (index > this.dataSource.length) {
      return;
    }
    if (index === this.dataSource.length && index > 0) {
      this.dataSource[index - 1]?.onItemEvent?.(new Map([[
        SettingStateType.STATE_TYPE_ITEM_POS, { state: false } as SettingCompState
      ]]));
    }
    if (index === 0) {
      this.dataSource[1]?.onItemEvent?.(new Map([[
        SettingStateType.STATE_TYPE_ITEM_IS_GROUP_START, { state: false } as SettingCompState
      ]]));
    }
    this.dataSource.splice(index, 0, data);
  }

  private insertDataIfNotExit(index: number, data: SettingItemModel): void {
    let oldIndex: number = this.dataSource.findIndex((value: SettingItemModel) => {
      return value.id === data.id;
    });
    if (oldIndex < 0) {
      this.insertData(index, data);
    }
  }

  init(compParam: CompCtrlParam): void {
    LogUtil.info(`${this.tag} init`);
    this.compId = compParam.compId;
    this.dataSource = compParam.dataSource as DynamicDataSource;
    MouseSettingsManager.getInstance().refreshPointerStyle();
    this.initItemModelList();
    EventBus.getInstance().on(`mouse_style_changed`, this.mouseStyleChangeEventCallback);
    EventBus.getInstance().on(`${this.compId}.MouseSmartChangeItem.toggle`, this.mouseSmartChangeEventCallback);
  }

  destroy(): void {
    EventBus.getInstance().detach(`mouse_style_changed`, this.mouseStyleChangeEventCallback);
    EventBus.getInstance().detach(`${this.compId}.MouseSmartChangeItem.toggle`, this.mouseSmartChangeEventCallback);
  }

  private initItemModelList(): void {
    if (Utils.isEnableMagicCursor()) {
      if (MouseSettingsManager.getInstance().isCircleStyle()) {
        this.dataSource.pushData(this.smartChangeItem);
      }
      if (!Utils.getSmartChangeState() || !MouseSettingsManager.getInstance().isCircleStyle()) {
        this.dataSource.pushData(this.mouseColorItem);
      }
      this.dataSource.pushData(this.mouseSizeItem);
    }
    this.dataSource.pushData(this.mouseSpeedItem);
  }

  private createSmartChangeItem(): SettingItemModel {
    return {
      id: 'MouseSmartChangeItem',
      type: ItemType.ITEM_TYPE_STANDARD,
      title: { content: $r('app.string.mouse_intelligent_change') },
      desc: { content: $r('app.string.mouse_intelligent_change_desc') },
      result: {
        type: ItemResultType.RESULT_TYPE_TOGGLE,
        result: { state: Utils.getSmartChangeState() }
      },
      compControl: new MouseSmartChangeController()
    }
  }

  private createMouseColorItem(): SettingItemModel {
    return {
      id: 'MousePointerColorItem',
      type: ItemType.ITEM_TYPE_CUSTOM,
      builder: wrapBuilder(mouseColorBuilder)
    }
  }

  private createMouseSizeItem(): SettingItemModel {
    return {
      id: 'MousePointerSizeItem',
      type: ItemType.ITEM_TYPE_CUSTOM,
      builder: wrapBuilder(mouseSizeBuilder)
    }
  }

  private createMouseSpeedItem(): SettingItemModel {
    return {
      id: 'MousePointerSpeedItem',
      type: ItemType.ITEM_TYPE_CUSTOM,
      builder: wrapBuilder(mouseSpeedBuilder)
    }
  }
}


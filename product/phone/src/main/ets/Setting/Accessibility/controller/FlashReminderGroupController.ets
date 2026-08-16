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
import { EventBus } from '@ohos/settings.common/src/main/ets/framework/common/EventBus';
import { CompCtrlParam, ComponentControl } from '@ohos/settings.common/src/main/ets/framework/model/SettingBaseModel';
import {
  notifyCompStateChange,
  SettingBaseState,
  SettingCompState,
  SettingStateType
} from '@ohos/settings.common/src/main/ets/framework/model/SettingStateModel';
import {
  ItemResultType,
  ItemType,
  SettingItemModel,
  SettingIconType
} from '@ohos/settings.common/src/main/ets/framework/model/SettingItemModel';
import { DynamicDataSource } from '@ohos/settings.common/src/main/ets/framework/model/DynamicDataSource';
import { ReminderFunctionSwitchController } from '../controller/FlashReminderPageController';
import { AccessibilityFlashReminderModel } from '../utils/AccessibilityCommonModel';
import { ACCESSIBILITY_FLASH_REMINDER_SWITCH_EVENT,
  DEFAULT_TEXT_STYLE,
  ReminderFunctionModeValue } from '../constant/Constants';

/* instrument ignore file */
export class AddReminderFunctionGroupController implements ComponentControl {
  private tag: string = 'AddReminderFunctionGroupController : ';
  private compId: string = '';
  private isShowGroup: boolean = false;
  private dataSource: DynamicDataSource = new DynamicDataSource();
  private onMainSwitchChangeCallback = (isVisible: boolean) => {
    LogUtil.info(`${this.tag} receive toggle state change: ${isVisible}`);
    // 闪烁提醒总开关状态发生变化后，显示或者隐藏添加其他提醒功能
    this.showOrHideHeader(isVisible);
    this.showOrHideGroup(isVisible);
    this.isShowGroup = isVisible;
  };

  constructor(isShowGroup: boolean) {
    this.isShowGroup = isShowGroup;
  }

  private showOrHideHeader(isShow: boolean): void {
    LogUtil.info(`${this.tag} showOrHideHeader: ${isShow}`);
    notifyCompStateChange(`${this.compId}.header`, new Map<SettingStateType, SettingBaseState>(
      [[SettingStateType.STATE_TYPE_GROUP_VISIBLE, { state: isShow } as SettingCompState]]
    ));
  }

  private showOrHideGroup(isShow: boolean): void {
    LogUtil.info(`${this.tag} showOrHideGroup: ${isShow}`);
    notifyCompStateChange(`${this.compId}`, new Map<SettingStateType, SettingBaseState>(
      [[SettingStateType.STATE_TYPE_GROUP_VISIBLE, { state: isShow } as SettingCompState]]
    ));
  }

  init(param: CompCtrlParam): void {
    LogUtil.info(`${this.tag} init`);
    if (!param) {
      LogUtil.error(`${this.tag} init failed, param is empty.`);
      return;
    }
    this.compId = (param as CompCtrlParam).compId;
    this.dataSource = param.dataSource as DynamicDataSource;
    // 注册闪烁提醒主开关变化监听
    EventBus.getInstance().on(ACCESSIBILITY_FLASH_REMINDER_SWITCH_EVENT, this.onMainSwitchChangeCallback);
    this.dataSource.pushData(this.createAlarmClockItem());
  }

  onPageShow(): void {
    LogUtil.info(`${this.tag} onPageShow, isShowGroup: ${this.isShowGroup}`);
    let flashSwitch: boolean | undefined = AccessibilityFlashReminderModel.getInstance().flashReminderSwitch;
    if (flashSwitch !== undefined && flashSwitch !== this.isShowGroup) {
      this.isShowGroup = AccessibilityFlashReminderModel.getInstance().flashReminderSwitch as boolean;
      this.onMainSwitchChangeCallback(this.isShowGroup);
    }
  }

  destroy(): void {
    LogUtil.info(`${this.tag} destroy`);
    EventBus.getInstance().detach(ACCESSIBILITY_FLASH_REMINDER_SWITCH_EVENT, this.onMainSwitchChangeCallback);
  }

  private createAlarmClockItem(): SettingItemModel {
    return {
      id: 'reminder_alarmClock_switch',
      type: ItemType.ITEM_TYPE_STANDARD,
      title: {
        content: $r('app.string.alarm_volume_title'),
        style: DEFAULT_TEXT_STYLE
      },
      icon: {
        icon: $r('app.media.ic_public_alarm_clock'),
        iconType: SettingIconType.ICON_TYPE_TIP,
        style: {
          mirrored: false,
          height: 24,
          width: 24,
          objectFit: ImageFit.Contain,
          draggable: false,
          fillColor: $r('sys.color.icon_primary'),
        }
      },
      result: {
        type: ItemResultType.RESULT_TYPE_TOGGLE,
        result: { state: true },
      },
      compControl: new ReminderFunctionSwitchController(ReminderFunctionModeValue.ALARM_CLOCK),
    };
  }
}
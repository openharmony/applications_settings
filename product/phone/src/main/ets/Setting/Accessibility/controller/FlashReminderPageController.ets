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

import { dataShare } from '@kit.ArkData';
import { CompCtrlParam, ComponentControl } from '@ohos/settings.common/src/main/ets/framework/model/SettingBaseModel';
import { EventBus } from '@ohos/settings.common/src/main/ets/framework/common/EventBus';
import { ItemResultType } from '@ohos/settings.common/src/main/ets/framework/model/SettingItemModel';
import { SettingPageModel } from '@ohos/settings.common/src/main/ets/framework/model/SettingPageModel';
import {
  HiSysAccessibilityEventGroup,
  HiSysAuxiliaryEventGroup
} from '@ohos/settings.common/src/main/ets/systemEvent/BehaviorEventConsts';
import { HiSysEventUtil } from '@ohos/settings.common/src/main/ets/systemEvent/HiSysEventUtil';
import {
  notifyCompStateChange,
  SettingResultState,
  SettingStateType,
  SettingToggleState
} from '@ohos/settings.common/src/main/ets/framework/model/SettingStateModel';
import { LogUtil } from '@ohos/settings.common/src/main/ets/utils/LogUtil';
import { SettingsDataUtils } from '@ohos/settings.common/src/main/ets/utils/SettingsDataUtils';
import { SearchDataController } from '@ohos/settings.search/src/main/ets/controller/SearchController';
import { PageUrl } from '../../../pages/PageUrl';
import { AccessibilityFlashReminderModel } from '../utils/AccessibilityCommonModel';
import {
  A11Y_CONFIG_CLONE,
  ACCESSIBILITY_FLASH_REMINDER_SWITCH,
  ACCESSIBILITY_FLASH_REMINDER_SWITCH_EVENT,
  ACCESSIBILITY_REMINDER_FUNCTION_ENABLED,
  CLICK_SWITCH_OFF,
  CLICK_SWITCH_ON
} from '../constant/Constants';
/* instrument ignore file */
const REMINDER_VALUE_HISYSEVENT_MAP: Map<string, string> = new Map([
  ['ALARM_CLOCK', HiSysAccessibilityEventGroup.FLASH_REMIND_CLOCK_SWITCH]
]);

/**
 * 闪烁提醒页面控制器
 *
 * @since 2025-05-22
 */
export class FlashReminderPageController implements ComponentControl {
  private tag: string = 'FlashReminderPageController : ';
  private compId: string = '';
  private settingPageModel?: SettingPageModel;

  async getAccessibilityConfig(): Promise<void> {
    try {
      let mainSwitchState: boolean = SettingsDataUtils.getSecureValue(ACCESSIBILITY_FLASH_REMINDER_SWITCH,
        CLICK_SWITCH_OFF) === CLICK_SWITCH_ON;
      let isEnabled: string = SettingsDataUtils.getSecureValue(ACCESSIBILITY_REMINDER_FUNCTION_ENABLED, '');
      AccessibilityFlashReminderModel.getInstance().flashReminderSwitch = mainSwitchState;
      if (isEnabled !== '') {
        AccessibilityFlashReminderModel.getInstance().flashReminderEnabled = isEnabled;
        AccessibilityFlashReminderModel.getInstance().flashReminderEnabledSet =
          new Set(isEnabled.includes(',') ? isEnabled.split(',') : [isEnabled]);
      } else {
        AccessibilityFlashReminderModel.getInstance().initEmptyReminderFunction();
        isEnabled = 'DEFAULT';
      }
      LogUtil.info(`${this.tag} get Accessibility success,
          mainSwitchState：${mainSwitchState}, isEnabled: ${isEnabled}`);
    } catch (err) {
      LogUtil.error(`${this.tag} get Accessibility config fail, err: ${err?.code}`);
    }
  }

  async init(compParam: CompCtrlParam): Promise<void> {
    if (!compParam || !compParam.compId) {
      LogUtil.error(`${this.tag} init fail, compParam is invalid`);
      return;
    }
    this.compId = compParam.compId;
    LogUtil.info(`${this.tag} init ${this.compId}`);
    if (compParam) {
      this.settingPageModel = compParam.component as SettingPageModel;
    }
    HiSysEventUtil.reportDefaultBehaviorEventByUE(HiSysAuxiliaryEventGroup.ENTER_FLASH_REMIND_PAGE,
      'pageUrl: ' + PageUrl.ACCESSIBILITY_FLASH_REMINDER_PAGE_URL);
  }

  async onPageShow(): Promise<void> {
    LogUtil.info(`${this.tag} onPageShow`);
    await this.getAccessibilityConfig();
  }

  destroy(): void {
    LogUtil.info(`${this.tag} on destroy`);
  }
}

/**
 * 闪烁提醒总开关控制器
 *
 * @since 2025-05-22
 */
export class FlashReminderSwitchController implements ComponentControl {
  private tag: string = 'FlashReminderSwitchController : ';
  private compId: string = '';
  private settingPageModel?: SettingPageModel;
  protected dataHelper?: dataShare.DataShareHelper;
  private switchState: boolean = false;
  private searchItems: string[] = ['reminder_alarmClock_switch'];
  private toggleStateChangeEventCallback = (toggleState: SettingToggleState) => {
    if (!toggleState) {
      LogUtil.error(`${this.tag} toggleModel is invalid`);
      return;
    }
    let isChecked: boolean = toggleState.state;
    LogUtil.info(`${this.tag} toggleState: ${isChecked}`)
    if (AccessibilityFlashReminderModel.getInstance().flashReminderSwitch !== isChecked) {
      AccessibilityFlashReminderModel.getInstance().flashReminderSwitch = isChecked;
      this.switchState = isChecked;
      if (isChecked) {
        SettingsDataUtils.setSecureValue(ACCESSIBILITY_FLASH_REMINDER_SWITCH, CLICK_SWITCH_ON);
        EventBus.getInstance().emit(ACCESSIBILITY_FLASH_REMINDER_SWITCH_EVENT, true);
      } else {
        SettingsDataUtils.setSecureValue(ACCESSIBILITY_FLASH_REMINDER_SWITCH, CLICK_SWITCH_OFF);
        EventBus.getInstance().emit(ACCESSIBILITY_FLASH_REMINDER_SWITCH_EVENT, false);
      }
      this.updateFlashReminderSearchItemStatus(this.switchState);
      HiSysEventUtil.reportDefaultBehaviorEventByUE(
        HiSysAccessibilityEventGroup.FLASH_REMIND_MAIN_SWITCH, isChecked ? 'on' : 'off');
    }
  };

  async getAccessibilityConfig(): Promise<void> {
    try {
      if (AccessibilityFlashReminderModel.getInstance().flashReminderSwitch as boolean !== this.switchState) {
        this.switchState = AccessibilityFlashReminderModel.getInstance().flashReminderSwitch as boolean;
        LogUtil.info(`${this.tag} get Accessibility config succ, switchState: ${this.switchState}`);
      }
      this.refreshUi(this.switchState);
    } catch (err) {
      LogUtil.error(`${this.tag} get Accessibility config fail, err: ${err?.code}`);
    }
  }

  /**
   * 数据库监听回调
   */
  public onDataChange = () => {
    LogUtil.info(`${this.tag} flash reminder switch status changed.`);
    this.switchState =
      SettingsDataUtils.getSecureValue(ACCESSIBILITY_FLASH_REMINDER_SWITCH, CLICK_SWITCH_OFF) === CLICK_SWITCH_ON;
    this.refreshUi(this.switchState);
  }
  /**
   * 克隆场景，监听克隆事件变化回调
   */
  public onCloneDataChange = () => {
    let cloneConfigState: boolean =
      SettingsDataUtils.getSettingsData(A11Y_CONFIG_CLONE, CLICK_SWITCH_OFF) === CLICK_SWITCH_ON;
    if (cloneConfigState === true) {
      LogUtil.info(`${this.tag} on clone config state change: ${cloneConfigState}`);
      this.switchState =
        SettingsDataUtils.getSecureValue(ACCESSIBILITY_FLASH_REMINDER_SWITCH, CLICK_SWITCH_OFF) === CLICK_SWITCH_ON;
      this.refreshUi(this.switchState);
    }
  }

  /**
   * 监听闪烁提醒开关的实时状态
   */
  protected async registerSecurityDataChange(): Promise<void> {
    if (this.dataHelper) {
      SettingsDataUtils.registerSecurityDataChange(
        this.dataHelper, ACCESSIBILITY_FLASH_REMINDER_SWITCH, this.onDataChange);
      SettingsDataUtils.registerDataChange(this.dataHelper, A11Y_CONFIG_CLONE, this.onCloneDataChange);
    } else {
      (SettingsDataUtils.createDataHelper(
        ACCESSIBILITY_FLASH_REMINDER_SWITCH) as Promise<dataShare.DataShareHelper>).then((
        dataShareHelper?: dataShare.DataShareHelper | undefined) => {
        if (dataShareHelper) {
          this.dataHelper = dataShareHelper;
          SettingsDataUtils.registerSecurityDataChange(this.dataHelper, ACCESSIBILITY_FLASH_REMINDER_SWITCH,
            this.onDataChange);
          SettingsDataUtils.registerDataChange(this.dataHelper, A11Y_CONFIG_CLONE, this.onCloneDataChange);
        }
      })
    }
    LogUtil.info(`${this.tag} flash reminder switch key listener registerd`);
  }

  /**
   * 取消监听闪烁提醒开关的实时状态
   */
  protected async unRegisterSecurityDataChange(): Promise<void> {
    SettingsDataUtils.unRegisterSecurityDataChange(
      this.dataHelper as dataShare.DataShareHelper, ACCESSIBILITY_FLASH_REMINDER_SWITCH);
    SettingsDataUtils.unRegisterDataChange(this.dataHelper as dataShare.DataShareHelper, A11Y_CONFIG_CLONE);
    LogUtil.info(`${this.tag} flash reminder switch listener unregisterd`);
  }

  init(compParam: CompCtrlParam): void {
    if (!compParam || !compParam.compId) {
      LogUtil.error(`${this.tag} init fail, compParam is invalid`);
      return;
    }
    this.compId = compParam.compId;
    LogUtil.info(`${this.tag} init ${this.compId}`);
    if (compParam) {
      this.settingPageModel = compParam.component as SettingPageModel;
    }
    EventBus.getInstance().on(`${this.compId}.toggle`, this.toggleStateChangeEventCallback);
    this.registerSecurityDataChange();
  }

  destroy(): void {
    LogUtil.info(`${this.tag} on destroy`);
    EventBus.getInstance().detach(`${this.compId}.toggle`, this.toggleStateChangeEventCallback);
    this.unRegisterSecurityDataChange();
  }

  onPageShow(): void {
    LogUtil.info(`${this.tag} onPageShow`);
    this.getAccessibilityConfig();
  }

  private refreshUi(isEnabled: boolean): void {
    notifyCompStateChange(this.compId,
      new Map<SettingStateType, SettingResultState>([[SettingStateType.STATE_TYPE_ITEM_RESULT,
        {
          type: ItemResultType.RESULT_TYPE_TOGGLE,
          result: { state: isEnabled }
        } as SettingResultState]]));
  }

  /**
   *  开启或关闭闪烁提醒开关时，更新闹钟是否支持搜索
   */
  private updateFlashReminderSearchItemStatus(isAllowed: boolean): void {
    LogUtil.info(`${this.tag} updateFlashReminderSearchItemStatus： ${isAllowed}`);
    this.searchItems.forEach((itemName) => {
      SearchDataController.getInstance().updateSearchItemStatus(itemName, isAllowed);
    });
  }
}

/**
 * 闪烁提醒功能开关控制器
 *
 * @since 2025-05-22
 */
export class ReminderFunctionSwitchController implements ComponentControl {
  private tag: string = 'ReminderFunctionSwitchController : ';
  private compId: string = '';
  private settingPageModel?: SettingPageModel;
  protected dataHelper?: dataShare.DataShareHelper;
  private reminderFunc?: string = '';
  private switchState: boolean = false;
  private toggleStateChangeEventCallback = (toggleState: SettingToggleState) => {
    if (!toggleState) {
      LogUtil.error(`${this.tag} toggleModel is invalid`);
      return;
    }
    let isChecked: boolean = toggleState.state;
    this.switchState = isChecked;
    if (isChecked) {
      AccessibilityFlashReminderModel.getInstance().flashReminderEnabledSet.add(this.reminderFunc as string);
    } else {
      AccessibilityFlashReminderModel.getInstance().flashReminderEnabledSet.delete(this.reminderFunc as string);
    }
    if (AccessibilityFlashReminderModel.getInstance().flashReminderEnabledSet.size === 0) {
      AccessibilityFlashReminderModel.getInstance().initEmptyReminderFunction();
    } else {
      AccessibilityFlashReminderModel.getInstance().flashReminderEnabled =
        Array.from<string>(AccessibilityFlashReminderModel.getInstance().flashReminderEnabledSet).join(',');
      SettingsDataUtils.setSecureValue(ACCESSIBILITY_REMINDER_FUNCTION_ENABLED,
        AccessibilityFlashReminderModel.getInstance().flashReminderEnabled);
    }
    HiSysEventUtil.reportDefaultBehaviorEventByUE(REMINDER_VALUE_HISYSEVENT_MAP.get(
      this.reminderFunc as string) as string, isChecked ? 'on' : 'off');
    LogUtil.info(`${this.tag} ${this.reminderFunc} toggleState: ${isChecked}, toggleStateChangeEventCallback
      flashReminderEnabled : ${AccessibilityFlashReminderModel.getInstance().flashReminderEnabled}`);
  };

  constructor(reminderFunc: string) {
    this.reminderFunc = reminderFunc;
  }

  async getAccessibilityConfig(): Promise<void> {
    try {
      AccessibilityFlashReminderModel.getInstance().getFlashReminderEnabled();
      if (AccessibilityFlashReminderModel.getInstance().flashReminderEnabledSet.has(this.reminderFunc as string)) {
        this.switchState = true;
      } else {
        this.switchState = false;
      }
      LogUtil.info(`${this.tag} ${this.reminderFunc} get Accessibility config succ : ${
      AccessibilityFlashReminderModel.getInstance().flashReminderEnabled}`);
      this.refreshUi(this.switchState);
    } catch (err) {
      LogUtil.error(`${this.tag} get Accessibility config fail, err: ${err?.code}`);
    }
  }

  /**
   * 数据库监听回调
   */
  public onDataChange = () => {
    LogUtil.info(`${this.tag} flash reminder function switch status changed.`);
    let dataStr: string = SettingsDataUtils.getSecureValue(ACCESSIBILITY_REMINDER_FUNCTION_ENABLED, '');
    if (dataStr !== '') {
      if (AccessibilityFlashReminderModel.getInstance().flashReminderEnabled !== dataStr) {
        AccessibilityFlashReminderModel.getInstance().flashReminderEnabled = dataStr;
        AccessibilityFlashReminderModel.getInstance().flashReminderEnabledSet = new Set(dataStr.split(','));
      }
      let isOpen: boolean = dataStr.includes(this.reminderFunc as string);
      if (isOpen !== this.switchState) {
        this.switchState = isOpen;
        this.refreshUi(this.switchState);
      }
    } else {
      AccessibilityFlashReminderModel.getInstance().initEmptyReminderFunction();
    }
  }
  /**
   * 克隆场景，监听克隆事件变化回调
   */
  public onCloneDataChange = () => {
    let cloneConfigState: boolean =
      SettingsDataUtils.getSettingsData(A11Y_CONFIG_CLONE, CLICK_SWITCH_OFF) === CLICK_SWITCH_ON;
    if (cloneConfigState === true) {
      this.onDataChange();
    }
  }

  /**
   * 监听闪烁提醒功能开关的实时状态
   */
  protected async registerSecurityDataChange(): Promise<void> {
    if (this.dataHelper) {
      SettingsDataUtils.registerSecurityDataChange(
        this.dataHelper, ACCESSIBILITY_REMINDER_FUNCTION_ENABLED, this.onDataChange);
      SettingsDataUtils.registerDataChange(this.dataHelper, A11Y_CONFIG_CLONE, this.onCloneDataChange);
    } else {
      (SettingsDataUtils.createDataHelper(
        ACCESSIBILITY_REMINDER_FUNCTION_ENABLED) as Promise<dataShare.DataShareHelper>).then((
        dataShareHelper?: dataShare.DataShareHelper | undefined) => {
        if (dataShareHelper) {
          this.dataHelper = dataShareHelper;
          SettingsDataUtils.registerSecurityDataChange(this.dataHelper, ACCESSIBILITY_REMINDER_FUNCTION_ENABLED,
            this.onDataChange);
          SettingsDataUtils.registerDataChange(this.dataHelper, A11Y_CONFIG_CLONE, this.onCloneDataChange);
        }
      })
    }
    LogUtil.info(`${this.tag} flash reminder function switch key listener registerd`);
  }

  /**
   * 取消监听闪烁提醒功能开关的实时状态
   */
  protected async unRegisterSecurityDataChange(): Promise<void> {
    SettingsDataUtils.unRegisterSecurityDataChange(
      this.dataHelper as dataShare.DataShareHelper, ACCESSIBILITY_REMINDER_FUNCTION_ENABLED);
    SettingsDataUtils.unRegisterDataChange(this.dataHelper as dataShare.DataShareHelper, A11Y_CONFIG_CLONE);
    LogUtil.info(`${this.tag} flash reminder function switch listener unregisterd`);
  }

  init(compParam: CompCtrlParam): void {
    if (!compParam || !compParam.compId) {
      LogUtil.error(`${this.tag} init fail, compParam is invalid`);
      return;
    }
    this.compId = compParam.compId;
    LogUtil.info(`${this.tag} ${this.reminderFunc} init ${this.compId}`);
    if (compParam) {
      this.settingPageModel = compParam.component as SettingPageModel;
    }
    this.getAccessibilityConfig();
    EventBus.getInstance().on(`${this.compId}.toggle`, this.toggleStateChangeEventCallback);
    this.registerSecurityDataChange();
  }

  destroy(): void {
    LogUtil.info(`${this.tag} ${this.reminderFunc} on destroy`);
    EventBus.getInstance().detach(`${this.compId}.toggle`, this.toggleStateChangeEventCallback);
    this.unRegisterSecurityDataChange();
  }

  onPageShow(): void {
    LogUtil.info(`${this.tag} onPageShow`);
  }

  private refreshUi(isEnabled: boolean): void {
    notifyCompStateChange(this.compId,
      new Map<SettingStateType, SettingResultState>([[SettingStateType.STATE_TYPE_ITEM_RESULT,
        {
          type: ItemResultType.RESULT_TYPE_TOGGLE,
          result: { state: isEnabled }
        } as SettingResultState]]));
  }
}
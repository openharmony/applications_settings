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
import {
  CompCtrlParam,
  ComponentControl,
  SettingBaseModel
} from '@ohos/settings.common/src/main/ets/framework/model/SettingBaseModel';
import { SettingsDataUtils } from '@ohos/settings.common/src/main/ets/utils/SettingsDataUtils';
import { LogUtil } from '@ohos/settings.common/src/main/ets/utils/LogUtil';
import {
  notifyCompStateChange,
  SettingBaseState,
  SettingCompState,
  SettingResultState,
  SettingStateType,
} from '@ohos/settings.common/src/main/ets/framework/model/SettingStateModel';
import { ItemResultType } from '@ohos/settings.common/src/main/ets/framework/model/SettingItemModel';
import { EventBus } from '@ohos/settings.common/src/main/ets/framework/common/EventBus';
import {
  ACCESSIBILITY_FLASH_REMINDER_SWITCH,
  CLICK_SWITCH_OFF,
  CLICK_SWITCH_ON
} from '../constant/Constants';
/* instrument ignore file */
const TAG: string = 'FlashReminderSettingsController : ';
const A11Y_CONFIG_CLONE: string = 'accessibility_config_clone';

/**
 * 闪烁提醒控制器
 *
 * @since 2025-05-23
 */
export class FlashReminderSettingsController implements ComponentControl {
  public flashReminderState: boolean = false;
  protected dataHelper?: dataShare.DataShareHelper;
  private compId: string = '';
  private isVisible: boolean | undefined = undefined;
  private showEventCallBack = (state: boolean) => {
    if (state !== undefined && this.isVisible !== state) {
      this.isVisible = state;
      this.notifyCompInvisible();
    }
  }
  /**
   * 数据库监听回调
   */
  public onDataChange = () => {
    LogUtil.info(`${TAG} flash reminder status data change`);
    this.flashReminderState =
      SettingsDataUtils.getSecureValue(ACCESSIBILITY_FLASH_REMINDER_SWITCH, CLICK_SWITCH_OFF) === CLICK_SWITCH_ON;
    this.refreshUi();
  }
  /**
   * 克隆场景，监听克隆事件变化回调
   */
  public onCloneDataChange = () => {
    let cloneConfigState: boolean =
      SettingsDataUtils.getSettingsData(A11Y_CONFIG_CLONE, CLICK_SWITCH_OFF) === CLICK_SWITCH_ON;
    if (cloneConfigState === true) {
      LogUtil.info(`${TAG} on clone config state change: ${cloneConfigState}`);
      this.flashReminderState =
        SettingsDataUtils.getSecureValue(ACCESSIBILITY_FLASH_REMINDER_SWITCH, CLICK_SWITCH_OFF) === CLICK_SWITCH_ON;
      this.refreshUi();
    }
  }

  constructor(isVisible: boolean | undefined) {
    this.isVisible = isVisible;
  }

  private notifyCompInvisible(): void {
    LogUtil.info(`${TAG} flashReminder visible state change: ${this.isVisible}`);
    notifyCompStateChange(this.compId, new Map<SettingStateType, SettingBaseState>(
      [[SettingStateType.STATE_TYPE_ITEM_VISIBLE, { state: this.isVisible } as SettingCompState]]));
  }

  async getAccessibilityConfig(): Promise<void> {
    let isEnabled: boolean =
      SettingsDataUtils.getSecureValue(ACCESSIBILITY_FLASH_REMINDER_SWITCH, CLICK_SWITCH_OFF) === CLICK_SWITCH_ON;
    this.flashReminderState = isEnabled;
    LogUtil.info(`${TAG} get flashReminderState success:${isEnabled}`);
  }

  /**
   * 监听闪烁提醒开关的实时状态以及克隆完成状态
   */
  protected async registerSecurityDataChange(): Promise<void> {
    if (this.dataHelper) {
      SettingsDataUtils.registerSecurityDataChange(this.dataHelper, ACCESSIBILITY_FLASH_REMINDER_SWITCH,
        this.onDataChange);
      SettingsDataUtils.registerDataChange(this.dataHelper, A11Y_CONFIG_CLONE, this.onCloneDataChange);
    } else {
      (SettingsDataUtils.createDataHelper(ACCESSIBILITY_FLASH_REMINDER_SWITCH) as Promise<
        dataShare.DataShareHelper>).then((dataShareHelper?: dataShare.DataShareHelper | undefined) => {
        if (dataShareHelper) {
          this.dataHelper = dataShareHelper;
          SettingsDataUtils.registerSecurityDataChange(this.dataHelper, ACCESSIBILITY_FLASH_REMINDER_SWITCH,
            this.onDataChange);
          SettingsDataUtils.registerDataChange(this.dataHelper, A11Y_CONFIG_CLONE, this.onCloneDataChange);
        }
      })
    }
    LogUtil.info(`${TAG} flash reminder key listener registerd`);
  }

  /**
   * 取消监听闪烁提醒开关的实时状态以及克隆完成状态
   */
  protected async unRegisterSecurityDataChange(): Promise<void> {
    SettingsDataUtils.unRegisterSecurityDataChange(this.dataHelper as dataShare.DataShareHelper,
      ACCESSIBILITY_FLASH_REMINDER_SWITCH);
    SettingsDataUtils.unRegisterDataChange(this.dataHelper as dataShare.DataShareHelper, A11Y_CONFIG_CLONE);
    LogUtil.info(`${TAG} flash reminder key listener unregisterd`);
  }

  async init(compParam: CompCtrlParam): Promise<void> {
    LogUtil.info(`${TAG} init`);
    if (!compParam || !compParam.compId) {
      LogUtil.error(`${TAG} init fail, compParam is invalid`);
      return;
    }
    this.compId = compParam.compId;
    await this.getAccessibilityConfig();
    this.refreshUi();
    this.registerSecurityDataChange();
  }

  destroy(): void {
    LogUtil.info(`${TAG} on destroy`);
    this.unRegisterSecurityDataChange()
  }

  onPageShow(component: SettingBaseModel): void {
    LogUtil.info(`${TAG} onPageShow`);
  }

  onPageHide(component: SettingBaseModel): void {
    LogUtil.info(`${TAG} onPageHide`);
  }

  private refreshUi(): void {
    let statusResult: ResourceStr =
      this.flashReminderState ? $r('app.string.accessibility_on') : $r('app.string.accessibility_off');
    notifyCompStateChange(this.compId,
      new Map<SettingStateType, SettingResultState>([[SettingStateType.STATE_TYPE_ITEM_RESULT,
        { type: ItemResultType.RESULT_TYPE_TEXT, result: { content: statusResult } } as SettingResultState]]));
  }
}

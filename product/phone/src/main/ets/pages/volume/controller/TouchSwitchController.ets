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

import { SwitchMenuController } from '@ohos/settings.common/src/main/ets/core/controller/MenuController';
import { SettingsBaseMenu } from '@ohos/settings.common/src/main/ets/core/model/menu/SettingsMenu';
import { LogUtil } from '@ohos/settings.common/src/main/ets/utils/LogUtil';
import { Controller } from '@ohos/settings.common/src/main/ets/core/controller/Controller';
import { SettingsDataUtils } from '@ohos/settings.common/src/main/ets/utils/SettingsDataUtils';
import {
  HiSysElderCareEventGroup,
  HiSysEventUtil,
  HiSysVolumeEventGroup
} from '@ohos/settings.common/src/main/ets/systemEvent/HiSysEventUtil';

const PHYSIC_NAVI_HAPTIC_FEEDBACK_ENABLED: string = 'physic_navi_haptic_feedback_enabled';
const TAG: string = 'TouchSwitchController : ';

/**
 * 触控反馈开关控制器
 */
@Observed
export class TouchFeedbackController extends SwitchMenuController {

  static CreateTouchFeedbackController(menu: SettingsBaseMenu): Controller {
    return new TouchFeedbackController(menu);
  }

  constructor(menu: SettingsBaseMenu) {
    super(menu);
    this.getObserverKey = () => this.menu.key as string;
  }

  registerDataChange() {
    this.menu?.getRoot()?.getLifecycleOwner()?.addObserver(this);
  }

  unRegisterDataChange() {
    this.menu?.getRoot()?.getLifecycleOwner()?.removeObserver(this.menu.key as string);
  }

  onPageShow() {
    LogUtil.info(`${TAG} AAA onPageShow`)
    this.updateStatus();
  }

  onPageHide() {
    LogUtil.info(`${TAG} BBB onPageHide`)
  }

  /**
   * 开关变化的回调
   */
  protected handleCheckedChange(isChecked: boolean): boolean {
    HiSysEventUtil.reportDefaultBehaviorEventByUE(HiSysVolumeEventGroup.VOLUME_TOUCH_FEEDBACK, isChecked ? 'On' : 'off');
    HiSysEventUtil.reportDefaultBehaviorEventByUE(HiSysElderCareEventGroup.ELDER_CARE_TOUCH_FEEDBACK_CLICK,
      isChecked ? 'On' : 'off');
    SettingsDataUtils.setSettingsData(PHYSIC_NAVI_HAPTIC_FEEDBACK_ENABLED, isChecked ? '1' : '0')
    this.updateStatus()
    this.publishDataChange(isChecked);
    return true;

  }


  /**
   * 返回开关的实时状态
   */
  protected updateCheckedState(): boolean {
    return SettingsDataUtils.getSettingsData(PHYSIC_NAVI_HAPTIC_FEEDBACK_ENABLED, '1') == '1';
  }


  updateStatus(): void {
    let isChecked = this.updateCheckedState();
    this.setChecked(isChecked);
    this.refreshUi()
  }
}
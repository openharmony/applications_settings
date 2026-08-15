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

import config from '@ohos.accessibility.config';
import { SwitchMenuController } from '@ohos/settings.common/src/main/ets/core/controller/MenuController';
import { SettingsBaseMenu } from '@ohos/settings.common/src/main/ets/core/model/menu/SettingsMenu';
import { LogUtil } from '@ohos/settings.common/src/main/ets/utils/LogUtil';
import { Controller } from '@ohos/settings.common/src/main/ets/core/controller/Controller';
import { HiSysEventUtil } from '@ohos/settings.common/src/main/ets/systemEvent/HiSysEventUtil';
import { HiSysAccessibilityEventGroup } from '@ohos/settings.common/src/main/ets/systemEvent/BehaviorEventConsts';
import { AccessibilitySettingModel } from '../model/AccessibilitySettingModel';
/* instrument ignore file */
const TAG: string = 'AccessibilityIgnoreRepeatTouchesController : ';

/**
 * 屏幕触控-忽略重复点击开关选择
 *
 * @since 2023-12-08
 */
@Observed
export class AccessibilityIgnoreRepeatTouchesController extends SwitchMenuController {
  public ignoreRepeatClick: boolean;
  static CreateAccessibilityIgnoreRepeatTouchesController(menu: SettingsBaseMenu): Controller {
    return new AccessibilityIgnoreRepeatTouchesController(menu);
  }
 
  private static switchState: boolean = true;
 
  constructor(menu: SettingsBaseMenu) {
    super(menu);
    this.ignoreRepeatClick = menu?.extra as boolean;
  }
 
  /**
   * 返回开关的实时状态
   */
  public updateStatus(): void {
    super.updateStatus();
    this.setChecked(this.ignoreRepeatClick);
    AccessibilityIgnoreRepeatTouchesController.switchState = this.ignoreRepeatClick;
    LogUtil.info(`${TAG} get Ignore Repeat Touches success`);
  }
 
  /**
   * 开关变化的回调
   */
  protected handleCheckedChange(isChecked: boolean): boolean {
    LogUtil.info(`${TAG} handleCheckedChange isChecked: ${isChecked}`);
    AccessibilitySettingModel.accessibilityConfigSetting('ignoreRepeatTouches', isChecked);
    this.menu?.getRoot()?.publishControllerDataChange('ignore_repeated_touches_switch', isChecked);
    if (AccessibilityIgnoreRepeatTouchesController.switchState || isChecked) {
      HiSysEventUtil.reportDefaultBehaviorEventByUE(
        HiSysAccessibilityEventGroup.IGNORE_REPEAT_TOUCHES_SWITCH, isChecked ? 'on' : 'off');
      AccessibilityIgnoreRepeatTouchesController.switchState = true;
    }
    return true;
  }

  onPageShow(): void {
    LogUtil.info(`${TAG} onPageShow success`);
    this.updateStatus();
  }

  public getObserverKey = (): string => {
    return this.menu?.key as string;
  }

  /**
   * 监听开关的实时状态
   */
  protected registerDataChange(): void {
    try {
      config.ignoreRepeatClick.on((data) => {
        if (AccessibilityIgnoreRepeatTouchesController.switchState === data) {
          AccessibilityIgnoreRepeatTouchesController.switchState = !data;
        }
        this.ignoreRepeatClick = data;
        LogUtil.info(`${TAG} ignoreRepeatTouches state change`);
        this.updateStatus();
      });
    } catch (err) {
      LogUtil.error(`${TAG} failed subscribe ignoreRepeatTouches, because ${err?.message}`);
    }
  }

  /**
   * 取消监听开关的实时状态
   */
  protected unRegisterDataChange(): void {
    LogUtil.info(`${TAG} unRegisterDataChange`);
    try {
      config.ignoreRepeatClick.off(() => {
        LogUtil.info(`${TAG} Register ignoreRepeatTouches state change off`);
      });
    } catch (err) {
      LogUtil.error(`${TAG} failed unsubscribe ignoreRepeatTouches, because ${err?.message}`);
    }
  }
}
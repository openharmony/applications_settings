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
const TAG: string = 'AccessibilityInvertColorController : ';

/**
 * 无障碍颜色反转控制器
 *
 * @since 2023-09-19
 */
export class AccessibilityInvertColorController extends SwitchMenuController {
  static CreateAccessibilityInvertColorController(menu: SettingsBaseMenu): Controller {
    return new AccessibilityInvertColorController(menu);
  }

  private static switchState: boolean = true;
  public invertColorState: boolean;

  constructor(menu: SettingsBaseMenu) {
    super(menu);
    this.invertColorState = menu?.extra as boolean;
  }

  /**
   * 返回开关的实时状态
   */
  public updateStatus(): void {
    this.setChecked(this.invertColorState);
    LogUtil.info(`${TAG} update status is: ${this.invertColorState}`)
    super.updateStatus();
  }

  /**
   * 开关变化的回调
   */
  protected handleCheckedChange(isChecked: boolean): boolean {
    LogUtil.info(`${TAG} handleCheckedChange isChecked: ${isChecked}`);
    AccessibilityInvertColorController.switchState = isChecked;
    if (isChecked) {
      AccessibilitySettingModel.accessibilityConfigSetting('invertColor', true);
    } else {
      AccessibilitySettingModel.accessibilityConfigSetting('invertColor', false);
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

  public onPageHide(): void {
    LogUtil.info(`${TAG} onPageHide success`);
  }

  /**
   * 监听开关的实时状态
   */
  protected registerDataChange(): void {
    try {
      config.invertColor.on((data) => {
        if (AccessibilityInvertColorController.switchState === data) {
          HiSysEventUtil.reportDefaultBehaviorEventByUE(
            HiSysAccessibilityEventGroup.CHANGE_INVERT_COLOR_TEXT_SWITCH, data ? 'on' : 'off');
          AccessibilityInvertColorController.switchState = !data;
        }
        this.invertColorState = data;
        LogUtil.info(`${TAG} invertColor state change`);
        this.updateStatus();
      });
    } catch (err) {
      LogUtil.error(`${TAG} failed subscribe invertColor, because ${err?.message}`);
    }
  }

  /**
   * 取消监听开关的实时状态
   */
  protected unRegisterDataChange(): void {
    LogUtil.info(`${TAG} unRegisterDataChange`);
    try {
      config.invertColor.off(() => {
        LogUtil.info(`${TAG} Register invertColor state change off`);
      });
    } catch (err) {
      LogUtil.error(`${TAG} failed unsubscribe invertColor, because ${err?.message}`);
    }
  }
}

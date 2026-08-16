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
const TAG: string = 'AccessibilityColorFilterController : ';

/**
 * 色彩校正开关选择
 *
 * @since 2023-09-25
 */
@Observed
export class AccessibilityColorFilterController extends SwitchMenuController {
  static CreateAccessibilityColorFilterController(menu: SettingsBaseMenu): Controller {
    return new AccessibilityColorFilterController(menu);
  }

  public daltonizationState: boolean;

  constructor(menu: SettingsBaseMenu) {
    super(menu);
    this.daltonizationState = menu?.extra as boolean;
  }

  /**
   * 返回开关的实时状态
   */
  public updateStatus(): void {
    LogUtil.info(`${TAG} daltonizationState isChecked: ${this.daltonizationState}`);
    this.setChecked(this.daltonizationState);
    super.updateStatus();
  }

  /**
   * 开关变化的回调
   */
  protected handleCheckedChange(isChecked: boolean): boolean {
    LogUtil.info(`${TAG} handleCheckedChange isChecked: ${isChecked}`);
    if (isChecked) {
      AccessibilitySettingModel.accessibilityConfigSetting('colorFilter', true);
    } else {
      AccessibilitySettingModel.accessibilityConfigSetting('colorFilter', false);
    }
    return true;
  }

  public onPageShow(): void {
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
      config.daltonizationState.on((data) => {
        if (this.daltonizationState != data) {
          HiSysEventUtil.reportDefaultBehaviorEventByUE(
            HiSysAccessibilityEventGroup.DALTONIZATION_SWITCH, data ? 'on' : 'off');
          this.daltonizationState = data;
          LogUtil.info(`${TAG} daltonizationState state change`);
          this.updateStatus();
        }
      });
    } catch (err) {
      LogUtil.error(`${TAG} failed subscribe daltonizationState, because ${err?.message}`);
    }
  }

  /**
   * 取消监听开关的实时状态
   */
  protected unRegisterDataChange(): void {
    LogUtil.info(`${TAG} unRegisterDataChange`);
    try {
      config.daltonizationState.off(() => {
        LogUtil.info(`${TAG} Register daltonizationState state change off`);
      });
    } catch (err) {
      LogUtil.error(`${TAG} failed unsubscribe daltonizationState, because ${err?.message}`);
    }
  }
}
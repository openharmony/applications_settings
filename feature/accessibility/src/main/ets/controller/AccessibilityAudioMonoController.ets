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
const TAG: string = 'AccessibilityAudioMonoController : ';

/**
 * 无障碍单声道音量控制器
 *
 * @since 2023-06-01
 */

export class AccessibilityAudioMonoController extends SwitchMenuController {
  static CreateAccessibilityAudioMonoController(menu: SettingsBaseMenu): Controller {
    return new AccessibilityAudioMonoController(menu);
  }

  private static switchState: boolean = true;
  public audioMonoState: boolean;

  constructor(menu: SettingsBaseMenu) {
    super(menu);
    this.audioMonoState = menu?.extra as boolean;
  }

  /**
   * 返回开关的实时状态
   */
  public updateStatus(): void {
    this.setChecked(this.audioMonoState);
    super.updateStatus();
  }

  /**
   * 开关变化的回调
   */
  protected handleCheckedChange(isChecked: boolean): boolean {
    LogUtil.info(`${TAG} handleCheckedChange isChecked: ${isChecked}`);
    HiSysEventUtil.reportDefaultBehaviorEventByUE(
      HiSysAccessibilityEventGroup.AUDIO_MONO_RADIO_CHANGE, isChecked ? 'on' : 'off');
    AccessibilityAudioMonoController.switchState = isChecked;
    if (isChecked) {
      AccessibilitySettingModel.accessibilityConfigSetting('audioMono', true);
    } else {
      AccessibilitySettingModel.accessibilityConfigSetting('audioMono', false);
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
      config.audioMono.on((data) => {
        LogUtil.info(`${TAG} audioMono state change.`);
        if (AccessibilityAudioMonoController.switchState === data) {
          AccessibilityAudioMonoController.switchState = !data;
        }
        this.audioMonoState = data;
        this.updateStatus();
      });
    } catch (err) {
      LogUtil.error(`${TAG} failed subscribe audioMono, because ${err?.message}`);
    }
  }

  /**
   * 取消监听开关的实时状态
   */
  protected unRegisterDataChange(): void {
    LogUtil.info(`${TAG} unRegisterDataChange`);
    try {
      config.audioMono.off(() => {
        LogUtil.info(`${TAG} Register audioMono state change off`);
      });
    } catch (err) {
      LogUtil.error(`${TAG} failed unsubscribe audioMono, because ${err?.message}`);
    }
  }
}

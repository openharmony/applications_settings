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
import { BusinessError } from '@ohos.base';
import { SwitchMenuController } from '@ohos/settings.common/src/main/ets/core/controller/MenuController';
import { SettingsBaseMenu } from '@ohos/settings.common/src/main/ets/core/model/menu/SettingsMenu';
import { LogUtil } from '@ohos/settings.common/src/main/ets/utils/LogUtil';
import { Controller } from '@ohos/settings.common/src/main/ets/core/controller/Controller';
import { HiSysEventUtil } from '@ohos/settings.common/src/main/ets/systemEvent/HiSysEventUtil';
import { HiSysAccessibilityEventGroup } from '@ohos/settings.common/src/main/ets/systemEvent/BehaviorEventConsts';
import {
  BundleStatusChangeListener,
  BundleStatusChangeManager
} from '@ohos/settings.common/src/main/ets/bundle/BundleStatusChangeManager';
import { AccessibilitySettingModel } from '../model/AccessibilitySettingModel';
/* instrument ignore file */
const TAG: string = 'AccessibilityShortKeyController : ';

/**
 * 辅助功能快捷键控制器
 *
 * @since 2023-06-20
 */
export class AccessibilityShortKeyController extends SwitchMenuController {
  static CreateAccessibilityShortKeyController(menu: SettingsBaseMenu): Controller {
    return new AccessibilityShortKeyController(menu);
  }

  private static switchState: boolean = true;
  public shortKetState: boolean;

  constructor(menu: SettingsBaseMenu) {
    super(menu);
    this.shortKetState = menu?.extra as boolean;
  }

  /**
   * 返回开关的实时状态
   */
  updateStatus(): void {
    this.setChecked(this.shortKetState);
    AccessibilityShortKeyController.switchState = this.shortKetState;
    super.updateStatus();
  }

  /**
   * 开关变化的回调
   */
  protected handleCheckedChange(isChecked: boolean): boolean {
    LogUtil.info(`${TAG} handleCheckedChange isChecked: ${isChecked}`);
    if (isChecked) {
      AccessibilitySettingModel.accessibilityConfigSetting('shortKey', true);
    } else {
      AccessibilitySettingModel.accessibilityConfigSetting('shortKey', false);
    }
    if (AccessibilityShortKeyController.switchState || isChecked) {
      HiSysEventUtil.reportDefaultBehaviorEventByUE(
        HiSysAccessibilityEventGroup.ACCESSIBILITY_SHORTCUT_SWITCH, isChecked ? 'on' : 'off');
      AccessibilityShortKeyController.switchState = true;
    }
    return true;
  }

  protected registerDataChange(): void {
    try {
      config.shortkey.on((data) => {
        if (AccessibilityShortKeyController.switchState === data) {
          HiSysEventUtil.reportDefaultBehaviorEventByUE(
            HiSysAccessibilityEventGroup.ACCESSIBILITY_SHORTCUT_SWITCH, data ? 'on' : 'off');
          AccessibilityShortKeyController.switchState = !data;
        }
        this.shortKetState = data;
        LogUtil.info(`${TAG} shortKey state change:${data}`);
        this.updateStatus();
      });
    } catch (err) {
      LogUtil.error(`${TAG} failed subscribe shortKey, because ${err}`);
    }
    this.registerStatusChange();
  }

  protected registerStatusChange(): void {
    if (!this.isRegister) {
      BundleStatusChangeManager.getInstance().registerBundleChangedListener(this.bundleStatusCallback);
      this.isRegister = true;
    }
  }

  protected readonly bundleStatusCallback: BundleStatusChangeListener = {
    getListenerName: (): string => {
      return this.menu.key ?? ' ';
    },
    onBundleAdd: (bundleName: string, userId: number) => {
      LogUtil.info(`${TAG} bundleStatusCallback add : bundleName:${bundleName} userId:${userId}`);
    },
    onBundleRemove: (bundleName: string, userId: number) => {
      LogUtil.info(`${TAG} bundleStatusCallback remove : bundleName:${bundleName} userId:${userId}`);
      config.shortkey.get().then((data: boolean) => {
        LogUtil.info(`${TAG} shortkey state get`);
        this.shortKetState = data;
        this.updateStatus();
      }).catch((error: BusinessError) => {
        LogUtil.error(`${TAG} short key get failed: ${error.message}`);
      });
    },
    onBundleUpdate: (bundleName: string, userId: number) => {
      LogUtil.info(`${TAG} bundleStatusCallback update : bundleName:${bundleName} userId:${userId}`);
    }
  }

  /**
   * 取消监听开关的实时状态
   */
  protected unRegisterDataChange(): void {
    try {
      config.shortkey.off(() => {
        LogUtil.info(`${TAG} Register shortKey state change off`);
      });
    } catch (err) {
      LogUtil.error(`${TAG} failed unsubscribe shortKey, because ${err}`);
    }
    this.unRegisterStatusChange();
  }

  private unRegisterStatusChange(): void {
    if (this.isRegister) {
      BundleStatusChangeManager.getInstance().unRegisterBundleChangedListener(this.bundleStatusCallback);
      this.isRegister = false;
    }
  }
}

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
import { SettingsDataUtils } from '@ohos/settings.common/src/main/ets/utils/SettingsDataUtils';
import { Controller } from '@ohos/settings.common/src/main/ets/core/controller/Controller';
import dataShare from '@ohos.data.dataShare';
import { HiSysEventUtil } from '@ohos/settings.common/src/main/ets/systemEvent/HiSysEventUtil';
import { HiSysAccessibilityEventGroup } from '@ohos/settings.common/src/main/ets/systemEvent/BehaviorEventConsts';
/* instrument ignore file */
const TAG: string = 'AccessibilityZoomGestureController : ';
const SCREEN_MAGNIFICATION: string = 'accessibility_display_magnification_enabled';
const SCREEN_MAGNIFICATION_ON: string = '1';
const SCREEN_MAGNIFICATION_OFF: string = '0';
// 放大手势触发方式：0-单指三击，1-三指双击
const SCREEN_MAGNIFICATION_TRIGGER_METHOD: string =
  'accessibility_display_magnification_trigger_method';
const SCREEN_MAGNIFICATION_TRIGGER_SINGLE_FINGER_TRIPLE_TAP: string = '0';

/**
 * 放大手势页面控制器
 *
 * @since 2024-07-16
 */
@Observed
export class AccessibilityZoomGestureController extends SwitchMenuController {
  static CreateAccessibilityZoomGestureController(menu: SettingsBaseMenu): Controller {
    return new AccessibilityZoomGestureController(menu);
  }

  public zoomGestureState: boolean;
  protected dataHelper?: dataShare.DataShareHelper;

  constructor(menu: SettingsBaseMenu) {
    super(menu);
    this.zoomGestureState = menu?.extra as boolean;
  }

  /**
   * 返回开关的实时状态
   */
  public updateStatus(): void {
    LogUtil.info(`${TAG} zoomGestureState isChecked: ${this.zoomGestureState}`);
    this.setChecked(this.zoomGestureState);
    super.updateStatus();
  }

  /**
   * 数据库监听回调
   */
  public onDataChange = () => {
    this.zoomGestureState = SettingsDataUtils.getSecureValue(SCREEN_MAGNIFICATION,
      SCREEN_MAGNIFICATION_OFF) === SCREEN_MAGNIFICATION_ON;
    HiSysEventUtil.reportDefaultBehaviorEventByUE(
      HiSysAccessibilityEventGroup.ZOOM_GESTURE_SWITCH, this.zoomGestureState ? 'on' : 'off');
    this.updateStatus();
  }

  /**
   * 开关变化的回调
   */
  protected handleCheckedChange(isChecked: boolean): boolean {
    LogUtil.info(`${TAG} handleCheckedChange isChecked: ${isChecked}`);
    if (isChecked) {
      SettingsDataUtils.setSecureValue(SCREEN_MAGNIFICATION, '1');
      // 设置页按单指三击引导，显式写入触发方式
      SettingsDataUtils.setSecureValue(SCREEN_MAGNIFICATION_TRIGGER_METHOD,
        SCREEN_MAGNIFICATION_TRIGGER_SINGLE_FINGER_TRIPLE_TAP);
      this.zoomGestureState = true;
    } else {
      SettingsDataUtils.setSecureValue(SCREEN_MAGNIFICATION, '0');
      this.zoomGestureState = false;
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
    if (this.dataHelper) {
      SettingsDataUtils.registerSecurityDataChange(this.dataHelper, SCREEN_MAGNIFICATION,
        this.onDataChange);
    } else {
      (SettingsDataUtils.createDataHelper(SCREEN_MAGNIFICATION) as Promise<dataShare.DataShareHelper>)
        .then((dataShareHelper?: dataShare.DataShareHelper | undefined) => {
          if (dataShareHelper) {
            this.dataHelper = dataShareHelper;
            SettingsDataUtils.registerSecurityDataChange(this.dataHelper, SCREEN_MAGNIFICATION,
              this.onDataChange);
          }
        })
    }
    LogUtil.info(`${TAG} zoom gesture state listener registerd`);
  }

  /**
   * 取消监听开关的实时状态
   */
  protected unRegisterDataChange(): void {
    LogUtil.info(`${TAG} unRegisterDataChange`);
    SettingsDataUtils.unRegisterSecurityDataChange(this.dataHelper as dataShare.DataShareHelper,
      SCREEN_MAGNIFICATION);
  }
}
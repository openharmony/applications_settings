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

import { settings } from '@kit.BasicServicesKit';
import { LogUtil } from '@ohos/settings.common/src/main/ets/utils/LogUtil';
import { HiSysEventUtil } from '@ohos/settings.common/src/main/ets/systemEvent/HiSysEventUtil';
/* instrument ignore file */
const TAG: string = 'AiBarSwitchManager';

export const GESTURE_NAVIGATION = '1';

export const FLOATING_NAVIGATION = '0';

export const AI_BAR_TYPE = 0;

export const FLOATING_NAVIGATION_TYPE = 1;

export const SWITCH_TITLE_FONTCOLOR = $r('sys.color.font_primary');

export const SWITCH_TERTIARY_FONTCOLOR = $r('sys.color.font_tertiary');

export class AiBarSwitchManager {
  public readonly floatingSettingDoMain: string = settings.domainName.USER_PROPERTY;
  public readonly aiBarSettingDoMain: string = settings.domainName.USER_PROPERTY;
  private static instance: AiBarSwitchManager;
  private threeButtonOpen: boolean = false;
  public readonly FLOATING_NAV_NAME: string = 'floatingNavigation';
  private  pageId: number = -1;

  private constructor() {
  }

  public static getInstance(): AiBarSwitchManager {
    if (!AiBarSwitchManager.instance) {
      AiBarSwitchManager.instance = new AiBarSwitchManager();
    }
    return AiBarSwitchManager.instance;
  }

  /**
   * 设置当前进入的系统导航页面的id
   */
  public setPageId(id: number): void {
    this.pageId = id;
  }

  /**
   * 获取当前进入的系统导航页面的id
   */
  public getPageId(): number {
    return this.pageId;
  }

  /**
   * 点击或者长按开关是否Enable
   */
  public isAiBarSwitchEnable(type: number): boolean {
    // 三键打开 点击和长按开关置灰，开关关闭，三键关闭后恢复之前状态
    if (this.threeButtonOpen && type === AI_BAR_TYPE) {
      return false;
    }
    return true;
  }

  public isFloatingNavigationOpen(): boolean {
    let systemNavigationStatusValue = settings.getValueSync(getContext(), 'floatingNavigation', GESTURE_NAVIGATION,
      this.floatingSettingDoMain);
    LogUtil.showInfo(TAG,
      `isFloatingNavigationOpen domainType is ${this.floatingSettingDoMain} Value is ${systemNavigationStatusValue}`);
    this.threeButtonOpen = systemNavigationStatusValue !== GESTURE_NAVIGATION;
    return this.threeButtonOpen;
  }

  public setValueToSettingsData(context: Context, name: string, type: number, isOn: boolean): void {
    try {
      let domainType = type === AI_BAR_TYPE ? this.aiBarSettingDoMain : this.floatingSettingDoMain;
      let setValue = type === AI_BAR_TYPE ? isOn.toString() : isOn ? FLOATING_NAVIGATION :
        GESTURE_NAVIGATION;
      LogUtil.showInfo(TAG, `setValue name is ${name} domainType is ${domainType} Value is ${setValue}`);
      settings.setValue(context, name, setValue, domainType);
      if (name === this.FLOATING_NAV_NAME) {
        HiSysEventUtil.reportFloatingNavSwitchParams(name, isOn);
      } else {
        HiSysEventUtil.reportAiBarSettingSwitchParams(name, isOn);
      }
    } catch (e) {
      LogUtil.showError(TAG, `setValue is error ${e?.message}`);
    }
  }

  public closeThreeButtonOrFloating(isThreeButtonOn: boolean = false, isFloatingOpen: boolean = false): void {
    // 悬浮导航开启，关闭三键
    if (isFloatingOpen) {
      settings.setValue(getContext(), AiBarSwitchManager.getInstance().FLOATING_NAV_NAME, GESTURE_NAVIGATION,
        this.floatingSettingDoMain);
    }

    // 三键开启 关闭悬浮导航
    if (isThreeButtonOn) {
      settings.setValue(getContext(), 'floating_navigation_ball', '0', this.floatingSettingDoMain);
    }
  }
}
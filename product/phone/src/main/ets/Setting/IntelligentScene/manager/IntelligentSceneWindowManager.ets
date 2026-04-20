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

import dataShare from '@ohos.data.dataShare';
import { AbilityContextManager } from '@ohos/settings.common/src/main/ets/ability/AbilityContextManager';
import { SettingsDataUtils } from '@ohos/settings.common/src/main/ets/utils/SettingsDataUtils';
import { LogUtil } from '@ohos/settings.common/src/main/ets/utils/LogUtil';
import { EventBus } from '@ohos/settings.common/src/main/ets/framework/common/EventBus';
import { DeviceUtil } from '@ohos/settings.common/src/main/ets/utils/BaseUtils';

/* instrument ignore file */
const TAG: string = 'IntelligentSceneWindowManager';

const WINDOW_MODE: string = 'settings.windowMode';
const SPLIT_MODE: string = '5';
const FLOATING_WINDOW_MODE: string = '4';
const DEFAULT_MODE: string = '-1';
export const SPLIT_1_3_RATE: number = 0.35;
export const SPLIT_MIN_SCROLL: number = 0.5;
export const SPLIT_MAX_SCROLL: number = 0.8;
export const SPLIT_PORTRAIT_RATE: number = 0.9;

export const WINDOW_MODE_CHANGE: string = 'WINDOW_MODE_CHANGE';

export class IntelligentSceneWindowManager {
  private static manager: IntelligentSceneWindowManager;
  private dataHelper: dataShare.DataShareHelper | null = null;
  private static isInMainPageMode: boolean = true;
  private onDataChange = () => {
    LogUtil.info(`${TAG} onDataChange`);
    EventBus.getInstance().emit(WINDOW_MODE_CHANGE, IntelligentSceneWindowManager.getWindowMode());
  }

  public static getInstance(): IntelligentSceneWindowManager {
    if (IntelligentSceneWindowManager.manager) {
      return IntelligentSceneWindowManager.manager;
    }
    IntelligentSceneWindowManager.manager = new IntelligentSceneWindowManager();
    return IntelligentSceneWindowManager.manager;
  }

  public static isMainPage(): boolean {
    return IntelligentSceneWindowManager.isInMainPageMode;
  }

  public static setInMainPage(isMainPageMode: boolean): void {
    IntelligentSceneWindowManager.isInMainPageMode = isMainPageMode;
  }

  public static isSplitScreenMode(windowMode: string): boolean {
    if (DeviceUtil.isDevicePad()) {
      return false;
    }
    return windowMode === SPLIT_MODE;
  }

  public static isFloatWindowMode(windowMode: string): boolean {
    return windowMode === FLOATING_WINDOW_MODE;
  }

  public static getWindowMode(): string {
    try {
      const windowMode: string = SettingsDataUtils.getSettingsDataWithContext(AbilityContextManager.getContext(),
        WINDOW_MODE, DEFAULT_MODE);
      LogUtil.info(`${TAG} getWindowMode: ${windowMode}`);
      return windowMode;
    } catch (error) {
      LogUtil.error(`${TAG} getWindowMode catch exception, errmsg: ${error?.message}`);
    }
    return DEFAULT_MODE;
  }

  public registerDataChange(): void {
    if (this.dataHelper) {
      SettingsDataUtils.registerDataChange(this.dataHelper, WINDOW_MODE, this.onDataChange);
    } else {
      (SettingsDataUtils.createDataHelper(WINDOW_MODE) as Promise<dataShare.DataShareHelper>)
        .then((dataShareHelper?: dataShare.DataShareHelper) => {
          if (dataShareHelper) {
            this.dataHelper = dataShareHelper;
            SettingsDataUtils.registerDataChange(this.dataHelper, WINDOW_MODE,
              this.onDataChange);
          }
        });
    }
  }

  public unRegisterDataChange(): void {
    SettingsDataUtils.unRegisterDataChange(this.dataHelper, WINDOW_MODE);
  }
}
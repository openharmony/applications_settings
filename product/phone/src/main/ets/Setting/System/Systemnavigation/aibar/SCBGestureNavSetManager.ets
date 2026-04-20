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

/* instrument ignore file */
import fs from '@ohos.file.fs';
import { configPolicy } from '@kit.BasicServicesKit';
import { LogUtil } from '@ohos/settings.common/src/main/ets/utils/LogUtil';

const TAG = 'SCBGestureNavSetManager';
const SCB_GESTURE_NAV_SET_FILE_PATH = 'etc/scb_effect_config/gesture_navigation_setting.json';

interface GestureNavigationSet {
  sceneCode: string;
  supportFloatNavigation: string;
  supportFloatBall: string;
}

/**
 * SCBGestureNavSetManager
 *
 * @since 2025-02-22
 */
export class SCBGestureNavSetManager {
  private navBarSet: GestureNavigationSet | undefined;

  private static scbGestureNavSetManager: SCBGestureNavSetManager;

  /**
   * 获取单例
   */
  public static getInstance(): SCBGestureNavSetManager {
    if (SCBGestureNavSetManager.scbGestureNavSetManager) {
      return SCBGestureNavSetManager.scbGestureNavSetManager;
    }
    SCBGestureNavSetManager.scbGestureNavSetManager = new SCBGestureNavSetManager();
    return SCBGestureNavSetManager.scbGestureNavSetManager;
  }

  /**
   * 手势导航配置参数初始化
   */
  public init(): void {
    LogUtil.showInfo(TAG, 'loadScbVisualEffectConfigs');
    try {
      let configFile: string | undefined = configPolicy.getOneCfgFileSync(SCB_GESTURE_NAV_SET_FILE_PATH);
      if (!configFile) {
        LogUtil.showWarn(TAG, 'Can not find effect json path');
        return;
      }
      if (!fs.accessSync(configFile)) {
        LogUtil.showWarn(TAG, 'Can not access effect json file');
        return;
      }
      const effectJsonText: string = fs.readTextSync(configFile);
      if (!effectJsonText) {
        LogUtil.showWarn(TAG, 'effectJsonText is empty');
        return;
      }
      let navBarSetOnes: GestureNavigationSet[] = JSON.parse(effectJsonText) as GestureNavigationSet[];
      for (let navBarSetOnesElement of navBarSetOnes) {
        if (navBarSetOnesElement.sceneCode === '0') {
          this.navBarSet = navBarSetOnesElement;
        }
      }
    } catch (err) {
      LogUtil.showError(TAG, `Error on load effects file, error ${err.message}`);
    }
  }

  /**
   * 获取是否支持三键导航
   * @returns 是否支持三键导航
   */
  public getSupportFloatNavigation(): boolean {
    return this.navBarSet?.supportFloatNavigation !== 'false';
  }

  /**
   * 获取是否支持悬浮导航
   * @returns 是否支持悬浮导航
   */
  public getSupportFloatBall(): boolean {
    return this.navBarSet?.supportFloatBall === 'true';
  }
}
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
import { LogUtil } from '@ohos/settings.common/src/main/ets/utils/LogUtil';
import { ResourceUtil } from '@ohos/settings.common/src/main/ets/utils/ResourceUtil';
import { SettingsDataUtils } from '@ohos/settings.common/src/main/ets/utils/SettingsDataUtils';
import { ToastUtil } from '@ohos/settings.common/src/main/ets/utils/ToastUtil';
/* instrument ignore file */
import { settings } from '@kit.BasicServicesKit';

/**
 * 单手模式key
 */
const SINGLE_HAND_MODE_KEY: string = 'single_hand_mode';

/**
 * 单手模式value
 */
enum SingleHandMode {
  LEFT = 'left',
  MIDDLE = 'middle',
  RIGHT = 'right'
}

const TAG: string = 'SingleHandModeController';

/**
 * 单手模式监听类
 *
 * @since 2025-01-09
 */
export class SingleHandModeController {
  private static instance: SingleHandModeController;
  private isPageChecked = false;

  private constructor() {
    SettingsDataUtils.registerKeyObserverUser(SINGLE_HAND_MODE_KEY, () => {
      this.checkSingleHandleMode();
    });
  }

  /**
   * 获取监听类
   *
   * @returns 单手模式监听类
   */
  public static getInstance(): SingleHandModeController {
    if (!SingleHandModeController.instance) {
      SingleHandModeController.instance = new SingleHandModeController();
    }
    return SingleHandModeController.instance;
  }

  /**
   * 设置状态参数
   *
   * @param isPageChecked 页面是否检查单手模式
   */
  public setPageChecked(isPageChecked: boolean): void {
    this.isPageChecked = isPageChecked;
  }

  /**
   * 检查单手模式，并设置为全屏状态
   */
  public checkSingleHandleMode(): void {
    let handModeType: string =
      SettingsDataUtils.getSettingsData(SINGLE_HAND_MODE_KEY, SingleHandMode.MIDDLE, settings.domainName.USER_PROPERTY);
    LogUtil.info(`${TAG} singleHandMode is ${handModeType}`);
    if (handModeType !== SingleHandMode.MIDDLE && this.isPageChecked) {
      ResourceUtil.getString($r('app.string.fp_do_not_support_mini_screen_new')).then(value => {
        ToastUtil.showToast(value, ToastUtil.SHORT_DURATION);
      });
      SettingsDataUtils.setSettingsData(SINGLE_HAND_MODE_KEY, SingleHandMode.MIDDLE, settings.domainName.USER_PROPERTY);
    }
  }
}
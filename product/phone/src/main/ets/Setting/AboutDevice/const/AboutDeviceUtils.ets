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

import { DeviceUtil } from '@ohos/settings.common/src/main/ets/utils/BaseUtils';
import { SystemParamUtil } from '@ohos/settings.common/src/main/ets/utils/SystemParamUtil';

const BUILD_PRODUCT_PARAM_KEY: string = 'const.build.product';

/**
 * 关于本机工具
 *
 * @since 2024-08-08
 */
export class AboutDeviceUtils {
  /**
   * 获取关于本机菜单图标
   *
   * @returns 关于本机菜单图标
   */
  public static getAboutDeviceMenuIcon(): Resource {
    let result: Resource = $r('app.media.illustration_settings_mate60');
    if (DeviceUtil.isDevicePad()) {
      result = $r('app.media.ic_settings_matepad_svg');
    } else if (DeviceUtil.isFoldable()) {
      result = $r('app.media.ic_settings_matex5_svg');
    } else if (AboutDeviceUtils.isPura80()) {
      result = $r('app.media.ic_pura80');
    } else if (DeviceUtil.isSmallFoldProduct()) {
      result = $r('app.media.illustration_settings_mate60');
    }
    return result;
  }

  private static isPura80(): boolean {
    let product: string = SystemParamUtil.getParam(BUILD_PRODUCT_PARAM_KEY, '');
    return product === 'HED' || product === 'LMR' || product === 'LMU';
  }
}
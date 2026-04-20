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

import { SettingsDataUtils } from '@ohos/settings.common/src/main/ets/utils/SettingsDataUtils';
import { SystemParamUtil } from '@ohos/settings.common/src/main/ets/utils/SystemParamUtil';
import { MouseConstants } from './Constants';

export class Utils {
  private static readonly DEFAULT_ENABLE_MAGIC_CURSOR: string = 'true';

  public static isEnableMagicCursor(): boolean {
    return SystemParamUtil.getParam('const.settings.magic_cursor_enable',
      Utils.DEFAULT_ENABLE_MAGIC_CURSOR) === Utils.DEFAULT_ENABLE_MAGIC_CURSOR;
  }

  public static getSmartChangeState(): boolean {
    return SettingsDataUtils.getSettingsData(MouseConstants.MOUSE_MAGIC_VARIABLE, 'true') === 'true' ? true : false;
  }

  public static isEnableCircleCursor(): boolean {
    return SystemParamUtil.getParam('const.settings.enable_circular_cursor', 'true') === 'true';
  }
}
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

import Want from '@ohos.application.Want';
import { UIExtensionJumpController } from '@ohos/settings.common/src/main/ets/core/controller/MenuController';
import { NavigationEntry } from '../menus/Menu';

/**
 * 系统回退拉起参数
 */
export const SYSTEM_ROLLBACK_WANT: Want = {
  bundleName: 'com.ohos.ouc', // OUC bundleName
  abilityName: 'ServiceExtAbility', // ServiceExtAbility abilityName
  action: 'com.ohos.ouc.show_rollback',
  parameters: {
    'wantContent': 'rollback',
    'SubscribeInfo': { 'businessType': { 'subType': 3 } as Record<string, Object> } as Record<string, Object>,
  } as Record<string, Object>,
}

export const WIFI_HILINK_ICON: ResourceStr = $r('app.media.ic_wifi_hilink');

export const DETAIL_INFO_ICON: ResourceStr = $r('app.media.ic_public_detail');

export const MARGIN_16: string = '16vp';

export const MARGIN_8: string = '8vp';

export class ThemeConstant {
  /**
   * 主题包资源目录-基础目录
   */
  public static readonly BASE_DIR: string = 'base';
  /**
   * 主题包资源目录-横屏目录
   */
  public static readonly LAND_DIR: string = 'land';

  /**
   * 主题包资源目录-A/B目录
   */
  public static readonly FLAG_PATH_A: string = '/data/themes/a/app/flag';
  public static readonly SANDBOX_PATH_A: string = '/data/themes/a/system/home/';
  public static readonly SANDBOX_LOCK_PATH_A: string = '/data/themes/a/system/lock/';
  public static readonly FLAG_PATH_B: string = '/data/themes/b/app/flag';
  public static readonly SANDBOX_PATH_B: string = '/data/themes/b/system/home/';
  public static readonly SANDBOX_LOCK_PATH_B: string = '/data/themes/b/system/lock/';
}

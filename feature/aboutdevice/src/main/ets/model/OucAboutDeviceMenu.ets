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

import { BaseEntryMenuData } from '@ohos/settings.common/src/main/ets/core/model/menu/BaseMenu';
import { BaseStyle } from '@ohos/settings.common/src/main/ets/core/model/menu/ComponetStyle';
import { MenuType } from '@ohos/settings.common/src/main/ets/core/model/menu/MenuType';
import { SettingsBaseMenu } from '@ohos/settings.common/src/main/ets/core/model/menu/SettingsMenu';
/* instrument ignore file */
export class OucAboutDeviceStyle extends BaseStyle {
  public size: SizeOptions = {
    height: '100%'
  };

  public oucPreloadImgSize: SizeOptions = {
    height: '100%'
  };
}

export let oucAboutDeviceStyle = new OucAboutDeviceStyle();

/**
 * 关于本机OUC卡片目录
 *
 * @since 2024-03-29
 */
export class OucAboutDeviceMenu extends SettingsBaseMenu implements BaseEntryMenuData {
  constructor(menu?: Partial<BaseEntryMenuData>) {
    super(menu);
    if (!menu?.menuType) {
      this.menuType = MenuType.OUC_ABOUT_DEVICE;
    }
    this.style = oucAboutDeviceStyle;
  }
}
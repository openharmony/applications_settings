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

import { Controller } from '@ohos/settings.common/src/main/ets/core/controller/Controller';
import { LogUtil } from '@ohos/settings.common/src/main/ets/utils/LogUtil';
import { NavEntryKey } from '@ohos/settings.common/src/main/ets/utils/Consts';
import {
  PageLifecycleMenuGroupController,
} from '@ohos/settings.common/src/main/ets/core/controller/LifecycleMenuController';
import { SettingsBaseMenu } from '@ohos/settings.common/src/main/ets/core/model/menu/SettingsMenu';
import { PreferencesUtil } from '@ohos/settings.common/src/main/ets/utils/PreferencesUtil';
import { NavigationEntry, TitleTextStyle } from '@ohos/settings.uikit/src/main/ets/menus/Menu';
import { changePrivacySearchItem, getCredentials } from '../common/PrivacyPassword';
import { emitter } from '@kit.BasicServicesKit';
import { EVENT_ID_ON_WINDOW_STAGE_CHANGED_FOR_PRIVATE_PIN } from '@ohos/settings.common/src/main/ets/event/types';
import CommonEntryMenuStyle from '../../../model/CommonEntryMenuStyle';

/**
 * 蓝色文本样式
 *
 * @since 2024-11-14
 */
class BlueEntryMenuStyle extends CommonEntryMenuStyle {
  public title = new BlueTextStyle();
}

/**
 * 蓝色文本样式
 *
 * @since 2024-11-24
 */
class BlueTextStyle extends TitleTextStyle {
  public fontColor: ResourceColor = $r('sys.color.ohos_id_color_text_hyperlink');
}

/**
 * 隐私密码功能入口控制器
 *
 * @since 2024-11-24
 */
@Observed
export class PrivacyPasswordEntryController extends PageLifecycleMenuGroupController {
  public tag: string = 'PrivacyPasswordEntryController : ';
  private style?: CommonEntryMenuStyle;

  constructor(menu: SettingsBaseMenu) {
    super(menu);
    this.setVisible(false);
    this.style = new CommonEntryMenuStyle();
  }

  aboutToAppear(): void {
    super.aboutToAppear();
    this.refreshMenuGroupVisible();
    emitter.on({
      eventId: EVENT_ID_ON_WINDOW_STAGE_CHANGED_FOR_PRIVATE_PIN,
      priority: emitter.EventPriority.IMMEDIATE
    }, (event) => {
      this.refreshMenuGroupVisible();
    });
    changePrivacySearchItem();
  }

  aboutToDisappear(): void {
    super.aboutToDisappear();
    emitter.off(EVENT_ID_ON_WINDOW_STAGE_CHANGED_FOR_PRIVATE_PIN);
  }

  onPageShow(): void {
    this.refreshMenuGroupVisible();
  }

  async refreshMenuGroupVisible(): Promise<void> {
    LogUtil.info(`${this.tag} refreshMenuGroupVisible`);
    this.clearChildren();
    let addMenus: SettingsBaseMenu[] = [];
    const r = await getCredentials()
    const isAvailable = r.length > 0;
    this.addChildren(addMenus);
    this.setVisible(true);
    this.refreshUi();
  }
}
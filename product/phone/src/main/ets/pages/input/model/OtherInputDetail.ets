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

import { CardMenuSection, SwitchMenu } from '@ohos/settings.uikit/src/main/ets/menus/Menu';
import { ResourceUtil } from '@ohos/settings.common/src/main/ets/utils/ResourceUtil';
import { extraType } from '@ohos/settings.common/src/main/ets/core/model/menu/SettingsMenu';
import { SettingHeaderPage } from '@ohos/settings.uikit/src/main/ets/component/SettingHeaderPage';
import { OtherInputSwitch, SwitchListController } from '../controller/otherInputRadioController';
import { PageUrl } from '../../PageUrl';

/**
 * 三方输入法设置面数据
 *
 * @since 2023-12-07
 */
export class OtherInputDetail extends SettingHeaderPage {
  constructor(params: object | Object | extraType | undefined, title: string,) {
    super({
      pageUrl: PageUrl.OTHER_INPUT_DETAIL_SETTINGS,
      title,
      isNavigation: true,
      showHeader: false,
    });
    this.addMenus([
      new CardMenuSection(
        {
          key: 'automatic_update',
          index: 10,
          controller: {
            createControllerConstructorInter: SwitchListController.CreateSwitchListController,
          },
          extra: params
        },
        [
          new SwitchMenu(
            {
              key: 'input_switch_pc',
              index: 10,
              title: ResourceUtil.getStringSync($r('app.string.input_enable')) + title,
              controller: {
                createControllerConstructorInter: OtherInputSwitch.CreateOtherInputSwitch,
              },
              extra: params
            }
          )
        ]
      )
    ]);
  }
}
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

import { MenuGroup } from '@ohos/settings.common/src/main/ets/core/model/menu/SettingsMenu';
import { ButtonMenu } from '@ohos/settings.uikit/src/main/ets/menus/Menu';
import { PushParam } from '@ohos/settings.common/src/main/ets/core/controller/Controller';
import { SettingHeaderPage } from '@ohos/settings.uikit/src/main/ets/component/SettingHeaderPage';
import { PageUrl } from '../../PageUrl';
import { PowerConsumptionPageController } from '../controller/PowerConsumptionPageController';
import { EndRunButtonController } from '../controller/EndRunButtonController';

/**
 * 应用耗电详情页菜单页数据
 *
 * @since 2024-01-05
 */
export class PowerConsumptionPage extends SettingHeaderPage {
  constructor(pathInfos: NavPathStack, params: PushParam) {
    super({
      pageUrl: PageUrl.POWER_CONSUMPTION_PAGE_URL,
      controller: {
        createControllerConstructorInter: PowerConsumptionPageController.CreatePowerConsumptionPageController,
      },
      showHeader: false,
      isNavigation: true,
      pathInfos: pathInfos,
      navRouterParam: params,
    });
    this.setFooter(this.buildSaveButtonMenu(params));
  }

  private buildSaveButtonMenu(params: PushParam): MenuGroup {
    return new MenuGroup(
      {
        key: 'key_save_button_group',
        index: 0,
      },
      [
        new ButtonMenu({
          key: 'key_save_button',
          index: 0,
          buttonTittle3: $r('app.string.battery_end_run'),
          pathInfos: this.pathInfos,
          controller: {
            createControllerConstructorInter: EndRunButtonController.CreateEndRunButtonController,
          },
          navRouterParam: params,
        }),
      ]
    );
  }
}
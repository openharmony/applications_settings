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

import { CardMenuSection, EntryMenu, SubHeaderSection } from '@ohos/settings.uikit';
import { PageUrl } from '../../PageUrl';
import { PushParam } from '@ohos/settings.common/src/main/ets/core/controller/Controller';
import {
  SettingHeaderPage,
  SettingHeaderPageStyle
} from '@ohos/settings.uikit/src/main/ets/component/SettingHeaderPage';
import { DefaultInputController, InputSettingController } from '../controller/inputSettingController';
import {
  DefaultListStyle,
  PrivacySingleChoiceMenuStyle,
  SingleChoiceEntryMenu
} from '@ohos/settings.uikit/src/main/ets/menus/Menu';

class DefaultInputChoiceMenuStyle extends PrivacySingleChoiceMenuStyle {
  public menuItemWidth: Length = $r('app.float.width_216');
}

class InputSettingListStyle extends DefaultListStyle {
  public borderRadius = $r('sys.float.corner_radius_level8');
}

let inputSettingListStyle = new InputSettingListStyle();

class InputSettingStyle extends SettingHeaderPageStyle {
  public listStyle = inputSettingListStyle;
}

/**
 * 输入法详情页
 */
export class InputSetting extends SettingHeaderPage {
  constructor(pathInfos: NavPathStack, params: PushParam) {
    super({
      pageUrl: PageUrl.INPUT_PAGE_URL,
      title: $r('app.string.input'),
      isNavigation: true,
      showHeader: false,
      style: new InputSettingStyle()
    });
    // index 用于菜单排序
    this.addMenus([
      new SubHeaderSection(
        {
          key: 'action_group_01',
          index: 10,
          title: $r('app.string.input_manager'),
        },
        [
          new SingleChoiceEntryMenu(
            {
              key: 'other_input_settings',
              index: 20,
              style: new DefaultInputChoiceMenuStyle(),
              selectIcon: $r('app.media.ic_selected'),
              stateIcon: $r('app.media.ic_arrow_down'),
              title: $r('app.string.input_default'),
              controller: {
                createControllerConstructorInter: DefaultInputController.createDefaultInputController,
              },
            }
          ),
        ]
      ),
      new CardMenuSection(
        {
          key: 'input_group_list',
          index: 30,
          controller: {
            createControllerConstructorInter: InputSettingController.InputSettingController,
          },
          pathInfos: pathInfos,
        }
      ),
    ]);
  }
}

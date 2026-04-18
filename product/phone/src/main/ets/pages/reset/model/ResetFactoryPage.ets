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

import {
  ButtonMenu,
  ButtonMenuContainerStyle,
  DefaultButtonMenuStyle,
  DefaultButtonStyle,
  DefaultStateMenuStyle,
  StateMenu,
  SubHeaderSection,
  TitleTextStyle
} from '@ohos/settings.uikit/src/main/ets/menus/Menu';
import { MenuGroup } from '@ohos/settings.common/src/main/ets/core/model/menu/SettingsMenu';
import { DeviceUtil } from '@ohos/settings.common/src/main/ets/utils/BaseUtils';
import { ResourceUtil } from '@ohos/settings.common/src/main/ets/utils/ResourceUtil';
import { SystemParamUtil } from '@ohos/settings.common/src/main/ets/utils/SystemParamUtil';
import { MenuType } from '@ohos/settings.common/src/main/ets/core/model/menu/MenuType';
import { PushParam } from '@ohos/settings.common/src/main/ets/core/controller/Controller';
import { SettingHeaderPage } from '@ohos/settings.uikit/src/main/ets/component/SettingHeaderPage';
import { FontScaleUtils } from '@ohos/settings.common/src/main/ets/utils/FontScaleUtils';
import { TabIndexConstants } from '@ohos/settings.common/src/main/ets/constant/TabIndexConstants';
import { CheckEmptyUtils } from '@ohos/settings.common/src/main/ets/utils/CheckEmptyUtils';
import { PageUrl } from '../../PageUrl';
import { ResetFactoryAccountController } from '../controller/ResetFactoryAccountController';
import { ResetFactoryButtonController } from '../controller/ResetFactoryButtonController';

const MAX_LINES_50: number = 50;
const DISALLOW_RESET_FACTORY_PARAM_KEY: string = 'persist.edm.reset_factory_disallowed';

export class ResetTitleTextStyle extends TitleTextStyle {
  public fontColor: ResourceColor = $r('sys.color.ohos_id_color_text_hint');
  public font: Font = {
    size: $r('sys.float.ohos_id_text_size_sub_title2'),
    weight: FontWeight.Medium,
  };
  public margin: Margin = {
    top: '16vp',
    bottom: '16vp',
  };
}

class ResetTitleMenuStyle extends DefaultStateMenuStyle {
  public title = new ResetTitleTextStyle();
}

export class ResetContentTextStyle extends TitleTextStyle {
  public fontColor: ResourceColor = $r('sys.color.ohos_id_color_text_secondary');
  public font: Font = {
    size: $r('sys.float.ohos_id_text_size_body2'),
    weight: FontWeight.Medium,
  };
  public maxLines = MAX_LINES_50;
  public margin: Margin = {
    bottom: '16vp',
  };
}

class ResetContentMenuStyle extends DefaultStateMenuStyle {
  public title = new ResetContentTextStyle();
}

class ResetButtonStyle extends DefaultButtonStyle {
  public size: SizeOptions = {
    width: FontScaleUtils.isExtraLargeFontMode() ? '90%' : '184vp',
    height: 'auto',
  };
  public padding: Padding = {
    top: FontScaleUtils.getButtonTopPadding(),
    bottom: FontScaleUtils.getButtonTopPadding(),
  };
  public margin: Margin = {
    top: '16vp',
    bottom: '16vp'
  };
}

class ButtonMenuStyle extends ButtonMenuContainerStyle {
  public margin: Margin = {
    top: FontScaleUtils.isExtraLargeFontMode() ? '16vp' : 0
  };
}

class ResetButtonMenuStyle extends DefaultButtonMenuStyle {
  public buttonStyle1 = new ResetButtonStyle();
  public rootContainer = new ButtonMenuStyle();
}

/**
 * 恢复出厂页界面数据
 *
 * @since 2022-10-13
 */
export class ResetFactoryPage extends SettingHeaderPage {
  public declare pathInfos: NavPathStack;
  constructor(pathInfos: NavPathStack, params: PushParam) {
    super({
      pageUrl: PageUrl.RESET_FACTORY_PAGE_URL,
      title: DeviceUtil.isDevicePhone() ? $r('app.string.reset_factory_title') : $r('app.string.reset_factory_title_pc'),
      isNavigation: true,
      showHeader: false,
    });
    this.pathInfos = pathInfos;
    this.addMenus([
      new StateMenu(
        {
          key: 'reset_factory_detail_title',
          index: 10,
          focusable: false,
          style: new ResetTitleMenuStyle(),
          title: $r('app.string.reset_factory_detail_title'),
        }
      ),
      new StateMenu(
        {
          key: 'reset_factory_detail_content',
          index: 20,
          focusable: false,
          style: new ResetContentMenuStyle(),
          title: this.getDetailContent(ResourceUtil.getStringSync($r('app.string.reset_factory_detail_content'))),
          menuType: MenuType.PARAGRAPH,
        }
      ),
      new SubHeaderSection(
        {
          key: 'reset_account_group',
          index: 30,
          title: $r('app.string.reset_account_group_title'),
          controller: {
            createControllerConstructorInter: ResetFactoryAccountController.CreateResetFactoryAccountController,
          },
        },
        []),
    ]);

    let isResetFactoryDisallowed = SystemParamUtil.getParam(DISALLOW_RESET_FACTORY_PARAM_KEY, 'false') === 'true';
    this.setFooter(
      new MenuGroup(
        {
          key: 'reset_factory_button_group',
          index: 0,
        },
        [
          new ButtonMenu(
            {
              key: 'reset_factory_button',
              index: 40,
              tabIndex: TabIndexConstants.TAB_INDEX_LEVEL2_PAGE,
              buttonTittle1: DeviceUtil.isDevicePhone() ? $r('app.string.reset_factory_button_text') : $r('app.string.reset_factory_button_text_pc'),
              controller: {
                createControllerConstructorInter: ResetFactoryButtonController.CreateResetFactoryButtonController,
              },
              pathInfos: this.pathInfos,
              style: new ResetButtonMenuStyle(),
              isGrayed: isResetFactoryDisallowed,
              stateEffect: !isResetFactoryDisallowed
            }
          )
        ]
      )
    );
  }

  private getDetailContent(content: string): string {
    if (!content) {
      return '';
    }
    let contents: string[] = content.split('\n');
    if (CheckEmptyUtils.isEmpty(contents)) {
      return '';
    }
    contents.pop();
    contents.pop();
    return contents.join('\n') + '\n';
  }
}

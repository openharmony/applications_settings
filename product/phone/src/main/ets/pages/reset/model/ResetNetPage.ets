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

import i18n from '@ohos.i18n';
import {
  ButtonMenu,
  DefaultButtonMenuStyle,
  DefaultButtonStyle,
  DefaultStateMenuStyle,
  StateMenu,
  SubHeaderSection,
  TitleTextStyle,
} from '@ohos/settings.uikit/src/main/ets/menus/Menu';
import { MenuGroup } from '@ohos/settings.common/src/main/ets/core/model/menu/SettingsMenu';
import { Style } from '@ohos/settings.common/src/main/ets/core/model/menu/ComponetStyle';
import { ResourceUtil } from '@ohos/settings.common/src/main/ets/utils/ResourceUtil';
import { MenuType } from '@ohos/settings.common/src/main/ets/core/model/menu/MenuType';
import { PushParam } from '@ohos/settings.common/src/main/ets/core/controller/Controller';
import { CapabilitySupportUtils } from '@ohos/settings.common/src/main/ets/utils/CapabilitySupportUtils';
import { SettingHeaderPage } from '@ohos/settings.uikit/src/main/ets/component/SettingHeaderPage';
import { FontScaleUtils } from '@ohos/settings.common/src/main/ets/utils/FontScaleUtils';
import { TabIndexConstants } from '@ohos/settings.common/src/main/ets/constant/TabIndexConstants';
import { PageUrl } from '../../PageUrl';
import { ResetNetButtonController } from '../controller/ResetNetButtonController';
import { ResetNetSimController } from '../controller/ResetNetSimController';

const MAX_LINES_50: number = 50;

export class ResetTitleTextStyle extends TitleTextStyle {
  public fontColor: ResourceColor = $r('sys.color.ohos_id_color_text_hint');
  public font: Font = {
    size: $r('sys.float.ohos_id_text_size_sub_title2'),
    weight: FontWeight.Medium,
  };
  public margin: Margin = {
    top: '24vp',
    bottom: '24vp',
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

class ResetNetButtonStyle extends DefaultButtonStyle {
  public size: SizeOptions = {
    height: 'auto',
  };
  public constraintSize?: ConstraintSizeOptions | undefined = {
    minWidth : '184vp',
  };
  public padding: Padding = {
    top: FontScaleUtils.getButtonTopPadding(),
    bottom: FontScaleUtils.getButtonTopPadding(),
  };
  public maxLines?: number | undefined = 2;
  public margin: Margin = {
    top: '16vp',
    bottom: '16vp'
  };
}

class ResetNetButtonStyle1 extends ResetNetButtonStyle {
  public size: SizeOptions = {
    height: 'auto',
  };
  public constraintSize?: ConstraintSizeOptions | undefined = {
    minWidth : '220vp',
  };
}

class ResetNetButtonMenuStyle extends DefaultButtonMenuStyle {
  public buttonStyle1 = (i18n.System.getSystemLanguage()
    .indexOf('zh-Hans') >= 0) ? new ResetNetButtonStyle() : new ResetNetButtonStyle1();
}

/**
 * Reset network settings
 *
 * @author yudenggao
 * @since 2023-08-29
 */
export class ResetNetPage extends SettingHeaderPage {

  constructor(pathInfos: NavPathStack, params: PushParam) {
    super({
      pageUrl: PageUrl.RESET_NET_PAGE_URL,
      title: $r('app.string.reset_net_title'),
      isNavigation: true,
      showHeader: false,
    });
    this.pathInfos = pathInfos;
    this.addMenus([
      new SubHeaderSection(
        {
          key: 'reset_sim_card',
          index: 10,
          title: $r('app.string.reset_sim_card_title'),
          controller: {
            createControllerConstructorInter: ResetNetSimController.CreateResetNetSimController,
          },
        },
        []),
      new StateMenu(
        {
          key: 'reset_net_detail_title',
          index: 20,
          focusable: false,
          style: new ResetTitleMenuStyle() as Style,
          title: $r('app.string.reset_net_detail_title'),
        }
      ),
      new StateMenu(
        {
          key: 'reset_net_detail_content',
          index: 30,
          focusable: false,
          style: new ResetContentMenuStyle() as Style,
          title: CapabilitySupportUtils.isSupportNearLink() ?
            ResourceUtil.getStringSync($r('app.string.reset_net_detail_content_with_nearlink')) :
            ResourceUtil.getStringSync($r('app.string.reset_net_detail_content')),
          menuType: MenuType.PARAGRAPH,
        }
      ),
    ]);

    this.setFooter(
      new MenuGroup(
        {
          key: 'reset_net_button',
          index: 0,
        },
        [
          new ButtonMenu(
            {
              key: 'reset_net_button',
              index: 40,
              tabIndex: TabIndexConstants.TAB_INDEX_LEVEL2_PAGE,
              buttonTittle1: $r('app.string.reset_net_title'),
              controller: {
                createControllerConstructorInter: ResetNetButtonController.CreateResetNetButtonController,
              },
              pathInfos: this.pathInfos,
              style: new ResetNetButtonMenuStyle() as Style,
            }
          )
        ])
    );
  }
}

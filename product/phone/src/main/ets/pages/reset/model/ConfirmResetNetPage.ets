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
  DefaultStateMenuStyle,
  StateMenu,
  TitleTextStyle,
  WarningButtonMenuStyle,
  WarningButtonStyle,
} from '@ohos/settings.uikit/src/main/ets/menus/Menu';
import { MenuGroup } from '@ohos/settings.common/src/main/ets/core/model/menu/SettingsMenu';
import { Style } from '@ohos/settings.common/src/main/ets/core/model/menu/ComponetStyle';
import { FontScaleUtils } from '@ohos/settings.common/src/main/ets/utils/FontScaleUtils';
import { TabIndexConstants } from '@ohos/settings.common/src/main/ets/constant/TabIndexConstants';
import { SettingHeaderPage } from '@ohos/settings.uikit/src/main/ets/component/SettingHeaderPage';
import { PageUrl } from '../../PageUrl';
import { ResetNetController } from '../controller/ResetNetController';

export class ConfirmTitleTextStyle extends TitleTextStyle {
  public fontColor: ResourceColor = $r('sys.color.ohos_id_color_text_hint');
  public font: Font = {
    size: $r('sys.float.ohos_id_text_size_sub_title2'),
    weight: FontWeight.Medium,
  };
  public margin: Margin = {
    top: '24vp',
    bottom: '24vp'
  };
  public maxLines = 30;
}

class ConfirmStateMenuStyle extends DefaultStateMenuStyle {
  public title = new ConfirmTitleTextStyle();
}

class ResetNetButtonStyle extends WarningButtonStyle {
  public padding: Padding = {
    top: FontScaleUtils.getButtonTopPadding(),
    bottom: FontScaleUtils.getButtonTopPadding(),
  };
  public size: SizeOptions = {
    height: 'auto',
  };
  public constraintSize?: ConstraintSizeOptions | undefined = {
    minWidth : '184vp',
    minHeight: '40vp'
  };
  public fontColor: ResourceColor = $r('sys.color.ohos_id_color_warning');
  public maxLines?: number | undefined = 2;
}

class ResetNetButtonStyle1 extends ResetNetButtonStyle {
  public size: SizeOptions = {
    height: 'auto',
  };
  public constraintSize?: ConstraintSizeOptions | undefined = {
    minWidth : '220vp',
    minHeight: '40vp'
  };
  public fontColor: ResourceColor = $r('sys.color.ohos_id_color_warning');
}

class ConfirmButtonMenuStyle extends WarningButtonMenuStyle {
  public buttonStyle3 = (i18n.System.getSystemLanguage()
    .indexOf('zh-Hans') >= 0) ? new ResetNetButtonStyle() : new ResetNetButtonStyle1();
}

/**
 * Confirm reset network settings page
 *
 * @author yudenggao
 * @since 2023-08-29
 */
export class ConfirmResetNetPage extends SettingHeaderPage {
  constructor() {
    super({
      pageUrl: PageUrl.CONFIRM_RESET_NET_PAGE_URL,
      title: $r('app.string.reset_net_title'),
      isNavigation: true,
      showHeader: false,
    });
    this.addMenus([
      new StateMenu(
        {
          key: 'reset_net_detail_title',
          index: 10,
          focusable: false,
          style: new ConfirmStateMenuStyle() as Style,
          title: $r('app.string.confirm_reset_net_content'),
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
              key: 'confirm_reset_net_button',
              index: 20,
              tabIndex: TabIndexConstants.TAB_INDEX_LEVEL2_PAGE,
              buttonTittle3: $r('app.string.reset_net_title'),
              style: new ConfirmButtonMenuStyle() as Style,
              controller: {
                createControllerConstructorInter: ResetNetController.CreateResetNetController,
              },
            }
          )
        ])
    );
  }
}

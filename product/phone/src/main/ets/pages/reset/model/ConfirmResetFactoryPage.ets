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

import { ResetFactoryController } from '@ohos/settings.reset/src/main/ets/controller/ResetFactoryController';
import {
  ButtonMenu,
  DefaultStateMenuStyle,
  StateMenu,
  TitleTextStyle,
  WarningButtonMenuStyle,
  WarningButtonStyle
} from '@ohos/settings.uikit/src/main/ets/menus/Menu';
import { DeviceUtil } from '@ohos/settings.common/src/main/ets/utils/BaseUtils';
import { MenuGroup } from '@ohos/settings.common/src/main/ets/core/model/menu/SettingsMenu';
import { Style } from '@ohos/settings.common/src/main/ets/core/model/menu/ComponetStyle';
import { SettingHeaderPage } from '@ohos/settings.uikit/src/main/ets/component/SettingHeaderPage';
import { FontScaleUtils } from '@ohos/settings.common/src/main/ets/utils/FontScaleUtils';
import { TabIndexConstants } from '@ohos/settings.common/src/main/ets/constant/TabIndexConstants';
import { PageUrl } from '../../PageUrl';

/* instrument ignore file */
export class ConfirmTitleTextStyle extends TitleTextStyle {
  public fontColor: ResourceColor = $r('sys.color.ohos_id_color_text_secondary');
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

class ResetFactoryButtonStyle extends WarningButtonStyle {
  public size: SizeOptions = {
    width: DeviceUtil.isSupportEsim() || FontScaleUtils.isExtraLargeFontMode() ? '90%' : '184vp',
    height: 'auto',
  };
  public padding: Padding = {
    top: FontScaleUtils.getButtonTopPadding(),
    bottom: FontScaleUtils.getButtonTopPadding(),
  };
  public margin: Margin = {
    bottom: $r('app.float.margin_24'),
  };
  public fontColor: ResourceColor = $r('sys.color.ohos_id_color_warning');
}

class ResetFactoryMenuStyle extends WarningButtonMenuStyle {
  public buttonStyle1 = new ResetFactoryButtonStyle();
  public buttonStyle2 = new ResetFactoryButtonStyle();
  public buttonStyle3 = new ResetFactoryButtonStyle();
}

/**
 * 恢复出厂确认页界面数据
 *
 * @since 2022-10-13
 */
export class ConfirmResetFactoryPage extends SettingHeaderPage {
  constructor() {
    super({
      pageUrl: PageUrl.RESET_FACTORY_PAGE_URL,
      title: DeviceUtil.isDevicePhone() ? $r('app.string.reset_factory_button_text') :
      $r('app.string.reset_factory_button_text_pc'),
      isNavigation: true,
      showHeader: false,
    });
    this.addMenus([
      new StateMenu(
        {
          key: 'reset_factory_detail_title',
          index: 10,
          focusable: false,
          style: new ConfirmStateMenuStyle() as Style,
          title: DeviceUtil.isDevicePhone() && DeviceUtil.isSupportEsim() ?
          $r('app.string.confirm_reset_factory_with_esim_content') : $r('app.string.confirm_reset_factory_content'),
        }
      ),
    ]);

    this.setFooter(this.buildResetMenuGroup());
  }

  private buildResetMenuGroup(): MenuGroup {
    const menuGroup = new MenuGroup({
      key: 'confirm_reset_factory_button_group',
      index: 0,
    });
    if (DeviceUtil.isDevicePhone() && DeviceUtil.isSupportEsim()) {
      menuGroup.addMenus([
        new ButtonMenu(
          {
            key: 'confirm_reset_all_factory_button',
            index: 20,
            tabIndex: TabIndexConstants.TAB_INDEX_LEVEL2_PAGE,
            buttonTittle1: $r('app.string.reset_all_factory_button_text'),
            style: new ResetFactoryMenuStyle() as Style,
            controller: {
              createControllerConstructorInter: ResetFactoryController.CreateResetFactoryController,
            }
          }
        ),
        new ButtonMenu(
          {
            key: 'confirm_reset_retain_esim_factory_button',
            index: 30,
            tabIndex: TabIndexConstants.TAB_INDEX_LEVEL2_PAGE,
            buttonTittle2: $r('app.string.reset_retain_esim_factory_button_text'),
            style: new ResetFactoryMenuStyle() as Style,
            controller: {
              createControllerConstructorInter: ResetFactoryController.CreateResetFactoryController,
            }
          }
        )
      ]);
    } else {
      menuGroup.addMenus([
        new ButtonMenu(
          {
            key: 'confirm_reset_factory_button',
            index: 10,
            tabIndex: TabIndexConstants.TAB_INDEX_LEVEL2_PAGE,
            buttonTittle3: DeviceUtil.isDevicePhone() ? $r('app.string.reset_factory_button_text') :
            $r('app.string.reset_factory_button_text_pc'),
            style: new ResetFactoryMenuStyle() as Style,
            controller: {
              createControllerConstructorInter: ResetFactoryController.CreateResetFactoryController,
            }
          }
        ),
      ]);
    }
    return menuGroup;
  }
}

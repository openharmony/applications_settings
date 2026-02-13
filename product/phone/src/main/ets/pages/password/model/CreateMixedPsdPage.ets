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

import { DeviceUtil } from '@ohos/settings.common/src/main/ets/utils/BaseUtils';
import { MenuGroup } from '@ohos/settings.common/src/main/ets/core/model/menu/SettingsMenu';
import { PushParam } from '@ohos/settings.common/src/main/ets/core/controller/Controller';
import { PasswordManager } from '@ohos/settings.common/src/main/ets/passwordManager/PasswordManager';
import {
  ButtonMenu,
  DefaultStateMenuStyle,
  RootContainerStyle,
  TitleTextStyle,
  PasswordUnderLineTextInputMenu,
  StateMenu
} from '@ohos/settings.uikit/src/main/ets/menus/Menu';
import { CreatePsdPage } from './CreatePsdPage';
import {
  CreateMixedPsdPageController,
  MixedPsdMessageController,
  MixedPsdInputController,
  MixedPsdWarningMessageController,
  MixedPsdSubmitButtonController,
  MixedPsdChangeTypeController,
} from '../controller/CreateMixedPsdController';
import {
  MixedPsdInputMenuStyle,
  ChangeTypeButtonMenuStyle,
  CreatePsdButtonMenuStyleForPad,
  CreatePsdButtonMenuStyle,
} from './CreateNumberPsdPage';
import { PasswordMessageMenuStyle, RememberPinWarningMenuStyle } from './CreateSixPinPage';
import { PageUrl } from '../../PageUrl';

/* instrument ignore file */
export const MIXED_PSD_INPUT_KEY: string = 'mixed_psd_input_key';
export const MIXED_PSD_SUBMIT_BUTTON: string = 'mixed_psd_submit_button';
export const MIXED_PSD_WARNING_TITLE: string = 'mixed_psd_warning_title';

/**
 * edm策略密码强度提示文本样式
 */
class EdmPasswordMessageTextStyle extends TitleTextStyle {
  public font: Font = {
    size: $r('sys.float.Subtitle_M'),
    weight: FontWeight.Medium,
  };
  public margin: Margin = {
    top: $r('app.float.margin_24'),
    bottom: $r('app.float.margin_24'),
  };
  public textAlign: TextAlign = TextAlign.Start;
}

/**
 * edm策略密码强度提示文本布局
 */
export class EdmPasswordContainer extends RootContainerStyle {
  public justifyContent: FlexAlign = FlexAlign.Center;
  public padding: Padding = {
    left: $r('app.float.padding_8'),
    right: $r('app.float.padding_8'),
    top: $r('app.float.margin_0'),
    bottom: $r('app.float.margin_0'),
  };
}

/**
 * edm策略密码强度提示文本框风格
 */
export class EdmPasswordMessageMenuStyle extends DefaultStateMenuStyle {
  public title = new EdmPasswordMessageTextStyle();
  public rootContainer = new EdmPasswordContainer();
}

/**
 * 创建混合锁屏密码界面
 *
 * @since 2023-01-16
 */
export class CreateMixedPsdPage extends CreatePsdPage {
  constructor(pathInfos: NavPathStack, params: PushParam) {
    super({
      pageUrl: PageUrl.CREATE_MIXED_PSD_PAGE_URL,
      controller: {
        createControllerConstructorInter: CreateMixedPsdPageController.CreateCreateMixedPsdPageController,
      },
      isNavigation: true,
      scrollable: false,
      showHeader: false,
      navRouterParam: params,
    });
    this.addMenus([
      new StateMenu(
        {
          key: 'mixed_password_message_title',
          index: 10,
          style: PasswordManager.hasEdmPolicy() ? new EdmPasswordMessageMenuStyle() : new PasswordMessageMenuStyle(),
          accessibilityDescription: ' ',
          controller: {
            createControllerConstructorInter: MixedPsdMessageController.CreateMixedPsdMessageController,
          },
          navRouterParam: params,
          focusable: false,
        }
      ),
      new PasswordUnderLineTextInputMenu(
        {
          key: MIXED_PSD_INPUT_KEY,
          index: 20,
          hint: $r('app.string.wifi_password_input_hint'),
          style: new MixedPsdInputMenuStyle(),
          controller: {
            createControllerConstructorInter: MixedPsdInputController.CreateMixedPsdInputController,
          },
        }
      ),
      new StateMenu(
        {
          key: MIXED_PSD_WARNING_TITLE,
          index: 30,
          style: new RememberPinWarningMenuStyle(),
          accessibilityDescription: ' ',
          controller: {
            createControllerConstructorInter: MixedPsdWarningMessageController.CreateMixedPsdWarningMessageController,
          },
          focusable: false,
          navRouterParam: params,
        }
      ),
      new ButtonMenu(
        {
          key: 'mixed_psd_change_type_button',
          index: 40,
          buttonTittle1: $r('app.string.change_unlock_method'),
          controller: {
            createControllerConstructorInter: MixedPsdChangeTypeController.CreateMixedPsdChangeTypeController,
          },
          style: new ChangeTypeButtonMenuStyle(),
          pathInfos: pathInfos,
          navRouterParam: params,
        }
      )
    ]);
    this.setFooter(
      new MenuGroup(
        {
          key: 'mixed_password_button_group',
          index: 0,
        },
        [
          new ButtonMenu(
            {
              key: MIXED_PSD_SUBMIT_BUTTON,
              index: 0,
              buttonTittle1: $r('app.string.dialog_cancel'),
              buttonTittle3: $r('app.string.dialog_continue'),
              controller: {
                createControllerConstructorInter: MixedPsdSubmitButtonController.CreateMixedPsdSubmitButtonController,
              },
              pathInfos: pathInfos,
              navRouterParam: params,
              style: DeviceUtil.isDevicePad() ? new CreatePsdButtonMenuStyleForPad() : new CreatePsdButtonMenuStyle()
            }
          )
        ]
      )
    );
  }
}
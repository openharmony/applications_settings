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

import { ButtonMenu } from '@ohos/settings.uikit/src/main/ets/menus/Menu';
import { ButtonMenuContainerStyle } from '@ohos/settings.uikit/src/main/ets/menus/Menu';
import { CreatePsdPage } from './CreatePsdPage';
import {
  CreateNumberPsdPageController,
  NumberPsdMessageController,
  NumberPsdInputController,
  NumberPsdWarningMessageController,
  NumberPsdSubmitButtonController,
  NumberPsdChangeTypeController,
} from '../controller/CreateNumberPsdController';
import { DeviceUtil } from '@ohos/settings.common/src/main/ets/utils/BaseUtils';
import { DefaultButtonMenuStyle } from '@ohos/settings.uikit/src/main/ets/menus/Menu';
import { DefaultButtonStyle } from '@ohos/settings.uikit/src/main/ets/menus/Menu';
import { MenuGroup } from '@ohos/settings.common/src/main/ets/core/model/menu/SettingsMenu';
import { NUMBER_PSD_MAX_LENGTH_EXT } from '../controller/CreateNumberPsdController';
import { PasswordUnderLineTextInputMenu } from '@ohos/settings.uikit/src/main/ets/menus/Menu';
import { PasswordMessageMenuStyle, RememberPinWarningMenuStyle } from './CreateSixPinPage';
import { PushParam } from '@ohos/settings.common/src/main/ets/core/controller/Controller';
import { PageUrl } from '../../PageUrl';
import { StateMenu } from '@ohos/settings.uikit/src/main/ets/menus/Menu';
import { TransparentButtonStyle } from '@ohos/settings.uikit/src/main/ets/menus/Menu';
import { TransparentButtonMenuStyle } from '@ohos/settings.uikit/src/main/ets/menus/Menu';
import { UnderLineTextInputMenuStyle } from '@ohos/settings.uikit/src/main/ets/menus/Menu';
import { UnderLineTextInputStyle } from '@ohos/settings.uikit/src/main/ets/menus/Menu';

/* instrument ignore file */
export const NUMBER_PSD_INPUT_KEY: string = 'number_psd_input_key';
export const NUMBER_PSD_SUBMIT_BUTTON: string = 'number_psd_submit_button';
export const NUMBER_PSD_WARNING_TITLE: string = 'number_psd_warning_title';

/**
 * 自定义数字密码输入框样式
 *
 * @since 2023-01-14
 */

export class NumberPsdInputStyle extends UnderLineTextInputStyle {
  public inputType = InputType.NUMBER_PASSWORD;
  public maxLength = NUMBER_PSD_MAX_LENGTH_EXT;
}

export class NumberPsdInputMenuStyle extends UnderLineTextInputMenuStyle {
  public textInputStyle = new NumberPsdInputStyle();
}

export class MixedPsdInputStyle extends UnderLineTextInputStyle {
  public inputType = InputType.Password;
  public maxLength = NUMBER_PSD_MAX_LENGTH_EXT;
}

export class MixedPsdInputMenuStyle extends UnderLineTextInputMenuStyle {
  public textInputStyle = new MixedPsdInputStyle();
}

/**
 * 切换密码类型按钮样式
 *
 * @since 2023-01-14
 */
export class ChangeTypeButtonStyle extends TransparentButtonStyle {
  public margin :Margin = {
    top: '8vp',
    bottom: '16vp',
  };
  public maxLines?: number | undefined = 2;
}

export class ChangeTypeButtonMenuStyle extends TransparentButtonMenuStyle {
  public buttonStyle1 = new ChangeTypeButtonStyle();
}

export class CreatePsdButton1ForPad extends DefaultButtonStyle {
  public gridSpan: number = 3;
  public gridOffset: number = 1;
}

export class CreatePsdButton3ForPad extends DefaultButtonStyle {
  public gridSpan: number = 3;
  public gridOffset: number = 4;
}

export class CreatePsdButtonMenuStyleForPad extends DefaultButtonMenuStyle {
  public rootContainer = new CreatePsdButtonContainerStyleForPad();
  public buttonStyle1 = new CreatePsdButton1ForPad();
  public buttonStyle3 = new CreatePsdButton3ForPad();
}

export class CreatePsdButtonContainerStyleForPad extends ButtonMenuContainerStyle {
  public gridColumns: number = 8;
}

export class CreatePsdButtonContainerStyle extends ButtonMenuContainerStyle {
  public gridMargin: Length = '8vp';
}

export class CreatePsdButtonMenuStyle extends DefaultButtonMenuStyle {
  public rootContainer = new CreatePsdButtonContainerStyle();
}

/**
 * 创建自定义数字锁屏密码界面
 *
 * @since 2023-01-14
 */
export class CreateNumberPsdPage extends CreatePsdPage {
  constructor(pathInfos: NavPathStack, params: PushParam) {
    super({
      pageUrl: PageUrl.CREATE_NUMBER_PSD_PAGE_URL,
      controller: {
        createControllerConstructorInter: CreateNumberPsdPageController.CreateCreateNumberPsdPageController,
      },
      isNavigation: true,
      pathInfos: pathInfos,
      navRouterParam: params,
      showHeader: false,
      scrollable: false,
    });
    this.addMenus([
      new StateMenu(
        {
          key: 'number_password_message_title',
          index: 10,
          style: new PasswordMessageMenuStyle(),
          accessibilityDescription: ' ',
          controller: {
            createControllerConstructorInter: NumberPsdMessageController.CreateNumberPsdMessageController,
          },
          navRouterParam: params,
          focusable: false,
        }
      ),
      new PasswordUnderLineTextInputMenu(
        {
          key: NUMBER_PSD_INPUT_KEY,
          index: 20,
          hint: $r('app.string.wifi_password_input_hint'),
          style: new NumberPsdInputMenuStyle(),
          controller: {
            createControllerConstructorInter: NumberPsdInputController.CreateNumberPsdInputController,
          },
        }
      ),
      new StateMenu(
        {
          key: NUMBER_PSD_WARNING_TITLE,
          index: 30,
          accessibilityDescription: ' ',
          style: new RememberPinWarningMenuStyle(),
          controller: {
            createControllerConstructorInter: NumberPsdWarningMessageController.CreateNumberPsdWarningMessageController,
          },
          focusable: false,
          navRouterParam: params,
        }
      ),
      new ButtonMenu(
        {
          key: 'number_psd_change_type_button',
          index: 40,
          buttonTittle1: $r('app.string.change_unlock_method'),
          controller: {
            createControllerConstructorInter: NumberPsdChangeTypeController.CreateNumberPsdChangeTypeController,
          },
          style: new ChangeTypeButtonMenuStyle(),
          pathInfos: this.pathInfos,
          navRouterParam: params,
        }
      )
    ]);
    this.setFooter(
      new MenuGroup(
        {
          key: 'number_password_button_group',
          index: 0,
        },
        [
          new ButtonMenu(
            {
              key: NUMBER_PSD_SUBMIT_BUTTON,
              index: 50,
              buttonTittle1: $r('app.string.dialog_cancel'),
              buttonTittle3: $r('app.string.dialog_continue'),
              controller: {
                createControllerConstructorInter: NumberPsdSubmitButtonController.CreateNumberPsdSubmitButtonController,
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

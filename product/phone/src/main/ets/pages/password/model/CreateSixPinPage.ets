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
import { ChangeTypeButtonMenuStyle } from './CreateNumberPsdPage';
import { CreatePsdPage, CREATE_PASSWORD_ENTRY_FACE_FLAG, CREATE_PASSWORD_ENTRY_FLAG } from './CreatePsdPage';
import { CheckPsdParams } from './CheckPasswordPage';
import { DefaultStateMenuStyle } from '@ohos/settings.uikit/src/main/ets/menus/Menu';
import { PasswordCircleMenu } from '@ohos/settings.uikit/src/main/ets/menus/Menu';
import { PasswordCircleMenuStyle } from '@ohos/settings.uikit/src/main/ets/menus/Menu';
import { PasswordCircleContainerStyle } from '@ohos/settings.uikit/src/main/ets/menus/Menu';
import { RootContainerStyle } from '@ohos/settings.uikit/src/main/ets/menus/Menu';
import { PushParam } from '@ohos/settings.common/src/main/ets/core/controller/Controller';
import { PageUrl } from '../../PageUrl';
import {
  CreateSixPinPageController,
  SixPinCircleController,
  SixPinMessageController,
  SixPinWarningMessageController,
  SixPinChangeTypeController,
} from '../controller/CreateSixPinController';
import { ResourceUtil } from '@ohos/settings.common/src/main/ets/utils/ResourceUtil';
import { StateMenu } from '@ohos/settings.uikit/src/main/ets/menus/Menu';
import { TitleTextStyle } from '@ohos/settings.uikit/src/main/ets/menus/Menu';
import { TabIndexConstants } from '@ohos/settings.common/src/main/ets/constant/TabIndexConstants';

/* instrument ignore file */
export const SIX_PIN_CIRCLE_KEY: string = 'six_pin_circle_key';
export const SIX_PIN_WARNING_TITLE: string = 'six_pin_warning_title';
const MARGIN_0: number = 0;
const MARGIN_12: number = 12;
const MSG_INDEX_6: string = '6';
/**
 * 密码输入信息文本样式
 *
 * @since 2023-01-10
 */
class PasswordMessageTextStyle extends TitleTextStyle {
  public font: Font = {
    size: $r('sys.float.ohos_id_text_size_sub_title2'),
    weight: FontWeight.Medium,
  };
  public margin: Margin = {
    top: '24vp',
    bottom: '24vp',
  };
  public size :SizeOptions = {
    width: '100%',
  };
  public textAlign: TextAlign = TextAlign.Center;
}

/**
 * 密码输入信息菜单样式
 *
 * @since 2023-01-10
 */
export class PasswordMessageMenuStyle extends DefaultStateMenuStyle {
  public title = new PasswordMessageTextStyle();
  public rootContainer = new PasswordContainer();
}

export class PasswordContainer extends RootContainerStyle {
  public padding: Padding = {
    left: $r('app.float.padding_8'),
    right: $r('app.float.padding_8'),
    top: $r('app.float.margin_0'),
    bottom: $r('app.float.margin_0'),
  };
}

/**
 * 忘记密码警告文本样式
 *
 * @since 2023-01-10
 */
class RememberPinWarningTextStyle extends TitleTextStyle {
  public font: Font = {
    size: $r('sys.float.ohos_id_text_size_sub_title3'),
    weight: FontWeight.Medium,
  };
  public size :SizeOptions = {
    width: '100%',
  };
  public textAlign: TextAlign = TextAlign.Center;
  public fontColor: ResourceColor = $r('sys.color.ohos_id_color_warning');
}

/**
 * 忘记密码警告菜单样式
 *
 * @since 2023-01-10
 */
export class RememberPinWarningMenuStyle extends DefaultStateMenuStyle {
  public rootContainer = new PasswordContainer();
  public title = new RememberPinWarningTextStyle();
}

/**
 * 创建锁屏密码圆圈根布局样式
 *
 * @since 2023-01-17
 */
class CreatePinCircleContainerStyle extends PasswordCircleContainerStyle {
  public margin :Margin = {
    top: MARGIN_0,
    bottom: MARGIN_12,
    left: MARGIN_0,
    right: MARGIN_0,
  };
}

/**
 * 创建锁屏密码圆圈样式
 *
 * @since 2023-01-17
 */
export class CreatePinCircleMenuStyle extends PasswordCircleMenuStyle {
  public rootContainer = new CreatePinCircleContainerStyle();
}

/**
 * 创建6位数字锁屏密码界面
 *
 * @since 2023-01-10
 */
export class CreateSixPinPage extends CreatePsdPage {
  public pathInfos: NavPathStack;
  constructor(pathInfos: NavPathStack, params: PushParam) {
    super({
      pageUrl: PageUrl.CREATE_SIX_PIN_PAGE_URL,
      controller: {
        createControllerConstructorInter: CreateSixPinPageController.CreateCreateSixPinPageController,
      },
      isNavigation: true,
      showHeader: false,
      scrollable: false,
      navRouterParam: params,
    });
    this.pathInfos = pathInfos;
    this.addMenus([
      new StateMenu(
        {
          key: 'six_password_message_title',
          index: 10,
          style: new PasswordMessageMenuStyle(),
          title: this.updatePasswordMessage(),
          accessibilityDescription: ' ',
          controller: {
            createControllerConstructorInter: SixPinMessageController.CreateSixPinMessageController,
          },
          navRouterParam: params,
          focusable: false,
        }
      ),
      new PasswordCircleMenu(
        {
          key: SIX_PIN_CIRCLE_KEY,
          index: 20,
          tabIndex: TabIndexConstants.TAB_INDEX_LEVEL2_PAGE,
          style: new CreatePinCircleMenuStyle(),
          controller: {
            createControllerConstructorInter: SixPinCircleController.CreateSixPinCircleController,
          },
          pathInfos: pathInfos,
          navRouterParam: params,
        }
      ),
      new StateMenu(
        {
          key: SIX_PIN_WARNING_TITLE,
          index: 30,
          style: new RememberPinWarningMenuStyle(),
          accessibilityDescription: ' ',
          controller: {
            createControllerConstructorInter: SixPinWarningMessageController.CreateSixPinWarningMessageController,
          },
          focusable: false,
          navRouterParam: params,
        }
      ),
      new ButtonMenu(
        {
          key: 'six_pin_change_type_button',
          tabIndex: TabIndexConstants.TAB_INDEX_LEVEL2_PAGE,
          index: 40,
          buttonTittle1: $r('app.string.change_unlock_method'),
          controller: {
            createControllerConstructorInter: SixPinChangeTypeController.CreateSixPinChangeTypeController,
          },
          style: new ChangeTypeButtonMenuStyle(),
          pathInfos: this.pathInfos,
          navRouterParam: params,
        }
      )
    ]);
  }

  private updatePasswordMessage(): string {
    let params = this.navRouterParam?.config;
    let message: string = '';
    let sourceFlag: string = '';
    if (params) {
      sourceFlag = (params as CheckPsdParams).source;
    }
    if (sourceFlag === CREATE_PASSWORD_ENTRY_FLAG) {
      message = ResourceUtil.getStringSync($r('app.string.fingerprint_new_pin_message'));
    } else if (sourceFlag === CREATE_PASSWORD_ENTRY_FACE_FLAG) {
      message = ResourceUtil.getStringSync($r('app.string.face_new_pin_message'));
    } else {
      message = ResourceUtil.getNumberFormatStringSync($r('app.string.pin_password_message'), MSG_INDEX_6);
    }
    return message;
  }
}
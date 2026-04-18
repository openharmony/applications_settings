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

import { SystemParamUtil } from '@ohos/settings.common/src/main/ets/utils/SystemParamUtil';
import { PushParam } from '@ohos/settings.common/src/main/ets/core/controller/Controller';
import { ContainerStyle } from '@ohos/settings.common/src/main/ets/core/model/menu/ComponetStyle';
import { SettingsBaseMenu } from '@ohos/settings.common/src/main/ets/core/model/menu/SettingsMenu';
import { AccountUtil } from '@ohos/settings.common/src/main/ets/utils/AccountUtil';
import { EnableUtils } from '@ohos/settings.common/src/main/ets/utils/baseutils/EnableUtils';
import { FontScaleUtils } from '@ohos/settings.common/src/main/ets/utils/FontScaleUtils';
import { LogUtil } from '@ohos/settings.common/src/main/ets/utils/LogUtil';
import { Style } from '@ohos/settings.commonUikit/src/main/ets/InputStyle';
import { SettingHeaderPage } from '@ohos/settings.uikit/src/main/ets/component/SettingHeaderPage';
import { DeviceUtil } from '@ohos/settings.common/src/main/ets/utils/BaseUtils';
import {
  CardMenuSection,
  CardSectionStyle,
  DefaultEntryMenuStyle,
  DefaultStateMenuStyle,
  NavigationEntry,
  PasswordTipTextMenu,
  SubHeaderSection,
  SwitchMenu,
  TitleTextStyle,
  CardSectionListStyle,
} from '@ohos/settings.uikit/src/main/ets/menus/Menu';
import { GroupStyle } from '@ohos/settings.common/src/main/ets/core/model/menu/ComponetStyle';
import { EntryMenuStyle } from '@ohos/settings.common/src/main/ets/core/model/menu/BaseMenu';
import { PageUrl } from '../../PageUrl';
import {
  ChangePasswordEntryController,
  ClosePasswordEntryController,
  DisableOldPasswordDialogController,
  DisableOldPasswordEntryController,
  GROUP_CLOSE_AND_CHANGE_LOCK_SCREEN_PASSWORD,
  GROUP_DISABLE_OLD_LOCK_SCREEN_PASSWORD,
  GROUP_DISABLE_OLD_LOCK_SCREEN_PASSWORD_TIP,
  GROUP_LOCK_SCREEN_PASSWORD,
  PasswordEntryController,
  SetPasswordEntryController
} from '../../password/controller/PasswordEntryController';
import { MenuGroup } from '@ohos/settings.common/src/main/ets/core/model/menu/SettingsMenu';
import CommonEntryMenuStyle from './CommonEntryMenuStyle';

/* instrument ignore file */
export const LOCK_SCREEN_PASSWORD_KEY: string = 'lock_screen_password_title';

const CHANGE_LOCK_SCREEN_PASSWORD_KEY: string = 'change_lock_screen_password_title';

export const CLOSE_LOCK_SCREEN_PASSWORD_KEY: string = 'close_lock_screen_password_title';

export const DISABLE_OLD_LOCK_SCREEN_PASSWORD_KEY: string = 'disable_old_lock_screen_password_title';

export const DEFAULT_PADDING_START: Length = $r('sys.float.ohos_id_default_padding_start');

export const DEFAULT_PADDING_END: Length = $r('sys.float.ohos_id_default_padding_end');

/**
 * 关闭锁屏密码入口菜单-蓝色文本样式
 *
 * @since 2022-05-28
 */
class BlueEntryMenuStyle extends CommonEntryMenuStyle {
  public title = new BlueTextStyle();
}

/**
 * 关闭锁屏密码入口菜单-蓝色文本样式
 *
 * @since 2022-05-28
 */
class BlueTextStyle extends TitleTextStyle {
  public fontColor: ResourceColor = $r('sys.color.ohos_id_color_text_hyperlink');
}

/**
 * 立即使旧密码过期入口菜单-红色文本样式
 *
 * @since 2025-06-10
 */
class WarningEntryMenuStyle extends CommonEntryMenuStyle {
  public title = new WarningTextStyle();
}

/**
 * 立即使旧密码过期入口菜单-红色文本样式
 *
 * @since 2025-06-10
 */
class WarningTextStyle extends TitleTextStyle {
  public fontColor: ResourceColor = $r('sys.color.ohos_id_color_warning');
}

/**
 * 立即使旧密码过期提示-黑色文本样式
 *
 * @since 2025-02-08
 */
class WarningTipEntryMenuStyle extends DefaultEntryMenuStyle {
  public title = new WarningTipTextStyle();
}

/**
 * 立即使旧密码过期提示-黑色文本样式
 *
 * @since 2025-06-10
 */
class WarningTipTextStyle extends TitleTextStyle {
  public fontColor: ResourceColor = $r('sys.color.font_secondary');
  public font: Font = {
    size: $r('sys.float.Body_M'),
    weight: FontWeight.Regular,
    family: 'HarmonyHeiTi'
  };
  public padding: Padding = {
    top: '0vp',
    bottom: '0vp',
    left: '4vp',
    right: '4vp',
  };
}

/**
 * 密码倒计时警告文本样式
 *
 * @since 2023-01-14
 */
export class CountDownDialogMessageStyle extends DefaultStateMenuStyle {
  public title: TextStyle = new CountDownMessageTextStyle();
  public rootContainer: ContainerStyle = new CountDownMessageContainerStyle();
}

/**
 * 密码倒计时警告文本样式
 *
 * @since 2023-01-14
 */

class CountDownMessageContainerStyle extends ContainerStyle {
  public size: SizeOptions = {
    width: '100%',
  };
  public constraintSize?: ConstraintSizeOptions | undefined = {
    minHeight: '100vp'
  }
  public margin: Margin = {
    top: '66vp',
    bottom: '0vp',
  };
}

class CountDownMessageTextStyle extends TitleTextStyle {
  public fontColor: ResourceColor = $r('sys.color.font_emphasize');
  public font: Font = {
    size: $r('sys.float.ohos_id_text_size_body1'),
    weight: FontWeight.Medium,
  };
  public size: SizeOptions = {
    width: '100%',
  };
  public constraintSize?: ConstraintSizeOptions | undefined = {
    minHeight: '48vp'
  }
  public overflow: TextOverflow = TextOverflow.Ellipsis;
  public maxLines = 5;
  public padding: Padding = {
    left: '24vp',
    right: '24vp',
    top: FontScaleUtils.isExtraLargeFontMode() ? FontScaleUtils.getCurrentTopPadding() : '0vp',
    bottom: FontScaleUtils.isExtraLargeFontMode() ? FontScaleUtils.getCurrentTopPadding() : '0vp',
  };
  public textAlign: TextAlign = TextAlign.Center;
  public borderRadius: Length = 10;
}

/**
 * 生物识别和密码界面
 *
 * @since 2023-01-07
 */
export class BiometricsAndPasswordPage extends SettingHeaderPage {
  private tag: string = 'BiometricsAndPasswordPage: ';
  private cardStyle?: GroupStyle;
  private entryStyle?: EntryMenuStyle;

  constructor(pathInfos: NavPathStack, params: PushParam) {
    super({
      pageUrl: PageUrl.BIOMETRICS_AND_PASSWORD_PAGE_URL,
      title: $r('app.string.biometrics_and_password_settings_title'),
      isNavigation: true,
      showHeader: false,
      scrollable: false
    });
    this.initStyle();
    this.initMenus(pathInfos, params);
  }

  private initStyle(): void {
    this.cardStyle = new CardSectionStyle();
    this.cardStyle.listStyle = new CardSectionListStyle();
    this.cardStyle.listStyle.borderRadius = $r('sys.float.corner_radius_level10');
    this.entryStyle = new CommonEntryMenuStyle();
  }

  private async initMenus(pathInfos: NavPathStack, params: PushParam): Promise<void> {
    LogUtil.info(`${this.tag} start init`);
    const isCurrentPrivateUser = await AccountUtil.isCurrentPrivate();
    LogUtil.info(`${this.tag} isCurrentPrivateUser ${isCurrentPrivateUser}`);
    if (SystemParamUtil.isSimulatorMode) {
      this.addMenus([
        this.addLockPsdMenu(pathInfos, params),
        this.addChangeOrClosePsdMenu(pathInfos, params, isCurrentPrivateUser)
      ]);
    } else {
      this.addMenus([
        this.addLockPsdMenu(pathInfos, params),
        this.addChangeOrClosePsdMenu(pathInfos, params, isCurrentPrivateUser),
        this.addDisableOldPsdMenu(pathInfos, params)
      ]);
    }

    const PRODUCT_MODEL: string = 'const.product.model';
    const PRODUCT_MODEL_EMULATOR: string = 'emulator';
    let productModel: string = SystemParamUtil.getParam(PRODUCT_MODEL, '');
    this.refreshUi();
    EnableUtils.setItemEnable(this);
  }

  private addLockPsdMenu(pathInfos: NavPathStack, params: PushParam): SettingsBaseMenu {
    return new CardMenuSection(
      {
        key: GROUP_LOCK_SCREEN_PASSWORD,
        index: 300,
        controller: {
          createControllerConstructorInter: PasswordEntryController.CreatePasswordEntryController,
        },
        style: this.cardStyle
      },
      [
        new NavigationEntry(
          {
            key: LOCK_SCREEN_PASSWORD_KEY,
            index: 50,
            tabIndex: 102,
            title: $r('app.string.lock_screen_password_title'),
            symbolIcon: $r('sys.symbol.chevron_right'),
            controller: {
              createControllerConstructorInter: SetPasswordEntryController.CreateSetPasswordEntryController,
            },
            pathInfos: pathInfos,
            navRouterParam: params,
            style: this.entryStyle
          },
        ),
      ],
    );
  }

  private addChangeOrClosePsdMenu(pathInfos: NavPathStack, params: PushParam, isCurrentPrivateUser: boolean):
    SettingsBaseMenu {
    let changePsdEntry: SettingsBaseMenu = new NavigationEntry(
      {
        key: CHANGE_LOCK_SCREEN_PASSWORD_KEY,
        index: 60,
        tabIndex: 102,
        title: $r('app.string.change_lock_screen_password_title'),
        symbolIcon: $r('sys.symbol.chevron_right'),
        controller: {
          createControllerConstructorInter: ChangePasswordEntryController.CreateChangePasswordEntryController,
        },
        pathInfos: pathInfos,
        navRouterParam: params,
        style: this.entryStyle
      },
    );

    let closePsdEntry: SettingsBaseMenu = new NavigationEntry(
      {
        key: CLOSE_LOCK_SCREEN_PASSWORD_KEY,
        index: 70,
        title: $r('app.string.close_lock_screen_password_title'),
        style: new BlueEntryMenuStyle(),
        controller: {
          createControllerConstructorInter: ClosePasswordEntryController.CreateClosePasswordEntryController,
        },
        pathInfos: pathInfos,
        navRouterParam: params,
      },
    );
    let menus: SettingsBaseMenu[] = [changePsdEntry];
    if (!isCurrentPrivateUser) {
      menus.push(closePsdEntry);
    }
    return new SubHeaderSection(
      {
        key: GROUP_CLOSE_AND_CHANGE_LOCK_SCREEN_PASSWORD,
        index: 400,
        controller: {
          createControllerConstructorInter: PasswordEntryController.CreatePasswordEntryController,
        },
        title: $r('app.string.password_title'),
        style: this.cardStyle
      }, menus);
  }

  private addDisableOldPsdMenu(pathInfos: NavPathStack, params: PushParam): SettingsBaseMenu {
    let disableOldPsdMenu = new CardMenuSection(
      {
        key: GROUP_DISABLE_OLD_LOCK_SCREEN_PASSWORD,
        index: 450,
        controller: {
          createControllerConstructorInter: DisableOldPasswordEntryController.CreateDisableOldPasswordEntryController,
        },
        style: this.cardStyle
      },
      [
        new NavigationEntry(
          {
            key: DISABLE_OLD_LOCK_SCREEN_PASSWORD_KEY,
            index: 80,
            tabIndex: 102,
            title: $r('app.string.expire_pre_password_or_pin_title'),
            style: new WarningEntryMenuStyle(),
            controller: {
              createControllerConstructorInter:
                DisableOldPasswordDialogController.CreateDisableOldPasswordDialogController,
            },
            pathInfos: pathInfos,
            navRouterParam: params,
          },
        )
      ],
    );
    disableOldPsdMenu.setFooter(new MenuGroup({
      key: GROUP_DISABLE_OLD_LOCK_SCREEN_PASSWORD_TIP,
      index: 1000,
    }, [new PasswordTipTextMenu(
      {
        key: GROUP_DISABLE_OLD_LOCK_SCREEN_PASSWORD_TIP,
        index: 90,
        tabIndex: 102,
        style: new WarningTipEntryMenuStyle(),
        controller: {
          createControllerConstructorInter: DisableOldPasswordEntryController.CreateDisableOldPasswordEntryController,
        },
        pathInfos: pathInfos,
        navRouterParam: params,
      },
    )]));
    return disableOldPsdMenu;
  }
}

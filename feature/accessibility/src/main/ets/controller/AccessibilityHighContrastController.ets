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

import config from '@ohos.accessibility.config';
import {
  ButtonMenuController,
  SwitchMenuController
} from '@ohos/settings.common/src/main/ets/core/controller/MenuController';
import { SettingsBaseMenu } from '@ohos/settings.common/src/main/ets/core/model/menu/SettingsMenu';
import { LogUtil } from '@ohos/settings.common/src/main/ets/utils/LogUtil';
import { Controller } from '@ohos/settings.common/src/main/ets/core/controller/Controller';
import { HiSysEventUtil } from '@ohos/settings.common/src/main/ets/systemEvent/HiSysEventUtil';
import { HiSysAccessibilityEventGroup } from '@ohos/settings.common/src/main/ets/systemEvent/BehaviorEventConsts';
import {
  ButtonMenu,
  DefaultButtonMenuStyle,
  DefaultDialogPageStyle,
  DialogMessageMenu,
  DialogMessageStyle,
  DialogMessageTextStyle,
  DialogPage,
  DialogPageData,
  DialogTitleMenu,
  DialogTitleMenuStyle,
  PageTitleContainerStyle,
  PageTitleTextStyle,
  TransparentButtonStyle
} from '@ohos/settings.uikit/src/main/ets/menus/Menu';
import { BusinessError } from '@ohos.base';
import uiAppearance from '@ohos.uiAppearance';
import { ContainerStyle } from '@ohos/settings.common/src/main/ets/core/model/menu/ComponetStyle';

import { AccessibilitySettingModel } from '../model/AccessibilitySettingModel';
/* instrument ignore file */
const TAG: string = 'AccessibilityHighContrastController : ';
const MAX_LINES_10: number = 10;

/**
 * 无障碍高对比度控制器
 *
 * @since 2023-06-01
 */
export class AccessibilityHighContrastController extends SwitchMenuController {
  public dialogPageInfo: Partial<DialogPageData> = {
    pageUrl: 'pages/accessibility/HighContrastText',
    title: 'high_contrast_text',
    style: new DefaultDialogPageStyle(),
  };
  private detailDialogPage: DialogPage = new HighContrastDialogPage(this.dialogPageInfo);

  static CreateAccessibilityHighContrastController(menu: SettingsBaseMenu): Controller {
    return new AccessibilityHighContrastController(menu);
  }

  private static switchState: boolean = true;
  public highContrastTextState: boolean;

  constructor(menu: SettingsBaseMenu) {
    super(menu);
    this.highContrastTextState = menu?.extra as boolean;
  }

  /**
   * 返回开关的实时状态
   */
  public updateStatus(): void {
    this.setChecked(this.highContrastTextState);
    super.updateStatus();
  }

  /**
   * 开关变化的回调
   */
  protected handleCheckedChange(isChecked: boolean): boolean {
    LogUtil.info(`${TAG} handleCheckedChange isChecked: ${isChecked}`);
    AccessibilityHighContrastController.switchState = isChecked;
    if (isChecked) {
      if (AccessibilityHighContrastController.isDarkModeOn()) {
        this.handleDarkMode();
        return false;
      }
      AccessibilitySettingModel.accessibilityConfigSetting('highContrastText', true);
    } else {
      AccessibilitySettingModel.accessibilityConfigSetting('highContrastText', false);
    }
    return true;
  }

  public onPageShow(): void {
    LogUtil.info(`${TAG} onPageShow success`);
    this.updateStatus();
  }

  public getObserverKey = (): string => {
    return this.menu?.key as string;
  }

  public onPageHide(): void {
    LogUtil.info(`${TAG} onPageHide success`);
  }

  /**
   * 监听开关的实时状态
   */
  protected registerDataChange(): void {
    try {
      config.highContrastText.on((data) => {
        if (AccessibilityHighContrastController.switchState === data) {
          HiSysEventUtil.reportDefaultBehaviorEventByUE(
            HiSysAccessibilityEventGroup.HIGH_CONTRAST_TEXT_SWITCH, data ? 'on' : 'off');
          AccessibilityHighContrastController.switchState = !data;
        }
        this.highContrastTextState = data;
        LogUtil.info(`${TAG} highContrastText state change`);
        this.updateStatus();
      });
    } catch (err) {
      LogUtil.error(`${TAG} failed subscribe highContrastText, because ${err?.message}`);
    }
  }

  /**
   * 取消监听开关的实时状态
   */
  protected unRegisterDataChange(): void {
    LogUtil.info(`${TAG} unRegisterDataChange`);
    try {
      config.highContrastText.off(() => {
        LogUtil.info(`${TAG} Register highContrastText state change off`);
      });
    } catch (err) {
      LogUtil.error(`${TAG} failed unsubscribe highContrastText, because ${err?.message}`);
    }
  }

  /**
   * 深色模式是否已打开
   * @returns true: 已开启深色模式
   */
  static isDarkModeOn(): boolean {
    return uiAppearance.getDarkMode() === uiAppearance.DarkMode.ALWAYS_DARK;
  }

  /**
   * 关闭深色模式
   */
  static setDarkModeOff(): void {
    uiAppearance.setDarkMode(uiAppearance.DarkMode.ALWAYS_LIGHT).then(() => {
      LogUtil.info(`${TAG} succeed to set dark mode.`);
    }).catch((err: BusinessError) => {
      LogUtil.error(`${TAG} Failed to set dark mode. Cause: ${err.code}`);
    });
  }

  private handleDarkMode(): void {
    config.highContrastText.get().then((isHighContrastOn) => {
      LogUtil.info(`${TAG} highContrastText get status: ${isHighContrastOn}`);
      if (isHighContrastOn) {
        // 通过辅助功能快捷键开启时，不弹窗，直接关深色模式
        AccessibilityHighContrastController.setDarkModeOff();
      } else {
        this.openDialog(this.detailDialogPage, true);
      }
    })
  }
}

export class DialogTitleStyle extends PageTitleTextStyle {
  public font: Font = {
    size: $r('sys.float.Title_S'),
    weight: FontWeight.Bold,
  };
  public margin: Margin = {
    top: $r('app.float.length_15'),
    bottom: $r('app.float.length_15'),
  };
  public fontColor: ResourceColor = $r('sys.color.font_primary');
  public justifyContent: FlexAlign = FlexAlign.Center;
  public overflow: TextOverflow = TextOverflow.None;
  public maxLines: number = MAX_LINES_10;
}

export class HighContrastTitleMenuStyle extends DialogTitleMenuStyle {
  public rootContainer?: ContainerStyle = new PageTitleContainerStyle();
  public title?: TextStyle = new DialogTitleStyle();
}

class HighContrastMessageContainerStyle extends PageTitleContainerStyle {
  public size: SizeOptions = {
    width: '100%',
  };
  public justifyContent: FlexAlign = FlexAlign.Center;
  public overflow: TextOverflow = TextOverflow.None;
}

export class HighContrastMessageStyle extends DialogMessageTextStyle {
  public font: Font = {
    size: $r('sys.float.Body_L'),
    weight: FontWeight.Regular,
  };
  public fontColor: ResourceColor = $r('sys.color.font_primary');
}

export class HighContrastMessageMenuStyle extends DialogMessageStyle {
  public rootContainer?: ContainerStyle = new HighContrastMessageContainerStyle();
  public title?: TextStyle = new HighContrastMessageStyle();
}

export class HighContrastContainerStyle extends ContainerStyle {
  public size: SizeOptions = {
    width: '100%',
  };
  public gridGutter: Length = '16vp';
  public gridMargin: Length = '4vp';
}

class HighContrastButtonStyle extends TransparentButtonStyle {
  public margin: Margin = {
    top: $r('app.float.length_8'),
    bottom: $r('app.float.border_radius_16'),
  };
  public size: SizeOptions = {
    width: '100%',
  };
  public constraintSize: ConstraintSizeOptions = {
    minHeight: $r('app.float.height_40'),
  };
  public font: Font = {
    size: $r('sys.float.Body_L'),
    weight: FontWeight.Medium,
  };
}

export class ConfirmDeleteButtonMenuStyle extends DefaultButtonMenuStyle {
  public rootContainer = new HighContrastContainerStyle();
  public buttonStyle1 = new HighContrastButtonStyle(); // 左侧取消按钮
  public buttonStyle2 = new HighContrastButtonStyle(); // 右侧开启按钮
}

/**
 * 深色模式与高对比度文字互斥弹窗
 *
 * @since 2024-07-04
 */
export class HighContrastDialogPage extends DialogPage {
  constructor(params: Partial<DialogPageData>) {
    super(params);
    this.initDialog();
  }

  /**
   * 初始化高对比度文字和深色模式互斥弹窗的内部界面
   */
  private initDialog() {
    this.addMenus([
      new DialogTitleMenu({
        key: 'high_contrast_dialog_title',
        index: 10,
        title: $r('app.string.high_contrast_dialog_title'),
        style: new HighContrastTitleMenuStyle(),
      }),
      new DialogMessageMenu(
        {
          key: 'high_contrast_dialog_message',
          index: 20,
          title: $r('app.string.confirm_close_dark_mode_content'),
          style: new HighContrastMessageMenuStyle(),
        }
      ),
      new ButtonMenu({
        key: 'high_contrast_confirm_button',
        index: 30,
        menuType: 'A11yDivideButton',
        buttonTittle1: $r('app.string.dialog_cancel'),
        buttonTittle2: $r('app.string.dialog_enable'),
        style: new ConfirmDeleteButtonMenuStyle(),
        controller: {
          createControllerConstructorInter: HighContrastDialogController.CreateController,
        },
        pathInfos: this.pathInfos,
      })
    ]);
  }
}

/**
 * 高对比度文字弹窗控制器
 *
 * @since 2024-07-04
 */
@Observed
export class HighContrastDialogController extends ButtonMenuController {
  public tag: string = 'HighContrastDialogController : ';

  constructor(menu: SettingsBaseMenu) {
    super(menu);
    if (!menu.style) {
      menu.style = new ConfirmDeleteButtonMenuStyle();
    }
  }

  static CreateController(menu: SettingsBaseMenu): Controller {
    return new HighContrastDialogController(menu);
  }

  /**
   * 点击取消按钮回调
   */
  onButton1Click(): void {
    LogUtil.info(`${this.tag} cancel Button Click`);
    super.onButton1Click();
    this.closeSelf();
  }

  /**
   * 点击开启按钮回调
   */
  onButton2Click(): void {
    LogUtil.info(`${this.tag} enable Button Click`);
    AccessibilityHighContrastController.setDarkModeOff();
    AccessibilitySettingModel.accessibilityConfigSetting('highContrastText', true);
    this.closeSelf();
  }
}
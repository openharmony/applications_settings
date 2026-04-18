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
  DialogButtonMenuController,
  RadioMenuController
} from '@ohos/settings.common/src/main/ets/core/controller/MenuController';
import { MenuGroup, SettingsBaseMenu } from '@ohos/settings.common/src/main/ets/core/model/menu/SettingsMenu';
import { LogUtil } from '@ohos/settings.common/src/main/ets/utils/LogUtil';
import { Controller } from '@ohos/settings.common/src/main/ets/core/controller/Controller';
import { SettingsDataUtils } from '@ohos/settings.common/src/main/ets/utils/SettingsDataUtils';
import { DialogLifecycleObserverInterface } from '@ohos/settings.common/src/main/ets/core/lifecycle/Lifecycle';
import { hasOwnPropertyCall } from '@ohos/settings.common/src/main/ets/utils/ObjectPrototypeUtil';
import { ConfigurationBaseController } from './ConfigurationBaseController';
import { ConfigurationConstant } from '../ConfigurationConstant';
import {
  ButtonMenu,
  DialogPage,
  DialogTitleMenu,
  DividerMenuGroup,
  RadioMenu,
  TransparentButtonMenuStyle,
  TransparentButtonStyle,
} from '../../menus/Menu';
/* instrument ignore file */
class MarginValue {
  public top: string = '';
  public bottom: string = '';
}

class CancelButtonStyle extends TransparentButtonStyle {
  public margin: MarginValue = { top: '8vp', bottom: '16vp', };
}

class CancelButtonMenuStyle extends TransparentButtonMenuStyle {
  public buttonStyle1 = new CancelButtonStyle();
}

const TAG: string = 'ConfigurationRadioController : ';

/**
 * 配置文件解析--单选菜单控制器
 *
 * @since 2023-08-21
 */


export default class ConfigurationRadioController extends ConfigurationBaseController
implements DialogLifecycleObserverInterface {
  private detailDialogPage: DialogPage = new DialogPage({
    title: this.menu.title,
  });
  private dialogTitleMenu?: DialogTitleMenu;
  private buttonMenu?: ButtonMenu;
  private dividerMenuGroup?: DividerMenuGroup;
  private radioList: SelectOption[] = [];

  static CreateConfigurationRadioController(menu: SettingsBaseMenu): Controller {
    return new ConfigurationRadioController(menu);
  }

  async aboutToAppear(): Promise<void> {
    LogUtil.info(`${TAG} aboutToAppear`);
    this.dialogTitleMenu = new DialogTitleMenu(
      {
        key: this.menu.title + '_dialog_menu',
        index: ConfigurationConstant.MENU_INDEX,
        title: this.menu.title,
      }
    );

    this.buttonMenu = new ButtonMenu(
      {
        key: 'radio_cancel_button',
        index: ConfigurationConstant.BUTTON_CANCEL_MENU_INDEX,
        buttonTittle1: $r('app.string.cancel'),
        controller: {
          createControllerConstructorInter: DialogButtonMenuController.CreateDialogButtonMenuController,
        },
        style: new CancelButtonMenuStyle(),
      }
    );

    this.dividerMenuGroup = new DividerMenuGroup(
      {
        key: this.menu.title + '_divider_group',
        index: ConfigurationConstant.DIVIDER_MENU_INDEX,
      },
      this.generateRadioMenu()
    );
    super.aboutToAppear();
  }

  private generateRadioMenu(): Array<RadioMenu> | undefined {
    if (!this.menu.extra) {
      LogUtil.error(`${TAG} menu extra is null}`)
      return undefined;
    }
    let hasRadioList: boolean = hasOwnPropertyCall(this.menu.extra, ConfigurationConstant.RADIO_LIST);
    LogUtil.info(`${TAG} hasRadioList :${hasRadioList}`);
    if (!hasRadioList) {
      return undefined;
    }
    let json: Record<string, Object> = JSON.parse(JSON.stringify(this.menu.extra));
    this.radioList = json['radioList'] as SelectOption[];
    let radioMenus: RadioMenu[] = [];
    let index: number = ConfigurationConstant.MENU_INDEX;
    for (let i = 0; i < this.radioList.length; i++) {
      let content: string = this.radioList[i].value.toString();
      let menu: RadioMenu = new RadioMenu({
        key: content + new Date().getTime(),
        index: index,
        title: content,
        controller: {
          createControllerConstructorInter: SingleRadioController.CreateSingleRadioController,
        },
        extra: {
          settingProperty: this.settingProperty,
          value: i.toString(),
        }
      });
      radioMenus.push(menu);
      index += ConfigurationConstant.MENU_INDEX;
    }
    return radioMenus;
  }

  public onMenuClick(): boolean {
    LogUtil.info(`${TAG} onMenuClick openDialog`);
    this.openRadioDialog();
    return true;
  }

  private openRadioDialog(): void {
    LogUtil.info(`${TAG} openRadioDialog`);
    this.openDialog(this.detailDialogPage, true);
  }

  public updateStatus(): void {
    LogUtil.info(`${TAG} updateStatus`);
    let index: number = Number(this.getSettingsDataByProperty(this.settingProperty as string));
    if (index >= this.radioList.length) {
      LogUtil.error(`${TAG} the index ${index} is error.`);
      return;
    }
    this.isRefreshUi(this.radioList[index].value.toString());
  }

  public isRefreshUi(content: string): void {
    LogUtil.info(`${TAG} the content is ${content}`);
    if (this.menu.state != content) {
      this.menu.state = content;
      this.menu.timestamp = new Date().getTime();
      this.refreshUi();
    }
  }

  public onDialogClose(key?: string, data?: Object): void {
    LogUtil.info(`${this.tag} onDialogClose`);
    this.updateStatus();
  }

  public onDialogCancel(key?: string, data?: Object): void {
    LogUtil.info(`${this.tag} onDialogCancel`);
  }

  public onDialogOpen(key?: string): void {
    LogUtil.info(`${TAG} onDialogOpen`);
    let header = new MenuGroup({
      key: 'radio_menu_header',
    }, [this.dialogTitleMenu as DialogTitleMenu]);

    let footer = new MenuGroup({
      key: 'radio_menu_footer',
    }, [this.buttonMenu as ButtonMenu]);

    this.detailDialogPage.setHeader(header);
    this.detailDialogPage.addMenu(this.dividerMenuGroup);
    this.detailDialogPage.setFooter(footer);
  }

  public getObserverKey = (): string => {
    LogUtil.info(`${TAG} getObserverKey`);
    return this.menu?.key as string;
  }

  /**
   * 数据库监听回调
   */
  public onDataChange = () => {
    this.updateStatus();
  }
}

class SingleRadioController extends RadioMenuController {
  public tag: string = 'SingleRadioController : ';
  private settingProperty: string = '';
  private value: string = '';

  constructor(menu: SettingsBaseMenu) {
    super(menu);
    this.getExtraInfo();
  }

  static CreateSingleRadioController(menu: SettingsBaseMenu): Controller {
    return new SingleRadioController(menu);
  }

  private getExtraInfo() {
    if (!this.menu.extra) {
      LogUtil.error(`${this.tag} extra is null.`);
      return;
    }
    for (let key of Object.keys(this.menu.extra)) {
      if (key === ConfigurationConstant.SETTING_PROPERTY) {
        this.settingProperty = (this.menu.extra as Record<string, string>)[key];
      } else if (key == ConfigurationConstant.SINGLE_RADIO_VALUE) {
        this.value = (this.menu.extra as Record<string, string>)[key];
      }
    }
  }

  public onRadioChange(isChecked: boolean): void {
    LogUtil.info(`${this.tag} onRadioChange.`);
    this.setRadio(isChecked);
    SettingsDataUtils.setSettingsData(this.settingProperty, this.value);
    this.closeSelf();
  }

  public updateStatus(): void {
    LogUtil.info(`${this.tag} updateStatus.`);
    let data = SettingsDataUtils.getSettingsData(this.settingProperty, null);
    if (data == this.value) {
      this.setRadio(true);
    }
  }

  public setRadio(isChecked: boolean): void {
    if (this.isChecked !== isChecked) {
      this.isChecked = isChecked;
      this.refreshUi();
    }
  }
}
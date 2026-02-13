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
  MenuController,
  RadioMenuController
} from '@ohos/settings.common/src/main/ets/core/controller/MenuController';
import { extraType, SettingsBaseMenu } from '@ohos/settings.common/src/main/ets/core/model/menu/SettingsMenu';
import { LogUtil } from '@ohos/settings.common/src/main/ets/utils/LogUtil';
import { Controller } from '@ohos/settings.common/src/main/ets/core/controller/Controller';
import { Style } from '@ohos/settings.common/src/main/ets/core/model/menu/ComponetStyle';
import { DialogLifecycleObserverInterface } from '@ohos/settings.common/src/main/ets/core/lifecycle/Lifecycle';
import { ButtonMenu, DialogPage, DialogTitleMenu, DividerMenuGroup } from '@ohos/settings.uikit';
import {
  dialogRadioMenuStyle,
  radioListDialogDividerGroupStyle,
  radioListDialogPageStyle,
  radioListDialogTitleMenuStyle,
  RadioMenu,
  transparentButtonMenuForRadioListDialogStyle,
} from '@ohos/settings.uikit/src/main/ets/menus/Menu';

const SELECT_DIALOG_TITLE_MENU: string = 'dialog_title_menu';
const SELECT_DIALOG_DIVIDER_MENU_GROUP: string = 'divider_menu_group';

export const SELECT_DIALOG_MENU_KEY_PREFIX: string = 'select_dialog_key_';

/**
 * 选择器基础控制器
 *
 */
export class SelectDialogBaseController extends MenuController implements DialogLifecycleObserverInterface {
  public tag: string = 'SelectBaseSettingsController : ';
  public pageUrl: string;
  public selectMenuNameAndValMap: Map<ResourceStr, number | string>;
  public currentSelectedVal: number;
  public currentSelectedName: ResourceStr | undefined = undefined;

  constructor(menu: SettingsBaseMenu) {
    super(menu);
    if (!this.menu?.extra) {
      LogUtil.info(`${this.tag} router params apConfig is invalid`);
    }

    this.pageUrl = (this.menu?.extra as extraType)?.pageUrl as string;
    this.selectMenuNameAndValMap =
      (this.menu?.extra as extraType)?.selectMenuNameAndValMap as Map<ResourceStr, string | number>;
    this.currentSelectedVal = (this.menu?.extra as extraType)?.currentSelectedVal as number;
    this.currentSelectedName = this.currentSelectedName ?? this.selectMenuNameAndValMap.keys().next().value;
  }

  static CreateSelectDialogBaseController(menu: SettingsBaseMenu): Controller {
    return new SelectDialogBaseController(menu);
  }

  onMenuClick(): boolean {
    LogUtil.info(`${this.tag} onMenuClick openDialog`);
    this.openSettingsDialog();
    return true;
  }

  public getObserverKey = (): string => {
    return this.menu?.key ?? '';
  }

  onDialogCancel(key?: string): void {
    LogUtil.info(`${this.tag} onDialogCancel, key: ${key}`);
  }

  onDialogClose(key?: string, data?: ResourceStr): void {
    LogUtil.info(`${this.tag} onDialogClose, key: ${key}`);
    if (data === undefined || data === null || key !== this.pageUrl) {
      return;
    }
    this.currentSelectedName = data;
    this.updateStatus(data);
  }

  onDialogOpen(key?: string): void {
    LogUtil.info(`${this.tag} onDialogOpen, key: ${key}`);
  }

  /**
   * update select status
   *
   * @param data
   */
  updateStatus(data?: ResourceStr): void {
    LogUtil.info(`${this.tag} updateStatus`);
    this.menu.state = this.currentSelectedName;
    this.refreshUi();
    if (data && this.selectMenuNameAndValMap.has(data)) {
      this.publishDataChange(this.selectMenuNameAndValMap.get(data) as string | number);
    }
  }

  /**
   * open select dialog
   */
  private openSettingsDialog(): void {
    let detail = new DialogPage({
      pageUrl: this.pageUrl,
      style: radioListDialogPageStyle,
    });

    detail.addMenus(
      [
        new DialogTitleMenu(
          {
            key: SELECT_DIALOG_TITLE_MENU,
            index: 10,
            title: this.menu.title,
            style: radioListDialogTitleMenuStyle as Style,
          }
        ),
        new DividerMenuGroup(
          {
            key: SELECT_DIALOG_DIVIDER_MENU_GROUP,
            index: 20,
            style: radioListDialogDividerGroupStyle as Style,
          },
          this.getRadioMenus()
        ),
        new ButtonMenu(
          {
            key: 'cancel_button',
            index: 30,
            buttonTittle1: $r('app.string.button_tittle_cancel'),
            controller: {
              createControllerConstructorInter: DialogButtonMenuController.CreateDialogButtonMenuController,
            },
            style: transparentButtonMenuForRadioListDialogStyle as Style,
          }
        ),
      ]
    );
    this.openDialog(detail, true);
  }

  /**
   * get radio menus
   *
   * @returns
   */
  private getRadioMenus(): Array<SettingsBaseMenu> {
    let menus: SettingsBaseMenu[] = [];
    let menuPriority: number = 0;
    for (const element of Array.from(this.selectMenuNameAndValMap.keys())) {
      menus.push(new RadioMenu(
        {
          key: SELECT_DIALOG_MENU_KEY_PREFIX + menuPriority,
          index: menuPriority,
          title: element,
          controller: {
            createControllerConstructorInter: SelectBaseSettingsController.CreateSelectBaseSettingsController,
          },
          extra: {
            value: this.selectMenuNameAndValMap.get(element) as string,
            isSelected: this.currentSelectedName === element,
          },
          style: dialogRadioMenuStyle as Style,
        }
      ));

      menuPriority++;
    }

    return menus;
  }
}

@Observed
export class SelectBaseSettingsController extends RadioMenuController {
  static CreateSelectBaseSettingsController(menu: SettingsBaseMenu): Controller {
    return new SelectBaseSettingsController(menu);
  }

  public tag: string = 'SelectBaseSettingsController : ';

  onRadioChange(isChecked: boolean): void {
    this.setRadio(isChecked);
    if (isChecked) {
      this.closeSelf(this.menu.title);
    }
  }

  updateStatus(): void {
    if ((this.menu?.extra as extraType)?.isSelected) {
      this.setRadio(true);
    }
  }
}
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

/* instrument ignore file */
import { CheckEmptyUtils } from '@ohos/settings.common/src/main/ets/utils/CheckEmptyUtils';
import { Style } from '@ohos/settings.common/src/main/ets/core/model/menu/ComponetStyle';
import { ControllerConstructorInter } from '@ohos/settings.common/src/main/ets/core/model/menu/SettingsMenu';
import {
  DialogMessageMenu,
  DialogPage,
  DialogTitleMenu,
  PhoneDialogTitleMenuStyle,
  TransparentButtonMenu
} from '@ohos/settings.uikit/src/main/ets/menus/Menu';
import { BiometricsDialogMsgStyle, BiometricsDialogStyle, ButtonStyle } from './PasswordEntryController';

const TAG: string = 'DialogController: ';

/**
 * 弹窗控制类
 *
 * @since 2024-9-24
 */
export class DialogController {
  private static isNeedShowDialog: boolean = true;

  /**
   * 初始化“提示用户关闭密码的后果”的弹窗的内部界面
   *
   * @param rootPage 弹窗根布局
   */
  public static initDialogPage(pathInfos: NavPathStack | undefined, title: Resource, dialogMessage1: Resource,
    dialogMessage2?: Resource, controller?: ControllerConstructorInter): DialogPage {
    let rootPage = new DialogPage({
      pageUrl: 'quick_switch_user_url',
      title: title,
      scrollable: false,
      style: new BiometricsDialogStyle(),
    });
    rootPage.addMenus([
      new DialogTitleMenu({
        key: 'quick_switch_user_title',
        index: 10, // 用于排序
        title: rootPage.title,
        style: new PhoneDialogTitleMenuStyle(),
      }),
      new DialogMessageMenu(
        {
          key: 'quick_switch_user_message1',
          index: 20,
          title: dialogMessage1,
          style: new BiometricsDialogMsgStyle() as Style,
        }
      ),
    ]);
    if (!CheckEmptyUtils.isEmpty(dialogMessage2)) {
      rootPage.addMenu(new DialogMessageMenu(
        {
          key: 'quick_switch_user_message2',
          index: 20,
          title: dialogMessage2,
          style: new BiometricsDialogMsgStyle() as Style,
        }
      ));
    }
    rootPage.addMenu(new TransparentButtonMenu({
      key: 'quick_switch_user_button',
      menuType: 'DivideButton',
      timestamp: 2,
      index: 40,
      buttonTittle1: $r('app.string.dialog_cancel'),
      buttonTittle2: $r('app.string.continue_process'),
      controller: controller,
      style: new ButtonStyle(),
      pathInfos: pathInfos
    }));
    return rootPage;
  }

  /**
   * 设置是否需要显示弹窗
   *
   * @param isNeedShowDialog 是否显示弹窗
   */
  public static setIsNeedShowDialog(isNeedShowDialog: boolean): void {
    DialogController.isNeedShowDialog = isNeedShowDialog;
  }

  /**
   * 获取是否需要显示弹窗值
   *
   * @returns true 显示 false 不显示
   */
  public static getIsNeedShowDialog(): boolean {
    return DialogController.isNeedShowDialog;
  }
}
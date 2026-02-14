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

import systemParameter from '@ohos.systemparameter';
import resourceManager from '@ohos.resourceManager';
import { Controller } from '@ohos/settings.common/src/main/ets/core/controller/Controller';
import {
  DialogButtonMenuController,
  MenuController,
} from '@ohos/settings.common/src/main/ets/core/controller/MenuController';
import { HiSysEventUtil } from '@ohos/settings.common/src/main/ets/systemEvent/HiSysEventUtil';
import { LogUtil } from '@ohos/settings.common/src/main/ets/utils/LogUtil';
import { MenuGroup, SettingsBaseMenu } from '@ohos/settings.common/src/main/ets/core/model/menu/SettingsMenu';
import { ContainerStyle, Style } from '@ohos/settings.common/src/main/ets/core/model/menu/ComponetStyle';
import { EventBus } from '@ohos/settings.common/src/main/ets/framework/common/EventBus';
import {
  AnimationScaleController,
  TransitionAnimationKey,
  TransitionAnimationValue,
} from '@ohos/settings.developeroptions/src/main/ets/controller/AnimationScaleController';
import {
  ButtonMenu,
  DialogPage,
  DialogTitleMenu,
  DividerMenuGroup,
  RadioMenu,
  DefaultHeaderPageStyle,
  DefaultListStyle,
  dialogRadioMenuStyle,
  DialogTitleMenuStyle,
  PageTitleContainerStyle,
  radioListDialogDividerGroupStyle,
} from '@ohos/settings.uikit/src/main/ets/menus/Menu';
import { dormancyButtonMenuStyle } from '../../display/controller/DormancyController';
import { HiSysSystemEventGroup } from '@ohos/settings.common/src/main/ets/systemEvent/BehaviorEventConsts';
/* instrument ignore file */
const ARKUI_ANIMATION_SCALE_NAME: string = 'persist.sys.arkui.animationscale';

// 用于适配缩放尺度弹窗页面规格的标题
class DialogTitleContainerStyle extends PageTitleContainerStyle {
  public size: SizeOptions = {
    height: $r('app.float.wh_value_60'),
    width: '100%',
  }
}

class AnimationDialogTitleMenuStyle extends DialogTitleMenuStyle {
  public rootContainer?: ContainerStyle = new DialogTitleContainerStyle();
}

let animationDialogTitleMenuStyle = new AnimationDialogTitleMenuStyle();

// 适配弹窗滚动条样式
class DialogListStyle extends DefaultListStyle {
  public borderRadius = $r('app.float.border_radius_0');
}

class DialogHeaderPageStyle extends DefaultHeaderPageStyle {
  public listStyle = new DialogListStyle();
  public padding: Padding = {
    top: '0',
    bottom: '0',
    left: '0',
    right: '0',
  };
}

const TAG: string = 'TransitionAnimationController : ';

export default class TransitionAnimationController extends MenuController {
  private contextArray: string[] = [];
  private detailDialogPage: DialogPage = new DialogPage({
    pageUrl: 'pages/developeroptions/DeveloperOptionsSettings/transitionAnimationScale',
    title: $r('app.string.transition_animation_scale_title'),
    style: new DialogHeaderPageStyle() as Style,
  });
  private dialogTitleMenu?: DialogTitleMenu;
  private buttonMenu?: ButtonMenu;
  private dividerMenuGroup?: DividerMenuGroup;

  static CreateTransitionAnimationController(menu: SettingsBaseMenu): Controller {
    return new TransitionAnimationController(menu);
  }

  async aboutToAppear(): Promise<void> {
    LogUtil.info(`${TAG} aboutToAppear`);
    this.contextArray = await this.getScaleData() as string[];

    // index 用于菜单排序
    this.dialogTitleMenu = new DialogTitleMenu(
      {
        key: 'transition_animation_group',
        index: 10,
        title: $r('app.string.transition_animation_scale_title'),
        style: animationDialogTitleMenuStyle as Style,
      }
    );

    // index 用于菜单排序
    this.buttonMenu = new ButtonMenu(
      {
        key: 'transition_animation_cancel_button',
        index: 80,
        buttonTittle1: $r('app.string.button_tittle_cancel'),
        controller: {
          createControllerConstructorInter: DialogButtonMenuController.CreateDialogButtonMenuController,
        },
        style: dormancyButtonMenuStyle as Style,
      }
    );

    // index 用于菜单排序
    this.dividerMenuGroup = new DividerMenuGroup(
      {
        key: 'transition_animation_scale_dialog_group',
        index: 1,
        style: radioListDialogDividerGroupStyle as Style,
      },
      [
        new RadioMenu(
          {
            key: TransitionAnimationKey.ANIMATION_OFF_KEY,
            index: 10,
            title: this.contextArray?.[0],
            controller: {
              createControllerConstructorInter: AnimationScaleController.CreateAnimationScaleController,
            },
            extra: TransitionAnimationValue.ANIMATION_OFF_VALUE,
            style: dialogRadioMenuStyle as Style,
          }
        ),
        new RadioMenu(
          {
            key: TransitionAnimationKey.ANIMATION_SCALE_0_5_KEY,
            index: 20,
            title: this.contextArray?.[1],
            controller: {
              createControllerConstructorInter: AnimationScaleController.CreateAnimationScaleController,
            },
            extra: TransitionAnimationValue.ANIMATION_SCALE_0_5_VALUE,
            style: dialogRadioMenuStyle as Style,
          }
        ),
        new RadioMenu(
          {
            key: TransitionAnimationKey.ANIMATION_SCALE_1_0_KEY,
            index: 30,
            title: this.contextArray?.[2],
            controller: {
              createControllerConstructorInter: AnimationScaleController.CreateAnimationScaleController,
            },
            extra: TransitionAnimationValue.ANIMATION_SCALE_1_0_VALUE,
            style: dialogRadioMenuStyle as Style,
          }
        ),
        new RadioMenu(
          {
            key: TransitionAnimationKey.ANIMATION_SCALE_1_5_KEY,
            index: 40,
            title: this.contextArray?.[3],
            controller: {
              createControllerConstructorInter: AnimationScaleController.CreateAnimationScaleController,
            },
            extra: TransitionAnimationValue.ANIMATION_SCALE_1_5_VALUE,
            style: dialogRadioMenuStyle as Style,
          }
        ),
        new RadioMenu(
          {
            key: TransitionAnimationKey.ANIMATION_SCALE_2_0_KEY,
            index: 50,
            title: this.contextArray?.[4],
            controller: {
              createControllerConstructorInter: AnimationScaleController.CreateAnimationScaleController,
            },
            extra: TransitionAnimationValue.ANIMATION_SCALE_2_0_VALUE,
            style: dialogRadioMenuStyle as Style,
          }
        ),
        new RadioMenu(
          {
            key: TransitionAnimationKey.ANIMATION_SCALE_5_0_KEY,
            index: 60,
            title: this.contextArray?.[5],
            controller: {
              createControllerConstructorInter: AnimationScaleController.CreateAnimationScaleController,
            },
            extra: TransitionAnimationValue.ANIMATION_SCALE_5_0_VALUE,
            style: dialogRadioMenuStyle as Style,
          }
        ),
        new RadioMenu(
          {
            key: TransitionAnimationKey.ANIMATION_SCALE_10_0_KEY,
            index: 70,
            title: this.contextArray?.[6],
            controller: {
              createControllerConstructorInter: AnimationScaleController.CreateAnimationScaleController,
            },
            extra: TransitionAnimationValue.ANIMATION_SCALE_10_0_VALUE,
            style: dialogRadioMenuStyle as Style,
          }
        ),
      ]
    );
    EventBus.getInstance().on('EVENT_ID_ANIMATION_SCALE_UPDATE_EVENTS', this.animationScaleUpdateEventCb);
    super.aboutToAppear();
  }

  aboutToDisappear(): void {
    EventBus.getInstance().detach('EVENT_ID_ANIMATION_SCALE_UPDATE_EVENTS', this.animationScaleUpdateEventCb);
    super.aboutToDisappear();
  }

  private animationScaleUpdateEventCb = () => {
    LogUtil.info(`${TAG} animationScaleUpdateEvent`);
    this.updateStatus();
  };

  private async getScaleData(): Promise<Array<string> | undefined> { //Promise<Array<string>|undefined>
    LogUtil.info(`${TAG} getScaleData`);
    try {
      let resourceManager: resourceManager.ResourceManager = getContext(this).resourceManager;
      let contextArray: string[] =
        await resourceManager.getStringArrayValue($r('app.strarray.transition_animation_scale_entries').id);
      return contextArray;
    } catch (error) {
      LogUtil.error(`${TAG} getStringArrayValue failed, error ${error}`);
    }
    return;
  }

  onMenuClick(): boolean {
    LogUtil.info(`${TAG} onMenuClick openDialog`);
    HiSysEventUtil.reportDefaultBehaviorEvent(HiSysSystemEventGroup.ENTER_TRANSITION_ANIMATION_ENTRY);
    this.openTransitionAnimationDialog();
    return true;
  }

  private openTransitionAnimationDialog(): void {
    LogUtil.info(`${TAG} openTransitionAnimationDialog`);
    let header = new MenuGroup({key: 'transitionScale_menu_header'}, [this.dialogTitleMenu as DialogTitleMenu]);
    let footer = new MenuGroup({key: 'transitionScale_menu_footer'}, [this.buttonMenu as ButtonMenu]);
    this.detailDialogPage.setHeader(header);
    this.detailDialogPage.addMenu(this.dividerMenuGroup);
    this.detailDialogPage.setFooter(footer);
    // 打开弹窗，并支持自动关闭弹窗
    this.openDialog(this.detailDialogPage, true);
  }

  updateStatus(): void {
    LogUtil.info(`${TAG} updateStatus  ${this.getLogKey()}`);
    let context: string = '';
    let animationScale: string = systemParameter.getSync(ARKUI_ANIMATION_SCALE_NAME, 
      TransitionAnimationValue.ANIMATION_SCALE_1_0_VALUE);
    LogUtil.info(`${TAG} updateStatus, animationScale, ${animationScale}`);
    switch (animationScale) {
    // 使用switch找出对应下标的缩放尺度，刷新对应界面数据，数组存放于 contextArray
      case TransitionAnimationValue.ANIMATION_OFF_VALUE:
        context = this.contextArray?.[0]
        break;
      case TransitionAnimationValue.ANIMATION_SCALE_0_5_VALUE:
        context = this.contextArray?.[1]
        break;
      case TransitionAnimationValue.ANIMATION_SCALE_1_0_VALUE:
        context = this.contextArray?.[2]
        break;
      case TransitionAnimationValue.ANIMATION_SCALE_1_5_VALUE:
        context = this.contextArray?.[3]
        break;
      case TransitionAnimationValue.ANIMATION_SCALE_2_0_VALUE:
        context = this.contextArray?.[4]
        break;
      case TransitionAnimationValue.ANIMATION_SCALE_5_0_VALUE:
        context = this.contextArray?.[5]
        break;
      case TransitionAnimationValue.ANIMATION_SCALE_10_0_VALUE:
        context = this.contextArray?.[6]
        break;
    // no default
    }
    this.isRefreshUi(context);
  }

  // 刷新ui，在点击完按钮后触发这一步动作
  isRefreshUi(str: string): void {
    LogUtil.info(`${TAG} str ${str}`);
    if (this.menu.state != str) {
      this.menu.state = str;
      this.menu.timestamp = new Date().getTime();
      this.refreshUi();
    }
  }

  public getObserverKey = (): string => {
    LogUtil.info(`${TAG} getObserverKey`);
    return this.menu?.key as string;
  }
}
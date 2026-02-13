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

import { curves } from '@kit.ArkUI';
import { LogUtil } from '@ohos/settings.common/src/main/ets/utils/LogUtil';
import { NavEntryKey } from '@ohos/settings.common/src/main/ets/utils/Consts';
import { FontScaleUtils } from '@ohos/settings.common/src/main/ets/utils/FontScaleUtils';
import { PageRouter } from '@ohos/settings.common/src/main/ets/framework/common/PageRouter';
import { SettingBaseModel } from '@ohos/settings.common/src/main/ets/framework/model/SettingBaseModel';
import { AllSceneMenuItemController } from '../controller/AllSceneMenuItemController';

const TAG = 'AllSceneMenuItemView';
const BADGE_SIZE = '6vp';
const BADGE_PADDING = '6vp';
const ICON_SIZE = '32vp';
const ENTRY_WIDTH = '12vp';
const ENTRY_HEIGHT = '32vp';

/**
 * 协同升级菜单项目显示器
 *
 * @since 2024-10-15
 */
@Component
export struct AllSceneMenuItemView {
  item?: SettingBaseModel;
  private isSelected: boolean = false;
  @Consume('pathInfos') pathInfos: NavPathStack;
  @State controller: AllSceneMenuItemController = AllSceneMenuItemController.getInstance();

  private getNormalColor(): ResourceColor {
    LogUtil.info(`${TAG} getNormalColor`);
    return $r('app.color.color_default_white');
  }

  private getPressedColor(): ResourceColor {
    LogUtil.info(`${TAG} getPressedColor`);
    return $r('sys.color.interactive_click');
  }

  private getBackgroundColor(): ResourceColor {
    LogUtil.info(`${TAG} getBackgroundColor sucess`);
    if (this.isSelected) {
      return $r('app.color.color_1A000000_grey');
    }
    return $r('app.color.color_default_white');
  }

  private onEntryClick(): void {
    LogUtil.showInfo(TAG, 'click to navigate');
    PageRouter.push(NavEntryKey.OUC_ALL_SCENE_UPDATE_ENTRY);
  }

  aboutToAppear(): void {
    LogUtil.showInfo(TAG, 'aboutToAppear');
    this.controller.aboutToAppear();
  }

  aboutToDisappear(): void {
    LogUtil.showInfo(TAG, 'aboutToDisappear');
    this.controller.aboutToDisappear();
  }

  @Builder
  allSceneIconBuilder() {
    Image($r('app.media.icon_system_update'))
      .id(`${TAG}_image`)
      .width(ICON_SIZE)
      .height(ICON_SIZE)
      .objectFit(ImageFit.Cover)
      .borderRadius($r('sys.float.corner_radius_level8'))
      .draggable(false)
      .interpolation(ImageInterpolation.Medium)
      .syncLoad(true)
  }

  @Builder
  allSceneTitleBuilder() {
    Text(this.controller.getAllSceneMenuItemInfo()?.menuItemTitle)
      .fontSize($r('sys.float.Body_L'))
      .fontColor($r('sys.color.font_primary'))
      .fontWeight(FontWeight.Medium)
      .wordBreak(WordBreak.BREAK_ALL)
      .id(`${TAG}_title`)
  }

  @Builder
  allSceneContentBuilder() {
    Text(this.controller.getAllSceneMenuItemInfo()?.menuItemContent)
      .fontSize($r('sys.float.Body_M'))
      .fontColor($r('sys.color.font_secondary'))
      .fontWeight(FontWeight.Medium)
      .margin({ top: $r('sys.float.ohos_id_text_margin_vertical') })
      .wordBreak(WordBreak.BREAK_WORD)
      .id(`${TAG}_content`)
  }

  @Builder
  allSceneInfoBuilder() {
    Column() {
      this.allSceneTitleBuilder();
      this.allSceneContentBuilder();
    }.layoutWeight(1)
    .id(`${TAG}_device_info`)
    .alignItems(HorizontalAlign.Start)
  }

  @Builder
  allSceneInfoWithBadgeBuilder() {
    Badge({
      value: '',
      position: BadgePosition.Right,
      style: { badgeSize: BADGE_SIZE }
    }) {
      this.allSceneInfoBuilder();
    }
    .id(`${TAG}_badge`)
    .layoutWeight(1)
    .padding({ right: BADGE_PADDING })
  }

  @Builder
  allSceneEntryBuilder() {
    Image($r('app.media.ic_settings_arrow'))
      .hoverEffect(null)
      .id(`${TAG}_entry_image`)
      .width(ENTRY_WIDTH)
      .height(ENTRY_HEIGHT)
      .margin({ left: $r('sys.float.padding_level2') })
      .fillColor($r('sys.color.icon_fourth'))
      .matchTextDirection(true)
  }

  build() {
    Flex({ direction: FlexDirection.RowReverse }) {
      Row() {
        this.allSceneIconBuilder();
        Column() {}.id(`${TAG}_Column_padding`).width($r('sys.float.padding_level8'))
        if (this.controller.getAllSceneMenuItemInfo()?.isShowBadge) {
          this.allSceneInfoWithBadgeBuilder();
        } else {
          this.allSceneInfoBuilder();
        }
        this.allSceneEntryBuilder();
      }.id(`${TAG}_Row_2`)
      .visibility(this.controller?.getAllSceneMenuItemInfo()?.isShowMenuItem ? Visibility.Visible : Visibility.None)
    }.id(`${TAG}_Row_1`)
    .padding({
      top: FontScaleUtils.getCurrentTopPadding(),
      bottom: FontScaleUtils.getCurrentTopPadding(),
      left: $r('sys.float.padding_level4'),
      right: $r('sys.float.padding_level4')
    })
    .width('100%')
    .backgroundColor(this.getBackgroundColor())
    .borderRadius($r('sys.float.corner_radius_level8'))
    .stateStyles({
      normal: {
        .backgroundColor(this.getNormalColor())
        .borderRadius($r('sys.float.corner_radius_level8'))
      },
      pressed: {
        .backgroundColor(this.getPressedColor())
        .borderRadius($r('sys.float.corner_radius_level8'))
      },
    })
    .onClick(() => {
      this.onEntryClick();
    })
    .onMouse((event?: MouseEvent): void => {
      if (event) {
        if (event.button === MouseButton.Left && event.action === MouseAction.Press) {
          this.isSelected = true;
        } else if (event.button === MouseButton.Left && event.action === MouseAction.Release) {
          this.isSelected = false;
        }
      }
    })
    .onTouch((event?: TouchEvent): void => {
      if (event) {
        if (event.type === TouchType.Down) {
          this.isSelected = true;
        } else if (event.type === TouchType.Up) {
          this.isSelected = false;
        }
      }
    })
    .animation({duration: 250, curve: curves.interpolatingSpring(0, 1, 228, 22)})
    .transition(TransitionEffect.OPACITY.animation({ duration: 250, curve: Curve.Linear }))
  }
}

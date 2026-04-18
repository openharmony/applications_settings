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
import { MenuGroup } from '@ohos/settings.common/src/main/ets/core/model/menu/SettingsMenu';
import { PushParam } from '@ohos/settings.common/src/main/ets/core/controller/Controller';
import { MenuGroupController } from '@ohos/settings.common/src/main/ets/core/controller/MenuController';
import { NavEntryKey } from '@ohos/settings.common/src/main/ets/utils/Consts';
import {
  CardMenuSection,
  DefaultSliderMenuStyle,
  NavigationEntry,
  ThemeEditor,
  ThemeEditorFont,
  ThemeEditorIcon,
  ThemeEditorIconSize,
  ThemeEditorWindowStyle,
  ThemeEditorDesktopStyle,
  ThemeEditorDockColorStyle,
  ThemeEditorDockAutoHideStyle
} from '@ohos/settings.uikit/src/main/ets/menus/Menu';
import { PRESETS_MANAGER } from '@ohos/settings.uikit/src/main/ets/utils/PresetsManager';
import { DeviceUtil } from '@ohos/settings.common/src/main/ets/utils/BaseUtils';
import { SettingHeaderPage } from './SettingHeaderPage';
import { systemParameterEnhance } from '@kit.BasicServicesKit';
import { LogUtil } from '@ohos/settings.common';

export const BRIGHTNESS_SWITCH_KEY: string = 'brightness_switch';
export const SCREEN_GROUP_KEY: string = 'screen_group';
export const AOD_SWITCH_KEY: string = 'aod_switch';

const TAG: string = 'ThemePagePc : ';

/**
 * 显示页菜单数据
 *
 * @since 2024-06-15
 */
export class ThemePagePc extends SettingHeaderPage {
  private static readonly DISPLAY_PAGE_URL: string = 'pages/ThemePage';

  constructor(_pathInfos: NavPathStack, params: PushParam) {
    super({
      pageUrl: ThemePagePc.DISPLAY_PAGE_URL,
      title: $r('app.string.display_settings_title'),
      isNavigation: true,
      showHeader: false,
      isShowBack: !params?.config?.toString().includes('isShowBack:false')
    });
    this.addPcMenuGroupWallpaperImage();
    this.addPcMenuGroupIconStyle();
    this.addPcMenuGroupIconSize();
    this.addPcMenuDesktopStyle();
    this.addPcMenuGroupFontStyle();
    this.addPcMenuGroupDockColorStyle();
    this.addPcMenuGroupWindowAnimStyle();
    this.addPcMenuGroupDockAutoHideStyle();
    if (DeviceUtil.isSuperFoldProduct() && this.isRed()) {
      this.addPcCentralAxisPersonalization();
    }
  }

  private isRed(): boolean {
    try {
      const isRed: string = systemParameterEnhance.getSync('ohos.boot.backcolor', '');
      return isRed === 'red';
    } catch (err) {
      LogUtil.warn(`error: ${err}`);
    }
    return false;
  }

  addPcMenuGroupWallpaperImage() {
    this.addMenus([
      new MenuGroup(
        {
          key: 'theme_editor_group',
          index: 5, // 用于页面排序
          controller: {
            createControllerConstructorInter: MenuGroupController.CreateMenuGroupController,
          },
        },
        [
          new ThemeEditor(
            {
              key: 'theme_editor',
              index: 10, // 用于页面排序
              title: $r('app.string.wall_paper_theme'),
            }
          )
        ]
      ),
    ]);
  }

  addPcMenuGroupIconStyle() {
    if (!PRESETS_MANAGER.iconPresetsList || PRESETS_MANAGER.iconPresetsList.length === 0) {
      return;
    }
    this.addMenus([
      new CardMenuSection(
        {
          key: 'pc_theme_icon_card',
          index: 10,
        },
        [
          new ThemeEditorIcon(
            {
              key: 'theme_editor_icon',
              index: 10, // 用于页面排序
              title: $r('app.string.icon_style_theme'),
            }
          )
        ]
      ),
    ]);
  }

  addPcMenuGroupIconSize() {
    this.addMenus([
      new CardMenuSection(
        {
          key: 'pc_theme_icon_size_card',
          index: 10,
        },
        [
          new ThemeEditorIconSize(
            {
              key: 'theme_editor_icon_size',
              index: 10, // 用于页面排序
            }
          )
        ]
      ),
    ]);
  }

  addPcMenuGroupFontStyle() {
    if (!PRESETS_MANAGER.fontPresetsList || PRESETS_MANAGER.fontPresetsList.length === 0) {
      return;
    }
    this.addMenus([
      new CardMenuSection(
        {
          key: 'pc_theme_font_card',
          index: 10,
        },
        [
          new ThemeEditorFont(
            {
              key: 'theme_editor_font',
              index: 10, // 用于页面排序
              title: $r('app.string.font_style_theme'),
            }
          )
        ]
      ),
    ]);
  }

  addPcMenuDesktopStyle() {
    this.addMenus([
      new CardMenuSection(
        {
          key: 'pc_theme_desktop_style_card',
          index: 10,
          controller: {
            createControllerConstructorInter: MenuGroupController.CreateMenuGroupController,
          },
        },
        [
          new ThemeEditorDesktopStyle( // Todo
            {
              key: 'theme_editor_desktop',
              index: 10, // 用于页面排序
              title: $r('app.string.desktop_style_title'),
            }
          )
        ]
      ),
    ]);
  }

  addPcMenuGroupDockColorStyle() {
    this.addMenus([
      new CardMenuSection(
        {
          key: 'pc_theme_dock_background_style_card',
          index: 11,
        },
        [
          new ThemeEditorDockColorStyle(
            {
              key: 'theme_editor_font',
              index: 10, // 用于页面排序
              title: $r('app.string.font_style_theme'),
            }
          )
        ]
      ),
    ]);
  }

  addPcMenuGroupWindowAnimStyle() {
    this.addMenus([
      new CardMenuSection(
        {
          key: 'pc_theme_window_style_card',
          index: 10,
        },
        [
          new ThemeEditorWindowStyle(
            {
              key: 'theme_editor_font',
              index: 10, // 用于页面排序
              title: $r('app.string.font_style_theme'),
            }
          )
        ]
      ),
    ]);
  }

  addPcMenuGroupDockAutoHideStyle() {
    this.addMenus([
      new CardMenuSection(
        {
          key: 'pc_theme_dock_auto_hide_style_card',
          index: 10,
        },
        [
          new ThemeEditorDockAutoHideStyle(
            {
              key: 'theme_editor_font',
              index: 11, // 用于页面排序
              title: $r('app.string.font_style_theme'),
            }
          )
        ]
      ),
    ]);
  }

  addPcCentralAxisPersonalization() {
    this.addMenus([
      new CardMenuSection(
        {
          key: NavEntryKey.CENTRAL_AXIS_PERSONALIZATION_ENTRY,
          index: 11,
        },
        [
          new NavigationEntry(
            {
              key: NavEntryKey.CENTRAL_AXIS_PERSONALIZATION_ENTRY,
              index: 12,
              title: $r('app.string.central_axis_personalization'),
              stateIcon: $r('app.media.ic_settings_arrow'),
            }
          ),
        ]
      )
    ]);
  }
}
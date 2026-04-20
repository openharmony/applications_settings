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

import { LengthMetrics, display, window, componentUtils, inspector } from '@kit.ArkUI';
import image from '@ohos.multimedia.image';
import promptAction from '@ohos.promptAction';
import lazy { SystemParamUtil } from '@ohos/settings.common/src/main/ets/utils/SystemParamUtil';
import { Style } from '@ohos/settings.common/src/main/ets/core/model/menu/ComponetStyle';
import { Controller, UiRefresher } from '@ohos/settings.common/src/main/ets/core/controller/Controller';
import { LogUtil } from '@ohos/settings.common/src/main/ets/utils/LogUtil';
import { SettingsBaseMenu } from '@ohos/settings.common/src/main/ets/core/model/menu/SettingsMenu';
import { DynamicLoader } from '@ohos/settings.common/src/main/ets/utils/DynamicLoader';
import { DeviceUtil } from '@ohos/settings.common/src/main/ets/utils/BaseUtils';
import { EventBus } from '@ohos/settings.common/src/main/ets/framework/common/EventBus';
import lazy { wallpaperPreloader } from '../utils/WallpaperPreloader';
/* instrument ignore file */
const TAG: string = 'ThemeEditorMenuComponent : ';
const HPR_FOLD_ASPECT_RATIO: number = 0.75;
const PREVIEW_MAX_RATIO: number = 0.4;
const PREVIEW_ID: string = 'pc_entry_wallpaper_picker_page';
const PREVIEW_SPACE: number = 12;

@Component
export struct ThemeEditorPcMenuComponent {
  menu?: SettingsBaseMenu;
  style?: Style;
  @State controller?: Controller = undefined;
  @State uiRefresher: UiRefresher = new UiRefresher();
  @State curEnableWallpaperImage: image.PixelMap | null = null;
  @State isDarkMode: boolean = false;
  @State hoverBackgroundColor: Resource = $r('app.color.transparent');
  @Consume('pathInfos') pathInfos: NavPathStack;
  @State lockWallpaperImage: image.PixelMap | null = null;
  @State previewAspectRatio: number = 1.5;
  @State previewWidth: number = 0;
  @State clockResource: Resource = $r('app.media.theme_lockscreen_clock');
  private isSuperFold: boolean = DeviceUtil.isSuperFoldProduct();
  private inspector: inspector.ComponentObserver = inspector.createComponentObserver(PREVIEW_ID);
  private previewChangeCallback = () => {
    LogUtil.showInfo(TAG, 'previewChangeCallback');
    this.refreshPreview();
  };

  aboutToAppear(): void {
    LogUtil.showInfo(TAG, 'ThemeEditorPcMenuComponent aboutToAppear.');
    this.style = this.menu?.style;
    this.controller = this.menu?.getControllerInstance(this.uiRefresher);
    EventBus.getInstance().on('wallpaper_change', () => {
      LogUtil.showInfo(TAG, 'wallpaper_change callback');
      this.refreshWallpapers();
    });
    wallpaperPreloader.registerOrientationListener();
    this.inspector.on('layout', this.previewChangeCallback);
    this.refreshWallpapers();
    this.refreshPreview();
    const windowClass = (AppStorage.get<window.WindowStage>('windowStage') as window.WindowStage).getMainWindowSync();
    windowClass.on('windowRectChange', this.previewChangeCallback);
  }

  aboutToDisappear(): void {
    LogUtil.showInfo(TAG, 'ThemeEditorPcMenuComponent aboutToDisappear.');
    try {
      EventBus.getInstance().off('wallpaper_change');
    } catch (e) {
      LogUtil.showError(TAG, 'commonEventManager unsubscribe failed');
    }
    this.controller?.aboutToDisappear();
    const windowClass = (AppStorage.get<window.WindowStage>('windowStage') as window.WindowStage).getMainWindowSync();
    windowClass.off('windowRectChange', this.previewChangeCallback);
    wallpaperPreloader.unregisterOrientationListener();
    this.inspector.off('layout', this.previewChangeCallback);
  }

  private calculateAspectRatio(): void {
    LogUtil.info(`calculateAspectRatio start. isSuperFold: ${this.isSuperFold}`);
    try {
      if (this.isSuperFold) {
        this.previewAspectRatio = DeviceUtil.isDevicePortrait() ? HPR_FOLD_ASPECT_RATIO : 1 / HPR_FOLD_ASPECT_RATIO;
      }
    } catch (err) {
      LogUtil.error(`calculateAspectRatio failed. error: ${err?.code} ${err?.message}`);
    }
  }

  private refreshPreviewWidth(): void {
    try {
      this.previewWidth = (px2vp(componentUtils.getRectangleById(PREVIEW_ID)
        .size.width) - 3 * PREVIEW_SPACE) / 2;
      if (this.isSuperFold) {
        let previewMaxHeight: number = px2vp(display.getDefaultDisplaySync().height) * PREVIEW_MAX_RATIO;
        if (DeviceUtil.isFoldExpand() && DeviceUtil.isDevicePortrait()) {
          previewMaxHeight = previewMaxHeight / 2;
        }
        if (this.previewWidth / this.previewAspectRatio > previewMaxHeight) {
          this.previewWidth = previewMaxHeight * this.previewAspectRatio;
        }
      }
    } catch (err) {
      LogUtil.error(`refreshPreviewWidth failed. error: ${err?.code} ${err?.message}`);
    }
  }

  private refreshClockResource(): void {
    if (!this.isSuperFold) {
      this.clockResource =
        this.isDarkMode ? $r('app.media.theme_lockscreen_clock_dark') : $r('app.media.theme_lockscreen_clock');
      return;
    }
    if (DeviceUtil.isDevicePortrait()) {
      this.clockResource =
        this.isDarkMode ? $r('app.media.hpr_clock_dark_portrait') : $r('app.media.hpr_clock_light_portrait');
    } else {
      this.clockResource = this.isDarkMode ? $r('app.media.hpr_clock_dark_land') : $r('app.media.hpr_clock_light_land');
    }
  }

  private refreshPreview(): void {
    this.refreshClockResource();
    this.calculateAspectRatio();
    this.refreshPreviewWidth();
  }

  private refreshWallpapers(): void {
    LogUtil.showInfo(TAG, 'refreshWallpapers');
    this.curEnableWallpaperImage = wallpaperPreloader.getHomeWallpaper() ?? this.curEnableWallpaperImage;
    this.lockWallpaperImage = wallpaperPreloader.getLockWallpaper() ?? this.lockWallpaperImage;
    this.isDarkMode = !wallpaperPreloader.getIsDarkWallpaper();
  }

  build() {
    Row() {
      Column({ space: 4 }) {
        Row() {
          Text(this.menu?.title)
            .fontSize(16)
            .lineHeight(21)
            .fontWeight(FontWeight.Medium)

          SymbolGlyph($r('sys.symbol.chevron_right'))
            .draggable(false)
            .fontColor([$r('sys.color.icon_fourth')])
            .fontSize('24vp')
        }
        .height(40)
        .width('100%')
        .justifyContent(FlexAlign.SpaceBetween)

        Row({ space: PREVIEW_SPACE }) {
          this.lockscreenWallpaper()
          this.homeWallpaper()
        }
        .justifyContent(FlexAlign.Center)
        .width('100%')
        .zIndex(1)
      }
      .padding({
        left: 8,
        right: 8,
        bottom: 8
      })
      .borderRadius(12)
      .backgroundColor(this.hoverBackgroundColor)
      .onHover((isHover: boolean) => {
        if (isHover) {
          this.hoverBackgroundColor = $r('sys.color.interactive_hover');
        } else {
          this.hoverBackgroundColor = $r('app.color.transparent');
        }
      })
      .onTouch((event?: TouchEvent) => {
        if (event && event.type === TouchType.Down) {
          this.hoverBackgroundColor = $r('sys.color.interactive_click')
        }
        if (event && event.type === TouchType.Up) {
          this.hoverBackgroundColor = $r('app.color.transparent');
        }
      })
      .focusBox({
        margin: new LengthMetrics(-2),
      })
      .onClick(() => {
        SystemParamUtil.isModifyWallpaperDisable().then((isDisabled: boolean) => {
          if (isDisabled) {
            LogUtil.showInfo(TAG, 'modify wallpaper is disabled,show toast');
            try {
              promptAction.showToast({
                message: $r('app.string.disable_modify_wallpaper_tips')
              });
            } catch (e) {
              LogUtil.showError(TAG, `showToast fail, code: ${e?.code}, message: ${e?.message}`);
            }
          } else {
            DynamicLoader.getInstance().fire('theme_wallpaper').then(() => {
              this.pathInfos?.pushPathByName('theme_wallpaper', null);
            });
          }
        });
      })
    }
    .borderRadius(16)
    .backgroundColor($r('sys.color.comp_background_list_card'))
    .padding(4)
    .margin({ top: 10 })
    .id('pc_entry_wallpaper_picker_page')
  }

  @Builder
  homeWallpaper() {
    Stack() {
      Image(this.curEnableWallpaperImage)
        .enhancedImageQuality(image.ResolutionQuality.MEDIUM)
        .width('100%')
        .height('100%')
        .zIndex(1)
        .draggable(false)
        .objectFit(ImageFit.Cover)
        .borderRadius(8);
    }
    .clip(true)
    .borderRadius(8)
    .width(this.previewWidth)
    .aspectRatio(this.previewAspectRatio)
  }

  @Builder
  lockscreenWallpaper() {
    Stack({ alignContent: Alignment.Bottom }) {
      Image(this.lockWallpaperImage)
        .enhancedImageQuality(image.ResolutionQuality.MEDIUM)
        .width('100%')
        .height('100%')
        .zIndex(1)
        .draggable(false)
        .objectFit(ImageFit.Cover)
        .borderRadius(8);
      Image(this.isDarkMode ? $r('app.media.theme_lockscreen_clock_dark') : $r('app.media.theme_lockscreen_clock'))
        .zIndex(2)
        .draggable(false)
        .width('100%')
        .height('100%')
    }
    .borderRadius(8)
    .width(this.previewWidth)
    .aspectRatio(this.previewAspectRatio)
  }
}
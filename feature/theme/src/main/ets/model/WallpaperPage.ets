/*
 * Copyright (c) Huawei Technologies Co., Ltd. 2024-2024. All rights reserved.
 */
import { SettingHeaderPage } from '@ohos/settings.uikit/src/main/ets/component/SettingHeaderPage';

/**
 * 壁纸选择页数据
 */
export class WallpaperPage extends SettingHeaderPage {
  private static readonly WALLPAPER_PAGE_URL: string = 'pages/theme/WallpaperPage';
  constructor(_pathInfos: NavPathStack) {
    super({
      pageUrl: WallpaperPage.WALLPAPER_PAGE_URL,
      isNavigation: false,
    });
    this.addMenus([]);
  }
}

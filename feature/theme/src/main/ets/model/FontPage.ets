/*
 * Copyright (c) Huawei Technologies Co., Ltd. 2024-2024. All rights reserved.
 */
import { SettingHeaderPage } from '@ohos/settings.uikit/src/main/ets/component/SettingHeaderPage';

/**
 * 字体选择页数据
 */
export class FontPage extends SettingHeaderPage {
  private static readonly FONT_PAGE_URL: string = 'pages/theme/FontPage';
  constructor(_pathInfos: NavPathStack) {
    super({
      pageUrl: FontPage.FONT_PAGE_URL,
      isNavigation: false,
    });
    this.addMenus([]);
  }
}

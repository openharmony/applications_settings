/*
 * Copyright (c) Huawei Technologies Co., Ltd. 2024-2024. All rights reserved.
 */
import { SettingHeaderPage } from '@ohos/settings.uikit/src/main/ets/component/SettingHeaderPage';

/**
 * 图标选择页数据
 */
export class IconPage extends SettingHeaderPage {
  private static readonly ICON_PAGE_URL: string = 'pages/theme/IconPage';
  constructor(_pathInfos: NavPathStack) {
    super({
      pageUrl: IconPage.ICON_PAGE_URL,
      isNavigation: false,
    });
    this.addMenus([]);
  }
}

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

import display from '@ohos.display';
import { LogUtil } from '@ohos/settings.common/src/main/ets/utils/LogUtil';
import { SettingsDataUtils } from '@ohos/settings.common/src/main/ets/utils/SettingsDataUtils';
import { SystemParamUtil } from '@ohos/settings.common/src/main/ets/utils/SystemParamUtil';

// 桌面风格类型
enum DockStyle {
  // 分离模式
  MAC_STYLE = '128',
  // 合一模式
  WIN_STYLE = '2048',
}

const TAG = 'StatusbarPanelUtil';

// 分离模式顶部状态栏高度
const DISPLAY_TOP_MENU_HEIGHT: number = 40;
// 分离模式底部菜单高度65 + 上4底部8的边距
const DISPLAY_BOTTOM_MENU_HEIGHT: number = 77;
// 合一模式DOCK菜单高度65 + 上下各8的边距
const DISPLAY_DOCK_MENU_HEIGHT: number = 81;
// 默认最大高度
const DEFAULT_DIALOG_MAX_HEIGHT: number = 973;
// PC 状态栏类型数据库字段
const PC_STATUS_BAR_TYPE_KEY: string = 'settings_in_status_bar_type';
// 产品名参数Key
const BUILD_PRODUCT_PARAM_KEY: string = 'const.build.product';
// hopper产品面板最大高度, hopper产品WIFI最大列表高度只允许屏幕高度的一半, 需要特殊处理
const HPR_DIALOG_MAX_HEIGHT_DEFAULT: number = 805;
const HPR_DIALOG_MAX_HEIGHT_FLOAT: number = 769;
const DEVICE_HPR: string = 'HPR';

/**
 * StatusbarPanelUtil class
 */
export default class StatusbarPanelUtil {
  /**
   * 获取二级面板最大高度
   */
  public static getWindowPanelMaxHeight(): number {
    try {
      let desktopStyle: string = SettingsDataUtils.getSecureValue(PC_STATUS_BAR_TYPE_KEY, DockStyle.WIN_STYLE);
      // 当前整个屏幕显示高度
      let defaultDisplayHeight: number = px2vp(display.getDefaultDisplaySync().height);
      // 合一模式面板最大高度
      let winStyleMaxHeight: number = defaultDisplayHeight - DISPLAY_DOCK_MENU_HEIGHT;
      // 分离模式面板最大高度
      let macStyleMaxHeight: number = defaultDisplayHeight - DISPLAY_TOP_MENU_HEIGHT - DISPLAY_BOTTOM_MENU_HEIGHT;
      // 当前模式面板最大高度
      let windowPanelMaxHeight: number =
        desktopStyle === DockStyle.WIN_STYLE ? winStyleMaxHeight : macStyleMaxHeight;
      // HPR产品当前模式面板最大高度
      let windowPanelMaxHeightHPR: number =
        desktopStyle === DockStyle.WIN_STYLE ? HPR_DIALOG_MAX_HEIGHT_DEFAULT : HPR_DIALOG_MAX_HEIGHT_FLOAT;
      // 产品化面板最大高度
      let productPanelMaxHeight: number =
        SystemParamUtil.getParam(BUILD_PRODUCT_PARAM_KEY, '') === DEVICE_HPR ?
          windowPanelMaxHeightHPR : windowPanelMaxHeight;
      LogUtil.info(`${TAG} getWindowPanelMaxHeight productPanelMaxHeight: ${productPanelMaxHeight}`);
      return productPanelMaxHeight;
    } catch (error) {
      LogUtil.error(`${TAG} getDefaultDisplay failed, error reason: ${error?.code}`);
      return DEFAULT_DIALOG_MAX_HEIGHT;
    }
  }
}
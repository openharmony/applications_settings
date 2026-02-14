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
import { SliderMenuController } from '@ohos/settings.common/src/main/ets/core/controller/MenuController';
import { SettingsBaseMenu } from '@ohos/settings.common/src/main/ets/core/model/menu/SettingsMenu';
import { LogUtil } from '@ohos/settings.common/src/main/ets/utils/LogUtil';
import { Controller } from '@ohos/settings.common/src/main/ets/core/controller/Controller';
import DpiManager from '@ohos/settings.common/src/main/ets/utils/DpiManager';
import { displayDataManager } from '@ohos/settings.common/src/main/ets/data/DisplayDataManager';

const TAG: string = 'ScreenZoomController : ';

/**
 * 显示大小的title信息展示
 */
export const SUMMARY_DEFAULT: Resource = $r('app.string.screen_zoom_summary_default');
export const SUMMARIES_SMALLER: Resource[] = [$r('app.string.screen_zoom_summary_small')];
export const SUMMARIES_LARGER: Resource[] = [
$r('app.string.screen_zoom_summary_large'),
$r('app.string.screen_zoom_summary_very_large'),
$r('app.string.screen_zoom_summary_extremely_large')];

/**
 * 滑动条的颗粒
 */
const STEP_NUM: number = 1;

/**
 * 亮度设置的通用逻辑
 *
 * @since 2023-08-24
 */
export class ScreenZoomController extends SliderMenuController {
  static CreateScreenZoomController(menu: SettingsBaseMenu): Controller {
    return new ScreenZoomController(menu);
  }

  private inSetValue: number = STEP_NUM;

  constructor(menu: SettingsBaseMenu) {
    super(menu);
    this.initialPage();
  }

  updateStatus(): void {
    this.setVisible(true);
    this.refreshUi();
  }

  /**
   * 数据库监听回调
   */
  public onDataChange = () => {
    this.updateStatus();
  }

  getSliderMin(): number {
    return 0;
  }

  getSliderMax(): number {
    return DpiManager.numSmaller + DpiManager.numLarger;
  }

  getSliderStep(): number {
    return STEP_NUM;
  }

  /**
   * 保存值
   */
  getSliderValue(): number {
    return this.inSetValue;
  }

  protected updateSliderValue(): number {
    return this.inSetValue;
  }

  onSliderChange(sliderValue: number, mode: SliderChangeMode): boolean {
    if (mode !== SliderChangeMode.End && mode !== SliderChangeMode.Click) {
      LogUtil.showInfo(TAG, 'slider not end or click');
      return true;
    }
    if (this.inSetValue === sliderValue) {
      LogUtil.showInfo(TAG, 'screen zoom size slider val not change');
      return true;
    }
    this.inSetValue = sliderValue;
    DpiManager.setDpiName(this.inSetValue);
    AppStorage.SetOrCreate('dpi_change', this.inSetValue);
    this.refreshUi();
    return true;
  }

  onStartIconClick() : void {
    LogUtil.info(`${TAG} onReduceClick`);
    if (this.inSetValue > 0) {
      this.inSetValue -= STEP_NUM;
    }
    LogUtil.info(`${TAG} this.inSetValue: ${this.inSetValue}`);
    AppStorage.SetOrCreate('dpi_change', this.inSetValue);
    DpiManager.setDpiName(this.inSetValue);
    this.refreshUi();
  }

  onEndIconClick() : void {
    LogUtil.info(`${TAG} onIncreaseClick`);
    if (this.inSetValue < DpiManager.numLarger + DpiManager.numSmaller) {
      this.inSetValue += STEP_NUM;
    }
    LogUtil.info(`${TAG} this.inSetValue: ${this.inSetValue}`);
    DpiManager.setDpiName(this.inSetValue);
    AppStorage.SetOrCreate('dpi_change', this.inSetValue);
    this.refreshUi();
  }

  private initialPage(): void {
    DpiManager.getClassInstance();
    DpiManager.setDefaultDpi(displayDataManager.getDefaultDPI());
    this.inSetValue = DpiManager.setNumberAndScale(SUMMARIES_LARGER, SUMMARIES_SMALLER, SUMMARY_DEFAULT);
    LogUtil.info(`${TAG} this.inSetValue: ${this.inSetValue}`);
    DpiManager.getDpiName(this.inSetValue);
  }
}

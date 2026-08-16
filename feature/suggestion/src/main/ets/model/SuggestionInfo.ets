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

import { SuggestionController } from '../controller/SuggestionController';

/**
 * 卡片推荐内容
 */
export class SuggestionInfo {
  /**
   * bundleName
   */
  public bundleName?: string;
  /**
   * Id
   */
  public id?: string
  /**
   * 业务名
   */
  public name?: string;
  /**
   * 设置提醒标题
   */
  public title?: string;
  /**
   * 设置提醒内容
   */
  public desc?: string;
  /**
   * 优先级
   */
  public priority?: number;
  /**
   * 图片资源名称
   */
  public icon?: string;
  /**
   * 图标资源
   */
  public iconImg?: ResourceStr | PixelMap | null = null;
  /**
   * bundleName
   */
  public jumpBundleName?: string;
  /**
   * 跳转方式
   */
  public jumpType?: string;
  /**
   * 跳转参数
   */
  public jumpValue?: string;
  /**
   * 跳转的内部页面，或者外部UiExtension界面（此时值为common_page）
   */
  public routerUri?: string;
  /**
   * 跳转参数
   */
  public actionParams?: string;
  /**
   * 跳转外部UiExtension界面abilityName
   */
  public abilityName?: string;
  /**
   * 推荐卡片信息对应controller
   */
  public controller?: SuggestionController;
  /**
   * 是否在首页无需展示
   */
  public isHomePageNoNeedShowDesc?: boolean;
}


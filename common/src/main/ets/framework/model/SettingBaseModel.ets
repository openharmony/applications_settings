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

export interface CompCtrlParam {
  compId: string;
  component: SettingBaseModel;
  dataSource?: object;
  param?: object;
}

export interface ComponentControl {
  /*
   * 框架组件控制器初始化接口，在组件aboutToAppear中被调用
   */
  init: (compParam: CompCtrlParam) => void;

  /*
   * 框架组件控制器销毁接口，在组件aboutToDisappear中被调用
   */
  destroy: () => void;

  /*
   * 自定义page显示相关逻辑
   */
  onPageShow?: (component: SettingBaseModel) => void;

  /*
   * 自定义page隐藏相关逻辑
   */
  onPageHide?: (component: SettingBaseModel) => void;

  /*
   * 自定义的组件点击事件响应
   * @param: custom component configed data
   */
  onClick?: (component: SettingBaseModel) => void;

  /*
   * 界面跳转前回调
   */
  onRouterPrepare?: (component: SettingBaseModel) => void;

  /*
   * 返回按钮被点击
   */
  onBackPressed?: (component: SettingBaseModel) => boolean;
}

export interface ComponentExtend {
  cached?: boolean;
  visible?: boolean;
  enabled?: boolean;
}

export interface SettingBaseModel {
  /*
   * 组件ID
   */
  id: string;

  /*
   * 自定义组件定义的组件Builder
   */
  builder?: WrappedBuilder<[object]>;

  /*
   * 组件控制器
   */
  compControl?: ComponentControl;

  /*
   * 组件是否缓存，如果声明为true，组件在非首次加载时，将使用缓存数据实现快速加载显示
   */
  cached?: boolean;

  /*
   * 组件是否可见，如果声明为false，组件默认不可见，在控制器中发送事件可控制组件可见性
   */
  visible?: boolean;

  /**
   * 组件是否使能
   */
  enabled?: boolean;

  /**
   * 组件走焦顺序
   */
  tabIndex?: number;

  /*
   * 对象存储数据信息
   */
  extra?: Object;

  /*
   * 组件是否获焦
   */
  focusable?: boolean;
}
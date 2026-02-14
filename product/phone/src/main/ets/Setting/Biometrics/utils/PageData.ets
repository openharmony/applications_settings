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

// import {
//   HdsNavDestinationTitleMode,
//   HdsNavigationMenuItemOptions,
//   HdsNavigationTitleBarOptions
// } from '@kit.UIDesignKit';
import { PushParam } from '@ohos/settings.common/src/main/ets/core/controller/Controller';
import { PinAuthUtil } from '@ohos/settings.privacy/src/main/ets/PinAuthUtil';
import PageOperation from './PageOperation';

@Observed
export default class PageData {
  public transitionType: NavigationSystemTransitionType = NavigationSystemTransitionType.TITLE;
  // public titleMode: HdsNavDestinationTitleMode = HdsNavDestinationTitleMode.MINI;
  private title: ResourceStr = '';
  private isFromUIExtension: boolean = false;
  // private titleMenuValue: HdsNavigationMenuItemOptions[] = [];

  constructor(transitionType?: NavigationSystemTransitionType) {
    if (transitionType !== undefined) {
      this.transitionType = transitionType;
    }
  }

  /**
   * 初始化数据
   *
   * @param params 调用信息
   * @param title 标题
   */
  initData(params?: PushParam | null, title?: ResourceStr): void {
    if (title) {
      this.title = title;
    }
    this.isFromUIExtension = PinAuthUtil.isFromUIExtension(params);
    if (!this.isFromUIExtension) {
      this.transitionType = NavigationSystemTransitionType.DEFAULT;
    }
    if (!params) {
      return;
    }
    const config = params?.config as Record<string, boolean>;
    // if (config?.showClose) {
    //   this.titleMenuValue.push(PageOperation.xMarkMenu());
    // }
    // if (config?.isModal) {
    //   this.titleMode = HdsNavDestinationTitleMode.MODAL;
    // }
  }

  public getTitle(): ResourceStr {
    return this.title;
  }

  /**
   * 获取titleBar的数据
   *
   * @returns titleBar数据
   */
  // public getTitleBarData(): HdsNavigationTitleBarOptions {
  //   return {
  //     enableComponentSafeArea: true,
  //     content: {
  //       title: {
  //         mainTitle: this.title
  //       },
  //       menu: {
  //         value: this.titleMenuValue
  //       }
  //     }
  //   };
  // }

  /**
   * 设置transition类型
   *
   * @param transitionType 类型
   */
  public setTransitionType(transitionType: NavigationSystemTransitionType): void {
    if (this.isFromUIExtension) {
      this.transitionType = transitionType;
    }
  }
}
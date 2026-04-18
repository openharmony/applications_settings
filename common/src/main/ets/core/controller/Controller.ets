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

import { PageStartModeManager } from '../../window/PageStartModeManager';
import { LifecycleObserverInterface } from '../lifecycle/Lifecycle';

export class Params {
  public params?: PushParam;
}

export class PushParam {
  public config?: Object | object;
  public startReason?: string;
  public subUri?: string;
  public bundleName?: string;
  public appIndex?: number;
  public itemName?: string;
  public abilityName?: string;
  public finishType?: number;
  public targetPage?: string;
  public originalCallerInfo?: string;

  constructor(param?: Object | object, subUri?: string, bundleName?: string, appIndex?: number, itemName?: string,
    callerInfo?: string) {
    this.config = param;
    this.subUri = subUri;
    this.bundleName = bundleName;
    this.startReason = PageStartModeManager.getInstance().getStartReason();
    this.appIndex = appIndex;
    this.itemName = itemName;
    this.originalCallerInfo = callerInfo;
  }
}

interface ControllerInterface {
  onStateIconClick?: Function | null
  onLongPressGesture?: Function | boolean
  onSecondStateIconClick?: Function | null
  onTitleClick?: undefined
  onSummaryClick?: undefined
  onSecondSummaryClick?: undefined
  onStateTextClick?: undefined
  onSecondStateTextClick?: undefined
}

/**
 * 菜单动态数据的控制器
 *
 * @since 2022-03-21
 */
export abstract class Controller implements ControllerInterface, LifecycleObserverInterface {
  public onStateIconClick?: Function | null
  public onLongPressGesture?: Function | boolean
  public onSecondStateIconClick?: Function | null
  public onTitleClick?: undefined
  public onSummaryClick?: undefined
  public onSecondSummaryClick?: undefined
  public onStateTextClick?: undefined
  public onSecondStateTextClick?: undefined
  public getObserverKey?: () => string
  /**
   * 唯一标识
   */
  abstract getKey(): string;

  /**
   * 即将显示，加载资源
   */
  abstract aboutToAppear(): void;

  /**
   * 即将推出，释放资源
   */
  abstract aboutToDisappear(): void;

  /**
   * 绑定当前UI
   *
   * @param uiRefresher UI刷新器
   */
  abstract bindUi(uiRefresher: UiRefresher): void

  /**
   * 点击事件
   */
  abstract onMenuClick(): boolean;

  /**
   * 点击事件
   */
  abstract onMenuIconClick(): boolean;

  /**
   * 刷新UI
   */
  abstract refreshUi(): void;

  /**
   * 显示隐藏状态
   */
  abstract isVisibleStatus(): boolean;

  /**
   * 更新显示隐藏状态
   */
  abstract updateVisibleStatus(): boolean;

  /**
   * 数据监听回调
   *
   * @param fromKey 数据来源
   * @param data 具体数据
   */
  abstract onDataChange(fromKey: string, data: Object): void;

  /**
   * 被监听者监听回调
   *
   * @param observerKey 监听者的key
   */
  abstract onRegisteredByObserver(observerKey: string): void;

  /**
   * 处理点击hover图标事件
   */
  abstract handleHoverButtonClick(): void;

  /**
   * 处理hover事件
   *
   * @param ishovered hover状态
   */
  abstract handleHoverEvent(isHovered: boolean): void;

  /**
   * 返回component是否为hover状态
   */
  abstract isComponentHovered(): boolean;

  abstract onPageDestroy(): void;

  abstract notifyChange(): void
}

/**
 * UI刷新器，触发刷新UI和显隐状态
 *
 * @since 2022-03-21
 */
export class UiRefresher {
  private static readonly MAX_REFRESH_ID: number = 1000;
  private static readonly SHOW_OR_HIDE_RANGE: number = 2;
  private static readonly SHOW_OR_HIDE_STEP: number = 1;
  private static readonly SHOW_ID: number = 1;
  private static readonly HIDE_ID: number = 0;
  protected readonly tag: string = 'UiRefresher : ';
  /**
   * 用 @State 标记 UiRefresher 变量，修改此值触发UI刷新
   */
  public refreshId: number = UiRefresher.SHOW_ID;
  public refreshTitleId: number = UiRefresher.SHOW_ID;
  public isRender: boolean = true;

  refreshUi(): void {
    this.refreshId += UiRefresher.SHOW_OR_HIDE_RANGE;
    this.adjustIdIfNeed();
  }

  refreshFontStyle(): void {
    this.refreshTitleId += UiRefresher.SHOW_OR_HIDE_RANGE;
    this.adjustTitleIdIfNeed();
  }

  isVisible(): boolean {
    return (this.refreshId % UiRefresher.SHOW_OR_HIDE_RANGE) >= UiRefresher.SHOW_ID ? true : false;
  }

  setVisible(isVisible: boolean): void {
    if (this.isVisible() != isVisible) {
      this.refreshId += UiRefresher.SHOW_OR_HIDE_STEP;
      this.adjustIdIfNeed();
    }
  }

  setRender(isRender: boolean): void {
    this.isRender = isRender;
  }

  isTitleVisible(): boolean {
    return (this.refreshTitleId % UiRefresher.SHOW_OR_HIDE_RANGE) >= UiRefresher.SHOW_ID ? true : false;
  }

  private adjustIdIfNeed(): void {
    if (this.refreshId > UiRefresher.MAX_REFRESH_ID) {
      this.refreshId = this.isVisible() ? UiRefresher.SHOW_ID : UiRefresher.HIDE_ID;
      return;
    }
  }

  private adjustTitleIdIfNeed(): void {
    if (this.refreshTitleId > UiRefresher.MAX_REFRESH_ID) {
      this.refreshTitleId = this.isTitleVisible() ? UiRefresher.SHOW_ID : UiRefresher.HIDE_ID;
      return;
    }
  }
}

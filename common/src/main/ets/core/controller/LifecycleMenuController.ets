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

import { MenuController, MenuGroupController, LoadingGroupController } from './MenuController';
import { PageLifecycleObserverInterface } from '../lifecycle/Lifecycle';

/**
 * 基础菜单控制器
 *
 * @since 2022-04-25
 */
export class PageLifecycleMenuController extends MenuController implements PageLifecycleObserverInterface {
  public getObserverKey = (): string => {
    return this.menu?.key as string;
  }

  onPageShow(): void {
  }

  onPageHide(): void {
  }
}

/**
 * 设备名称控制器
 * 将pc与phone的DeviceNameController抽象
 */
export abstract class CommonDeviceNameController extends PageLifecycleMenuController {
  public flashFocusTargetKey: string = '';
  public onStateIconClick: (() => void) | null = null;
  public onDeviceNameTextClick: (() => void) | null = null;
  public inputController: TextInputController = new TextInputController()

  abstract getCurrentTextInput(): string;

  abstract onTextInputChange(input: string): void;

  abstract onEditChange(isEditing: boolean): void;

  abstract onFocusChange(): void;

  abstract onSubmit(enterKey?: EnterKeyType): void;

  abstract onReceivePageTouchEvent(): void;

  abstract isEditVisible(): boolean;

  abstract isEditEnabled(): boolean;

  abstract isStateIconEnable(): boolean;
}

/**
 * 菜单组控制器
 *
 * @since 2022-04-25
 */
export class PageLifecycleMenuGroupController extends MenuGroupController implements PageLifecycleObserverInterface {
  public getObserverKey = (): string => {
    return this.menu?.key as string;
  }

  onPageShow(): void {
  }

  onPageHide(): void {
  }
}

/**
 * 加载菜单父菜单控制器
 *
 * @since 2022-04-25
 */
export class PageLifecycleLoadingGroupController extends LoadingGroupController {
  public getObserverKey?: () => string = (): string => {
    return this.menu?.key as string;
  }

  onPageShow(): void {
  }

  onPageHide(): void {
  }
}

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

/**
 * 生命周期宿主
 *
 * @since 2022-03-21
 */
export abstract class LifecycleOwner {
  /**
   * 添加生命周期监听者
   *
   * @param observer 生命周期监听者
   */
  abstract addObserver(observer: LifecycleObserverInterface): void;

  /**
   * 删除生命周期监听者
   *
   * @param observerKey 生命周期监听者的key
   */
  abstract removeObserver(observerKey: string): void;
}

/**
 * 页的生命周期宿主
 *
 * @since 2022-03-21
 */
export class PageLifecycleOwner extends LifecycleOwner {
  public tag: string = 'PageLifecycleOwner: ';
  private pageObservers = new Map<string, PageLifecycleObserver>();
  private dialogObservers = new Map<string, DialogLifecycleObserver>();

  addObserver(observer: LifecycleObserverInterface): void {
    if (observer.getObserverKey) {
      if (PageLifecycleObserver.isPageLifecycleObserver(observer) && observer.getObserverKey()) {
        this.pageObservers.set(observer.getObserverKey(), observer as PageLifecycleObserver);
      }
      if (DialogLifecycleObserver.isDialogLifecycleObserver(observer) && observer.getObserverKey()) {
        this.dialogObservers.set(observer.getObserverKey(), observer as DialogLifecycleObserver);
      }
    }
  }

  removeObserver(observerKey: string): void {
    if (observerKey) {
      this.pageObservers.delete(observerKey);
      this.dialogObservers.delete(observerKey);
    }
  }

  /**
   * 页显示回调
   */
  onPageShow(): void {
    for (let observer of Array.from(this.pageObservers.values())) {
      if (observer.onPageShow) {
        observer.onPageShow();
      }
    }
  }

  /**
   * 页不可见回调
   */
  onPageHide(): void {
    for (let observer of Array.from(this.pageObservers.values())) {
      if (observer.onPageHide) {
        observer.onPageHide();
      }
    }
  }

  /**
   * 页的弹框取消回调
   */
  onDialogCancel(key?: string, data?: Object) {
    for (let observer of Array.from(this.dialogObservers.values())) {
      if (observer.onDialogCancel) {
        observer.onDialogCancel(key, data);
      }
    }
  }

  /**
   * 页的弹框打开回调
   */
  onDialogOpen(key?: string, data?: Object): void {
    for (let observer of Array.from(this.dialogObservers.values())) {
      if (observer.onDialogOpen) {
        observer.onDialogOpen(key, data);
      }
    }
  }

  /**
   * 页的弹框关闭回调
   */
  onDialogClose(key?: string, data?: Object): void {
    for (let observer of Array.from(this.dialogObservers.values())) {
      if (observer.onDialogClose) {
        observer.onDialogClose(key, data);
      }
    }
  }
}

/**
 * 弹框的生命周期宿主
 *
 * @since 2022-03-21
 */
export class DialogLifecycleOwner extends LifecycleOwner {
  public dialogObservers = new Map<string, DialogSelfLifecycleObserver>();
  public parentLifecycleOwner: LifecycleOwner;

  constructor(lifecycleOwner?: LifecycleOwner) {
    super();
    this.parentLifecycleOwner = lifecycleOwner as LifecycleOwner;
  }

  addObserver(observer: LifecycleObserver): void {
    this.parentLifecycleOwner?.addObserver(observer);
    if (DialogSelfLifecycleObserver.isDialogSelfLifecycleObserver(observer) && observer.getObserverKey()) {
      this.dialogObservers.set(observer.getObserverKey(), observer as DialogSelfLifecycleObserver);
    }
  }

  removeObserver(observerKey: string): void {
    this.parentLifecycleOwner?.removeObserver(observerKey);
    if (observerKey) {
      this.dialogObservers.delete(observerKey);
    }
  }

  /**
   * 弹框自己打开回调
   */
  onSelfOpen(): void {
    for (let observer of Array.from(this.dialogObservers.values())) {
      if (observer.onSelfOpen) {
        observer.onSelfOpen();
      }
    }
  }

  /**
   * 弹框自己关闭回调
   */
  onSelfClose(): void {
    for (let observer of Array.from(this.dialogObservers.values())) {
      if (observer.onSelfClose) {
        observer.onSelfClose();
      }
    }
  }

  /**
   * 弹框自己取消回调
   */
  onSelfCancel(): void {
    for (let observer of Array.from(this.dialogObservers.values())) {
      if (observer.onSelfCancel) {
        observer.onSelfCancel();
      }
    }
  }
}

export interface LifecycleObserverInterface {
  getObserverKey?: () => string,
}

/**
 * 生命周期监听者
 *
 * @since 2022-03-21
 */
export abstract class LifecycleObserver implements LifecycleObserverInterface {
  abstract getObserverKey(): string;

  static isLifecycleObserver(obj: Object): boolean {
    return typeof (obj as LifecycleObserver).getObserverKey === 'function';
  }
}

export interface PageLifecycle {
  onPageShow(): void;

  onPageHide(): void;
}

export interface PageLifecycleObserverInterface extends LifecycleObserverInterface, PageLifecycle {}

/**
 * 页生命周期监听者
 *
 * @since 2022-03-21
 */
export abstract class PageLifecycleObserver extends LifecycleObserver implements PageLifecycle {
  abstract onPageShow(): void;

  abstract onPageHide(): void;

  static isPageLifecycleObserver(obj: Object): boolean {
    if (typeof (obj as PageLifecycleObserver).getObserverKey !== 'function') {
      return false;
    }
    if (typeof (obj as PageLifecycleObserver).onPageShow !== 'function') {
      return false;
    }
    if (typeof (obj as PageLifecycleObserver).onPageHide !== 'function') {
      return false;
    }
    return true;
  }
}

export interface DialogLifecycle {
  onDialogOpen(key?: string, data?: Object): void;

  onDialogClose(key?: string, data?: Object): void;

  onDialogCancel(key?: string, data?: Object): void;
}

export interface DialogLifecycleObserverInterface extends DialogLifecycle, LifecycleObserverInterface {}

/**
 * 页的弹框生命周期监听者
 *
 * @since 2022-03-21
 */
export abstract class DialogLifecycleObserver extends LifecycleObserver implements DialogLifecycle {
  abstract onDialogOpen(key?: string, data?: Object): void;

  abstract onDialogClose(key?: string, data?: Object): void;

  abstract onDialogCancel(key?: string, data?: Object): void;

  static isDialogLifecycleObserver(obj: Object): boolean {
    if (typeof (obj as DialogLifecycleObserver).getObserverKey !== 'function') {
      return false;
    }
    if (typeof (obj as DialogLifecycleObserver).onDialogOpen !== 'function') {
      return false;
    }
    if (typeof (obj as DialogLifecycleObserver).onDialogClose !== 'function') {
      return false;
    }
    if (typeof (obj as DialogLifecycleObserver).onDialogCancel !== 'function') {
      return false;
    }
    return true;
  }
}

export interface DialogSelfLifecycleObserverInterface extends LifecycleObserverInterface {
  onSelfOpen(): void;

  onSelfClose(): void;

  onSelfCancel(): void;
}
/**
 * 弹框自己生命周期监听者
 *
 * @since 2022-03-21
 */
export abstract class DialogSelfLifecycleObserver extends LifecycleObserver {
  abstract onSelfOpen(): void;

  abstract onSelfClose(): void;

  abstract onSelfCancel(): void;

  static isDialogSelfLifecycleObserver(obj: Object): boolean {
    if (typeof (obj as DialogSelfLifecycleObserver).getObserverKey !== 'function') {
      return false;
    }
    if (typeof (obj as DialogSelfLifecycleObserver).onSelfOpen !== 'function') {
      return false;
    }
    if (typeof (obj as DialogSelfLifecycleObserver).onSelfClose !== 'function') {
      return false;
    }
    if (typeof (obj as DialogSelfLifecycleObserver).onSelfCancel !== 'function') {
      return false;
    }
    return true;
  }
}

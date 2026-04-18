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

import { Controller } from '../controller/Controller'
import { LifecycleOwner, LifecycleObserver, PageLifecycleOwner, DialogLifecycleOwner } from '../lifecycle/Lifecycle';
import { SettingsBaseMenu, MenuGroup, MenuSection, MenuParent, MenuPage, RootMenu } from '../model/menu/SettingsMenu';
import { OffEvent } from '../../displaymanager/DisplayManager';
import { LogUtil } from '../../utils/LogUtil';

/**
 * 动态页面，承接UI和页数据
 *
 * @since 2022-03-21
 */
export class PageRoot extends RootMenu {
  public tag: string = 'PageRoot: ';
  public menuPage?: MenuPage;
  public scroller?: Scroller;
  private lifecycleOwner?: LifecycleOwner;
  private dialog?: DialogPageRoot;
  private controllers: Map<string, Controller> = new Map();
  private observerMap: Map<string, Set<string>> = new Map();
  private firstVisibleChild?: SettingsBaseMenu;
  private firstVisibleContentChild?: SettingsBaseMenu;
  private displayOffEvent?: OffEvent;

  constructor(lifecycleOwner?: LifecycleOwner) {
    super();
    this.lifecycleOwner = lifecycleOwner;
  }

  public setScroller(scroller: Scroller): void {
    this.scroller = scroller;
  }

  public scrollToIndex(index: number): void {
    this.scroller?.scrollToIndex(index);
  }

  public scrollEdge(edge: Edge): void {
    this.scroller?.scrollEdge(edge);
  }

  public setLifecycleOwner(lifecycleOwner: LifecycleOwner): void {
    this.lifecycleOwner = lifecycleOwner;
  }

  public getControllersCount():number {
    return this.controllers.size;
  }

  public setMenuPage(menuPage: MenuPage | undefined): void {
    if (this.menuPage === menuPage) {
      return;
    }

    this.menuPage?.onHierarchyChange(undefined);
    this.menuPage = menuPage;
    this.menuPage?.onHierarchyChange(this as MenuParent);
  }

  public getMenuPage(): MenuPage {
    return this.menuPage as MenuPage;
  }

  public aboutToAppear(menuPage: MenuPage): void {
    LogUtil.debug(`${this.tag} aboutToAppear`);
    this.setMenuPage(menuPage);
    this.updateStatus();
  }

  public aboutToDisappear(): void {
    LogUtil.debug(`${this.tag} aboutToDisappear`);
    this.onPageDestroy();
    this.closeDialog();
    this.controllers.clear();
    this.observerMap.clear();
    this.firstVisibleChild = undefined;
    this.firstVisibleContentChild = undefined;
  }

  public onPageDestroy(): void {
    for (let controller of Array.from(this.controllers.values())) {
      controller?.onPageDestroy();
    }
  }

  public onPageShow(): void {
    LogUtil.debug(`${this.tag} onPageShow`);
    if (this.lifecycleOwner instanceof PageLifecycleOwner) {
      this.lifecycleOwner.onPageShow();
    }
    this.updateStatus();
  }

  public updateStatus(): void {
    this.updateFirstVisibleChild(this.getFirstVisibleChild());
    this.updateFirstVisibleContentChild(this.getFirstVisibleContentChild());
  }

  public onPageHide(): void {
    LogUtil.debug(`${this.tag} onPageHide`);
    if (this.lifecycleOwner instanceof PageLifecycleOwner) {
      this.lifecycleOwner.onPageHide();
    }
  }

  public isFirstVisibleChild(child: SettingsBaseMenu): boolean {
    return child === this.firstVisibleChild;
  }

  public isFirstVisibleContentChild(child: SettingsBaseMenu): boolean {
    return child === this.firstVisibleContentChild;
  }

  public isMenuVisible(menu: SettingsBaseMenu): boolean {
    if (!menu) {
      return false;
    }

    let controller = this.getController(menu.key as string);
    return !controller || controller.isVisibleStatus();
  }

  public getListFirstVisibleMenu(menus: SettingsBaseMenu[]): SettingsBaseMenu | undefined {
    if (!menus || menus.length === 0) {
      return undefined;
    }
    for (let menu of menus) {
      let result = this.getFirstVisibleMenu(menu);
      if (result) {
        return result;
      }
    }
    return undefined;
  }

  public getFirstVisibleMenu(menu: SettingsBaseMenu): SettingsBaseMenu | undefined {
    if (menu instanceof MenuGroup) {
      if (!this.isMenuVisible(menu)) {
        return undefined;
      }
      if (menu instanceof MenuSection) {
        let result = this.getSectionFirstVisibleChild(menu);
        if (result) {
          return result;
        }
      } else {
        let result = this.getListFirstVisibleMenu(menu.getMenus());
        if (result) {
          return result;
        }
      }
    } else {
      if (this.isMenuVisible(menu)) {
        return menu;
      }
    }
    return undefined;
  }

  public getSectionFirstVisibleChild(menuSection: MenuSection): SettingsBaseMenu | undefined {
    let menu = this.getFirstVisibleMenu(menuSection?.getHeader());
    if (menu) {
      return menu;
    }

    menu = this.getListFirstVisibleMenu(menuSection?.getMenus());
    if (menu) {
      return menu;
    }

    menu = this.getFirstVisibleMenu(menuSection?.getFooter());
    if (menu) {
      return menu;
    }

    return undefined;
  }

  private updateFirstVisibleChild(child: SettingsBaseMenu): void {
    if (this.firstVisibleChild !== child) {
      this.firstVisibleChild?.refreshUi();
      this.firstVisibleChild = child;
      this.firstVisibleChild?.refreshUi();
    }
  }

  private updateFirstVisibleContentChild(child: SettingsBaseMenu): void {
    if (this.firstVisibleContentChild !== child) {
      this.firstVisibleContentChild?.refreshUi();
      this.firstVisibleContentChild = child;
      this.firstVisibleContentChild?.refreshUi();
    }
  }

  private getFirstVisibleChild(): SettingsBaseMenu {
    let menu = this.getSectionFirstVisibleChild(this.menuPage as MenuPage);
    LogUtil.debug(`${this.tag} getFirstVisibleChild ${menu?.getLogKey()}`);
    return menu as SettingsBaseMenu;
  }


  private getFirstVisibleContentChild(): SettingsBaseMenu {
    let menu = this.getListFirstVisibleMenu(this.menuPage?.getMenus() as SettingsBaseMenu[]);
    LogUtil.debug(`${this.tag} getFirstVisibleContentChild ${menu?.getLogKey()}`);
    return menu as SettingsBaseMenu;
  }

  public onChildVisibilityChanged(child: SettingsBaseMenu, isVisible: boolean): void {
    LogUtil.debug(`${this.tag} onChildVisibilityChanged`);
    this.updateFirstVisibleChild(this.getFirstVisibleChild());
    this.updateFirstVisibleContentChild(this.getFirstVisibleContentChild());
  }

  public setDialogPageRoot(dialog: DialogPageRoot | undefined): void {
    if (this.dialog === dialog) {
      return;
    }

    this.dialog?.onAttachPageRoot(undefined);
    this.dialog = dialog;
    this.dialog?.onAttachPageRoot(this);
  }

  public getDialogControllersCount(): number {
    return this.dialog?.getControllersCount() ?? 0;
  }

  public openDialog(menuPage: MenuPage, autoCancel: boolean = true): void {
    if (this.dialog) {
      LogUtil.info(`${this.tag} openDialog`);
      this.dialog.setMenuPage(menuPage);
      this.dialog.setAutoCancel(autoCancel);
      this.dialog.openSelf(menuPage?.isPrivacy as boolean);
    }
  }

  public closeDialog(): void {
    this.dialog?.closeSelf();
  }

  public closeSelf(data?: Object): void {
  }

  public onDialogCancel(key?: string, data?: Object) {
    LogUtil.info(`${this.tag} onDialogCancel`);
    if (this.lifecycleOwner instanceof PageLifecycleOwner) {
      this.lifecycleOwner.onDialogCancel(key, data);
    }
  }

  public onDialogOpen(key?: string, data?: Object): void {
    LogUtil.info(`${this.tag} onDialogOpen`);
    if (this.lifecycleOwner instanceof PageLifecycleOwner) {
      this.lifecycleOwner.onDialogOpen(key, data);
    }
  }

  public onDialogClose(key?: string, data?: Object): void {
    LogUtil.info(`${this.tag} onDialogClose`);
    if (this.lifecycleOwner instanceof PageLifecycleOwner) {
      this.lifecycleOwner.onDialogClose(key, data);
    }
  }

  public getParent(): MenuParent | undefined {
    return undefined;
  }

  public findMenu(key: string): SettingsBaseMenu {
    return this.menuPage?.findMenu(key) as SettingsBaseMenu;
  }

  public refreshChildren(): void {
    return this.menuPage?.refreshChildren();
  }

  public getKey(): string {
    return `PageRoot:${this.menuPage?.pageUrl}`;
  }

  public getLifecycleOwner(): LifecycleOwner {
    return this.lifecycleOwner as LifecycleOwner;
  }

  public addController(key: string, controller: Controller) {
    if (!key || !controller) {
      return;
    }
    this.controllers.set(key, controller);
    if (LifecycleObserver.isLifecycleObserver(controller)) {
      this.lifecycleOwner?.addObserver(controller);
    }
  }

  public deleteController(key: string) {
    if (!key) {
      return;
    }
    if (!this.controllers.has(key)) {
      return;
    }
    let controller: Controller = this.controllers.get(key) as Controller;
    if (LifecycleObserver.isLifecycleObserver(controller)) {
      if (controller.getObserverKey) {
        this.lifecycleOwner?.removeObserver(controller.getObserverKey());
      }
    }
    this.controllers.delete(key);
    for (let observerList of Array.from(this.observerMap.values())) {
      observerList?.delete(key);
    }
  }

  public getController(key: string): Controller {
    return this.controllers.get(key) as Controller;
  }

  public getControllers(): IterableIterator<Controller> {
    return this.controllers.values();
  }

  public registerControllerObserver(changerKey: string, observerKey: string): void {
    let observerList = this.observerMap.get(changerKey);
    if (!observerList) {
      observerList = new Set();
    }
    observerList.add(observerKey);
    this.observerMap.set(changerKey, observerList);
    this.controllers.get(changerKey)?.onRegisteredByObserver(observerKey);
  }

  public unRegisterControllerObserver(changerKey: string, observerKey: string): void {
    let observerList = this.observerMap.get(changerKey);
    observerList?.delete(observerKey);
  }

  public publishControllerDataChange(changerKey: string, data: Object): void {
    let observerList = this.observerMap.get(changerKey);
    observerList?.forEach(observerKey => this.controllers.get(observerKey)?.onDataChange(changerKey, data));
  }
}

/**
 * 弹框动态页面，承接UI和弹框页数据
 *
 * @since 2022-03-21
 */
export class DialogPageRoot extends PageRoot {
  public tag: string = 'DialogPageRoot: ';
  public autoCancelController?: CustomDialogController;
  public autoCancelDisableController?: CustomDialogController;
  public dialogController?: CustomDialogController;
  public dialogLifecycleOwner?: DialogLifecycleOwner;
  public autoCancel: boolean = true;
  public hostPageRoot?: PageRoot;

  constructor(lifecycleOwner?: DialogLifecycleOwner) {
    super(lifecycleOwner)
    this.dialogLifecycleOwner = lifecycleOwner;
  }

  public onAttachPageRoot(pageRoot: PageRoot | undefined) {
    this.hostPageRoot = pageRoot as PageRoot;
    this.setLifecycleOwner(new DialogLifecycleOwner(this.hostPageRoot?.getLifecycleOwner())); // 弹框生命周期宿主
  }

  /**
   * 设置弹框句柄
   *
   * @param autoCancelController 可自动取消的弹框
   * @param autoCancelDisableController 不可自动取消的弹框
   */
  public setDialogController(autoCancelController: CustomDialogController | undefined,
                      autoCancelDisableController: CustomDialogController | undefined,): DialogPageRoot {
    this.autoCancelController = autoCancelController;
    this.autoCancelDisableController = autoCancelDisableController;
    return this;
  }

  public setAutoCancel(autoCancel: boolean): DialogPageRoot {
    this.autoCancel = autoCancel;
    return this;
  }

  public onSelfCancel(): void {
    LogUtil.info(`${this.tag} onSelfCancel`);
    this.hostPageRoot?.onDialogCancel(this.menuPage?.pageUrl);
    this.dialogLifecycleOwner?.onSelfCancel();
  }

  public onSelfCancelBindThis = () => {
    this.onSelfCancel();
  }

  public onSelfOpen(key: string, data?: Object): void {
    LogUtil.info(`${this.tag} onSelfOpen!`);
    this.hostPageRoot?.onDialogOpen(key, data);
    this.dialogLifecycleOwner?.onSelfOpen();
  }

  public onSelfClose(key: string, data?: Object): void {
    LogUtil.info(`${this.tag} onSelfClose!`);
    this.hostPageRoot?.onDialogClose(key, data);
    this.dialogLifecycleOwner?.onSelfClose();
  }

  public openSelf(isPrivacy: boolean): void {
    LogUtil.info(`${this.tag} openSelf`);
    this.dialogController = this.getDialogController();
    if (this.dialogController) {
      this.dialogController.close();
      this.dialogController.open();
      this.onSelfOpen(this.menuPage?.pageUrl as string, isPrivacy);
    }
  }

  private getDialogController() {
    return this.autoCancel ? this.autoCancelController : this.autoCancelDisableController;
  }

  public closeSelf(data?: Object): void {
    LogUtil.info(`${this.tag} closeSelf ${this.dialogController}`);
    if (this.dialogController) {
      this.dialogController.close();
      this.onSelfClose(this.menuPage?.pageUrl as string, data);
    }
  }

  public aboutToDisappear(): void {
    super.aboutToDisappear();
    this.dialogController = undefined;
  }
}

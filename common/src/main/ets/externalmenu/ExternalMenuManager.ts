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

import type { BusinessError } from '@ohos.base';
import bundle from '@ohos.bundle.bundleManager';
import OsAccount from '@ohos.account.osAccount';
import abilityAccessCtrl from '@ohos.abilityAccessCtrl';
import type resourceManager from '@ohos.resourceManager';
import { MemoryMgrUtils } from '../utils/MemoryMgrUtils';
import { LogUtil } from '../utils/LogUtil';
import { SettingsDataUtils } from '../utils/SettingsDataUtils';
import { BundleStatusChangeManager, BundleStatusChangeListener } from '../bundle/BundleStatusChangeManager';
import { ResourceManagerUtil } from '../utils/ResourceManagerUtil';

const IS_DEBUG = false;
const TAG = 'ExternalMenuManager : ';
const EXTERNAL_MENU_ACTION_V1 = 'action.settings.menu.v1';
const EXTERNAL_MENU_METADATA_V1 = 'metadata.settings.menu.v1';

/**
 * 外部菜单数据类
 *
 * @since 2022-06-25
 */
export class ExternalMenu {
  public bundleName: string;
  public abilityName: string;
  public key: string;
  public menuType: string;
  public showCondition: string;
  public titleResource: string;
  public title: string;
  public state: string;
  public iconResource: string;
  public icon: string;
  public summaryResource: string;
  public summary: string;
  public stateDbKey: string;
  public stateDefault: string;
  public switchDbKey: string;
  public switchDefault: string;
  public accessTokenId: number;

  constructor(menu: ExternalMenu) {
    if (!menu) {
      return;
    }
    this.key = menu.key;
    this.menuType = menu.menuType;
    this.showCondition = menu.showCondition;
    this.titleResource = menu.titleResource;
    this.iconResource = menu.iconResource;
    this.summaryResource = menu.summaryResource;
    this.stateDbKey = menu.stateDbKey;
    this.stateDefault = menu.stateDefault;
    this.switchDbKey = menu.switchDbKey;
    this.switchDefault = menu.switchDefault;
  }

  /**
   * 加载标题资源
   *
   * @param resourceManager 当前的resourceManager
   */
  loadTitleResourceNew(resourceManager: resourceManager.ResourceManager | null): string {
    LogUtil.info(`${TAG} loadTitleResource: ${this.titleResource}`);
    if (!this.titleResource) {
      return '';
    }
    if (!resourceManager) {
      resourceManager = ResourceManagerUtil.getBundleResourceManager(this.bundleName);
      if (!resourceManager) {
        return '';
      }
    }
    try {
      this.title = resourceManager.getStringByNameSync(this.titleResource);
    } catch (err) {
      LogUtil.error(`${TAG} get title failed ${err?.message}`);
    }
    return this.title;
  }

  /**
   * 加载辅助文本资源
   *
   * @param resourceManager 当前的resourceManager
   */
  loadSummaryResourceNew(resourceManager: resourceManager.ResourceManager | null): string {
    LogUtil.info(`${TAG} loadSummaryResource: ${this.summaryResource}`);
    if (!this.summaryResource) {
      return '';
    }
    if (!resourceManager) {
      resourceManager = ResourceManagerUtil.getBundleResourceManager(this.bundleName);
      if (!resourceManager) {
        return '';
      }
    }
    try {
      this.summary = resourceManager.getStringByNameSync(this.summaryResource);
    } catch (err) {
      LogUtil.error(`${TAG} get summary failed ${err?.message}`);
    }
    return this.summary;
  }

  /**
   * 加载状态文本资源
   *
   * @param context 当前的Context
   */
  loadStateResource(): string {
    if (!this.stateDbKey) {
      return '';
    }
    let stateResource = SettingsDataUtils.getSettingsData(this.stateDbKey, this.stateDefault ?? '');
    this.state = this.loadStringResource(stateResource);
    return this.state;
  }

  /**
   * 加载文本资源
   *
   * @param resString 资源名称
   * @param context 当前的Context
   */
  loadStringResource(resString: string): string {
    if (!resString) {
      return '';
    }
    let resourceManager = ResourceManagerUtil.getBundleResourceManager(this.bundleName);
    if (!resourceManager) {
      return '';
    }
    try {
      let result: string = resourceManager.getStringByNameSync(resString);
      MemoryMgrUtils.removeNapiWrap(resourceManager, false);
      return result;
    } catch (err) {
      LogUtil.error(`${TAG} get string resource failed ${err?.message}`);
    }
    return '';
  }

  async hasPermission(atManager: any): Promise<boolean> {
    LogUtil.info(`${TAG} verifyAccessToken enter`);
    let currentAtManager = atManager ?? abilityAccessCtrl.createAtManager();
    let grantStatus = await currentAtManager.verifyAccessToken(this.accessTokenId,
      'ohos.permission.ACCESS_SYSTEM_SETTINGS');
    LogUtil.info(`${TAG} grantStatus`);
    return grantStatus === abilityAccessCtrl.GrantStatus.PERMISSION_GRANTED;
  }

  /**
   * 打印externalMenu信息，供调测使用
   */
  public print(): void {
    if (IS_DEBUG) {
      let hasIcon = this.icon ? 'true' : 'false';
      LogUtil.debug(`${TAG} ExternalMenu:${this.key}, ${this.title}, ${this.summary}, ${this.state}, icon:${hasIcon}`);
    }
  }
}

/**
 * 外部菜单数据变更监听接口
 *
 * @since 2022-06-25
 */
export interface ExternalMenuChangeListener {
  /**
   * 获取 listener name
   * @returns listener name
   */
  getListenerName(): string;

  /**
   * 外部菜单数据变更回调
   */
  onExternalMenuChange(bundleName: string): void;

  /**
   * 外部菜单数据加载完成回调
   */
  onExternalMenuLoadFinish(): void;
}

/**
 * 语言变化时回调接口
 *
 * @since 2023-08-25
 */
export interface LangChangeListener {
  /**
   * 语言变化回调事件
   */
  onLangChange(newLang: string): void;

  /**
   * 获取 listener name
   * @returns listener name
   */
  getListenerName(): string;
}

/**
 * 外部菜单数据管理类
 *
 * @since 2022-06-25
 */
export class ExternalMenuManager implements BundleStatusChangeListener {
  public listenerKey: string = 'external_menu_manager';
  public externalMenus: Map<string, Array<ExternalMenu>> = new Map();
  public grantExternalMenus: Map<string, ExternalMenu> = new Map();
  public bundleMenuKeys: Map<string, Array<string>> = new Map();
  public listeners: ExternalMenuChangeListener[] = [];
  public grantStatusMap: Map<string, boolean> = new Map();
  public queryFlag: number = bundle.AbilityFlag.GET_ABILITY_INFO_WITH_METADATA |
    bundle.AbilityFlag.GET_ABILITY_INFO_WITH_APPLICATION;
  public queryExtentionFlag: number = bundle.ExtensionAbilityFlag.GET_EXTENSION_ABILITY_INFO_WITH_METADATA |
    bundle.ExtensionAbilityFlag.GET_EXTENSION_ABILITY_INFO_WITH_APPLICATION;
  atManager: any = abilityAccessCtrl.createAtManager();
  public langChangeListeners: LangChangeListener[] = [];

  registerLangChangeListener(listener: LangChangeListener): void {
    if (!listener) {
      LogUtil.error(`${TAG} registerLangChangeListener invalid`);
      return;
    }

    for (const langChangeListener of this.langChangeListeners) {
      if (langChangeListener.getListenerName() === listener.getListenerName()) {
        LogUtil.info(`${TAG} registerLangChangeListener listener already register`);
        return;
      }
    }

    this.langChangeListeners.push(listener);
    LogUtil.info(`${TAG} push: ${listener.getListenerName()} size: ${this.langChangeListeners.length}`);
  }

  unregisterLangChangeListener(listener: LangChangeListener): void {
    if (!listener) {
      LogUtil.error(`${TAG} unregisterLangChangeListener invalid`);
      return;
    }
    for (let index = 0; index < this.langChangeListeners.length; index++) {
      if (this.langChangeListeners[index].getListenerName() === listener.getListenerName()) {
        LogUtil.info(`${TAG} unregisterLangChangeListener success: ${listener.getListenerName()}`);
        this.langChangeListeners.splice(index, 1);
        return;
      }
    }
  }

  /**
   * 语言变化时的回调，触发外部菜单的文本资源刷新
   *
   * @param newLang 新的语言
   * */
  public dispatchLangChangeEvent(newLang: string): void {
    LogUtil.info(`${TAG} dispatchLangChangeEvent`);
    for (let listener of this.langChangeListeners) {
      listener?.onLangChange(newLang);
    }
  }

  /**
   * 根据Key获取外部菜单数据
   *
   * @param key 外部菜单唯一标识符
   */
  async getExternalMenu(key: string): Promise<ExternalMenu> {
    LogUtil.info(`${TAG} getExternalMenu`);
    let menu = this.grantExternalMenus.get(key);
    return menu ?? this.updateGrantMenuList(this.externalMenus.get(key));
  }

  /**
   * 监听应用变更
   *
   * @param listener 监听者
   */
  registerListener(listener: ExternalMenuChangeListener): void {
    if (!listener) {
      LogUtil.error(`${TAG} registerListener listener invalid`);
      return;
    }

    for (let index = 0; index < this.listeners.length; index++) {
      if (this.listeners[index].getListenerName() === listener.getListenerName()) {
        LogUtil.info(`${TAG} registerListener listener already register`);
        return;
      }
    }
    this.listeners.push(listener);
    LogUtil.info(`${TAG} listeners size: ${this.listeners.length}`);
  }

  /**
   * 取消监听应用变更
   *
   * @param listener 监听者
   */
  unRegisterListener(listener: ExternalMenuChangeListener): void {
    if (!listener) {
      LogUtil.error(`${TAG} unRegisterListener listener invalid`);
      return;
    }
    for (let index = 0; index < this.listeners.length; index++) {
      if (this.listeners[index].getListenerName() === listener.getListenerName()) {
        this.listeners.splice(index, 1);
        return;
      }
    }
  }

  /**
   * 开始加载外部应用菜单数据
   */
  async startLoad(errCallBack?: (err: BusinessError) => void): Promise<void> {
    LogUtil.info(`${TAG} startLoad`);
    BundleStatusChangeManager.getInstance().registerBundleChangedListener(this);
    await bundle.queryAbilityInfo({
      action: EXTERNAL_MENU_ACTION_V1
    }, this.queryFlag).then((infos: Array<bundle.AbilityInfo>) => {
      LogUtil.info(`${TAG} queryAbilityInfo in`);
      this.updateAbilityInfos(infos).then(() => {
        LogUtil.info(`${TAG} updateGrantStatus`);
        this.updateGrantStatus();
        this.dispatchExternalMenuLoadFinish();
      });
    });
  }

  async startLoadExtentionAbilityAsync(): Promise<void> {
    LogUtil.info(`${TAG} startLoadExtentionAbilityAsync`);
    let extensionAbilityInfos: Array<bundle.AbilityInfo | bundle.ExtensionAbilityInfo> = bundle.queryExtensionAbilityInfoSync({
      action: EXTERNAL_MENU_ACTION_V1
    }, 'sys/commonUI', this.queryExtentionFlag);

    let abilityInfos: Array<bundle.AbilityInfo | bundle.ExtensionAbilityInfo> = await bundle.queryAbilityInfo({
      action: EXTERNAL_MENU_ACTION_V1
    }, this.queryFlag);

    this.updateAbilityInfos(extensionAbilityInfos.concat(abilityInfos)).then(() => {
      LogUtil.info(`${TAG} updateGrantStatus`);
      this.updateGrantStatus();
      this.dispatchExternalMenuLoadFinish();
    });
  }

  private dispatchExternalMenuLoadFinish(): void {
    LogUtil.info(`${TAG} dispatchExternalMenuLoadFinish`);
    for (let listener of this.listeners) {
      listener?.onExternalMenuLoadFinish();
    }
  }

  private clearCache(): void {
    this.externalMenus.clear();
    this.grantExternalMenus.clear();
    this.grantStatusMap.clear();
    this.bundleMenuKeys.clear();
  }

  private async updateAbilityInfos(infos: Array<bundle.AbilityInfo | bundle.ExtensionAbilityInfo>): Promise<void> {
    if (!infos) {
      LogUtil.info(`${TAG} updateAbilityInfos infos invalid`);
      this.clearCache();
      return;
    }

    let menus: Map<string, Array<ExternalMenu>> = new Map();
    for (let info of infos) {
      let parseMenus = await Promise.resolve(this.parseAbilityInfo(info));
      for (let menu of parseMenus) {
        LogUtil.debug(`${TAG} Found ExternalMenu key: ${menu.key}`);
        this.addMapMenu(menus, menu);
        this.addBundleMenuKey(menu);
      }
    }
    this.externalMenus = menus;
    LogUtil.info(`${TAG} updateAbilityInfos size: ${this.externalMenus.size}`);
  }

  private addMapMenu(menus: Map<string, Array<ExternalMenu>>, menu: ExternalMenu): void {
    let keyMenus: Array<ExternalMenu> = menus.get(menu.key);
    if (!keyMenus) {
      keyMenus = [];
    }
    keyMenus.push(menu);
    menus.set(menu.key, keyMenus);
  }

  private addBundleMenuKey(menu: ExternalMenu): void {
    let keys = this.bundleMenuKeys.get(menu.bundleName);
    if (!keys) {
      keys = new Array<string>();
      this.bundleMenuKeys.set(menu.bundleName, keys);
    }
    keys.push(menu.key);
  }

  private async updateGrantStatus(): Promise<void> {
    for (let value of this.externalMenus.values()) {
      let grantExternalMenus = this.grantExternalMenus;
      this.updateGrantMenuList(value).then((grantMenu: ExternalMenu) => {
        if (grantMenu) {
          grantExternalMenus.set(grantMenu.key, grantMenu);
        }
      });
    }
  }

  private async updateGrantMenuList(list: Array<ExternalMenu>): Promise<ExternalMenu> {
    if (!list) {
      LogUtil.error(`${TAG} updateGrantMenuList invalid`);
      return null;
    }
    for (let menu of list) {
      let isGrant = true; // await this.isGrantMenu(menu) 权限合入后需要鉴权
      if (isGrant) {
        return menu;
      }
    }
    return null;
  }

  private async isGrantMenu(menu: ExternalMenu): Promise<boolean> {
    if (this.grantStatusMap.has(menu.bundleName)) {
      return this.grantStatusMap.get(menu.bundleName);
    }
    let isGrant = await menu.hasPermission(this.atManager);
    this.grantStatusMap.set(menu.bundleName, isGrant);
    return isGrant;
  }

  onBundleAdd(bundleName: string, userId: number, appIndex: number): void {
    if (!bundleName) {
      LogUtil.error(`${TAG} onBundleAdd bundleName invalid`);
      return;
    }
    LogUtil.info(`${TAG} onBundleAdd : bundleName:${bundleName} userId:${userId} appIndex:${appIndex}`);
    OsAccount.getAccountManager().isOsAccountActived(userId).then((isActive: boolean) => {
      LogUtil.info(TAG + 'isActive : ' + isActive);
      if (isActive) {
        this.queryAndAddBundleMenus(bundleName);
        this.dispatchExternalMenuChange(bundleName);
      }
    });
  }

  private queryAndAddBundleMenus(bundleName: string): void {
    bundle.queryAbilityInfo({
      action: EXTERNAL_MENU_ACTION_V1,
      bundleName: bundleName
    }, this.queryFlag).then((infos: Array<any>) => {
      this.addBundleAbilityInfos(infos);
    });
  }

  private addBundleAbilityInfos(infos: Array<bundle.AbilityInfo>): void {
    if (!infos) {
      LogUtil.info(`${TAG} addBundleAbilityInfos infos invalid`);
      return;
    }

    for (let info of infos) {
      let parseMenus = this.parseAbilityInfo(info);
      for (let menu of parseMenus) {
        LogUtil.info(`${TAG} add ExternalMenu key: ${menu.key}`);
        this.addMapMenu(this.externalMenus, menu);
        this.addBundleMenuKey(menu);
      }
    }
  }

  private parseAbilityInfo(info: bundle.AbilityInfo | bundle.ExtensionAbilityInfo): Array<ExternalMenu> {
    let menus = new Array<ExternalMenu>();

    if (IS_DEBUG) {
      LogUtil.info(`${TAG} parseAbilityInfo`);
    }

    if (!info || !info.metadata) {
      LogUtil.info(`${TAG} parseAbilityInfo info invalid`);
      return menus;
    }

    for (let metadata of info.metadata) {
      if (!metadata || metadata.name !== EXTERNAL_MENU_METADATA_V1) {
        LogUtil.warn(`${TAG} parseAbilityInfo metadata name invalid`);
        continue;
      }

      let menuObj;
      try {
        menuObj = JSON.parse(metadata.value)?.menu;
      } catch (err) {
        LogUtil.warn(`${TAG} parseAbilityInfo parse invalid`);
        continue;
      }

      if (!menuObj) {
        LogUtil.warn(`${TAG} parseAbilityInfo metadata invalid`);
        continue;
      }

      let menu = new ExternalMenu(menuObj);
      menu.bundleName = info.bundleName;
      menu.abilityName = info.name;
      menu.accessTokenId = info.applicationInfo?.accessTokenId;
      menus.push(menu);
    }
    return menus;
  }

  onBundleUpdate(bundleName: string, userId: number, appIndex: number): void {
    if (!bundleName) {
      LogUtil.error(`${TAG} onBundleUpdate bundleName invalid`);
      return;
    }
    LogUtil.info(`${TAG} onBundleUpdate : bundleName:${bundleName} userId:${userId} appIndex:${appIndex}`);
    OsAccount.getAccountManager().isOsAccountActived(userId).then((isActive: boolean) => {
      LogUtil.info(`${TAG} isActive: ${isActive}`);
      if (isActive) {
        this.removeBundleMenus(bundleName);
        this.queryAndAddBundleMenus(bundleName);
        this.dispatchExternalMenuChange(bundleName);
      }
    });
  }

  onBundleRemove(bundleName: string, userId: number, appIndex: number): void {
    if (!bundleName) {
      LogUtil.error(`${TAG} onBundleRemove bundleName invalid`);
      return;
    }
    LogUtil.info(`${TAG} onBundleRemove : bundleName:${bundleName} userId:${userId} appIndex:${appIndex}`);
    OsAccount.getAccountManager().isOsAccountActived(userId).then((isActive: boolean) => {
      LogUtil.info(`${TAG} isActive: ${isActive}`);
      if (isActive) {
        this.removeBundleMenus(bundleName);
        this.dispatchExternalMenuChange(bundleName);
      }
    });
  }

  private removeBundleMenus(bundleName: string): void {
    for (let key of this.bundleMenuKeys.get(bundleName)) {
      this.externalMenus.delete(key);
      this.grantExternalMenus.delete(key);
    }
    this.bundleMenuKeys.delete(bundleName);
  }

  private dispatchExternalMenuChange(key: string): void {
    for (let listener of this.listeners) {
      listener?.onExternalMenuChange(key);
    }
  }

  getListenerName(): string {
    return this.listenerKey ?? ' ';
  }

  static getInstance(): ExternalMenuManager {
    if (!Boolean(AppStorage.get<ExternalMenuManager>('externalMenuManager') as ExternalMenuManager).valueOf()) {
      AppStorage.setOrCreate<ExternalMenuManager>('externalMenuManager', new ExternalMenuManager());
    }
    return AppStorage.get<ExternalMenuManager>('externalMenuManager') as ExternalMenuManager;
  }
}

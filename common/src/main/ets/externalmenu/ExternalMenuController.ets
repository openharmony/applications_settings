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

import { LogUtil } from '../utils/LogUtil';
import { SettingsDataUtils } from '../utils/SettingsDataUtils';
import { externalMenuPreferences } from './ExternalMenuPreferences';
import { MenuController } from '../core/controller/MenuController';
import {
  ExternalMenuManager,
  ExternalMenu,
  ExternalMenuChangeListener,
  LangChangeListener
} from './ExternalMenuManager';
import { AbilityUtils } from '../utils/AbilityUtils';
import { HiSysEventUtil } from '../systemEvent/HiSysEventUtil';
import { PageLifecycleObserverInterface } from '../core/lifecycle/Lifecycle';
import i18n from '@ohos.i18n';
import dataShare from '@ohos.data.dataShare';
import { SettingsBaseMenu } from '../core/model/menu/SettingsMenu';
import { Controller } from '../core/controller/Controller';

const ENTER_EXTERNAL_ENTRY: string = 'enter_external_entry';

/**
 * 外部菜单控制器类
 *
 * @since 2022-06-25
 */
export class ExternalMenuController extends MenuController implements ExternalMenuChangeListener,
PageLifecycleObserverInterface, LangChangeListener {
  public tag: string = 'ExternalMenuController : ';
  public externalMenu?: ExternalMenu;
  public language?: string;

  constructor(menu: SettingsBaseMenu) {
    super(menu);
  }

  static createExternalMenuController(menu: SettingsBaseMenu): Controller {
    return new ExternalMenuController(menu)
  }

  public onLangChange(newLang: string): void {
    if (this.externalMenu && this.externalMenu.key) {
      LogUtil.info(`${this.tag} onLangChange to ${newLang}, reload menu: ${this.externalMenu.key}`);
      this.enforceReloadContentResource();
    }
  }

  public getListenerName(): string {
    return this.menu.key ?? ' ';
  }

  public updateStatus(): void {
    super.updateStatus();
    this.loadContentResourceForInit(false);
  }

  public getObserverKey = (): string => {
    return this.menu?.key as string;
  }

  public onPageShow(): void {
    if (this.getCurrentVisibleStatus()) {
      this.loadResource();
    }
  }

  public onPageHide(): void {
  }

  public onExternalMenuChange(bundleName: string): void {
    if (this.externalMenu?.bundleName === bundleName) {
      LogUtil.info(`${this.tag} onExternalMenuChange ${bundleName}`);
      this.loadExternalMenu();
    }
  }

  public onExternalMenuLoadFinish(): void {
    LogUtil.info(`${this.tag} onExternalMenuLoadFinish ${this.menu?.key}`);
    this.loadExternalMenu();
  }

  public async loadContentResourceForInit(force: boolean): Promise<void> {
    LogUtil.info(`${this.tag} loadContentResourceForInit force ${force} ${this.menu?.key}`);
    this.externalMenu = await ExternalMenuManager.getInstance().getExternalMenu(this.menu.key);
    if (this.externalMenu) {
      let resource: string[] = externalMenuPreferences.getTitleAndSummaryResource(this.externalMenu, force);
      this.menu.title = resource[0];
      this.menu.summary = resource[1];
      LogUtil.info(`${this.tag} loadContentResourceForInit ${this.menu.title} `);
    }
  }

  protected registerDataChange(): void {
    ExternalMenuManager.getInstance().registerListener(this);
    ExternalMenuManager.getInstance().registerLangChangeListener(this);
  }

  protected unRegisterDataChange(): void {
    ExternalMenuManager.getInstance().unRegisterListener(this);
    ExternalMenuManager.getInstance().unregisterLangChangeListener(this);
  }

  protected async loadExternalMenu(): Promise<void> {
    LogUtil.info(`${this.tag} loadExternalMenu ${this.menu?.key}`);
    this.externalMenu = await ExternalMenuManager.getInstance().getExternalMenu(this.menu.key);
    if (!this.externalMenu) {
      LogUtil.info(`${this.tag} externalMenu not exist ${this.getLogKey()}`);
      this.setVisible(false);
      return;
    }
  }

  protected loadResource(): void {
    LogUtil.info(`${this.tag} loadResource ${this.menu?.key}`);
    let currentLanguage = i18n.System.getSystemLanguage();
    externalMenuPreferences.getDisplayVersion();
    LogUtil.info(`${this.tag} load resource language ${this.language} to ${currentLanguage}`);
    let forceRefresh: boolean = (this.language !== undefined) && (this.language !== currentLanguage);
    this.language = currentLanguage;
    this.loadContentResource(forceRefresh);
  }

  protected enforceReloadContentResource(): void {
    LogUtil.info(`${this.tag} enforceReloadContentResource ${this.menu?.key}`);
    let resource: string[] = externalMenuPreferences.getTitleAndSummaryResource(this.externalMenu, true);
    this.menu.title = resource[0];
    this.menu.summary = resource[1];
    this.setVisible(true);
    this.refreshUi();
  }

  protected loadContentResource(force: boolean): void {
    LogUtil.info(`${this.tag} force ${force}`);
    const curTitle: ResourceStr | undefined = this.menu.title;
    let resource: string[] = externalMenuPreferences.getTitleAndSummaryResource(this.externalMenu, force);
    this.menu.title = resource[0];
    this.menu.summary = resource[1];
    if (!force && String(this.menu.title) === String(curTitle)) {
      LogUtil.info(`${this.tag} title is same, no need to refreshUi`);
      return;
    }
    this.setVisible(true);
    this.refreshUi();
  }

  public onMenuClick(): boolean {
    let message: string = 'bundleName: ' + this.externalMenu?.bundleName + '; abilityName: ' +
      this.externalMenu?.abilityName;
    HiSysEventUtil.reportEntryEvent(ENTER_EXTERNAL_ENTRY, message);
    AbilityUtils.startAbility({
      bundleName: this.externalMenu?.bundleName,
      abilityName: this.externalMenu?.abilityName,
    });
    return true;
  }
}

export class UIExtensionMenuController extends ExternalMenuController {
  static CreateUIExtensionMenuController(menu: SettingsBaseMenu): Controller {
    return new UIExtensionMenuController(menu);
  }

  public tag: string = 'UIExtensionMenuController : ';

  public onMenuClick(): boolean {
    if (this.menu && this.menu.pathInfos) {
      let message: string = 'bundleName: ' + this.externalMenu?.bundleName + '; abilityName: ' +
        this.externalMenu?.abilityName;
      HiSysEventUtil.reportEntryEvent(ENTER_EXTERNAL_ENTRY, message);
      this.menu.pathInfos.clear();
      this.menu.pushName(this.menu.key as string, undefined);
      return true;
    }
    return false;
  }
}

export class UIExtensionSubMenuController extends UIExtensionMenuController {
  static CreateUIExtensionSubMenuController(menu: SettingsBaseMenu): Controller {
    return new UIExtensionSubMenuController(menu);
  }

  public tag: string = 'UIExtensionSubMenuController : ';

  public onMenuClick(): boolean {
    if (this.menu && this.menu.pathInfos) {
      let message: string = 'bundleName: ' + this.externalMenu?.bundleName + '; abilityName: ' +
        this.externalMenu?.abilityName;
      HiSysEventUtil.reportEntryEvent(ENTER_EXTERNAL_ENTRY, message);
      this.menu.pushName(this.menu.key as string, undefined);
      return true;
    }
    return false;
  }
}

export class ExternalStateController extends ExternalMenuController {
  public tag: string = 'ExternalStateController : ';
  private dataHelper?: dataShare.DataShareHelper;
  public onSettingsDataChange = () => {
    this.updateMenuState();
  }

  protected loadResource(): void {
    super.loadResource();
    this.updateMenuState();
  }

  private updateMenuState(): void {
    this.menu.state = this.externalMenu?.state ?? this.externalMenu?.loadStateResource();
    this.refreshUi();
    LogUtil.info(`${this.tag} ${this.menu.state}`);
  }

  protected registerDataChange(): void {
    super.registerDataChange();
    if (this.dataHelper) {
      SettingsDataUtils.registerDataChange(this.dataHelper, this.externalMenu?.stateDbKey, this.onSettingsDataChange)
    } else {
      (SettingsDataUtils.createDataHelper(this.externalMenu?.stateDbKey as string) as
      Promise<dataShare.DataShareHelper>).then((dataShareHelper) => {
        if (dataShareHelper) {
          this.dataHelper = dataShareHelper;
          SettingsDataUtils.registerDataChange(this.dataHelper, this.externalMenu?.stateDbKey,
            this.onSettingsDataChange);
        }
      })
    }
  }

  protected unRegisterDataChange(): void {
    super.unRegisterDataChange();
    SettingsDataUtils.unRegisterDataChange(this.dataHelper, this.externalMenu?.stateDbKey);
  }
}

export class ExternalSwitchController extends ExternalMenuController {
  public tag: string = 'ExternalSwitchController : ';
  private isChecked: boolean = true;
  private dataHelper?: dataShare.DataShareHelper;
  public onSettingsDataChange = () => {
    this.updateSwitchState();
  }

  protected async loadResource(): Promise<void> {
    super.loadResource();
    LogUtil.info(`${this.tag} loadResource switchDbKey ${this.externalMenu?.switchDbKey}`);
    LogUtil.info(`${this.tag} loadResource switchDefault ${this.externalMenu?.switchDefault}`);
    this.updateSwitchState();
  }

  private updateSwitchState(): void {
    let isChecked = this.updateCheckedState();
    this.setChecked(isChecked);
  }

  protected registerDataChange(): void {
    super.registerDataChange();
    if (this.dataHelper) {
      SettingsDataUtils.registerDataChange(this.dataHelper, this.externalMenu?.switchDbKey, this.onSettingsDataChange);
    } else {
      (SettingsDataUtils.createDataHelper(this.externalMenu?.stateDbKey as string) as
      Promise<dataShare.DataShareHelper>).then((dataShareHelper?: dataShare.DataShareHelper | undefined) => {
        if (dataShareHelper) {
          this.dataHelper = dataShareHelper;
          SettingsDataUtils.registerDataChange(this.dataHelper, this.externalMenu?.switchDbKey,
            this.onSettingsDataChange);
        }
      })
    }
  }

  protected unRegisterDataChange(): void {
    super.unRegisterDataChange();
    SettingsDataUtils.unRegisterDataChange(this.dataHelper, this.externalMenu?.switchDbKey);
  }

  /**
   * 返回开关的实时状态
   */
  protected updateCheckedState(): boolean {
    return SettingsDataUtils.getSettingsData(this.externalMenu?.switchDbKey,
      this.externalMenu?.switchDefault) === '1';
  }

  public onToggleChange(isOn: boolean): boolean {
    LogUtil.info(`${this.tag} onToggleChange ${isOn}`);

    // isOn 可能是 0/1 , 必须转换成boolean值 true/false, 否则开关控件不兼容，有异常
    let booleanValue = Boolean(isOn).valueOf();

    if (!this.handleCheckedChange(booleanValue)) {
      LogUtil.error(`${this.tag} handleCheckedChange fail`);
      this.refreshUi();
      return false;
    }

    this.isChecked = booleanValue;
    LogUtil.info(`${this.tag} handleCheckedChange success, isChecked : ${this.isChecked}`);
    return true;
  }

  /**
   * 返回开关的保存状态
   */
  public getChecked(): boolean {
    LogUtil.info(`${this.tag} getChecked ${this.isChecked}`);
    return this.isChecked;
  }

  /**
   * 设置开关的状态
   */
  public setChecked(isChecked: boolean): void {
    LogUtil.info(`${this.tag} setChecked ${isChecked}`);
    if (this.isChecked !== isChecked) {
      this.isChecked = isChecked;
      LogUtil.info(`${this.tag} setChecked, refresh : ${this.isChecked}`);
      this.refreshUi();
    }
  }

  /**
   * 开关变化的回调
   */
  protected handleCheckedChange(isChecked: boolean): boolean {
    SettingsDataUtils.setSettingsData(this.externalMenu?.switchDbKey, isChecked ? '1' : '0');
    return true;
  }
}

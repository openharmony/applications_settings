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

import bundle from '@ohos.bundle.bundleManager';
import bundleManager from '@ohos.bundle.bundleManager';
import defaultAppMgr from '@ohos.bundle.defaultAppManager';
import { EventBus } from '@ohos/settings.common/src/main/ets/framework/common/EventBus';
import { DynamicDataSource } from '@ohos/settings.common/src/main/ets/framework/model/DynamicDataSource';
import {
  CompCtrlParam,
  ComponentControl,
  SettingBaseModel,
} from '@ohos/settings.common/src/main/ets/framework/model/SettingBaseModel';
import {
  ItemResultType,
  ItemType,
  SettingIconStyle,
  SettingIconType,
  SettingItemModel } from '@ohos/settings.common/src/main/ets/framework/model/SettingItemModel';
import { LogUtil } from '@ohos/settings.common/src/main/ets/utils/LogUtil';
import { PreferencesUtil } from '@ohos/settings.common/src/main/ets/utils/PreferencesUtil';
import { PushParam } from '@ohos/settings.common/src/main/ets/core/controller/Controller';
import { ResourceUtil } from '@ohos/settings.common/src/main/ets/utils/ResourceUtil';
import { EmailRadioController } from './EmailRadioController';
import { AppListInfo } from '../model/SettingAppItemModel';
import { AppListLoader } from '../AppListLoader';
import { DefaultMailUtil } from '../util/DefaultMailUtil';
import { AppEntry } from '../AppModel';
/* instrument ignore file */
const TAG = 'EmailListController: ';
const MAIL_LIST_DATA: string = 'mail_list_data';

export class EmailListController implements ComponentControl {
  private compId: string = '';
  private params: PushParam = new PushParam();
  private dataSource: DynamicDataSource = new DynamicDataSource();
  private radioController?: EmailRadioController;
  private bundleName: string = '';
  private isSystemApp: boolean = true;

  private appListAddCb = (data: object, appIndex: number) => {
    LogUtil.info(`${TAG} app add`);
    let bundleName = (data as String).toString();
    if (bundleName) {
      this.onAppListAdd(bundleName, appIndex);
    }
  };

  private appListRemoveCb = (data: object, appIndex: number) => {
    LogUtil.info(`${TAG} app remove`);
    let bundleName = (data as String).toString();
    if (bundleName) {
      this.onAppListRemove(bundleName, appIndex);
    }
  };

  constructor(radioController: EmailRadioController, isSystemApp: boolean) {
    this.isSystemApp = isSystemApp;
    this.radioController = radioController;
  }

  init(compParam: CompCtrlParam): void {
    LogUtil.showInfo(TAG, `onInit`);
    if (!compParam || !compParam.compId) {
      LogUtil.error(`${TAG} init fail, compParam is invalid`);
      return;
    }
    LogUtil.info(`${TAG} init begin: ${compParam.compId}`);
    this.compId = compParam.compId;
    this.params = compParam.param as PushParam;
    this.dataSource = compParam.dataSource as DynamicDataSource;

    EventBus.getInstance().on('EVENT_ID_APP_LIST_ADD', this.appListAddCb);
    EventBus.getInstance().on('EVENT_ID_APP_LIST_REMOVE', this.appListRemoveCb);
  }

  private async initData(): Promise<void> {
    await this.initDefaultMail();
    this.getMailList().then((mailListPro) => {
      this.initGroups(mailListPro);
    });
  }

  onPageShow(component: SettingBaseModel): void {
    LogUtil.info(`${TAG} ${this.compId} onPageShow.`);
    this.initData();
  }

  onPageHide(component: SettingBaseModel): void {
    LogUtil.info(`${TAG} ${this.compId} onPageHide.`);
  }

  destroy(): void {
    LogUtil.showInfo(TAG, 'onDestroy');
    EventBus.getInstance().on('EVENT_ID_APP_LIST_ADD', this.appListRemoveCb);
    EventBus.getInstance().detach('EVENT_ID_APP_LIST_REMOVE', this.appListRemoveCb);
  }

  private onAppListAdd(bundleName: string, appIndex: number): void {
    LogUtil.info(`${TAG} onAppListAdd ${bundleName}`);
    this.initData();
  }

  private onAppListRemove(bundleName: string, appIndex: number): void {
    LogUtil.info(`${TAG} onAppListRemove ${bundleName}`);
    this.initData();
  }

  private async getMailList(): Promise<AppListInfo[]> {
    let mailListPro: AppListInfo[] = [];
    try {
      let data = await PreferencesUtil.get(MAIL_LIST_DATA, '');
      let mailList: bundle.AbilityInfo[] = [];
      // 如果从缓存中拿到数据就用缓存中的，没有就直接从接口里面取
      if (!data) {
        mailList = await this.getMailListByBms();
      } else {
        mailList = JSON.parse(data as string);
      }
      mailList.forEach(async (mailListItem: bundle.AbilityInfo, index) => {
        mailListPro.push(await this.newAppInfo(mailListItem));
      });
      LogUtil.info(`${TAG} get mail success`);
    } catch (error) {
      LogUtil.error(`${TAG} catch error : ${error?.code} msg: ${error?.message}`);
    }
    return mailListPro;
  }

  private async getMailListByBms(): Promise<bundle.AbilityInfo[]> {
    LogUtil.info(`${TAG} Get default mail list`);
    let want: Want = {
      'action': 'ohos.want.action.sendToData',
      'uri': 'mailto',
    }
    let mailLists: bundle.AbilityInfo[] = [];
    try {
      mailLists = await bundle.queryAbilityInfo(want,
        bundle.AbilityFlag.GET_ABILITY_INFO_WITH_APPLICATION);
      LogUtil.info(`${TAG} get mail list success ${mailLists?.length}`);
    } catch (error) {
      LogUtil.error(`${TAG} query mail list catch, error : ${error.message}`);
    }
    return mailLists;
  }

  private async newAppInfo(browserListItem: bundle.AbilityInfo): Promise<AppListInfo> {
    const bundleName: string = browserListItem.bundleName;
    const appIndex: number = browserListItem.appIndex;
    let entry: AppEntry = AppListLoader.getInstance().getAppEntry(bundleName, appIndex) as AppEntry;
    if (!entry) {
      entry = await AppListLoader.getInstance().createAndCache(bundleName, appIndex) as AppEntry;
    }
    return {
      labelId: browserListItem?.labelId as number,
      label: entry?.label,
      icon: entry.icon as PixelMap,
      bundleName: browserListItem?.bundleName,
      name: browserListItem?.name,
      isSystemApp: browserListItem?.applicationInfo?.systemApp,
    };
  }

  private async initDefaultMail(): Promise<void> {
    LogUtil.info(`${TAG} initDefaultMail`);
    await this.getDefaultMail();
  }

  private async getDefaultMailApp(curDefaultMailAPPValue: string): Promise<void> {
    try {
      let mailListPro: AppListInfo[] = await this.getMailList()
      const defaultMailApp = mailListPro.find(mail => curDefaultMailAPPValue === mail.bundleName);
      if (defaultMailApp && defaultMailApp.isSystemApp === this.isSystemApp) {
        this.bundleName = defaultMailApp.bundleName as string;
        this.radioController?.initValue(this.compId, defaultMailApp);
        return;
      }
    } catch (err) {
      LogUtil.error(`${TAG} update email state fail`);
    }
  }

  private getLabel(defaultMailApp: AppListInfo): string {
    let label: string = defaultMailApp?.label as string;
    let text: string = ResourceUtil.getFormatStringSync($r('app.string.system_default'), '');
    return defaultMailApp?.isSystemApp ? `${label} (${text})` : label;
  }

  private async getDefaultMail(): Promise<void> {
    try {
      let data: bundleManager.BundleInfo = await defaultAppMgr.getDefaultApplication(defaultAppMgr.ApplicationType
        .EMAIL);
      this.bundleName = data?.name;
      await this.getDefaultMailApp(this.bundleName);
      LogUtil.info(`${TAG} Operation successful. bundleInfo: ${data?.name}`);
    } catch (err) {
      LogUtil.error(`getDefaultMail Cause:code: ${err.code} message: ${err.message}`);
      this.setSystemMailApp();
    }
  }

  initGroups(mailList: AppListInfo[]): void {
    LogUtil.info(`${TAG} initGroups: ${mailList.length} ${this.isSystemApp}`);
    let systemMails: AppListInfo[] = [];
    if (this.isSystemApp) {
      systemMails = mailList.filter(item => item.isSystemApp);
    } else {
      systemMails = mailList.filter(item => !item.isSystemApp);
    }
    if (systemMails.length > 0) {
      this.dataSource?.splice(0, this.dataSource?.length);
      this.dataSource.pushData(...this.createItems(systemMails));
    }
  }

  private setSystemMailApp(): void {
    try {
      this.getMailList().then((mailListPro) => {
        const systemMailApp = mailListPro.find(mail => mail.isSystemApp);
        if (systemMailApp && systemMailApp.bundleName) {
          DefaultMailUtil.setDefaultMail(systemMailApp.bundleName);
          this.radioController?.initValue(this.compId, systemMailApp);
          return;
        }
        LogUtil.error(`${TAG} System mail not foundApp`);
      });
    } catch (err) {
      LogUtil.error(`${TAG} System mail set failed`);
    }
  }

  private createItems(mailInfos: AppListInfo[]): SettingItemModel[] {
    let items: SettingItemModel[] = [];
    for (let mailInfo of mailInfos) {
      let item: SettingItemModel = {
        id: `${mailInfo.bundleName}`,
        type: ItemType.ITEM_TYPE_STANDARD,
        title: { content: this.getLabel(mailInfo) },
        icon: {
          icon: mailInfo.icon as PixelMap,
          iconType: SettingIconType.ICON_TYPE_APPICON,
          style: this.getIconStyle()
        },
        result: {
          type: ItemResultType.RESULT_TYPE_RADIO,
          result: {
            style: { width: 22, height: 22, showUnchecked: true },
            checked: this.setChecked(mailInfo),
            onCheck: (isCheck: boolean, item: SettingItemModel) => {
              this.radioController?.onChange(this.compId, mailInfo, isCheck);
            }
          },
        }
      };
      items.push(item);
    }
    return items;
  }

  private getIconStyle(): SettingIconStyle {
    // 接入了HDS之后，图标不需要主动做描边处理
    let style: SettingIconStyle = {
      border: { width: '0px', color: '#00000000', radius: 0 },
      borderRadius: 0,
      width: 48,
      height: 48,
      mirrored: false
    };
    return style;
  }

  private setChecked(mailInfo: AppListInfo): boolean | undefined {
    LogUtil.info(`${TAG} setChecked ${this.bundleName}`);
    return this.bundleName === mailInfo.bundleName;
  }
}
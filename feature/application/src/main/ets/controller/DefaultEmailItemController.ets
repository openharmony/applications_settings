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

import { preferences } from '@kit.ArkData';
import bundle from '@ohos.bundle.bundleManager';
import bundleManager from '@ohos.bundle.bundleManager';
import defaultAppMgr from '@ohos.bundle.defaultAppManager';
import { EventBus } from '@ohos/settings.common/src/main/ets/framework/common/EventBus';
import { DynamicDataSource } from '@ohos/settings.common/src/main/ets/framework/model/DynamicDataSource';
import {
  CompCtrlParam,
  ComponentControl,
} from '@ohos/settings.common/src/main/ets/framework/model/SettingBaseModel';
import { ItemDetailType,
  ItemResultType,
  ItemType,
  SettingItemModel } from '@ohos/settings.common/src/main/ets/framework/model/SettingItemModel';
import { notifyCompStateChange,
  SettingBaseState,
  SettingCompState,
  SettingContentState,
  SettingResultState,
  SettingStateType } from '@ohos/settings.common/src/main/ets/framework/model/SettingStateModel';
import { NavEntryKey } from '@ohos/settings.common/src/main/ets/utils/Consts';
import { LogUtil } from '@ohos/settings.common/src/main/ets/utils/LogUtil';
import { PreferencesUtil } from '@ohos/settings.common/src/main/ets/utils/PreferencesUtil';
import { PageRouter } from '@ohos/settings.common/src/main/ets/framework/common/PageRouter';
import { PushParam } from '@ohos/settings.common/src/main/ets/core/controller/Controller';
import { MemoryMgrUtils } from '@ohos/settings.common/src/main/ets/utils/MemoryMgrUtils';
import { ResourceManagerUtil } from '@ohos/settings.common/src/main/ets/utils/ResourceManagerUtil';
import { ResourceUtil } from '@ohos/settings.common/src/main/ets/utils/ResourceUtil';
import { AppDataModel, AppListInfo, SettingAppGroupModel } from '../model/SettingAppItemModel';
import { AppEntry } from '../AppModel';
import { DefaultMailUtil } from '../util/DefaultMailUtil';

const TAG = 'DefaultEmailItemController';
const MAIL_LIST_DATA: string = 'mail_list_data';

export class DefaultEmailItemController implements ComponentControl {
  private compId: string = '';
  private dataSource: DynamicDataSource = new DynamicDataSource();
  private entry: AppEntry | null = null;
  private bundleName: string = '';
  private isShow: boolean = false;
  private result: string = '';

  private refreshData = (entry: AppEntry) => {
    /* instrument ignore if*/
    if (!entry) {
      LogUtil.error(`${TAG} appEntry is invalid`);
      return;
    }
    LogUtil.info(`${TAG} receive app change: ${this.compId}, ${entry.name}`);
    this.entry = entry;
    this.bundleName = entry?.name;
    this.initDefaultMail();
    // ��ҳ�����һ��controller��ˢ������⣬�����ⲿ��תʱ����ˢ��ʱ������
    this.updateGroupTitle();
  }

  private mailListChangeEventCb = (data: object) => {
    LogUtil.info(`${TAG} browser list changed`);
    this.checkMail();
  };

  private mailAppSelectEventCb = (data: object) => {
    LogUtil.info(`${TAG} browser list changed`);
    this.initDefaultMail();
  };

  init(compParam: CompCtrlParam): void {
    LogUtil.showInfo(TAG, `onInit`);
    /* instrument ignore if*/
    if (!compParam || !compParam.compId) {
      LogUtil.error(`${TAG} init fail, compParam is invalid`);
      return;
    }
    this.compId = compParam.compId;
    this.dataSource = compParam.dataSource as DynamicDataSource;
    let appItem: SettingAppGroupModel = compParam.component as SettingAppGroupModel;
    this.entry = appItem.entry as AppEntry;
    if (this.entry) {
      this.refreshData(this.entry);
    }
    EventBus.getInstance().on('DEFAULT_MAIL_APP_SELECT', this.mailAppSelectEventCb);
    EventBus.getInstance().on('EVENT_ID_MAIL_LIST_CHANGE_EVENTS', this.mailListChangeEventCb);
  }

  destroy(): void {
    LogUtil.showInfo(TAG, 'onDestroy');
    EventBus.getInstance().detach('DEFAULT_MAIL_APP_SELECT', this.mailAppSelectEventCb);
    EventBus.getInstance().detach('EVENT_ID_MAIL_LIST_CHANGE_EVENTS', this.mailListChangeEventCb);
  }

  private async initDefaultMail(): Promise<void> {
    if (!this.entry) {
      LogUtil.error(`${TAG} entry invalid`);
      return;
    }
    await this.checkMail();
    await this.getDefaultMail();
    LogUtil.info(`${TAG} entry default_mail_settings: ${this.entry?.name} ${this.isShow} ${this.result}`);
    if (this.isShow) {
      this.dataSource?.splice(0, this.dataSource.length);
      this.dataSource.pushData(this.createItem(() => {
        LogUtil.info(`${TAG} entry default_mail_settings: ${this.entry?.name}`);
        PageRouter.push(NavEntryKey.DEFAULT_MAIL_ENTRY, new PushParam({
          bundleName: this.entry?.name,
          uid: this.entry?.appInfo?.uid,
        } as AppDataModel));
      }))
    }
  }

  private async getDefaultMailApp(curDefaultMailAPPValue: string): Promise<void> {
    try {
      let mailListPro: AppListInfo[] = await this.getMailList();
      const defaultMailApp = mailListPro.find(mail => curDefaultMailAPPValue === mail.bundleName);
      if (defaultMailApp) {
        this.setMailLabel(defaultMailApp);
        return;
      }
      LogUtil.error(`${TAG} invalid email info`);
    } catch (err) {
      LogUtil.error(`${TAG} update email state fail`);
    }
  }

  private async setMailLabel(defaultMailApp: AppListInfo): Promise<void> {
    if (defaultMailApp?.label) {
      let text: string = ResourceUtil.getFormatStringSync($r('app.string.system_default'), '');
      let label: string = await defaultMailApp?.label as string;
      this.result = defaultMailApp?.isSystemApp ? `${label} (${text})` : label;
      LogUtil.info(`${TAG} setMailLabel, ${this.result}`);
      this.refreshResult();
    }
  }

  private async getDefaultMail(): Promise<void> {
    try {
      let data: bundleManager.BundleInfo = await defaultAppMgr.getDefaultApplication(defaultAppMgr.ApplicationType
        .EMAIL);
      let curStateBundleName: string = data?.name;
      await this.getDefaultMailApp(curStateBundleName);
      LogUtil.info(`${TAG} Operation successful. bundleInfo: ${data?.name}`);
    } catch (err) {
      LogUtil.error(`getDefaultMail Cause:code: ${err.code} message: ${err.message}`);
      await this.setSystemMailApp();
    }
  }

  /* instrument ignore next */
  private async setSystemMailApp(): Promise<void> {
    try {
      let mailListPro: AppListInfo[] = await this.getMailList();
      const systemMailApp = mailListPro.find(mail => mail.isSystemApp);
      if (systemMailApp && systemMailApp.bundleName) {
        this.setMailLabel(systemMailApp);
        DefaultMailUtil.setDefaultMail(systemMailApp.bundleName);
        return;
      }
      LogUtil.error(`${TAG} System mail not foundApp`);
    } catch (err) {
      LogUtil.error(`${TAG} System mail set failed`);
    }
  }

  public async getMailList(): Promise<AppListInfo[]> {
    let mailListPro: AppListInfo[] = [];
    try {
      let data = await PreferencesUtil.get(MAIL_LIST_DATA, '');
      let mailList: bundle.AbilityInfo[] = JSON.parse(data as string);
      mailList.forEach((mailListItem: bundle.AbilityInfo, index) => {
        const resourceManager = ResourceManagerUtil.getBundleResourceManager(mailListItem?.bundleName)!;
        let label = resourceManager.getStringSync(mailListItem?.labelId);
        mailListPro.push({
          labelId: mailListItem?.labelId as number,
          label,
          bundleName: mailListItem?.bundleName,
          name: mailListItem?.name,
          isSystemApp: mailListItem?.applicationInfo?.systemApp
        });
        MemoryMgrUtils.removeNapiWrap(resourceManager, false);
      });
      LogUtil.info(`${TAG} get mail success`);
    } catch (error) {
      LogUtil.error(`${TAG} catch error : ${error?.code} msg: ${error?.message}`);
    }
    return mailListPro;
  }

  private createItem(onItemClick: () => void): SettingItemModel {
    return {
      id: 'DefaultMail',
      type: ItemType.ITEM_TYPE_STANDARD,
      title: { content: $r('app.string.default_mail') },
      result: {
        type: ItemResultType.RESULT_TYPE_TEXT,
        result: {
          content: this.result,
        }
      },
      detail: {
        type: ItemDetailType.DETAIL_TYPE_CUSTOM,
        icon: $r('sys.symbol.chevron_right'),
        isSymbolIcon: true,
        onItemClick: () => {
          onItemClick();
        }
      }
    }
  }

  private async checkMail(): Promise<void> {
    let data: preferences.ValueType = await PreferencesUtil.get(MAIL_LIST_DATA, '');
    if (data) {
      let defaultList: bundle.AbilityInfo[] = [];
      try {
        defaultList = JSON.parse(data as string);
        LogUtil.info(`${TAG} defaultList parse ${defaultList.length}`);
      } catch (error) {
        LogUtil.info(`${TAG} defaultList parse fail`);
      }
      const bundleNameList: string[] = defaultList?.map((item: bundle.AbilityInfo) => item.bundleName);
      this.isShow = bundleNameList.some((item: string) => {
        return item === this.bundleName;
      });
    }
    LogUtil.info(`${TAG} isShow: ${this.isShow}`);
    this.setVisible(this.isShow);
  }

  private refreshResult(): void {
    notifyCompStateChange('Setting.AppDetail.DefaultEmailGroup.DefaultMail',
      new Map<SettingStateType, SettingResultState>([[SettingStateType.STATE_TYPE_ITEM_RESULT,
        { type: ItemResultType.RESULT_TYPE_TEXT,
          result: { content: this.result }
        } as SettingResultState]]));
  }

  private setVisible(isBrowser: boolean) {
    notifyCompStateChange('Setting.AppDetail.DefaultEmailGroup',
      new Map<SettingStateType, SettingBaseState>([[SettingStateType.STATE_TYPE_GROUP_VISIBLE, {
        state: isBrowser
      } as SettingCompState]]));
  }

  private updateGroupTitle() {
    LogUtil.info(`${TAG} updateTitle: ${this.entry?.label as string}`);
    notifyCompStateChange('Setting.AppDetail.AppAllowAccessGroup.header',
      new Map<SettingStateType, SettingBaseState>([[SettingStateType.STATE_TYPE_GROUP_HEADER_TITLE,
        { content: ResourceUtil.getFormatStringSync($r('app.string.app_info_allow_access'),
          this.entry?.label as string) } as SettingContentState]]
      ));
  }
}
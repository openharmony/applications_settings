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

import common from '@ohos.app.ability.common';
import { taskpool } from '@kit.ArkTS';
import Want from '@ohos.app.ability.Want';
import { BusinessError } from '@ohos.base';
import bundle from '@ohos.bundle.bundleManager';
import bundleManager from '@ohos.bundle.bundleManager';
// import hiviewLogService from '@hms.hiviewLogService';
import Settings from '@ohos.settings';
import { AppListLoader } from '@ohos/settings.application/src/main/ets/AppListLoader';
import { AppType } from '@ohos/settings.application/src/main/ets/AppModel';
import { DeliverUtil } from '@ohos/settings.common/src/main/ets/utils/DeliverUtil';
import { AbilityContextManager } from '@ohos/settings.common/src/main/ets/ability/AbilityContextManager';
import { AppManager } from '@ohos/settings.application/src/main/ets/util/AppManager';
import { PADDING_8 } from '@ohos/settings.common/src/main/ets/constant/StyleConstant';
import { PageRouter } from '@ohos/settings.common/src/main/ets/framework/common/PageRouter';
import {
  CompCtrlParam,
  ComponentControl,
  SettingBaseModel,
} from '@ohos/settings.common/src/main/ets/framework/model/SettingBaseModel';
import { GroupType, SettingGroupModel } from '@ohos/settings.common/src/main/ets/framework/model/SettingGroupModel';
import {
  ItemDetailType,
  ItemResultType,
  ItemType,
  SettingItemModel,
} from '@ohos/settings.common/src/main/ets/framework/model/SettingItemModel';
import { SettingPageModel } from '@ohos/settings.common/src/main/ets/framework/model/SettingPageModel';
import {
  notifyCompStateChange,
  SettingDialogState,
  SettingResultState,
  SettingStateType,
  SettingCompState,
  SettingBaseState,
  SettingTextState,
} from '@ohos/settings.common/src/main/ets/framework/model/SettingStateModel';
import { CheckEmptyUtils } from '@ohos/settings.common/src/main/ets/utils/CheckEmptyUtils';
import { FontScaleUtils } from '@ohos/settings.common/src/main/ets/utils/FontScaleUtils';
import { LogUtil } from '@ohos/settings.common/src/main/ets/utils/LogUtil';
import { ResourceUtil } from '@ohos/settings.common/src/main/ets/utils/ResourceUtil';
import { EventBus } from '@ohos/settings.common/src/main/ets/framework/common/EventBus';
import { EVENT_ID_CLEAR_CACHE, EVENT_ID_REFRESH_CACHE } from '@ohos/settings.common/src/main/ets/event/types';
import {
  BundleStatusChangeListener,
  BundleStatusChangeManager
} from '@ohos/settings.common/src/main/ets/bundle/BundleStatusChangeManager';
import { HiSysEventUtil } from '@ohos/settings.common/src/main/ets/systemEvent/HiSysEventUtil';
import { HiSysStorageEventGroup } from '@ohos/settings.common/src/main/ets/systemEvent/BehaviorEventConsts';
import { SettingsDataUtils } from '@ohos/settings.common/src/main/ets/utils/SettingsDataUtils';
import { ToastUtil } from '@ohos/settings.common/src/main/ets/utils/ToastUtil';
import { ERROR_CODE_APP_LOCKED } from '@ohos/settings.application/src/main/ets/model/UninstallResult';
import { AppUtils } from '@ohos/settings.application/src/main/ets/AppUtils';
import { StorageSizeUtil } from '../utils/StorageSizeUtil';
import { removeContentBuilder } from '../components/RemoveContentComponent';
import { removeLoadingBuilder } from '../components/RemoveLoadingComponent';
import { appItemHeaderBuilder } from '../components/AppItemHeaderComponent';
import { RemoveHeaderModel, SettingAppItemHeaderModel } from '../model/SettingAppItemHeaderModel';
import { StorageUtil } from '../utils/StorageUtil';
import { BundleStats } from '../model/BundleStats';
import { StorageEventConstant } from '../constant/StorageConstant';
import { recoverBackupBundleDataAsync, removeBackupBundleDataAsync } from '../utils/StorageAppUtil';

/* instrument ignore file */
const TAG = 'AppItemControl'
const DOUBLE_SLASH: string = '://';
const SINGLE_SLASH: string = '/';
const COLON: string = ':';
const GET_APPLICATION_INFO_DEFAULT = 0x00000000;
const LISTENER_KEY: string = 'STORAGE_APP_UNINSTALL';
const DEFAULT_BACKUP_DATA_SIZE: string = '0';

export class AppItemControl implements ComponentControl {
  private appSize: string = '';
  private dataSize: string = '';
  private totalSize: string = '';
  private cacheSize: string = '';
  private label: string = '';
  private compId: string = '';
  private removable: boolean = false;
  private params: BundleStats = new BundleStats();
  private canClearData: boolean = false;
  private skillUrl?: bundle.SkillUrl;
  private clearCacheBtnEnable: boolean = false;
  private hasPopped: boolean = false;
  private dataClearable: boolean = true;
  private canShowToast: boolean = false;
  private refreshCache = async () => {
    let cacheSize: number = await StorageUtil.getCacheByName(this.params.name as string, this.params.appIndex);
    this.clearCacheBtnEnable = this.dataClearable && cacheSize > 0;
    this.cacheSize = StorageSizeUtil.formatDataIntl(cacheSize, 0, true);
    LogUtil.showInfo(TAG, `refreshCache: ${this.cacheSize}`);
    notifyCompStateChange(`${this.compId}.CacheDataGroup.cacheSizeData`,
      new Map<SettingStateType, SettingResultState>([[SettingStateType.STATE_TYPE_ITEM_RESULT,
        { type: ItemResultType.RESULT_TYPE_TEXT, result: { content: this.cacheSize } } as SettingResultState]]));
    this.notifyClearCacheData();
  };
  private isUninstallSuccess: boolean = false;
  private bundleStatusCallback: BundleStatusChangeListener = {
    getListenerName: (): string => LISTENER_KEY,
    onBundleAdd: (bundleName, userId, appIndex) => {
      LogUtil.info(`${TAG} bundleStatusCallback add, bundleName: ${bundleName} userId: ${userId} appIndex: ${appIndex}`);
    },
    onBundleRemove: (bundleName, userId, appIndex) => {
      LogUtil.info(`${TAG} bundleStatusCallback remove, bundleName: ${bundleName} userId: ${userId} appIndex: ${appIndex}`);

      if (!this.isUninstallSuccess && bundleName === this.params.name && appIndex === this.params.appIndex) {
        LogUtil.info(`${TAG} app uninstalled, go back`);
        this.reportUninstallResult(bundleName, true, 0);
        this.pop();
      }
    },
    onBundleUpdate: (bundleName, userId, appIndex) => {
      LogUtil.info(`${TAG} bundleStatusCallback update, bundleName: ${bundleName} userId: ${userId} appIndex: ${appIndex}`);
    }
  };

  private pop(): void {
    LogUtil.info(`${TAG} pop with hasPopped: ${this.hasPopped}`);
    if (!this.hasPopped) {
      this.hasPopped = true;
      PageRouter.pop('Setting');
    }
  }

  private checkDataClearable(): void {
    try {
      let name: string = this.params.name as string;
      this.dataClearable = !bundleManager.getApplicationInfoSync(name, GET_APPLICATION_INFO_DEFAULT)?.dataUnclearable;
      LogUtil.info(`${TAG} checkDataClearable with clearable: ${this.dataClearable}`);
    } catch (error) {
      LogUtil.error(`${TAG} getApplicationInfoSync error ${error?.message}`);
    }
  }

  init(compParam: CompCtrlParam): void {
    if (!compParam || !compParam.compId) {
      LogUtil.error(`${TAG} init fail, compParam is invalid`);
      return;
    }
    this.compId = compParam.compId;
    this.params = compParam.param as BundleStats;
    let comp = compParam.component as SettingPageModel;
    if (!this.params) {
      LogUtil.info(`${TAG} init fail, init params is undefined`);
      return;
    }
    LogUtil.info(`${TAG} params removable ${this.params?.removable}`);
    this.checkDataClearable();
    this.totalSize = StorageSizeUtil.formatDataIntl(parseInt(this.params.totalSize), 0, true);
    this.appSize = StorageSizeUtil.formatDataIntl(parseInt(this.params.appSize), 0, true);
    this.dataSize = StorageSizeUtil.formatDataIntl(parseInt(this.params.dataSize), 0, true);
    this.cacheSize = StorageSizeUtil.formatDataIntl(parseInt(this.params.cacheSize), 0, true);
    this.clearCacheBtnEnable = this.dataClearable && parseInt(this.params.cacheSize) > 0;
    this.label = this.params.label?.toString() || '';
    this.removable = this.params?.removable as boolean;
    this.skillUrl = this.params.skillUrl;
    if (!CheckEmptyUtils.isEmpty(this.skillUrl)) {
      this.canClearData = true;
    }
    EventBus.getInstance().on(EVENT_ID_REFRESH_CACHE + this.params.name, this.refreshCache);
    LogUtil.info(`${TAG} init seccess`);

    comp.title = this.label;
    this.setHeader(comp);
    this.setGroups(comp);
    this.setBackupDataGroup(comp);
    this.setOptionGroup(comp);
  }

  private notifyClearCacheData(): void {
    LogUtil.info(`${TAG} isEnable is ${this.clearCacheBtnEnable}`);
    notifyCompStateChange(`${this.compId}.AppOptionGroup.clearCacheData`,
      new Map<SettingStateType, SettingCompState>([[SettingStateType.STATE_TYPE_ITEM_ENABLED,
        { state: this.clearCacheBtnEnable } as SettingCompState]]));
  }

  private getAndRefreshData() {
    StorageUtil.getAllDataByName(this.params.name as string, this.params.appIndex).then((res) => {
      this.cacheSize = StorageSizeUtil.formatDataRound(0, 0);
      this.totalSize = StorageSizeUtil.formatDataRound(parseInt(res.totalSize), 0);
      this.dataSize = StorageSizeUtil.formatDataRound(parseInt(res.dataSize), 0);
      this.appSize = StorageSizeUtil.formatDataRound(parseInt(res.appSize), 0);
      this.clearCacheBtnEnable = false;
      EventBus.getInstance().emit(EVENT_ID_CLEAR_CACHE, this.params.name, this.params.appIndex,
        res.totalSize, res.appSize, res.dataSize);
      this.refreshUi(this.params.name as string);
    });
  }

  setHeader(comp: SettingPageModel): void {
    LogUtil.info(`${TAG} app name is  ${this.params.name}`)
    comp.header = {
      id: 'AppItemTestControl',
      builder: wrapBuilder(appItemHeaderBuilder),
      icon: this.params.icon,
      versionName: this.params.versionName,
      label: this.params.label,
      name: this.params.name,
      appIndex: this.params.appIndex,
      entry: this.params
    } as SettingAppItemHeaderModel;
  }

  setGroups(comp: SettingPageModel): void {
    comp.groups = [
      {
        id: 'AppDataGroup',
        type: GroupType.GROUP_TYPE_STANDARD,
        items: [
          {
            id: 'totalSizeData',
            type: ItemType.ITEM_TYPE_STANDARD,
            title: { content: $r('app.string.app_info_storage_total_size') },
            result: { type: ItemResultType.RESULT_TYPE_TEXT, result: { content: this.totalSize } },
            focusable: false,
          },
          {
            id: 'appSizeData',
            type: ItemType.ITEM_TYPE_STANDARD,
            title: { content: $r('app.string.app_info_storage_app_size') },
            result: { type: ItemResultType.RESULT_TYPE_TEXT, result: { content: this.appSize } },
            focusable: false,
          },
          {
            id: 'dataSizeData',
            type: ItemType.ITEM_TYPE_STANDARD,
            title: { content: $r('app.string.app_info_storage_data_size') },
            result: { type: ItemResultType.RESULT_TYPE_TEXT, result: { content: this.dataSize } },
            focusable: false,
          }
        ],
      },
      {
        id: 'CacheDataGroup',
        type: GroupType.GROUP_TYPE_STANDARD,
        items: [
          {
            id: 'cacheSizeData',
            type: ItemType.ITEM_TYPE_STANDARD,
            title: { content: $r('app.string.app_info_storage_cache_size') },
            result: { type: ItemResultType.RESULT_TYPE_TEXT, result: { content: this.cacheSize } },
            focusable: false,
            compControl: {
              init: () => {
                EventBus.getInstance().emit(EVENT_ID_REFRESH_CACHE + this.params.name);
              },
              destroy: () => {
              },
            }
          },
        ],
      }
    ]
  }

  setBackupDataGroup(comp: SettingPageModel): void {
    comp.groups?.push({
      id: 'BackupData',
      type: GroupType.GROUP_TYPE_STANDARD,
      visible: this.needShowBackupDataGroup(),
      items: [
        {
          id: 'RecoverBackupData',
          type: ItemType.ITEM_TYPE_STANDARD,
          title: {
            content: $r('app.string.restore_bakcup_data_item_title'),
            style: { fontColor: $r('sys.color.font_emphasize') }
          },
          detail: {
            type: ItemDetailType.DETAIL_TYPE_DIALOG,
            dialog: {
              title: $r('app.string.restore_bakcup_data_dialog_title'),
              message: ResourceUtil.getFormatStringSync($r('app.string.restore_backup_data_dialog_message'),
                this.label),
              buttonVertical: FontScaleUtils.isExtraLargeFontMode() ? false : true,
              buttons: [
                {
                  value: $r('app.string.dialog_cancel'),
                  style: { fontColor: $r('sys.color.font_emphasize') },
                  action: (component: SettingItemModel) => {
                  }
                },
                {
                  value: $r('app.string.restore_backup_data_dialog_confirm'),
                  style: { fontColor: $r('sys.color.font_emphasize') },
                  action: (component: SettingItemModel): void => {
                    LogUtil.warn(`${TAG} onclicked recover backup data`);
                    this.recoverBackupBundleData();
                  }
                }
              ]
            }
          }
        },
        {
          id: 'RemoveBackupData',
          type: ItemType.ITEM_TYPE_STANDARD,
          title: {
            content: $r('app.string.delete_backup_data_item_title'),
            style: { fontColor: $r('sys.color.warning') }
          },
          detail: {
            type: ItemDetailType.DETAIL_TYPE_DIALOG,
            dialog: {
              title: $r('app.string.delete_backup_data_dialog_title'),
              message: ResourceUtil.getFormatStringSync($r('app.string.delete_backup_data_dialog_message'), this.label),
              buttonVertical: FontScaleUtils.isExtraLargeFontMode() ? false : true,
              buttons: [
                {
                  value: $r('app.string.dialog_cancel'),
                  style: { fontColor: $r('sys.color.font_emphasize') },
                  action: (component: SettingItemModel) => {
                  }
                },
                {
                  value: $r('app.string.delete_backup_data_dialog_confirm'),
                  style: { role: ButtonRole.ERROR },
                  action: (component: SettingItemModel): void => {
                    LogUtil.warn(`${TAG} onclicked remove backup data`);
                    this.removeBackupBundleData();
                  }
                }
              ]
            }
          }
        }
      ],
    });
  }

  setOptionGroup(comp: SettingPageModel): void {
    let appOptionGroup: SettingGroupModel = {
      id: 'AppOptionGroup',
      type: GroupType.GROUP_TYPE_STANDARD,
      items: [
        {
          id: 'clearCacheData',
          type: ItemType.ITEM_TYPE_STANDARD,
          title: {
            content: $r('app.string.app_info_clear_cache'),
            style: { fontColor: $r('sys.color.font_emphasize') }
          },
          enabled: this.clearCacheBtnEnable,
          detail: {
            type: ItemDetailType.DETAIL_TYPE_CUSTOM,
            icon: '',
            onItemClick: (component: SettingBaseModel) => {
              notifyCompStateChange(`${this.compId}.AppOptionGroup.clearCacheData`,
                new Map<SettingStateType, SettingCompState>([[SettingStateType.STATE_TYPE_ITEM_ENABLED,
                  { state: false } as SettingCompState]]));
              bundleManager.cleanBundleCacheFiles(this.params.name, this.params.appIndex).then(() => {
                LogUtil.showInfo(TAG, `cleanBundleCacheFiles ${this.params.name} successfully.`);
                this.reportClearCacheClickEvent(this.params.name ?? '', this.cacheSize, this.params.appIndex);
                this.getAndRefreshData();
              }).catch((err: Error) => {
                LogUtil.showError(TAG, `cleanBundleCacheFiles ${this.params.name} failed, message:${err?.message}`);
              });
            }
          }
        },
        ...this.getOptionItems()
      ]
    };
    comp.groups?.push(appOptionGroup);
  }

  private reportClearCacheClickEvent(bundleName: string, cacheSize: string, appIndex: number) {
    let reportParams: Record<string, Object> = {};
    reportParams.NAME = bundleName;
    reportParams.CACHE_SIZE = cacheSize;
    reportParams.INDEX = appIndex;
    HiSysEventUtil.reportBehaviorEventByUE(HiSysStorageEventGroup.CLICK_CLEAN_CACHE_BUTTON, reportParams);
  }

  getOptionItems(): SettingItemModel[] {
    let arr: SettingItemModel[] = [];
    if (this.removable || this.canClearData) {
      this.addClearDataOption(arr);
      this.addUninstallOption(arr);
    }
    return arr;
  }

  private addClearDataOption(arr: SettingItemModel[]): void {
    let clearContent =
      ResourceUtil.getFormatStringSync($r('app.string.storage_app_clear_data'), this.label as string);
    if (this.canClearData) {
      arr.push({
        id: 'clearAppData',
        type: ItemType.ITEM_TYPE_STANDARD,
        title: {
          content: clearContent,
          style: { fontColor: $r('sys.color.font_emphasize') }
        },
        detail: {
          type: ItemDetailType.DETAIL_TYPE_CUSTOM,
          icon: '',
          onItemClick: (component: SettingBaseModel) => {
            this.clearAppDataMenuClick();
          }
        }
      })
    }
  }

  private addUninstallOption(arr: SettingItemModel[]): void {
    if (this.removable) {
      arr.push({
        id: 'removeApp',
        type: ItemType.ITEM_TYPE_STANDARD,
        title: {
          content: $r('app.string.app_info_uninstall'),
          style: { fontColor: $r('sys.color.warning') }
        },
        enabled: this.isUninstallItemEnable(),
        pic: this.params.icon,
        label: this.params.label,
        entry: this.params,
        detail: {
          type: ItemDetailType.DETAIL_TYPE_DIALOG,
          dialog: {
            contentBuilder: wrapBuilder(removeContentBuilder),
            buttonVertical: FontScaleUtils.isExtraLargeFontMode() ? false : true,
            style: {
              padding: { top: PADDING_8 },
            },
            buttons: [
              {
                value: $r('app.string.dialog_cancel'),
                action: (component: SettingItemModel) => {
                  this.onHandlerCancerClick();
                },
              },
              {
                value: $r('app.string.app_info_uninstall'),
                style: {
                  role: ButtonRole.ERROR
                },
                action: (component: SettingItemModel) => {
                  this.onHandlerRemoveClick(component);
                },
              },
            ],
          }
        }
      } as RemoveHeaderModel)
    }
  }

  private isUninstallItemEnable(): boolean {
    let isAncoStatusRunning: boolean = DeliverUtil.getDeliverStartStatus() === DeliverUtil.DELIVER_START_FINISHED_CODE;
    LogUtil.info(`${TAG} isUninstallItemEnable with isAncoStatusRunning: ${isAncoStatusRunning}`);
    return isAncoStatusRunning || AppListLoader.getInstance().getAppType(this.params) !== AppType.CONTAINER_APP
  }

  clearAppDataMenuClick(): void {
    LogUtil.info(`${TAG} clearAppDataMenuClick`);
    let uiContext = AbilityContextManager.getMainAbilityContext() as common.UIAbilityContext;
    if (!uiContext) {
      LogUtil.showError(TAG, 'clearAppDataMenuClick uiContext is invalid');
      return;
    }
    try {
      let uri: string = this.initUri();
      if (CheckEmptyUtils.checkStrIsEmpty(uri)) {
        LogUtil.showError(TAG, 'uri is empty');
        return;
      }
      let want: Want = {
        uri: uri,
        bundleName: this.params.name,
        parameters: {
          'linkFeature': 'AppStorageMgmt'
        }
      };
      uiContext.startAbility(want).then(() => {
        LogUtil.showInfo(TAG, 'startAbility success');
      }).catch((e: BusinessError) => {
        LogUtil.showError(TAG, `startAbility error ${e.code}`);
      });
    } catch (e) {
      LogUtil.showError(TAG, `startAbility fail ${(e as BusinessError).code}`);
    }
  }

  private initUri(): string {
    if (!this.skillUrl) {
      LogUtil.showError(TAG, 'initUri skill invalid');
      return '';
    }
    let uri: string = '';
    if (this.skillUrl.scheme) {
      uri += this.skillUrl.scheme + DOUBLE_SLASH;
    }
    if (this.skillUrl.host) {
      uri += this.skillUrl.host;
    }
    if (this.skillUrl.port) {
      uri += COLON + this.skillUrl.port;
    }

    if (this.skillUrl.path) {
      uri += SINGLE_SLASH + this.skillUrl.path;
    } else if (this.skillUrl.pathStartWith) {
      uri += SINGLE_SLASH + this.skillUrl.pathStartWith;
    } else if (this.skillUrl.pathRegex) {
      uri += SINGLE_SLASH + this.skillUrl.pathRegex;
    }
    LogUtil.info(`${TAG} initUri uri: ${uri}`);
    return uri;
  }

  onHandlerCancerClick(): void {
    LogUtil.info(`${TAG} onHandlerCancerClick`);
  }

  // 确认删除APP
  onHandlerRemoveClick(component: SettingItemModel): void {
    BundleStatusChangeManager.getInstance().registerBundleChangedListener(this.bundleStatusCallback);
    component.onItemEvent?.(new Map([[
      SettingStateType.STATE_TYPE_ITEM_DIALOG, {
      style: { autoCancel: false },
      contentBuilder: wrapBuilder(removeLoadingBuilder),
    } as SettingDialogState,
    ]]));
    let bundleName: string = this.params.name ?? '';
    try {
      AppManager.getInstance().uninstallApp(bundleName, this.params.appIndex, false).then(result => {
        component.onItemEvent?.(new Map([[
          SettingStateType.STATE_TYPE_ITEM_DIALOG, {} as SettingDialogState,
        ]]));
        this.isUninstallSuccess = result.isSuccess;
        if (result.isSuccess || result.error?.code !== ERROR_CODE_APP_LOCKED) {
          EventBus.getInstance().emit(StorageEventConstant.EVENT_REFRESH_STORAGE_DATA);
          this.reportUninstallResult(bundleName, result.isSuccess, result.error?.code);
          this.pop();
        }
      });
    } catch (e) {
      LogUtil.error(`${TAG} uninstall error`);
    }
  }

  destroy(): void {
    LogUtil.showInfo(TAG, 'onDestroy');
    BundleStatusChangeManager.getInstance().unRegisterBundleChangedListener(this.bundleStatusCallback);
    EventBus.getInstance().detach(EVENT_ID_REFRESH_CACHE + this.params.name, this.refreshCache);
  }

  protected refreshUi(name: string): void {
    notifyCompStateChange(`${this.compId}.CacheDataGroup.cacheSizeData`,
      new Map<SettingStateType, SettingResultState>([[SettingStateType.STATE_TYPE_ITEM_RESULT,
        { type: ItemResultType.RESULT_TYPE_TEXT, result: { content: this.cacheSize } } as SettingResultState]]));

    notifyCompStateChange(`${this.compId}.AppDataGroup.totalSizeData`,
      new Map<SettingStateType, SettingResultState>([[SettingStateType.STATE_TYPE_ITEM_RESULT,
        { type: ItemResultType.RESULT_TYPE_TEXT, result: { content: this.totalSize } } as SettingResultState]]));

    notifyCompStateChange(`${this.compId}.AppDataGroup.dataSizeData`,
      new Map<SettingStateType, SettingResultState>([[SettingStateType.STATE_TYPE_ITEM_RESULT,
        { type: ItemResultType.RESULT_TYPE_TEXT, result: { content: this.dataSize } } as SettingResultState]]));

    notifyCompStateChange(`${this.compId}.AppDataGroup.appSizeData`,
      new Map<SettingStateType, SettingResultState>([[SettingStateType.STATE_TYPE_ITEM_RESULT,
        { type: ItemResultType.RESULT_TYPE_TEXT, result: { content: this.appSize } } as SettingResultState]]));

    this.notifyClearCacheData();
  }

  private reportUninstallResult(bundleName: string, isSuccess: boolean, errorCode: number = 0): void {
    const param: Record<string, Object> = {};
    param.BUNDLE_NAME = bundleName;
    param.IS_SUCCESS = isSuccess;
    param.ERROR_CODE = errorCode;
    HiSysEventUtil.reportBehaviorEventByUE(HiSysStorageEventGroup.STORAGE_UNINSTALL_APP, param);
  }

  onPageShow(component: SettingBaseModel): void {
    LogUtil.info(`${TAG} onPageShow`);
    this.canShowToast = true;
    this.changeUninstallItemEnableStatus(this.isUninstallItemEnable());
  }

  onPageHide(component: SettingBaseModel): void {
    LogUtil.info(`${TAG} onPageHide`);
    this.canShowToast = false;
  }

  private needShowBackupDataGroup(): boolean {
    return this.hasBackupData() && this.isDiagnosisMode();
  }

  private isDiagnosisMode(): boolean {
    let isDiagnosisMode: boolean = false;
    try {
      // isDiagnosisMode = hiviewLogService.getDiagnosisStatus()?.isDiagnosisMode;
      LogUtil.warn(`${TAG} getDiagnosisStatus with result: ${isDiagnosisMode}`);
    } catch (err) {
      LogUtil.error(`${TAG} getDiagnosisStatus error occured, code:${err?.code}, message:${err?.message}`);
    }
    return isDiagnosisMode;
  }

  private hasBackupData(): boolean {
    const backupDataKey: string = `${this.params.name}_${this.params.appIndex}`;
    const size: number = Number(SettingsDataUtils.getSettingsData(backupDataKey, DEFAULT_BACKUP_DATA_SIZE,
      Settings.domainName.USER_SECURITY));
    LogUtil.warn(`${TAG} get backup data size: ${size}`);
    return size > 0;
  }

  private async removeBackupBundleData(): Promise<void> {
    this.changeBackupDataGroupEnableStatus(false);
    this.changeRemoveItemTitle($r('app.string.deleting_backup_data'));
    let userID = await AppUtils.getActivatedAccountLocalId();
    let removeTask: taskpool.Task =
      new taskpool.Task(removeBackupBundleDataAsync, this.params.name, userID, this.params.appIndex);
    let result: boolean = false;
    try {
      result = await taskpool.execute(removeTask) as boolean;
      LogUtil.warn(`${TAG} execute removeTask with result:${result}`);
    } catch (err) {
      LogUtil.error(`${TAG} execute removeTask occured exception, code: ${err?.code}, msg: ${err?.message}`);
    }
    if (result) {
      this.showToast(ResourceUtil.getStringSync($r('app.string.delete_backup_data_success_tip')));
      this.hideBackupDataGroup();
      return;
    }
    this.showToast(ResourceUtil.getStringSync($r('app.string.delete_backup_data_fail_tip')));
    if (this.needShowBackupDataGroup()) {
      this.changeRemoveItemTitle($r('app.string.delete_backup_data_item_title'));
      this.changeBackupDataGroupEnableStatus(true);
    } else {
      this.hideBackupDataGroup();
    }
  }

  private async recoverBackupBundleData(): Promise<void> {
    this.changeBackupDataGroupEnableStatus(false);
    this.changeRecoverItemTitle($r('app.string.restoring_backup_data'));
    let userID = await AppUtils.getActivatedAccountLocalId();
    let recoverTask: taskpool.Task =
      new taskpool.Task(recoverBackupBundleDataAsync, this.params.name, userID, this.params.appIndex);
    let result: boolean = false;
    try {
      result = await taskpool.execute(recoverTask) as boolean;
      LogUtil.warn(`${TAG} execute recoverTask with result:${result}`);
    } catch (err) {
      LogUtil.error(`${TAG} execute recoverTask occured exception, code: ${err?.code}, msg: ${err?.message}`);
    }
    if (result) {
      this.showToast(ResourceUtil.getStringSync($r('app.string.restore_backup_data_success_tip')));
      this.hideBackupDataGroup();
      return;
    }
    this.showToast(ResourceUtil.getStringSync($r('app.string.restore_backup_data_fail_tip')));
    if (this.needShowBackupDataGroup()) {
      this.changeRecoverItemTitle($r('app.string.restore_bakcup_data_item_title'));
      this.changeBackupDataGroupEnableStatus(true);
    } else {
      this.hideBackupDataGroup();
    }
  }

  private showToast(str: string): void {
    if (this.canShowToast) {
      ToastUtil.showToast(str);
    }
  }

  private hideBackupDataGroup(): void {
    notifyCompStateChange(`${this.compId}.BackupData`, new Map<SettingStateType, SettingBaseState>(
      [[SettingStateType.STATE_TYPE_GROUP_VISIBLE, { state: false } as SettingCompState]]
    ));
  }

  private changeBackupDataGroupEnableStatus(enable: boolean): void {
    notifyCompStateChange(`${this.compId}.BackupData.RecoverBackupData`,
      new Map<SettingStateType, SettingCompState>([[SettingStateType.STATE_TYPE_ITEM_ENABLED,
        { state: enable } as SettingCompState]]));
    notifyCompStateChange(`${this.compId}.BackupData.RemoveBackupData`,
      new Map<SettingStateType, SettingCompState>([[SettingStateType.STATE_TYPE_ITEM_ENABLED,
        { state: enable } as SettingCompState]]));
  }

  private changeRemoveItemTitle(title: ResourceStr): void {
    notifyCompStateChange(`${this.compId}.BackupData.RemoveBackupData`, new Map<SettingStateType, SettingBaseState>(
      [[SettingStateType.STATE_TYPE_ITEM_TITLE, { content: title } as SettingTextState]]
    ));
  }

  private changeRecoverItemTitle(title: ResourceStr): void {
    notifyCompStateChange(`${this.compId}.BackupData.RecoverBackupData`, new Map<SettingStateType, SettingBaseState>(
      [[SettingStateType.STATE_TYPE_ITEM_TITLE, { content: title } as SettingTextState]]
    ));
  }

  private changeUninstallItemEnableStatus(enable: boolean): void {
    notifyCompStateChange(`${this.compId}.AppOptionGroup.removeApp`,
      new Map<SettingStateType, SettingCompState>([[SettingStateType.STATE_TYPE_ITEM_ENABLED,
        { state: enable } as SettingCompState]]));
  }
}
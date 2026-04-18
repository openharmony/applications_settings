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

import { SettingPageDescController } from '@ohos/settings.search/src/main/ets/controller/SettingPageDescController';
import Want from '@ohos.app.ability.Want';
import { DynamicLoader } from '@ohos/settings.common/src/main/ets/utils/DynamicLoader';
import { CustomMenuManager } from '@ohos/settings.common/src/main/ets/custom/CustomMenuManager';
import {
  NavEntryKey,
  PHONE_SETTING_HOME_MENU_KEYS
} from '@ohos/settings.common/src/main/ets/utils/Consts';
import { LogUtil } from '@ohos/settings.common/src/main/ets/utils/LogUtil';
import { DeviceUtil } from '@ohos/settings.common/src/main/ets/utils/BaseUtils';
import { PageRouter } from '@ohos/settings.common/src/main/ets/framework/common/PageRouter';
import { EventBus } from '@ohos/settings.common/src/main/ets/framework/common/EventBus';
import {
  notifyCompStateChange,
  SettingBaseState,
  SettingCompState,
  SettingStateType
} from '@ohos/settings.common/src/main/ets/framework/model/SettingStateModel';
import lazy { PasswordUtil } from '@ohos/settings.common/src/main/ets/utils/PasswordUtil';
import lazy { AppListLoader } from '@ohos/settings.application/src/main/ets/AppListLoader';
import lazy { AppCloneData } from '@ohos/settings.cloneapps/src/main/ets/model/CloneAppsData';
import lazy { PageStartModeManager } from '@ohos/settings.common/src/main/ets/window/PageStartModeManager';
import lazy { WalletManageUtils } from '@ohos/settings.common/src/main/ets/utils/WalletManageUtils';
import { PasswordManager } from '@ohos/settings.common/src/main/ets/passwordManager/PasswordManager';
import { CommonUtils } from '@ohos/settings.common/src/main/ets/utils/CommonUtils';
import lazy { PageRouteController } from './PageRouteController';

const TAG: string = 'ExportPageController: ';

const CHECK_PASSWORD_ENTRY_FLAG: string = 'check_password';
const CREATE_PASSWORD_ENTRY_FLAG: string = 'create_password_entry_flag';
const CREATE_PASSWORD_ENTRY_FACE_FLAG: string = 'create_password_entry_face_flag';
const SCROLL_DELAY: number = 50; // 冷启动设置需等待，否则滚动不生效
const CHANGE_PASSWORD_ENTRY_FLAG: string = 'change_password';

enum BackMode {
  Inner,
  Outer,
}

export class PushParam {
  public config?: Object | object;
  public startReason?: string;
  public subUri?: string;
  public bundleName?: string;
  public originalCallerInfo?: string;

  constructor(param?: Object | object, subUri?: string, bundleName?: string, callerInfo?: string) {
    this.config = param;
    this.subUri = subUri;
    this.bundleName = bundleName;
    this.startReason = PageStartModeManager.getInstance().getStartReason();
    this.originalCallerInfo = callerInfo;
  }
}

/**
 * 创建密码参数
 *
 * @since 2023-07-29
 */
class CreatePwdParams {
  public source: string;
  public nextUrl: string;

  constructor(source ?: string, nextUrl ?: string) {
    this.source = source as string;
    this.nextUrl = nextUrl as string;
  }
}

class CheckPwdParams {
  public source: string;
  public nextUrl: string;
  public dynamic?: boolean;

  constructor(source ?: string, nextUrl ?: string, dynamic?: boolean) {
    this.source = source as string;
    this.nextUrl = nextUrl as string;
    this.dynamic = dynamic;
  }
}

class PrivacyPushParams extends PushParam {
  public backMode: BackMode | undefined = BackMode.Inner;
  public targetSubRouter: string | undefined = '';

  constructor(targetSubRouter?: string, backMode?: BackMode) {
    super();
    this.backMode = backMode;
    this.targetSubRouter = targetSubRouter;
  }
}

export class ExportPageController {
  private pagePath: string[] = [];
  private timerId: number | null = null;

  /**
   * 外部拉起页面路由
   *
   * @param pathInfos 路由栈
   * @param entryKey 页面key
   *
   * @returns
   */
  public async pageRoute(pathInfos: NavPathStack, entryKey: string, animated?: boolean): Promise<void> {
    LogUtil.info(`${TAG} pageRoute ${entryKey}`);
    let topEntry: string = NavEntryKey.WIFI_ENTRY;
    let entryKeyList: string[] = await this.getPagePath(entryKey);
    if (await this.pushPreviousNavPathInfo(pathInfos, entryKeyList, animated)) {
      switch (entryKey) {
        case NavEntryKey.FINGERPRINT_SETTING_ENTRY:
          this.fingerPrintRoute(pathInfos);
          topEntry = NavEntryKey.BIOMETRICS_PASSWORD_ENTRY;
          break;
        case NavEntryKey.CHECK_PSD_ENTRY:
          this.checkPsdRoute(pathInfos);
          topEntry = NavEntryKey.BIOMETRICS_PASSWORD_ENTRY;
          break;
        case NavEntryKey.FACE_SETTING_ENTRY:
          this.faceRecordRoute(pathInfos);
          topEntry = NavEntryKey.BIOMETRICS_PASSWORD_ENTRY;
          break;
        case NavEntryKey.PRIVACY_ENTRY:
          this.privacyRoute(pathInfos, animated);
          topEntry = NavEntryKey.PRIVACY_ENTRY;
          break;
        case NavEntryKey.LOCATION_MANAGER_ENTRY:
          this.locationManagerRoute(pathInfos, animated);
          topEntry = NavEntryKey.PRIVACY_ENTRY;
          break;
        case NavEntryKey.CLONE_APP_DETAIL:
          this.cloneAppDetailRoute(pathInfos, entryKey, animated);
          topEntry = NavEntryKey.CLONE_APP_DETAIL;
          break;
        default:
          this.defaultRoute(pathInfos, entryKey, animated);
          let len: number = entryKeyList.length;
          topEntry = len > 0 ? entryKeyList[0] : entryKey;
          break;
      }
      this.sendShowBgEventToHomeEntry(topEntry);
    }
  }

  async pushByPath(pathInfos: NavPathStack, navPath: NavPathInfo, animated?: boolean): Promise<void> {
    if (PageRouteController.getInstance().isPageAdapted(navPath.name)) {
      await PageRouter.push(navPath.name, navPath.param as object, false, navPath.isEntry);
    } else {
      await DynamicLoader.getInstance().fire(navPath.name);
      pathInfos?.pushPath(navPath, animated);
    }
  }

  pushName(pathInfos: NavPathStack, key: string, params: PushParam | undefined): void {
    DynamicLoader.getInstance().fire(key).then(() => {
      pathInfos?.pushPath(new NavPathInfo(key, params, undefined, true));
    });
  }

  /**
   * 直接路由到三级以上页面，需要保存前面的几级页面信息
   */
  private async pushPreviousNavPathInfo(pathInfos: NavPathStack, entryKeyList: string[],
    animated?: boolean): Promise<boolean> {
    this.pagePath = entryKeyList.slice();
    if (entryKeyList.length === 0) {
      return false;
    }
    entryKeyList.pop();
    LogUtil.info(`${TAG} pushPreviousNavPathInfo ${entryKeyList.length}`);
    for (const entryKey of entryKeyList) {
      await this.pushByPath(pathInfos, new NavPathInfo(entryKey, null), animated);
    }
    return true;
  }

  public sendShowBgEventToHomeEntry(topEntry: string) {
    LogUtil.info(`${TAG} top entry is ${topEntry}`);
    if (PHONE_SETTING_HOME_MENU_KEYS.has(topEntry) && (DeviceUtil.isDeviceFoldable || DeviceUtil.isDevicePad())) {
      let lastKey: string = AppStorage.get('currentHomeKey') as string;
      notifyCompStateChange(lastKey,
        new Map<SettingStateType, SettingBaseState>([[SettingStateType.STATE_TYPE_ITEM_SELECTED,
          { state: false } as SettingCompState]]));
      AppStorage.setOrCreate('currentHomeKey', topEntry);
      notifyCompStateChange(topEntry,
        new Map<SettingStateType, SettingBaseState>([[SettingStateType.STATE_TYPE_ITEM_SELECTED,
          { state: true } as SettingCompState]]));
      this.timerId = setTimeout(() => {
        this.timerId = null;
        EventBus.getInstance().emit('HomePageScroll', topEntry);
      }, SCROLL_DELAY);
    }
  }

  public clearTimer(): void {
    if (this.timerId != null) {
      clearTimeout(this.timerId);
      this.timerId = null;
    }
  }

  /**
   * 获取页面路径
   * <p> 1.必须是允许列表中的页面才可以供外部跳转
   * <p> 2.如果是隐藏的菜单，则返回空页
   * <p> 3.如果是一级菜单，直接返回一级菜单entryKey
   * <p> 4.其他场景通过pageInfo.json获取层级路径
   *
   * @param entryKey entryKey
   * @returns 页面路径
   */
  public async getPagePath(entryKey: string): Promise<Array<string>> {
    if (CustomMenuManager.getInstance().isMenuHide(entryKey)) {
      LogUtil.warn(`${TAG} this page is hidden ${entryKey}`);
      return [];
    }

    let entryKeyList: string[] = [];
    if (PHONE_SETTING_HOME_MENU_KEYS.has(entryKey)) {
      return [entryKey];
    }
    // 不在配置文件里的直接返回，避免配置文件添加遗漏
    if (!await SettingPageDescController.isPageExistInConfig(entryKey)) {
      return [entryKey];
    }
    await SettingPageDescController.getParentPage(entryKey, entryKeyList);
    return entryKeyList.reverse();
  }

  /* instrument ignore next */
  async cloneAppDetailRoute(pathInfos: NavPathStack, entryKey: string, animated?: boolean): Promise<void> {
    let parameters = AppStorage.get<Want>('wantParams')?.parameters;
    if (parameters === undefined) {
      LogUtil.error(`${TAG} parameters is undefined`);
      return;
    }
    let appCloneData = new AppCloneData();
    let appBundleName = parameters?.bundleName as string;
    appCloneData.bundleName = appBundleName;
    let entry = await AppListLoader.getInstance().getAndUpdateAppEntryByName(appBundleName);
    if (entry) {
      appCloneData.label = entry?.label as string;
      appCloneData.icon = entry.icon;
      appCloneData.maxCloneAppNum = entry?.appInfo?.multiAppModeMaxCount as number;
    }
    this.pushByPath(pathInfos, new NavPathInfo(entryKey, new PushParam(appCloneData), undefined, true), animated);
  }

  defaultRoute(pathInfos: NavPathStack, entryKey: string, animated?: boolean): void {
    let want: Want = AppStorage.get<Want>('wantParams') as Want;
    let parameters = want?.parameters;
    // 获取外部调用方信息
    let callerInfo = CommonUtils.getCallerInfo(want);
    let pushParams = new PushParam(parameters?.pushParams, parameters?.subUri as string,
      parameters?.bundleName as string, callerInfo);
    if (entryKey === NavEntryKey.PHONE_NOTIFICATION_SETTINGS_ENTRY) {
      this.pushByPath(pathInfos, new NavPathInfo(entryKey, pushParams, undefined, true), animated);
    } else {
      this.pushByPath(pathInfos, new NavPathInfo(entryKey, pushParams, undefined, true), false);
    }
  }

  // 页面不刷新，通过replace方式
  async replacePath(pathInfos: NavPathStack, navPath: NavPathInfo, animated?: boolean): Promise<void> {
    await DynamicLoader.getInstance().fire(navPath.name);
    pathInfos?.pushPath(navPath, animated);
    pathInfos?.replacePath(navPath, animated);
  }

  fingerPrintRoute(pathInfos: NavPathStack): void {
    import('@ohos/settings.common/src/main/ets/utils/SecurityUtil').then(async (util) => {
      const isSupport: boolean = await util.SecurityUtil.isSupportFingerPrint();
      if (!isSupport) {
        return;
      }
      PasswordUtil.hasPinPassword((hasPinPassword) => {
        if (hasPinPassword) {
          LogUtil.info(`${TAG} has pin password, router to check psd page`);
          let params: CheckPwdParams = new CheckPwdParams(CHECK_PASSWORD_ENTRY_FLAG,
            NavEntryKey.UNDER_SCREEN_FINGERPRINT_INTRO_ENTRY);
          this.pushName(pathInfos, NavEntryKey.CHECK_PSD_ENTRY, new PushParam(params));
        } else {
          LogUtil.info(`${TAG} without pin password, router to create pin page`);
          let params: CreatePwdParams = new CreatePwdParams(CREATE_PASSWORD_ENTRY_FLAG,
            NavEntryKey.UNDER_SCREEN_FINGERPRINT_INTRO_ENTRY);
          this.pushName(pathInfos, PasswordManager.getEntryKey(), new PushParam(params));
        }
      });
    })
  }

  /* instrument ignore next */
  checkPsdRoute(pathInfos: NavPathStack): void {
    PasswordUtil.hasPinPassword((hasPinPassword) => {
      if (hasPinPassword) {
        LogUtil.info(`${TAG} has pin password, router to check psd page`);
        let params: CheckPwdParams = WalletManageUtils.isFromWallet() ?
          new CheckPwdParams(CHANGE_PASSWORD_ENTRY_FLAG, PasswordManager.getEntryKey()) :
          new CheckPwdParams(CHECK_PASSWORD_ENTRY_FLAG, NavEntryKey.BIOMETRICS_PASSWORD_ENTRY);
        this.pushName(pathInfos, NavEntryKey.CHECK_PSD_ENTRY, new PushParam(params));
      } else {
        LogUtil.info(`${TAG} without pin password, router to create pin page`);
        let params: CreatePwdParams = new CreatePwdParams('', NavEntryKey.BIOMETRICS_PASSWORD_ENTRY);
        this.pushName(pathInfos, PasswordManager.getEntryKey(), new PushParam(params));
      }
    });
  }

  privacyRoute(pathInfos: NavPathStack, animated?: boolean): void {
    let want = AppStorage.get<Want>('wantParams');
    AppStorage.setOrCreate<string>('privacySettingsTargetSubRouter', '');
    AppStorage.setOrCreate<string>('privacySettingsTargetSubRouter',
      (want?.parameters?.pushParams as PrivacyPushParams)?.targetSubRouter);
    let pushParams = new PrivacyPushParams((want?.parameters?.pushParams as PrivacyPushParams)?.targetSubRouter);
    pushParams.subUri = want?.parameters?.subUri as string;
    pushParams.bundleName = want?.parameters?.bundleName as string;
    this.pushByPath(pathInfos, new NavPathInfo(NavEntryKey.PRIVACY_ENTRY, pushParams, undefined, true), animated);
  }

  locationManagerRoute(pathInfos: NavPathStack, animated?: boolean): void {
    AppStorage.setOrCreate<string>('privacySettingsTargetSubRouter', '');
    AppStorage.setOrCreate<NavEntryKey>('privacySettingsTargetSubRouter', NavEntryKey.LOCATION_MANAGER_ENTRY);
    let pushParams = new PrivacyPushParams(NavEntryKey.LOCATION_MANAGER_ENTRY);
    let want = AppStorage.get<Want>('wantParams');
    pushParams.subUri = want?.parameters?.subUri as string;
    pushParams.bundleName = want?.parameters?.bundleName as string;
    this.pushByPath(pathInfos, new NavPathInfo(NavEntryKey.PRIVACY_ENTRY, pushParams, undefined, true), animated);
  }

  /* instrument ignore next */
  async faceRecordRoute(pathInfos: NavPathStack): Promise<void> {
    // const userAuthModel = await import('@hw-hmos/settings-face-auth/src/main/ets/faceauth/Model/UserAuthModel');
    // const faceAuthPromise = userAuthModel.default.isSupportFaceAuth();
    // faceAuthPromise.then(isSupport => {
    //   if (!isSupport) {
    //     return;
    //   }
    //   PasswordUtil.hasPinPassword((hasPinPassword) => {
    //     if (hasPinPassword) {
    //       LogUtil.info(`$${TAG} has pin password, router to check psd page`);
    //       this.faceRecordRouteWithPsd(pathInfos);
    //     } else {
    //       LogUtil.info(`${TAG} without pin password, router to create pin page`);
    //       let params: CreatePwdParams =
    //         new CreatePwdParams(CREATE_PASSWORD_ENTRY_FACE_FLAG, NavEntryKey.FACE_AUTH_FEATURE_GUIDE_ENTRY);
    //       this.pushName(pathInfos, PasswordManager.getEntryKey(), new PushParam(params));
    //     }
    //   });
    // })
  }

  /* instrument ignore next */
  private async faceRecordRouteWithPsd(pathInfos: NavPathStack): Promise<void> {
    try {
      // const userIdmModel = await import('@hw-hmos/settings-face-auth/src/main/ets/faceauth/Model/UserIdmModel');
      // if (await userIdmModel.default.isFaceEnrolled()) {
      //   let params: CheckPwdParams =
      //     new CheckPwdParams(CHECK_PASSWORD_ENTRY_FLAG, NavEntryKey.FACE_AUTH_PREFERENCE_ENTRY);
      //   this.pushName(pathInfos, NavEntryKey.CHECK_PSD_ENTRY, new PushParam(params));
      // } else {
      //   let params: CheckPwdParams =
      //     new CheckPwdParams(CHECK_PASSWORD_ENTRY_FLAG, NavEntryKey.FACE_AUTH_FEATURE_GUIDE_ENTRY);
      //   this.pushName(pathInfos, NavEntryKey.CHECK_PSD_ENTRY, new PushParam(params));
      // }
    } catch (error) {
      LogUtil.error(`${TAG} isFaceEnrolled failed`);
    }
  }
}
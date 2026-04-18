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

import { display } from '@kit.ArkUI';
import bundleManager from '@ohos.bundle.bundleManager';
import window from '@ohos.window';
import { DisplayConstant } from '../constant/DisplayConstant';
import { PageRouter } from '../framework/common/PageRouter';
import { notifyCompStateChange, SettingCompState, SettingStateType } from '../framework/model/SettingStateModel';
import { FoldPhoneTypeValue, DeviceUtil } from './BaseUtils';
import { DEFAULT_WINDOW_WIDTH, INVALID_AVOID_WIDTH } from './Consts';
import { LogUtil } from './LogUtil';
import { ResourceUtil } from './ResourceUtil';

const TAG: string = 'CommonUtils: ';

export class CommonUtils {

  /**
   * 判断当前页面是否存在
   *
   * @param key 当前页面的key
   * @returns true表示存在，false表示不存在
   */
  public static isPageExist(key: string): boolean {
    let isExist: boolean = false;
    PageRouter.getRouterPath('Setting').ifPresent((path: NavPathStack) => {
      let indexs = path.getIndexByName(key);
      if (indexs && indexs.length > 0) {
        isExist = true;
      }
    });

    LogUtil.info(`${TAG} the page isExist: ${isExist}`);
    return isExist;
  }

  /**
   * 检测当前页面是否是激活状态
   *
   * @param pagePathName
   * @returns true:是,false:不是
   */
  public static isPageActive(pagePathName: string): boolean {
    let isActive: boolean = false;
    PageRouter.getRouterPath('Setting').ifPresent((path: NavPathStack) => {
      const pathNameList: string[] = path.getAllPathName();
      if (pathNameList?.length > 0) {
        isActive = pathNameList[pathNameList.length - 1] === pagePathName;
      }
    });
    LogUtil.info(`${TAG} ${pagePathName} isPageActive is: ${isActive}`);
    return isActive;
  }

  public static async getScreenHeight(context: Context): Promise<number> {
    if (!context) {
      LogUtil.error(`${TAG} getScreenHeight fail, context is empty`);
      return -1;
    }

    try {
      const win = await window.getLastWindow(context);
      const screen = win.getWindowProperties().windowRect;
      return px2vp(screen.height);
    } catch (err) {
      LogUtil.error(`${TAG} getScreenHeight fail, err.code: ${err?.code}, err.Message: ${err?.message}`);
    }
    return -1;
  }

  /**
   * 检测当前页面是否是通过搜索进入
   *
   * @returns true:是,false:不是
   */
  public static isFromSearch(): boolean {
    let isFromSearch: boolean = AppStorage.get('isFromSearch') as boolean;
    LogUtil.info(`${TAG} isFromSearch: ${isFromSearch}`);
    return isFromSearch;
  }

  /**
   * 设置页面内容区边距
   *
   * @param navDesDynamicPadding
   * @returns 页面内容区边距值
   */
  public static getSettingsPagePadding(navDesDynamicPadding: number): number {
    if (DeviceUtil.isDevicePc()) {
      return navDesDynamicPadding;
    }
    return 0;
  }

  /**
   * 设置页面内容区标题栏按钮右边距
   *
   * @param navDesDynamicPadding
   * @returns 标题栏按钮右边距
   */
  public static calculateAvoidWidth(titleButtonRectWidth: number, navDesDynamicPadding: number): number {
    LogUtil.info(`${TAG} ${titleButtonRectWidth} ${navDesDynamicPadding}`);
    if (DeviceUtil.isDevicePc() && navDesDynamicPadding !== undefined && titleButtonRectWidth !== undefined) {
      return Math.max(titleButtonRectWidth - DEFAULT_WINDOW_WIDTH - navDesDynamicPadding, 0);
    }
    return INVALID_AVOID_WIDTH;
  }

  public static isAppInstalled(bundleName: string, bundleFlags: number, appId: string): boolean {
    try {
      let info = bundleManager.getBundleInfoSync(bundleName, bundleFlags);
      if (appId === info.signatureInfo.appId) {
        LogUtil.info(`${TAG} tips app is installed`);
        return true;
      } else {
        LogUtil.warn(`${TAG} tips app is forged`);
        return false;
      }
    } catch (e) {
      LogUtil.error(`${TAG} getBundleInfoSync error, ${e?.code}, ${e?.message}`);
      return false;
    }
  }

  public static verifyAppIdentifier(bundleName: string, appIdentifier: string): boolean {
    try {
      let info =
        bundleManager.getBundleInfoSync(bundleName, bundleManager.BundleFlag.GET_BUNDLE_INFO_WITH_SIGNATURE_INFO);
      return appIdentifier === info.signatureInfo.appIdentifier;
    } catch (e) {
      LogUtil.error(`${TAG} getBundleInfoSync error, ${e?.code}, ${e?.message}`);
    }
    return false;
  }

  public static isSingleDisplayPocketFoldDevice(): boolean {
    let currentDevice: boolean | undefined = AppStorage.get<boolean>('singleDisplayPocketFoldDevice');
    LogUtil.info(`${TAG} currentDevice:${currentDevice}`);
    if (currentDevice === undefined) {
      let result = (DeviceUtil.getFoldProductType() === FoldPhoneTypeValue.EXPANDING_NEX_FORMS);
      AppStorage.setOrCreate('singleDisplayPocketFoldDevice', result);
      return result;
    }
    return currentDevice;
  }

  public static isOuterScreen(): boolean {
    return CommonUtils.isSingleDisplayPocketFoldDevice() &&
        (display.getFoldStatus() === display.FoldStatus.FOLD_STATUS_FOLDED);
  }

  /**
   * 保持从左到右显示字符串
   *
   * @param resource ResourceStr
   * @returns string
   */
  public static getLreString(resource: ResourceStr | undefined): string {
    let resourceString: string = '';
    if (!resource) {
      return resourceString;
    }
    return DisplayConstant.TEXT_DIRECTION_CTRL_LRE + ResourceUtil.getStringSync(resource) +
    DisplayConstant.TEXT_DIRECTION_CTRL_PDF;
  }

  /**
   * 设置分栏左侧导航栏选中
   *
   * @param key 导航栏左侧选中项的entry key
   */
  public static setNavigationSelectedItem(key: string) {
    LogUtil.info(`${TAG} setNavigationSelectedItem ${key}`);
    let lastKey: string = AppStorage.get('currentHomeKey') as string;
    if (lastKey) {
      notifyCompStateChange(lastKey, new Map([[SettingStateType.STATE_TYPE_ITEM_SELECTED,
        { state: false } as SettingCompState]]));
    }
    AppStorage.setOrCreate('currentHomeKey', key);
    notifyCompStateChange(key, new Map([[SettingStateType.STATE_TYPE_ITEM_SELECTED,
      { state: true } as SettingCompState]]));
  }

  /**
   * 获取指定应用的指定模块下的metadata数据
   *
   * @param bundleName 应用包名
   * @param moduleName 模块名
   * @param metaDataName metadata名称
   * @returns 匹配的元数据
   */
  public static getMetadata(bundleName: string, moduleName: string,
    metaDataName: string): bundleManager.Metadata | null {
    try {
      let applicationInfo = bundleManager.getApplicationInfoSync(bundleName,
        bundleManager.ApplicationFlag.GET_APPLICATION_INFO_WITH_METADATA);
      if (applicationInfo === null || applicationInfo.metadata === null) {
        LogUtil.error(
          `${TAG} applicationInfo or metadata is null. getMetadata failed.
          bundleName: ${bundleName} ${(applicationInfo === null)}`);
        return null;
      }
      let metadataObj = applicationInfo.metadata;
      if (metadataObj[moduleName]) {
        for (let metaData of metadataObj[moduleName] as Array<bundleManager.Metadata>) {
          if (metaData.name === metaDataName) {
            LogUtil.info(`${TAG} getMetadata metaData value: ${metaData.value}`);
            return metaData;
          }
        }
      }
    } catch (err) {
      LogUtil.error(`${TAG} getMetadata error: ${err?.message}`);
    }
    return null;
  }

  /**
   * 从want参数中获取调用方信息
   *
   * @param want want参数
   * @returns json字符串
   */
  public static getCallerInfo(want: Want): string {
    let params = want?.parameters as Record<string, string>;
    let origin: OriginalCallerInfo = {
      bundleName: params?.['ohos.aafwk.param.callerBundleName'],
      abilityName: params?.['ohos.aafwk.param.callerAbilityName'],
      appIdentifier: params?.['ohos.aafwk.param.callerAppIdentifier'],
      uri: want?.uri
    }
    return JSON.stringify(origin);
  }
}

/**
 * 调用方信息
 */
interface OriginalCallerInfo {
  bundleName: string,
  abilityName: string,
  appIdentifier: string,
  uri?: string
}
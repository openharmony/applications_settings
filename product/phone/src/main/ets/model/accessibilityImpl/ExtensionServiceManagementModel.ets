/**
 * Copyright (c) 2023-2023 Huawei Device Co., Ltd.
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

import router from '@ohos.router';
import config from '@ohos.accessibility.config';
import bundleMonitor from '@ohos.bundle.bundleMonitor';
import bundleManager from '@ohos.bundle.bundleManager';
import { GlobalContext } from '../../../../../../../common/utils/src/main/ets/default/baseUtil/GlobalContext';
import accessibility from '@ohos.accessibility';
import BaseModel from '../../../../../../../common/utils/src/main/ets/default/model/BaseModel';
import LogUtil from '../../../../../../../common/utils/src/main/ets/default/baseUtil/LogUtil';
import ConfigData from '../../../../../../../common/utils/src/main/ets/default/baseUtil/ConfigData';

const INDEX = 0;
const URI_PAGE = 'pages/accessibilityServiceInfo';
let icon_arrow = $r('app.media.ic_settings_arrow');
let icon_default = "ohos_app_icon";
let icon_default_str = "";
const MODULE_TAG = ConfigData.TAG + 'extensionService-> ';

class serviceItem {
  serviceIcon?: string;
  serviceTitle?: string;
  serviceArrow?: Resource;
  serviceSummary?: ResourceStr;
  serviceEndText?: Resource;
  serviceState?: boolean;
  serviceId?: number | string;
  serviceBundleName?: string;
  serviceUri?: string
}

class serviceInfo {
  name?: string;
  id?: number | string;
  bundleName?: string
}

/**
 * app management service class
 */
export class ExtensionServiceManagementModel extends BaseModel {
  private serviceInfoList: serviceItem[] = [];

  constructor() {
    super();
    try {
      let context = GlobalContext.getContext().getObject(GlobalContext.globalKeySettingsAbilityContext) as Context;
      context.resourceManager.getMediaBase64ByName(icon_default)
        .then((res: string) => {
          icon_default_str = res;
          LogUtil.info(`${MODULE_TAG} getResourceManager init defaultIcon res: ${JSON.stringify(icon_default_str)}`);
        })
        .catch((err: object) => {
          icon_default_str = '';
          LogUtil.info(`${MODULE_TAG} getResourceManager init defaultIcon error: ${JSON.stringify(err)}`);
        });
    } catch (err) {
      icon_default_str = '';
      LogUtil.info(`${MODULE_TAG} getResourceManager init defaultIcon error: ${JSON.stringify(err)}`);
    }
  }

  /**
   * listen extensionService status
   */
  openExtensionServiceManagementStatusListener() {
    try {
      config.on('enabledAccessibilityExtensionListChange', () => {
        LogUtil.info(`subscribe enabled accessibility extension list change state success`);
        this.setExtensionServiceManagementListener();
      });
    } catch (exception) {
      LogUtil.info(`failed to subscribe enabled accessibility extension list change state, because ${JSON.stringify(exception)}`);
    }
  }

  closeExtensionServiceManagementStatusListener() {
    try {
      config.off('enabledAccessibilityExtensionListChange', () => {
        LogUtil.info(`Unsubscribe enabled accessibility extension list change state success`);
      });
    } catch (exception) {
      LogUtil.info(`failed to Unsubscribe enabled accessibility extension list change state, because ${JSON.stringify(exception)}`);
    }
  }

  /**
   * listen extensionService application
   */
  openExtensionServiceManagementApplicationListener() {
    try {
      bundleMonitor.on('add', (bundleChangeInfo) => {
        LogUtil.info(`${MODULE_TAG} Add bundleName: ${bundleChangeInfo.bundleName} userId: ${bundleChangeInfo.userId}`);
        this.setExtensionServiceManagementListener();
      });
    } catch (exception) {
      LogUtil.info(`${MODULE_TAG} failed subscribe bundleMonitor add, result: ${JSON.stringify(exception)}`);
    }
    try {
      bundleMonitor.on('update', (bundleChangeInfo) => {
        LogUtil.info(`${MODULE_TAG} Update bundleName: ${bundleChangeInfo.bundleName} userId: ${bundleChangeInfo.userId}`);
        this.setExtensionServiceManagementListener();
      });
    } catch (exception) {
      LogUtil.info(`${MODULE_TAG} failed subscribe bundleMonitor update, result: ${JSON.stringify(exception)}`);
    }
    try {
      bundleMonitor.on('remove', (bundleChangeInfo) => {
        LogUtil.info(`${MODULE_TAG} Remove bundleName: ${bundleChangeInfo.bundleName} userId: ${bundleChangeInfo.userId}`);
        this.setExtensionServiceManagementListener();
      });
    } catch (exception) {
      LogUtil.info(`${MODULE_TAG} failed subscribe bundleMonitor remove, result: ${JSON.stringify(exception)}`);
    }
  }

  closeExtensionServiceManagementApplicationListener() {
    try {
      bundleMonitor.off('add');
      bundleMonitor.off('update');
      bundleMonitor.off('remove');
    } catch (exception) {
      LogUtil.info(`${MODULE_TAG} failed subscribe bundleMonitor, result: ${JSON.stringify(exception)}`);
    }
  }

  /**
   * get extensionService data
   */
  setExtensionServiceManagementListener() {
    this.serviceInfoList = [];
    accessibility.getAccessibilityExtensionList('all', 'install').then((data) => {
      LogUtil.info(`${MODULE_TAG} extensionService data.length:  ${data.length} data: ${JSON.stringify(data)}`);
      if (!data || data.length < 1) {
        router.back();
        return;
      }
      this.getResourceItemAndState(INDEX, data.length, data);
    }).catch((err: object) => {
      LogUtil.error(`${MODULE_TAG} getExtensionServiceList failed, err: ${JSON.stringify(err)}`);
    });
  }

  /**
   * get resource information according to resource id
   *
   * @param index - array position
   * @param count - array length
   * @param data - data
   */
  async getResourceItemAndState(index: number, count: number, data: serviceInfo[]) {
    LogUtil.info(`${MODULE_TAG} getIconItem start data.length: ${data.length}`);
    let imageValue = '';
    let description: ResourceStr;
    let enabledServiceList: Array<accessibility.AccessibilityAbilityInfo> = await accessibility.getAccessibilityExtensionList('all', 'enable');
    for (let serviceInfo of data) {
      if (!serviceInfo || !serviceInfo.id) {
        continue;
      }
      LogUtil.info(`${MODULE_TAG} extensionService name : ${JSON.stringify(serviceInfo.id)}`);
      let serviceState: boolean = false;
      for (let enabledService of enabledServiceList) {
        if (enabledService.id && enabledService.id === serviceInfo.id) {
          serviceState = true;
          break;
        }
      }
      LogUtil.info(`${MODULE_TAG} + ${JSON.stringify(serviceInfo.name)} : ${JSON.stringify(serviceState)}`);
      let bundleFlag: number = bundleManager.BundleFlag.GET_BUNDLE_INFO_WITH_APPLICATION | bundleManager.BundleFlag.GET_BUNDLE_INFO_WITH_HAP_MODULE | bundleManager.BundleFlag.GET_BUNDLE_INFO_WITH_EXTENSION_ABILITY;
      let bundleInfo: bundleManager.BundleInfo = await bundleManager.getBundleInfo(serviceInfo.bundleName as string, bundleFlag);
      imageValue = await this.loadIcon(bundleInfo);
      description = await this.loadDescription(bundleInfo, serviceInfo.name as string);
      LogUtil.info(`${MODULE_TAG} getResourceManager getMediaBase64() value: ${imageValue}`);
      this.serviceInfoList.push({
        serviceIcon: imageValue,
        serviceTitle: serviceInfo.name,
        serviceArrow: icon_arrow,
        serviceSummary: description,
        serviceEndText: serviceState ? $r('app.string.enabled') : $r('app.string.disabled'),
        serviceState: serviceState,
        serviceId: serviceInfo.id,
        serviceBundleName: serviceInfo.bundleName,
        serviceUri: URI_PAGE,
      });
    }
    AppStorage.SetOrCreate('extensionServiceManagementList', this.serviceInfoList);
    LogUtil.info(`${MODULE_TAG} loadExtensionService end`);
  }

  /**
   * Load icon of AccessibilityService
   */
  async loadIcon(bundleInfo: bundleManager.BundleInfo): Promise<string> {
    let appInfo = bundleInfo.appInfo;
    let imageValue = '';
    let context = GlobalContext.getContext().getObject(GlobalContext.globalKeySettingsAbilityContext) as Context;
    LogUtil.info(`${MODULE_TAG} getResourceManager appInfo.iconResource: ${JSON.stringify(appInfo.iconResource)}`);
    if (appInfo.iconResource.id > 0) {
      imageValue = await context.resourceManager.getMediaContentBase64(appInfo.iconResource);
      if (!imageValue) {
        LogUtil.warn(`${MODULE_TAG} load icon invalid`);
        imageValue = icon_default_str;
      }
      LogUtil.info(`${MODULE_TAG} + getResourceManager loadIcon end`);
      return imageValue;
    }
    imageValue = icon_default_str;
    return imageValue;
  }

  /**
   * Load description of AccessibilityService
   */
  async loadDescription(bundleInfo: bundleManager.BundleInfo, serviceName: string): Promise<ResourceStr> {
    let description: ResourceStr = $r('app.string.no_description_provided');
    let context = GlobalContext.getContext().getObject(GlobalContext.globalKeySettingsAbilityContext) as Context;
    let moduleInfo: Array<bundleManager.HapModuleInfo> = bundleInfo.hapModulesInfo;
    if (moduleInfo.length > 0) {
      for (let hapInfo of moduleInfo) {
        let bundleContext: Context = context.createBundleContext(bundleInfo.name);
        for (let ability of hapInfo.extensionAbilitiesInfo) {
          if (ability.name === serviceName && ability.descriptionId > 0) {
            LogUtil.info(`${MODULE_TAG} descriptionId: ${JSON.stringify(ability.descriptionId)}`);
            await bundleContext.resourceManager.getStringValue(ability.descriptionId)
              .then((res) => {
                description = res;
                LogUtil.info(`${MODULE_TAG} description: ${JSON.stringify(description)}`);
              })
              .catch((err: object) => {
                LogUtil.info(`${MODULE_TAG} get description error: ${JSON.stringify(err)}`);
              });
            if (!description) {
              LogUtil.warn(`${MODULE_TAG} load description invalid`);
              description = $r('app.string.no_description_provided');
            }
            LogUtil.info(`${MODULE_TAG} load description end`);
            return description;
          }
        }
      }
    }
    return description;
  }
}

let extensionServiceManagementModel = new ExtensionServiceManagementModel();

export default extensionServiceManagementModel as ExtensionServiceManagementModel;
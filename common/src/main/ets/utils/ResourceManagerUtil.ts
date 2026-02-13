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

import { Context } from '@kit.AbilityKit';
import resourceManager from '@ohos.resourceManager';
import bundleResourceManager from '@ohos.bundle.bundleResourceManager';
import { LogUtil } from './LogUtil';
import { AbilityContextManager } from '../ability/AbilityContextManager';

const TAG = 'ResourceUtil';

/**
 * 资源管理工具类
 */
export class ResourceManagerUtil {

  static getBundleResourceManager(bundleName: string): resourceManager.ResourceManager | null {
    let context: Context = AbilityContextManager.getStageContext();
    return ResourceManagerUtil.getResManagerWithContext(bundleName, context);
  }

  static getResManagerWithContext(bundleName: string, context: Context): resourceManager.ResourceManager | null {
    let resManager: resourceManager.ResourceManager | null = null;
    try {
      let bundleContext = context?.createBundleContext(bundleName);
      resManager = bundleContext ? bundleContext.resourceManager : null;
    } catch (err) {
      LogUtil.error(`${TAG} get resource manager failed: ${err?.message}`);
    }
    return resManager;
  }

  static getBundleResourceInfo(bundleName: string, bundleFlags: number):
    bundleResourceManager.BundleResourceInfo | undefined {
    let bundleResource: bundleResourceManager.BundleResourceInfo | undefined = undefined;
    try {
      bundleResource = bundleResourceManager.getBundleResourceInfo(bundleName, bundleFlags);
    } catch (error) {
      LogUtil.error(`${TAG} getBundleResourceInfo error, errmsg: ${error?.message}`);
    }
    return bundleResource;
  }
}
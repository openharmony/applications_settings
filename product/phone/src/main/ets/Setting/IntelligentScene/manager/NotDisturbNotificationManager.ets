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

import i18n from '@ohos.i18n';
import taskpool from '@ohos.taskpool';
import notificationManager from '@ohos.notificationManager';
import { ResourceUtil } from '@ohos/settings.common/src/main/ets/utils/ResourceUtil';
import { AbilityContextManager } from '@ohos/settings.common/src/main/ets/ability/AbilityContextManager';
import { LogUtil } from '@ohos/settings.common/src/main/ets/utils/LogUtil';

/* instrument ignore file */
@Concurrent
export async function initI18nAndNotificationEnabledBundles(context: Context):
  Promise<notificationManager.BundleOption[]> {
  AbilityContextManager.setSubThreadContext(context);
  ResourceUtil.getString($r('app.string.settings_title')).then((res) => {
    // 第一次调用耗时120ms左右，因此提前执行一次，用于提升界面加载完成时延
    i18n.Transliterator.getInstance('Any-Latn; Latin-ASCII')?.transform(res);
  });
  let bundles: notificationManager.BundleOption[] = [];
  try {
    bundles = await notificationManager.getAllNotificationEnabledBundles();
  } catch (error) {
    LogUtil.error(`getAllNotificationEnabledBundles failed, errmsg: ${error?.message}`);
  }
  return bundles;
}

const TAG: string = 'AppAndMetaServiceManager';

export class AppAndMetaServiceManager {
  private static manager: AppAndMetaServiceManager;
  public transliterator?: i18n.Transliterator;
  private bundles: notificationManager.BundleOption[] = [];

  public static getInstance(): AppAndMetaServiceManager {
    if (AppAndMetaServiceManager.manager) {
      return AppAndMetaServiceManager.manager;
    }
    AppAndMetaServiceManager.manager = new AppAndMetaServiceManager();
    return AppAndMetaServiceManager.manager;
  }

  public async init(): Promise<void> {
    try {
      let task: taskpool.Task =
        new taskpool.Task(initI18nAndNotificationEnabledBundles, AbilityContextManager.getContext());
      this.bundles = await taskpool.execute(task, taskpool.Priority.HIGH) as notificationManager.BundleOption[];
    } catch (error) {
      LogUtil.error(`${TAG} catch exception, errmsg: ${error?.message}`);
    }
  }

  public async getAllNotificationEnabledBundles(): Promise<notificationManager.BundleOption[]> {
    if (this.bundles.length >= 0) {
      return this.bundles;
    }
    try {
      this.bundles = await notificationManager.getAllNotificationEnabledBundles();
      return this.bundles;
    } catch (error) {
      LogUtil.error(`${TAG} getAllNotificationEnabledBundles occurs exception, errmsg: ${error?.message}`);
    }
    return [];
  }
}
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

import HashMap from '@ohos.util.HashMap';
import { Optional } from './Optional';
import { SettingPageModel } from '../model/SettingPageModel';
import { LogHelper } from './LogHelper';
import { PageConfig } from './PageConfig';

export interface PageParams {
  router: string;
  pageUrl: string;
  pageCtx: PageContext;
  param?: object;
  listScroller?: Scroller;
}

export type PageConfigGenerator = (pageKey?: string) => SettingPageModel;

export interface PageContext {
  configGenerator: PageConfigGenerator;
  pageBuilder?: WrappedBuilder<[object]>;
  getPageReady?: () => boolean;
}

const TAG: string = 'PageLoader';

export class PageLoader {
  private static pageMap: HashMap<string, PageContext> = new HashMap();

  public static load(pageUrl: string, pageCtx: PageContext): void {
    if (!pageUrl || pageUrl.length === 0) {
      return;
    }
    if (!PageLoader.pageMap.get(pageUrl)) {
      pageCtx.pageBuilder = pageCtx.pageBuilder ?? PageConfig.getInstance().getDefaultPageBuilder();
      PageLoader.pageMap.set(pageUrl, pageCtx);
      LogHelper.info(TAG, 'load page: ' + pageUrl);
    }
  }

  public static getPageContext(pageUrl: string): Optional<PageContext> {
    return Optional.ofNullable(PageLoader.pageMap.get(pageUrl));
  }

  public static setPageCtx(pageUrl: string, pageCtx: PageContext): void {
    if (!pageUrl || pageUrl.length === 0 || !pageCtx) {
      LogHelper.error(TAG, 'setPageCtx error, pageUrl or pageCtx null');
      return;
    }
    PageLoader.pageMap.set(pageUrl, pageCtx);
  }
}
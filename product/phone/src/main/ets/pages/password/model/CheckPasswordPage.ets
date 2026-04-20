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
import { PushParam } from '@ohos/settings.common/src/main/ets/core/controller/Controller';
import { SettingHeaderPage } from '@ohos/settings.uikit/src/main/ets/component/SettingHeaderPage';
import { PageUrl } from '../../PageUrl';
import { CheckPasswordPageController } from '../controller/CheckPasswordController';

/**
 * 校验锁屏密码界面
 *
 * @since 2023-01-13
 */
export class CheckPasswordPage extends SettingHeaderPage {
  constructor(pathInfos: NavPathStack, param: PushParam) {
    super({
      pageUrl: PageUrl.CHECK_PSD_PAGE_URL,
      controller: {
        createControllerConstructorInter: CheckPasswordPageController.CreateCheckPasswordPageController,
      },
      isNavigation: true,
      pathInfos: pathInfos,
      navRouterParam: param,
      scrollable: false,
      showHeader: false
    });
    this.addMenus([]);
  }
}

export class CheckPsdParams {
  public source: string;
  public nextUrl: string;
  public dynamic?: boolean;

  constructor(source ?: string, nextUrl ?: string, dynamic?: boolean) {
    this.source = source as string;
    this.nextUrl = nextUrl as string;
    this.dynamic = dynamic;
  }
}
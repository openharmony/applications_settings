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
import { SettingsBaseMenu } from '@ohos/settings.common/src/main/ets/core/model/menu/SettingsMenu';
import { SettingHeaderPage,
  SettingHeaderPageData } from '@ohos/settings.uikit/src/main/ets/component/SettingHeaderPage';

/* instrument ignore file */
export const CREATE_PASSWORD_ENTRY_FLAG: string = 'create_password_entry_flag';
export const CREATE_PASSWORD_ENTRY_FACE_FLAG: string = 'create_password_entry_face_flag';
export const PRIVACY_CENTER_CREATE_PASSWORD_ENTRY: string = 'privacy_center_create_password_entry';

export function isFaceOrFingerprint(name: string): boolean {
  return name === CREATE_PASSWORD_ENTRY_FLAG || name === CREATE_PASSWORD_ENTRY_FACE_FLAG;
}

/**
 * 密码输入基础类
 *
 * @since 2023-07-29
 */
export class CreatePsdPage extends SettingHeaderPage {
  constructor(params?: Partial<SettingHeaderPageData>, menus?: Array<SettingsBaseMenu>) {
    super(params, menus);
    // 根据入参隐藏返回按钮
    const isShowBack = (params?.navRouterParam?.config as Record<string, boolean>)?.hideBack;
    if (isShowBack !== undefined) {
      this.isShowBack = !isShowBack;
    }
    const isShowClose = (params?.navRouterParam?.config as Record<string, boolean>)?.showClose;
    if (isShowClose !== undefined) {
      this.isShowClose = isShowClose;
    }
    const topAreaHeight = (params?.navRouterParam?.config as Record<string, number>)?.topAreaHeight;
    if (topAreaHeight !== undefined) {
      this.topAreaHeight = topAreaHeight;
    }
    const titleMaxLine = (params?.navRouterParam?.config as Record<string, number>)?.titleMaxLine;
    if (titleMaxLine !== undefined) {
      this.titleMaxLine = titleMaxLine;
    }
  }
}


/**
 * 创建密码参数
 *
 * @since 2023-07-29
 */
export class CreatePsdParams {
  public source: string;
  public nextUrl: string;

  constructor(source ?: string, nextUrl ?: string) {
    this.source = source as string;
    this.nextUrl = nextUrl as string;
  }
}
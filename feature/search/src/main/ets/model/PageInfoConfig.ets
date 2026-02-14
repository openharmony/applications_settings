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
import { ConfigVersion } from './ConfigVersion';

export class PageInfo {
  public entryKey: string = '';
  public parentKey: string = '';
  public isVisible: boolean = true;
  public permission: string = '';

  public setEntryKey(entryKey: string) {
    this.entryKey = entryKey;
  }

  public getEntryKey(): string {
    return this.entryKey;
  }

  public setParentKey(parentKey: string) {
    this.parentKey = parentKey;
  }

  public getParentKey(): string {
    return this.parentKey;
  }

  public setIsVisible(isVisible: boolean) {
    this.isVisible = isVisible;
  }

  public getIsVisible(): boolean {
    return this.isVisible;
  }

  public setPermission(permission: string) {
    this.permission = permission;
  }

  public getPermission(): string {
    return this.permission;
  }
}

export class PageInfoConfig {
  public version: ConfigVersion = new ConfigVersion();
  public pageInfos: Array<PageInfo> = [];

  public setPageInfos(searchPages: Array<PageInfo>) {
    this.pageInfos = searchPages;
  }

  public getPageInfos(): Array<PageInfo> {
    return this.pageInfos;
  }

  public setVersion(version: ConfigVersion) {
    this.version = version;
  }

  public getVersion(): ConfigVersion {
    return this.version;
  }
}
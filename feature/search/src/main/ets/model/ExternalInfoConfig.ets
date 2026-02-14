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

export class ExternalInfo {
  public bundleName: string = '';
  public moduleName: string = '';
  public entryKey: string[] = [];
  public removable: boolean = false;

  public setBundleName(bundleName: string) {
    this.bundleName = bundleName;
  }

  public getBundleName(): string {
    return this.bundleName;
  }

  public setModuleName(moduleName: string) {
    this.moduleName = moduleName;
  }

  public getModuleName(): string {
    return this.moduleName;
  }

  public setEntryKey(entryKey: string[]) {
    this.entryKey = entryKey;
  }

  public getEntryKey(): string[] {
    return this.entryKey;
  }
}

export class ExternalInfoConfig {
  public externalInfos: ExternalInfo[] = [];

  public setExternalInfos(externalInfos: Array<ExternalInfo>) {
    this.externalInfos = externalInfos;
  }

  public getExternalInfos(): Array<ExternalInfo> {
    return this.externalInfos;
  }
}
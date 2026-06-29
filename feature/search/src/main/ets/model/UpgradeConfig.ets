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

export class UpgradeInfo {
  public version: number = 0;
  public description: string = '';
  public sqlList: string[] = [];

  public setVersion(version: number) {
    this.version = version;
  }

  public getVersion(): number {
    return this.version;
  }

  public setDescription(description: string) {
    this.description = description;
  }

  public getDescription(): string {
    return this.description;
  }

  public setSqlList(sqlList: string[]) {
    this.sqlList = sqlList;
  }

  public getSqlList(): string[] {
    return this.sqlList;
  }
}

export class UpgradeConfig {
  public upgradeInfos: UpgradeInfo[] = [];

  public setUpgradeInfos(upgradeInfos: Array<UpgradeInfo>) {
    this.upgradeInfos = upgradeInfos;
  }

  public getUpgradeInfos(): Array<UpgradeInfo> {
    return this.upgradeInfos;
  }
}
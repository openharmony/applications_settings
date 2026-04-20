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

export class CheckItem {
  public type: string = '';
  public checkKey: string = '';
  public value: string = '';
}

export class SearchItem {
  public itemName: string = '';
  public itemTitle: string = '';
  public itemDescription: string = '';
  public icon: string = '';
  public enable: string = '';
  public alias: string = '';
  public childItems: string = '';
  public supportDevices: Array<string> = [];
  public checkItem: CheckItem = new CheckItem();

  public setItemName(itemName: string) {
    this.itemName = itemName;
  }

  public getItemName(): string {
    return this.itemName;
  }

  public setItemTitle(itemTitle: string) {
    this.itemTitle = itemTitle;
  }

  public getItemTitle(): string {
    return this.itemTitle;
  }

  public getItemDescription(): string {
    return this.itemDescription;
  }

  public setIcon(icon: string) {
    this.icon = icon;
  }

  public getIcon(): string {
    return this.icon;
  }

  public setAlias(alias: string) {
    this.alias = alias;
  }

  public getAlias(): string {
    return this.alias;
  }

  public getSupportDevices(): Array<string> {
    return this.supportDevices;
  }
}

export class SearchPage {
  public pageTitle: string = '';
  public pageDescription: string = '';
  public entryKey: string = '';
  public params: string = '';
  public path: Array<string> = [];
  public supportDevices: Array<string> = [];
  public searchItems: Array<SearchItem> = [];

  public setPageTitle(pageTitle: string) {
    this.pageTitle = pageTitle;
  }

  public getPageTitle(): string {
    return this.pageTitle;
  }

  public getEntryKey(): string {
    return this.entryKey;
  }

  public setPageDescription(pageDescription: string) {
    this.pageDescription = pageDescription;
  }

  public getPageDescription(): string {
    return this.pageDescription;
  }

  public setParams(params: string) {
    this.params = params;
  }

  public getParams(): string {
    return this.params;
  }

  public getSearchItems(): Array<SearchItem> {
    return this.searchItems;
  }

  public getSupportDevices(): Array<string> {
    return this.supportDevices;
  }
}


export class SearchPageConfig {
  public version: ConfigVersion = new ConfigVersion();
  public searchPages: Array<SearchPage> = [];

  public setSearchPage(searchPages: Array<SearchPage>) {
    this.searchPages = searchPages;
  }

  public getSearchPage(): Array<SearchPage> {
    return this.searchPages;
  }

  public setVersion(version: ConfigVersion) {
    this.version = version;
  }

  public getVersion(): ConfigVersion {
    return this.version;
  }
}
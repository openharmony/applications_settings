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

// import search from '@hms.ai.search';

const indexName: string = 'sysSettings'; // 索引名称
const offset: number = 0; // 分页起始值
const size: number = 100; // 分页大小
const outFields = ['locale', 'title', 'uriParams', 'entryKey', 'parentKey', 'itemName', 'path', 'callbackType', 'wantCallback']; // 输出字段
const queryFieldName: string[] = ['title', 'alias']; // 检索字段
const appsQueryFieldName: string[] = ['appName']; // 已安装应用检索字段
// 已安装应用输出字段
const appOutFields = ['appName', 'bundleName', 'icon', 'appStatus', 'installSource', 'appIndex', 'typeId', 'shortcutId'];
const sourceChannel: number = 1;
const pcAppOutFields = ['appName', 'bundleName', 'abilityName', 'moduleName', 'sourceChannel', 'typeId',
  'supportDesktopIcon', 'appStatus', 'installSource', 'appIndex'];
const pcSize: number = 80;

// const searchIndex: search.Index = {
//   indexId: '',
//   ownerId: '',
//   indexName: indexName,
//   schemaType: 5,
//   version: '',
// };

// const searchAppIndex: search.Index = {
//   indexId: '',
//   ownerId: '',
//   indexName: 'sysApp',
//   schemaType: 5,
//   version: '',
// };
//
// const searchPcAppIndex: search.Index = {
//   indexId: '',
//   ownerId: '',
//   indexName: 'sysApp',
//   schemaType: 1,
//   version: '',
// };

export class SearchDataConfig {
  // static getSearchQuery(value: string): search.Query {
  //   let queryClause: search.SimpleQueryClause = {
  //     query: value,
  //     searchFields: queryFieldName,
  //     queryType: 'match'
  //   };
  //
  //   let filterClause: search.CompareFilter = {
  //     field: 'displayStatus',
  //     operator: 'eq',
  //     value: 1
  //   };
  //
  //   const query: search.Query = {
  //     index: searchIndex,
  //     outFields: outFields,
  //     query: queryClause,
  //     filter: filterClause,
  //     offset: offset,
  //     size: size
  //   };
  //   return query;
  // }
}

export class SearchAppsDataConfig {
  // static getSearchQuery(value: string): search.Query {
  //   let queryClause: search.SimpleQueryClause = {
  //     query: value,
  //     searchFields: appsQueryFieldName,
  //     queryType: 'match'
  //   };
  //
  //   let filterClause: search.CompareFilter = {
  //     field: 'sourceChannel',
  //     operator: 'eq',
  //     value: sourceChannel // 1 桌面 2 bms （可能无图标）
  //   };
  //
  //   const query: search.Query = {
  //     index: searchAppIndex,
  //     outFields: appOutFields,
  //     query: queryClause,
  //     offset: offset,
  //     size: size,
  //     filter: filterClause,
  //   };
  //   return query;
  // }
  //
  // static getPcSearchQuery(value: string): search.Query {
  //   let queryClause: search.SimpleQueryClause = {
  //     query: value,
  //     searchFields: appsQueryFieldName,
  //     queryType: 'match'
  //   };
  //
  //   let supportDesktopIconFilter: search.CompareFilter = {
  //     field: 'supportDesktopIcon',
  //     operator: 'eq',
  //     value: 1
  //   };
  //
  //   let sourceChallengeFilter: search.CompareFilter = {
  //     field: 'sourceChannel',
  //     operator: 'eq',
  //     value: 2
  //   };
  //
  //   let logicFilters: search.LogicalFilterClause = {
  //     logicalOperator: 'and',
  //     clauses: [supportDesktopIconFilter, sourceChallengeFilter]
  //   };
  //
  //   const query: search.Query = {
  //     index: searchPcAppIndex,
  //     outFields: pcAppOutFields,
  //     query: queryClause,
  //     offset: offset,
  //     size: pcSize,
  //     filter: logicFilters,
  //   };
  //   return query;
  // }
}

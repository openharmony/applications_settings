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

export const SEARCHHISTORY_TABLE = 'SEARCHHISTORY_TABLE';

export const SQL_CREATE_SEARCHHISTORY_TABLE = `
  CREATE TABLE IF NOT EXISTS ${SEARCHHISTORY_TABLE} (
    ID INTEGER PRIMARY KEY AUTOINCREMENT,
    query TEXT NOT NULL,
    timestamp INTEGER NOT NULL
  );
`;

export const SQL_DELETE_SEARCHHISTORY_TABLE = `
  DELETE FROM ${SEARCHHISTORY_TABLE};
`;

export interface SearchHistory {
  query: string,
  timestamp: number,
}
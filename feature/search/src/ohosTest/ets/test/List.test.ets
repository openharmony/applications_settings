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

import SearchControllerTest from './controller/SearchController.test';
import SearchHistoryControllerTest from './controller/SearchHistoryController.test';
import SettingPageDescControllerTest from './controller/SettingPageDescController.test';
import EnableSearchItemsTest from './service/EnableSearchItems.test';
import RdbStoreInitServiceTest from './service/RdbStoreInitService.test';
import SearchEnableServiceTest from './service/SearchEnableService.test';
import SearchConfigFileParserTest from './util/SearchConfigFileParser.test';

export default function SearchTestSuite() {
  SearchControllerTest();
  SearchHistoryControllerTest();
  SettingPageDescControllerTest();
  RdbStoreInitServiceTest();
  SearchEnableServiceTest();
  EnableSearchItemsTest();
  SearchConfigFileParserTest();
}
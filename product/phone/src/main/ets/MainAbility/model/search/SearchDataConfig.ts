/**
 * Copyright (c) 2021 Huawei Device Co., Ltd.
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
import SettingListProvider from '../../model/settingListImpl/SettingListProvider';
import WifiProvider from '../../model/wifiImpl/WifiProvider';
import DummyProvider from './DummyProvider';

/**
 * Search data config
 */
const SEARCH_DATA_CONFIG = [
  {
    settingUri: 'pages/settingList',
    settingRawJson: 'settinglist.json',
    provider: SettingListProvider
  },
  {
    settingUri: 'pages/wifi',
    settingRawJson: 'wifi.json',
    provider: WifiProvider
  },
  // DummyProvider as example, and should be removed in the further.
  {
    settingUri: 'pages/wifi',
    settingRawJson: 'wifi.json',
    provider: DummyProvider
  }
];

export default SEARCH_DATA_CONFIG;

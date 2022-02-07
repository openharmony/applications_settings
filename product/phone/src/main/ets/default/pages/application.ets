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
import EntryComponent from '../../../../../../../common/component/src/main/ets/default/entryComponent.ets';
import HeadComponent from '../../../../../../../common/component/src/main/ets/default/headComponent.ets';

/**
 * Application
 */
@Entry
@Component
struct Application {
  build() {
    Column() {
      HeadComponent({ headName: $r('app.string.applyTab'), isActive: true });
      Navigator({ target: 'pages/appManagement' }) {
        EntryComponent({
          settingIcon: '',
          settingTitle: $r('app.string.appManagement'),
          settingSummary: '',
          settingValue: '',
          settingArrow: '/res/image/ic_settings_arrow.svg',
          settingArrowStyle: '',
          settingUri: ''
        });
      }
      Navigator({ target: '' }) {
        EntryComponent({
          settingIcon: '',
          settingTitle: $r("app.string.authorityManagement"),
          settingSummary: '',
          settingValue: '',
          settingArrow: '/res/image/ic_settings_arrow.svg',
          settingArrowStyle: '',
          settingUri: ''
        });
      }
    }
  }

}
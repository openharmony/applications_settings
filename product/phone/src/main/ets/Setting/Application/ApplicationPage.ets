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

import { NavEntryKey } from '@ohos/settings.common/src/main/ets/utils/Consts';
import { PageLoader } from '@ohos/settings.common/src/main/ets/framework/common/PageLoader';
import { PageType, SettingPageModel } from '@ohos/settings.common/src/main/ets/framework/model/SettingPageModel';
import { GroupType } from '@ohos/settings.common/src/main/ets/framework/model/SettingGroupModel';
import { SettingTabsModel } from '@ohos/settings.common/src/main/ets/framework/model/SettingTabsModel';
import { EVENT_ID_APP_TAB_CHANGE_EVENT } from '@ohos/settings.common/src/main/ets/event/types';
import { PADDING_8 } from '@ohos/settings.common/src/main/ets/constant/StyleConstant';
import {
  EVENT_ID_SEARCH_BAR_VISIBLE
} from '@ohos/settings.common/src/main/ets/event/types';
import { EventBus } from '@ohos/settings.common/src/main/ets/framework/common/EventBus';
import {
  notifyCompStateChange,
  SettingBaseState,
  SettingCompState,
  SettingStateType
} from '@ohos/settings.common/src/main/ets/framework/model/SettingStateModel';
import { EVENT_ID_SEARCH_NO_EDIT } from '@ohos/settings.common/src/main/ets/event/types';
import { AccessibilityUtils } from '@ohos/settings.common/src/main/ets/utils/AccessibilityUtils';
import { BundleListController } from '@ohos/settings.application/src/main/ets/controller/BundleListController';
import { ApplicationPageController } from '@ohos/settings.application/src/main/ets/controller/ApplicationPageController';
import { SearchBundleListController } from '@ohos/settings.application/src/main/ets/controller/SearchBundleListController'
import { BaseAppLoadingComponent } from '@ohos/settings.application/src/main/ets/view/BaseAppLoadingComponent';
import { EmptyServiceComponent } from '@ohos/settings.application/src/main/ets/view/EmptyServiceComponent';
import { EmptySearchComponent } from '@ohos/settings.application/src/main/ets/view/EmptySearchComponent';
import { CustomMenuComponent } from './components/CustomMenuComponent';
import { CoverComponent } from './components/CoverComponent';
import { SearchComponent } from './components/SearchTitleBarComponent';
/* instrument ignore file */
let tabIndex: number = 0;

@Builder
function loadingBuilder(param: object): void {
  BaseAppLoadingComponent();
}

@Builder
function emptyServiceBuilder(param: object): void {
  EmptyServiceComponent();
}

@Builder
function emptySearchBuilder(param: object): void {
  EmptySearchComponent();
}

@Builder
function coverBuilder(param: object): void {
  CoverComponent();
}

@Builder
function searchTitleBarBuilder(param: object): void {
  SearchComponent({
    menuBuilder: wrapBuilder(customMenuBuilder),
    onMoreIconClicked: onMenuClick,
    onClickSearchBack: onSearchBackClick,
    onChangeSearchText: onSearchTextChange,
    onClickSearchIcon: onSearchIconClick
  });
}

@Builder
function customMenuBuilder(): void {
  CustomMenuComponent();
}

function customPage(): SettingPageModel {
  tabIndex = 0;
  let systemController: SearchBundleListController = new SearchBundleListController();
  let unSystemController: SearchBundleListController = new SearchBundleListController();
  let containerController: SearchBundleListController = new SearchBundleListController();
  let serviceController: SearchBundleListController = new SearchBundleListController();
  let pageController: ApplicationPageController = new ApplicationPageController(onSearchBackClick);
  pageController.registerController(systemController);
  pageController.registerController(unSystemController);
  pageController.registerController(containerController);
  pageController.registerController(serviceController);
  return {
    id: 'Application',
    url: NavEntryKey.APPLICATION_SERVICE_ENTRY,
    type: PageType.PAGE_TYPE_STANDARD,
    compControl: pageController,
    layout: {
      hideTitleBar: true,
      padding: {
        top: PADDING_8
      }
    },
    titleBar: {
      id: 'AppTitleBar',
      builder: wrapBuilder(searchTitleBarBuilder),
    },
    tabs: getTabs(),
    groupForeground: {
      id: 'CoverGroup',
      builder: wrapBuilder(coverBuilder)
    },
    groups: [
      {
        id: 'ApplicationSystemGroup',
        type: GroupType.GROUP_TYPE_DYNAMIC_LAZY,
        compControl: systemController,
      },
      {
        id: 'ApplicationUnSystemGroup',
        type: GroupType.GROUP_TYPE_DYNAMIC_LAZY,
        compControl: unSystemController,
      },
      {
        id: 'ApplicationContainerGroup',
        type: GroupType.GROUP_TYPE_DYNAMIC_LAZY,
        compControl: containerController,
      },
      {
        id: 'ServiceGroup',
        type: GroupType.GROUP_TYPE_DYNAMIC_LAZY,
        compControl: serviceController,
      },
      {
        id: 'EmptyAppGroup',
        type: GroupType.GROUP_TYPE_CUSTOM,
        builder: wrapBuilder(emptyServiceBuilder),
      }
    ],
    onTabSelected(index: number) {
      tabIndex = index;
      AccessibilityUtils.announceRadioSelected();
    },
    onTouchEvent: (type: TouchType) => {
      if (type === TouchType.Down) {
        EventBus.getInstance().emit(EVENT_ID_SEARCH_NO_EDIT);
      }
    }
  }
}

function getTabs(): SettingTabsModel[] {
  return [
    {
      id: 'ApplicationTab',
      content: $r('app.string.storage_apps'),
      groups: [
        {
          id: 'ApplicationSystemGroup',
          type: GroupType.GROUP_TYPE_DYNAMIC_LAZY,
          compControl: new BundleListController(),
        },
        {
          id: 'ApplicationUnSystemGroup',
          type: GroupType.GROUP_TYPE_DYNAMIC_LAZY,
          compControl: new BundleListController(),
        },
        {
          id: 'ApplicationContainerGroup',
          type: GroupType.GROUP_TYPE_DYNAMIC_LAZY,
          compControl: new BundleListController(),
        },
        {
          id: 'LoadingGroup',
          type: GroupType.GROUP_TYPE_CUSTOM,
          builder: wrapBuilder(loadingBuilder),
        },
      ]
    }
  ]
}

function onMenuClick(): void {
  EventBus.getInstance().emit(EVENT_ID_APP_TAB_CHANGE_EVENT, {
    data: {
      tabIndex
    }
  });
}

function onSearchIconClick(): void {
  notifyMessage(true, true);
}

function onSearchTextChange(newValue: string, oldValue: string): void {
  if (newValue.length > 0) {
    notifyCompStateChange('Setting.Application',
      new Map<SettingStateType, SettingBaseState>([[SettingStateType.STATE_TYPE_PAGE_CHANGE, {
        state: true,
      } as SettingCompState]]
      ));
    notifyMessage(true, false, newValue);
  }
  if (oldValue.length > 0 && newValue.length === 0) {
    notifyCompStateChange('Setting.Application',
      new Map<SettingStateType, SettingBaseState>([[SettingStateType.STATE_TYPE_PAGE_CHANGE, {
        state: false,
      } as SettingCompState]]
      ));
    notifyMessage(true, true);
  }
  EventBus.getInstance().emit('EVENT_ID_APP_LIST_SEARCH_LOADER', newValue);
}

function onSearchBackClick(): void {
  notifyCompStateChange('Setting.Application',
    new Map<SettingStateType, SettingBaseState>([[SettingStateType.STATE_TYPE_PAGE_CHANGE, {
      state: false,
    } as SettingCompState]]
    ));
  notifyMessage(false, false, '');
}

function notifyMessage(isSearching: boolean, coverVisible: boolean, searchWord: string = '') {
  EventBus.getInstance().emit(EVENT_ID_SEARCH_BAR_VISIBLE, isSearching, coverVisible, searchWord);
}

// 页面配置导入
PageLoader.load(NavEntryKey.APPLICATION_SERVICE_ENTRY, {
  configGenerator: customPage,
});
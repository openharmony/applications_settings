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
import Log from '../../../../../../../common/utils/src/main/ets/default/baseUtil/LogDecorator';
import PageSearchDataProvider from '../../../../../../../common/search/src/main/ets/default/provider/PageSearchDataProvider';
import WifiModel from '../../model/wifiImpl/WifiModel';

const SEARCH_DATA = {
    title: $r('app.string.wifiTab'),
    data: [
        {
            keyword: $r('app.string.wifiTab'),
            summary: $r('app.string.tipsContent'),
            synonym: $r('app.string.wifiSynonym')
        }
    ]
};

/**
 * Dummy provider as an example, and should be removed in the further.
 *
 */
export class DummyProvider extends PageSearchDataProvider {

  /**
   * Get page search data
   */
    @Log
    getPageSearchData(): any {
        let searchData = SEARCH_DATA

        if (WifiModel.isWiFiActive()) {
            searchData.data.push(
                {
                    keyword: $r('app.string.wifiList'),
                    summary: undefined,
                    synonym: $r('app.string.wifiListSynonym')
                }
            )
        }

        return searchData;
    }

}

let dummyProvider = new DummyProvider();
export default dummyProvider as DummyProvider
;
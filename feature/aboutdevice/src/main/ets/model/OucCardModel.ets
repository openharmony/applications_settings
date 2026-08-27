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

import { IAboutDevicePageModel } from './IAboutDevicePageModel';

@Observed
export class OucCardModel {
  private parent: IAboutDevicePageModel;
  public size: SizeOptions = {
    width: '100%',
    height: '100%'
  };
  public oucPreloadImgSize: SizeOptions = {
    height: '100%',
    width: '100%'
  };
  public isOucPreloadImgShow: boolean = true;

  constructor(parent: IAboutDevicePageModel) {
    this.parent = parent;
  }

  getPreviewUri() {
    return $r('app.media.picture_check');
  }
}
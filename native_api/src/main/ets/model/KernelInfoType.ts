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

/**
 * 内核版本信息类型
 */
export class KernelInfoType {

  // release信息
  public static readonly KERNEL_RELEASE: number = 1;

  // sysName信息
  public static readonly KERNEL_SYS_NAME: number = 2;

  // nodeName信息
  public static readonly KERNEL_NODE_NAME: number = 3;

  // version信息
  public static readonly KERNEL_VERSION: number = 4;
}
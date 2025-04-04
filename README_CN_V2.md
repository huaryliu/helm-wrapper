# A [Helm3](https://github.com/helm/helm) HTTP Wrapper With Go SDK

Helm3 摒弃了 Helm2 的 Tiller 架构，使用纯命令行的方式执行相关操作。如果想通过 Helm API 来实现相关功能，很遗憾官方并没有提供类似的服务。不过，因为官方提供了相对友好的 [Helm Go SDK](https://helm.sh/docs/topics/advanced/)，我们只需在此基础上做封装即可实现。[helm-wrapper](https://github.com/opskumu/helm-wrapper) 就是这样一个通过 Go [Gin](https://github.com/gin-gonic/gin) Web 框架，结合 Helm Go SDK 封装的 HTTP Server，让 Helm 相关的日常命令操作可以通过 Restful API 的方式来实现同样的操作。

## Support API

* 如果某些API需要支持多个集群，则可以使用以下参数

| Params | Description |
| :- | :- |
| kube_context | 支持指定kube_context来区分不同集群 |

helm 原生命令行和相关 API 对应关系：

+ helm install
    - `POST`
    - `/api/namespaces/:namespace/releases/:release?chart=<chartName>`

POST Body: 

``` json
{
    "dry_run": false,           // `--dry-run`
    "disable_hooks": false,     // `--no-hooks`
    "wait": false,              // `--wait`
    "devel": false,             // `--false`
    "description": "",          // `--description`
    "atomic": false,            // `--atomic`
    "skip_crds": false,         // `--skip-crds`
    "sub_notes": false,         // `--render-subchart-notes`
    "create_namespace": false,  // `--create-namespace`
    "dependency_update": false, // `--dependency-update`
    "values": "",               // `--values`
    "set": [],                  // `--set`
    "set_string": [],           // `--set-string`
    "ca_file": "",              // `--ca-file`
    "cert_file": "",            // `--cert-file`
    "key_file": "",             // `--key-file`
    "insecure_skip_verify": "", // `--insecure-skip-verify`
    "keyring": "",              // `--keyring`
    "password": "",             // `--password`
    "repo": "",                 // `--repo`
    "username": "",             // `--username`
    "verify": false,            // `--verify`
    "version": ""               // `--version`
}
```

> 此处 values 内容同 helm install `--values` 选项

+ helm uninstall
    - `DELETE`
    - `/api/namespaces/:namespace/releases/:release`


+ helm upgrade
    - `PUT`
    - `/api/namespaces/:namespace/releases/:release?chart=<chartName>`

PUT Body: 

``` json
{
    "dry_run": false,           // `--dry-run`
    "disable_hooks": false,     // `--no-hooks`
    "wait": false,              // `--wait`
    "devel": false,             // `--false`
    "description": "",          // `--description`
    "atomic": false,            // `--atomic`
    "skip_crds": false,         // `--skip-crds`
    "sub_notes": false,         // `--render-subchart-notes`
    "force": false,             // `--force`
    "install": false,           // `--install`
    "recreate": false,          // `--recreate`
    "cleanup_on_fail": false,   // `--cleanup-on-fail`
    "values": "",               // `--values`
    "set": [],                  // `--set`
    "set_string": [],           // `--set-string`
    "ca_file": "",              // `--ca-file`
    "cert_file": "",            // `--cert-file`
    "key_file": "",             // `--key-file`
    "insecure_skip_verify": "", // `--insecure-skip-verify`
    "keyring": "",              // `--keyring`
    "password": "",             // `--password`
    "repo": "",                 // `--repo`
    "username": "",             // `--username`
    "verify": false,            // `--verify`
    "version": ""               // `--version`
}
```


> 此处 values 内容同 helm upgrade `--values` 选项

+ helm rollback
    - `PUT`
    - `/api/namespaces/:namespace/releases/:release/versions/:reversion`

PUT Body 可选:

``` json
{
    "dry_run": false,           // `--dry-run`
    "disable_hooks": false,     // `--no-hooks`
    "wait": false,              // `--wait`
    "force": false,             // `--force`
    "recreate": false,          // `--recreate`
    "cleanup_on_fail": false,   // `--cleanup-on-fail`
    "history_max":              // `--history-max` int
}
```

+ helm list
    - `GET`
    - `/api/namespaces/:namespace/releases`

Body:

``` json
{
    "all": false,               // `--all`
    "all_namespaces": false,    // `--all-namespaces`
    "by_date": false,           // `--date`
    "sort_reverse": false,      // `--reverse`
    "limit":  ,                 // `--max`
    "offset": ,                 // `--offset`
    "filter": "",               // `--filter`
    "uninstalled": false,       // `--uninstalled`
    "uninstalling": false,      // `--uninstalling`
    "superseded": false,        // `--superseded`
    "failed": false,            // `--failed`
    "deployed": false,          // `--deployed`
    "pending": false            // `--pending`
}
```

+ helm get
    - `GET`
    - `/api/namespaces/:namespace/releases/:release`

| Params | Description |
| :- | :- |
| info | 支持 hooks/manifest/notes/values 信息，默认为 values |
| output | values 输出格式（仅当 info=values 时有效），支持 json/yaml，默认为 json |

+ helm release history
    - `GET`
    - `/api/namespaces/:namespace/releases/:release/histories`


+ helm show
    - `GET`
    - `/api/charts`

| Params | Description |
| :- | :- |
| chart  | 指定 chart 名，必填 |
| info   | 支持 all/readme/values/chart 信息，默认为 all |
| version | 支持版本指定，同命令行 |

+ helm search repo 
    - `GET`
    - `/api/repositories/charts`

| Params | Description |
| :- | :- |
| keyword | 搜索关键字，必填 |
| version | 指定 chart version |
| versions | if "true", all versions |

+ helm repo list
    - `GET`
    - `/api/repositories`


+ helm repo update
    - `PUT`
    - `/api/repositories`

+ helm env
    - `GET`
    - `/api/envs`

+ upload chart
    - `POST`
    - `/api/charts/upload`

| Params | Description |
| :- | :- |
| chart | chart 包，必须为 .tgz 文件 |

+ list local charts
    - `GET`
    - `/api/charts/upload`

> 当前该版本处于 Alpha 状态，还没有经过大量的测试，只是把相关的功能测试了一遍，你也可以在此基础上自定义适合自身的版本。



## Support API -V2

------

------

为了支撑多集群场景，新增以下接口：

#### 集群配置文件【新增】

- upload
  - POST
  - `/api/k8s/config/upload`

Form:

| Params | Description    |
| :----- | :------------- |
| file   | 集群的配置文件 |

返回值

```json
{
    "code": 200,
    "data": "7fc76a25-14c5-4da8-b19a-985a36dfdc95"
}
```

> 说明：其中返回的data为集群的ID，后续使用Helm接口中URL中的cluster就是返回的data的值

#### Helm-V2

+ helm install
  - `POST`
  - `/api/namespaces/:namespace/releases/v2/:cluster/install/:release`

Form: 

| Params | Description                                                  |
| :----- | :----------------------------------------------------------- |
| chart  | chart 包，必须为 .tgz 文件                                   |
| args   | {<br/>    "dry_run": false,           // `--dry-run`<br/>    "disable_hooks": false,     // `--no-hooks`<br/>    "wait": false,              // `--wait`<br/>    "devel": false,             // `--false`<br/>    "description": "",          // `--description`<br/>    "atomic": false,            // `--atomic`<br/>    "skip_crds": false,         // `--skip-crds`<br/>    "sub_notes": false,         // `--render-subchart-notes`<br/>    "create_namespace": false,  // `--create-namespace`<br/>    "dependency_update": false, // `--dependency-update`<br/>    "values": "",               // `--values`<br/>    "set": [],                  // `--set`<br/>    "set_string": [],           // `--set-string`<br/>    "ca_file": "",              // `--ca-file`<br/>    "cert_file": "",            // `--cert-file`<br/>    "key_file": "",             // `--key-file`<br/>    "insecure_skip_verify":  false, // `--insecure-skip-verify`<br/>    "keyring": "",              // `--keyring`<br/>    "password": "",             // `--password`<br/>    "repo": "",                 // `--repo`<br/>    "username": "",             // `--username`<br/>    "verify": false,            // `--verify`<br/>    "version": ""               // `--version`<br/>} |

> - cluster的值是`集群配置文件`接口返回的data值
> - args中可以不包含全部字段，如果只设置set字段，可以只包含set字段，set字段的写法如下：
>
> ```json
> {               
>     "set": ["replicaCount=2"]               
> }
> ```
>
> - 此处 values 内容同 helm install `--values` 选项



+ helm upgrade
  - `POST`
  - `/api/namespaces/:namespace/releases/v2/:cluster/upgrade/:release`

Form: 

| Params | Description                                                  |
| :----- | :----------------------------------------------------------- |
| chart  | chart 包，必须为 .tgz 文件                                   |
| args   | {<br/>    "dry_run": false,           // `--dry-run`<br/>    "disable_hooks": false,     // `--no-hooks`<br/>    "wait": false,              // `--wait`<br/>    "devel": false,             // `--false`<br/>    "description": "",          // `--description`<br/>    "atomic": false,            // `--atomic`<br/>    "skip_crds": false,         // `--skip-crds`<br/>    "sub_notes": false,         // `--render-subchart-notes`<br/>    "create_namespace": false,  // `--create-namespace`<br/>    "dependency_update": false, // `--dependency-update`<br/>    "values": "",               // `--values`<br/>    "set": [],                  // `--set`<br/>    "set_string": [],           // `--set-string`<br/>    "ca_file": "",              // `--ca-file`<br/>    "cert_file": "",            // `--cert-file`<br/>    "key_file": "",             // `--key-file`<br/>    "insecure_skip_verify": false, // `--insecure-skip-verify`<br/>    "keyring": "",              // `--keyring`<br/>    "password": "",             // `--password`<br/>    "repo": "",                 // `--repo`<br/>    "username": "",             // `--username`<br/>    "verify": false,            // `--verify`<br/>    "version": ""               // `--version`<br/>} |




> - cluster的值是`集群配置文件`接口返回的data值
> - args中可以不包含全部字段，如果只设置set字段，可以只包含set字段，set字段的写法如下：
>
> ```json
> {               
>     "set": ["replicaCount=2"]               
> }
> ```
>
> - 此处 values 内容同 helm install `--values` 选项
> - release要保证已经安装过，不然会报错



+ helm list
  - `GET`
  - `/api/namespaces/:namespace/releases/v2/:cluster`

Body:

``` json
{
    "all": false,               // `--all`
    "all_namespaces": false,    // `--all-namespaces`
    "by_date": false,           // `--date`
    "sort_reverse": false,      // `--reverse`
    "limit":  ,                 // `--max`
    "offset": ,                 // `--offset`
    "filter": "",               // `--filter`
    "uninstalled": false,       // `--uninstalled`
    "uninstalling": false,      // `--uninstalling`
    "superseded": false,        // `--superseded`
    "failed": false,            // `--failed`
    "deployed": false,          // `--deployed`
    "pending": false            // `--pending`
}
```

+ helm get
  - `GET`
  - `/api/namespaces/:namespace/releases/v2/:cluster/:release`
+ helm uninstall
  - `DELETE`
  - `/api/namespaces/:namespace/releases/v2/:cluster/:release`
+ helm rollback
  - `PUT`
  - `/api/namespaces/:namespace/releases/v2/:cluster/:release/versions/:reversion`
+ helm release status
  - `GET`
  - `/api/namespaces/:namespace/releases/v2/:cluster/:release/status`
+ helm release history
  - `GET`
  - `/api/namespaces/:namespace/releases/v2/:cluster/:release/histories`

------

------



### 响应

为了简化，所有请求统一返回 200 状态码，通过返回 Body 中的 Code 值来判断响应是否正常：

``` go
type respBody struct {
    Code  int         `json:"code"` // 0 or 1, 0 is ok, 1 is error
    Data  interface{} `json:"data,omitempty"`
    Error string      `json:"error,omitempty"`
}
```

------

------

**【修改】**

```go
type respBody struct {
    Code  int         `json:"code"` // 200 or 500, 200 is ok, 500 is error
    Data  interface{} `json:"data,omitempty"`
    Error string      `json:"error,omitempty"`
}
```

------

------



## Build & Run 

### Build

源码提供了简单的 `Makefile` 文件，如果要构建二进制，只需要通过以下方式构建即可。

```
make build          // 构建当前主机架构的二进制版本
make build-linux    // 构建 Linux 版本的二进制
make build-docker   // 构建 Docker 镜像
```

直接构建会生成名为 `helm-wrapper` 的二进制程序，你可以通过如下方式获取帮助：

```
$ helm-wrapper -h
Usage of helm-wrapper:
      --addr string                      server listen addr (default "0.0.0.0")
      --alsologtostderr                  log to standard error as well as files
      --config string                    helm wrapper config (default "config.yaml")
      --debug                            enable verbose output
      --kube-context string              name of the kubeconfig context to use
      --kubeconfig string                path to the kubeconfig file
      --log_backtrace_at traceLocation   when logging hits line file:N, emit a stack trace (default :0)
      --log_dir string                   If non-empty, write log files in this directory
      --logtostderr                      log to standard error instead of files (default true)
  -n, --namespace string                 namespace scope for this request
      --port string                      server listen port (default "8080")
      --registry-config string           path to the registry config file (default "/root/.config/helm/registry.json")
      --repository-cache string          path to the file containing cached repository indexes (default "/root/.cache/helm/repository")
      --repository-config string         path to the file containing repository names and URLs (default "/root/.config/helm/repositories.yaml")
      --stderrthreshold severity         logs at or above this threshold go to stderr (default 2)
  -v, --v Level                          log level for V logs
      --vmodule moduleSpec               comma-separated list of pattern=N settings for file-filtered logging
pflag: help requested
```

关键性的选项说明一下：

+ `--config` helm-wrapper 的配置项，内容如下，主要是指定 Helm Repo 命名和 URL，用于 Repo 初始化。

```
$ cat config-example.yaml
uploadPath: /tmp/charts
helmRepos:
  - name: bitnami
    url: https://charts.bitnami.com/bitnami
```
+ `--kubeconfig` 默认如果你不指定的话，使用默认的路径，一般是 `~/.kube/config`。这个配置是必须的，这指明了你要操作的 Kubernetes 集群地址以及访问方式。`kubeconfig` 文件如何生成，这里不过多介绍，具体可以详见 [Configure Access to Multiple Clusters](https://kubernetes.io/docs/tasks/access-application-cluster/configure-access-multiple-clusters/)

### Run

运行比较简单，如果你本地已经有默认的 `kubeconfig` 文件，只需要把 helm-wrapper 需要的 repo 配置文件配置好即可，然后执行以下命令即可运行，示例如下：

```
$ ./helm-wrapper --config </path/to/config.yaml> --kubeconfig </path/to/kubeconfig>
```

> 启动时会先初始化 repo，因此根据 repo 本身的大小或者网络因素，会耗费些时间

#### 运行在 Kubernetes 集群中

替换 `deployment/deployment.yaml` 中 image 字段为你正确的 helm-wrapper 镜像地址即可，然后执行命令部署：

```
kubectl create -f ./deployment
```

> __注：__ 以上操作会创建 RBAC 相关，因此不需要在构建镜像的时候额外添加 kubeconfig 文件，默认会拥有相关的权限

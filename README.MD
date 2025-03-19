# Дипломный практикум в Yandex.Cloud - Филатов А .В.
  * [Цели:](#цели)
  * [Этапы выполнения:](#этапы-выполнения)
     * [Создание облачной инфраструктуры](#создание-облачной-инфраструктуры)
     * [Создание Kubernetes кластера](#создание-kubernetes-кластера)
     * [Создание тестового приложения](#создание-тестового-приложения)
     * [Подготовка cистемы мониторинга и деплой приложения](#подготовка-cистемы-мониторинга-и-деплой-приложения)
     * [Установка и настройка CI/CD](#установка-и-настройка-cicd)
  * [Что необходимо для сдачи задания?](#что-необходимо-для-сдачи-задания)
  * [Как правильно задавать вопросы дипломному руководителю?](#как-правильно-задавать-вопросы-дипломному-руководителю)

**Перед началом работы над дипломным заданием изучите [Инструкция по экономии облачных ресурсов](https://github.com/netology-code/devops-materials/blob/master/cloudwork.MD).**

---
## Цели:

1. Подготовить облачную инфраструктуру на базе облачного провайдера Яндекс.Облако.
2. Запустить и сконфигурировать Kubernetes кластер.
3. Установить и настроить систему мониторинга.
4. Настроить и автоматизировать сборку тестового приложения с использованием Docker-контейнеров.
5. Настроить CI для автоматической сборки и тестирования.
6. Настроить CD для автоматического развёртывания приложения.

---
## Этапы выполнения:


### Создание облачной инфраструктуры

Для начала необходимо подготовить облачную инфраструктуру в ЯО при помощи [Terraform](https://www.terraform.io/).

Особенности выполнения:

- Бюджет купона ограничен, что следует иметь в виду при проектировании инфраструктуры и использовании ресурсов;
Для облачного k8s используйте региональный мастер(неотказоустойчивый). Для self-hosted k8s минимизируйте ресурсы ВМ и долю ЦПУ. В обоих вариантах используйте прерываемые ВМ для worker nodes.

Предварительная подготовка к установке и запуску Kubernetes кластера.

1. Создайте сервисный аккаунт, который будет в дальнейшем использоваться Terraform для работы с инфраструктурой с необходимыми и достаточными правами. Не стоит использовать права суперпользователя
2. Подготовьте [backend](https://developer.hashicorp.com/terraform/language/backend) для Terraform:  
   а. Рекомендуемый вариант: S3 bucket в созданном ЯО аккаунте(создание бакета через TF)
   б. Альтернативный вариант:  [Terraform Cloud](https://app.terraform.io/)
3. Создайте конфигурацию Terrafrom, используя созданный бакет ранее как бекенд для хранения стейт файла. Конфигурации Terraform для создания сервисного аккаунта и бакета и основной инфраструктуры следует сохранить в разных папках.
4. Создайте VPC с подсетями в разных зонах доступности.
5. Убедитесь, что теперь вы можете выполнить команды `terraform destroy` и `terraform apply` без дополнительных ручных действий.
6. В случае использования [Terraform Cloud](https://app.terraform.io/) в качестве [backend](https://developer.hashicorp.com/terraform/language/backend) убедитесь, что применение изменений успешно проходит, используя web-интерфейс Terraform cloud.

Ожидаемые результаты:

1. Terraform сконфигурирован и создание инфраструктуры посредством Terraform возможно без дополнительных ручных действий, стейт основной конфигурации сохраняется в бакете или Terraform Cloud
2. Полученная конфигурация инфраструктуры является предварительной, поэтому в ходе дальнейшего выполнения задания возможны изменения.

### Решение

## ШАГ 1: Настройка Yandex Cloud
* Для работы с Yandex Cloud необходимо установить Yandex CLI:
 - запустим выполнение скрипта по установке
```
curl -sSL https://storage.yandexcloud.net/yandexcloud-yc/install.sh | bash
```
 - перезапустим оболочку 
```
exec -l $SHELL
```
 - авторизуемся в Yandex Cloud:
```
yc init
```
[alt text](Screenshot_1.png)

## ШАГ 2: Настройка Terraform
* Для работы с Terraform нужно его установить:
 - скачаем диструбутив с офф. сайта и распакуем архив
 - переместим в директорию 
```
 sudo mv terraform /usr/local/bin/
```
 - добавим права на выполнение файла
```
sudo chmod +x /usr/local/bin/terraform
```
 - проверим работоспособность
 ```
 terraform --version
 ```
[Screenshot_2.png]

## ШАГ 3: Установка провайдера Yandex Cloud
* Создадим файл ~/.terraformrc и добавим блок 
```
provider_installation {
    network_mirror {
        url = "https://terraform-mirror.yandexcloud.net/"
        include = ["registry.terraform.io/*/*"]
}
    direct {
        exclude = ["registry.terraform.io/*/*"]
    }
}
```

## ШАГ 4: Подготовка сервисного аккаунта и backend для Terraform
* подготовим файлы terraform: 
/diplom/sa-backet/
[main.tf] [outputs.tf] [providers.tf] [variables.tf] [terraform.tfvars]
  * main.tf
    - Создание сервисного аккаунта
    - Назначение роли storage.editor сервисному аккаунту (для управления бакетом)
    - Создание статического ключа доступа
    - Создание S3-бакета для хранения Terraform state
    - Создание файла ~/.aws/credentials для использования AWS Profile
    - Создание файл конфигурации backend.tf для Terraform

* Описание комманд по запуску подготовленных файлов
```
terraform init
```
[Screenshot_3.png]

```
terraform validate
terraform plan
terraform apply
```
[Screenshot_4.png]

 - По окончанию работы Terraform у нас создан сервисный аккаунт, файл backend.tf для дальнейшего его использования при разворачивании vpc. Данные секрета добавлены в профиль, для более удобного использования.

## Создадим json файл для сервисного аккаунта
```
yc iam key create --service-account-id ************** --output ~/diplom/sa-key-init.json
```

## ШАГ 5: Подготовка файлов для разворачивания vpc
* подготовим файлы terraform: 
/diplom/terraform/
[main.tf] [outputs.tf] [providers.tf] [variables.tf] [terraform.tfvars] [backend.tf]
  * main.tf
    - Создание VPC
    - Создание подсети в доступных зонах
  * backend.tf
    - файл создан на предыдущем шаге

* Описание комманд по запуску подготовленных файлов
```
terraform init
```
[Screenshot_5.png]
  - Видим что Terraform теперь использует backend

```
terraform validate
terraform plan
terraform apply
```
[Screenshot_6.png]
  - Появился файл terraform.tfstate в бакете
[Screenshot_7.png]

* Проверяем что можем выполнить команды `terraform destroy` и `terraform apply` без дополнительных ручных действий.

[Screenshot_8.png]
[Screenshot_9.png]


---
### Создание Kubernetes кластера

На этом этапе необходимо создать [Kubernetes](https://kubernetes.io/ru/docs/concepts/overview/what-is-kubernetes/) кластер на базе предварительно созданной инфраструктуры.   Требуется обеспечить доступ к ресурсам из Интернета.

Это можно сделать двумя способами:

1. Рекомендуемый вариант: самостоятельная установка Kubernetes кластера.  
   а. При помощи Terraform подготовить как минимум 3 виртуальных машины Compute Cloud для создания Kubernetes-кластера. Тип виртуальной машины следует выбрать самостоятельно с учётом требовании к производительности и стоимости. Если в дальнейшем поймете, что необходимо сменить тип инстанса, используйте Terraform для внесения изменений.  
   б. Подготовить [ansible](https://www.ansible.com/) конфигурации, можно воспользоваться, например [Kubespray](https://kubernetes.io/docs/setup/production-environment/tools/kubespray/)  
   в. Задеплоить Kubernetes на подготовленные ранее инстансы, в случае нехватки каких-либо ресурсов вы всегда можете создать их при помощи Terraform.
2. Альтернативный вариант: воспользуйтесь сервисом [Yandex Managed Service for Kubernetes](https://cloud.yandex.ru/services/managed-kubernetes)  
  а. С помощью terraform resource для [kubernetes](https://registry.terraform.io/providers/yandex-cloud/yandex/latest/docs/resources/kubernetes_cluster) создать **региональный** мастер kubernetes с размещением нод в разных 3 подсетях      
  б. С помощью terraform resource для [kubernetes node group](https://registry.terraform.io/providers/yandex-cloud/yandex/latest/docs/resources/kubernetes_node_group)
  
Ожидаемый результат:

1. Работоспособный Kubernetes кластер.
2. В файле `~/.kube/config` находятся данные для доступа к кластеру.
3. Команда `kubectl get pods --all-namespaces` отрабатывает без ошибок.

### Решение

## ШАГ 1: Подготовка файлов для разворачивания кластера k8s
* Подготовим файлы Terraform для разворачивания кластера k8s, воспользуемся сервисом Yandex Managed Service for Kubernetes
/diplom/terraform-mks
[k8s-cluster.tf] [mks-node-group.tf] [outputs.tf] [providers.tf] [backend.tf] [remote_state.tf] [variables.tf] [terraform.tfvars]

* remot_state.tf
  - Подключение к удаленному состоянию Terraform, для получения данных id vpc и подсети

* providers.tf
  - Добавили в данный файл, блок с данными для подключения к beckend и размещением состония в отдельной дериктории.

* k8s-cluster.tf
  - Создания кластера k8s
  - Указываем подсети для размещения
  - Создаем аккаунт который будет разворачивать кластер и назначаем ему права

* mks-node-group.tf
  - Создаем и конфигурируем ноды, запуск происходит после выполнения k8s-cluster.tf 

* Добавили роли для сервисного аккаунта, чтоб он мог разворачивать k8s и работать с ним
/diplom/sa-backet
[main.tf]

## ШАГ 2: Установка утилиты для работы с k8s
* для работы с k8s установим утилиту kubectl
```
sudo snap install kubectl --classic
```

## ШАГ 3: Запустим выполнение конфигурации Terraform
* Описание комманд по запуску подготовленных файлов

```
terraform init
```
[Screenshot_10.png]
  - Видим что Terraform теперь использует backend

```
terraform validate
terraform plan
terraform apply
```
[Screenshot_11.png]

## ШАГ 4: Настроим подключение к кластеру k8s
* добавим контекст кластера в файл ~/.kube/config
```
yc managed-kubernetes cluster get-credentials --name mks-cluster --folder-id b1ga79lki1s68b3r289b --external --force
```
[Screenshot_13.png]
* После этого выполним проверку работоспособности
```
kubectl get nodes & kubectl get pods --all-namespaces
```
[Screenshot_14.png]

---
### Создание тестового приложения

Для перехода к следующему этапу необходимо подготовить тестовое приложение, эмулирующее основное приложение разрабатываемое вашей компанией.

Способ подготовки:

1. Рекомендуемый вариант:  
   а. Создайте отдельный git репозиторий с простым nginx конфигом, который будет отдавать статические данные.  
   б. Подготовьте Dockerfile для создания образа приложения.  
2. Альтернативный вариант:  
   а. Используйте любой другой код, главное, чтобы был самостоятельно создан Dockerfile.

Ожидаемый результат:

1. Git репозиторий с тестовым приложением и Dockerfile.
2. Регистри с собранным docker image. В качестве регистри может быть DockerHub или [Yandex Container Registry](https://cloud.yandex.ru/services/container-registry), созданный также с помощью terraform.

### Решение

## ШАГ 1: Подготовка файлов c простым nginx конфигом и Dockerfile для создания образа приложения.
~/test-app/
[index.html] [nginx.conf] [Dockerfile]

## ШАГ 2: Создадим отдельный git репозиторий
* Создадим репозиторий https://github.com/v1us1885/test-app
* Добавим файл README.MD
* Настроим Git
```
echo "# test" >> README.md
git init
git add README.md
git config --global user.email "v1rus1885@mail.ru"
git config --global user.name "FilatovAV"
git commit -m "first commit"
git branch -M master
git remote add origin https://github.com/v1us1885/test-app.git
git push -u origin master
git add .
git commit -m "add test-app"
git push
```
[Screenshot_12.png]

## ШАГ 3: Создадим образ Docker и загрузим на DockerHub
* Для начала работ с Docker требуется его установить
```
sudo apt install -y apt-transport-https ca-certificates curl software-properties-common
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg
echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
sudo apt update
sudo apt install -y docker-ce docker-ce-cli containerd.io
sudo groupadd docker
sudo usermod -aG docker $USER
docker --version
newgrp docker
exec -l $SHELL
```
[Screenshot_16.png]

* Авторизуемся в DockerHub
```
docker login
```
[Screenshot_17.png]

* Соберем образ из папки test-app
```
docker build -t v1rus1885/test-app:latest .
```
[Screenshot_15.png]

* Загрузим образ
```
docker push v1rus1885/test-app:latest
```
[Screenshot_18.png]
[Screenshot_19.png]

---
### Подготовка cистемы мониторинга и деплой приложения

Уже должны быть готовы конфигурации для автоматического создания облачной инфраструктуры и поднятия Kubernetes кластера.  
Теперь необходимо подготовить конфигурационные файлы для настройки нашего Kubernetes кластера.

Цель:
1. Задеплоить в кластер [prometheus](https://prometheus.io/), [grafana](https://grafana.com/), [alertmanager](https://github.com/prometheus/alertmanager), [экспортер](https://github.com/prometheus/node_exporter) основных метрик Kubernetes.
2. Задеплоить тестовое приложение, например, [nginx](https://www.nginx.com/) сервер отдающий статическую страницу.

Способ выполнения:
1. Воспользоваться пакетом [kube-prometheus](https://github.com/prometheus-operator/kube-prometheus), который уже включает в себя [Kubernetes оператор](https://operatorhub.io/) для [grafana](https://grafana.com/), [prometheus](https://prometheus.io/), [alertmanager](https://github.com/prometheus/alertmanager) и [node_exporter](https://github.com/prometheus/node_exporter). Альтернативный вариант - использовать набор helm чартов от [bitnami](https://github.com/bitnami/charts/tree/main/bitnami).

2. Если на первом этапе вы не воспользовались [Terraform Cloud](https://app.terraform.io/), то задеплойте и настройте в кластере [atlantis](https://www.runatlantis.io/) для отслеживания изменений инфраструктуры. Альтернативный вариант 3 задания: вместо Terraform Cloud или atlantis настройте на автоматический запуск и применение конфигурации terraform из вашего git-репозитория в выбранной вами CI-CD системе при любом комите в main ветку. Предоставьте скриншоты работы пайплайна из CI/CD системы.

Ожидаемый результат:
1. Git репозиторий с конфигурационными файлами для настройки Kubernetes.
2. Http доступ на 80 порту к web интерфейсу grafana.
3. Дашборды в grafana отображающие состояние Kubernetes кластера.
4. Http доступ на 80 порту к тестовому приложению.
5. Atlantis или terraform cloud или ci/cd-terraform

### Решение

## ШАГ 1: Настройка мониторинга
* Будем использовать наборы helm 
* Для начала установим helm
```
curl https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 | bash
helm version
```
* Теперь можно приступать к установке мониторинга
```
helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
helm repo update
helm install monitoring-stack prometheus-community/kube-prometheus-stack --namespace monitoring --create-namespace
```
[Screenshot_20.png]

* Проверка развёртывания: Убедимся, что все поды запущены:
```
kubectl get pods -n monitoring
```
[Screenshot_21.png]

* Получим доступ в графану, изменим NodePort на LadBalancer для доступа через web
```
kubectl patch svc monitoring-stack-grafana -n monitoring -p '{"spec": {"type": "LoadBalancer"}}'
kubectl --namespace monitoring get secrets monitoring-stack-grafana -o jsonpath="{.data.admin-password}" | base64 -d ; echo
kubectl get svc -n monitoring
```
[Screenshot_22.png]
[Screenshot_23.png]

## ШАГ 2: Deploy нашего приложения
* подготовим файл deplyment.yaml
[deplyment.yaml]
* выполним наш манифест
```
kubectl apply -f k8s/deployment.yaml
```
* проверим работоспособность нашего приложения
```
kubectl get pods
kubectl get svc test-app-service
```
[Screenshot_24.png]
[Screenshot_25.png]

## ШАГ 3: Создадим отдельный git репозиторий для инфраструктуры
* Создадим репозиторий https://github.com/v1us1885/infra-diplom
* Добавим файл README.MD
* Настроим Git
```
echo "# test" >> README.md
git init
git add README.md
git config --global user.email "v1rus1885@mail.ru"
git config --global user.name "FilatovAV"
git commit -m "first commit"
git branch -M master
git remote add origin https://github.com/v1us1885/infra-diplom.git
git push -u origin master
git add .
git commit -m "add infra-diplom"
git push
```
[Screenshot_25.png]

## ШАГ 4: подготовка ci/cd terraform
* Подготовим файл для terraform apply инфраструктуры при изменении кода
[apply-mks-terraform]

* т.к. github не работает с секретами в jsonn, переведем ключ sa-key-init.json в base64

```
base64 ~/diplom/sa-key-init.json > ~/diplom/sa-key-init.txt
```

## ШАГ 5: Добавим секреты в github
YC_AWS_ACCESS_KEY_ID
YC_AWS_SECRET_ACCESS_KEY
YC_SA_KEY_INIT

## ШАГ 6: проверим изменение инфраструктуры при пуше изменений в коде терраформа
```
git add .
git commit -m " add terraform-msk "
git push origin 
```
[Screenshot_27.png]
[Screenshot_28.png]

---
### Установка и настройка CI/CD

Осталось настроить ci/cd систему для автоматической сборки docker image и деплоя приложения при изменении кода.

Цель:

1. Автоматическая сборка docker образа при коммите в репозиторий с тестовым приложением.
2. Автоматический деплой нового docker образа.

Можно использовать [teamcity](https://www.jetbrains.com/ru-ru/teamcity/), [jenkins](https://www.jenkins.io/), [GitLab CI](https://about.gitlab.com/stages-devops-lifecycle/continuous-integration/) или GitHub Actions.

Ожидаемый результат:

1. Интерфейс ci/cd сервиса доступен по http.
2. При любом коммите в репозиторие с тестовым приложением происходит сборка и отправка в регистр Docker образа.
3. При создании тега (например, v1.0.0) происходит сборка и отправка с соответствующим label в регистри, а также деплой соответствующего Docker образа в кластер Kubernetes.


### Решение

## настроим CI/CD систему с использованием GitHub Actions для автоматической сборки Docker-образа и деплоя в k8s кластер

## ШАГ 1: Сначала создадим workflow файл test-app/.github/workflows/deploy.yml
[deploy.yml]

## ШАГ 2: Создадим отдельный git репозиторий для инфраструктуры
* Создадим репозиторий https://github.com/v1us1885/infra-diplom
* Добавим файл README.MD
* Настроим Git
```
echo "# test" >> README.md
git init
git add README.md
git config --global user.email "v1rus1885@mail.ru"
git config --global user.name "FilatovAV"
git commit -m "first commit"
git branch -M master
git remote add origin https://github.com/v1us1885/test-app.git
git push -u origin master
git add .
git commit -m "add test-app"
git push
```
[Screenshot_29.png]

## ШАГ 3: Добавим секреты в github для работы c dockerhub
DOCKER_HUB_PASSWORD
DOCKER_HUB_USERNAME
YC_SA_KEY_INIT


## ШАГ 4: Проверим что при коммите,  в репозиторие с тестовым приложением происходит сборка и отправка в регистр Docker образа
```
git add .
git commit -m "test deploy, push image"
git push 
```
[Screenshot_31.png]

## ШАГ 5: Проверим что gри создании тега происходит сборка и отправка с соответствующим label в регистри, а также деплой соответствующего Docker образа в кластер Kubernetes.
```
git tag v1.0.1
git push origin v1.0.1
```
[Screenshot_32.png]
[Screenshot_33.png]
[Screenshot_34.png]
[Screenshot_35.png]
[Screenshot_36.png]

---
## Что необходимо для сдачи задания?

1. Репозиторий с конфигурационными файлами Terraform и готовность продемонстрировать создание всех ресурсов с нуля.
2. Пример pull request с комментариями созданными atlantis'ом или снимки экрана из Terraform Cloud или вашего CI-CD-terraform pipeline.
3. Репозиторий с конфигурацией ansible, если был выбран способ создания Kubernetes кластера при помощи ansible.
4. Репозиторий с Dockerfile тестового приложения и ссылка на собранный docker image.
5. Репозиторий с конфигурацией Kubernetes кластера.
6. Ссылка на тестовое приложение и веб интерфейс Grafana с данными доступа.
7. Все репозитории рекомендуется хранить на одном ресурсе (github, gitlab)

## Репозитории:
(https://github.com/v1us1885/infra-diplom)
(https://github.com/v1us1885/test-app)
(https://hub.docker.com/r/v1rus1885/test-app)
(http://158.160.157.1/) - Grafana
(http://51.250.37.150/) - Test-app
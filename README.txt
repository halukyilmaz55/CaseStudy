
NOTLAR: 

- Yapı AWS EKS cluster üzerinde host olacak mimari de tasarlandı. Katmanlar namespace seviyesinde ayrıştırıldı. 
    Cluster içi erişimler any-any acık durumda istenirse Network policy lerle ingress egress uygulanır.
    frontend de react var o configmap lerden enpoint okuyor backend nodejs'ine gidiyor o da son katmanda olan postgresql db sine gidip veri okuyup geri dönüyor.

- Uygulamalar MAC de oluşturuldu. 
    Debian tabanlı sistemlerde code derlenirken AMD olarak;  MAC de ARM olarak derlendiğinden bu runtimeda sorun oluşturuyor.
    Ben MAC de hazırladım bu sebeple host olacakları instance ları da ARM çalıştıracak şekilde seçtim AWS EKS de.

- storageClass olarak biz normalde nfs-clinet veya longhorn tercih ediyoruz. 
    EBS kullanmıyoruz. Fakat burada defaultta **EBS oldugundan emptyDir: {}** ile EBS kullanılmış oldu.

- AWS'nin arayüzünü kullanım için tercih etmedim. 
    Rancher'a generic cluster ekleyerek EKS cluster ını Rancher üzerinden yönetiyorum. (.kubeconfig dosyasında EKS cluster ın contex bilgileri ve token'ı yer alıyor.)
    Bunun da anlatımı paylaşıacak görsel dökümanda yer alacak bunun için Cattle-System Namespace i kuruluyor. Rancher'ın agent ı EKS üzerine import olup arayzden cluster ı yönetmeye başlıyor.
    Cattle-System e ait bir configmap de IAM bilgisinin set edilmesi gerekiyor.

- Uygulamalarımı deploy ederken helm değil kubernetes kustomization yapısını kullanıyorum.

- AWS EKS cluster içindeki default pod sayısını 8 ile sınırlamış.
    Defaultta kullandığı CNI bunu karşılamıyor. 
    O Sebeple biz default'u değil Calico CNI kurup 250 pod kullanacak şekilde ayarlıyoruz.Buna ilişkin komut seti Terraform başlığı altında paylaşıldı.

------------FOLDER HİYERARŞİSİ----------

│── kubernetes-platform/             # Kubernetes YAML dosyaları
│   │── backend/                      # Backend ile ilgili YAML dosyaları
│   │   ├── backend-deployment.yaml
│   │   ├── backend-service.yaml
│   │   ├── kustomization.yaml
│   │   ├── ns.yaml
│   │
│   │── database/                     # Veritabanı (PostgreSQL) ile ilgili YAML dosyaları
│   │   ├── configmap.yaml
│   │   ├── kustomization.yaml
│   │   ├── ns.yaml
│   │   ├── postgres-deployment.yaml
│   │   ├── postgres-service.yaml
│   │
│   │── frontend/                     # Frontend ile ilgili YAML dosyaları
│   │   ├── configmap.yaml
│   │   ├── frontend-deployment.yaml
│   │   ├── frontend-service.yaml
│   │   ├── kustomization.yaml
│   │   ├── ns.yaml
│
│── backend/                          # Backend (Node.js)
│   ├── Dockerfile
│   ├── package.json
│   ├── server.js
│
│── frontend/                         # Frontend (React)
│   ├── Dockerfile
│   ├── package.json
│   ├── src/
│
│── README.md                     



--------- CODE -------

cd /Users/haluk/Desktop/Github
git clone https://github.com/halukyilmaz55/CaseStudy.git
mkdir backend && mkdir frontend && touch README.txt




# BACKEND

# Node.js projesini başlat
npm init -y
npm install
npm start
node server.js

# Gerekli bağımlılıkları yükle
npm install express pg cors dotenv

# Backend'i başlat (EXTRA NOT)
node server.js

--------



# FRONTEND

# React projesini oluştur
npx create-react-app .

# Frontend i başlat (EXTRA NOT)
npm start

----------

# GIT operasyonları

echo "node_modules/" >> .gitignore (içine aşağıdakileri ekle)

node_modules/
.env
.DS_Store
*.log

---Bu esnada CODE lar eklendi----


git rm -r --cached node_modules
git add .gitignore
git add .
git commit -m "Added .gitignore and removed node_modules"
git push origin main


--------CI-CD (AzureDevops)----------

Uygulamalar main branch'ında yazılacağı düşünüldü. Yoksa ayrı branching mekanizamaları işletilebilir.

!! pipeline içeriği "/ci-cd-azuredevops/azure-pipelines.yml" içindedir.

# Docker Image'larını Build Et ve Tag'le

# Login Image Registry 

docker login

---

# BUILD

# Backend için
docker build -t halyil/backend-app:latest -f backend/Dockerfile backend/

# Frontend için
docker build -t halyil/frontend-app:latest -f frontend/Dockerfile frontend/

---

# TAG

# Backend için
docker tag halyil/backend-app:latest halyil/backend-app:v1.0

# Frontend için
docker tag halyil/frontend-app:latest halyil/frontend-app:v1.0

---

# PUSH

# Backend için
docker push halyil/backend-app:v1.0

# Frontend için
docker push halyil/frontend-app:v1.0

--- 

# localimde run etmek istersem (EXTRA NOT)

# Backend uygulamasını çalıştır
docker run -d -p 5000:5000 halyil/backend-app:latest

# Frontend uygulamasını çalıştır
docker run -d -p 3000:3000 halyil/frontend-app:latest



-------------POSTGRESQL DB ISLEMLERI----------------

- pgadmin kurulup arayüz üzerinden ilgili düzenlemler yapılabilir
- alternatif olarak kurulum sonrası postgresql pod'u üzerinden de bağlantı sağlanabilir --> psql -U postgres -h localhost
- default user passowrd genelde postgres postgres olur.

-- Veritabanını oluştur
CREATE DATABASE halukyilmaz55;

-- Kullanıcıyı oluştur ve yetkilendir
CREATE ROLE halukuser WITH LOGIN PASSWORD 'Ale3duysunkr@lSa3sun';
GRANT ALL PRIVILEGES ON DATABASE halukyilmaz55 TO halukuser;

-- DBA rolü oluştur ve yetkilendir
CREATE ROLE dba WITH LOGIN CREATEDB CREATEROLE SUPERUSER PASSWORD 'Ale3duysunkr@lSa3sun';
CREATE ROLE dba WITH LOGIN PASSWORD 'Ale3duysunkr@lSa3sun';
GRANT ALL PRIVILEGES ON DATABASE halukyilmaz55 TO halukuser;
GRANT dba TO halukuser;

-- Veritabanına bağlan
\c halukyilmaz55

-- users tablosunu oluştur
CREATE TABLE users (
    id SERIAL PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    email VARCHAR(150) UNIQUE NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Kullanıcıya tüm yetkileri ver
GRANT ALL PRIVILEGES ON ALL TABLES IN SCHEMA public TO halukuser;
GRANT ALL PRIVILEGES ON ALL SEQUENCES IN SCHEMA public TO halukuser;

-- Örnek kullanıcılar ekle
INSERT INTO users (name, email) VALUES 
    ('Haluk Yılmaz', 'haluk@example.com'),
    ('Ahmet Kaya', 'mete@example.com'),
    ('Mehmet Demir', 'ezgi@example.com');



---------------AWS CREDENTIAL CONFIG IAM ISLEMLERİ & TERRAFORM APPLY-----------------

!!! Terraform tf lerini basmadan evvel aşağıdaki düzenlemelerin yapılmış olması gerekir. !!!

- Çalıştırmadığım için tfstate'i koymadım çünkü içinde hassas veri var.
- aws ve eksctl e ait komut setlerini kullanıyoruz localden 
- öncesinde acces_key ve secret_key komut çalıştırmak için must'tır.

- AWS de bir service account oluşturup yetkilendirip tf lerde credential olarak gösterip, o şekilde de  ilerleyebilirdik, ben bu yöntemle ilerledim.

    aws iam create-access-key --user-name haluk@example.com     # access_key oluştur
    aws iam list-access-keys --user-name haluk@example.com      # access_key listele

    aws iam get-user --user-name haluk@example.com              # Arn ve Secret bilgisi bilgisi 
    aws configure set region eu-west-1                          # ilgili region a geç
    aws configure list --profile default                        # default profilin içeriğine bak burda acces_key ve secret_key göreceksin

    # Root ile oluşturuyoruz genelde fakat işlemler bittikteen sonra güvenlik açısından silinmeli 
    aws iam delete-access-key --access-key-id ???????? --user-name haluk@example.com

- Kontrolleri localde cat ~/.aws/config & cat ~/.aws/credentials & aws configure list den de sağlayabilirsin.

Sonrasında terraform-iac/haluk-eks dizini altından 
    terraform init
    terraform plan -var-file="terraform.tfvars" -out=halukplan
    terraform apply halukplan

komutlarını çalıştırarak cluster'ı kurarsın.

# --- ! POD sayısı yetersizliğinden kaynaklı komut seti ile kurulum ! ------

eksctl create cluster --name haluk-test --without-nodegroup                                                             # Bununla master node lar oluşacak sonrasında arayüzden 30 ise 31 e upgrde başlat

kubectl delete daemonset -n kube-system aws-node                                                                        # varolan CNI'yı da  kaldıracak

kubectl create -f https://raw.githubusercontent.com/projectcalico/calico/v3.27.0/manifests/tigera-operator.yaml         # Calico CNI için tigera operator indir

kubectl create -f - <<EOF                                                                                               # Calico CNI ı kur
kind: Installation
apiVersion: operator.tigera.io/v1
metadata:
  name: default
spec:
  kubernetesProvider: EKS
  cni:
    type: Calico
  calicoNetwork:
    bgp: Disabled
EOF


eksctl create nodegroup -f - <<EOF                                                                                       # 3 instance node dan oluşan node pool oluştur 
apiVersion: eksctl.io/v1alpha5
kind: ClusterConfig
metadata:
  name: haluk-test
  region: eu-west-1
managedNodeGroups:
  - name: node-group-1
    ssh:
      allow: true
      publicKeyPath: amazon-public-key.pub                                                                               # ssh için public key file ı set et. (tf de de mevcut:  cluster_ca_certificate = base64decode(module.eks.cluster_certificate_authority_data) )
    instanceType: t3.xlarge
    desiredCapacity: 3
    minSize: 1
    maxSize: 2                                                                                                           # worker node umuz 2 adet 
    maxPodsPerNode: 250                                                                                                  # pod sayısını tek node için 250 yapabildik
    privateNetworking: true
    subnets:
      - subnet-???                                                                                                       # Availibty zone'u Private'tan seçtik subnet atadı bize bu deger speceifik o sebeple yazılmadı
EOF


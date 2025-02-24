# **CaseStudy AWS-EKS Cluster Installation (All SDLC Readme)**

## **NOTLAR**

- **Yapı AWS EKS cluster üzerinde host olacak mimari ile tasarlandı.**

  - Katmanlar namespace seviyesinde ayrıştırıldı.
  - Cluster içi erişimler **any-any açık durumda** olup, istenirse **Network Policy** ile ingress-egress kuralları uygulanabilir.
  - **Frontend (React)** configmap üzerinden **Backend'e (Node.js)** bağlanıyor, backend ise **PostgreSQL** veritabanına giderek veri okuyor ve geri dönüyor.

- **Uygulamalar MAC ortamında geliştirildi.**

  - Debian tabanlı sistemlerde **AMD mimarisi**, MAC sistemlerde **ARM mimarisi** kullanıldığından, **AWS EKS'de ARM destekli instance'lar seçildi.**

- **StorageClass tercihi:**

  - Normalde **NFS-Client** veya **Longhorn** kullanıyoruz, ancak burada defaultta **EBS oldugundan emptyDir: {}** ile EBS kullanılmış oldu.

- **AWS arayüzü kullanılmadı.**

  - **Rancher ile AWS EKS yönetimi** sağlandı. **Cattle-System Namespace** oluşturularak, Rancher Agent **EKS üzerinde import** edildi.
  - **IAM bilgileri configmap ile set edildi.**

- **Kubernetes Deployment Stratejisi**

  - **Helm değil, Kubernetes Kustomization** yapısı kullanıldı.

- **AWS EKS'deki varsayılan pod sınırı 8 olarak geliyor.**

  - AWS CNI yerine **Calico CNI kurulumu** yapılarak pod sınırı **250'ye çıkarıldı.**

---

## **FOLDER HİYERARŞİSİ**

```
│── kubernetes-platform/             # Kubernetes YAML dosyaları
│   ├── backend/                     # Backend ile ilgili YAML dosyaları
│   │   ├── backend-deployment.yaml
│   │   ├── backend-service.yaml
│   │   ├── kustomization.yaml
│   │   ├── ns.yaml
│   │
│   ├── database/                    # PostgreSQL ile ilgili YAML dosyaları
│   │   ├── configmap.yaml
│   │   ├── kustomization.yaml
│   │   ├── ns.yaml
│   │   ├── postgres-deployment.yaml
│   │   ├── postgres-service.yaml
│   │
│   ├── frontend/                     # Frontend ile ilgili YAML dosyaları
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
│── README.md                        # Bu dosya
```

---

## **CODE**

```bash
cd /Users/haluk/Desktop/Github
git clone https://github.com/halukyilmaz55/CaseStudy.git
mkdir backend && mkdir frontend && touch README.txt
```

### **Backend Gelistirme**

```bash
# Gerekli bağımlılıkları yükle
npm install express pg cors dotenv

# Node.js projesini başlat
npm init -y
npm install
npm start
node server.js
```

### **Frontend Gelistirme**

```bash
# React projesini oluştur
npx create-react-app .

# Frontend'i başlat
npm start
```

---

## **GIT Operasyonları**

```bash
echo "node_modules/" >> .gitignore

git rm -r --cached node_modules
git add .gitignore
git add .
git commit -m "Added .gitignore and removed node_modules"
git push origin main
```

---

## **CI/CD (Azure DevOps)**

Uygulamalar main branch'ında yazılacağı düşünüldü. Yoksa ayrı branching mekanizmaları işletilebilir.

‼ Pipeline içeriği ci-cd-azuredevops/azure-pipelines.yml dosyası içindedir. ‼

```bash
# Docker Image'larını Build Et ve Tag'le

docker login docker.io

# Backend için
cd /Users/haluk/Desktop/Github/CaseStudy
docker build --platform linux/amd64 -t halyil/backend-app:latest -f backend/Dockerfile backend/
docker tag halyil/backend-app:latest halyil/backend-app:v1.0
docker push halyil/backend-app:v1.0

# Frontend için
cd /Users/haluk/Desktop/Github/CaseStudy
docker build --platform linux/amd64 -t halyil/frontend-app:latest -f frontend/Dockerfile frontend/
docker tag halyil/frontend-app:latest halyil/frontend-app:v1.0
docker push halyil/frontend-app:v1.0
```

---

## **PostgreSQL DB İşlemleri**

Normal de Postgre statefulset ile kurulur.(helm template ile) Fakat burda demo oldugu için ve data kaybı önem arz etmediğinden deployment olarak kurulacak.

pgAdmin kurulup arayüz üzerinden ilgili düzenlemeler yapılabilir.

Alternatif olarak PostgreSQL pod'u üzerinden de bağlantı sağlanabilir:

*psql -U halukuser -d halukyilmaz55 -h localhost* komutu ile


```sql
-- CREATE DATABASE halukyilmaz55;
-- CREATE ROLE halukuser WITH LOGIN PASSWORD 'Ale3duysunkr@lSa3sun';
GRANT ALL PRIVILEGES ON DATABASE halukyilmaz55 TO halukuser;

-- DBA rolü oluştur
CREATE ROLE dba WITH LOGIN CREATEDB CREATEROLE SUPERUSER PASSWORD 'Ale3duysunkr@lSa3sun';
GRANT dba TO halukuser;

-- Veritabanına bağlan
\c halukyilmaz55

-- users tablosu oluştur
CREATE TABLE users (
    id SERIAL PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    email VARCHAR(150) UNIQUE NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Kullanıcı ekle
INSERT INTO users (name, email) VALUES
    ('Haluk Yılmaz', 'haluk@example.com'),
    ('Mete Kose', 'mete@example.com'),
    ('Ezgi Uslan', 'ezgi@example.com');
```

---

## **AWS Credential & Terraform Apply & Kustomization Apply**

‼ Terraform tf dosyalarını uygulamadan önce aşağıdaki düzenlemelerin yapılmış olması gerekir! ‼

tfstate dosyasını koymadım, hassas veri içerdiği için.

aws ve eksctl komut setleri localden çalıştırılıyor.

Terraform uygulamadan önce access_key ve secret_key oluşturmak şarttır.


---
Farklı bir profil oluştur

aws configure --profile free-tier

access key: ???

secret access key: ???


---
AWS ye erişimi kontrol et (root ile yaptım aslında tehlikeli farklı bir user ile oluşturulmalıydı)

aws configure list-profiles

aws sts get-caller-identity --profile free-tier


---
Default profilimi farklı region için kullanıyordum.free-tier profilimi  default yaptım

export AWS_PROFILE=free-tier

AWS_PROFILE=free-tier terraform destroy -auto-approve

AWS_PROFILE=free-tier terraform init

AWS_PROFILE=free-tier terraform plan -var-file="terraform.tfvars" -out=halukplan

AWS_PROFILE=free-tier terraform apply halukplan


---
Destroy etmek istersen komut:

AWS_PROFILE=free-tier terraform destroy -auto-approve


---
Localinden Terraform apply sonrası, EKS erişimi için aws eks update-kubeconfig komutunu çalıştırman gerekecek.

aws eks update-kubeconfig --name haluk-test --region eu-west-1 --profile free-tier

kubectl get nodes


---
Cluster ın NAT ip sini öğren ve rancher entegrasyonu için rancher makinesinin fw kurallarına tanım gir. (rancher a 443 den gidecek clusterımız)

aws ec2 describe-nat-gateways --query "NatGateways[*].NatGatewayAddresses[*].PublicIp" --region eu-west-1 --profile free-tier


---
kube-system namespace'inde aws-auth configmap'inin içeriğini editle. AWS deki kullandığın user'ın ARN'nını mapUser olarak ekle

kubectl get configmap -n kube-system aws-auth -o yaml



mapUsers: |

    - userarn: arn:aws:iam::????????:user/haluk@example.com
  
      username: haluk@example.com

      groups:

        - system:masters

  

---
Aşağıdaki komutu localde çalıştırarak, rancher agent'ını cluster a yükle cattle-system ns ayağa kalksın.

(screenshot-docs folder'ında detaylarıyla ekran goruntuleri mevcut)

kubectl apply -f https://rancher.???.com/v3/import/sz2fb645htrm???????w9h5k82pg244x84w2x??4rcrnc_c-m-qljgvzst.yaml


```bash
# AWS IAM Kullanıcı ve Anahtar İşlemleri
aws iam create-access-key --user-name haluk@example.com
aws iam list-access-keys --user-name haluk@example.com
aws iam get-user --user-name haluk@example.com
aws configure set region eu-west-1
aws configure list --profile free-tier
```

```bash
# Terraform ile AWS EKS Cluster Kurulumu
cd terraform-iac/haluk-eks
terraform init
terraform plan -var-file="terraform.tfvars" -out=halukplan
terraform apply halukplan
```

Local'den çalıştırbiliriz

*kubectl config use-context haluk-test*
*kubectl config current-context*
*kubectl apply -k CaseStudy/kubernetes-platform/*


---

## **EKS Cluster ve Calico CNI Kurulumu (Alternatif Kurulum Terraform olmadan)**

```bash
eksctl create cluster --name haluk-test --without-nodegroup
kubectl delete daemonset -n kube-system aws-node
kubectl create -f https://raw.githubusercontent.com/projectcalico/calico/v3.27.0/manifests/tigera-operator.yaml
```

```bash
cat <<EOF | kubectl apply -f -
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
```

```bash
cat <<EOF | eksctl create nodegroup -f -
apiVersion: eksctl.io/v1alpha5
kind: ClusterConfig
metadata:
  name: haluk-test
  region: eu-west-1
managedNodeGroups:
  - name: node-group-1
    ssh:
      allow: true
      publicKeyPath: amazon-public-key.pub
    instanceType: t3.xlarge
    desiredCapacity: 1
    minSize: 1
    maxSize: 1
    maxPodsPerNode: 250
    privateNetworking: true
    subnets:
      - subnet-??? # Buraya subnet ID'si girmen gerekiyor.
EOF
```


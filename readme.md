# **AWS EKS Deployment README**

## **NOTLAR**

- **Yapı AWS EKS cluster üzerinde host olacak mimari ile tasarlandı.**

  - Katmanlar namespace seviyesinde ayrıştırıldı.
  - Cluster içi erişimler **any-any açık durumda** olup, istenirse **Network Policy** ile ingress-egress kuralları uygulanabilir.
  - **Frontend (React)** configmap üzerinden **Backend'e (Node.js)** bağlanıyor, backend ise **PostgreSQL** veritabanına giderek veri okuyor ve geri dönüyor.

- **Uygulamalar MAC ortamında geliştirildi.**

  - Debian tabanlı sistemlerde **AMD mimarisi**, MAC sistemlerde **ARM mimarisi** kullanıldığından, **AWS EKS'de ARM destekli instance'lar seçildi.**

- **StorageClass tercihi:**

  - Normalde **NFS-Client** veya **Longhorn** kullanıyoruz, ancak burada **EBS yerine emptyDir: {}** kullanıldı.

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

### **Backend Kurulumu**

```bash
# Node.js projesini başlat
npm init -y
npm install
npm start
node server.js

# Gerekli bağımlılıkları yükle
npm install express pg cors dotenv
```

### **Frontend Kurulumu**

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

```bash
# Docker Image'larını Build Et ve Tag'le

docker login

# Backend için
docker build -t halyil/backend-app:latest -f backend/Dockerfile backend/
docker tag halyil/backend-app:latest halyil/backend-app:v1.0
docker push halyil/backend-app:v1.0

# Frontend için
docker build -t halyil/frontend-app:latest -f frontend/Dockerfile frontend/
docker tag halyil/frontend-app:latest halyil/frontend-app:v1.0
docker push halyil/frontend-app:v1.0
```

---

## **PostgreSQL DB İşlemleri**

```sql
CREATE DATABASE halukyilmaz55;
CREATE ROLE halukuser WITH LOGIN PASSWORD 'Ale3duysunkr@lSa3sun';
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
    ('Ahmet Kaya', 'mete@example.com'),
    ('Mehmet Demir', 'ezgi@example.com');
```

---

## **AWS Credential & Terraform Apply**

```bash
# AWS IAM Kullanıcı ve Anahtar İşlemleri
aws iam create-access-key --user-name haluk@example.com
aws iam list-access-keys --user-name haluk@example.com
aws iam get-user --user-name haluk@example.com
aws configure set region eu-west-1
aws configure list --profile default
```

```bash
# Terraform ile AWS EKS Cluster Kurulumu
terraform init
terraform plan -var-file="terraform.tfvars" -out=halukplan
terraform apply halukplan
```

---

## **EKS Cluster ve Calico CNI Kurulumu**

```bash
eksctl create cluster --name haluk-test --without-nodegroup
kubectl delete daemonset -n kube-system aws-node
kubectl create -f https://raw.githubusercontent.com/projectcalico/calico/v3.27.0/manifests/tigera-operator.yaml
```

```yaml
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
```

```yaml
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
    desiredCapacity: 3
    minSize: 1
    maxSize: 2
    maxPodsPerNode: 250
    privateNetworking: true
    subnets:
      - subnet-???
```


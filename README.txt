
NOTLAR: 

- Uygulamalar MAC de oluşturuldu. 
    Debian tabanlı sistemlerde code derlenirken AMD olarak MAC de ARM olarak derlendiğinden bu runtimeda sorun oluşturuyor.Ben MAC de hazırladım.
    Değerlendirme yaparken buna dikkat edebilirsiniz.

- storageClass olarak biz normalde nfs-clinet veya longhorn tercih ediyoruz. EBS kullanmıyoruz. Fakat burda emptyDir: {} kullanıldı defaultta EBS kullanacaktır.

- AWS'nin arayüzünü kullanım için tercih etmedim. Rancher'a generic cluster ekleyerek EKS cluster ını Rancher üzerinden yönetiyorum. (.kubeconfig dosyasında EKS cluster ın contex bilgileri ve token'ı yer alıyor.)

- Uygulamalarımı deploy ederken helm değil kubernetes kustomization yapısını kullanıyorum.

------------FOLDER HİYERARŞİSİ----------

│── kubernetes/                     # Kubernetes YAML dosyaları
│   ├── frontend-deployment.yaml
│   ├── frontend-service.yaml
│   ├── backend-deployment.yaml
│   ├── backend-service.yaml
│   ├── postgres-deployment.yaml
│   ├── postgres-service.yaml
│   ├── configmap.yaml
│── backend/                  # Backend (Node.js)
│   ├── Dockerfile
│   ├── package.json
│   ├── server.js
│── frontend/                 # Frontend (React)
│   ├── Dockerfile
│   ├── package.json
│   ├── src/
│── README.md


--------- CODE -------

cd /Users/haluk/Desktop/Github
git clone https://github.com/halukyilmaz55/CaseStudy.git
mkdir backend && mkdir frontend && touch README.txt




# BACKEND

# Node.js projesini başlat
npm init -y

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


--------CI-CD----------

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

CREATE DATABASE halukyilmaz55;
CREATE ROLE halukuser WITH LOGIN PASSWORD 'Ale3duysunkr@lSa3sun';
GRANT ALL PRIVILEGES ON DATABASE halukyilmaz55 TO halukuser;
CREATE ROLE dba WITH LOGIN CREATEDB CREATEROLE SUPERUSER PASSWORD 'Ale3duysunkr@lSa3sun';
CREATE ROLE dba WITH LOGIN PASSWORD 'Ale3duysunkr@lSa3sun';
GRANT ALL PRIVILEGES ON DATABASE halukyilmaz55 TO halukuser;
GRANT ALL PRIVILEGES ON ALL TABLES IN SCHEMA public TO halukuser;
GRANT ALL PRIVILEGES ON ALL SEQUENCES IN SCHEMA public TO halukuser;
GRANT dba TO halukuser;
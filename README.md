# AWS Üzerinde 3 Tier Proje için Landing Zone

## 📌 Notlar

- Yapı **AWS EKS** cluster üzerinde host olacak mimari ile tasarlandı. Katmanlar namespace seviyesinde ayrıştırıldı. Cluster içi erişimler herhangi bir açık durumda istenirse **Network Policy** ile ingress/egress uygulanır.
- Uygulamaları **Mac** cihazda oluşturuldu. Debian tabanlı sistemlerde code derlenirken **AMD** olarak, **Mac**'de **ARM** olarak derlendiğinden bu durumda runtime sorun oluşturabilir. **Mac ile hazırlandı**, değerlendirirken bunu göz önünde bulundurabilirsiniz.
- **StorageClass** olarak **nfs-client** veya **longhorn** yerine **EBS** tercih ediliyor. Varsayılan olarak `emptyDir: {}` kullanılmaktadır.
- AWS'nin arayüzünü **kullanım için tercih etmedim**. Bunun yerine **Rancher** kullanarak **EKS cluster** ekleyip Rancher üzerinden yönetiyorum. (`.kubeconfig` dosyasında EKS cluster için context bilgileri ve token bilgileri yer almaktadır.)
- Uygulamaları **deploy ederken** **Helm** değil, **Kubernetes Kustomization** yapısını kullanıyorum.
- **Veritabanı olarak PostgreSQL kullanılıyor** ve backend API bu veritabanına bağlanarak çalışıyor.

---

## 📂 Folder Hiyerarşisi

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


---

## 🚀 PostgreSQL Veritabanı Kurulumu

PostgreSQL veritabanını **lokalde veya Kubernetes pod'u üzerinde** çalıştırabilirsin.  


🔌 PostgreSQL Bağlantısı
PostgreSQL'e bağlanmak için:
kubectl exec -it postgres-pod -- psql -U postgres -h localhost

🔑 PostgreSQL Kullanıcı ve Yetkilendirme İşlemleri
PostgreSQL'e bağlandıktan sonra aşağıdaki SQL komutlarını çalıştırarak veritabanı ve kullanıcı rollerini oluşturabilirsin:



CREATE DATABASE halukyilmaz55;

-- Kullanıcı oluştur
CREATE ROLE halukuser WITH LOGIN PASSWORD 'Ale3duysunkr@lSa3sun';

-- Yetkileri ata
GRANT ALL PRIVILEGES ON DATABASE halukyilmaz55 TO halukuser;
GRANT ALL PRIVILEGES ON ALL TABLES IN SCHEMA public TO halukuser;
GRANT ALL PRIVILEGES ON ALL SEQUENCES IN SCHEMA public TO halukuser;

-- DBA rolü oluştur ve yetki ver
CREATE ROLE dba WITH LOGIN CREATEDB CREATEROLE SUPERUSER PASSWORD 'Ale3duysunkr@lSa3sun';
GRANT dba TO halukuser;
Eğer pgAdmin kullanıyorsan, veritabanını GUI arayüzünden de yönetebilirsin.




🛠️ Backend API Kurulumu

cd backend
npm init -y  # Node.js projesini başlat
npm install express pg cors dotenv  # Gerekli bağımlılıkları yükle
node server.js  # Backend'i başlat



🎨 Frontend Kurulumu
cd frontend
npx create-react-app .  # React projesini oluştur
npm start  # Frontend'i başlat


📦 Docker Image Build Etme
docker build -t halyil/backend-app:latest -f backend/Dockerfile backend/
docker build -t halyil/frontend-app:latest -f frontend/Dockerfile frontend/


🔖 Image’ları Tagleme
docker tag halyil/backend-app:latest halyil/backend-app:v1.0
docker tag halyil/frontend-app:latest halyil/frontend-app:v1.0


📤 DockerHub’a Push Etme
docker push halyil/backend-app:v1.0
docker push halyil/frontend-app:v1.0


🛠️ Kubernetes Deployment
ConfigMap ve Secret'ları oluştur
kubectl apply -f kubernetes/configmap.yaml
kubectl apply -f kubernetes/secret.yaml


PostgreSQL Veritabanını Deploy Et
kubectl apply -f kubernetes/postgres-deployment.yaml
kubectl apply -f kubernetes/postgres-service.yaml

Backend API'yi Deploy Et
kubectl apply -f kubernetes/backend-deployment.yaml
kubectl apply -f kubernetes/backend-service.yaml

Frontend Uygulamasını Deploy Et
kubectl apply -f kubernetes/frontend-deployment.yaml
kubectl apply -f kubernetes/frontend-service.yaml

🔗 GIT Operasyonları
git add .
git commit -m "Initial commit"
git push origin main
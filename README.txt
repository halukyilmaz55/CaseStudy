
NOT: Uygulamalar MAC de oluşturuldu. 
Debian tabanlı sistemlerde code derlenirken AMD olarak MAC de ARM olarak derlendiğinden bu runtimeda sorun oluşturuyor.Ben MAC de hazırladım.
Değerlendirme yaparken buna dikkat edebilirsiniz.


--------- CODE -------

cd /Users/haluk/Desktop/Github
git clone https://github.com/halukyilmaz55/CaseStudy.git
mkdir backend && mkdir frontend && touch README.txt




# BACKEND

# Node.js projesini başlat
npm init -y

# Gerekli bağımlılıkları yükle
npm install express pg cors dotenv

# Backend'i başlat
node server.js

--------



# FRONTEND

# React projesini oluştur
npx create-react-app .

# Frontend i başlat
npm start

----------

# GIT operasyonları

echo "node_modules/" >> .gitignore (içine aşağıdakileri ekle)

node_modules/
.env
.DS_Store
*.log

---CODE lar eklendi


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

# localimde run etmek istersem

# Backend uygulamasını çalıştır
docker run -d -p 5000:5000 halyil/backend-app:latest

# Frontend uygulamasını çalıştır
docker run -d -p 3000:3000 halyil/frontend-app:latest


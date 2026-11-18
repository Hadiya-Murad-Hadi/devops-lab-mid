# DevOps Lab Midterm Report
**Student Reg No:** FA23-BDS-012
**GitHub repo:** https://github.com/<user>/<repo>
**EC2 metrics URL:** http://16.170.67.170:8000/metrics
**Sender email:** hadiyamurad04@gmail.com

## 1. Dataset and repository  (screenshot each)
- [ ] `configs/FA23-BDS-012.json` copied to `config.json`
- [ ] `python generate_dataset.py` output
- [ ] GitHub repo file list showing `config.json` and `dataset/train.csv`
- [ ] Settings -> Collaborators showing qasimalik@gmail.com

## 2. AWS EC2  (screenshot each)
- [ ] Instance running (type, Elastic IP)
- [ ] Security group inbound rules: 22, 8080, 8000

## 3. Jenkins setup  (screenshot each)
- [ ] Job `MIDTERM-FA23-BDS-012` configuration (GitHub hook trigger ticked, SCM + Jenkinsfile path)
- [ ] Email Extension SMTP settings (hide password)

## 4. Pipeline scripts
Paste full text of `Jenkinsfile` and `Dockerfile` here.

## 5. Webhook  (screenshot)
- [ ] GitHub Settings -> Webhooks -> Recent Deliveries with green tick (HTTP 200)

## 6. Automatic run after push  (screenshot)
- [ ] Commit that changed `dataset/train.csv`
- [ ] Build started automatically ("Started by GitHub push")
- [ ] Console output: Train -> Test -> Docker Build -> Deploy all green
- [ ] Browser at /metrics: training_rows / model_version / git_sha changed after the push

## 7. POST /predict  (screenshot)
Example: curl -X POST http://<IP>:8000/predict -H "Content-Type: application/json" -d '{"records":[{...}]}'

## 8. Email  (screenshot)
- [ ] Received email with Reg No in the subject and the correct From address

## 9. Challenges / notes

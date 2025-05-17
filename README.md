#  專案環境說明文件

## OCI Always Free ARM VM Setup – Terraform + Ansible 自動化架構

本專案設計目標為：**在 Oracle Cloud Always Free 資源下，自動化部署 Ubuntu ARM VM、強化系統安全，並建構可擴展的 Docker 容器化基礎設施**。

---

##  開發與執行環境

| 類別           | 工具/版本              | 說明                           |
| ------------ | ------------------ | ---------------------------- |
| 作業系統         | Ubuntu 24.04.2 LTS | 運行於 Oracle ARM VM            |
| Terraform    | >= 1.3             | 管理 OCI VM 資源                 |
| Ansible      | >= 2.10            | 自動化系統硬化、Docker 安裝等           |
| Oracle Cloud | Always Free Tier   | 使用 2 台 `VM.Standard.A1.Flex` |
| 實體架構         | ARM64 (aarch64)    | 適用 Docker ARM 映像檔            |

---

##  專案目錄結構

```bash
.
├── terraform/
│   ├── main.tf              # 定義 VM、VNIC、Image 等資源
│   ├── outputs.tf           # 輸出 Public IP, OCID 等資訊
│   ├── variables.tf         # 可參數化變數設置
├── ansible/
│   ├── inventory.ini        # VM 清單 (Terraform output 手動填寫)
│   ├── setup-basic.yaml     # 安裝工具、設定 NTP、firewalld、fail2ban
│   └── install-docker.yaml  # 安裝 Docker Engine 與 Docker Compose
└── README.md
```

---

##  Oracle Cloud VM 資源概況

| 項目    | 說明                             |
| ----- | ------------------------------ |
| VM 類型 | `VM.Standard.A1.Flex` (ARM 架構) |
| 配置    | 每台 VM：2 OCPUs / 12 GB RAM      |
| 數量    | 2 台 Always Free VM             |
| 區域    | 依照 `var.region` 設定             |
| 公網 IP | Terraform 自動分配，並以 output 顯示    |

---

##  基礎硬化內容（via Ansible）

### `setup-basic.yaml`

* 升級系統與安裝常用工具（vim、curl、net-tools...）
* 設定時區為 `Asia/Taipei`
* 使用 Google Public NTP (via `chrony`)
* 啟用 `firewalld` 並允許：

  * SSH (`port 22`)
  * ICMP echo（ping）
* 啟用 `fail2ban` 防止暴力破解

---

##  Docker 安裝內容（via Ansible）

### `install-docker.yaml`

* 設定 Docker 官方 APT 倉庫
* 安裝：

  * Docker Engine
  * containerd
  * Docker CLI
* 安裝 Docker Compose（`aarch64` 版本）
* 驗證安裝版本

---

##  操作流程

### 1️ 使用 Terraform 建立 VM

```bash
cd terraform/
terraform init
terraform apply
```

取得 VM Public IP：

```bash
terraform output instance_public_ip_1
terraform output instance_public_ip_2
```

###  將 IP 寫入 Ansible Inventory

```ini
[ubuntu_arm]
free-arm-vm-1 ansible_host=<IP1> ansible_user=ubuntu ansible_ssh_private_key_file=./oracle_vm_rsa
free-arm-vm-2 ansible_host=<IP2> ansible_user=ubuntu ansible_ssh_private_key_file=./oracle_vm_rsa
```

### 3 使用 Ansible 配置 VM

```bash
cd ansible/
ansible-playbook -i inventory.ini setup-basic.yaml
ansible-playbook -i inventory.ini install-docker.yaml
```

---

## 計畫中的擴充項目（TODO）

* [ ] 改用 **動態 Ansible Inventory**（從 Terraform JSON 自動解析）
* [ ] 模組化 Terraform（分離 VCN / Subnet / VM）
* [ ] 防火牆強化（只允許必要 port）
* [ ] 安裝 `prometheus-node-exporter` 以監控資源
* [ ] 自動產生 VM 使用者帳號與隨機密碼（寫入 Terraform output）

---

##  備註

* **Always Free 限制提醒**：

  * ARM VM 使用上限為 4 OCPU + 24 GB RAM
  * Public IP 數量最多 2 個
  * 區網流量無限制，但出網每月 10TB


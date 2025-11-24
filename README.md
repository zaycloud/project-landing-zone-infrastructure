```mermaid
graph TD
    user((👷 Developer))
    
    subgraph "GCP Project: zayn-lz"
        direction TB
        
        subgraph "Management"
            stateBucket["🪣 GCS Bucket<br/>(Terraform State)"]
        end

        subgraph "VPC Network (10.0.0.0/20)"
            fw["🛡️ Firewall<br/>(Deny All Ingress)"]
            router["Cloud Router + Cloud NAT<br/>(Egress Only)"]
            
            subgraph "Private Subnet"
                gke[☸️ GKE Autopilot Cluster]
                nodes["📦 Private Nodes<br/>(No Public IP)"]
            end
        end
    end

    %% Connections
    user -- "./create-environment.sh" --> stateBucket
    user -- "kubectl" --> gke
    gke --> nodes
    nodes -- "Pull Images" --> router
    router -- "Secure Internet Access" --> internet((☁️ Internet))
    
    %% Styling
    classDef plain fill:#fff,stroke:#333,stroke-width:1px;
    classDef blue fill:#e8f0fe,stroke:#4285F4,stroke-width:2px;
    classDef red fill:#fce8e6,stroke:#EA4335,stroke-width:2px;
    
    class gke,nodes,stateBucket blue;
    class fw red;
    class router,internet plain;
```

# Secure GCP Infrastructure Landing Zone (GKE Autopilot)

![Terraform](https://img.shields.io/badge/Terraform-v1.5+-623CE4?style=for-the-badge&logo=terraform&logoColor=white)
![Google Cloud](https://img.shields.io/badge/Google_Cloud-4285F4?style=for-the-badge&logo=google-cloud&logoColor=white)
![Kubernetes](https://img.shields.io/badge/GKE-Autopilot-326CE5?style=for-the-badge&logo=kubernetes&logoColor=white)

## 📖 Om Projektet
Detta projekt är en produktionsredo Infrastructure-as-Code (IaC) lösning som sätter upp en säker Kubernetes-miljö på Google Cloud.

Istället för manuell konfiguration ("ClickOps"), använder detta projekt modulär Terraform för att garantera att infrastrukturen är **säker**, **upprepbar** och **versionshanterad**.

### Tekniska Höjdpunkter
* **GKE Autopilot:** Ett helt managera Kubernetes-kluster som följer Googles "Hardening Guidelines".
* **Private Nodes:** Klustret är konfigurerat med `enable_private_nodes = true`, vilket innebär att servrarna är helt isolerade från det publika internet.
* **Zero Trust Nätverk:** VPC:n är låst med en `deny-all` brandväggsregel som standard. Utgående trafik hanteras via **Cloud NAT**.
* **Automated State Management:** Ett custom shell-script hanterar initieringen av Terraform Remote State backend automatiskt.

---

## Arkitektur

Systemet är uppbyggt i lager:

1.  **Network Layer (`modules/network`):**
    * Custom VPC (ingen default VPC).
    * Privata Subnets för noder, pods och services.
    * Cloud NAT för säker patchning av noder.
2.  **Compute Layer (`modules/gke-autopilot`):**
    * GKE Autopilot Cluster (Serverless K8s).
    * IP Masquerading och Private Endpoint-konfiguration.
3.  **Orchestration (`live/dev`):**
    * Binder ihop modulerna och hanterar API-aktivering (`compute.googleapis.com`, `container.googleapis.com`).

---

## 🚀 Kom igång (Mac/Linux)

Jag har inkluderat ett hjälpscript för att förenkla uppsättningen och hanteringen av Remote State.

### 1. Förberedelser
Se till att du har `gcloud` CLI och `terraform` installerat.

```bash
# Logga in i GCP
gcloud auth application-default login

2. chmod +x scripts/create-environment.sh
./scripts/create-environment.sh

3. Anslut till Klustret
När scriptet är klart får du ett kommando för att ansluta kubectl till ditt nya kluster:

01-secure-landing-zone/
├── scripts/
│   └── create-environment.sh  # Automatiserar init & apply
├── modules/
│   ├── network/               # VPC, NAT, Firewall-logik
│   └── gke-autopilot/         # Kluster-konfiguration
├── live/
│   └── dev/                   # Dev-miljöns konfiguration
│       ├── main.tf            # Huvudfil som anropar moduler
│       └── terraform.tfvars   # Miljöspecifika variabler
└── README.md
```